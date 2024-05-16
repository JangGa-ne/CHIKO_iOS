//
//  ReDeliveryPaymentVC.swift
//  market
//
//  Created by 장 제현 on 3/28/24.
//

/// 번역완료

import UIKit

class ReDeliveryPaymentTC: UITableViewCell {
    
    @IBOutlet var labels: [UILabel]!
    
    @IBOutlet weak var itemName_label: UILabel!
    @IBOutlet weak var optionName_label: UILabel!
    @IBOutlet weak var optionWeight_label: UILabel!
}

class ReDeliveryPaymentVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var action: String = "normal"
    var OrderObject: ReOrderData = ReOrderData()
    var item_name: String = ""
    var total_option_weight: Double = 0.0
    var total_delivery_price: Int = 0
    var payment_type: String = ""
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    /// 오늘의 환율
    @IBOutlet weak var exchangeRate_sv: UIStackView!
    @IBOutlet weak var krw_label: UILabel!
    @IBOutlet weak var Cny_label: UILabel!
    /// 물류비
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_height: NSLayoutConstraint!
    @IBOutlet weak var totalWeight_label: UILabel!
    @IBOutlet weak var totalPrice_label: UILabel!
    /// 결제수단
    @IBOutlet weak var overseasCard_img: UIImageView!
    @IBOutlet weak var overseasCard_label: UILabel!
    @IBOutlet weak var overseasCard_btn: UIButton!
    @IBOutlet weak var aliPay_img: UIImageView!
    @IBOutlet weak var aliPay_label: UILabel!
    @IBOutlet weak var aliPay_btn: UIButton!
    @IBOutlet weak var wechatPay_img: UIImageView!
    @IBOutlet weak var wechatPay_label: UILabel!
    @IBOutlet weak var wechatPay_btn: UIButton!
    /// 결제하기
    @IBOutlet weak var deliveryPayment_sv: UIStackView!
    @IBOutlet weak var deliveryPayment_btn: UIButton!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in label.text = translation(label.text!) }
        buttons.forEach { btn in btn.setTitle(translation(btn.title(for: .normal)), for: .normal) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReDeliveryPaymentVCdelegate = self
        
        if OrderObject.order_item.count > 0 {
            item_name = OrderObject.order_item.count == 1 ? OrderObject.order_item[0].item_name : "\(OrderObject.order_item[0].item_name) 외 \(OrderObject.order_item.count-1)개"
        }
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = .zero }
        tableView.delegate = self; tableView.dataSource = self
        
        var total_height: CGFloat = 0.0
        OrderObject.order_item.forEach { item in
            total_height += CGFloat(item.item_option.count*25)+35
            item.item_option.forEach { option in
                total_option_weight += (option.weight * Double(option.quantity))
            }
        }
        tableView_height.constant = total_height
        
        exchangeRate_sv.isHidden = (OrderObject.ch_total_delivery_price != 0.0)
        if OrderObject.ch_total_delivery_price == 0.0 {
            requestExchangeRate { status in
                self.krw_label.text = String(PaymentObject.exchange_rate)
                self.totalWeight_label.text = "\(priceFormatter.string(from: PaymentObject.dpcostperkg as NSNumber) ?? "0") x \(String(format: "%.1f", self.total_option_weight).replacingOccurrences(of: ".0", with: ""))kg"
                self.totalPrice_label.attributedText = attributedPriceString(krw: Int(self.total_option_weight*Double(PaymentObject.dpcostperkg)), cny: self.total_option_weight*Double(PaymentObject.dpcostperkg)/PaymentObject.exchange_rate)
            }
        } else {
            totalWeight_label.text = "\(priceFormatter.string(from: Double(OrderObject.kr_total_delivery_price)/self.total_option_weight as NSNumber) ?? "0") x \(String(self.total_option_weight).replacingOccurrences(of: ".0", with: ""))kg"
            totalPrice_label.attributedText = attributedPriceString(krw: OrderObject.kr_total_delivery_price, cny: OrderObject.ch_total_delivery_price)
        }
        /// 결제수단
        ([overseasCard_img, aliPay_img, wechatPay_img] as [UIImageView]).forEach { img in
            img.image = UIImage(named: "check_off")
        }
        ([overseasCard_label, aliPay_label, wechatPay_label] as [UILabel]).forEach { label in
            label.textColor = .black.withAlphaComponent(0.3)
        }
        ([overseasCard_btn, aliPay_btn, wechatPay_btn] as [UIButton]).enumerated().forEach { i, btn in
            btn.isSelected = false
            btn.tag = i; btn.addTarget(self, action: #selector(paymentType_btn(_:)), for: .touchUpInside)
        }
        /// 결제하기
        deliveryPayment_sv.isHidden = (OrderObject.ch_total_delivery_price != 0.0)
        deliveryPayment_btn.addTarget(self, action: #selector(deliveryPayment_btn(_:)), for: .touchUpInside)
    }
    
    @objc func paymentType_btn(_ sender: UIButton) {
        
        if sender == overseasCard_btn {
            payment_type = "OPCARD"
        } else if sender == aliPay_btn {
            payment_type = "ALIPAY"
        } else if sender == wechatPay_btn {
            payment_type = "WECHATPAY"
        }
        
        ([overseasCard_img, aliPay_img, wechatPay_img] as [UIImageView]).enumerated().forEach { i, img in
            img.image = i == sender.tag ? UIImage(named: "check_on") : UIImage(named: "check_off")
        }
        ([overseasCard_label, aliPay_label, wechatPay_label] as [UILabel]).enumerated().forEach { i, label in
            label.textColor = i == sender.tag ? .black : .black.withAlphaComponent(0.3)
        }
        ([overseasCard_btn, aliPay_btn, wechatPay_btn] as [UIButton]).enumerated().forEach { i, btn in
            btn.isSelected = i == sender.tag
        }
    }
    
    @objc func deliveryPayment_btn(_ sender: UIButton) {
        
        if payment_type == "" {
            customAlert(message: "결제수단을 선택해 주세요.", time: 1)
        } else {
            
            let segue = storyboard?.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
            segue.type = "물류"
            segue.payment_type = payment_type
            segue.item_name = "물류비(\(totalPrice_label.text!))"
            if OrderObject.ch_total_delivery_price == 0.0 {
                segue.cny_cash = String(format: "%.2f", total_option_weight*Double(PaymentObject.dpcostperkg)/PaymentObject.exchange_rate).replacingOccurrences(of: ".", with: "")
            } else {
                segue.cny_cash = String(format: "%.2f", OrderObject.ch_total_delivery_price).replacingOccurrences(of: ".", with: "")
            }
            navigationController?.pushViewController(segue, animated: true, completion: {
                self.customLoadingIndicator(animated: false)
            })
        }
    }
    
    func payment(status: Int) {
        
        switch status {
        case 200:
            
            var status_code: Int = 500
            let timestamp = setGMTUnixTimestamp()

            customLoadingIndicator(text: "물류비 결제 중...", animated: true)
                
            let params: [String: Any] = [
                "action": "set_dpcost",
                "store_id": StoreObject.store_id,
                "AuthCode": "",
                "AuthDate": "",
                "BuyerEmail": MemberObject.member_email,
                "MID": "",
                "Amt": String(format: "%.2f", total_option_weight*Double(PaymentObject.dpcostperkg)/PaymentObject.exchange_rate).replacingOccurrences(of: ".", with: ""),
                "TID": "",
                "GoodsName": "\(item_name)의 물류비",
                "MallReserved": "",
                "Currency": "CNY",
                "PayMethod": payment_type,
                "name": MemberObject.member_name,
                "mallUserID": "",
                "MOID": "",
                "ResultMsg": "success",
                "ResultCode": "",
                "weight": total_option_weight,
                "kr_price": Int(total_option_weight*Double(PaymentObject.dpcostperkg)),
                "ch_price": (total_option_weight*Double(PaymentObject.dpcostperkg)/PaymentObject.exchange_rate*100).rounded()/100,
                "dpre_key": "dpre\(timestamp)",
                "order_key": OrderObject.order_key,
                "order_id": MemberObject.member_id,
                "order_name": MemberObject.member_name,
                "order_position": MemberObject.member_grade,
                "order_datetime": String(timestamp),
                "payment_type": payment_type,
            ]
            
            var ReceiptObject: ReceiptData = ReceiptData()
            /// DpCost Receipt 요청
            dispatchGroup.enter()
            requestReReceipt(action: "set_dpcost", params: params) { _, object, status in
                /// Order 요청
                if status == 200, let delegate = ReOrderVCdelegate {
                    dispatchGroup.enter()
                    delegate.loadingData {
                        dispatchGroup.leave()
                    }
                }; ReceiptObject = object; status_code = status; dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                
                self.customLoadingIndicator(animated: false)
                
                switch status_code {
                case 200:
                    
                    if let delegate1 = ReOrderVCdelegate {
                        
                        self.customLoadingIndicator(text: "처리 중...", animated: true)
                        
                        if let matchedData = delegate1.ReOrderArray.first(where: { $0.order_key == ReceiptObject.order_key }) {
                            if let delegate2 = ReOrderDetailVCdelegate {
                                delegate2.OrderObject = matchedData; delegate2.tableView.reloadData()
                            }
                            self.alert(title: "", message: "물류비 결제가\n정상적으로 완료되었습니다.", style: .alert, time: 1) {
                                self.navigationController?.popViewController(animated: true)
                            }
                        } else {
                            self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1) {
                                /// 결제 취소하는 로직 필요함
                            }
                        }
                        
                        self.customLoadingIndicator(animated: false)
                    }
                default:
                    self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1) {
                        /// 결제 취소하는 로직 필요함
                    }
                }
            }
        default:
            self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
        
        PaymentVCdelegate = nil
    }
}

extension ReDeliveryPaymentVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if OrderObject.order_item.count > 0 { return OrderObject.order_item.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let data = OrderObject.order_item[section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReDeliveryPaymentTCT") as! ReDeliveryPaymentTC
        
        cell.itemName_label.text = data.item_name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if OrderObject.order_item[section].item_option.count > 0 { return OrderObject.order_item[section].item_option.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let option = OrderObject.order_item[indexPath.section].item_option[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReDeliveryPaymentTC", for: indexPath) as! ReDeliveryPaymentTC
        
        cell.optionName_label.text = "\(translation(option.color))+\(translation(option.size)) / \(String(format: NSLocalizedString("개", comment: ""), String(option.quantity)))"
        cell.optionWeight_label.text = "\(String(Double(option.quantity) * option.weight).replacingOccurrences(of: ".0", with: ""))kg"
        
        return cell
    }
}

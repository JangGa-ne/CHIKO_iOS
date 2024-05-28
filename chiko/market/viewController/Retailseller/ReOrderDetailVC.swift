//
//  ReOrderDetailVC.swift
//  market
//
//  Created by 장 제현 on 12/22/23.
//

/// 번역완료

import UIKit

class ReOrderDetailTC: UITableViewCell {
    
    var OrderItemObject: ReOrderItemData = ReOrderItemData()
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var deliveryPayment_v: UIView!
    @IBOutlet weak var deliveryPayment_btn: UIButton!
    @IBOutlet weak var deliveryReceipt_v: UIView!
    @IBOutlet weak var deliveryTracking_btn: UIButton!
    @IBOutlet weak var deliveryReceipt_btn: UIButton!
    
    @IBOutlet weak var orderId_label: UILabel!
    @IBOutlet weak var orderDatetime_label: UILabel!
    @IBOutlet weak var itemPrice_label: UILabel!
    @IBOutlet weak var deliveryPrice_label: UILabel!
    
    @IBOutlet weak var Address_label: UILabel!
    @IBOutlet weak var AddressDetail_label: UILabel!
    @IBOutlet weak var Name_label: UILabel!
    @IBOutlet weak var Num_label: UILabel!
    
    @IBOutlet weak var item_img_v: UIView!
    @IBOutlet weak var item_img: UIImageView!
    @IBOutlet weak var itemName_btn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_heignt: NSLayoutConstraint!
    
    @IBOutlet weak var optionName_label: UILabel!
    @IBOutlet weak var optionQuantity_label: UILabel!
    @IBOutlet weak var enterQuantity_label: UILabel!
    @IBOutlet weak var enterDate_label: UILabel!
    @IBOutlet weak var optionPrice_label: UILabel!
    
    @IBOutlet weak var totalItemPrice_label: UILabel!
    @IBOutlet weak var totalDeliveryPrice_label: UILabel!
    @IBOutlet weak var totalPrice_label: UILabel!
    
    func viewDidLoad() {
        
        tableView.delegate = nil; tableView.dataSource = nil
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        
        var total_height: CGFloat = 0.0
        OrderItemObject.item_option.forEach { option in
            total_height += 50
            total_height += option.enter_quantity == 0 ? 0 : 20
            total_height += option.enter_date == "" || option.enter_quantity == option.quantity ? 0 : 20
        }
        tableView_heignt.constant = total_height
    }
}

extension ReOrderDetailTC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if OrderItemObject.item_option.count > 0 { return OrderItemObject.item_option.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = OrderItemObject.item_option[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReOrderDetailItemOptionTC", for: indexPath) as! ReOrderDetailTC
        
        cell.labels.forEach { label in label.text = translation(label.text!) }
        
        if (data.price-OrderItemObject.item_sale_price) < 0 {
            cell.optionName_label.text = "\(translation("옵션.")) \(translation(data.color)) + \(translation(data.size)) (-₩\(priceFormatter.string(from: -(data.price-OrderItemObject.item_sale_price) as NSNumber) ?? "0"))"
        } else {
            cell.optionName_label.text = "\(translation("옵션.")) \(translation(data.color)) + \(translation(data.size)) (+₩\(priceFormatter.string(from: (data.price-OrderItemObject.item_sale_price) as NSNumber) ?? "0"))"
        }
        cell.optionQuantity_label.text = "\(translation("주문수량.")) \(String(format: NSLocalizedString("개", comment: ""), String(data.quantity)))"
        cell.enterQuantity_label.isHidden = (data.enter_quantity == 0)
        cell.enterQuantity_label.text = "\(translation("입고수량.")) \(String(format: NSLocalizedString("개", comment: ""), String(data.enter_quantity)))"
        cell.enterDate_label.isHidden = (data.enter_date == "")
        let content = NSMutableAttributedString()
        content.append(NSAttributedString(string: translation("재입고예정일.")+" ", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.black
        ]))
        content.append(NSAttributedString(string: translation(data.enter_date), attributes: [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.systemRed
        ]))
        cell.enterDate_label.attributedText = content
        cell.optionPrice_label.text = "₩\(priceFormatter.string(from: (data.price*data.quantity) as NSNumber) ?? "0")"
        
        return cell
    }
}

class ReOrderDetailVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var action: String = "normal"
    var OrderObject: ReOrderData = ReOrderData()
    
    var delivery_price_zero: Bool = false
    var delivery_total_price: Int = 0
    
    var order_total: Int = 0
    var total_price: Int = 0
    var total_vat: Int = 3
    
    @IBOutlet var labels: [UILabel]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in label.text = translation(label.text!) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReOrderDetailVCdelegate = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
    }
}

extension ReOrderDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0, !OrderObject.delivery_price_state {
            return 1
        } else if section == 1 {
            return 1
        } else if section == 2, OrderObject.order_item.count > 0 {
            return OrderObject.order_item.count
        } else if section == 3 {
            return 1
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 2 {
            
            let data = OrderObject.order_item[indexPath.row]
            guard let cell = cell as? ReOrderDetailTC else { return }
            
            setKingfisher(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 10)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            
        if indexPath.section == 2 {
            
            guard let cell = cell as? ReOrderDetailTC else { return }
            
            cancelKingfisher(imageView: cell.item_img)
            cell.removeFromSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReOrderDetailTC1", for: indexPath) as! ReOrderDetailTC
            
            cell.labels.forEach { label in
                if label.text!.contains("상품 입고 후의 검수를") {
                    label.text = translation("상품 입고 후의 검수를 거쳐 물류비가 적용될 예정입니다.\n물류비 미납 시 상품은 배송되지 않으며, 알림이 공지된 후 일정 기간 내에 결제가 이루어지지 않을 경우 폐기될 수 있습니다.")
                } else {
                    label.text = translation(label.text!)
                }
            }
            cell.buttons.forEach { btn in btn.setTitle(translation(btn.title(for: .normal)), for: .normal) }
            
            cell.deliveryPayment_v.isHidden = !((OrderObject.order_state == "상품준비중") || (OrderObject.order_state == "배송준비중" && OrderObject.ch_total_delivery_price == 0.0))
//            cell.deliveryPayment_btn.isHidden = delivery_price_zero && (OrderObject.order_state != "배송준비중")
            cell.deliveryPayment_btn.isHidden = (OrderObject.order_state != "배송준비중")
            cell.deliveryPayment_btn.setTitle(translation("물류비 결제하기"), for: .normal)
            cell.deliveryPayment_btn.tag = delivery_total_price; cell.deliveryPayment_btn.addTarget(self, action: #selector(deliveryPayment_btn(_:)), for: .touchUpInside)
            cell.deliveryReceipt_v.isHidden = !cell.deliveryPayment_v.isHidden
            cell.deliveryTracking_btn.tag = indexPath.row; cell.deliveryTracking_btn.addTarget(self, action: #selector(deliveryTracking_btn(_:)), for: .touchUpInside)
            cell.deliveryReceipt_btn.tag = indexPath.row; cell.deliveryReceipt_btn.addTarget(self, action: #selector(deliveryReceipt_btn(_:)), for: .touchUpInside)
            
            return cell
        } else if indexPath.section == 1 {
            
            let data = OrderObject
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReOrderDetailTC2", for: indexPath) as! ReOrderDetailTC
            
            cell.labels.forEach { label in label.text = translation(label.text!) }
            
            cell.orderId_label.text = data.order_key
            cell.orderDatetime_label.text = setTimestampToDateTime(timestamp: Int(data.order_datetime) ?? 0)
            /// 상품금액
            cell.itemPrice_label.attributedText = attributedPriceString(krw: data.kr_total_item_price, cny: data.ch_total_item_price, fontSize: 14)
            /// 물류비
            if data.ch_total_delivery_price == 0.0 && data.kr_total_delivery_price == 0 {
                cell.deliveryPrice_label.text = translation("물류비 결제 후 표시됩니다.")
            } else {
                cell.deliveryPrice_label.attributedText = attributedPriceString(krw: data.kr_total_delivery_price, cny: data.ch_total_delivery_price, fontSize: 14)
            }
            
            cell.Address_label.text = data.delivery_address
            cell.AddressDetail_label.text = data.delivery_address_detail
            cell.Name_label.text = data.delivery_name
            cell.Num_label.text = data.delivery_num
            
            return cell
        } else if indexPath.section == 2 {
            
            let data = OrderObject.order_item[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReOrderDetailTC3", for: indexPath) as! ReOrderDetailTC
            cell.OrderItemObject = data
            cell.viewDidLoad()
            
            cell.item_img_v.isHidden = (action == "receipt")
            cell.itemName_btn.setTitle(data.item_name, for: .normal)
            if action == "normal" {
                cell.itemName_btn.tag = indexPath.row; cell.itemName_btn.addTarget(self, action: #selector(itemName_btn(_:)), for: .touchUpInside)
            }
            
            return cell
        } else if indexPath.section == 3 {
            
            let data = OrderObject
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReOrderDetailTC4", for: indexPath) as! ReOrderDetailTC
            
            cell.labels.forEach { label in label.text = translation(label.text!) }
            /// 상품금액
            cell.totalItemPrice_label.attributedText = attributedPriceString(krw: data.kr_total_item_price, cny: data.ch_total_item_price, fontSize: 14)
            /// 물류비
            if data.ch_total_delivery_price == 0.0 && data.kr_total_delivery_price == 0 {
                cell.totalDeliveryPrice_label.text = translation("물류비 결제 후 표시됩니다.")
            } else {
                cell.totalDeliveryPrice_label.attributedText = attributedPriceString(krw: data.kr_total_delivery_price, cny: data.ch_total_delivery_price, fontSize: 14)
            }
            /// 총 금액
            cell.totalPrice_label.attributedText = attributedPriceString(krw: data.kr_total_item_price+data.kr_total_delivery_price, cny: data.ch_total_item_price+data.ch_total_delivery_price)
                        
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func deliveryPayment_btn(_ sender: UIButton) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReDeliveryPaymentVC") as! ReDeliveryPaymentVC
        segue.action = action
        segue.OrderObject = OrderObject
        navigationController?.pushViewController(segue, animated: true, completion: nil)
    }
    
    @objc func deliveryTracking_btn(_ sender: UIButton) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReDeliveryTrackingVC") as! ReDeliveryTrackingVC
        segue.linkUrl = "https://www.sf-international.com/kr/ko/dynamic_function/waybill/#search/bill-number/"+OrderObject.delivery_tracking_num
        navigationController?.pushViewController(segue, animated: true, completion: nil)
    }
    
    @objc func deliveryReceipt_btn(_ sender: UIButton) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReDeliveryPaymentVC") as! ReDeliveryPaymentVC
        segue.action = action
        segue.OrderObject = OrderObject
        navigationController?.pushViewController(segue, animated: true, completion: nil)
    }
    
    @objc func itemName_btn(_ sender: UIButton) {
        
        let data = OrderObject.order_item[sender.tag]
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReGoodsDetailVC") as! ReGoodsDetailVC
        segue.store_id = data.store_id
        segue.item_key = data.item_key
        navigationController?.pushViewController(segue, animated: true, completion: nil)
    }
}

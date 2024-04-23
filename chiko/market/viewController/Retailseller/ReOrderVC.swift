//
//  ReOrderVC.swift
//  market
//
//  Created by Busan Dynamic on 12/21/23.
//

import UIKit

class ReOrderItemOptionTC: UITableViewCell {
    
    var delegate: ReOrderVC = ReOrderVC()
    var indexpath_row: Int = 0
    
    var OrderItemObject: ReOrderItemData = ReOrderItemData()
    
    @IBOutlet weak var orderState_btn: UIButton!
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
    
    @IBOutlet weak var orderTotalPrice_label: UILabel!
    
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

extension ReOrderItemOptionTC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if OrderItemObject.item_option.count > 0 { return OrderItemObject.item_option.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = OrderItemObject.item_option[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReOrderItemOptionTC", for: indexPath) as! ReOrderItemOptionTC
        
        if (data.price-OrderItemObject.item_sale_price) < 0 {
            cell.optionName_label.text = "옵션. \(data.color) + \(data.size) (₩\(priceFormatter.string(from: (data.price-OrderItemObject.item_sale_price) as NSNumber) ?? "0"))"
        } else {
            cell.optionName_label.text = "옵션. \(data.color) + \(data.size) (+₩\(priceFormatter.string(from: (data.price-OrderItemObject.item_sale_price) as NSNumber) ?? "0"))"
        }
        cell.optionQuantity_label.text = "주문수량. \(data.quantity)개"
        cell.enterQuantity_label.isHidden = (data.enter_quantity == 0)
        cell.enterQuantity_label.text = "입고수량. \(data.enter_quantity)개"
        cell.enterDate_label.isHidden = (data.enter_date == "")
        let content = NSMutableAttributedString()
        content.append(NSAttributedString(string: "재입고예정일. ", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.black
        ]))
        content.append(NSAttributedString(string: data.enter_date, attributes: [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.systemRed
        ]))
        cell.enterDate_label.attributedText = content
        cell.optionPrice_label.text = "₩\(priceFormatter.string(from: (data.price*data.quantity) as NSNumber) ?? "0")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let segue = delegate.storyboard?.instantiateViewController(withIdentifier: "ReOrderDetailVC") as! ReOrderDetailVC
        segue.action = delegate.action
        segue.OrderObject = delegate.ReOrderArray[indexpath_row]
        delegate.navigationController?.pushViewController(segue, animated: true)
    }
}
    
class ReOrderTC: UITableViewCell {
    
    var delegate: ReOrderVC = ReOrderVC()
    var indexpath_row: Int = 0
    
    var OrderItemArray: [ReOrderItemData] = []
    
    @IBOutlet weak var datetime_label: UILabel!
    @IBOutlet weak var detail_btn: UIButton!
    @IBOutlet weak var delete_btn: UIButton!
    @IBOutlet weak var deliveryPayment_v: UIView!
    @IBOutlet weak var deliveryPayment_btn: UIButton!
    @IBOutlet weak var deliveryReceipt_v: UIView!
    @IBOutlet weak var deliveryTracking_btn: UIButton!
    @IBOutlet weak var deliveryReceipt_btn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_heignt: NSLayoutConstraint!
    
    func viewDidLoad() {
        
        tableView.delegate = nil; tableView.dataSource = nil
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self; tableView.reloadData()
        
        var total_height: CGFloat = 0.0
        OrderItemArray.forEach { item in
            item.item_option.forEach { option in
                total_height += 50
                total_height += option.enter_quantity == 0 ? 0 : 20
                total_height += option.enter_date == "" || option.enter_quantity == option.quantity ? 0 : 20
            }; total_height += 181
        }
        tableView_heignt.constant = total_height
    }
}

extension ReOrderTC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if OrderItemArray.count > 0 { return OrderItemArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var data = OrderItemArray[indexPath.row]
        guard let cell = cell as? ReOrderItemOptionTC else { return }
        
        if !data.load { data.load = true
            setKingfisher(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 10)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? ReOrderItemOptionTC else { return }
        
        cancelKingfisher(imageView: cell.item_img)
        cell.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = OrderItemArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReOrderTC2", for: indexPath) as! ReOrderItemOptionTC
        cell.delegate = delegate
        cell.indexpath_row = indexpath_row
        cell.OrderItemObject = data
        cell.viewDidLoad()
        
        cell.orderState_btn.setTitle(delegate.ReOrderArray[indexpath_row].order_state, for: .normal)
        cell.item_img_v.isHidden = (delegate.action == "receipt")
        cell.itemName_btn.setTitle(data.item_name, for: .normal)
        if delegate.action == "normal" {
            cell.itemName_btn.tag = indexPath.row; cell.itemName_btn.addTarget(self, action: #selector(itemName_btn(_:)), for: .touchUpInside)
        }
        
        var order_total: Int = 0
        data.item_option.forEach { data in
            order_total += data.price*data.quantity
        }
        cell.orderTotalPrice_label.text = "₩\(priceFormatter.string(from: order_total as NSNumber) ?? "0")"
        
        return cell
    }
    
    @objc func orderState_btn(_ sender: UIButton) {
        
//        let data = OrderItemArray[sender.tag]
//        let segue = ReOrderVCdelegate.storyboard?.instantiateViewController(withIdentifier: "ReGoodsDetailVC") as! ReGoodsDetailVC
//        segue.store_id = data.store_id
//        segue.item_key = data.item_key
//        ReOrderVCdelegate.navigationController?.pushViewController(segue, animated: true)
    }
    
    @objc func itemName_btn(_ sender: UIButton) {
        
        let data = OrderItemArray[sender.tag]
        let segue = delegate.storyboard?.instantiateViewController(withIdentifier: "ReGoodsDetailVC") as! ReGoodsDetailVC
        segue.store_id = data.store_id
        segue.item_key = data.item_key
        delegate.navigationController?.pushViewController(segue, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let segue = delegate.storyboard?.instantiateViewController(withIdentifier: "ReOrderDetailVC") as! ReOrderDetailVC
        segue.action = delegate.action
        segue.OrderObject = delegate.ReOrderArray[indexpath_row]
        delegate.navigationController?.pushViewController(segue, animated: true)
    }
}

class ReOrderVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var action: String = "normal"
    var ReOrderArray: [ReOrderData] = []
    let refreshControl: UIRefreshControl = UIRefreshControl()
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var navi_btns: [UIButton]!
    @IBOutlet weak var all_btn_width: NSLayoutConstraint!
    @IBOutlet weak var orderDelivery_btn_width: NSLayoutConstraint!
    @IBOutlet weak var changeReturnCancel_btn_width: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReOrderVCdelegate = self
        
        navi_btns.forEach { btn in
            btn.addTarget(self, action: #selector(navi_btn(_:)), for: .touchUpInside)
        }
        all_btn_width.constant = stringWidth(text: "전체", fontSize: 12, fontWeight: .medium)+30
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .black.withAlphaComponent(0.3)
        refreshControl.addTarget(self, action: #selector(refreshControl(_:)), for: .valueChanged)
        
        customLoadingIndicator(text: "불러오는 중...", animated: true)
        
        loadingData()
    }
    
    func loadingData() {
        /// 데이터 삭제
        ReOrderArray.removeAll(); tableView.reloadData()
        /// Order 요청
        requestReOrder(action: action) { array, status in
            
            self.customLoadingIndicator(animated: false)
            
            if status == 200 {
                self.problemAlert(view: self.tableView)
                self.ReOrderArray += array
                self.ReOrderArray.sort { $0.order_datetime > $1.order_datetime }
            } else if status == 204 {
                self.problemAlert(view: self.tableView, type: "nodata")
            } else {
                self.problemAlert(view: self.tableView, type: "error")
            }
            self.tableView.reloadData()
        }
    }
    
    @objc func navi_btn(_ sender: UIButton) {
        
        navi_btns.forEach { btn in
            if btn.tag == sender.tag {
                btn.backgroundColor = .H_8CD26B
                btn.setTitleColor(.white, for: .normal)
                ([all_btn_width, orderDelivery_btn_width, changeReturnCancel_btn_width] as [NSLayoutConstraint])[sender.tag].constant = stringWidth(text: sender.titleLabel!.text!, fontSize: 12, fontWeight: .medium)+30
            } else {
                btn.backgroundColor = .white
                btn.setTitleColor(.black.withAlphaComponent(0.3), for: .normal)
                ([all_btn_width, orderDelivery_btn_width, changeReturnCancel_btn_width] as [NSLayoutConstraint])[btn.tag].constant = stringWidth(text: btn.titleLabel!.text!, fontSize: 12, fontWeight: .medium)
            }
        }
        
        customLoadingIndicator(text: "불러오는 중...", animated: true)
        
        loadingData()
    }
    
    @objc func refreshControl(_ sender: UIRefreshControl) {
        loadingData(); sender.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
    }
}

extension ReOrderVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ReOrderArray.count > 0 { return ReOrderArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = ReOrderArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReOrderTC1", for: indexPath) as! ReOrderTC
        cell.delegate = self
        cell.indexpath_row = indexPath.row
        cell.OrderItemArray = data.order_item
        cell.viewDidLoad()
        
        cell.datetime_label.text = setTimestampToDateTime(timestamp: Int(data.order_datetime) ?? 0, dateformat: "yyyy. MM. dd.")
        cell.detail_btn.tag = indexPath.row; cell.detail_btn.addTarget(self, action: #selector(detail_btn(_:)), for: .touchUpInside)
        cell.delete_btn.tag = indexPath.row; cell.delete_btn.addTarget(self, action: #selector(delete_btn(_:)), for: .touchUpInside)
        
        cell.deliveryPayment_v.isHidden = !((data.order_state == "상품준비중") || (data.order_state == "배송준비중" && data.ch_total_delivery_price == 0.0))
//        cell.deliveryPayment_btn.isHidden = delivery_price_zero && (data.order_state != "배송준비중")
        cell.deliveryPayment_btn.isHidden = (data.order_state != "배송준비중")
        cell.deliveryPayment_btn.setTitle("물류비 결제하기", for: .normal)
        cell.deliveryPayment_btn.tag = indexPath.row; cell.deliveryPayment_btn.addTarget(self, action: #selector(deliveryPayment_btn(_:)), for: .touchUpInside)
        cell.deliveryReceipt_v.isHidden = !cell.deliveryPayment_v.isHidden
        cell.deliveryTracking_btn.tag = indexPath.row; cell.deliveryTracking_btn.addTarget(self, action: #selector(deliveryTracking_btn(_:)), for: .touchUpInside)
        cell.deliveryReceipt_btn.tag = indexPath.row; cell.deliveryReceipt_btn.addTarget(self, action: #selector(deliveryReceipt_btn(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func detail_btn(_ sender: UIButton) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReOrderDetailVC") as! ReOrderDetailVC
        segue.action = action
        segue.OrderObject = ReOrderArray[sender.tag]
        navigationController?.pushViewController(segue, animated: true)
    }
    
    @objc func delete_btn(_ sender: UIButton) {
        
    }
    
    @objc func deliveryPayment_btn(_ sender: UIButton) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReDeliveryPaymentVC") as! ReDeliveryPaymentVC
        segue.action = action
        segue.OrderObject = ReOrderArray[sender.tag]
        navigationController?.pushViewController(segue, animated: true)
    }
    
    @objc func deliveryTracking_btn(_ sender: UIButton) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReDeliveryTrackingVC") as! ReDeliveryTrackingVC
        segue.linkUrl = "https://www.sf-international.com/kr/ko/dynamic_function/waybill/#search/bill-number/"+ReOrderArray[sender.tag].delivery_tracking_num
        navigationController?.pushViewController(segue, animated: true)
    }
    
    @objc func deliveryReceipt_btn(_ sender: UIButton) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReDeliveryPaymentVC") as! ReDeliveryPaymentVC
        segue.action = action
        segue.OrderObject = ReOrderArray[sender.tag]
        navigationController?.pushViewController(segue, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let btn = UIButton()
        btn.tag = indexPath.row
        detail_btn(btn)
    }
}

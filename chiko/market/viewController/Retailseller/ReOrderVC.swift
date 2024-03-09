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
    
    @IBOutlet weak var deliveryState_btn: UIButton!
    @IBOutlet weak var item_img_v: UIView!
    @IBOutlet weak var item_img: UIImageView!
    @IBOutlet weak var itemName_btn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_heignt: NSLayoutConstraint!
    
    @IBOutlet weak var optionName_label: UILabel!
    @IBOutlet weak var optionQuantity_label: UILabel!
    @IBOutlet weak var optionPrice_label: UILabel!
    
    @IBOutlet weak var orderTotalPrice_label: UILabel!
    
    func viewDidLoad() {
        
        tableView.delegate = nil; tableView.dataSource = nil
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        tableView_heignt.constant = CGFloat(OrderItemObject.item_option.count*50)
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
            cell.optionName_label.text = "옵션. \(data.color) + \(data.size) (₩ \(priceFormatter.string(from: (data.price-OrderItemObject.item_sale_price) as NSNumber) ?? "0"))"
        } else {
            cell.optionName_label.text = "옵션. \(data.color) + \(data.size) (+₩ \(priceFormatter.string(from: (data.price-OrderItemObject.item_sale_price) as NSNumber) ?? "0"))"
        }
        if data.enter_quantity > 0 {
            let content = NSMutableAttributedString()
            content.append(NSAttributedString(string: "주문수량. \(data.quantity)개", attributes: [.font: UIFont.systemFont(ofSize: 14)]))
            content.append(NSAttributedString(string: "입고수량. \(data.enter_quantity)개", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]))
            cell.optionQuantity_label.attributedText = content
        } else {
            cell.optionQuantity_label.text = "주문수량. \(data.quantity)개"
        }
        cell.optionPrice_label.text = "₩ \(priceFormatter.string(from: (data.price*data.quantity) as NSNumber) ?? "0")"
        
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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_heignt: NSLayoutConstraint!
    
    func viewDidLoad() {
        
        tableView.delegate = nil; tableView.dataSource = nil
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        
        var height: CGFloat = 0.0
        OrderItemArray.forEach { data in height += CGFloat((data.item_option.count*50)+181) }
        tableView_heignt.constant = height
    }
}

extension ReOrderTC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if OrderItemArray.count > 0 { return OrderItemArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let data = OrderItemArray[indexPath.row]
        guard let cell = cell as? ReOrderItemOptionTC else { return }
        
        setKingfisher(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 10)
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
        
        cell.deliveryState_btn.setTitle(data.delivery_state, for: .normal)
        cell.item_img_v.isHidden = (delegate.action == "receipt")
        cell.itemName_btn.setTitle(data.item_name, for: .normal)
        if delegate.action == "normal" {
            cell.itemName_btn.tag = indexPath.row; cell.itemName_btn.addTarget(self, action: #selector(itemName_btn(_:)), for: .touchUpInside)
        }
        
        var order_total: Int = 0
        data.item_option.forEach { data in
            order_total += data.price*data.quantity
        }
        cell.orderTotalPrice_label.text = "₩ \(priceFormatter.string(from: order_total as NSNumber) ?? "0")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let segue = delegate.storyboard?.instantiateViewController(withIdentifier: "ReOrderDetailVC") as! ReOrderDetailVC
        segue.action = delegate.action
        segue.OrderObject = delegate.ReOrderArray[indexpath_row]
        delegate.navigationController?.pushViewController(segue, animated: true)
    }
    
    @objc func deliveryState_btn(_ sender: UIButton) {
        
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
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .black.withAlphaComponent(0.3)
        refreshControl.addTarget(self, action: #selector(refreshControl(_:)), for: .valueChanged)
        
        customLoadingIndicator(animated: true)
        
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
        
        customLoadingIndicator(animated: true)
        
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
        
        cell.deliveryPayment_v.isHidden = data.delivery_price_state
        var delivery_price_zero: Bool = false
        var delivery_total_price: Int = 0
        data.order_item.forEach { item in
            item.item_option.forEach { option in
                delivery_price_zero = (option.delivery_price == 0)
                delivery_total_price += option.delivery_price
            }
        }
        cell.deliveryPayment_btn.isHidden = delivery_price_zero
        cell.deliveryPayment_btn.setTitle("배송비(₩ \(priceFormatter.string(from: delivery_total_price as NSNumber) ?? "0")) 결제하기", for: .normal)
        cell.deliveryPayment_btn.tag = delivery_total_price; cell.deliveryPayment_btn.addTarget(self, action: #selector(deliveryPayment_btn(_:)), for: .touchUpInside)
        
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
        
        let alert = UIAlertController(title: "", message: "배송비(₩ \(priceFormatter.string(from: sender.tag as NSNumber) ?? "0")) 결제하기", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "결제하기", style: .default, handler: { _ in
            
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReOrderDetailVC") as! ReOrderDetailVC
        segue.action = action
        segue.OrderObject = ReOrderArray[indexPath.row]
        navigationController?.pushViewController(segue, animated: true)
    }
}

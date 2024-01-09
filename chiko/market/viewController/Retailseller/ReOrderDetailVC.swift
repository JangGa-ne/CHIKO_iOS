//
//  ReOrderDetailVC.swift
//  market
//
//  Created by Busan Dynamic on 12/22/23.
//

import UIKit

class ReOrderDetailTC: UITableViewCell {
    
    var OrderItemObject: ReOrderItemData = ReOrderItemData()
    
    @IBOutlet weak var orderId_label: UILabel!
    @IBOutlet weak var orderDatetime_label: UILabel!
    @IBOutlet weak var KrTotalPrice_label: UILabel!
    @IBOutlet weak var CnTotalPrice_label: UILabel!
    
    @IBOutlet weak var Address_label: UILabel!
    @IBOutlet weak var AddressDetail_label: UILabel!
    @IBOutlet weak var Name_label: UILabel!
    @IBOutlet weak var Num_label: UILabel!
    
    @IBOutlet weak var item_img: UIImageView!
    @IBOutlet weak var itemName_btn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_heignt: NSLayoutConstraint!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var delivery_btn: UIButton!
    
    @IBOutlet weak var optionName_label: UILabel!
    @IBOutlet weak var optionQuantity_label: UILabel!
    @IBOutlet weak var optionPrice_label: UILabel!
    
    @IBOutlet weak var TotalItemPrice_label: UILabel!
    @IBOutlet weak var TotalVAT_label: UILabel!
    @IBOutlet weak var TotalPrice_label: UILabel!
    
    func viewDidLoad() {
        
        tableView.delegate = nil; tableView.dataSource = nil
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        tableView_heignt.constant = CGFloat(OrderItemObject.item_option.count*50)
    }
}

extension ReOrderDetailTC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if OrderItemObject.item_option.count > 0 { return OrderItemObject.item_option.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = OrderItemObject.item_option[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReOrderDetailItemOptionTC", for: indexPath) as! ReOrderDetailTC
        
        if (data.price-OrderItemObject.item_sale_price) < 0 {
            cell.optionName_label.text = "옵션. \(data.color) + \(data.size) (₩ \(priceFormatter.string(from: (data.price-OrderItemObject.item_sale_price) as NSNumber) ?? "0"))"
        } else {
            cell.optionName_label.text = "옵션. \(data.color) + \(data.size) (+₩ \(priceFormatter.string(from: (data.price-OrderItemObject.item_sale_price) as NSNumber) ?? "0"))"
        }
        cell.optionQuantity_label.text = "수량. \(data.quantity)개"
        cell.optionPrice_label.text = "₩ \(priceFormatter.string(from: (data.price*data.quantity) as NSNumber) ?? "0")"
        
        return cell
    }
}

class ReOrderDetailVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var OrderObject: ReOrderData = ReOrderData()
    
    var order_total: Int = 0
    var total_price: Int = 0
    var total_vat: Int = 3
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
    }
}

extension ReOrderDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1, OrderObject.order_item.count > 0 {
            return OrderObject.order_item.count
        } else if section == 2 {
            return 1
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            let data = OrderObject.order_item[indexPath.row]
            guard let cell = cell as? ReOrderDetailTC else { return }
            
            setNuke(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 10)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let data = OrderObject
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReOrderDetailTC1", for: indexPath) as! ReOrderDetailTC
            
            data.order_item.forEach { data in data.item_option.forEach { data in total_price += data.price*data.quantity } }
            order_total = total_price+Int(Double(total_price)*(Double(total_vat)/100.0))
            
            cell.orderId_label.text = data.order_key
            cell.orderDatetime_label.text = setTimestampToDateTime(timestamp: Int(data.order_datetime) ?? 0, dateformat: "yyyy. MM. dd.")
            cell.KrTotalPrice_label.text = "₩ \(priceFormatter.string(from: data.kr_total_item_price as NSNumber) ?? "0")"
            cell.CnTotalPrice_label.text = "¥ \(data.cn_total_item_price)"
            
            cell.Address_label.text = data.delivery_address
            cell.AddressDetail_label.text = data.delivery_address_detail
            cell.Name_label.text = data.delivery_name
            cell.Num_label.text = data.delivery_num
            
            return cell
        } else if indexPath.section == 1 {
            
            let data = OrderObject.order_item[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReOrderDetailTC2", for: indexPath) as! ReOrderDetailTC
            cell.OrderItemObject = data
            cell.viewDidLoad()
            
            cell.itemName_btn.setTitle(data.item_name, for: .normal)
            cell.itemName_btn.tag = indexPath.row; cell.itemName_btn.addTarget(self, action: #selector(itemName_btn(_:)), for: .touchUpInside)
            
            return cell
        } else if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReOrderDetailTC3", for: indexPath) as! ReOrderDetailTC
            
            cell.TotalItemPrice_label.text = "₩ \(priceFormatter.string(from: order_total as NSNumber) ?? "0")"
            cell.TotalVAT_label.text = "₩ \(priceFormatter.string(from: Int(Double(total_price)*(Double(total_vat)/100.0)) as NSNumber) ?? "0")"
            cell.TotalPrice_label.text = "₩ \(priceFormatter.string(from: (order_total+total_vat) as NSNumber) ?? "0")"
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func itemName_btn(_ sender: UIButton) {
        
        let data = OrderObject.order_item[sender.tag]
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReGoodsDetailVC") as! ReGoodsDetailVC
        segue.store_id = data.store_id
        segue.item_key = data.item_key
        navigationController?.pushViewController(segue, animated: true)
    }
}

//
//  ReOrderVC.swift
//  market
//
//  Created by Busan Dynamic on 12/21/23.
//

import UIKit

class ReOrderItemOptionTC: UITableViewCell {
    
    var OrderItemObject: ReOrderItemData = ReOrderItemData()
    
    @IBOutlet weak var item_img: UIImageView!
    @IBOutlet weak var itemName_btn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_heignt: NSLayoutConstraint!
    
    @IBOutlet weak var optionName_label: UILabel!
    @IBOutlet weak var optionQuantity_label: UILabel!
    @IBOutlet weak var optionPrice_label: UILabel!
    
    @IBOutlet weak var orderTotalPrice_label: UILabel!
    
    func viewDidLoad() {
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReOrderItemOptionTC2", for: indexPath) as! ReOrderItemOptionTC
        
        if (data.price-OrderItemObject.item_sale_price) < 0 {
            cell.optionName_label.text = "옵션. \(data.color) + \(data.size) (\(priceFormatter.string(from: (data.price-OrderItemObject.item_sale_price) as NSNumber) ?? "0"))"
        } else {
            cell.optionName_label.text = "옵션. \(data.color) + \(data.size) (+\(priceFormatter.string(from: (data.price-OrderItemObject.item_sale_price) as NSNumber) ?? "0"))"
        }
        cell.optionQuantity_label.text = "수량. \(data.quantity)개"
        cell.optionPrice_label.text = "₩ \(priceFormatter.string(from: (data.price*data.quantity) as NSNumber) ?? "0")"
        
        return cell
    }
}
    
class ReOrderTC: UITableViewCell {
    
    var OrderItemArray: [ReOrderItemData] = []
    
    @IBOutlet weak var datetime_label: UILabel!
    @IBOutlet weak var detail_btn: UIButton!
    @IBOutlet weak var delete_btn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_heignt: NSLayoutConstraint!
    
    func viewDidLoad() {
        
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
        
        setNuke(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 10)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = OrderItemArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReOrderItemOptionTC1", for: indexPath) as! ReOrderItemOptionTC
        cell.OrderItemObject = data
        cell.viewDidLoad()
        
        cell.itemName_btn.setTitle(data.item_name, for: .normal)
        cell.itemName_btn.tag = indexPath.row; cell.itemName_btn.addTarget(self, action: #selector(itemName_btn(_:)), for: .touchUpInside)
        
        var order_total: Int = 0
        data.item_option.forEach { data in
            order_total += data.price*data.quantity
        }
        cell.orderTotalPrice_label.text = "₩ \(priceFormatter.string(from: order_total as NSNumber) ?? "0")"
        
        return cell
    }
    
    @objc func itemName_btn(_ sender: UIButton) {
        
    }
}

class ReOrderVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    let refreshControl: UIRefreshControl = UIRefreshControl()
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var navi_btns: [UIButton]!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navi_btns.enumerated().forEach { i, btn in
            if btn.tag == i { btn.frame.size.width = stringWidth(text: btn.titleLabel!.text!)+15 }
            btn.addTarget(self, action: #selector(navi_btn(_:)), for: .touchUpInside)
        }
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .lightGray
        refreshControl.addTarget(self, action: #selector(refreshControl(_:)), for: .valueChanged)
        
        customLoadingIndicator(animated: true)
        
        loadingData()
    }
    
    func loadingData() {
        /// 데이터 삭제
        ReOrderArray.removeAll(); tableView.reloadData()
        /// Order 요청
        requestOrder { status in
            
            self.customLoadingIndicator(animated: false); self.tableView.reloadData()
            
            switch status {
            case 200:
                break
            case 204:
                self.customAlert(message: "No data", time: 1)
            case 600:
                self.customAlert(message: "Error occurred during data conversion", time: 1)
            default:
                self.customAlert(message: "Internal server error", time: 1)
            }
        }
    }
    
    @objc func navi_btn(_ sender: UIButton) {
        
        navi_btns.forEach { btn in
            if btn.tag == sender.tag {
                btn.backgroundColor = .H_8CD26B
                btn.layer.borderColor = UIColor.clear.cgColor
                btn.layer.borderWidth = .zero
                btn.setTitleColor(.white, for: .normal)
            } else {
                btn.backgroundColor = .white
                btn.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
                btn.layer.borderWidth = 1
                btn.setTitleColor(.black.withAlphaComponent(0.3), for: .normal)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReOrderTC", for: indexPath) as! ReOrderTC
        cell.OrderItemArray = data.order_item
        cell.viewDidLoad()
        
        cell.datetime_label.text = setTimestampToDateTime(timestamp: (Int(data.order_datetime) ?? 0)-32400000, dateformat: "yyyy. MM. dd.")
        cell.detail_btn.tag = indexPath.row; cell.detail_btn.addTarget(self, action: #selector(detail_btn(_:)), for: .touchUpInside)
        cell.delete_btn.tag = indexPath.row; cell.delete_btn.addTarget(self, action: #selector(delete_btn(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func detail_btn(_ sender: UIButton) {
        
    }
    
    @objc func delete_btn(_ sender: UIButton) {
        
    }
}

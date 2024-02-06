//
//  WhOrderVC.swift
//  market
//
//  Created by Busan Dynamic on 1/30/24.
//

import UIKit
import PanModal

class WhOrderTC: UITableViewCell {
    
    var WhOrderObject: WhOrderData = WhOrderData()
    
    @IBOutlet weak var notDelivery_sv: UIStackView!
    @IBOutlet weak var itemName_label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_height: NSLayoutConstraint!
    @IBOutlet weak var totalPrice_label: UILabel!
    @IBOutlet weak var totalQuantity_label: UILabel!
    
    @IBOutlet weak var optionName_label: UILabel!
    @IBOutlet weak var optionPrice_label: UILabel!
    @IBOutlet weak var optionQuantity_label: UILabel!
    
    func viewDidLoad() {
        
        tableView.delegate = nil; tableView.dataSource = nil
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
    }
}

extension WhOrderTC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if WhOrderObject.item_option.count > 0 { return WhOrderObject.item_option.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = WhOrderObject.item_option[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhOrderTC2") as! WhOrderTC
        
        cell.optionName_label.text = "\(data.color) / \(data.size)"
        cell.optionPrice_label.text = priceFormatter.string(from: data.price as NSNumber) ?? "0"
        cell.optionQuantity_label.text = String(data.quantity)
        
        return cell
    }
}

class WhOrderVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var WhOrderArray_all: [WhOrderData] = []
    var WhOrderArray: [WhOrderData] = []
    var WhNotDeliveryArray: [WhNotDeliveryData] = []
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalPrice_label: UILabel!
    @IBOutlet weak var UndeliveryAdd_btn: UIButton!
    @IBOutlet weak var Undelivery_btn: UIButton!
    @IBOutlet weak var date_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WhOrderVCdelegate = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
//        tableView.refreshControl = refreshControl
//        refreshControl.tintColor = .lightGray
//        refreshControl.addTarget(self, action: #selector(refreshControl(_:)), for: .valueChanged)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        date_btn.setTitle(dateFormatter.string(from: Date()), for: .normal)
        date_btn.addTarget(self, action: #selector(date_btn(_:)), for: .touchUpInside)
        
        ([UndeliveryAdd_btn, Undelivery_btn] as [UIButton]).enumerated().forEach { i, btn in
            btn.tag = i; btn.addTarget(self, action: #selector(Undelivery_btn(_:)), for: .touchUpInside)
        }
        
        loadingData()
    }
    
    @objc func refreshControl(_ sender: UIRefreshControl) {
        loadingData(); sender.endRefreshing()
    }
    
    @objc func date_btn(_ sender: UIButton) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "CalendarVC") as! CalendarVC
        segue.present_date = date_btn.titleLabel!.text!
        presentPanModal(segue)
    }
    
    @objc func Undelivery_btn(_ sender: UIButton) {
        
        if sender.tag == 0 {
            if WhOrderArray.count > 0 {
                let segue = storyboard?.instantiateViewController(withIdentifier: "WhNotDeliveryAddVC") as! WhNotDeliveryAddVC
                if #available(iOS 13.0, *) { segue.isModalInPresentation = true }
                segue.present_date = date_btn.titleLabel!.text!
                segue.WhOrderArray = WhOrderArray
//                presentPanModal(segue)
                present(segue, animated: true, completion: nil)
            } else {
                customAlert(message: "해당 날짜에 주문상품이 없어\n미송상품을 추가 할 수 없습니다.", time: 2)
            }
        } else if sender.tag == 1 {
//            segueViewController(identifier: "WhUndeliveryVC")
        }
    }
    
    func loadingData() {
        
        customLoadingIndicator(animated: true)
        
        /// WhOrder 요청
        dispatchGroup.enter()
        requestWhOrder { array, _ in
            self.WhOrderArray_all = array; dispatchGroup.leave()
        }
        /// WhUndelivery 요청
        dispatchGroup.enter()
        requestWhNotDelivery { array, _ in
            self.WhNotDeliveryArray = array; dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            
            var total_price: Int = 0
            
            self.customLoadingIndicator(animated: false)
            /// 데이터 삭제
            self.WhOrderArray.removeAll()
            
            self.WhOrderArray_all.filter { data in
                return data.order_date.contains(self.date_btn.titleLabel?.text!.replacingOccurrences(of: ".", with: "") ?? "") && self.date_btn.titleLabel?.text! != ""
            }.forEach { data in
                data.item_option.forEach { data in total_price += (data.price*data.quantity) }
                /// 데이터 추가
                self.WhOrderArray.append(data)
            }
            
            self.totalPrice_label.text = "₩\(priceFormatter.string(from: total_price as NSNumber) ?? "0")"
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
        
        CalendarVCdelegate = nil
        WhNotDeliveryAddVCdelegate = nil
        WhNotDeliveryAddTCdelegate = nil
    }
}

extension WhOrderVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if WhOrderArray.count > 0 { return WhOrderArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var price: Int = 0
        var quantity: Int = 0
        
        let data = WhOrderArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhOrderTC1") as! WhOrderTC
        cell.WhOrderObject = data
        cell.viewDidLoad()
        
        cell.notDelivery_sv.isHidden = false
        cell.itemName_label.text = data.item_name
        data.item_option.forEach { data in price += (data.price*data.quantity); quantity += data.quantity }
        cell.tableView_height.constant = CGFloat(data.item_option.count*30)
        cell.totalPrice_label.text = priceFormatter.string(from: price as NSNumber) ?? "0"
        cell.totalQuantity_label.text = String(quantity)
        
        return cell
    }
}

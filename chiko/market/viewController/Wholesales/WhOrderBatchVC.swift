//
//  WhOrderBatchVC.swift
//  market
//
//  Created by 장 제현 on 1/30/24.
//

import UIKit
import PanModal

class WhOrderBatchTC: UITableViewCell {
    
    var delegate: WhOrderBatchVC = WhOrderBatchVC()
    var WhOrderObject: WhOrderData = WhOrderData()
    
    @IBOutlet weak var receiveCalculate_v: UIView!
    
    @IBOutlet weak var notDelivery_sv: UIStackView!
    @IBOutlet weak var itemName_label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_height: NSLayoutConstraint!
    
    @IBOutlet weak var totalPrice_label: UILabel!
    @IBOutlet weak var totalQuantity_label: UILabel!
    @IBOutlet weak var receivePrice_label: UILabel!
    @IBOutlet weak var deservePrice_label: UILabel!
    
    @IBOutlet weak var optionName_label: UILabel!
    @IBOutlet weak var optionPrice_label: UILabel!
    @IBOutlet weak var optionQuantity_label: UILabel!
    @IBOutlet weak var enterQuantity_label: UILabel!
    
    func viewDidLoad() {
        
        tableView.delegate = nil; tableView.dataSource = nil
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self; tableView.reloadData()
    }
}

extension WhOrderBatchTC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if WhOrderObject.item_option.count > 0 { return WhOrderObject.item_option.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = WhOrderObject.item_option[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhOrderBatchTC2") as! WhOrderBatchTC
        
        cell.optionName_label.text = "\(data.color) / \(data.size)"
        cell.optionPrice_label.text = priceFormatter.string(from: data.price as NSNumber) ?? "0"
        cell.optionQuantity_label.text = priceFormatter.string(from: data.quantity as NSNumber) ?? "0"
        if delegate.type == "정산" {
            cell.enterQuantity_label.text = priceFormatter.string(from: data.enter_quantity as NSNumber) ?? "0"
        }
        
        return cell
    }
}

class WhOrderBatchVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var type: String = "주문" // 주문.정산
    var WhOrderArray_all: [WhOrderData] = []
    var WhOrderArray: [WhOrderData] = []
    var WhNotDeliveryArray_all: [WhNotDeliveryData] = []
    var WhNotDeliveryArray: [WhNotDeliveryData] = []
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    @IBOutlet weak var mainTitle_label: UILabel!
    @IBOutlet weak var subTitle_label: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var total_v: UIView!
    @IBOutlet weak var totalPrice_sv: UIStackView!
    @IBOutlet weak var totalPrice_label: UILabel!
    @IBOutlet weak var notDeliveryAdd_btn: UIButton!
    @IBOutlet weak var notDelivery_btn: UIButton!
    @IBOutlet weak var date_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WhOrderBatchVCdelegate = self
        
        if type == "주문" {
            mainTitle_label.text = "주문관리"
            subTitle_label.text = "오늘의주문"
        } else if type == "정산" {
            mainTitle_label.text = "정산관리"
            subTitle_label.text = "오늘의정산"
        }
        
        total_v.frame.size.height = type == "정산" ? 85 : 150
        totalPrice_sv.isHidden = type == "정산"
        tableView.layoutIfNeeded()
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = .zero }
        tableView.delegate = self; tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .black.withAlphaComponent(0.3)
        refreshControl.addTarget(self, action: #selector(refreshControl(_:)), for: .valueChanged)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        date_btn.setTitle(dateFormatter.string(from: Date()), for: .normal)
        date_btn.addTarget(self, action: #selector(date_btn(_:)), for: .touchUpInside)
        
        ([notDeliveryAdd_btn, notDelivery_btn] as [UIButton]).enumerated().forEach { i, btn in
            btn.tag = i; btn.addTarget(self, action: #selector(notDelivery_btn(_:)), for: .touchUpInside)
        }
        
        customLoadingIndicator(text: "불러오는 중...", animated: true)
        
        loadingData()
    }
    
    @objc func refreshControl(_ sender: UIRefreshControl) {
        loadingData(); sender.endRefreshing()
    }
    
    @objc func date_btn(_ sender: UIButton) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "CalendarVC") as! CalendarVC
        segue.WhOrderBatchVCdelegate = self
        segue.present_date = date_btn.titleLabel!.text!
        presentPanModal(segue)
    }
    
    @objc func notDelivery_btn(_ sender: UIButton) {
        
        if sender.tag == 0 {
            if WhOrderArray.count > 0 {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                let segue = storyboard?.instantiateViewController(withIdentifier: "WhNotDeliveryAddVC") as! WhNotDeliveryAddVC
                segue.modalPresentationStyle = .currentContext; segue.transitioningDelegate = self
                segue.present_date = date_btn.titleLabel!.text!
                segue.WhOrderArray = WhOrderArray
                segue.WhNotDeliveryArray = WhNotDeliveryArray
                present(segue, animated: true, completion: nil)
            } else {
                customAlert(message: "해당 날짜에 주문상품이 없어\n미송상품을 추가 할 수 없습니다.", time: 2)
            }
        } else if sender.tag == 1 {
            segueViewController(identifier: "WhNotDeliveryVC")
        }
    }
    
    func loadingData() {
        /// 데이터 삭제
        WhOrderArray_all.removeAll(); WhOrderArray.removeAll(); WhNotDeliveryArray_all.removeAll(); WhNotDeliveryArray.removeAll(); tableView.reloadData()
        
        /// WhOrder 요청
        dispatchGroup.enter()
        requestWhOrder { array, _ in
            self.WhOrderArray_all = array; dispatchGroup.leave()
        }
//        /// WhNotDelivery 요청
//        dispatchGroup.enter()
//        requestWhNotDelivery(type: "date") { array, _ in
//            self.WhNotDeliveryArray_all = array; dispatchGroup.leave()
//        }
        
        dispatchGroup.notify(queue: .main) {
            
            var total_price: Int = 0
            
            self.customLoadingIndicator(animated: false)
            
            self.WhOrderArray_all.filter { data in
                return data.order_date.contains(self.date_btn.title(for: .normal)?.replacingOccurrences(of: ".", with: "") ?? "") && self.date_btn.title(for: .normal) != ""
            }.forEach { data in
                data.item_option.forEach { data in total_price += (data.price*data.quantity) }
                /// 데이터 추가
                self.WhOrderArray.append(data)
            }
            
            self.WhNotDeliveryArray_all.filter { data in
                return data.order_date.contains(self.date_btn.title(for: .normal)?.replacingOccurrences(of: ".", with: "") ?? "") && self.date_btn.title(for: .normal) != ""
            }.forEach { data in
                /// 데이터 추가
                self.WhNotDeliveryArray.append(data)
            }
            
            self.totalPrice_label.text = "₩\(priceFormatter.string(from: total_price as NSNumber) ?? "0")"
            
            if self.WhOrderArray.count > 0 {
                self.problemAlert(view: self.tableView)
            } else {
                self.problemAlert(view: self.tableView, type: "nodata")
            }
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

extension WhOrderBatchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if WhOrderArray.count > 0 { return WhOrderArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = WhOrderArray[indexPath.row]
        
        var price: Int = 0
        var quantity: Int = 0
        
        if type == "주문" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhOrderBatchTC1") as! WhOrderBatchTC
            cell.delegate = self
            cell.WhOrderObject = data
            cell.viewDidLoad()
            
            cell.notDelivery_sv.isHidden = !(WhNotDeliveryArray_all.contains { $0.item_key == data.item_key })
            cell.itemName_label.text = data.item_name
            data.item_option.forEach { data in price += (data.price*data.quantity); quantity += data.quantity }
            cell.tableView_height.constant = CGFloat(data.item_option.count*30)
            
            cell.totalPrice_label.text = priceFormatter.string(from: price as NSNumber) ?? "0"
            cell.totalQuantity_label.text = priceFormatter.string(from: quantity as NSNumber) ?? "0"
            
            return cell
        } else if type == "정산" {
            
            var receive_price: Int = 0
            var deserve_price: Int = 0
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhOrderBatchTC2") as! WhOrderBatchTC
            cell.delegate = self
            cell.WhOrderObject = data
            cell.viewDidLoad()
            
            cell.receiveCalculate_v.isHidden = (data.calculate_datetime == "")
            cell.receiveCalculate_v.transform = CGAffineTransform(rotationAngle: CGFloat(5 * Double.pi / 180))
            
            cell.itemName_label.text = data.item_name
            data.item_option.forEach { data in
                price += (data.price*data.quantity)
                receive_price += data.enter_price
                deserve_price += (data.price*data.enter_quantity-data.enter_price)
            }
            cell.tableView_height.constant = CGFloat(data.item_option.count*30)
            
            cell.totalPrice_label.text = priceFormatter.string(from: price as NSNumber) ?? "0"
            cell.receivePrice_label.text = priceFormatter.string(from: receive_price as NSNumber) ?? "0"
            cell.deservePrice_label.text = priceFormatter.string(from: deserve_price as NSNumber) ?? "0"
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

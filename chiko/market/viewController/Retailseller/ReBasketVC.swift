//
//  ReBasketVC.swift
//  market
//
//  Created by Busan Dynamic on 11/16/23.
//

import UIKit

class ReBasketTC: UITableViewCell {
    
    var BasketObject: BasketData = BasketData()
    
    @IBOutlet weak var storeName_btn: UIButton!
    @IBOutlet weak var choice_img: UIImageView!
    @IBOutlet weak var choice_btn: UIButton!
    @IBOutlet weak var item_img: UIImageView!
    @IBOutlet weak var itemName_btn: UIButton!
    @IBOutlet weak var delete_btn: UIButton!
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
        tableView_heignt.constant = CGFloat(BasketObject.item_option.count*50)
    }
}

extension ReBasketTC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if BasketObject.item_option.count > 0 { return BasketObject.item_option.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = BasketObject.item_option[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReBasketTC2", for: indexPath) as! ReBasketTC
        
        if (data.price-BasketObject.item_sale_price) < 0 {
            cell.optionName_label.text = "옵션. \(data.color) + \(data.size) (₩ \(priceFormatter.string(from: (data.price-BasketObject.item_sale_price) as NSNumber) ?? "0"))"
        } else {
            cell.optionName_label.text = "옵션. \(data.color) + \(data.size) (+₩ \(priceFormatter.string(from: (data.price-BasketObject.item_sale_price) as NSNumber) ?? "0"))"
        }
        cell.optionQuantity_label.text = "수량. \(data.quantity)개"
        cell.optionPrice_label.text = "₩ \(priceFormatter.string(from: (data.price*data.quantity) as NSNumber) ?? "0")"
        
        return cell
    }
}

class ReBasketVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var choice_total: Int = 0
    var sale_total: Int = 0
    var order_total: Int = 0
    
    var ReBasketArray_filter: [BasketData] = []
    var OrderArray: [BasketData] = []
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    @IBOutlet weak var choiceAll_label: UILabel!
    @IBOutlet weak var choiceAll_img: UIImageView!
    @IBOutlet weak var choiceAll_btn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var orderTotalPrice_label: UILabel!
    @IBOutlet weak var order_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReBasketVCdelegate = self
        
        choiceAll_btn.addTarget(self, action: #selector(choiceAll_btn(_:)), for: .touchUpInside)
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .black.withAlphaComponent(0.3)
        refreshControl.addTarget(self, action: #selector(refreshControl(_:)), for: .valueChanged)
        
        order_btn.addTarget(self, action: #selector(order_btn(_:)), for: .touchUpInside)
    }
    
    @objc func refreshControl(_ sender: UIRefreshControl) {
        /// ReBasket 요청
        requestReBasket(type: "get") { status in
            
            switch status {
            case 200:
                self.choiceAllData()
                self.totalData()
                preheatImages(urls: ReBasketArray.compactMap { URL(string: $0.item_mainphoto_img) })
            case 204:
                print("No data")
            case 600:
                self.customAlert(message: "Error occurred during data conversion", time: 1)
            default:
                self.customAlert(message: "Internal server error", time: 1)
            }
            
            self.tableView.reloadData(); sender.endRefreshing()
        }
    }
    
    @objc func choiceAll_btn(_ sender: UIButton) {
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        sender.isSelected = !sender.isSelected
        ReBasketArray.forEach { data in data.choice = sender.isSelected }
        
        choiceAllData()
        totalData()
        tableView.reloadData()
    }
    
    func choiceAllData() {
        
        var choice: Bool = true
        if ReBasketArray.count == 0 { choice = false }
        ReBasketArray.forEach { data in if !data.choice { choice = false } }
        if choice {
            choiceAll_img.image = UIImage(named: "check_on")
        } else {
            choiceAll_img.image = UIImage(named: "check_off")
        }
        
        choiceAll_btn.isSelected = choice
    }
    
    func totalData() {
        
        choice_total = 0
        sale_total = 0
        order_total = 0
        /// 데이터 삭제
        OrderArray.removeAll()
        
        ReBasketArray.enumerated().forEach { i, data in
            if data.choice {
                choice_total += 1
                data.item_option.forEach { data in
                    sale_total += (ReBasketArray[i].item_price-ReBasketArray[i].item_sale_price)*data.quantity
                    order_total += data.price*data.quantity
                }
                /// 데이터 추가
                OrderArray.append(data)
            }
        }
        
        orderTotalPrice_label.text = "₩ \(priceFormatter.string(from: order_total as NSNumber) ?? "0")"
    }
    
    @objc func order_btn(_ sender: UIButton) {
        
        if choice_total == 0 {
            
            let alert = UIAlertController(title: "", message: "주문하실 상품을 선택해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            
            let segue = storyboard?.instantiateViewController(withIdentifier: "ReLiquidateVC") as! ReLiquidateVC
            segue.LiquidateArray = OrderArray
            navigationController?.pushViewController(segue, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
        
        ReStoreVisitVCdelegate = nil
        ReGoodsDetailVCdelegate = nil
        ReOrderVCdelegate = nil
        
        ReBasketArray.sort { $0.basket_key > $1.basket_key }
        choiceAllData()
        totalData()
        tableView.reloadData()
    }
}

extension ReBasketVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1, ReBasketArray.count > 0 {
            return ReBasketArray.count
        } else if section == 2, ReBasketArray.count > 0 {
            return 1
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            let data = ReBasketArray[indexPath.row]
            guard let cell = cell as? ReBasketTC else { return }
            
            setNuke(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 10)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "ReBasketTC0", for: indexPath) as! ReBasketTC
        } else if indexPath.section == 1 {
            
            let data = ReBasketArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReBasketTC1", for: indexPath) as! ReBasketTC
            cell.BasketObject = data
            cell.viewDidLoad()
            
            cell.storeName_btn.setTitle(data.store_name, for: .normal)
            cell.storeName_btn.tag = indexPath.row; cell.storeName_btn.addTarget(self, action: #selector(store_btn(_:)), for: .touchUpInside)
            if data.choice {
                cell.choice_img.image = UIImage(named: "check_on")
            } else {
                cell.choice_img.image = UIImage(named: "check_off")
            }
            cell.choice_btn.tag = indexPath.row; cell.choice_btn.addTarget(self, action: #selector(choice_btn(_:)), for: .touchUpInside)
            cell.itemName_btn.setTitle(data.item_name, for: .normal)
            cell.itemName_btn.tag = indexPath.row; cell.itemName_btn.addTarget(self, action: #selector(itemName_btn(_:)), for: .touchUpInside)
            cell.delete_btn.tag = indexPath.row; cell.delete_btn.addTarget(self, action: #selector(delete_btn(_:)), for: .touchUpInside)
            
            var order_total: Int = 0
            if data.choice {
                data.item_option.forEach { data in
                    order_total += data.price*data.quantity
                }
            }
            cell.orderTotalPrice_label.text = "₩ \(priceFormatter.string(from: order_total as NSNumber) ?? "0")"
            
            return cell
        } else if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReBasketTC3", for: indexPath) as! ReBasketTC
            cell.orderTotalPrice_label.text = "₩ \(priceFormatter.string(from: order_total as NSNumber) ?? "0")"
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func store_btn(_ sender: UIButton) {
        
        let data = ReBasketArray[sender.tag]
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReStoreVisitVC") as! ReStoreVisitVC
        segue.store_id = data.wh_store_id
        navigationController?.pushViewController(segue, animated: true)
    }
    
    @objc func choice_btn(_ sender: UIButton) {
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        let data = ReBasketArray[sender.tag]
        data.choice = !data.choice
        
        choiceAllData()
        totalData()
        tableView.reloadData()
    }
    
    @objc func itemName_btn(_ sender: UIButton) {
        
        let data = ReBasketArray[sender.tag]
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReGoodsDetailVC") as! ReGoodsDetailVC
        segue.store_id = data.wh_store_id
        segue.item_key = data.item_key
        navigationController?.pushViewController(segue, animated: true)
    }
    
    @objc func delete_btn(_ sender: UIButton) {
        
        let data = ReBasketArray[sender.tag]
        let alert = UIAlertController(title: "", message: "상품을 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            /// ReBasket 요청
            requestReBasket(type: "delete", params: ["basket_key": data.basket_key]) { status in
                
                switch status {
                case 200:
                    self.choiceAllData()
                    self.totalData()
                    preheatImages(urls: ReBasketArray.compactMap { URL(string: $0.item_mainphoto_img) })
                case 204:
                    print("No data")
                case 600:
                    self.customAlert(message: "Error occurred during data conversion", time: 1)
                default:
                    self.customAlert(message: "Internal server error", time: 1)
                }
                
                self.tableView.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

//
//  ReLiquidateDetailVC.swift
//  market
//
//  Created by Busan Dynamic on 12/18/23.
//

import UIKit
import PanModal

class ReLiquidateDetailTC: UITableViewCell {
    
    var LiquidateObject: BasketData = BasketData()
    
    @IBOutlet weak var storeName_btn: UIButton!
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
        tableView_heignt.constant = CGFloat(LiquidateObject.item_option.count*50)
    }
}

extension ReLiquidateDetailTC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if LiquidateObject.item_option.count > 0 { return LiquidateObject.item_option.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = LiquidateObject.item_option[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReLiquidateDetailTC2", for: indexPath) as! ReLiquidateDetailTC
        
        if (data.price-LiquidateObject.item_sale_price) < 0 {
            cell.optionName_label.text = "옵션. \(data.color) + \(data.size) (₩ \(priceFormatter.string(from: (data.price-LiquidateObject.item_sale_price) as NSNumber) ?? "0"))"
        } else {
            cell.optionName_label.text = "옵션. \(data.color) + \(data.size) (+₩ \(priceFormatter.string(from: (data.price-LiquidateObject.item_sale_price) as NSNumber) ?? "0"))"
        }
        cell.optionQuantity_label.text = "수량. \(data.quantity)개"
        cell.optionPrice_label.text = "₩ \(priceFormatter.string(from: (data.price*data.quantity) as NSNumber) ?? "0")"
        
        return cell
    }
}

class ReLiquidateDetailVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var LiquidateArray: [BasketData] = []
    var order_total: Int = 0
    
    @IBAction func back_btn(_ sender: UIButton) { dismiss(animated: true, completion: nil) }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.delegate = self; tableView.dataSource = self
    }
}

extension ReLiquidateDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0, LiquidateArray.count > 0 {
            return LiquidateArray.count
        } else if section == 1, LiquidateArray.count > 0 {
            return 1
        } else {
            return .zero
        }

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            let data = LiquidateArray[indexPath.row]
            guard let cell = cell as? ReLiquidateDetailTC else { return }
            
            setNuke(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 10)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let data = LiquidateArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReLiquidateDetailTC1", for: indexPath) as! ReLiquidateDetailTC
            
            cell.storeName_btn.setTitle(data.store_name, for: .normal)
            cell.itemName_btn.setTitle(data.item_name, for: .normal)
            cell.LiquidateObject = data
            cell.viewDidLoad()
            
            var order_total: Int = 0
            if data.choice {
                data.item_option.forEach { data in
                    order_total += data.price*data.quantity
                }
            }
            cell.orderTotalPrice_label.text = "₩ \(priceFormatter.string(from: order_total as NSNumber) ?? "0")"
            
            return cell
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReLiquidateDetailTC3", for: indexPath) as! ReLiquidateDetailTC
            cell.orderTotalPrice_label.text = "₩ \(priceFormatter.string(from: order_total as NSNumber) ?? "0")"
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

extension ReLiquidateDetailVC: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var cornerRadius: CGFloat {
        return 15
    }
    
    var shortFormHeight: PanModalHeight {
        return .maxHeight
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeight
    }
}


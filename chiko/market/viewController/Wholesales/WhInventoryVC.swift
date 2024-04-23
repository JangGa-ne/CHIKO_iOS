//
//  WhInventoryVC.swift
//  market
//
//  Created by 장 제현 on 3/20/24.
//

import UIKit
import PanModal

class WhInventoryTC: UITableViewCell {
    
    var delegate: WhInventoryVC = WhInventoryVC()
    var InventoryObject: InventoryData = InventoryData()
    
    @IBOutlet weak var option_v: UIView!
    @IBOutlet weak var dot_v: UIView!
    
    @IBOutlet weak var itemName_label: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalOptionQuantity_label: UILabel!
    @IBOutlet weak var option_label: UILabel!
    @IBOutlet weak var optionPrice_label: UILabel!
    @IBOutlet weak var requestedQuantity_label: UILabel!
    @IBOutlet weak var quantity_label: UILabel!
    @IBOutlet weak var requiredQuantity_label: UILabel!
    @IBOutlet weak var datetime_label: UILabel!
    
    @IBOutlet weak var edit_btn: UIButton!
    
    func viewDidLoad() {
        
        tableView.delegate = nil; tableView.dataSource = nil
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        tableView.delegate = self; tableView.dataSource = self
    }
}

extension WhInventoryTC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if InventoryObject.item_option.count > 0 { return InventoryObject.item_option.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = InventoryObject.item_option[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhInventoryTC2", for: indexPath) as! WhInventoryTC
        
        if InventoryObject.position == indexPath.row {
            cell.option_v.backgroundColor = .H_8CD26B
            cell.option_label.font = UIFont.boldSystemFont(ofSize: 12)
            cell.option_label.textColor = .white
        } else {
            cell.option_v.backgroundColor = .clear
            cell.option_label.font = UIFont.systemFont(ofSize: 12)
            cell.option_label.textColor = .black.withAlphaComponent(0.3)
        }
        cell.option_label.text = "\(data.color) / \(data.size)"
        cell.dot_v.isHidden = (data.date == "")
        
        if InventoryObject.position == indexPath.row {
            totalOptionQuantity_label.text = "총판매량. " + (priceFormatter.string(from: data.total_option_quantity as NSNumber) ?? "0")
            option_label.text = "\(data.color) / \(data.size)"
            optionPrice_label.text = "가격. \(priceFormatter.string(from: data.price as NSNumber) ?? "0")"
            requestedQuantity_label.text = "주문수량. \(priceFormatter.string(from: data.requested_quantity as NSNumber) ?? "0")"
            quantity_label.text = "재고수량. \(priceFormatter.string(from: data.quantity as NSNumber) ?? "0")"
            requiredQuantity_label.text = -(data.quantity-data.requested_quantity) > 0 ? "필요수량. \(priceFormatter.string(from: -(data.quantity-data.requested_quantity) as NSNumber) ?? "0")" : "필요수량. 0"
            datetime_label.text = "재입고일. \(data.date)"
            edit_btn.tag = indexPath.row; edit_btn.addTarget(self, action: #selector(edit_btn(_:)), for: .touchUpInside)
        }
        
        return cell
    }
    
    @objc func edit_btn(_ sender: UIButton) {
        
        let option = InventoryObject.item_option[sender.tag]
        
        let alert = UIAlertController(title: nil, message: "재입고일 또는 품절 등록/수정", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "재입고일", style: .default, handler: { UIAlertAction in
            let segue = self.delegate.storyboard?.instantiateViewController(withIdentifier: "CalendarVC") as! CalendarVC
            segue.WhInventoryTCdelegate = self
            segue.start_date = (option.date == "" || option.date == "품절") ? setDate(dateformat: "yy.MM.dd") : option.date
            segue.indexpath_row = sender.tag
            self.delegate.presentPanModal(segue)
        }))
        alert.addAction(UIAlertAction(title: "품절", style: .default, handler: { UIAlertAction in
            option.date = "품절"
            self.tableView.reloadData(); self.register()
        }))
        alert.addAction(UIAlertAction(title: "내용삭제", style: .destructive, handler: { UIAlertAction in
            option.date.removeAll(); self.register()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        delegate.present(alert, animated: true, completion: nil)
    }
    
    func register() {
        
        delegate.customLoadingIndicator(animated: true)
        
        var item_option: Array<[String: Any]> = []
        InventoryObject.item_option.forEach { option in
            item_option.append([
                "color": option.color,
                "date": option.date,
                "price": option.price,
                "quantity": option.quantity,
                "requested_quantity": option.requested_quantity,
                "size": option.size,
                "sold_out": option.date == "품절" ? "true" : "false",
                "total_option_quantity": option.total_option_quantity,
                "weight": option.weight,
            ])
        }
        
        let params: [String: Any] = [
            "action": "edit",
            "collection_id": "inventory",
            "document_id": "\(StoreObject.store_id)_\(InventoryObject.item_key)",
            "item_option": item_option,
        ]
        /// EditDB 요청
        requestEditDB(params: params) { status in
            
            self.delegate.customLoadingIndicator(animated: false)
            
            if status == 200 {
                self.delegate.alert(title: "", message: "등록/수정 되었습니다.", style: .alert, time: 1)
            } else {
                self.delegate.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
            }; self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        InventoryObject.position = indexPath.row; tableView.reloadData()
    }
}

class WhInventoryVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var InventoryArray: [InventoryData] = []
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .black.withAlphaComponent(0.3)
        refreshControl.addTarget(self, action: #selector(refreshControl(_:)), for: .valueChanged)
        
        customLoadingIndicator(text: "불러오는 중...", animated: true)
        
        loadingData()
    }
    
    @objc func refreshControl(_ sender: UIRefreshControl) {
        loadingData(); sender.endRefreshing()
    }
    
    func loadingData() {
        
        requestWhInventory { array, status in
            
            self.customLoadingIndicator(animated: false)
            
            if status == 200 {
                self.InventoryArray = array
                self.problemAlert(view: self.tableView)
            } else if status == 204 {
                self.problemAlert(view: self.tableView, type: "nodata")
            } else {
                self.problemAlert(view: self.tableView, type: "error")
            }; self.tableView.reloadData()
        }
    }
}

extension WhInventoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if InventoryArray.count > 0 { return InventoryArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = InventoryArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhInventoryTC1", for: indexPath) as! WhInventoryTC
        cell.delegate = self
        cell.InventoryObject = data
        cell.viewDidLoad()
        
        cell.itemName_label.text = data.item_name
        
        return cell
    }
}

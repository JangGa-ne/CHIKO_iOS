//
//  WhNotDeliveryVC.swift
//  market
//
//  Created by Busan Dynamic on 2/2/24.
//

import UIKit
import PanModal

class WhNotDeliveryTC: UITableViewCell {
    
    var delegate: WhNotDeliveryVC = WhNotDeliveryVC()
    var indexpath_section: Int = 0
    var indexpath_row: Int = 0
    
    @IBOutlet weak var datetime_label: UILabel!
    @IBOutlet weak var itemName_label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_height: NSLayoutConstraint!
    
    @IBOutlet weak var option_label: UILabel!
    @IBOutlet weak var notDeliveryQuantity_label: UILabel!
    @IBOutlet weak var NotDeliveryMemo_label: UILabel!
    
    func viewDidLoad() {
        
        tableView.delegate = nil; tableView.dataSource = nil
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        
        if delegate.filter == "전체보기" {
            tableView_height.constant = CGFloat(30*delegate.WhNotDelivery_all[indexpath_row].item_option.count)
        } else if delegate.filter == "날짜별" {
            tableView_height.constant = CGFloat(60*delegate.WhNotDelivery_date[indexpath_section].data[indexpath_row].item_option.count)
        }
    }
}

extension WhNotDeliveryTC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if delegate.filter == "전체보기", delegate.WhNotDelivery_all[indexpath_row].item_option.count > 0 {
            return delegate.WhNotDelivery_all[indexpath_row].item_option.count
        } else if delegate.filter == "날짜별", delegate.WhNotDelivery_date[indexpath_section].data[indexpath_row].item_option.count > 0 {
            return delegate.WhNotDelivery_date[indexpath_section].data[indexpath_row].item_option.count
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if delegate.filter == "전체보기" {
            
            let data = delegate.WhNotDelivery_all[indexpath_row].item_option[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhNotDeliveryTC2", for: indexPath) as! WhNotDeliveryTC
            
            cell.option_label.text = "\(data.color) / \(data.size)"
            cell.notDeliveryQuantity_label.text = priceFormatter.string(from: data.not_delivery_quantity as NSNumber) ?? "0"
            cell.NotDeliveryMemo_label.text = "-"
            
            return cell
        } else if delegate.filter == "날짜별" {
            
            let data = delegate.WhNotDelivery_date[indexpath_section].data[indexpath_row].item_option[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhNotDeliveryTC3", for: indexPath) as! WhNotDeliveryTC
            
            cell.option_label.text = "옵션. \(data.color) / \(data.size)\n가격. \(priceFormatter.string(from: data.price as NSNumber) ?? "0")\n수량.\(data.quantity)"
            cell.notDeliveryQuantity_label.text = priceFormatter.string(from: data.not_delivery_quantity as NSNumber) ?? "0"
            cell.NotDeliveryMemo_label.text = data.not_delivery_memo
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

class WhNotDeliveryVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var filter: String = "전체보기"
    
    var WhNotDelivery: [WhNotDeliveryData] = []
    var WhNotDelivery_date: [(date: String, data: [WhNotDeliveryData])] = []
    var WhNotDelivery_all: [WhNotDeliveryData] = []
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    @IBOutlet weak var filter_btn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filter_btn.setTitle("전체보기", for: .normal)
        filter_btn.addTarget(self, action: #selector(filter_btn(_:)), for: .touchUpInside)
        
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
        /// 데이터 삭제
        WhNotDelivery.removeAll(); tableView.reloadData()
        
        loadingData(); sender.endRefreshing()
    }
    
    func loadingData() {
        
        var status_code: Int = 500
        /// WhNotDelivery 요청
        dispatchGroup.enter()
        requestWhNotDelivery { array, status in
            self.WhNotDelivery = array
            status_code = status; dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            
            self.customLoadingIndicator(animated: false)
            
            if status_code == 200 {
                self.filter = self.filter_btn.titleLabel?.text! ?? "" == "전체보기" ? "날짜별" : "전체보기"
                self.filter_btn(UIButton())
                self.problemAlert(view: self.tableView)
            } else if status_code == 204 {
                self.problemAlert(view: self.tableView, type: "nodata")
            } else {
                self.problemAlert(view: self.tableView, type: "error")
            }
        }
    }
    
    @objc func filter_btn(_ sender: UIButton) {
        /// 데이터 삭제
        WhNotDelivery_all.removeAll(); WhNotDelivery_date.removeAll()
        
        sender.setTitle(filter == "전체보기" ? "날짜별" : "전체보기", for: .normal)
        
        if filter == "날짜별" { filter = "전체보기"
            
            WhNotDelivery_all.removeAll()
            
            WhNotDelivery.forEach { data in
                
                if let index = WhNotDelivery_all.firstIndex(where: { $0.item_key == data.item_key }) {
                    data.item_option.forEach { option in
                        if let existingOptionIndex = WhNotDelivery_all[index].item_option.firstIndex(where: { $0.color == option.color && $0.size == option.size }) {
                            WhNotDelivery_all[index].item_option[existingOptionIndex].not_delivery_quantity += option.not_delivery_quantity
                        } else {
                            WhNotDelivery_all[index].item_option.append(option)
                        }
                    }
                } else {
                    WhNotDelivery_all.append(data)
                }
            }
            WhNotDelivery_all.sort { $0.item_name < $1.item_name }
            
        } else if filter == "전체보기" { filter = "날짜별"
            
            WhNotDelivery_date = Dictionary(grouping: WhNotDelivery, by: { $0.processing_key }).flatMap { [(date: $0.key, data: $0.value)] }
            WhNotDelivery_date.sort { $0.date > $1.date }
            WhNotDelivery_date.indices.forEach { i in
                WhNotDelivery_date[i].data.sort { $0.processing_key > $1.processing_key }
            }
        }
        
        tableView.reloadData()
        tableView.setContentOffset(CGPoint(x: 0, y: -50), animated: true)
    }
}

extension WhNotDeliveryVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if filter == "전체보기", WhNotDelivery_all.count > 0 {
            return 1
        } else if filter == "날짜별", WhNotDelivery_date.count > 0 {
            return WhNotDelivery_date.count
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filter == "전체보기", WhNotDelivery_all.count > 0 {
            return WhNotDelivery_all.count
        } else if filter == "날짜별", WhNotDelivery_date.count > 0 {
            return WhNotDelivery_date[section].data.count
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhNotDeliveryTC1", for: indexPath) as! WhNotDeliveryTC
        cell.delegate = self
        cell.indexpath_section = indexPath.section
        cell.indexpath_row = indexPath.row
        cell.viewDidLoad()
        
        cell.datetime_label.isHidden = (filter == "전체보기")
        
        if filter == "전체보기" {
            
            let data = WhNotDelivery_all[indexPath.row]
            
            cell.itemName_label.text = data.item_name
            
        } else if filter == "날짜별" {
            
            let data = WhNotDelivery_date[indexPath.section].data[indexPath.row]
            
            cell.datetime_label.isHidden = (indexPath.row != 0)
            cell.datetime_label.text = setTimestampToDateTime(timestamp: Int(WhNotDelivery_date[indexPath.section].date) ?? 0, dateformat: "yyyy. MM. dd.")
            cell.itemName_label.text = data.item_name
        }
        
        return cell
    }
}

//
//  WhNotDeliveryVC.swift
//  market
//
//  Created by Busan Dynamic on 2/2/24.
//

import UIKit
import PanModal

class WhNotDeliveryTC: UITableViewCell {
    
    var delegate: WhNotDeliveryVC? = nil
    var indexpath_row: Int = 0
    
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
    }
}

extension WhNotDeliveryTC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if delegate?.filter == "전체보기" {
            return 1
        } else if delegate?.filter == "날짜별" {
            return 3
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhNotDeliveryTC2", for: indexPath) as! WhNotDeliveryTC
        
        if delegate?.filter == "전체보기" {
            
        } else if delegate?.filter == "날짜별" {
            
        }
        
        return cell
    }
}

class WhNotDeliveryVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var filter: String = "전체보기"
    
    var WhNotDelivery_date: [WhNotDeliveryData] = []
    var WhNotDelivery_all: [WhNotDeliveryData] = []
    
    @IBAction func back_btn(_ sender: UIButton) { dismiss(animated: true, completion: nil) }
    @IBOutlet weak var filter_btn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filter_btn.setTitle("전체보기", for: .normal)
        filter_btn.addTarget(self, action: #selector(filter_btn(_:)), for: .touchUpInside)
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
    }
    
    @objc func filter_btn(_ sender: UIButton) {
        
        sender.setTitle(filter == "전체보기" ? "날짜별" : "전체보기", for: .normal)
        
        if filter == "전체보기" {
            
            filter = "날짜별"
            
        } else if filter == "날짜별" {
            
            filter = "전체보기"
            
        }
        
        tableView.reloadData()
    }
}

extension WhNotDeliveryVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filter == "전체보기" {
            return 1
        } else if filter == "날짜별" {
            return 1
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhNotDeliveryTC1", for: indexPath) as! WhNotDeliveryTC
        cell.delegate = self
        cell.viewDidLoad()
        
        if filter == "전체보기" {
            
        } else if filter == "날짜별" {
            
        }
        
        return cell
    }
}

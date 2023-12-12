//
//  EmployeeVC.swift
//  market
//
//  Created by 장 제현 on 12/10/23.
//

import UIKit

class EmployeeTC: UITableViewCell {
    
    @IBOutlet weak var employeeId_label: UILabel!
    @IBOutlet weak var employeeName_label: UILabel!
    @IBOutlet weak var delete_btn: UIButton!
    @IBOutlet weak var lineView: UIView!
}

class EmployeeVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var EmployeeArray: [MemberData] = []
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .lightGray
        refreshControl.addTarget(self, action: #selector(refreshControl(_:)), for: .valueChanged)
        
        loadingData()
    }
    
    @objc func refreshControl(_ sender: UIRefreshControl) {
        loadingData(); sender.endRefreshing()
    }
    
    func loadingData() {
        /// 데이터 삭제
        EmployeeArray.removeAll(); tableView.reloadData()
        /// Employee 요청
        requestEmployee { array, status in
            
            switch status {
            case 200:
                self.EmployeeArray += array; self.tableView.reloadData()
            case 204:
                self.customAlert(message: "No data", time: 1)
            case 600:
                self.customAlert(message: "Error occurred during data conversion", time: 1)
            default:
                self.customAlert(message: "Internal server error", time: 1)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

extension EmployeeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if EmployeeArray.count > 0 { return EmployeeArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = EmployeeArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeTC", for: indexPath) as! EmployeeTC
        
        cell.employeeId_label.text = data.member_id
        if data.member_grade == "ceo" {
            cell.employeeName_label.text = "\(data.member_name)(CEO)"
        } else {
            cell.employeeName_label.text = data.member_name
        }
        cell.delete_btn.isHidden = (data.member_grade == "ceo")
        cell.delete_btn.tag = indexPath.row; cell.delete_btn.addTarget(self, action: #selector(delete_btn(_:)), for: .touchUpInside)
        cell.lineView.isHidden = (indexPath.row == EmployeeArray.count-1)
        
        return cell
    }
    
    @objc func delete_btn(_ sender: UIButton) {
        
    }
}

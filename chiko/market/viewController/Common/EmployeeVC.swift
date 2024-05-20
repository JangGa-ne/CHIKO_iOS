//
//  EmployeeVC.swift
//  market
//
//  Created by 장 제현 on 12/10/23.
//

/// 번역완료

import UIKit

class EmployeeTC: UITableViewCell {
    
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var employeeId_label: UILabel!
    @IBOutlet weak var employeeName_label: UILabel!
    @IBOutlet weak var delete_btn: UIButton!
}

class EmployeeVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var EmployeeArray: [MemberData] = []
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var storePw_tf: UITextField!
    @IBOutlet weak var storePw_btn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in label.text = translation(label.text!) }
        buttons.forEach { btn in btn.setTitle(translation(btn.title(for: .normal)), for: .normal) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storePw_tf.text = StoreObject.store_pw
        storePw_tf.addTarget(self, action: #selector(edit_storePw_tf(_:)), for: .editingChanged)
        storePw_btn.addTarget(self, action: #selector(storePw_btn(_:)), for: .touchUpInside)
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .black.withAlphaComponent(0.3)
        refreshControl.addTarget(self, action: #selector(refreshControl(_:)), for: .valueChanged)
        
        loadingData()
    }
    
    @objc func edit_storePw_tf(_ sender: UITextField) {
        sender.text! = String(sender.text!.prefix(4))
    }
    
    @objc func storePw_btn(_ sender: UIButton) {
        
        if storePw_tf.text!.count < 4 {
            customAlert(message: "4자리 이상 입력해 주세요.", time: 1)
        } else {
            storePw_tf.resignFirstResponder()
            
            let params: [String: Any] = [
                "action": "edit",
                "collection_id": "store",
                "document_id": StoreObject.store_id,
                "store_pw": storePw_tf.text!,
            ]
            /// Edit DB 요청
            requestEditDB(params: params) { status in
                
                switch status {
                case 200:
                    StoreObject.store_pw = self.storePw_tf.text!
                    self.alert(title: "", message: translation("변경되었습니다."), style: .alert, time: 1)
                    self.storePw_btn.backgroundColor = .H_8CD26B
                default:
                    self.storePw_btn.backgroundColor = .red
                    self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
                }
            }
        }
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
                self.EmployeeArray += array
                self.problemAlert(view: self.tableView)
            case 204:
                self.problemAlert(view: self.tableView, type: "nodata")
            default:
                self.problemAlert(view: self.tableView, type: "error")
            }; self.tableView.reloadData()
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
        
        cell.buttons.forEach { btn in btn.setTitle(translation(btn.title(for: .normal)), for: .normal) }
        
        cell.employeeId_label.text = data.member_id
        if data.member_grade == "ceo" {
            cell.employeeName_label.text = "\(data.member_name)(CEO)"
        } else {
            cell.employeeName_label.text = data.member_name
        }
        cell.delete_btn.isHidden = (data.member_grade == "ceo")
        cell.delete_btn.tag = indexPath.row; cell.delete_btn.addTarget(self, action: #selector(delete_btn(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func delete_btn(_ sender: UIButton) {
        
        
    }
}

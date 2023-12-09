//
//  ReEmployeeVC.swift
//  market
//
//  Created by 장 제현 on 12/10/23.
//

import UIKit

class ReEmployeeTC: UITableViewCell {
    
    @IBOutlet weak var employeeName_label: UILabel!
    @IBOutlet weak var employeeId_label: UILabel!
    @IBOutlet weak var delete_btn: UIButton!
    @IBOutlet weak var lineView: UIView!
}

class ReEmployeeVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var EmployeeArray: [GoodsData] = []
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
    }
    
    func loadingData() {
        
        
    }
}

extension ReEmployeeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if EmployeeArray.count > 0 { return EmployeeArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = EmployeeArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReEmployeeTC", for: indexPath) as! ReEmployeeTC
        
        return cell
    }
}

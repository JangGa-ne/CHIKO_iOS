//
//  AccountVC.swift
//  market
//
//  Created by Busan Dynamic on 12/12/23.
//

import UIKit

class AccountTC: UITableViewCell {
    
    @IBOutlet weak var accountName_label: UILabel!
    @IBOutlet weak var bankName_label: UILabel!
    @IBOutlet weak var accountNumber_label: UILabel!
}

class AccountVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var AccountArray: Array<[String: Any]> = []
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var add_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        StoreObject.account
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

extension AccountVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if AccountArray.count > 0 { return AccountArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = AccountArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTC", for: indexPath) as! AccountTC
        
        return cell
    }
}

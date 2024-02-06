//
//  WhUndeliveryVC.swift
//  market
//
//  Created by Busan Dynamic on 2/2/24.
//

import UIKit
import PanModal

class WhUndeliveryTC: UITableViewCell {
    
    @IBOutlet weak var itemName_label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_height: NSLayoutConstraint!
    
    @IBOutlet weak var option_label: UILabel!
    @IBOutlet weak var notDeliveryQuantity_tf: UITextField!
    @IBOutlet weak var UndeliveryMemo_tf: UITextField!
}

class WhUndeliveryVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBAction func back_btn(_ sender: UIButton) { dismiss(animated: true, completion: nil) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var date_label: UILabel!
    
    @IBOutlet weak var register_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        
        register_btn.addTarget(self, action: #selector(register_btn(_:)), for: .touchUpInside)
    }
    
    @objc func register_btn(_ sender: UIButton) {
        
    }
}

extension WhUndeliveryVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhUndeliveryTC", for: indexPath) as! WhUndeliveryTC
        
        return cell
    }
}

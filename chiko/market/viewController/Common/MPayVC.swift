//
//  MPayVC.swift
//  market
//
//  Created by Busan Dynamic on 1/9/24.
//

import UIKit

class MPayTC: UITableViewCell {
    
    @IBOutlet weak var dateTime_label: UILabel!
    @IBOutlet weak var chinaPrice_label: UILabel!
    @IBOutlet weak var content_label: UILabel!
    @IBOutlet weak var cash_label: UILabel!
}

class MPayVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var storeCash_label: UILabel!
    @IBOutlet weak var addCash_btn: UIButton!
    @IBOutlet weak var refundCash_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MPayVCdelegate = self
        
        storeCash_label.text = "\(priceFormatter.string(from: StoreObject.store_cash as NSNumber) ?? "0") M"
        ([addCash_btn, refundCash_btn] as [UIButton]).enumerated().forEach { i, btn in
            btn.tag = i; btn.addTarget(self, action: #selector(segue_btn(_:)), for: .touchUpInside)
        }
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
    }
    
    @objc func segue_btn(_ sender: UIButton) {
        if sender.tag == 0 {
            
        } else if sender.tag == 1 {
            
        }
    }
}

extension MPayVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MPayTC", for: indexPath) as! MPayTC
        
        return cell
    }
}

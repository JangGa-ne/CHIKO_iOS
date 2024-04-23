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
    
    var StoreCashArray: [StoreCashData] = []
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var storeCash_label: UILabel!
    @IBOutlet weak var addCash_btn: UIButton!
    @IBOutlet weak var refundCash_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MPayVCdelegate = self
        
        ([addCash_btn, refundCash_btn] as [UIButton]).enumerated().forEach { i, btn in
            btn.tag = i; btn.addTarget(self, action: #selector(segue_btn(_:)), for: .touchUpInside)
        }
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        
        customLoadingIndicator(text: "불러오는 중...", animated: true)
        
        requestMPayList { array, status in
            
            self.customLoadingIndicator(animated: false)
            self.storeCash_label.text = priceFormatter.string(from: StoreObject.store_cash as NSNumber) ?? "0"
            
            if status == 200 {
                self.problemAlert(view: self.tableView)
                self.StoreCashArray += array
                self.tableView.reloadData()
            } else if status == 204 {
                self.problemAlert(view: self.tableView, type: "nodata")
            } else {
                self.problemAlert(view: self.tableView, type: "error")
            }
        }
    }
    
    @objc func segue_btn(_ sender: UIButton) {
        segueViewController(identifier: "MPayChargeVC")
    }
}

extension MPayVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if StoreCashArray.count > 0 { return StoreCashArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = StoreCashArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MPayTC", for: indexPath) as! MPayTC
        
        cell.dateTime_label.text = setTimestampToDateTime(timestamp: Int(data.datetime) ?? 0)
        cell.chinaPrice_label.isHidden = data.use_cash
        cell.chinaPrice_label.text = "¥\(priceFormatter.string(from: data.ch_cash as NSNumber) ?? "0.0")"
        cell.content_label.text = data.use_where
        cell.cash_label.textColor = data.use_cash ? .black.withAlphaComponent(0.7) : .H_8CD26B
        let cash = priceFormatter.string(from: data.kr_cash as NSNumber) ?? "0"
        cell.cash_label.text = data.use_cash ? "-\(cash)" : "+\(cash)"
        
        return cell
    }
}

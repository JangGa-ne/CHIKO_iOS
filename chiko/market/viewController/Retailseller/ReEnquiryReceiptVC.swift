//
//  ReEnquiryReceiptVC.swift
//  market
//
//  Created by Busan Dynamic on 2/16/24.
//

import UIKit

class ReEnquiryReceiptTC: UITableViewCell {
    
    @IBOutlet weak var storeName_label: UILabel!
    @IBOutlet weak var datetime_label: UILabel!
}

class ReEnquiryReceiptVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var ReEnquiryReceiptArray: [(store_name: String, summary_address: String, timestamp: String, data: [ReEnquiryReceiptData])] = []
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var receiptUpload_v: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReEnquiryReceiptVCdelegate = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        
        customLoadingIndicator(animated: true)
        /// ReEnquiryReceipt 요청
        requestReEnquiryReceipt { array, _, status in
            
            self.customLoadingIndicator(animated: false)
            
            switch status {
            case 200:
                self.ReEnquiryReceiptArray += array; self.tableView.reloadData()
            case 204:
                self.customAlert(message: "No Data", time: 1)
            case 600:
                self.customAlert(message: "Error occurred during data conversion", time: 1)
            default:
                self.customAlert(message: "Internal server error", time: 1)
            }
        }
        
        receiptUpload_v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(receiptUpload_v(_:))))
    }
    
    @objc func receiptUpload_v(_ sender: UITapGestureRecognizer) {
        segueViewController(identifier: "ReReceiptUploadVC")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
        
        ReReceiptUploadVCdelegate = nil
        ReReceiptUploadTCdelegate = nil
    }
}

extension ReEnquiryReceiptVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ReEnquiryReceiptArray.count > 0 { return ReEnquiryReceiptArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = ReEnquiryReceiptArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReEnquiryReceiptTC", for: indexPath) as! ReEnquiryReceiptTC
        
        cell.storeName_label.text = data.store_name != "" ? "\(data.store_name), \(data.summary_address)" : data.summary_address
        cell.datetime_label.text = setTimestampToDateTime(timestamp: Int(data.timestamp) ?? 0, dateformat: "yyyy.MM.dd a hh:mm")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let segue = self.storyboard?.instantiateViewController(withIdentifier: "ReEnquiryReceiptDetailVC") as! ReEnquiryReceiptDetailVC
        segue.ReEnquiryReceiptArray = [ReEnquiryReceiptArray[indexPath.row]]
        navigationController?.pushViewController(segue, animated: true)
    }
}

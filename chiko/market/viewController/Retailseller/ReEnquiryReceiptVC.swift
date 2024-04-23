//
//  ReEnquiryReceiptVC.swift
//  market
//
//  Created by Busan Dynamic on 2/16/24.
//

import UIKit

class ReEnquiryReceiptTC: UITableViewCell {
    
    @IBOutlet weak var readOrNot_v: UIView!
    @IBOutlet weak var storeName_label: UILabel!
    @IBOutlet weak var datetime_label: UILabel!
}

class ReEnquiryReceiptVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var ReEnquiryReceiptArray: [(store_name: String, summary_address: String, timestamp: String, data: [ReEnquiryReceiptData])] = []
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var receiptUpload_v: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReEnquiryReceiptVCdelegate = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 75, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .black.withAlphaComponent(0.3)
        refreshControl.addTarget(self, action: #selector(refreshControl(_:)), for: .valueChanged)
        
        customLoadingIndicator(text: "불러오는 중...", animated: true)
        
        loadingData()
        
        receiptUpload_v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(receiptUpload_v(_:))))
    }
    
    @objc func refreshControl(_ sender: UIRefreshControl) {
        /// 데이터 삭제
        ReEnquiryReceiptArray.removeAll(); tableView.reloadData()
        
        loadingData(); sender.endRefreshing()
    }
    
    func loadingData() {
        /// ReEnquiryReceipt 요청
        requestReEnquiryReceipt { array, status in
            
            self.customLoadingIndicator(animated: false)
            
            if status == 200 {
                self.problemAlert(view: self.tableView)
                self.ReEnquiryReceiptArray = array
            } else if status == 204 {
                self.problemAlert(view: self.tableView, type: "nodata")
            } else {
                self.problemAlert(view: self.tableView, type: "error")
            }; self.tableView.reloadData()
        }
    }
    
    @objc func receiptUpload_v(_ sender: UITapGestureRecognizer) {
        segueViewController(identifier: "ReReceiptUploadVC")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
        
        ReReceiptUploadVCdelegate = nil
        ReReceiptUploadTCdelegate = nil
        ReEnquiryReceiptDetailVCdelegate = nil
    }
}

extension ReEnquiryReceiptVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ReEnquiryReceiptArray.count > 0 { return ReEnquiryReceiptArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = ReEnquiryReceiptArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReEnquiryReceiptTC", for: indexPath) as! ReEnquiryReceiptTC
        
        cell.readOrNot_v.isHidden = (data.data.filter { $0.direction == "touser" && !$0.read_or_not }.count == 0)
        cell.storeName_label.text = data.store_name != "" ? "\(data.store_name), \(data.summary_address)" : data.summary_address
        cell.datetime_label.text = setTimestampToDateTime(timestamp: Int(data.timestamp) ?? 0, dateformat: "yyyy.MM.dd a hh:mm")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = ReEnquiryReceiptArray[indexPath.row]
        let segue = self.storyboard?.instantiateViewController(withIdentifier: "ReEnquiryReceiptDetailVC") as! ReEnquiryReceiptDetailVC
        segue.enquiry_time = data.timestamp
        segue.ReEnquiryReceiptArray = [data]
        navigationController?.pushViewController(segue, animated: true)
    }
}

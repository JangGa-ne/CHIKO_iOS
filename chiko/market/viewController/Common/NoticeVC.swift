//
//  NoticeVC.swift
//  market
//
//  Created by 장 제현 on 5/3/24.
//

/// 번역완료

import UIKit

class NoticeTC: UITableViewCell {
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var noticeDot_v: UIView!
    @IBOutlet weak var body_label: UILabel!
}

class NoticeVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    @IBOutlet var labels: [UILabel]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in label.text = translation(label.text!) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NoticeVCdelegate = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .black.withAlphaComponent(0.3)
        refreshControl.addTarget(self, action: #selector(refreshControl(_:)), for: .valueChanged)
        
        customLoadingIndicator(animated: true)
        
        loadingData()
    }
    
    @objc func refreshControl(_ sender: UIRefreshControl) {
        loadingData(); sender.endRefreshing()
    }
    
    func loadingData() {
        /// 데이터 삭제
        NoticeArray.removeAll()
        
        requestNotice { status in
            
            self.customLoadingIndicator(animated: false)
            
            switch status {
            case 200:
                self.problemAlert(view: self.tableView)
                notice_read = NoticeArray.allSatisfy { $0.read_or_not }
            case 204:
                self.problemAlert(view: self.tableView, type: "nodata")
            default:
                self.problemAlert(view: self.tableView, type: "error")
            }; self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
    }
}

extension NoticeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if NoticeArray.count > 0 { return NoticeArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = NoticeArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeTC", for: indexPath) as! NoticeTC
        
        cell.title_label.text = data.title
        cell.noticeDot_v.isHidden = data.read_or_not
        cell.body_label.text = data.body
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = NoticeArray[indexPath.row]
        let params: [String: Any] = [
            "action": "edit",
            "collection_id": "notice",
            "document_id": StoreObject.store_id,
            data.datetime: [
                "body": data.body,
                "datetime": data.datetime,
                "order_key": data.order_key,
                "read_or_not": "true",
                "segue": data.segue,
                "title": data.title,
                "type": data.type,
            ]
        ]
        
        requestEditDB(params: params) { status in
            
            NoticeArray[indexPath.row].read_or_not = (status == 200)
            tableView.reloadRows(at: [indexPath], with: .none)
            
            notice_read = NoticeArray.allSatisfy { $0.read_or_not }
            if let delegate = ReHomeVCdelegate {
                delegate.noticeDot_v.isHidden = notice_read
            }
            if let delegate = ReGoodsVCdelegate {
                delegate.noticeDot_v.isHidden = notice_read
            }
            if let delegate = ReMyPageVCdelegate {
                delegate.noticeDot_v.isHidden = notice_read
            }
            if let delegate = WhHomeVCdelegate {
                delegate.noticeDot_v.isHidden = notice_read
            }
        }
        
        if data.type == "dpcost_request" {
            segueViewController(identifier: "ReOrderVC")
        } else if data.type == "local", data.segue == "order_batch_processing" {
            segueViewController(identifier: "WhOrderBatchVC")
        } else if data.type == "chats" {
            segueViewController(identifier: "WhChatVC")
        }
    }
}

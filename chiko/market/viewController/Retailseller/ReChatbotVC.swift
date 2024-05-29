//
//  ReChatbotVC.swift
//  market
//
//  Created by Busan Dynamic on 5/27/24.
//

import UIKit

class ReChatbotTC: UITableViewCell {
    
    @IBOutlet weak var comment_v: UIView!
    @IBOutlet weak var content_label: UILabel!
    @IBOutlet weak var datetimeReadorNot_label: UILabel!
}

class ReChatbotVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var ChatbotArray: [ChatbotData] = []
    
    @IBOutlet weak var storeMain_img: UIImageView!
    @IBOutlet weak var choiceStore_btn: UIButton!
    @IBOutlet weak var noticeDot_v: UIView!
    @IBOutlet weak var notice_btn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var content_tv: UITextView!
    @IBOutlet weak var send_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReChatbotVCdelegate = self
        
        setKeyboard()
        
//        setKingfisher(imageView: storeMain_img, imageUrl: StoreObject.store_mainphoto_img, cornerRadius: 15)
//        choiceStore_btn.addTarget(self, action: #selector(choiceStore_btn(_:)), for: .touchUpInside)
        noticeDot_v.isHidden = notice_read
        notice_btn.addTarget(self, action: #selector(notice_btn(_:)), for: .touchUpInside)
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        
        content_tv.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        send_btn.addTarget(self, action: #selector(send_btn(_:)), for: .touchUpInside)
        
        loadingData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(show(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func notice_btn(_ sender: UIButton) {
        segueViewController(identifier: "NoticeVC")
    }
    
    @objc func send_btn(_ sender: UIButton) {
        if content_tv.text!.replacingOccurrences(of: " ", with: "") != "" {
            loadingData(action: "set", content: content_tv.text!); content_tv.text?.removeAll()
        }
    }
    
    func loadingData(action: String = "get", content: String = "") {
        
        requestChatbot(action: action, content: content) { array, status in
            
            if status == 200 {
                self.ChatbotArray = array
            }; self.tableView.reloadData()
            
            if array.count > 0 { self.tableView.scrollToRow(at: IndexPath(row: array.count-1, section: 0), at: .bottom, animated: false) }
        }
    }
    
    @objc func show(_ sender: Notification) {
        if ChatbotArray.count > 0 { tableView.scrollToRow(at: IndexPath(row: ChatbotArray.count-1, section: 0), at: .bottom, animated: false) }
    }
}

extension ReChatbotVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ChatbotArray.count > 0 { return ChatbotArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = ChatbotArray[indexPath.row]
        var datetime: String = ""
        
        let today: Int = Int(setTimestampToDateTime(dateformat: "yyyyMMdd")) ?? 0
        let date: Int = Int(setTimestampToDateTime(timestamp: Int(data.time) ?? 0, dateformat: "yyyyMMdd")) ?? 0
        
        if date == today {
            datetime = setTimestampToDateTime(timestamp: Int(data.time) ?? 0, dateformat: "a hh:mm")
        } else {
            datetime = setTimestampToDateTime(timestamp: Int(data.time) ?? 0, dateformat: "yy.MM.dd a hh:mm")
        }
        
        switch data.direction {
        case "touser":
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReChatbotTC1", for: indexPath) as! ReChatbotTC
            
            cell.comment_v.layer.cornerRadius = 15
            cell.comment_v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            cell.content_label.text = translation(data.content.replacingOccurrences(of: "\\n", with: "\n"))
            cell.datetimeReadorNot_label.text = datetime
            
            return cell
        case "tochatbot":
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReChatbotTC2", for: indexPath) as! ReChatbotTC
            
            cell.comment_v.layer.cornerRadius = 15
            cell.comment_v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
            cell.content_label.text = translation(data.content.replacingOccurrences(of: "\\n", with: "\n"))
            cell.datetimeReadorNot_label.text = datetime
            
            return cell
        default:
            return UITableViewCell()
        }
    }
}


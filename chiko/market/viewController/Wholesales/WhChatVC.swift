//
//  WhChatVC.swift
//  market
//
//  Created by Busan Dynamic on 5/27/24.
//

/// 번역

import UIKit

class WhChatTC: UITableViewCell {
    
    @IBOutlet weak var date_v: UIView!
    @IBOutlet weak var date_label: UILabel!
    @IBOutlet weak var date_top: NSLayoutConstraint!
    @IBOutlet weak var comment_v: UIView!
    @IBOutlet weak var content_tv: UITextView!
    @IBOutlet weak var datetimeReadorNot_label: UILabel!
}

class WhChatVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var ChatsArray: [ChatsData] = []
    
    @IBOutlet var labels: [UILabel]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true, completion: { WhChatVCdelegate = nil }) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var content_tv: UITextView!
    @IBOutlet weak var send_btn: UIButton!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in label.text = translation(label.text!) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WhChatVCdelegate = self
        
        setKeyboard()
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        
        content_tv.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        send_btn.addTarget(self, action: #selector(send_btn(_:)), for: .touchUpInside)
        
        loadingData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(show(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func send_btn(_ sender: UIButton) {
        if content_tv.text!.replacingOccurrences(of: " ", with: "") != "" {
            loadingData(action: "set", content: content_tv.text!); content_tv.text?.removeAll()
        }
    }
    
    func loadingData(action: String = "get", content: String = "") {
        
        requestChats(action: action, content: content) { array, status in
            
            if status == 200 {
                self.ChatsArray = array
            }; self.tableView.reloadData()
            
            if array.count > 0 { self.tableView.scrollToRow(at: IndexPath(row: array.count-1, section: 0), at: .bottom, animated: false) }
        }
    }
    
    @objc func show(_ sender: Notification) {
        if ChatsArray.count > 0 { tableView.scrollToRow(at: IndexPath(row: ChatsArray.count-1, section: 0), at: .bottom, animated: false) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
    }
}

extension WhChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ChatsArray.count > 0 { return ChatsArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = ChatsArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: data.direction == "touser" ? "WhChatTC1" : "WhChatTC2", for: indexPath) as! WhChatTC
        
        let datetime = setTimestampToDateTime(timestamp: Int(data.time) ?? 0, dateformat: "a hh:mm")
        let read_or_not = data.read_or_not ? translation("읽음") : ""
        
        if indexPath.row > 0 {
            let before = setTimestampToDateTime(timestamp: Int(ChatsArray[indexPath.row-1].time) ?? 0, dateformat: "yyyyMMdd")
            let now = setTimestampToDateTime(timestamp: Int(ChatsArray[indexPath.row].time) ?? 0, dateformat: "yyyyMMdd")
            cell.date_v.isHidden = (before == now)
        } else {
            cell.date_v.isHidden = false
        }
        cell.date_label.text = setTimestampToDateTime(timestamp: Int(data.time) ?? 0, dateformat: "yyyy년 MM월 dd일 E요일")
        cell.date_top.constant = cell.date_v.isHidden ? 10 : 50
        cell.comment_v.layer.cornerRadius = 15
        cell.comment_v.layer.maskedCorners = data.direction == "touser" ? [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner] : [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        cell.content_tv.isEditable = false
        cell.content_tv.dataDetectorTypes = .link
        cell.content_tv.text = data.content
        cell.datetimeReadorNot_label.text = data.read_or_not ? (data.direction == "touser" ? "\(datetime) ∙ \(read_or_not)" : "\(read_or_not) ∙ \(datetime)") : datetime
        
        return cell
    }
}

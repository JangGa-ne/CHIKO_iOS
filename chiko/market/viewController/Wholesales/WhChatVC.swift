//
//  WhChatVC.swift
//  market
//
//  Created by Busan Dynamic on 5/27/24.
//

/// 번역

import UIKit

class WhChatTC: UITableViewCell {
    
    @IBOutlet weak var comment_v: UIView!
    @IBOutlet weak var content_label: UILabel!
    @IBOutlet weak var datetimeReadorNot_label: UILabel!
}

class WhChatVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var ChatsArray: [ChatsData] = []
    
    @IBOutlet var labels: [UILabel]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
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
        var datetime: String = ""
        let read_or_not = data.read_or_not ? translation("읽음") : ""
        
        let today: Int = Int(setTimestampToDateTime(dateformat: "yyyyMMdd")) ?? 0
        let date: Int = Int(setTimestampToDateTime(timestamp: Int(data.time) ?? 0, dateformat: "yyyyMMdd")) ?? 0
        
        if date == today {
            datetime = setTimestampToDateTime(timestamp: Int(data.time) ?? 0, dateformat: "a hh:mm")
        } else {
            datetime = setTimestampToDateTime(timestamp: Int(data.time) ?? 0, dateformat: "yy.MM.dd a hh:mm")
        }
        
        switch data.direction {
        case "touser":
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhChatTC1", for: indexPath) as! WhChatTC
            
            cell.comment_v.layer.cornerRadius = 15
            cell.comment_v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            cell.content_label.text = translation(data.content.replacingOccurrences(of: "\\n", with: "\n"))
            cell.datetimeReadorNot_label.text = data.read_or_not ? "\(datetime) ∙ \(read_or_not)" : datetime
            
            return cell
        case "tomanager":
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhChatTC2", for: indexPath) as! WhChatTC
            
            cell.comment_v.layer.cornerRadius = 15
            cell.comment_v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
            cell.content_label.text = translation(data.content.replacingOccurrences(of: "\\n", with: "\n"))
            cell.datetimeReadorNot_label.text = data.read_or_not ? "\(read_or_not) ∙ \(datetime)" : datetime
            
            return cell
        default:
            return UITableViewCell()
        }
    }
}

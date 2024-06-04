//
//  SettingVC.swift
//  market
//
//  Created by 장 제현 on 3/29/24.
//

/// 번역완료

import UIKit
import FirebaseMessaging

class SettingTC: UITableViewCell {
    
    @IBOutlet var labels: [UILabel]!
    
    @IBOutlet weak var cell_v: UIView!
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var switch_btn: UISwitch!
    @IBOutlet weak var next_img: UIImageView!
    @IBOutlet weak var lineView: UIView!
}

class SettingVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var menus: [(title: String, content: [String])] = [
        (title: "Agreement", content: ["전자상거래 이용약관", "해외구매 이용약관", "개인정보처리방침", "개인 및 법인정보 제3자 제공동의서"]),
        (title: "Other", content: ["Face ID 인증 사용", "소프트웨어 업데이트"]),
    ]
    var segues: [(String, [String])] = [
        (title: "Agreement", content: ["https://sites.google.com/view/chiko-terms1", "https://sites.google.com/view/chiko-terms2", "https://sites.google.com/view/chiko-terms3", "https://sites.google.com/view/chiko-terms4"]),
        (title: "Other", content: ["", "VersionVC"]),
    ]
    var topics: [String] = []
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var withdrawal_btn: UIButton!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in label.text = translation(label.text!) }
        buttons.forEach { btn in btn.setTitle(translation(btn.title(for: .normal)), for: .normal) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if StoreObject.store_type == "retailseller" {
            menus.insert((title: "알림", content: ["마케팅 정보", "영수증 주문요청"]), at: 0)
            segues.insert((title: "알림", content: ["", ""]), at: 0)
            topics = [
                MemberObject.topics["marketing"] as? String ?? "false",
                MemberObject.topics["enquiry"] as? String ?? "false",
            ]
        } else if StoreObject.store_type == "wholesales" {
            menus.insert((title: "알림", content: ["마케팅정보", "채팅플러스+"]), at: 0)
            segues.insert((title: "알림", content: [""]), at: 0)
            topics = [
                MemberObject.topics["marketing"] as? String ?? "false",
                MemberObject.topics["chats"] as? String ?? "false",
            ]
        }
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 20, right: 0)
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = .zero }
        tableView.delegate = self; tableView.dataSource = self
        
        withdrawal_btn.addTarget(self, action: #selector(withdrawal_btn(_:)), for: .touchUpInside)
    }
    
    @objc func withdrawal_btn(_ sender: UIButton) {
        segueViewController(identifier: "WithdrawalVC")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
    }
}

extension SettingVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if menus[section].content.count > 0 { return menus[section].content.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTC", for: indexPath) as! SettingTC
        if indexPath.row == 0 {
            cell.cell_v.layer.cornerRadius = 10
            cell.cell_v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.lineView.isHidden = false
        } else if indexPath.row == menus[indexPath.section].content.count-1 {
            cell.cell_v.layer.cornerRadius = 10
            cell.cell_v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.lineView.isHidden = true
        } else {
            cell.cell_v.layer.cornerRadius = .zero
            cell.lineView.isHidden = false
        }
        
        cell.title_label.text = translation(menus[indexPath.section].content[indexPath.row])
        if indexPath.section == 0 {
            cell.switch_btn.isHidden = false
            cell.switch_btn.transform = CGAffineTransform(scaleX: 0.6455, y: 0.6455)
            cell.switch_btn.isOn = Bool(topics[indexPath.row]) ?? false
            cell.switch_btn.tag = indexPath.row; cell.switch_btn.addTarget(self, action: #selector(switch_btn(_:)), for: .valueChanged)
        } else {
            cell.switch_btn.isHidden = true
        }
        
        cell.next_img.isHidden = !(indexPath.section == 1)
        
        return cell
    }
    
    @objc func switch_btn(_ sender: UISwitch) {
        
        customLoadingIndicator(animated: true)
        
        var title: String = ""
        var topic: String = ""
        if sender.tag == 0 {
            title = "마케팅 정보"
            topic = "marketing"
        } else if sender.tag == 1, MemberObject.member_type == "retailseller" {
            title = "영수증 주문요청"
            topic = "enquiry"
        } else if sender.tag == 1, MemberObject.member_type == "wholesales" {
            title = "채팅플러스+"
            topic = "chats"
        }; MemberObject.topics[topic] = String(sender.isOn)
        
        guard topic != "" else { self.customLoadingIndicator(animated: false); return }
        
        let params: [String: Any] = [
            "action": "edit",
            "collection_id": "member",
            "document_id": MemberObject.member_id,
            "topics": MemberObject.topics,
        ]
        let topic_name = topic == "chats" ? "chats_\(MemberObject.member_id)" : "\(topic)_\(StoreObject.store_id)"
        
        if sender.isOn {
            Messaging.messaging().subscribe(toTopic: topic_name) { error in
                self.customLoadingIndicator(animated: false)
                if error == nil {
                    requestEditDB(params: params) { _ in
                        self.alert(title: translation(title), message: "\(setTimestampToDateTime())\n\(translation("알림 수신 동의 처리되었습니다."))", style: .alert, time: 1)
                    }; print("토픽구독성공: \(topic_name)")
                } else {
                    self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1) {
                        MemberObject.topics[topic] = "false"
                    }; print("토픽구독실패: \(topic_name)"); sender.isOn = false
                }
            }
        } else {
            Messaging.messaging().unsubscribe(fromTopic: topic_name) { error in
                self.customLoadingIndicator(animated: false)
                if error == nil {
                    requestEditDB(params: params) { _ in
                        self.alert(title: translation(title), message: "\(setTimestampToDateTime())\n\(translation("알림 수신 거부 처리되었습니다."))", style: .alert, time: 1)
                    }; print("토픽구독해제성공: \(topic_name)")
                } else {
                    self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1) {
                        MemberObject.topics[topic] = "false"
                    }; print("토픽구독해제실패: \(topic_name)"); sender.isOn = true
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let identifier = segues[indexPath.section].1[indexPath.row]
        guard identifier != "" else { return }
        
        if indexPath.section == 0 {
            
        } else if indexPath.section == 1 {
            let segue = storyboard?.instantiateViewController(withIdentifier: "SafariVC") as! SafariVC
            segue.linkUrl = identifier
            navigationController?.pushViewController(segue, animated: true, completion: nil)
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                
            } else if indexPath.row == 1 {
                segueViewController(identifier: identifier)
            }
        }
    }
}

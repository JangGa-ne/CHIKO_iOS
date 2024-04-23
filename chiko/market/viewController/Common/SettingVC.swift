//
//  SettingVC.swift
//  market
//
//  Created by Busan Dynamic on 3/29/24.
//

import UIKit
import FirebaseMessaging

class SettingTC: UITableViewCell {
    
    @IBOutlet weak var cell_v: UIView!
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var switch_btn: UISwitch!
    @IBOutlet weak var info_label: UILabel!
    @IBOutlet weak var next_img: UIImageView!
    @IBOutlet weak var lineView: UIView!
}

class SettingVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var menus: [(title: String, content: [String])] = [
        (title: "약관", content: ["이용약관", "개인정보 수집", "마케팅정보 수신"]),
        (title: "기타", content: ["Face ID 인증 사용", "앱 버전"]),
    ]
    var segues: [(String, [String])] = [
        (title: "약관", content: ["", "", ""]),
        (title: "기타", content: ["", ""]),
    ]
    var topics: [String] = []
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if StoreObject.store_type == "retailseller" {
            menus.insert((title: "알림", content: ["영수증 주문요청", "마케팅정보 수신"]), at: 0)
            segues.insert((title: "알림", content: ["", ""]), at: 0)
            topics = [
                UserDefaults.standard.string(forKey: "re_enquiry") ?? "",
                "",
            ]
        } else if StoreObject.store_type == "wholesales" {
            menus.insert((title: "알림", content: ["마케팅정보 수신"]), at: 0)
            segues.insert((title: "알림", content: [""]), at: 0)
            topics = [
                "",
            ]
        }
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 20, right: 0)
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = .zero }
        tableView.delegate = self; tableView.dataSource = self
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
        
        cell.title_label.text = menus[indexPath.section].content[indexPath.row]
        if indexPath.section == 0 {
            cell.switch_btn.isHidden = false
            cell.switch_btn.transform = CGAffineTransform(scaleX: 0.6455, y: 0.6455)
            cell.switch_btn.isOn = topics[indexPath.row] != ""
            cell.switch_btn.tag = indexPath.row; cell.switch_btn.addTarget(self, action: #selector(switch_btn(_:)), for: .valueChanged)
        } else {
            cell.switch_btn.isHidden = true
        }
        
        cell.info_label.isHidden = !(indexPath.section == 2 && indexPath.row == 1)
        cell.next_img.isHidden = !(indexPath.section == 1)
        
        return cell
    }
    
    @objc func switch_btn(_ sender: UISwitch) {
        
        customLoadingIndicator(animated: true)
        
        var topic: String = ""
        var topic_key: String = ""
        if StoreObject.store_type == "retailseller" {
            topic_key = "re_"
        } else if StoreObject.store_type == "wholesales" {
            topic_key = "wh_"
        }
        
        if sender.tag == 0 {
            topic = "enquiry_\(StoreObject.store_id)"
            topic_key += "enquiry"
        } else if sender.tag == 1 {
            
        }
        
        guard topic != "" else { self.customLoadingIndicator(animated: false); return }
        
        if sender.isOn {
            Messaging.messaging().subscribe(toTopic: topic) { error in
                self.customLoadingIndicator(animated: false)
                if error == nil {
                    self.alert(title: "영수증 주문요청", message: "\(setTimestampToDateTime())\n알림 수신 동의 처리가 되었습니다.", style: .alert, time: 1)
                    UserDefaults.standard.setValue(topic, forKey: topic_key)
                } else {
                    self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
                    sender.isOn = false
                }
            }
        } else {
            Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                self.customLoadingIndicator(animated: false)
                if error == nil {
                    self.alert(title: "영수증 주문요청", message: "\(setTimestampToDateTime())\n알림 수신 거부 처리가 되었습니다.", style: .alert, time: 1)
                    UserDefaults.standard.removeObject(forKey: topic_key)
                } else {
                    self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
                    sender.isOn = true
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
        } else if indexPath.section == 1 {
            
        } else if indexPath.section == 2 {
            
        }
    }
}

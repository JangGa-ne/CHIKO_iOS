//
//  WaitingVC.swift
//  market
//
//  Created by 장 제현 on 11/29/23.
//

import UIKit

class WaitingVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var back_view: UIView!
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true, completion: { WaitingVCdelegate = nil }) }
    @IBOutlet weak var navi_label: UILabel!
    @IBOutlet weak var navi_lineView: UIView!
    @IBOutlet weak var logout_btn: UIButton!
    
    @IBOutlet weak var waitingTitle_label: UILabel!
    @IBOutlet weak var waitingContent_label: UILabel!
    @IBOutlet weak var submit_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WaitingVCdelegate = self
        // init
        /// navi 
        back_view.isHidden = back_btn_hidden
        navi_label.alpha = 0.0
        navi_lineView.alpha = 0.0
        logout_btn.isHidden = !back_btn_hidden
        logout_btn.addTarget(self, action: #selector(logout_btn(_:)), for: .touchUpInside)
        
        if MemberObject.member_grade == "ceo" {
            if StoreObject.waiting_step == 0 {
                navi_label.text = "입점대기 중"
                waitingTitle_label.text = "입점대기 중"
                waitingContent_label.text = "꼼꼼히 심사하고 있어요.\n조금만 기다려주세요."
            } else if StoreObject.waiting_step == 1 {
                navi_label.text = "입점승인 됨"
                waitingTitle_label.text = "입점승인 됨"
                waitingContent_label.text = "심사가 완료되었습니다.\n환영합니다!"
            }
            submit_btn.isHidden = (StoreObject.waiting_step == 0)
        } else if MemberObject.member_grade == "employee" {
            if MemberObject.waiting_step == 0 {
                navi_label.text = "승인대기 중"
                waitingTitle_label.text = "승인대기 중"
                waitingContent_label.text = "꼼꼼히 심사하고 있어요.\n조금만 기다려주세요."
            } else if MemberObject.waiting_step == 1 {
                navi_label.text = "직원승인 됨"
                waitingTitle_label.text = "직원승인 됨"
                waitingContent_label.text = "심사가 완료되었습니다.\n환영합니다!"
            }
            submit_btn.isHidden = (MemberObject.waiting_step == 0)
        }
        
        submit_btn.addTarget(self, action: #selector(submit_btn(_:)), for: .touchUpInside)
    }
    
    @objc func logout_btn(_ sender: UIButton) {
        segueViewController(identifier: "SignInVC") { _ in WaitingVCdelegate = nil }
    }
    
    @objc func submit_btn(_ sender: UIButton) {
        
        customLoadingIndicator(animated: true)
        
        let params: [String: Any] = [
            "action": "edit",
            "collection_id": "member",
            "document_id": MemberObject.member_id,
            "waiting_step": "2",
        ]
        
        requestEditDB(params: params) { status in
            
            self.customLoadingIndicator(animated: false)
            
            if status == 200 {
                if MemberObject.member_type == "retailseller" {
                    self.segueTabBarController(identifier: "ReMainTBC", idx: 0) { _ in WaitingVCdelegate = nil }
                } else if MemberObject.member_type == "wholesales" {
                    self.segueViewController(identifier: "WhHomeVC") { _ in WaitingVCdelegate = nil }
                }
            } else {
                self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
            }
        }
    }
}

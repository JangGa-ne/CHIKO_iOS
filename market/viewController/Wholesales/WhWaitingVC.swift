//
//  WhWaitingVC.swift
//  market
//
//  Created by Busan Dynamic on 11/29/23.
//

import UIKit

class WhWaitingVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBOutlet weak var back_view: UIView!
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    @IBOutlet weak var navi_label: UILabel!
    @IBOutlet weak var navi_lineView: UIView!
    @IBOutlet weak var logout_btn: UIButton!
    
    @IBOutlet weak var waitingTitle_label: UILabel!
    @IBOutlet weak var waitingContent_label: UILabel!
    @IBOutlet weak var submit_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init
        /// navi 
        back_view.isHidden = back_btn_hidden
        navi_label.alpha = 0.0
        navi_lineView.alpha = 0.0
        logout_btn.isHidden = !back_btn_hidden
        logout_btn.addTarget(self, action: #selector(logout_btn(_:)), for: .touchUpInside)
        
        let data = StoreArray[store_index]
        
        if data.waiting_step == 0 {
            navi_label.text = "입점대기 중"
            waitingTitle_label.text = "입점대기 중"
            waitingContent_label.text = "꼼꼼히 심사하고 있어요.\n조금만 기다려주세요."
        } else if data.waiting_step == 1 {
            navi_label.text = "입점승인 됨"
            waitingTitle_label.text = "입점승인 됨"
            waitingContent_label.text = "심사가 완료되었습니다.\n환영합니다!"
        }
        
        submit_btn.isHidden = (data.waiting_step == 0)
        submit_btn.addTarget(self, action: #selector(submit_btn(_:)), for: .touchUpInside)
    }
    
    @objc func logout_btn(_ sender: UIButton) {
        segueViewController(identifier: "SignInVC")
    }
    
    @objc func submit_btn(_ sender: UIButton) {
        segueViewController(identifier: "WhHomeVC")
    }
}

//
//  WithdrawalVC.swift
//  market
//
//  Created by 장 제현 on 5/7/24.
//

import UIKit

class WithdrawalVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var withdrawal_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        withdrawal_btn.addTarget(self, action: #selector(withdrawal_btn(_:)), for: .touchUpInside)
    }
    
    @objc func withdrawal_btn(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "회원탈퇴", message: "정말로 탈퇴하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "탈퇴하기", style: .destructive, handler: { _ in
            self.alert(title: "", message: "회원탈퇴 처리되었습니다.", style: .alert, time: 1) {
                self.segueViewController(identifier: "SignInVC")
            }
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

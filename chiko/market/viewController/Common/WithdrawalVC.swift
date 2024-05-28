//
//  WithdrawalVC.swift
//  market
//
//  Created by 장 제현 on 5/7/24.
//

/// 번역완료

import UIKit

class WithdrawalVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var withdrawal_btn: UIButton!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in
            if label.text!.contains("회원탈퇴 시 모든 정보는 즉시") {
                label.text = translation("회원탈퇴 시 모든 정보는 즉시 파기 되며, 복구 할 수 없습니다.\n대표계정 인 경우 직원관리에서 모든 직원을 삭제 후 탈퇴 할 수 있습니다.\n\n이를 인지하였으며 계정 삭제에 동의합니다.")
            } else {
                label.text = translation(label.text!)
            }
        }
        buttons.forEach { btn in btn.setTitle(translation(btn.title(for: .normal)), for: .normal) }
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        withdrawal_btn.addTarget(self, action: #selector(withdrawal_btn(_:)), for: .touchUpInside)
    }
    
    @objc func withdrawal_btn(_ sender: UIButton) {
        
        let alert = UIAlertController(title: translation("회원탈퇴"), message: translation("정말 탈퇴하시겠습니까?"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: translation("탈퇴하기"), style: .destructive, handler: { _ in
            self.alert(title: "", message: "회원탈퇴 처리되었습니다.", style: .alert, time: 1) {
                self.segueViewController(identifier: "SignInVC")
            }
        }))
        alert.addAction(UIAlertAction(title: translation("취소"), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

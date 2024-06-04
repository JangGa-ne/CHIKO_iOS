//
//  CertificationVC.swift
//  market
//
//  Created by 장 제현 on 5/21/24.
//

/// 번역

import UIKit

class CertificationVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var member_id: String = ""
    var member_num: String = ""
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var certification_tf: UITextField!
    @IBOutlet weak var certification_btn: UIButton!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in
            if label.text!.contains("SMS으로") {
                label.text = translation("SMS으로 인증번호를 발송 하였습니다.\n인증번호를 입력해주세요.")
            } else {
                label.text = translation(label.text!)
            }
        }
        buttons.forEach { btn in btn.setTitle(translation(btn.title(for: .normal)), for: .normal) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setKeyboard()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.certification_tf.becomeFirstResponder()
        }
        
        certification_tf.placeholder(text: "인증번호 입력")
        certification_tf.addTarget(self, action: #selector(edit_certification_tf(_:)), for: .editingChanged)
        
        certification_btn.addTarget(self, action: #selector(certification_btn(_:)), for: .touchUpInside)
    }
    
    @objc func edit_certification_tf(_ sender: UITextField) {
        if sender.text!.count == 6 {
            certification_btn(UIButton())
        }
    }
    
    @objc func certification_btn(_ sender: UIButton) {
        
        if certification_tf.text!.count != 6 {
            customAlert(message: "인증번호를 확인해주세요.", time: 1) {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.certification_tf.becomeFirstResponder()
                }
            }
        } else {
            
            customLoadingIndicator(animated: true)
            
            requestPhoneNumCheck(verificationId: UserDefaults.standard.string(forKey: "verification_id") ?? "", phoneNum: member_num, phoneNumCheck: certification_tf.text!) { status in
                
                self.customLoadingIndicator(animated: false)
                
                if status == 200 {
                    let segue = self.storyboard?.instantiateViewController(withIdentifier: "ChangeVC") as! ChangeVC
                    segue.member_id = self.member_id
                    self.navigationController?.pushViewController(segue, animated: true, completion: nil)
                } else {
    //                self.customAlert(message: "인증번호가 맞지 않거나,\n입력시간 초과입니다.", time: 1) {
    //                    self.navigationController?.popViewController(animated: true)
    //                }
                    self.customAlert(message: "인증번호가 맞지 않습니다.", time: 1)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

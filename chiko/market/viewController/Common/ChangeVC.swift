//
//  ChangeVC.swift
//  market
//
//  Created by 장 제현 on 5/22/24.
//

import UIKit

class ChangeVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var password_check: [Bool] = [false, false]
    var member_id: String = ""
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var password_tf: UITextField!
    @IBOutlet weak var noticePassword_label: UILabel!
    @IBOutlet weak var passwordCheck_tf: UITextField!
    @IBOutlet weak var noticePasswordCheck_label: UILabel!
    
    @IBOutlet weak var changePassword_btn: UIButton!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in
            if label.text!.contains("가입한 이름과") {
                label.text = translation("가입한 이름과 휴대전화를 입력하세요.\nSMS으로 인증번호를 발송 합니다.")
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
            self.password_tf.becomeFirstResponder()
        }
        
        ([password_tf, passwordCheck_tf] as [UITextField]).enumerated().forEach { i, tf in
            tf.placeholder(text: ["영어+숫자+특수문자 조합 8~15자리", ""][i])
            if i < 1 {
                tf.returnKeyType = .next
            } else {
                tf.returnKeyType = .done
            }
            tf.delegate = self
            tf.tag = i
            tf.addTarget(self, action: #selector(changedEditPassword_tf(_:)), for: .editingChanged)
            tf.addTarget(self, action: #selector(endEditPassword_tf(_:)), for: .editingDidEnd)
        }
        ([noticePassword_label, noticePasswordCheck_label] as [UILabel]).forEach { label in
            label.isHidden = true
        }
        
        changePassword_btn.addTarget(self, action: #selector(changePassword_btn(_:)), for: .touchUpInside)
    }
    
    @objc func changedEditPassword_tf(_ sender: UITextField) {
        
        let notice: UILabel = [noticePassword_label, noticePasswordCheck_label][sender.tag]
        
        password_check[sender.tag] = false
        notice.isHidden = true
        
        switch sender {
        case password_tf:
            
            passwordCheck_tf.text?.removeAll()
            noticePassword_label.isHidden = true
            noticePasswordCheck_label.isHidden = true
            
            let filterContains = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~`!@#$%^&*()-+="
            
            if sender.text!.count < 8 || sender.text!.count > 15 {
                noticePassword_label.text = translation("8~15자까지 입력 가능합니다.")
            } else if sender.text!.rangeOfCharacter(from: CharacterSet(charactersIn: filterContains).inverted) != nil {
                noticePassword_label.text = translation("영어, 숫자, 특수문자 - ' ! @ # $ % ^ & * ( ) - + = 조합")
            } else if !isPasswordValid(sender.text!) {
                noticePassword_label.text = translation("영어, 숫자, 특수문자가 최소 1자 이상 포함되어야 합니다.")
            } else {
                password_check[sender.tag] = true
            }
        case passwordCheck_tf:
            if !noticePassword_label.isHidden {
                noticePasswordCheck_label.text = translation("비밀번호 형식이 맞지 않습니다.")
            } else if sender.text! != password_tf.text! {
                noticePasswordCheck_label.text = translation("비밀번호가 맞지 않습니다.")
            } else {
                password_check[sender.tag] = true
            }
        default:
            break
        }
    }
    
    @objc func endEditPassword_tf(_ sender: UITextField) {
        
        let notice: UILabel = [noticePassword_label, noticePasswordCheck_label][sender.tag]
        notice.isHidden = password_check[sender.tag]
    }
    
    @objc func changePassword_btn(_ sender: UIButton) {
        
        if password_tf.text! != "", noticePassword_label.isHidden, passwordCheck_tf.text! != "", noticePasswordCheck_label.isHidden {
            
            customLoadingIndicator(animated: true)
            
            let params: [String: Any] = [
                "action": "edit",
                "collection_id": "member",
                "document_id": member_id,
                "user_pw": passwordCheck_tf.text!,
            ]
            
            requestEditDB(params: params) { status in
                
                self.customLoadingIndicator(animated: false)
                
                if status == 200 {
                    self.alert(title: "", message: "비밀번호 변경 되었습니다.", style: .alert, time: 1) {
                        self.segueViewController(identifier: "SignInVC")
                    }
                } else {
                    self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
                }
            }
        } else {
            customAlert(message: "미입력된 항목이 있거나\n확인되지 않은 항목이 있습니다.", time: 1)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

extension ChangeVC {
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == password_tf {
            passwordCheck_tf.becomeFirstResponder()
        } else if textField == passwordCheck_tf {
            passwordCheck_tf.resignFirstResponder(); changePassword_btn(UIButton())
        }
        return true
    }
}

//
//  MemberVC.swift
//  market
//
//  Created by Busan Dynamic on 12/12/23.
//

import UIKit

class MemberVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var phoneNum_tf: UITextField!
    @IBOutlet weak var phoneNum_btn: UIButton!
    @IBOutlet weak var noticePhoneNum_label: UILabel!
    @IBOutlet weak var phoneNumCheck_view: UIView!
    @IBOutlet weak var phoneNumCheck_tf: UITextField!
    @IBOutlet weak var checkPhoneNumCheck_img: UIImageView!
    @IBOutlet weak var noticePhoneNumCheck_label: UILabel!
    
    @IBOutlet weak var memberName_tf: UITextField!
    @IBOutlet weak var checkMemberName_img: UIImageView!
    @IBOutlet weak var memberEmail_tf: UITextField!
    @IBOutlet weak var checkMemberEmail_img: UIImageView!
    @IBOutlet weak var noticeMemberEmail_label: UILabel!
    
    @IBOutlet weak var submitDocu_sv: UIStackView!
    @IBOutlet weak var memberIdCard_view: UIView!
    @IBOutlet weak var memberIdCard_img: UIImageView!
    @IBOutlet weak var memberIdCard_label: UILabel!
    @IBOutlet weak var checkMemberIdCard_img: UIImageView!
    
    @IBOutlet weak var edit_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let data = MemberObject
        
        ([phoneNum_tf, phoneNumCheck_tf, memberName_tf, memberEmail_tf] as [UITextField]).enumerated().forEach { i, tf in
            tf.placeholder(text: ["-없이 입력", "", "영어 소문자 또는 숫자 4~20자리", "영어+숫자+특수문자 조합 8~15자리", "", "", "@이하 주소까지 모두 입력"][i], color: .black.withAlphaComponent(0.3))
            tf.text = ["", "", data.member_id, "", "", data.member_name, data.member_email][i]
            tf.delegate = self
            tf.tag = i
            tf.addTarget(self, action: #selector(changedEditMemberInfo_if(_:)), for: .editingChanged)
            tf.addTarget(self, action: #selector(endEditMemberInfo_if(_:)), for: .editingDidEnd)
            if tf != memberEmail_tf { tf.returnKeyType = .next } else { tf.returnKeyType = .done }
        }
        /// notice
        ([noticePhoneNum_label, noticePhoneNumCheck_label, noticeMemberEmail_label] as [UILabel]).enumerated().forEach { i, label in
            label.isHidden = true
        }
        /// check
        ([checkPhoneNumCheck_img, checkMemberName_img, checkMemberEmail_img, checkMemberIdCard_img] as [UIImageView]).enumerated().forEach { i, img in
            img.isHidden = true
        }
        
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scrollView(_:))))
        
        submitDocu_sv.isHidden = !(data.member_type == "retailseller")
        
        edit_btn.addTarget(self, action: #selector(edit_btn(_:)), for: .touchUpInside)
    }
    
    @objc func changedEditMemberInfo_if(_ sender: UITextField) {
        
        let check: UIImageView = [UIImageView(), checkPhoneNumCheck_img, checkMemberName_img, checkMemberEmail_img][sender.tag]
        let notice: UILabel = [noticePhoneNum_label, noticePhoneNumCheck_label, UILabel(), noticeMemberEmail_label][sender.tag]
        // init
        check.isHidden = true
        notice.isHidden = true
        
        switch sender {
        case phoneNum_tf:
            
            phoneNum_btn.isSelected = false
            phoneNum_btn.backgroundColor = .black.withAlphaComponent(0.3)
            phoneNumCheck_view.isHidden = true
            phoneNumCheck_tf.text?.removeAll()
            noticePhoneNumCheck_label.isHidden = true
            checkPhoneNumCheck_img.isHidden = true
            
            if MemberObject_signup.member_type == "retailseller" {
                
            } else if MemberObject_signup.member_type == "wholesales" {
                
            }
            if isChinesePhoneNumValid(sender.text!) || sender.text! == "01031870005" { check.isHidden = false }
        case phoneNumCheck_tf:
            
            sender.text! = String(sender.text!.prefix(6))
            noticePhoneNumCheck_label.isHidden = true
            checkPhoneNumCheck_img.isHidden = true
            
            if sender.text!.count == 6 {
                customLoadingIndicator(animated: true)
                /// Phone Number Check 요청
                requestPhoneNumCheck(verificationId: UserDefaults.standard.string(forKey: "verification_id") ?? "", phoneNum: phoneNum_tf.text!, phoneNumCheck: sender.text!) { status in
                    self.customLoadingIndicator(animated: false)
                    if status == 200 {
                        notice.isHidden = true
                        check.isHidden = false
                    } else {
                        notice.isHidden = false
                        check.isHidden = true
                    }
                }
            }
        case memberName_tf:
            if sender.text!.count > 0 { check.isHidden = false }
        case memberEmail_tf:
            if isEmailValid(sender.text!) { check.isHidden = false }
        default:
            break
        }
    }
    
    @objc func endEditMemberInfo_if(_ sender: UITextField) {
        
        if sender == phoneNumCheck_tf { return }
        
        let check: UIImageView = [UIImageView(), checkPhoneNumCheck_img, checkMemberName_img, checkMemberEmail_img][sender.tag]
        let notice: UILabel = [noticePhoneNum_label, noticePhoneNumCheck_label, UILabel(), noticeMemberEmail_label][sender.tag]
        
        notice.isHidden = !check.isHidden
    }
    
    @objc func edit_btn(_ sender: UIButton) {
        
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

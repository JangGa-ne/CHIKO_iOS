//
//  SignUpMemberVC.swift
//  market
//
//  Created by Busan Dynamic on 2023/10/18.
//

import UIKit
import PanModal

class SignUpMemberVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBAction func back_btn(_ sender: UIButton) { view.endEditing(true); navigationController?.popViewController(animated: true) }
    @IBOutlet weak var navi_label: UILabel!
    @IBOutlet weak var navi_lineView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    /// member type
    @IBOutlet weak var ceo_btn: UIButton!
    @IBOutlet weak var employee_btn: UIButton!
    
    @IBOutlet weak var phoneNum_tf: UITextField!
    @IBOutlet weak var phoneNum_btn: UIButton!
    @IBOutlet weak var noticePhoneNum_label: UILabel!
    @IBOutlet weak var phoneNumCheck_view: UIView!
    @IBOutlet weak var phoneNumCheck_tf: UITextField!
    @IBOutlet weak var checkPhoneNumCheck_img: UIImageView!
    @IBOutlet weak var noticePhoneNumCheck_label: UILabel!
    
    @IBOutlet weak var memberId_tf: UITextField!
    @IBOutlet weak var memberId_btn: UIButton!
    @IBOutlet weak var noticeMemberId_label: UILabel!
    @IBOutlet weak var memberPw_tf: UITextField!
    @IBOutlet weak var checkMemberPw_Img: UIImageView!
    @IBOutlet weak var noticeMemberPw_label: UILabel!
    @IBOutlet weak var memberPwCheck_tf: UITextField!
    @IBOutlet weak var checkMemberPwCheck_Img: UIImageView!
    @IBOutlet weak var noticeMemberPwCheck_label: UILabel!
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
    
    @IBOutlet weak var registerSearchStoreTitle_label: UILabel!
    @IBOutlet weak var new_label: UILabel!
    @IBOutlet weak var registerSearchStoreName_label: UILabel!
    @IBOutlet weak var registerSearchStore_btn: UIButton!
    
    @IBOutlet weak var signUp_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SignUpMemberVCdelegate = self
        
        setKeyboard()
        // init
        /// navi
        navi_label.alpha = 0.0
        navi_lineView.alpha = 0.0
        
        scrollView.delegate = self
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scrollView(_:))))
        /// placeholder, delegate, edit, return next/done
        ([phoneNum_tf, phoneNumCheck_tf, memberId_tf, memberPw_tf, memberPwCheck_tf, memberName_tf, memberEmail_tf] as [UITextField]).enumerated().forEach { i, tf in
            tf.placeholder(text: ["-없이 입력", "", "영어 소문자 또는 숫자 4~20자리", "영어+숫자+특수문자 조합 8~15자리", "", "", "@이하 주소까지 모두 입력"][i], color: .black.withAlphaComponent(0.3))
            tf.delegate = self
            tf.tag = i
            tf.addTarget(self, action: #selector(changedEditMemberInfo_if(_:)), for: .editingChanged)
            tf.addTarget(self, action: #selector(endEditMemberInfo_if(_:)), for: .editingDidEnd)
            if tf != memberId_tf && tf != memberEmail_tf { tf.returnKeyType = .next } else { tf.returnKeyType = .done }
        }
        /// notice
        ([noticePhoneNum_label, noticePhoneNumCheck_label, noticeMemberId_label, noticeMemberPw_label, noticeMemberPwCheck_label, noticeMemberEmail_label] as [UILabel]).forEach { label in
            label.isHidden = true
        }
        /// check
        ([checkPhoneNumCheck_img, checkMemberPw_Img, checkMemberPwCheck_Img, checkMemberName_img, checkMemberEmail_img, checkMemberIdCard_img] as [UIImageView]).forEach { img in
            img.isHidden = true
        }
        
        scrollView.delegate = self
        /// member type
        MemberObject_signup.member_grade = "ceo"
        for (i, btn) in ([ceo_btn, employee_btn] as [UIButton]).enumerated() {
            btn.tag = i; btn.addTarget(self, action: #selector(memberType_btn(_:)), for: .touchUpInside)
            if btn.tag == 0 { btn.isSelected = true } else { btn.isSelected = false }
        }
        /// phone number send
        phoneNum_btn.addTarget(self, action: #selector(phoneNum_btn(_:)), for: .touchUpInside)
        phoneNumCheck_view.isHidden = true
        /// member id check
        memberId_btn.addTarget(self, action: #selector(memberId_btn(_:)), for: .touchUpInside)
        /// member id card
        memberIdCard_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(memberIdCard_view(_:))))
        /// submit document
        if MemberObject_signup.member_type == "retailseller" {
            submitDocu_sv.isHidden = false
        } else if MemberObject_signup.member_type == "wholesales" {
            submitDocu_sv.isHidden = true
        }
        /// register or search store
        new_label.isHidden = true
        registerSearchStoreName_label.text?.removeAll()
        registerSearchStore_btn.addTarget(self, action: #selector(registerSearchStore_btn(_:)), for: .touchUpInside)
        /// next agreement/signup
        signUp_btn.addTarget(self, action: #selector(signUp_btn(_:)), for: .touchUpInside)
    }
    
    @objc func changedEditMemberInfo_if(_ sender: UITextField) {
        
        var filterContains: String = ""
        
        let check: UIImageView = [UIImageView(), checkPhoneNumCheck_img, UIImageView(), checkMemberPw_Img, checkMemberPwCheck_Img, checkMemberName_img, checkMemberEmail_img][sender.tag]
        let notice: UILabel = [noticePhoneNum_label, noticePhoneNumCheck_label, noticeMemberId_label, noticeMemberPw_label, noticeMemberPwCheck_label, UILabel(), noticeMemberEmail_label][sender.tag]
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
            
            if isChinesePhoneNumValid(sender.text!) || sender.text! == "01031870005" { check.isHidden = false }; break
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
                        self.memberId_tf.becomeFirstResponder()
                    } else {
                        notice.isHidden = false
                        check.isHidden = true
                    }
                }
            }
        case memberId_tf:
            
            memberId_btn.isSelected = false
            memberId_btn.backgroundColor = .black.withAlphaComponent(0.3)
            noticeMemberId_label.isHidden = true
            noticeMemberId_label.textColor = .systemRed
            
            filterContains = "abcdefghijklmnopqrstuvwxyz0123456789"
            
            if sender.text!.count < 4 || sender.text!.count > 20 {
                notice.text = "4~20자까지 입력 가능합니다."
            } else if sender.text!.rangeOfCharacter(from: CharacterSet(charactersIn: filterContains).inverted) != nil {
                notice.text = "영어 소문자 또는 숫자 조합"
            } else {
                check.isHidden = false
            }
            memberId_btn.isSelected = false
            memberId_btn.backgroundColor = .black.withAlphaComponent(0.3)
            break
        case memberPw_tf:
            
            memberPwCheck_tf.text?.removeAll()
            noticeMemberPwCheck_label.isHidden = true
            checkMemberPwCheck_Img.isHidden = true
            
            filterContains = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~`!@#$%^&*()-+="
            
            if sender.text!.count < 8 || sender.text!.count > 15 {
                notice.text = "8~15자까지 입력 가능합니다."
            } else if sender.text!.rangeOfCharacter(from: CharacterSet(charactersIn: filterContains).inverted) != nil {
                notice.text = "영어, 숫자, 특수문자 - ' ! @ # $ % ^ & * ( ) - + = 조합"
            } else if !isPasswordValid(sender.text!) {
                notice.text = "영어, 숫자, 특수문자가 최소 1자 이상 포함되어야 합니다."
            } else {
                check.isHidden = false
            }
            break
        case memberPwCheck_tf:
            if !noticeMemberPw_label.isHidden {
                notice.text = "비밀번호 형식이 맞지 않습니다."
            } else if sender.text! != memberPw_tf.text! {
                notice.text = "비밀번호가 맞지 않습니다."
            } else if sender.text!.count > 0 {
                check.isHidden = false
            }
            break
        case memberName_tf:
            if sender.text!.count > 0 { check.isHidden = false }; break
        case memberEmail_tf:
            if isEmailValid(sender.text!) { check.isHidden = false }; break
        default:
            break
        }
    }
    
    @objc func endEditMemberInfo_if(_ sender: UITextField) {
        
        if sender == phoneNumCheck_tf { return }
        
        let check: UIImageView = [UIImageView(), checkPhoneNumCheck_img, UIImageView(), checkMemberPw_Img, checkMemberPwCheck_Img, checkMemberName_img, checkMemberEmail_img][sender.tag]
        let notice: UILabel = [noticePhoneNum_label, noticePhoneNumCheck_label, noticeMemberId_label, noticeMemberPw_label, noticeMemberPwCheck_label, UILabel(), noticeMemberEmail_label][sender.tag]
        
        notice.isHidden = !check.isHidden
    }
    
    @objc func memberType_btn(_ sender: UIButton) {
        /// hidden keyboard
        view.endEditing(true)
        
        if sender.tag == 0 {
            /// ceo
            MemberObject_signup.member_grade = "ceo"
            ceo_btn.isSelected = true; employee_btn.isSelected = false
            ceo_btn.backgroundColor = .H_8CD26B; employee_btn.backgroundColor = .white
            /// set register store
            registerSearchStoreTitle_label.text = "매장 등록"
            new_label.isHidden = true
            registerSearchStoreName_label.text?.removeAll()
            registerSearchStore_btn.isSelected = false
            registerSearchStore_btn.setTitle("매장등록", for: .normal)
            registerSearchStore_btn.backgroundColor = .black.withAlphaComponent(0.3)
        } else if sender.tag == 1 {
            /// employee
            MemberObject_signup.member_grade = "employee"
            ceo_btn.isSelected = false; employee_btn.isSelected = true
            ceo_btn.backgroundColor = .white; employee_btn.backgroundColor = .H_8CD26B
            /// set searh store
            registerSearchStoreTitle_label.text = "매장 찾기"
            new_label.isHidden = true
            registerSearchStoreName_label.text?.removeAll()
            registerSearchStore_btn.isSelected = false
            registerSearchStore_btn.setTitle("매장찾기", for: .normal)
            registerSearchStore_btn.backgroundColor = .black.withAlphaComponent(0.3)
        }
    }
    
    @objc func phoneNum_btn(_ sender: UIButton) {
        /// hidden keyboard
        view.endEditing(true)
        
        phoneNumCheck_tf.text?.removeAll()
        checkPhoneNumCheck_img.isHidden = true
        
        if phoneNum_tf.text!.count > 0, noticePhoneNum_label.isHidden {
            customLoadingIndicator(animated: true)
            /// Phone Number Send 요청
            requestPhoneNum(phoneNum: "+86"+phoneNum_tf.text!) { status in
                self.customLoadingIndicator(animated: false)
                if status == 200 {
                    self.customAlert(message: "인증번호를 요청하였습니다.", time: 1)
                    sender.isSelected = true
                    sender.backgroundColor = .H_8CD26B
                    self.phoneNumCheck_view.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now()+1) { self.phoneNumCheck_tf.becomeFirstResponder() }
                } else {
                    self.customAlert(message: "Internal server error", time: 1)
                    sender.isSelected = false
                    sender.backgroundColor = .systemOrange
                    self.phoneNumCheck_view.isHidden = true
                }
            }
        }
    }
    
    @objc func memberId_btn(_ sender: UIButton) {
        /// hidden keyboard
        view.endEditing(true)
        
        if memberId_tf.text!.count > 0, noticeMemberId_label.isHidden {
            customLoadingIndicator(animated: true)
            /// Member ID Check 요청
            requestCheckId(member_id: memberId_tf.text!) { status in
                self.customLoadingIndicator(animated: false)
                if status == 200 {
                    sender.isSelected = true
                    sender.backgroundColor = .H_8CD26B
                    self.noticeMemberId_label.isHidden = false
                    self.noticeMemberId_label.text = "사용 가능한 아이디 입니다."
                    self.noticeMemberId_label.textColor = .systemGreen
                    self.memberPw_tf.becomeFirstResponder()
                } else if status == 204 {
                    sender.isSelected = false
                    sender.backgroundColor = .black.withAlphaComponent(0.3)
                    self.noticeMemberId_label.isHidden = false
                    self.noticeMemberId_label.text = "이미 사용중인 아이디 입니다."
                    self.noticeMemberId_label.textColor = .systemRed
                } else {
                    sender.isSelected = false
                    sender.backgroundColor = .systemOrange
                    self.noticeMemberId_label.isHidden = true
                    self.noticeMemberId_label.textColor = .systemRed
                    self.customAlert(message: "Internal server error", time: 1)
                }
            }
        }
    }
    
    @objc func registerSearchStore_btn(_ sender: UIButton) {
        if MemberObject_signup.member_grade == "ceo" {
            segueViewController(identifier: "SignUpStoreVC")
        } else if MemberObject_signup.member_grade == "employee" {
            let segue = storyboard?.instantiateViewController(withIdentifier: "SearchStoreVC") as! SearchStoreVC
            segue.SignUpMemberVCdelegate = self
            segue.search_store_type = MemberObject_signup.member_type
            navigationController?.pushViewController(segue, animated: true)
        }
    }
    
    @objc func memberIdCard_view(_ sender: UITapGestureRecognizer) {
        /// hidden keyboard
        view.endEditing(true)
        
        setPhoto(max: 1) { photo in
            MemberObject_signup.upload_member_idcard_img = photo
            self.memberIdCard_img.image = UIImage(data: photo[0].file_data)
            self.checkMemberIdCard_img.isHidden = false
        }
    }
    
    @objc func signUp_btn(_ senser: UIButton) {
        
        var final_check: Bool = true
        let check_btn: [UIButton] = [phoneNum_btn, memberId_btn, registerSearchStore_btn]
        var check_img: [UIImageView] = [checkPhoneNumCheck_img, checkMemberPw_Img, checkMemberPwCheck_Img, checkMemberName_img, checkMemberEmail_img]
        
        if MemberObject_signup.member_type == "retailseller" {
            check_img = check_img+[checkMemberIdCard_img]
        }
        check_btn.forEach { btn in
            if !btn.isSelected { customAlert(message: "미입력된 항목이 있거나\n확인되지 않은 항목이 있습니다.", time: 1); final_check = false }
        }
        check_img.forEach { img in
            if img.isHidden { customAlert(message: "미입력된 항목이 있거나\n확인되지 않은 항목이 있습니다.", time: 1); final_check = false }
        }
        
        if !final_check { return }
        /// member
        MemberObject_signup.fcm_id = UserDefaults.standard.string(forKey: "fcm_id") ?? ""
        MemberObject_signup.member_num = phoneNum_tf.text!
        MemberObject_signup.member_id = memberId_tf.text!
        MemberObject_signup.member_pw = memberPwCheck_tf.text!
        MemberObject_signup.member_name = memberName_tf.text!
        MemberObject_signup.member_email = memberEmail_tf.text!
        MemberObject_signup.my_store = StoreObject_signup.store_id
        /// store
        if MemberObject_signup.member_grade == "ceo" {
            StoreObject_signup.ceo_name = MemberObject_signup.member_name
            StoreObject_signup.ceo_num = MemberObject_signup.member_num
        }
        /// segue agreement
        presentPanModal(storyboard?.instantiateViewController(withIdentifier: "SignUpRegisterVC") as! SignUpRegisterVC)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
        
        ChoiceStoreVCdelegate = nil
        SignUpStoreVCdelegate = nil
    }
}

extension SignUpMemberVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

extension SignUpMemberVC {
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            textField.resignFirstResponder()
        } else if let nextTextField = view.viewWithTag(textField.tag+1) as? UITextField {
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}

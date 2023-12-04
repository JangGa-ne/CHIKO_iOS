//
//  SignUpRegisterVC.swift
//  market
//
//  Created by Busan Dynamic on 10/24/23.
//

import UIKit
import PanModal

class SignUpRegisterVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var sms: Bool = false
    var email: Bool = false
    
    @IBOutlet var agree_sv_s: [UIStackView]!
    @IBOutlet var agree_img_s: [UIImageView]!
    @IBOutlet var agree_label_s: [UILabel]!
    @IBOutlet var agree_btn_s: [UIButton]!
    @IBOutlet var agreeDetail_btn_s: [UIButton]!
    
    @IBOutlet weak var sms_img: UIImageView!
    @IBOutlet weak var sms_btn: UIButton!
    @IBOutlet weak var email_img: UIImageView!
    @IBOutlet weak var email_btn: UIButton!
    
    @IBOutlet weak var register_btn: UIButton!
    @IBAction func back_btn(_ sender: UIButton) { dismiss(animated: true, completion: nil) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 데이터 삭제
        SignUpMemberObject.upload_files.removeAll()
        SignUpStoreObject.upload_files.removeAll()
        // init
        /// member id card
        for (_, data) in SignUpMemberObject.upload_member_idcard_img.enumerated() {
            SignUpMemberObject.upload_files.append((field_name: "user_idcard_img", file_name: data.file_name, file_data: data.file_data, file_size: data.file_size))
        }
        /// store main photo
        for (_, data) in SignUpStoreObject.upload_store_mainphoto_img.enumerated() {
            SignUpStoreObject.upload_files.append((field_name: "store_mainphoto_img", file_name: data.file_name, file_data: data.file_data, file_size: data.file_size))
        }
        /// store passbook
        for (_, data) in SignUpStoreObject.upload_passbook_img.enumerated() {
            SignUpStoreObject.upload_files.append((field_name: "passbook_img", file_name: data.file_name, file_data: data.file_data, file_size: data.file_size))
        }
        /// store business register number
        for (_, data) in SignUpStoreObject.upload_business_reg_img.enumerated() {
            SignUpStoreObject.upload_files.append((field_name: "business_reg_img", file_name: data.file_name, file_data: data.file_data, file_size: data.file_size))
        }
        /// store building contract
        for (_, data) in SignUpStoreObject.upload_building_contract_img.enumerated() {
            SignUpStoreObject.upload_files.append((field_name: "building_contract_img", file_name: data.file_name, file_data: data.file_data, file_size: data.file_size))
        }
        /// agreement
        agree_btn_s.forEach { btn in btn.addTarget(self, action: #selector(normal_agree_btn(_:)), for: .touchUpInside) }
        sms_btn.addTarget(self, action: #selector(marketing_agree_btn(_:)), for: .touchUpInside)
        email_btn.addTarget(self, action: #selector(marketing_agree_btn(_:)), for: .touchUpInside)
        /// signup
        register_btn.addTarget(self, action: #selector(register_btn(_:)), for: .touchUpInside)
    }
    
    @objc func normal_agree_btn(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            agree_sv_s.forEach { sv in if (sv.tag == sender.tag) { sv.backgroundColor = .H_8CD26B } }
            agree_img_s.forEach { img in if (img.tag == sender.tag) { img.image = UIImage(named: "check_on") } }
            agree_label_s.forEach { label in if (label.tag == sender.tag) { label.textColor = .white } }
            agreeDetail_btn_s.forEach { btn in if (btn.tag == sender.tag) { btn.isHidden = true } }
            if (sender.tag == 2) { SignUpMemberObject.marketing_agree = true; SignUpMemberObject.marketing_agree_type = ["sms", "email"]
                sms = true; sms_img.image = UIImage(named: "check_on"); sms_btn.isSelected = true
                email = true; email_img.image = UIImage(named: "check_on"); email_btn.isSelected = true
            }
        } else {
            agree_sv_s.forEach { sv in if (sv.tag == sender.tag) { sv.backgroundColor = .H_F2F2F7 } }
            agree_img_s.forEach { img in if (img.tag == sender.tag) { img.image = UIImage(named: "check_off") } }
            agree_label_s.forEach { label in if (label.tag == sender.tag) { label.textColor = .black.withAlphaComponent(0.3) } }
            agreeDetail_btn_s.forEach { btn in if (btn.tag == sender.tag) { btn.isHidden = false } }
            if (sender.tag == 2) { SignUpMemberObject.marketing_agree = false; SignUpMemberObject.marketing_agree_type.removeAll()
                sms = false; sms_img.image = UIImage(named: "check_off"); sms_btn.isSelected = false
                email = false; email_img.image = UIImage(named: "check_off"); email_btn.isSelected = false
            }
        }
    }
    
    @objc func marketing_agree_btn(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            if (sender.tag == 0) { sms = true; sms_img.image = UIImage(named: "check_on"); sms_btn.isSelected = true }
            if (sender.tag == 1) { email = true; email_img.image = UIImage(named: "check_on"); email_btn.isSelected = true }
        } else {
            if (sender.tag == 0) { sms = false; sms_img.image = UIImage(named: "check_off"); sms_btn.isSelected = false }
            if (sender.tag == 1) { email = false; email_img.image = UIImage(named: "check_off"); email_btn.isSelected = false }
        }
        
        SignUpMemberObject.marketing_agree_type.removeAll()
        if sms { SignUpMemberObject.marketing_agree_type.append("sms") }
        if email { SignUpMemberObject.marketing_agree_type.append("email") }
        
        if (SignUpMemberObject.marketing_agree_type.count > 0) { SignUpMemberObject.marketing_agree = true
            agree_sv_s.forEach { sv in if (sv.tag == 2) { sv.backgroundColor = .H_8CD26B } }
            agree_img_s.forEach { img in if (img.tag == 2) { img.image = UIImage(named: "check_on") } }
            agree_label_s.forEach { label in if (label.tag == 2) { label.textColor = .white } }
            agree_btn_s.forEach { btn in if (btn.tag == 2) { btn.isSelected = true } }
        } else { SignUpMemberObject.marketing_agree = false
            agree_sv_s.forEach { sv in if (sv.tag == 2) { sv.backgroundColor = .H_F2F2F7 } }
            agree_img_s.forEach { img in if (img.tag == 2) { img.image = UIImage(named: "check_off") } }
            agree_label_s.forEach { label in if (label.tag == 2) { label.textColor = .black.withAlphaComponent(0.3) } }
            agree_btn_s.forEach { btn in if (btn.tag == 2) { btn.isSelected = false } }
        }
    }
    
    @objc func register_btn(_ sender: UIButton) {
        
        var final_check: Bool = true
        
        agree_btn_s.forEach { btn in
            if (btn.tag == 0 || btn.tag == 1) && !btn.isSelected { customAlert(message: "필수 약관 미동의 항목이 있습니다.", time: 1); final_check = false }
        }
        
        if !final_check { return }
        
        customLoadingIndicator(animated: true)
        
        var status_code: Int = 500
        /// SignUp 요청
        dispatchGroup.enter()
        requestSignUp { status in
            status_code = status; dispatchGroup.leave()
            
            if status == 200 {
                /// Member FileUpload 요청
                dispatchGroup.enter()
                requestFileUpload(collection_id: "member", document_id: SignUpMemberObject.member_id, file_data: SignUpMemberObject.upload_files) { status in
                    status_code = status; dispatchGroup.leave()
                }
                /// Store FileUpload 요청
                dispatchGroup.enter()
                requestFileUpload(collection_id: "store", document_id: SignUpStoreObject.store_id, file_data: SignUpStoreObject.upload_files) { status in
                    status_code = status; dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            
            self.customLoadingIndicator(animated: false)
            
            switch status_code {
            case 200:
                self.customAlert(message: "회원가입 되었습니다.", time: 1)
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self.dismiss(animated: true) {
                        UserDefaults.standard.setValue(SignUpMemberObject.member_type, forKey: "member_type")
                        UserDefaults.standard.setValue(SignUpMemberObject.member_id, forKey: "member_id")
                        UserDefaults.standard.setValue(SignUpMemberObject.member_pw, forKey: "member_pw")
                        SignUpMemberVCdelegate?.segueViewController(identifier: "SplashVC")
                    }
                }
            case 204:
                self.customAlert(message: "No data", time: 1)
            case 600:
                self.customAlert(message: "Error occurred during data conversion", time: 1)
            default:
                self.customAlert(message: "Internal server error", time: 1)
            }
        }
    }
}

extension SignUpRegisterVC: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var showDragIndicator: Bool {
        return false
    }
}

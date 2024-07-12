//
//  MemberVC.swift
//  market
//
//  Created by 장 제현 on 12/12/23.
//

/// 번역완료

import UIKit
import PanModal

class MemberVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var password_check: [Bool] = [false, false, false]
    /// 휴대 전화번호, 본인인증, 기존 비밀번호, 새 비밀번호, 비밀번호 확인, 가입자 이름, 이메일
    var input_check: [Bool] = [false, false, true, true, true, false, false]
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var scrollView: UIScrollView!
    /// 휴대 전화번호
    @IBOutlet weak var phoneNum_tf: UITextField!
    @IBOutlet weak var checkPhoneNum_img: UIImageView!
    @IBOutlet weak var phoneNum_btn: UIButton!
    @IBOutlet weak var noticePhoneNum_label: UILabel!
    @IBOutlet weak var phoneNumCheck_view: UIView!
    @IBOutlet weak var phoneNumCheck_tf: UITextField!
    @IBOutlet weak var checkPhoneNumCheck_img: UIImageView!
    @IBOutlet weak var noticePhoneNumCheck_label: UILabel!
    /// 비밀번호 변경
    @IBOutlet weak var beforeMemberPw_tf: UITextField!
    @IBOutlet weak var noticeBeforeMemberPw_label: UILabel!
    @IBOutlet weak var checkBeforeMemberPw_img: UIImageView!
    @IBOutlet weak var afterMemberPw_tf: UITextField!
    @IBOutlet weak var noticeAfterMemberPw_label: UILabel!
    @IBOutlet weak var checkAfterMemberPw_img: UIImageView!
    @IBOutlet weak var afterMemberPwCheck_tf: UITextField!
    @IBOutlet weak var noticeAfterMemberPwCheck_label: UILabel!
    @IBOutlet weak var checkAfterMemberPwCheck_img: UIImageView!
    @IBOutlet weak var afterMemberPwCheck_btn: UIButton!
    /// 가입자 이름
    @IBOutlet weak var memberName_tf: UITextField!
    @IBOutlet weak var checkMemberName_img: UIImageView!
    /// 이메일
    @IBOutlet weak var memberEmail_tf: UITextField!
    @IBOutlet weak var checkMemberEmail_img: UIImageView!
    @IBOutlet weak var noticeMemberEmail_label: UILabel!
    // 증명 서류 제출
    /// 신분증
    @IBOutlet weak var submitDocu_sv: UIStackView!
    @IBOutlet weak var memberIdCard_view: UIView!
    @IBOutlet weak var memberIdCard_img: UIImageView!
    @IBOutlet weak var memberIdCard_label: UILabel!
    @IBOutlet weak var checkMemberIdCard_img: UIImageView!
    
    @IBOutlet weak var edit_btn: UIButton!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in label.text = translation(label.text!) }
        buttons.forEach { btn in btn.setTitle(translation(btn.title(for: .normal)), for: .normal) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setKeyboard()
        
        let data = MemberObject
        
        ([phoneNum_tf, phoneNumCheck_tf, beforeMemberPw_tf, afterMemberPw_tf, afterMemberPwCheck_tf, memberName_tf, memberEmail_tf] as [UITextField]).enumerated().forEach { i, tf in
            tf.placeholder(text: ["-없이 입력", "인증번호 입력", "기존 비밀번호", "새 비밀번호", "비밀번호 확인", "", "@이하 주소까지 모두 입력"][i])
            tf.text = [data.member_num, "", "", "", "", data.member_name, data.member_email][i]
            if i < 1 || i >= 5 { input_check[i] = (tf.text! != "") }
            tf.delegate = self
            tf.tag = i
            tf.addTarget(self, action: #selector(changedEditMemberInfo_if(_:)), for: .editingChanged)
            tf.addTarget(self, action: #selector(endEditMemberInfo_if(_:)), for: .editingDidEnd)
            if tf != memberEmail_tf { tf.returnKeyType = .next } else { tf.returnKeyType = .done }
        }
        /// check
        ([checkPhoneNum_img, checkPhoneNumCheck_img, checkBeforeMemberPw_img, checkAfterMemberPw_img, checkAfterMemberPwCheck_img, checkMemberName_img, checkMemberEmail_img, checkMemberIdCard_img] as [UIImageView]).enumerated().forEach { i, img in
            img.isHidden = true
        }
        /// notice
        ([noticePhoneNum_label, noticePhoneNumCheck_label, noticeBeforeMemberPw_label, noticeAfterMemberPw_label, noticeAfterMemberPwCheck_label, noticeMemberEmail_label] as [UILabel]).enumerated().forEach { i, label in
            label.isHidden = true
        }
        
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scrollView(_:))))
//        /// phone number send
//        phoneNum_btn.isHidden = true
        phoneNum_btn.addTarget(self, action: #selector(phoneNum_btn(_:)), for: .touchUpInside)
        phoneNumCheck_view.isHidden = true
        /// member pw
        afterMemberPwCheck_btn.addTarget(self, action: #selector(afterMemberPwCheck_btn(_:)), for: .touchUpInside)
        submitDocu_sv.isHidden = !(data.member_type == "retailseller")
        /// member id card
        memberIdCard_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(memberIdCard_view(_:))))
        imageUrlStringToData(from: MemberObject.member_idcard_img) { mimeType, imgData in
            DispatchQueue.main.async {
                MemberObject.upload_member_idcard_img.append((file_name: "user_idcard_img.\((mimeTypes.filter { $0.value == mimeType }.map { $0.key }).first ?? "")", file_data: imgData ?? Data(), file_size: imgData?.count ?? 0))
                if let imgData = UIImage(data: imgData ?? Data()) {
                    self.memberIdCard_img.image = resizeImage(imgData, targetSize: self.memberIdCard_img.frame.size)
//                    self.checkMemberIdCard_img.isHidden = false
                } else {
                    self.memberIdCard_img.image = UIImage()
//                    self.checkMemberIdCard_img.isHidden = true
                }
            }
        }
        
        edit_btn.addTarget(self, action: #selector(edit_btn(_:)), for: .touchUpInside)
    }
    
    @objc func changedEditMemberInfo_if(_ sender: UITextField) {
        
        var filterContains: String = ""
        
        let text = sender.text!.replacingOccurrences(of: " ", with: "")
        let member_type: String = MemberObject.member_type
        
        let notice: UILabel = [noticePhoneNum_label, noticePhoneNumCheck_label, noticeBeforeMemberPw_label, noticeAfterMemberPw_label, noticeAfterMemberPwCheck_label, UILabel(), noticeMemberEmail_label][sender.tag]
        // init
        if sender.tag >= 2 && sender.tag <= 4 {
            password_check[sender.tag-2] = false
        } else {
            input_check[sender.tag] = false
        }; notice.isHidden = true
        
        switch sender {
        case phoneNum_tf:
            
            phoneNum_btn.isSelected = false
            phoneNum_btn.backgroundColor = .black.withAlphaComponent(0.3)
            phoneNumCheck_view.isHidden = true
            phoneNumCheck_tf.text?.removeAll()
            noticePhoneNumCheck_label.isHidden = true
            checkPhoneNumCheck_img.isHidden = true
            
            if member_type == "retailseller" {
//                check.isHidden = !(isChinesePhoneNumValid(text) || text == "01031870005")
                input_check[sender.tag] = (text.count != 0 || text == "01031870005")
            } else if member_type == "wholesales" {
                input_check[sender.tag] = (text.count == 11 || text == "01031870005")
            }
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
                        self.checkPhoneNumCheck_img.isHidden = false
                        self.input_check[sender.tag] = true
                    } else {
                        notice.isHidden = false
                        self.checkPhoneNumCheck_img.isHidden = true
                        self.input_check[sender.tag] = false
                    }
                }
            }
        case beforeMemberPw_tf:
            if sender.text! == MemberObject.member_pw {
                password_check[sender.tag-2] = true
            }
        case afterMemberPw_tf:
            
            afterMemberPwCheck_tf.text?.removeAll()
            noticeAfterMemberPwCheck_label.isHidden = true
            checkAfterMemberPwCheck_img.isHidden = true
            
            filterContains = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~`!@#$%^&*()-+="
            
            if sender.text!.count < 8 || sender.text!.count > 15 {
                notice.text = translation("8~15자까지 입력 가능합니다.")
            } else if sender.text!.rangeOfCharacter(from: CharacterSet(charactersIn: filterContains).inverted) != nil {
                notice.text = translation("영어, 숫자, 특수문자 - ' ! @ # $ % ^ & * ( ) - + = 조합")
            } else if !isPasswordValid(sender.text!) {
                notice.text = translation("영어, 숫자, 특수문자가 최소 1자 이상 포함되어야 합니다.")
            } else {
                password_check[sender.tag-2] = true
            }
            break
        case afterMemberPwCheck_tf:
            if !noticeAfterMemberPw_label.isHidden {
                notice.text = translation("비밀번호 형식이 맞지 않습니다.")
            } else if sender.text! != afterMemberPw_tf.text! {
                notice.text = translation("비밀번호가 맞지 않습니다.")
            } else {
                password_check[sender.tag-2] = true
            }
            break
        case memberName_tf:
            if text.count > 0 { input_check[sender.tag] = true }
        case memberEmail_tf:
            if isEmailValid(text) { input_check[sender.tag] = true }
        default:
            break
        }
    }
    
    @objc func endEditMemberInfo_if(_ sender: UITextField) {
        
        if sender == phoneNumCheck_tf { return }
        
        let notice: UILabel = [noticePhoneNum_label, noticePhoneNumCheck_label, noticeBeforeMemberPw_label, noticeAfterMemberPw_label, noticeAfterMemberPwCheck_label, UILabel(), noticeMemberEmail_label][sender.tag]
        
        if sender.tag >= 2 && sender.tag <= 4 {
            notice.isHidden = password_check[sender.tag-2]
        } else {
            notice.isHidden = input_check[sender.tag]
        }
    }
    
    @objc func phoneNum_btn(_ sender: UIButton) {
        
        phoneNumCheck_tf.text?.removeAll()
        checkPhoneNumCheck_img.isHidden = true
        
        if phoneNum_tf.text!.count > 0, noticePhoneNum_label.isHidden {
            customLoadingIndicator(animated: true)
            /// Phone Number Send 요청
            requestPhoneNum(phoneNum: phoneNum_tf.text!) { status in
                self.customLoadingIndicator(animated: false)
                if status == 200 {
                    self.customAlert(message: "인증번호를 요청하였습니다.", time: 1) {
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                            self.phoneNumCheck_tf.becomeFirstResponder()
                        }
                    }
                    sender.isSelected = true
                    sender.backgroundColor = .H_8CD26B
                    self.phoneNumCheck_view.isHidden = false
                } else {
                    self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
                    sender.isSelected = false
                    sender.backgroundColor = .systemOrange
                    self.phoneNumCheck_view.isHidden = true
                }
            }
        }
    }
    
    @objc func afterMemberPwCheck_btn(_ sender: UIButton) {
        
        if beforeMemberPw_tf.text! != "", noticeBeforeMemberPw_label.isHidden, afterMemberPw_tf.text! != "", noticeAfterMemberPw_label.isHidden, afterMemberPwCheck_tf.text! != "", noticeAfterMemberPwCheck_label.isHidden {
            
            customLoadingIndicator(animated: true)
            
            let params: [String: Any] = [
                "action": "edit",
                "collection_id": "member",
                "document_id": MemberObject.member_id,
                "user_pw": afterMemberPwCheck_tf.text!,
            ]
            
            requestEditDB(params: params) { status in
                
                self.customLoadingIndicator(animated: false)
                
                if status == 200 {
                    MemberObject.member_pw = self.afterMemberPw_tf.text!
                    UserDefaults.standard.setValue(self.afterMemberPw_tf.text!, forKey: "member_pw")
                    self.alert(title: "", message: "비밀번호 변경 되었습니다.", style: .alert, time: 1) {
                        self.navigationController?.popViewController(animated: true)
                    }
                    sender.backgroundColor = .H_8CD26B
                } else {
                    self.alert(title: "", message: "문제가 발생했습니다. 다시 시도해주세요.", style: .alert, time: 1)
                    sender.backgroundColor = .systemRed
                }
            }
        } else {
            customAlert(message: "미입력된 항목이 있거나\n확인되지 않은 항목이 있습니다.", time: 1)
            sender.backgroundColor = .black.withAlphaComponent(0.3)
        }
    }
    
    @objc func memberIdCard_view(_ sender: UITapGestureRecognizer) {
        
        setPhoto(max: 1) { photo in
            MemberObject.upload_member_idcard_img = photo
            self.memberIdCard_img.image = UIImage(data: photo[0].file_data)
            self.checkMemberIdCard_img.isHidden = false
        }
    }
    
    @objc func edit_btn(_ sender: UIButton) {
        
        var final_check: Bool = true
        var phone_check: Bool = false
        input_check.enumerated().forEach { i, check in
            if !check && i != 1 {
                final_check = false
            }
            if i == 1 {
                phone_check = check
            }
        }
        print(input_check)
        if !final_check { customAlert(message: "미입력된 항목이 있거나\n확인되지 않은 항목이 있습니다.", time: 1); return }
        if !phone_check { customAlert(message: "본인인증을 해주세요.", time: 1); return }
        if MemberObject.member_type == "retailseller" && MemberObject.upload_member_idcard_img.count == 0 {
            customAlert(message: "증빙 서류 미제출 항목이 있습니다.", time: 1); return
        }
        
        if MemberObject.member_pw2 != "" {
            let segue = storyboard?.instantiateViewController(withIdentifier: "PasswordVC") as! PasswordVC
            segue.dismissCompletion = { self.postData() }
            presentPanModal(segue)
        } else {
            postData()
        }
    }
    
    func postData() {
        
        customLoadingIndicator(animated: true)
        
        MemberObject.upload_files.removeAll()
        /// 신분증
        MemberObject.upload_member_idcard_img.forEach { (file_name: String, file_data: Data, file_size: Int) in
            MemberObject.upload_files.append((field_name: "user_idcard_img", file_name: file_name, file_data: file_data, file_size: file_size))
        }
        
        var status_code: Int = 500
        
        let params: [String: Any] = [
            "action": "edit",
            "collection_id": "member",
            "document_id": MemberObject.member_id,
            "user_num": phoneNum_tf.text!,
            "user_name": memberName_tf.text!,
            "user_email": memberEmail_tf.text!
        ]
        /// EditDB 요청
        dispatchGroup.enter()
        requestEditDB(params: params) { status in
            
            if status == 200 {
                dispatchGroup.enter()
                requestFileUpload(action: "edit", collection_id: "member", document_id: MemberObject.member_id, file_data: MemberObject.upload_files) { _, status in
                    dispatchGroup.leave()
                }
            }
            status_code = status; dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            
            self.customLoadingIndicator(animated: false)
            
            if status_code == 200 {
                MemberObject.member_num = self.phoneNum_tf.text!
                MemberObject.member_name = self.memberName_tf.text!
                MemberObject.member_email = self.memberEmail_tf.text!
                MemberObject.upload_files.removeAll()
                self.alert(title: "", message: "저장되었습니다.", style: .alert, time: 1) {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.alert(title: "", message: "문제가 발생했습니다. 다시 시도해주세요.", style: .alert, time: 1)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

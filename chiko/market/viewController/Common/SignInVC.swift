//
//  SignInVC.swift
//  market
//
//  Created by 장 제현 on 2023/10/16.
//

/// 번역완료

import UIKit
import FirebaseMessaging

class SignInVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var navi_label: UILabel!
    @IBOutlet weak var navi_lineView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var retailseller_btn: UIButton!
    @IBOutlet weak var wholesales_btn: UIButton!
    
    @IBOutlet weak var memberId_tf: UITextField!
    @IBOutlet weak var memberPw_tf: UITextField!
    @IBOutlet weak var findIdPw_btn: UIButton!
    @IBOutlet weak var signIn_btn: UIButton!
    @IBOutlet weak var signUp_sv: UIStackView!
    @IBOutlet weak var signUp_btn: UIButton!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in label.text = translation(label.text!) }
        buttons.forEach { btn in btn.setTitle(translation(btn.title(for: .normal)), for: .normal) }
                
        NotificationCenter.default.addObserver(self, selector: #selector(show(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func show(_ sender: Notification) {
        signUp_sv.isHidden = true
    }
    
    @objc func hidden(_ sender: Notification) {
        signUp_sv.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoryCheck(delete: true)
        
        SignInVCdelegate = self
        
        setKeyboard()
        // init
        appDelegate.member_type = "retailseller"
        /// 푸시 구독해제
        let store_id: String = StoreObject.store_id
        let member_id: String = MemberObject.member_id
        ["local", "marketing", "chats", "dpcost_request", "enquiry"].forEach { topic in
            let topic_name = topic == "chats" ? "chats_\(member_id)" : "\(topic)_\(store_id)"
            Messaging.messaging().unsubscribe(fromTopic: topic_name) { error in
                error == nil ? print("도픽구독해제성공: \(topic_name)") : print("도픽구독해제실패: \(topic_name)")
            }
        }
        /// 데이터 삭제
        listener = nil
        /// Common
        MemberObject_signup = MemberData()
        StoreObject_signup = StoreData()
        MemberObject = MemberData()
        StoreObject = StoreData()
        StoreArray.removeAll()
        NoticeArray.removeAll()
        /// Retailseller
        ReStoreArray_best.removeAll()
        ReGoodsArray_best.removeAll()
        ReGoodsArray_best2.removeAll()
        ReBasketArray.removeAll()
        /// Wholesales
        WhGoodsArray_realtime.removeAll()
        WhCountingObject = WhCountingData()
        WhOrderArray.removeAll()
        
        UserDefaults.standard.removeObject(forKey: "store_index_select")
        UserDefaults.standard.removeObject(forKey: "store_index")
        UserDefaults.standard.removeObject(forKey: "member_type")
        UserDefaults.standard.removeObject(forKey: "member_id")
        UserDefaults.standard.removeObject(forKey: "member_pw")
        
        /// navi
        navi_label.alpha = 0.0
        navi_lineView.alpha = 0.0
        
        scrollView.delegate = self
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scrollView(_:))))
        /// member_type
        ([retailseller_btn, wholesales_btn] as [UIButton]).enumerated().forEach { i, btn in
            btn.tag = i; btn.addTarget(self, action: #selector(memberType_btn(_:)), for: .touchUpInside)
            if btn.tag == 0 { btn.isSelected = true } else { btn.isSelected = false }
        }
        /// member_id, member_pw
        ([memberId_tf, memberPw_tf] as [UITextField]).enumerated().forEach { i, tf in
            tf.placeholder(text: ["아이디를 입력하세요.", "비밀번호를 입력하세요."][i])
            tf.delegate = self
            if tf == memberId_tf {
                tf.returnKeyType = .next
            } else {
                tf.returnKeyType = .done
            }
        }
        /// find id/pw
        findIdPw_btn.addTarget(self, action: #selector(findIdPw_btn(_:)), for: .touchUpInside)
        /// sign in/up
        ([signIn_btn, signUp_btn] as [UIButton]).enumerated().forEach { i, btn in
            btn.tag = i; btn.addTarget(self, action: #selector(sign_btn(_:)), for: .touchUpInside)
        }
        
//        memberId_tf.text = "receo0005"; memberPw_tf.text = "qqq111---"
    }
    
    @objc func memberType_btn(_ sender: UIButton) {
        
        if sender.tag == 0 {
            /// retailseller
            appDelegate.member_type = "retailseller"
            retailseller_btn.isSelected = true; wholesales_btn.isSelected = false
            retailseller_btn.backgroundColor = .H_8CD26B; wholesales_btn.backgroundColor = .H_F2F2F7
            
//            memberId_tf.text = "receo0005"; memberPw_tf.text = "qqq111---"
            
        } else if sender.tag == 1 {
            /// wholesales
            appDelegate.member_type = "wholesales"
            retailseller_btn.isSelected = false; wholesales_btn.isSelected = true
            retailseller_btn.backgroundColor = .H_F2F2F7; wholesales_btn.backgroundColor = .H_8CD26B
            
//            memberId_tf.text = "whceo0005"; memberPw_tf.text = "qqq111---"
        }
    }
    
    @objc func findIdPw_btn(_ sender: UIButton) {
        segueViewController(identifier: "VerificationVC")
    }
    
    @objc func sign_btn(_ sender: UIButton) {
        
        if sender.tag == 0 {
            /// signin
            if memberId_tf.text! == "" || memberPw_tf.text! == "" {
                customAlert(message: "아이디 또는 비밀번호가 입력되지 않았습니다.", time: 1)
            } else {
                // init
                appDelegate.member_id = memberId_tf.text!
                appDelegate.member_pw = memberPw_tf.text!
                
                customLoadingIndicator(animated: true)
                
                var status_code: Int = 500
                /// SignIn 요청
                dispatchGroup.enter()
                requestSignIn { status in
                    
                    if status == 200 {
                        /// Notice 요청
                        dispatchGroup.enter()
                        requestNotice { status in
                            notice_read = NoticeArray.allSatisfy { $0.read_or_not }; dispatchGroup.leave()
                        }
                        if MemberObject.member_type == "retailseller" {
                            /// ReMain 요청
                            dispatchGroup.enter()
                            requestReMain { status in
                                dispatchGroup.leave()
                            }
                            /// Best Items 요청
                            dispatchGroup.enter()
                            requestBestItems { status in
                                dispatchGroup.leave()
                            }
                            /// ReBasket 요청
                            dispatchGroup.enter()
                            requestReBasket(type: "get") { status in
                                dispatchGroup.leave()
                            }
                        } else if MemberObject.member_type == "wholesales" {
                            /// WhRealTime 요청
                            dispatchGroup.enter()
                            requestWhRealTime(filter: "최신순", limit: 3) { status in
                                dispatchGroup.leave()
                            }
                        }
                    }
                    
                    status_code = status; dispatchGroup.leave()
                }
                /// 모든 요청이 완료된 후 실행
                dispatchGroup.notify(queue: .main) {
                    
                    self.customLoadingIndicator(animated: false)
                    
                    switch status_code {
                    case 200:
                        UserDefaults.standard.setValue(appDelegate.member_type, forKey: "member_type")
                        UserDefaults.standard.setValue(appDelegate.member_id, forKey: "member_id")
                        UserDefaults.standard.setValue(appDelegate.member_pw, forKey: "member_pw")
//                        /// 매장선택
//                        self.segueViewController(identifier: "ChoiceStoreVC")
                        
                        if MemberObject.member_type == "retailseller" {
                            if MemberObject.member_grade == "employee" && (MemberObject.waiting_step == 0 || MemberObject.waiting_step == 1) {
                                if push_type == "member_register" { MemberObject.waiting_step = 1 }
                                self.segueViewController(identifier: "WaitingVC")
                            } else {
                                self.segueTabBarController(identifier: "ReMainTBC", idx: 0)
                            }
                        } else if MemberObject.member_type == "wholesales" {
                            if StoreObject.waiting_step == 0 || StoreObject.waiting_step == 1 {
                                if push_type == "member_register" { StoreObject.waiting_step = 1 }
                                self.segueViewController(identifier: "WaitingVC")
                            } else if MemberObject.member_grade == "employee" && (MemberObject.waiting_step == 0 || MemberObject.waiting_step == 1) {
                                if push_type == "member_register" { MemberObject.waiting_step = 1 }
                                self.segueViewController(identifier: "WaitingVC")
                            } else if StoreObject.waiting_step == 2 {
                                self.segueViewController(identifier: "WhHomeVC")
                            }
                        }; if push_type != "" { push_type.removeAll(); segue_type.removeAll() }
                    case 500:
                        self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
                    default:
                        self.customAlert(message: "로그인 실패", time: 1)
                    }
                }
            }
        } else if sender.tag == 1 {
            /// signup
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: translation("소매자 회원가입"), style: .default, handler: { _ in
                MemberObject_signup.member_type = "retailseller"
                DispatchQueue.main.async { self.segueViewController(identifier: "SignUpMemberVC") }
            }))
            alert.addAction(UIAlertAction(title: translation("도매 판매자 회원가입"), style: .default, handler: { _ in
                MemberObject_signup.member_type = "wholesales"
                DispatchQueue.main.async { self.segueViewController(identifier: "SignUpMemberVC") }
            }))
            alert.addAction(UIAlertAction(title: translation("취소"), style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
        
        SignUpMemberVCdelegate = nil
    }
}

extension SignInVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

extension SignInVC {
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == memberId_tf {
            memberPw_tf.becomeFirstResponder()
        } else if textField == memberPw_tf {
            memberPw_tf.resignFirstResponder(); sign_btn(UIButton())
        }
        return true
    }
}


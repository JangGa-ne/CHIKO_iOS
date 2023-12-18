//
//  SignInVC.swift
//  market
//
//  Created by Busan Dynamic on 2023/10/16.
//

import UIKit

class SignInVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
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
        
        SignInVCdelegate = self
        
        setKeyboard()
        // init
        appDelegate.member_type = "retailseller"
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
            tf.placeholder(text: ["아이디를 입력하세요.", "비밀번호를 입력하세요."][i], color: .black.withAlphaComponent(0.3))
            if i != [memberId_tf, memberPw_tf].count-2 { tf.returnKeyType = .next } else { tf.returnKeyType = .done }
        }
        /// find id/pw
        findIdPw_btn.addTarget(self, action: #selector(findIdPw_btn(_:)), for: .touchUpInside)
        /// sign in/up
        ([signIn_btn, signUp_btn] as [UIButton]).enumerated().forEach { i, btn in
            btn.tag = i; btn.addTarget(self, action: #selector(sign_btn(_:)), for: .touchUpInside)
        }
        
        memberId_tf.text = "qqqqqqq"; memberPw_tf.text = "qqq111---"
    }
    
    @objc func memberType_btn(_ sender: UIButton) {
        /// hidden keyboard
        view.endEditing(true)
        
        if sender.tag == 0 {
            /// retailseller
            appDelegate.member_type = "retailseller"
            retailseller_btn.isSelected = true; wholesales_btn.isSelected = false
            retailseller_btn.backgroundColor = .H_8CD26B; wholesales_btn.backgroundColor = .H_F2F2F7
            
            memberId_tf.text = "qqqqqqq"; memberPw_tf.text = "qqq111---"
            
        } else if sender.tag == 1 {
            /// wholesales
            appDelegate.member_type = "wholesales"
            retailseller_btn.isSelected = false; wholesales_btn.isSelected = true
            retailseller_btn.backgroundColor = .H_F2F2F7; wholesales_btn.backgroundColor = .H_8CD26B
            
            memberId_tf.text = "testnike"; memberPw_tf.text = "qqq111---"
        }
    }
    
    @objc func findIdPw_btn(_ sender: UIButton) {
        
    }
    
    @objc func sign_btn(_ sender: UIButton) {
        /// hidden keyboard
        view.endEditing(true)
        
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
                    
                    if status == 200, MemberObject.member_type == "retailseller" {
                        /// ReMain 요청
                        dispatchGroup.enter()
                        requestReMain { status in
                            status_code = status; dispatchGroup.leave()
                        }
                        /// ReBasket 요청
                        dispatchGroup.enter()
                        requestReBasket(type: "get") { status in
                            status_code = status; dispatchGroup.leave()
                        }
                    } else if status == 200, MemberObject.member_type == "wholesales" {
                        /// WhRealTime 요청
                        dispatchGroup.enter()
                        requestWhRealTime(filter: "최신순", limit: 3) { status in
                            status_code = status; dispatchGroup.leave()
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
//                        self.segueViewController(identifier: "ChoiceStoreVC")
                        if MemberObject.member_type == "retailseller" {
                            self.segueTabBarController(identifier: "ReMainTBC", idx: 0)
                        } else if MemberObject.member_type == "wholesales" {
                            if StoreObject.waiting_step == 0 || StoreObject.waiting_step == 1 {
                                self.segueViewController(identifier: "WhWaitingVC")
                            } else if StoreObject.waiting_step == 2 {
                                self.segueViewController(identifier: "WhHomeVC")
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
        } else if sender.tag == 1 {
            /// signup
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "소매자 회원가입", style: .default, handler: { _ in
                MemberObject_signup.member_type = "retailseller"
                DispatchQueue.main.async { self.segueViewController(identifier: "SignUpMemberVC") }
            }))
            alert.addAction(UIAlertAction(title: "도매 판매자 회원가입", style: .default, handler: { _ in
                MemberObject_signup.member_type = "wholesales"
                DispatchQueue.main.async { self.segueViewController(identifier: "SignUpMemberVC") }
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
        
        SignUpMemberVCdelegate = nil
        
        /// 데이터 삭제
        /// Common
        MemberObject_signup = MemberData()
        StoreObject_signup = StoreData()
        MemberObject = MemberData()
        StoreObject = StoreData()
        StoreArray.removeAll()
        /// Retailseller
        StoreArray_best.removeAll()
        GoodsArray_best.removeAll()
        BasketArray.removeAll()
        /// Wholesales
        GoodsArray_realtime.removeAll()
        
        UserDefaults.standard.removeObject(forKey: "store_index_select")
        UserDefaults.standard.removeObject(forKey: "store_index")
        UserDefaults.standard.removeObject(forKey: "member_type")
        UserDefaults.standard.removeObject(forKey: "member_id")
        UserDefaults.standard.removeObject(forKey: "member_pw")
    }
}

extension SignInVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

//
//  SplashVC.swift
//  market
//
//  Created by 장 제현 on 2023/10/18.
//

import UIKit
import FirebaseMessaging

class SplashVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SplashVCdelegate = self
        // init
        /// member info
        appDelegate.member_type = UserDefaults.standard.string(forKey: "member_type") ?? ""
        appDelegate.member_id = UserDefaults.standard.string(forKey: "member_id") ?? ""
        appDelegate.member_pw = UserDefaults.standard.string(forKey: "member_pw") ?? ""
        fcm_id = UserDefaults.standard.string(forKey: "fcm_id") ?? ""
        
        if fcm_id == "" {
            Messaging.messaging().token { token, error in fcm_id = token ?? "" }
        }
        if UserDefaults.standard.string(forKey: "member_id") == nil {
            segueViewController(identifier: "SignInVC"); return
        }
        
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
        /// Category 요청
        dispatchGroup.enter()
        requestCategory(action: ["color_category", "item_category", "size_category", "style_category", "material_category"]) { _ in
            dispatchGroup.leave()
        }
        /// 모든 요청이 완료된 후 실행
        dispatchGroup.notify(queue: .main) {
            
            switch status_code {
            case 200:
//                if !store_index_select {
//                    back_btn_hidden = true
//                    self.segueViewController(identifier: "ChoiceStoreVC")
//                } else
                if MemberObject.member_type == "retailseller" {
                    if MemberObject.member_grade == "employee" && (MemberObject.waiting_step == 0 || MemberObject.waiting_step == 1) {
                        if push_type == "member_register" { MemberObject.waiting_step = 1 }
                        back_btn_hidden = true; self.segueViewController(identifier: "WaitingVC")
                    } else {
                        self.segueTabBarController(identifier: "ReMainTBC", idx: 0) { delegate in
//                            if push_type == "" {
//                                self.customAlert(message: "회원타입 에러: 도매자로 로그인 해주세요.", time: 1)
//                            }
                            if push_type != "" {
                                delegate.segueViewController(identifier: "NoticeVC")
                            }
                        }
                    }
                } else if MemberObject.member_type == "wholesales" {
                    if StoreObject.waiting_step == 0 || StoreObject.waiting_step == 1 {
                        if push_type == "member_register" { StoreObject.waiting_step = 1 }
                        back_btn_hidden = true; self.segueViewController(identifier: "WaitingVC")
                    } else if MemberObject.member_grade == "employee" && (MemberObject.waiting_step == 0 || MemberObject.waiting_step == 1) {
                        if push_type == "member_register" { MemberObject.waiting_step = 1 }
                        back_btn_hidden = true; self.segueViewController(identifier: "WaitingVC")
                    } else if StoreObject.waiting_step == 2 {
                        self.segueViewController(identifier: "WhHomeVC") { delegate in
                            if push_type == "enquiry" || push_type == "dpcost_request" {
                                self.customAlert(message: "회원타입 에러: 소매자로 로그인 해주세요.", time: 1)
                            } else if push_type != "" {
                                delegate?.segueViewController(identifier: push_type == "chats" ? "WhChatVC" : "NoticeVC")
                            }
                        }
//                    } else {
//                        back_btn_hidden = true
//                        /// 매장선택
//                        self.segueViewController(identifier: "ChoiceStoreVC")
                    }
                }; if push_type != "" { push_type.removeAll(); segue_type.removeAll() }; return
            case 500:
                self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
            default:
                self.customAlert(message: "로그인 실패", time: 1)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.segueViewController(identifier: "SignInVC")
            }
        }
        
//        var status_code: Int = 500
        /// request SignIn
//        requestSignIn { status in
//            /// response status
//            status_code = status
//            /// request ReMain
//            requestReMain { status in
//                /// response status
//                status_code = status
//                /// request all Category
//                requestCategory(action: ["color_category", "item_category", "size_category", "style_category", "material_category"]) { status in
//                    /// response status
//                    status_code = status
//                    self.customLoadingIndicator(animated: false)
//                    /// check error
//                    if status_code == 200 {
//                        if !store_index_select {
//                            back_btn_hidden = true
//                            self.segueViewController(identifier: "ChoiceStoreVC")
//                        } else if MemberObject.member_type == "retailseller" {
//                            self.segueTabBarController(identifier: "ReMainTBC", idx: 0)
//                        } else if MemberObject.member_type == "wholesales" {
////                            self.segueViewController(identifier: "WhHomeVC", animated: true)
//                        }; return
//                    } else if status_code == 204 {
//                        self.customAlert(message: "No data", time: 1)
//                    } else if status_code == 999 {
//                        self.customAlert(message: "Error occurred during data conversion", time: 1)
//                    } else {
//                        self.customAlert(message: "Internal server error", time: 1)
//                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
//                        self.segueViewController(identifier: "SignInVC")
//                    }
//                }
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

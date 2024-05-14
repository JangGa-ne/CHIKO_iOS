//
//  s_push.swift
//  market
//
//  Created by 장 제현 on 1/18/24.
//

import UIKit
import UserNotifications
import FirebaseMessaging

// MARK: PUSH 설정
extension UIViewController {
    
    func setLocalPush(title: String, body: String, userInfo: [String: Any] = [:]) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = userInfo
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "local_notification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        UserDefaults.standard.setValue(fcmToken ?? "", forKey: "fcm_id")
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: ["token": fcmToken ?? ""])
    }
    
    // PUSH(서스펜드) 누름
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        completionHandler(.newData)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // PUSH 받음
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        print("알림 받음 userNotificationCenter", userInfo)
        
        if let delegate = NoticeVCdelegate {
            delegate.loadingData()
        }
        
        if let delegate = ReHomeVCdelegate {
            delegate.noticeDot_v.isHidden = false
        }
        if let delegate = ReGoodsVCdelegate {
            delegate.noticeDot_v.isHidden = false
        }
        if let delegate = ReMyPageVCdelegate {
            delegate.noticeDot_v.isHidden = false
        }
        if let delegate = WhHomeVCdelegate {
            delegate.noticeDot_v.isHidden = false
        }
        
        completionHandler([.alert, .sound, .badge])
    }
    
    // PUSH(포그라운드) 누름
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print("알림 누름 userNotificationCenter", userInfo)
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        push_type = userInfo["type"] as? String ?? ""
        segue_type = userInfo["segue"] as? String ?? ""
        /// 로그인 정보 확인
//        if MemberObject.member_id == "", MemberObject.member_pw == "" {
//            if var window = UIApplication.shared.keyWindow?.rootViewController {
//                while let presentedViewController = window.presentedViewController {
//                    window = presentedViewController
//                }; window.customAlert(message: "로그인을 해주세요.", time: 1)
//            }
//        }
        if StoreObject.store_type == "retailseller", let delegate = ReMainTBCdelegate {
            delegate.segueViewController(identifier: "NoticeVC")
        } else if StoreObject.store_type == "wholesales", let delegate = WhHomeVCdelegate {
            delegate.segueViewController(identifier: "NoticeVC")
        }
                      
        completionHandler()
    }
}

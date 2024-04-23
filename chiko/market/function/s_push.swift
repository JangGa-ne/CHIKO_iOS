//
//  s_push.swift
//  market
//
//  Created by Busan Dynamic on 1/18/24.
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
}


// MARK: PUSH 알림 설정
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // PUSH 받음
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        print("알림 받음 userNotificationCenter", userInfo)
        
        completionHandler([.alert, .sound, .badge])
    }
    
    // PUSH(포그라운드) 누름
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print("알림 누름 userNotificationCenter", userInfo)
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        let push_type = userInfo["type"] as? String ?? ""
        
        DispatchQueue.main.async {
            if MemberObject.member_id == "", MemberObject.member_pw == "" {
                if var window = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = window.presentedViewController {
                        window = presentedViewController
                    }; window.customAlert(message: "로그인을 해주세요.", time: 1)
                }
            } else {
                
            }
        }
                      
        completionHandler()
    }
    
    // PUSH(서스펜드) 누름
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        completionHandler(.newData)
    }
}

//
//  appDelegate.swift
//  market
//
//  Created by 장 제현 on 2023/10/12.
//

/// APPLE ACCOUNT
/// ID: chikoddpmall@gmail.com
/// PW: Ehdeoans1!

import UIKit
import Nuke
import FirebaseCore
import FirebaseMessaging
import FirebaseFirestore

var system_language: String = ""
var system_country: String = ""
let dataCache = try? DataCache(name: "com.blink.dk.market2")

var priceFormatter: NumberFormatter = NumberFormatter()
var back_btn_hidden: Bool = false

var fcm_id: String = ""
var push_type: String = ""
var segue_type: String = ""

var platform_type: String = ""
var device_info: String = ""
var device_ratio: String = ""
var device_radius: CGFloat = 0.0
/// Register
var MemberObject_signup: MemberData = MemberData()
var StoreObject_signup: StoreData = StoreData()
var BuildingObject: BuildingData = BuildingData()
var BuildingArray: [String: [String: [String]]] = [:]
/// Common
var PaymentObject: PaymentData = PaymentData()
var MemberObject: MemberData = MemberData()
var StoreObject: StoreData = StoreData()
var StoreArray: [StoreData] = []
var store_index_select: Bool = false
var store_index: Int = 0
var CategoryObject: CategoryData = CategoryData()
var NoticeArray: [NoticeData] = []
var notice_read: Bool = true
/// Retailseller
var ReStoreArray_best: [(StoreObject: StoreData, GoodsObject: GoodsData)] = []
var ReGoodsArray_best: [GoodsData] = []
var ReGoodsArray_best2: [(title: String, ReGoodsArray_best: [GoodsData])] = []
var ReBasketArray: [BasketData] = []
/// Wholesales
var WhGoodsArray_realtime: [GoodsData] = []
var WhCountingObject: WhCountingData = WhCountingData()
var WhOrderArray: [WhOrderData] = []

var WaitingListener: ListenerRegistration? = nil
var ChatsListener: ListenerRegistration? = nil
var AdminListener: ListenerRegistration? = nil

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    var backSwipeGesture: Bool = false
    
    var member_type: String = ""
    var member_id: String = ""
    var member_pw: String = ""
       
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        system_language = getCurrentLanguage() ?? "ko-kr"; print("시스템언어", system_language)
        system_country = getCountryCallingCode() ?? "+82"; print("국가코드", system_country)
        
        memoryCheck()
        UIViewController.swizzleViewDidDisappear()
        // init
        priceFormatter.numberStyle = .decimal
        deviceInfo { ratio, device in
            platform_type = UIDevice.current.systemName
            device_info = device
            device_ratio = ratio
        }
        if device_ratio == "16:9" {
            device_radius = 5
        } else if device_ratio == "18:9" {
            device_radius = 30
        } else if device_ratio == "19:9" {
            device_radius = 50
        }
        /// AppVersion
        appVersion = Double(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") ?? 1.0
        appBuildCode = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1") ?? 1
        /// AppStoreVersion
        requestAppStoreVersion { status in
            
            if appBuildCode < storeBuildCode, PaymentVCdelegate == nil {
                
                let alert = UIAlertController(title: translation("앱 업데이트 알림"), message: translation("최신버전이 업데이트 되었습니다.\n업데이트 하시겠습니까?"), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: translation("업데이트"), style: .default, handler: { _ in
                    if let url = URL(string: storeUrl) { UIApplication.shared.open(url) }
                }))
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
        
        store_index_select = Bool(UserDefaults.standard.string(forKey: "store_index_select") ?? "false") ?? false
        store_index = UserDefaults.standard.integer(forKey: "store_index")
        /// Firebase init
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = false
        /// Notification Push init
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { didAllow, Error in
            if fcm_id == "" { Messaging.messaging().token { token, error in fcm_id = token ?? "" } }
        })
        application.registerForRemoteNotifications()
        /// first segue
        let segue = storyboard.instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
        let root = UINavigationController(rootViewController: segue)
        root.setNavigationBarHidden(true, animated: true)
        window?.rootViewController = root; window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        /// AppVersion
        appVersion = Double(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") ?? 1.0
        appBuildCode = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1") ?? 1
        /// AppStoreVersion
        requestAppStoreVersion { status in
            
            if appBuildCode < storeBuildCode, PaymentVCdelegate == nil {
                
                let alert = UIAlertController(title: translation("앱 업데이트 알림"), message: translation("최신버전이 업데이트 되었습니다.\n업데이트 하시겠습니까?"), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: translation("업데이트"), style: .default, handler: { _ in
                    if let url = URL(string: storeUrl) { UIApplication.shared.open(url) }
                }))
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
}


//
//  appDelegate.swift
//  market
//
//  Created by Busan Dynamic on 2023/10/12.
//

import UIKit
import Nuke
import FirebaseCore
import FirebaseMessaging

let dataCache = try? DataCache(name: "com.blink.dk.market2")

var priceFormatter: NumberFormatter = NumberFormatter()
var back_btn_hidden: Bool = false

var fcm_id: String = ""

var platform_type: String = ""
var device_info: String = ""
var device_ratio: String = ""
var divice_radius: CGFloat = 0.0
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
/// Retailseller
var ReStoreArray_best: [(StoreObject: StoreData, GoodsObject: GoodsData)] = []
var ReGoodsArray_best: [GoodsData] = []
var ReGoodsArray_best2: [(title: String, ReGoodsArray_best: [GoodsData])] = []
var ReBasketArray: [BasketData] = []
/// Wholesales
var WhGoodsArray_realtime: [GoodsData] = []
var WhCountingObject: WhCountingData = WhCountingData()
var WhOrderArray: [WhOrderData] = []

var push_type: String = ""

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    var backSwipeGesture: Bool = false
    
    var member_type: String = ""
    var member_id: String = ""
    var member_pw: String = ""
       
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
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
            divice_radius = 5
        } else if device_ratio == "18:9" {
            divice_radius = 30
        } else if device_ratio == "19:9" {
            divice_radius = 50
        }
        
        store_index_select = Bool(UserDefaults.standard.string(forKey: "store_index_select") ?? "false") ?? false
        store_index = UserDefaults.standard.integer(forKey: "store_index")
        /// Firebase init
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = false
        /// Notification Push init
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { didAllow, Error in })
        application.registerForRemoteNotifications()
        /// Category 요청
        requestCategory(action: ["color_category", "item_category", "size_category", "style_category", "material_category"]) { _ in }
        /// first segue
        let segue = storyboard.instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
        let root = UINavigationController(rootViewController: segue)
        root.setNavigationBarHidden(true, animated: true)
        window?.rootViewController = root; window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        window?.endEditing(true)
    }
}


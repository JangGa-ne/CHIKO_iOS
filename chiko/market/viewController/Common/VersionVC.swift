//
//  VersionVC.swift
//  market
//
//  Created by 장 제현 on 4/24/24.
//

import UIKit

var appVersion: Double = 0.0
var appBuildCode: Int = 0
var storeVersion: Double = 0.0
var storeUrl: String = ""
var storeBuildCode: Int = 0

class VersionVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var appVersion_label: UILabel!
    @IBOutlet weak var storeVersion_label: UILabel!
    @IBOutlet weak var openStore_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// AppStoreVersion
        requestAppStoreVersion { status in
            
            self.appVersion_label.text = "현재버전: \(appVersion) (\(appBuildCode))"
            self.storeVersion_label.text = "최신버전: \(storeVersion) (\(storeBuildCode))"
        }
        
        openStore_btn.isHidden = (appBuildCode >= storeBuildCode)
        openStore_btn.addTarget(self, action: #selector(openStore_btn(_:)), for: .touchUpInside)
    }
    
    @objc func openStore_btn(_ sender: UIButton) {
        if let url = URL(string: "") {
            UIApplication.shared.open(url) { success in if success { exit(0) } }
        } else {
            customAlert(message: "Internal server error", time: 1)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
    }
}

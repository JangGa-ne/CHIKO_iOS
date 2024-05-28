//
//  VersionVC.swift
//  market
//
//  Created by 장 제현 on 4/24/24.
//

/// 번역완료

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
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var appVersion_label: UILabel!
    @IBOutlet weak var storeVersion_label: UILabel!
    @IBOutlet weak var openStore_btn: UIButton!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in label.text = translation(label.text!) }
        buttons.forEach { btn in btn.setTitle(translation(btn.title(for: .normal)), for: .normal) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// AppStoreVersion
        requestAppStoreVersion { status in
            self.appVersion_label.text = "\(translation("현재버전:")) \(appVersion) (\(appBuildCode))"
            self.storeVersion_label.text = "\(translation("최신버전:")) \(storeVersion) (\(storeBuildCode))"
        }
        
        openStore_btn.isHidden = (appBuildCode >= storeBuildCode)
        openStore_btn.addTarget(self, action: #selector(openStore_btn(_:)), for: .touchUpInside)
    }
    
    @objc func openStore_btn(_ sender: UIButton) {
        if let url = URL(string: "https://apps.apple.com/us/app/chiko/id6499313211") {
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

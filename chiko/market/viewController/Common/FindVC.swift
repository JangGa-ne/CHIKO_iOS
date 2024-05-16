//
//  FindVC.swift
//  market
//
//  Created by 장 제현 on 5/9/24.
//

/// 번역완료

import UIKit

class FindVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBOutlet var labels: [UILabel]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var country_btn: UIButton!
    @IBOutlet weak var number_tf: UITextField!
    @IBOutlet weak var send_btn: UIButton!
    @IBOutlet weak var sign_tf: UITextField!
    @IBOutlet weak var submit_btn: UIButton!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in label.text = translation(label.text!) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        country_btn.addTarget(self, action: #selector(country_btn(_:)), for: .touchUpInside)
    }
    
    @objc func country_btn(_ sender: UIButton) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

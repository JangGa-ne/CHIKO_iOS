//
//  VirtualVC.swift
//  market
//
//  Created by Busan Dynamic on 5/23/24.
//

import UIKit

class VirtualVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var type: String = ""               // 결제타입(상품, 물류)
    var item_name: String = ""
    var cny_cash: String = ""
    
    @IBOutlet var labels: [UILabel]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

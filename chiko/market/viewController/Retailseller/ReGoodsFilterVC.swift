//
//  ReGoodsFilterVC.swift
//  market
//
//  Created by 장 제현 on 12/11/23.
//

import UIKit

class ReGoodsFilterVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        ReGoodsFilterVCdelegate = self
    }
}

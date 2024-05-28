//
//  s_base.swift
//  market
//
//  Created by 장 제현 on 2023/10/16.
//

import UIKit

extension UIViewController {
    
    static func swizzleViewDidDisappear() {
        let originalSelector = #selector(UIViewController.viewDidDisappear(_:))
        let swizzledSelector = #selector(UIViewController.swizzledViewDidDisappear(_:))
        
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else {
            return
        }
        
        let didAddMethod = class_addMethod(UIViewController.self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(UIViewController.self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    @objc func swizzledViewDidDisappear(_ animated: Bool) {
        swizzledViewDidDisappear(animated)
        
        memoryCheck(delete: true)
    }
}

extension UITableViewCell {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
}

class FetchingMoreTC: UITableViewCell {
    
    @IBOutlet weak var fetchingMore_indicatorView: UIActivityIndicatorView!
}

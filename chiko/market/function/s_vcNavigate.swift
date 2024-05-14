//
//  s_vcNavigate.swift
//  market
//
//  Created by 장 제현 on 2023/10/16.
//

import UIKit

extension UIViewController {
    
    func segueTabBarController(identifier: String, idx: Int, animated: Bool = true, completion: ((UITabBarController) -> Void)? = nil) {
        /// hidden keyboard
        view.endEditing(true)
        
        let tabBarController = storyboard?.instantiateViewController(withIdentifier: identifier) as! UITabBarController
        tabBarController.selectedIndex = idx
        navigationController?.pushViewController(tabBarController, animated: animated)
        
        completion?(tabBarController)
    }
    
    func segueViewController(identifier: String, animated: Bool = true, completion: ((UIViewController?) -> Void)? = nil) {
        /// hidden keyboard
        view.endEditing(true)
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: identifier)
        navigationController?.pushViewController(viewController!, animated: animated)
        
        completion?(viewController)
    }
}

extension UIViewController: UIGestureRecognizerDelegate {
    
    func setBackSwipeGesture(_ bool: Bool) {
        appDelegate.backSwipeGesture = bool
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        return appDelegate.backSwipeGesture
    }
}

extension UINavigationController {

    public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        CATransaction.begin(); CATransaction.setCompletionBlock(completion); pushViewController(viewController, animated: animated); CATransaction.commit()
    }
    
    public func popViewController(animated: Bool, completion: (() -> Void)? = nil) {
        CATransaction.begin(); CATransaction.setCompletionBlock(completion); popViewController(animated: animated); CATransaction.commit()
    }
}




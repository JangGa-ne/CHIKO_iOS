//
//  s_keyboard.swift
//  market
//
//  Created by 장 제현 on 2023/07/24.
//

import UIKit

extension UIViewController: UITextFieldDelegate {
    
    func setKeyboard() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
/// 키보드 나타남
    @objc func showKeyboard(_ sender: Notification) {
        
        let s = sender.userInfo![UIResponder.keyboardFrameEndUserInfoKey]
        let rect = (s! as AnyObject).cgRectValue

        let keyboardFrameEnd = view!.convert(rect!, to: nil)
        view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: keyboardFrameEnd.origin.y)
        view.layoutIfNeeded()
    }
    
/// 키보드 사라짐
    @objc func hideKeyboard(_ sender: Notification) {
        
        let s = sender.userInfo![UIResponder.keyboardFrameBeginUserInfoKey]
        let rect = (s! as AnyObject).cgRectValue
        
        let keyboardFrameEnd = view!.convert(rect!, to: nil)
        view.frame = CGRect(x: view.bounds.origin.x, y: view.bounds.origin.y, width: view.bounds.width, height: view.bounds.height + keyboardFrameEnd.size.height)
        view.layoutIfNeeded()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done { textField.resignFirstResponder() }; return true
    }
    
    func hideKeyboardWhenTappedAround(_ view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) { view.endEditing(true) }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        /// hidden keyboard
        view.endEditing(true)
    }
    
    @objc func scrollView(_ sender: UITapGestureRecognizer) {
        /// hidden keyboard
        view.endEditing(true)
    }
}

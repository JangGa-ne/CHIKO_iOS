//
//  s_text.swift
//  market
//
//  Created by Busan Dynamic on 2023/07/21.
//

import UIKit

extension UILabel {
    
    func padding(_ insets: UIEdgeInsets) {
        
        let paddingView = UIView()
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(paddingView)
        
        NSLayoutConstraint.activate([
            paddingView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            paddingView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
            paddingView.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            paddingView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom)
        ])
        
        sendSubviewToBack(paddingView)
    }
}

func stringWidth(text: String, fontName: String = "", fontSize: CGFloat = 14, fontWeight: UIFont.Weight = .regular) -> CGFloat {
    if fontName == "" {
        return NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize, weight: fontWeight)]).size().width
    } else {
        return NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont(name: fontName, size: fontSize) ?? UIFont()]).size().width
    }
}

extension UITextField {
    
    func paddingLeft(_ x: CGFloat) {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: x, height: frame.height)); leftViewMode = ViewMode.always
    }
    
    func paddingRight(_ x: CGFloat) {
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: x, height: frame.height)); rightViewMode = ViewMode.always
    }
    
    func placeholder(text: String, color: UIColor) {
        attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: color])
    }
    
    func removeSpecialChars() {
        text = text!.filter { Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890_").contains($0) }
    }
}

extension UITextView {
    
    func lineHeight() {
        let size = sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
        contentOffset.y = -max(0, (bounds.size.height - size.height * zoomScale) / 2)
    }
}

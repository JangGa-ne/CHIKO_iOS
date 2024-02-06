//
//  s_text.swift
//  market
//
//  Created by Busan Dynamic on 2023/07/21.
//

import UIKit

func stringWidth(text: String, fontName: String = "", fontSize: CGFloat = 14, fontWeight: UIFont.Weight = .regular) -> CGFloat {
    if fontName == "" {
        return NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize, weight: fontWeight)]).size().width
    } else {
        return NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont(name: fontName, size: fontSize) ?? UIFont()]).size().width
    }
}

extension UIButton {
    
    func padding(_ padding: UIEdgeInsets) {
        contentEdgeInsets = UIEdgeInsets(
            top: contentEdgeInsets.top + padding.top,
            left: contentEdgeInsets.left + padding.left,
            bottom: contentEdgeInsets.bottom + padding.bottom,
            right: contentEdgeInsets.right + padding.right
        )
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

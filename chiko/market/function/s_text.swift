//
//  s_text.swift
//  market
//
//  Created by 장 제현 on 2023/07/21.
//

import UIKit

func translation(_ string: String?) -> String {
    return NSLocalizedString(string ?? "", comment: "")
}

func getCurrentLanguage() -> String? {
    if #available(iOS 16.0, *), let preferredLanguage = Locale.current.language.languageCode?.identifier {
        return preferredLanguage
    } else if let preferredLanguage = Locale.current.languageCode {
        return preferredLanguage
    } else {
        return nil
    }
}

func getCountryCallingCode() -> String? {
    
    let countryCallingCodes: [String: String] = [
        "en": "1",   // 미국
        "ko": "82",  // 대한민국
        "zh": "86",  // 중국
    ]
    
    guard let currentLocale = Locale.current.languageCode else { return nil }
    guard let callingCode = countryCallingCodes[currentLocale] else { return nil }
    
    return "+\(callingCode)"
}

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

func attributedPriceString(krw: Int, cny: Double, fontSize: CGFloat = 16) -> NSAttributedString {
    
    let priceString = NSMutableAttributedString()
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    
    priceString.append(NSAttributedString(string: "₩\(numberFormatter.string(from: krw as NSNumber) ?? "0") / ", attributes: [
        .font: UIFont.systemFont(ofSize: fontSize)
    ]))
    
    numberFormatter.maximumFractionDigits = 2
    priceString.append(NSAttributedString(string: "¥\(numberFormatter.string(from: cny as NSNumber) ?? "0")", attributes: [
        .font: UIFont.boldSystemFont(ofSize: fontSize)
    ]))
    
    return priceString
}

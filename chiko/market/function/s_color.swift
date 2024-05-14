//
//  s_color.swift
//  market
//
//  Created by 장 제현 on 2023/10/16.
//

import UIKit

extension UIColor {
    
    static let H_8CD26B = UIColor(red: 140/255, green: 210/255, blue: 107/255, alpha: 1.0)
    
    static let H_F2F2F7 = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
    static let H_F4F4F4 = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
    
    public convenience init?(hex: String, alpha: CGFloat = 1.0) {
        
        if hex.hasPrefix("#") {
            
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    
                    let r, g, b: CGFloat
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: alpha)
                    
                    return
                }
            }
        }

        return nil
    }
    
    var brightness: CGFloat {
        var brightness: CGFloat = 0.0
        getRed(nil, green: nil, blue: nil, alpha: &brightness)
        return brightness
    }
}

func isDarkBackground(color: UIColor) -> Bool {
    
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 0.0
    
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    let brightness = 0.299 * red + 0.587 * green + 0.114 * blue
    let threshold: CGFloat = 0.5
    
    return brightness < threshold
}

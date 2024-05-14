//
//  s_device.swift
//  market
//
//  Created by 장 제현 on 10/24/23.
//

import UIKit

func deviceIdentifier() -> String {
    
    var systemInfo = utsname(); uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    return identifier
}

func deviceInfo(completionHandler: @escaping ((String, String) -> Void)) {
    
    let device = UIDevice.current
    
    var model_ratio: String = ""
    var model_name: String = ""
    
    switch deviceIdentifier() {
        
    case "iPhone16,2":                              model_ratio = "19:9"; model_name = "iPhone 15 Pro Max"
    case "iPhone16,1":                              model_ratio = "19:9"; model_name = "iPhone 15 Pro"
    case "iPhone15,5":                              model_ratio = "19:9"; model_name = "iPhone 15 Plus"
    case "iPhone15,4":                              model_ratio = "19:9"; model_name = "iPhone 15"
        
    case "iPhone15,3":                              model_ratio = "19:9"; model_name = "iPhone 14 Pro Max"
    case "iPhone15,2":                              model_ratio = "19:9"; model_name = "iPhone 14 Pro"
    case "iPhone14,8":                              model_ratio = "18:9"; model_name = "iPhone 14 Plus"
    case "iPhone14,7":                              model_ratio = "18:9"; model_name = "iPhone 14"
    
    case "iPhone14,6":                              model_ratio = "16:9"; model_name = "iPhone SE (3G)"
    
    case "iPhone14,3":                              model_ratio = "18:9"; model_name = "iPhone 13 Pro Max"
    case "iPhone14,2":                              model_ratio = "18:9"; model_name = "iPhone 13 Pro"
    case "iPhone14,5":                              model_ratio = "18:9"; model_name = "iPhone 13"
    case "iPhone14,4":                              model_ratio = "18:9"; model_name = "iPhone 13 Mini"
    
    case "iPhone13,4":                              model_ratio = "18:9"; model_name = "iPhone 12 Pro Max"
    case "iPhone13,3":                              model_ratio = "18:9"; model_name = "iPhone 12 Pro"
    case "iPhone13,2":                              model_ratio = "18:9"; model_name = "iPhone 12"
    case "iPhone13,1":                              model_ratio = "18:9"; model_name = "iPhone 12 Mini"
    
    case "iPhone12,8":                              model_ratio = "16:9"; model_name = "iPhone SE (2G)"
    
    case "iPhone12,5":                              model_ratio = "18:9"; model_name = "iPhone 11 Pro Max"
    case "iPhone12,3":                              model_ratio = "18:9"; model_name = "iPhone 11 Pro"
    case "iPhone12,1":                              model_ratio = "18:9"; model_name = "iPhone 11"
    
    case "iPhone11,8":                              model_ratio = "18:9"; model_name = "iPhone XR"
    case "iPhone11,4", "iPhone11,6":                model_ratio = "18:9"; model_name = "iPhone XS Max"
    case "iPhone11,2":                              model_ratio = "18:9"; model_name = "iPhone XS"
    
    case "iPhone10,3", "iPhone10,6":                model_ratio = "18:9"; model_name = "iPhone X"
        
    default: model_ratio = "16:9"; model_name = "N/A"
        
    }
    
    completionHandler(model_ratio, "시스템명: \(device.systemName) / 디바이스명: \(device.name) / 모델명: \(model_name) / HW버전: \(deviceIdentifier()) / SW버전: ios\(device.systemVersion) / 화면비율: \(model_ratio)")
}


//
//  s_regularExpression.swift
//  market
//
//  Created by Busan Dynamic on 2023/10/19.
//

import UIKit

func isChinesePhoneNumValid(_ phoneNum: String) -> Bool {
    return NSPredicate(format: "SELF MATCHES %@", "^1[3-9]{9}$").evaluate(with: phoneNum)
}

func isPasswordValid(_ password: String) -> Bool {
    return NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[^a-zA-Z\\d]).{8,15}$").evaluate(with: password)
}

func isEmailValid(_ email: String) -> Bool {
    return NSPredicate(format: "SELF MATCHES %@", "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$").evaluate(with: email)
}

func isChineseBusinessRegNumValid(_ businessRegNum: String) -> Bool {
    return NSPredicate(format: "SELF MATCHES %@", "^[0-9A-Z]{18}$").evaluate(with: businessRegNum)
}

func isChineseTelNumValid(_ phoneNum: String) -> Bool {
    return NSPredicate(format: "SELF MATCHES %@", "^(0\\d{2,3}\\d{7,8}|(400|800)\\d{7})$").evaluate(with: phoneNum)
}

func isUrlValid(_ url: String) -> Bool {
    return NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$").evaluate(with: url)
}

func isChineseAccountNumValid(_ accountNum: String) -> Bool {
    return NSPredicate(format: "SELF MATCHES %@", "^\\d{16,19}$").evaluate(with: accountNum)
}

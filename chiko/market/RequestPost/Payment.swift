//
//  Payment.swift
//  market
//
//  Created by Busan Dynamic on 3/7/24.
//

import UIKit
import Alamofire

func requestExchangeRate() {
    
}

func requestPayment(params: [String: Any], completionHandler: ((String, Int) -> Void)?) {
    /// x-www-form-urlencoded
    AF.request(requestPaymentUrl, method: .post, parameters: params, encoding: URLEncoding.default).responseString { response in
        switch response.result {
        case .success(let responseHtml):
            print(responseHtml)
            completionHandler?(responseHtml, 200)
        case .failure(let error):
            print(error as Any)
            completionHandler?("", response.error?.responseCode ?? 500)
        }
    }
}

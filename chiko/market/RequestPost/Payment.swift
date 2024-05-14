//
//  Payment.swift
//  market
//
//  Created by 장 제현 on 3/7/24.
//

import UIKit
import Alamofire

func requestExchangeRate(completionHandler: @escaping (Int) -> Void) {
    
    let params: Parameters = [
        "collection_id": "admin_data",
        "document_id": "price_info",
    ]
    
    params.forEach { dict in print(dict) }
    ///
    AF.request(requestUrl+"/get_db", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                let data = responseJson["data"] as? [String: Any] ?? nil
                if data != nil {
                    PaymentObject = setPayment(paymentDict: data ?? [:])
                    completionHandler(200)
                } else {
                    completionHandler(204)
                }
            } else {
                completionHandler(600)
            }
        } catch {
            print(response.error as Any)
            completionHandler(response.error?.responseCode ?? 500)
        }
    }
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

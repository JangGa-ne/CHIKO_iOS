//
//  MPay.swift
//  market
//
//  Created by Busan Dynamic on 2/29/24.
//

import UIKit
import Alamofire

func requestMPay(completionHandler: ((Int) -> Void)?) {
    
    let params: Parameters = [
        "action": "get",
        "store_id": StoreObject.store_id,
    ]
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/mpay", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                if let data = responseJson["data"] as? [String: Any] {
                    StoreObject.store_cash = data["store_cash"] as? Int ?? 0
                    completionHandler?(200)
                } else {
                    completionHandler?(204)
                }
            } else {
                completionHandler?(600)
            }
        } catch {
            print(response.error as Any)
            completionHandler?(response.error?.responseCode ?? 500)
        }
    }
}

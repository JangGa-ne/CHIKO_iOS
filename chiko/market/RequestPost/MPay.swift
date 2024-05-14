//
//  MPay.swift
//  market
//
//  Created by 장 제현 on 2/29/24.
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

func requestMPayList(completionHandler: @escaping (([StoreCashData], Int) -> Void)) {
    
    let params: Parameters = [
        "action": "get_list",
        "store_id": StoreObject.store_id,
    ]
    
    var StoreCashArray: [StoreCashData] = []
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/mpay", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                let array = responseJson["data"] as? Array<[String: Any]> ?? []
                array.forEach { dict in
                    /// 데이터 추가
                    StoreCashArray.append(setStoreCash(storeCashDict: dict))
                }
                
                StoreObject.store_cash = responseJson["store_cash"] as? Int ?? 0
                
                if array.count > 0 {
                    completionHandler(StoreCashArray, 200)
                } else {
                    completionHandler([], 204)
                }
            } else {
                completionHandler([], 600)
            }
        } catch {
            print(response.error as Any)
            completionHandler([], response.error?.responseCode ?? 500)
        }
    }
}

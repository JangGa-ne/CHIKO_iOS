//
//  ReOrder.swift
//  market
//
//  Created by Busan Dynamic on 2/21/24.
//

import UIKit
import Alamofire

func requestReOrder(action: String, completionHandler: @escaping (Int) -> Void) {
    
    let params: Parameters = [
        "action": "find_order",
        "store_id": StoreObject.store_id,
    ]
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/order", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                let array = responseJson["data"] as? Array<[String: Any]> ?? []
                array.forEach { dict in
                    /// 데이터 추가
                    if MemberObject.member_type == "retailseller" {
                        ReOrderArray.append(setReOrder(orderDict: dict))
                    } else if MemberObject.member_type == "wholesales" {
//                        WhOrderArray.append()
//                        WhOrderArray.sort { $0.order_datetime > $1.order_datetime }
                    }
                }
                
                if array.count > 0 {
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

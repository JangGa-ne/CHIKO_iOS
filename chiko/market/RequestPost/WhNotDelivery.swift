//
//  WhNotDelivery.swift
//  market
//
//  Created by 장 제현 on 2/21/24.
//

import UIKit
import Alamofire

func requestWhNotDelivery(type: String = "date", parameters: [String: Any]? = nil, completionHandler: @escaping ([WhNotDeliveryData], Int) -> Void) {
    
    var params: Parameters = [
        "store_id": StoreObject.store_id,
    ]
    if parameters == nil {
        params["action"] = "get"
        params["store_id"] = StoreObject.store_id
        params["type"] = type
    } else {
        params = parameters ?? [:]
        params["action"] = "set"
        params["store_id"] = StoreObject.store_id
    }
    
    params.forEach { dict in print(dict) }
    
    var WhNotDeliveryArray: [WhNotDeliveryData] = []
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/not_delivery", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                if parameters == nil {
                    let array = responseJson["data"] as? Array<[[String: Any]]> ?? []
                    array.forEach { array in
                        array.forEach { dict in
                            /// 데이터 추가
                            WhNotDeliveryArray.append(setWhNotDelivery(notDeliveryDict: dict))
                        }
                    }
                } else {
                    let array = responseJson["data"] as? Array<[String: Any]> ?? []
                    array.forEach { dict in
                        /// 데이터 추가
                        WhNotDeliveryArray.append(setWhNotDelivery(notDeliveryDict: dict))
                    }
                }
                
                if WhNotDeliveryArray.count > 0 {
                    completionHandler(WhNotDeliveryArray, 200)
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

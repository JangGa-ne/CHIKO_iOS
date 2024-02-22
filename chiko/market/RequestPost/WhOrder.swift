//
//  WhOrder.swift
//  market
//
//  Created by Busan Dynamic on 2/21/24.
//

import UIKit
import Alamofire

func requestWhOrder(completionHandler: @escaping ([WhOrderData], Int) -> Void) {
    
    let params: Parameters = [
        "action": "get",
        "store_id": StoreObject.store_id,
    ]
    
    var WhOrderArray: [WhOrderData] = []
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/order_batch_processing", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                let array = responseJson["data"] as? Array<[[String: Any]]> ?? []
                array.forEach { array in
                    array.forEach { dict in
                        /// 데이터 추가
                        WhOrderArray.append(setWhOrder(orderDict: dict))
                    }
                }
                
                if WhOrderArray.count > 0 {
                    completionHandler(WhOrderArray, 200)
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


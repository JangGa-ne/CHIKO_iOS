//
//  WhGoods.swift
//  market
//
//  Created by 장 제현 on 2/21/24.
//

import UIKit
import Alamofire

func requestWhGoods(item_disclosure: String, item_key: String = "0", limit: Int = 99999, completionHandler: @escaping ([GoodsData], Int) -> Void) {
    
    let params: Parameters = [
        "action": "mylist",
        "store_id": StoreObject.store_id,
        "filter": "최신순",
        "item_disclosure": item_disclosure,
        "item_key": item_key,
        "limit": limit,
    ]
    
    var GoodsArray: [GoodsData] = []
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/goods", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                let array = responseJson["data"] as? Array<Any> ?? []
                array.forEach { data in
                    /// 데이터 추가
                    GoodsArray.append(setGoods(goodsDict: data as? [String: Any] ?? [:]))
                }
                if GoodsArray.count > 0 {
                    completionHandler(GoodsArray, 200)
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

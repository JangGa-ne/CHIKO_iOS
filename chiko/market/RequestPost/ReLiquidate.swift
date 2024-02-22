//
//  ReLiquidate.swift
//  market
//
//  Created by Busan Dynamic on 2/21/24.
//

import UIKit
import Alamofire

func requestReLiquidate(LiquidateArray: [BasketData], payment_type: String, completionHandler: @escaping (Int) -> Void) {
    
    let timestamp: Int64 = setGMTUnixTimestamp()
    var params: Parameters = [
        "action": "order_list",
        "cn_total_item_price": 0,
        "kr_total_item_price": 0,
        "vat_total_price": 0,
        "delivery_nickname": StoreObject.store_delivery[StoreObject.store_delivery_position].nickname,
        "delivery_address": StoreObject.store_delivery[StoreObject.store_delivery_position].address,
        "delivery_address_detail": StoreObject.store_delivery[StoreObject.store_delivery_position].address_detail,
        "delivery_name": StoreObject.store_delivery[StoreObject.store_delivery_position].name,
        "delivery_num": StoreObject.store_delivery[StoreObject.store_delivery_position].num,
        "order_store_name": StoreObject.store_name,
        "order_store_id": StoreObject.store_id,
        "order_id": MemberObject.member_id,
        "order_name": MemberObject.member_name,
        "order_position": MemberObject.member_grade,
        "order_num": MemberObject.member_num,
        "order_key": "or\(timestamp)",
        "order_datetime": String(timestamp),
        "order_memo": "",
        "order_state": "결제완료",
        "payment_type": payment_type,
        "receipt_key": "rc\(timestamp)",
    ]
    
    var order_item: Array<[String: Any]> = []
    LiquidateArray.enumerated().forEach { i, data in
        
        var item_option: Array<[String: Any]> = []
        data.item_option.forEach { data in
            item_option.append([
                "color": data.color,
                "price": data.price,
                "quantity": data.quantity,
                "size": data.size,
                "sold_out": String(data.sold_out)
            ])
        }
        
        order_item.append([
            "item_price": data.item_price,
            "item_key": data.item_key,
            "item_name": data.item_name,
            "item_mainphoto_img": data.item_mainphoto_img,
            "item_option": item_option,
            "item_sale": String(data.item_sale),
            "item_sale_price": data.item_sale_price,
            "item_total_price": data.item_total_price,
            "item_total_quantity": data.item_total_quantity,
            "store_id": data.wh_store_id,
            "store_name": data.store_name,
            "store_name_eng": data.store_name_eng,
            "delivery_state": "상품준비중",
            "order_detail_key": "or\(timestamp)_\(i)",
        ])
    }
    params["order_item"] = order_item
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/order", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                if let dict = responseJson["data"] as? [String: Any] {
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

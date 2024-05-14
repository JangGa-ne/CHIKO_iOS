//
//  ReLiquidate.swift
//  market
//
//  Created by 장 제현 on 2/21/24.
//

import UIKit
import Alamofire

func requestReLiquidate(receipt_mode: Bool, LiquidateArray: [BasketData], store_delivery_position: Int, timestamp: Int64, payment_type: String, kr_order_total: Int, completionHandler: @escaping (Int) -> Void) {
    
    let delivery_data = StoreObject.store_delivery[store_delivery_position]
    let store_data = StoreObject
    let member_data = MemberObject
    
    var params: Parameters = [
        "ch_total_item_price": (Double(kr_order_total)/PaymentObject.exchange_rate*100).rounded()/100,
        "kr_total_item_price": kr_order_total,
        "delivery_nickname": delivery_data.nickname,
        "delivery_address": delivery_data.address,
        "delivery_address_detail": delivery_data.address_detail,
        "delivery_name": delivery_data.name,
        "delivery_num": delivery_data.num,
        "order_store_id": store_data.store_id,
        "order_store_name": store_data.store_name,
        "order_store_name_eng": store_data.store_name_eng,
        "order_key": "or\(timestamp)",
        "order_id": member_data.member_id,
        "order_name": member_data.member_name,
        "order_position": member_data.member_grade,
        "order_num": member_data.member_num,
        "order_datetime": String(timestamp),
        "order_memo": "",
        "order_state": "상품준비중",
        "payment_type": payment_type,
        "gdre_key": "gdre\(timestamp)",
    ]
    
    params["action"] = receipt_mode ? "enquiry_order_list" : "order_list"
    
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

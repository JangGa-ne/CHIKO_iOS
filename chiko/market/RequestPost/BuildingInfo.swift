//
//  BuildingInfo.swift
//  market
//
//  Created by 장 제현 on 2/21/24.
//

import UIKit
import Alamofire

func requestBuildingInfo(completionHandler: @escaping (Int) -> Void) {
    
    let params: Parameters = [
        "action": "get_building",
    ]
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/building_info", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                let array = responseJson["data"] as? Array<[String: Any]> ?? []
                
                let buildingValue = BuildingData()
                array.forEach { dict in
                    
                    let building_name = dict["building_name"] as? String ?? ""
                    buildingValue.building_name.append(building_name)
                    
                    (dict["building_info"] as? [String: Any] ?? [:]).forEach { dict in
                        
                        let building_floor = dict.key
                        buildingValue.building_floor.append("\(building_name)/\(building_floor)")
                        
                        (dict.value as? Array<[String: Any]> ?? []).forEach { dict in
                            if dict["store_name"] as? String ?? "" == "" {
                                
                                let building_room = dict["building_num"] as? String ?? ""
                                buildingValue.building_room.append("\(building_name)/\(building_floor)/\(building_room)")
                            }
                        }
                    }
                }
                /// 데이터 추가
                BuildingObject = buildingValue
                
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

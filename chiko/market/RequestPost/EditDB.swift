//
//  EditDB.swift
//  market
//
//  Created by 장 제현 on 2/21/24.
//

import UIKit
import Alamofire

func requestEditDB(params: [String: Any], completionHandler: @escaping (Int) -> Void) {
    
    params.forEach { dict in print(dict) }
    
    AF.request(requestUrl+"/edit_db", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
                print(responseJson)
                completionHandler(200)
            } else {
                completionHandler(600)
            }
        } catch {
            print(response.error as Any)
            completionHandler(response.error?.responseCode ?? 500)
        }
    }
}

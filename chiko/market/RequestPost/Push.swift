//
//  Push.swift
//  market
//
//  Created by Busan Dynamic on 2/23/24.
//

import UIKit
import Alamofire

func requestPush(params: [String: Any], completionHandler: ((Int) -> Void)?) {
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/send_datapush", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                completionHandler?(200)
            } else {
                completionHandler?(600)
            }
        } catch {
            print(response.error as Any)
            completionHandler?(response.error?.responseCode ?? 500)
        }
    }
}

//
//  ReEnquiryReceipt.swift
//  market
//
//  Created by Busan Dynamic on 2/21/24.
//

import UIKit
import Alamofire
import Nuke
import SDWebImage

func requestReEnquiryReceipt(parameters: [String: Any]? = nil, completionHandler: @escaping ([(store_name: String, summary_address: String, timestamp: String, data: [ReEnquiryReceiptData])], String, Int) -> Void) {
    
    var params: Parameters = [:]
    
    if parameters == nil {
        params["action"] = "get"
        params["store_id"] = StoreObject.store_id
    } else {
        params = parameters ?? [:]
        params["action"] = "set"
        params["store_id"] = StoreObject.store_id
    }
    
    params.forEach { data in print(data) }
    
    var ReEnquiryReceiptArray: [(store_name: String, summary_address: String, timestamp: String, data: [ReEnquiryReceiptData])] = []
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/enquiry", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                let array = responseJson["data"] as? Array<[[String: Any]]> ?? []
                array.forEach { array in
                    
                    var store_name: String = ""
                    var summary_address: String = ""
                    var timestamp: String = ""
                    var EnquiryReceiptArray: [ReEnquiryReceiptData] = []
                    
                    array.enumerated().forEach { i, dict in
                        
                        if i == 0 {
                            store_name = dict["requested_store_name"] as? String ?? ""
                            summary_address = dict["summary_address"] as? String ?? ""
                            timestamp = dict["time"] as? String ?? ""
                        }
                        EnquiryReceiptArray.append(setReEnquiryReceipt(enquiryReceiptDict: dict))
                    }
                    /// 데이터 추가
                    ReEnquiryReceiptArray.append((store_name: store_name, summary_address: summary_address, timestamp: timestamp, data: EnquiryReceiptArray))
                }
                
                let fcm_id = responseJson["fcm_id"] as? String ?? ""
                
                if ReEnquiryReceiptArray.count > 0 {
                    completionHandler(ReEnquiryReceiptArray, fcm_id, 200)
                } else {
                    completionHandler([], "", 204)
                }
            } else {
                completionHandler([], "", 600)
            }
        } catch {
            print(response.error as Any)
            completionHandler([], "", response.error?.responseCode ?? 500)
        }
    }
}

func requestEnquiryFileUpload(action: String, enquiry_time: String, comment_time: String, file_data: [(field_name: String, file_name: String, file_data: Data, file_size: Int)], file_index: Int = 0, first: Bool = true, completionHandler: @escaping (([(store_name: String, summary_address: String, timestamp: String, data: [ReEnquiryReceiptData])], Int) -> Void)) {
    /// limit upload data
    var upload_size: Int = 0
    var upload_index: Int = file_index
    var upload_data: [(field_name: String, file_name: String, file_data: Data, file_size: Int)] = []
    for i in upload_index ..< file_data.count { upload_size += file_data[i].file_size; upload_data.append(file_data[i]); upload_index += 1
        if (upload_size > 26214400) { break }
    }
    
    let params: Parameters = [
        "action": action,
        "collection_id": "enquiry_history",
        "document_id": StoreObject.store_id,
        "enquiry_time": enquiry_time,
        "comment_time": comment_time,
        "first": String(first),
    ]
    
    params.forEach { data in print(data) }
    upload_data.forEach { data in print(data) }
    
    var ReEnquiryReceiptArray: [(store_name: String, summary_address: String, timestamp: String, data: [ReEnquiryReceiptData])] = []
    /// multipart/form-data
    AF.upload(multipartFormData: { formData in
        /// string
        params.forEach { (key: String, value: Any) in
            if let value = "\(value)".data(using: .utf8) { formData.append(value, withName: key) }
        }
        /// data
        upload_data.forEach { (field_name: String, file_name: String, file_data: Data, file_size: Int) in
            if !field_name.contains("_imgs") {
                formData.append(file_data, withName: field_name, fileName: field_name, mimeType: file_name.mimeType())
            } else {
                let index: String = field_name.components(separatedBy: "_imgs")[1]
                formData.append(file_data, withName: field_name, fileName: index, mimeType: file_name.mimeType())
            }
        }
    }, to: requestUrl+"/enquiry_file_upload", method: .post)
    .uploadProgress { progress in
        print(progress.fractionCompleted)
    }
    .responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                if (file_data.count > upload_index+1) {
                    requestEnquiryFileUpload(action: action, enquiry_time: enquiry_time, comment_time: comment_time, file_data: file_data, file_index: upload_index, first: false) { _, status in
                        completionHandler([], status)
                    }
                } else {
                    
                    let array = responseJson["data"] as? Array<[[String: Any]]> ?? []
                    array.forEach { array in
                        
                        var store_name: String = ""
                        var summary_address: String = ""
                        var timestamp: String = ""
                        var EnquiryReceiptArray: [ReEnquiryReceiptData] = []
                        
                        array.enumerated().forEach { i, dict in
                            
                            if i == 0 {
                                store_name = dict["requested_store_name"] as? String ?? ""
                                summary_address = dict["summary_address"] as? String ?? ""
                                timestamp = dict["time"] as? String ?? ""
                            }
                            EnquiryReceiptArray.append(setReEnquiryReceipt(enquiryReceiptDict: dict))
                        }
                        /// 데이터 추가
                        ReEnquiryReceiptArray.append((store_name: store_name, summary_address: summary_address, timestamp: timestamp, data: EnquiryReceiptArray))
                    }
                    
                    if ReEnquiryReceiptArray.count > 0 {
                        completionHandler(ReEnquiryReceiptArray, 200)
                    } else {
                        completionHandler([], 204)
                    }
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

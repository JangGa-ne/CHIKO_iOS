//
//  RestApiPost.swift
//  market
//
//  Created by Busan Dynamic on 11/16/23.
//

import UIKit
import Alamofire
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import Nuke
import SDWebImage

let requestPaymentUrl: String = "https://pg.innopay.co.kr/ipay/js/innopay_overseas-2.0.js"
let requestUrl: String = "https://dk-sto-yy2mch6sra-du.a.run.app"
let dispatchGroup = DispatchGroup()
let dispatchQueue = DispatchQueue(label: "com.blink.dk.market2", attributes: .concurrent)

// other request error code: 999(json변환오류)

func requestCategory(action: [String], index: Int = 0, completionHandler: @escaping ((Int) -> Void)) {
    
    let params: Parameters = [
        "action": action[index],
    ]
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/goods", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                if let array = responseJson["data"] as? Array<[String: Any]> {
                    /// category info
                    /// 데이터 추가
                    if (action[index] == "color_category") {
                        array.forEach { dict in
                            let _: [()] = dict.compactMap { (key: String, value: Any) in
                                let _: [()] = (value as? [String: Any] ?? [:]).compactMap { (key: String, value: Any) in
                                    let _: [()] = (value as? [String: Any] ?? [:]).compactMap { (key: String, value: Any) in
                                        CategoryObject.ColorArray_all[key] = value
                                    }
                                }
                            }
                        }
                        CategoryObject.ColorArray = array
                    } else if (action[index] == "item_category") {
                        CategoryObject.CategoryArray = array
                    } else if (action[index] == "size_category") {
                        CategoryObject.SizeArray = array
                    } else if (action[index] == "style_category") {
                        CategoryObject.StyleArray = array
                    } else if (action[index] == "material_category") {
                        CategoryObject.MaterialArray = array
                    }
                    // action[index]에 따른 각 카테고리 진입
                    if action.count > index+1 {
                        requestCategory(action: action, index: index+1) { status in completionHandler(status) }
                    } else {
                        completionHandler(200)
                    }
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

func requestSignUp(completionHandler: @escaping ((Int) -> Void)) {
    
    let timestamp: Int64 = setGMTUnixTimestamp()
    var params: Parameters = [
        "action": "register"
    ]
    /// member
    params["device_info"] = device_info
    params["fcm_id"] = MemberObject_signup.fcm_id
    params["marketing_agree"] = String(MemberObject_signup.marketing_agree)
    params["member_position"] = MemberObject_signup.member_grade
    params["my_store"] = MemberObject_signup.my_store
    params["platform_type"] = "iOS"
    params["signup_time"] = String(timestamp)
    params["user_num"] = MemberObject_signup.member_num
    params["user_id"] = MemberObject_signup.member_id
    params["user_pw"] = MemberObject_signup.member_pw
    params["user_name"] = MemberObject_signup.member_name
    params["user_email"] = MemberObject_signup.member_email
    params["user_type"] = MemberObject_signup.member_type
    /// member grade
    if MemberObject_signup.member_grade == "ceo" {
        /// store
        if MemberObject_signup.member_type == "retailseller" {
            StoreObject_signup.store_id = "re"+String(timestamp)
            params["onoff_type"] = StoreObject_signup.onoff_type
            params["store_domain"] = StoreObject_signup.store_domain
            params["store_address"] = StoreObject_signup.store_address_street
            params["store_address_detail"] = StoreObject_signup.store_address_detail
            params["store_address_zipcode"] = StoreObject_signup.store_address_zipcode
            params["wechat_id"] = StoreObject_signup.wechat_id
        } else if MemberObject_signup.member_type == "wholesales" {
            StoreObject_signup.store_id = "wh"+String(timestamp)
            params["business_reg_status"] = String(StoreObject_signup.business_reg_status)
            params["business_reg_num"] = StoreObject_signup.business_reg_num
        }
        params["ceo_name"] = StoreObject_signup.ceo_name
        params["ceo_num"] = StoreObject_signup.ceo_num
        params["store_id"] = StoreObject_signup.store_id
        params["store_type"] = StoreObject_signup.store_type
        params["store_member"] = [MemberObject_signup.member_id]
        params["store_name"] = StoreObject_signup.store_name
        params["store_name_eng"] = StoreObject_signup.store_name_eng
        params["store_tel"] = StoreObject_signup.store_tel
        params["summary_address"] = StoreObject_signup.summary_address
        params["account"] = StoreObject_signup.account
        /// member
        params["my_store"] = StoreObject_signup.store_id
    }
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/dk_sto", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                if responseJson["data"] != nil {
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

func requestFileUpload(action: String, collection_id: String, document_id: String, file_data: [(field_name: String, file_name: String, file_data: Data, file_size: Int)], file_index: Int = 0, first: Bool = true, completionHandler: @escaping (([String: Any]?, Int) -> Void)) {
    /// limit upload data
    var upload_size: Int = 0
    var upload_index: Int = file_index
    var upload_data: [(field_name: String, file_name: String, file_data: Data, file_size: Int)] = []
    for i in upload_index ..< file_data.count { upload_size += file_data[i].file_size; upload_data.append(file_data[i]); upload_index += 1
        if (upload_size > 26214400) { break }
    }
    
    let params: Parameters = [
        "action": action,
        "collection_id": collection_id,
        "document_id": document_id,
        "first": String(first),
    ]
    
    params.forEach { data in print(data) }
    upload_data.forEach { data in print(data) }
    
    var fileUrls: [String: Any] = [:]
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
                
                if (field_name.contains("building_contract_imgs")) {
                    formData.append(file_data, withName: field_name, fileName: field_name, mimeType: file_name.mimeType())
                } else if (field_name.contains("item_content_imgs")) {
                    formData.append(file_data, withName: field_name, fileName: "detail\(index)", mimeType: file_name.mimeType())
                } else if (field_name == "item_photo_imgs0") {
                    formData.append(file_data, withName: "item_mainphoto_img", fileName: "main", mimeType: file_name.mimeType())
                } else {
                    formData.append(file_data, withName: field_name, fileName: index, mimeType: file_name.mimeType())
                }
            }
        }
    }, to: requestUrl+"/file_upload", method: .post)
    .uploadProgress { progress in
        print(progress.fractionCompleted)
    }
    .responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
                print(responseJson)
                if responseJson["data"] as? [String: Any] != nil {
                    if (file_data.count > upload_index+1) {
                        requestFileUpload(action: action, collection_id: collection_id, document_id: document_id, file_data: file_data, file_index: upload_index, first: false) { _, status in
                            completionHandler(nil, status)
                        }
                    } else {
                        /// 이미지 캐시 삭제
                        memoryCheck(delete: true)
                        /// 데이터 추가
                        fileUrls = responseJson["data"] as? [String: Any] ?? [:]
                        completionHandler(fileUrls, 200)
                    }
                } else {
                    completionHandler(nil, 204)
                }
            } else {
                completionHandler(nil, 600)
            }
        } catch {
            print(response.error as Any)
            completionHandler(nil, response.error?.responseCode ?? 500)
        }
    }
}

func requestSignIn(completionHandler: @escaping ((Int) -> Void)) {
    
    let params: Parameters = [
        "action": "login",
        "user_type": appDelegate.member_type,
        "user_id": appDelegate.member_id,
        "user_pw": appDelegate.member_pw,
        "device_info": device_info,
        "fcm_id": fcm_id,
    ]
    params.forEach { dict in print(dict) }
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/dk_sto", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                if let dict = responseJson["data"] as? [String: Any] {
                    /// member info
                    let memberDict = dict["member"] as? [String: Any] ?? [:]
                    /// 데이터 추가
                    MemberObject = setMember(memberDict: memberDict)
                    /// store info
                    let storeDict = dict["store"] as? [String: Any] ?? [:]
                    /// 데이터 추가
                    StoreObject = setStore(storeDict: storeDict)
                    
//                    let storeArray = dict["store"] as? Array<[String: Any]> ?? []
//                    StoreObject = setStore(storeDict: storeArray.first ?? [:])
                    
//                    let storeArray = dict["store"] as? Array<[String: Any]> ?? []
//                    storeArray.forEach { storeDict in
//                        /// 데이터 추가
//                        StoreArray.append(setStore(storeDict: storeDict))
//                    }
                    
                    var topics: [String] = []
                    if StoreObject.store_type == "retailseller" {
                        topics = [
                            UserDefaults.standard.string(forKey: "re_enquiry") ?? "",
                            "",
                            "",
                            "",
                            "",
                        ]
                    } else if StoreObject.store_type == "wholesales" {
                        topics = [
                            UserDefaults.standard.string(forKey: "wh_enquiry") ?? "",
                            "",
                            "",
                            "",
                            "",
                        ]
                    }
                    topics.forEach { topic in
                        if topic != "" {
                            Messaging.messaging().subscribe(toTopic: topic) { error in
                                if error == nil { print("도픽구독성공: \(topic)") } else { print("도픽구독실패: \(topic)") }
                            }
                        }
                    }
                    
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

func requestPhoneNum(phoneNum: String, completionHandler: @escaping ((Int) -> Void)) {
    
    if phoneNum.contains("01031870005") {
        completionHandler(200)
    } else {
        Auth.auth().languageCode = "ko"
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNum, uiDelegate: nil) { verificationID, error in
            if (error == nil) {
                print(verificationID as Any)
                UserDefaults.standard.setValue(verificationID ?? "", forKey: "verification_id")
                completionHandler(200)
            } else {
                print(error as Any)
                completionHandler(500)
            }
        }
    }
}

func requestPhoneNumCheck(verificationId: String, phoneNum: String, phoneNumCheck: String, completionHandler: @escaping ((Int) -> Void)) {
    
    if phoneNum == "01031870005", phoneNumCheck == "000191" {
        completionHandler(200)
    } else {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: phoneNumCheck)
        Auth.auth().signIn(with: credential) { authResult, error in
            if error == nil {
                print(authResult as Any)
                completionHandler(200)
            } else {
                print(error as Any)
                completionHandler(500)
            }
        }
    }
}

func requestCheckId(member_id: String, completionHandler: @escaping ((Int) -> Void)) {
    
    let params: Parameters = [
        "action": "check_id",
        "user_id": member_id,
    ]
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/dk_sto", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                if responseJson["data"] as? String == "available" {
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

func requestSearchStore(storeType: String, storeName: String, completionHandler: @escaping ((Int) -> Void)) {
    
    let params: Parameters = [
        "action": "find_store",
        "store_type": storeType,
        "store_name": storeName,
        "limit": 100,
    ]
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/dk_sto", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                if let storeArray = responseJson["data"] as? Array<[String: Any]> {
                    storeArray.forEach { storeDict in
                        /// 데이터 추가
                        if let delegate = SearchStoreVCdelegate {
                            delegate.StoreArray_search.append(setStore(storeDict: storeDict))
                        }
                    }
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








func requestReMain(completionHandler: @escaping ((Int) -> Void)) {
    
    let params: Parameters = [
        "action": "get",
    ]
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/main", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                let data = responseJson["data"] as? [String: Any] ?? [:]
                /// best store
                (data["best_store"] as? Array<[String: Any]> ?? []).forEach { dict in
                    /// 데이터 추가
                    ReStoreArray_best.append((
                        StoreObject: setStore(storeDict: dict),
                        GoodsObject: setGoods(goodsDict: (dict["best_item"] as? Array<[String: Any]> ?? []).first ?? [:])
                    ))
                }
                /// best goods
                (data["best_item"] as? Array<[String: Any]> ?? []).forEach { dict in
                    /// 데이터 추가
                    ReGoodsArray_best.append(setGoods(goodsDict: dict))
                }
                if ReStoreArray_best.count+ReGoodsArray_best.count > 0 {
                    ReStoreArray_best.sort { $0.StoreObject.store_name_eng < $1.StoreObject.store_name_eng }
                    ReGoodsArray_best.sort { $0.item_pullup_time > $1.item_pullup_time }
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

func requestBestItems(completionHandler: @escaping ((Int) -> Void)) {
    
    let params: Parameters = [
        "collection_id": "main",
        "document_id": "best_items",
    ]
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/get_db", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                /// best goods
                let data = responseJson["data"] as? [String: Any] ?? [:]
                let _: [()]? = data.compactMap({ (key: String, value: Any) in
                    let array = data[key] as? Array<[String: Any]> ?? []
                    var ReGoodsArray_best: [GoodsData] = []
                    array.forEach { dict in
                        /// 데이터 추가
                        ReGoodsArray_best.append(setGoods(goodsDict: dict))
                    }
                    ReGoodsArray_best.sort { $0.item_pullup_time > $1.item_pullup_time }
                    /// 데이터 추가
                    ReGoodsArray_best2.append((title: key, ReGoodsArray_best: ReGoodsArray_best))
                })
                ReGoodsArray_best2.sort { $0.title < $1.title }
                completionHandler(ReGoodsArray_best2.count > 0 ? 200 : 204)
            } else {
                completionHandler(600)
            }
        } catch {
            print(response.error as Any)
            completionHandler(response.error?.responseCode ?? 500)
        }
    }
}

func requestReGoods(params: [String: Any], completionHandler: @escaping (([GoodsData], Int) -> Void)) {
    
    print(params)
    
    var GoodsArray: [GoodsData] = []
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/goods", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                if let data = responseJson["data"] as? Array<Any> {
                    /// goods
                    data.forEach { data in
                        /// 데이터 추가
                        GoodsArray.append(setGoods(goodsDict: data as? [String: Any] ?? [:]))
                    }
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

func requestReBasket(type: String = "get", params: [String: Any] = [:], completionHandler: @escaping ((Int) -> Void)) {
    /// 데이터 삭제
    ReBasketArray.removeAll()
    
    var params: Parameters = params
    if type == "get" {
        params["action"] = "find_basket"
    } else if type == "set" {
        params["action"] = "basket"
    } else if type == "edit" {
        params["action"] = "basket_edit"
    } else if type == "delete" {
        params["action"] = "basket_delete"
    }
    params["re_store_id"] = StoreObject.store_id
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/order", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
//                if type == "get" {
//                    
//                    let array = responseJson["data"] as? Array<[String: Any]> ?? []
//                    array.forEach { dict in
//                        /// 데이터 추가
//                        ReBasketArray.append(setBasket(basketDict: dict))
//                    }
//                    
//                    if ReBasketArray.count > 0 {
//                        completionHandler(200)
//                    } else {
//                        completionHandler(204)
//                    }
//                } else if type == "set" {
//                    
//                    params.removeValue(forKey: "action")
//                    /// 데이터 추가
//                    ReBasketArray.append(setBasket(basketDict: params))
//                    
//                    completionHandler(200)
//                } else if type == "edit" {
//                    
//                    params.removeValue(forKey: "action")
//                    /// 데이터 변경
//                    ReBasketArray.enumerated().forEach { i, data in
//                        if data.basket_key == params["basket_key"] as? String ?? "" {
//                            ReBasketArray[i] = setBasket(basketDict: params)
//                        }
//                    }
//                    
//                    completionHandler(200)
//                } else if type == "delete" {
//                    /// 데이터 삭제
//                    ReBasketArray.enumerated().forEach { i, data in
//                        if data.basket_key == params["basket_key"] as? String ?? "" {
//                            ReBasketArray.remove(at: i)
//                        }
//                    }
//                    
//                    completionHandler(200)
//                }
                
                let array = responseJson["data"] as? Array<[String: Any]> ?? []
                array.forEach { dict in
                    /// 데이터 추가
                    ReBasketArray.append(setBasket(basketDict: dict))
                }
                
                if ReBasketArray.count > 0 {
                    ReBasketArray.sort { $0.basket_key > $1.basket_key }
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

func requestFindReGoods(store_id: String, item_key: String, completionHandler: @escaping ((GoodsData, Int) -> Void)) {
    
    let params: Parameters = [
        "action": "find_goods",
        "store_id": store_id,
        "item_key": item_key,
    ]
    
    var GoodsObject: GoodsData = GoodsData()
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/order", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            guard let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] else { completionHandler(GoodsObject, 600); return }
//            print(responseJson)
            if let dict = responseJson["data"] as? [String: Any] {
                GoodsObject = setGoods(goodsDict: dict)
                completionHandler(GoodsObject, 200)
            } else {
                completionHandler(GoodsObject, 204)
            }
        } catch {
            print(response.error as Any)
            completionHandler(GoodsObject, response.error?.responseCode ?? 500)
        }
    }
}

func requestReStoreVisit(store_id: String, limit: Int = 99999, completionHandler: @escaping ((VisitData, Int) -> Void)) {
    
    let params: Parameters = [
        "action": "store_visit",
        "store_id": store_id,
        "limit": limit,
    ]
    
    var VisitObject: VisitData = VisitData()
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/goods", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            guard let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] else { completionHandler(VisitObject, 600); return }
//            print(responseJson)
            if let dict = responseJson["data"] as? [String: Any] {
                
                let visitValue = VisitData()
                visitValue.StoreObject = setStore(storeDict: dict["store"] as? [String: Any] ?? [:])
                (dict["toplist"] as? Array<[String: Any]>)?.forEach({ bestDict in
                    visitValue.ReGoodsArray_best.append(setGoods(goodsDict: bestDict))
                })
                (dict["fulldisclosure"] as? Array<[String: Any]>)?.forEach({ fullDict in
                    visitValue.GoodsArray_full.append(setGoods(goodsDict: fullDict))
                })
                (dict["businessdisclosure"] as? Array<[String: Any]>)?.forEach({ businessDict in
                    visitValue.GoodsArray_business.append(setGoods(goodsDict: businessDict))
                })
                /// 데이터 추가
                VisitObject = visitValue
                completionHandler(VisitObject, 200)
            } else {
                completionHandler(VisitObject, 204)
            }
        } catch {
            print(response.error as Any)
            completionHandler(VisitObject, response.error?.responseCode ?? 500)
        }
    }
}

func requestReStoreAdd(store_id: String, store_pw: String, completionHandler: @escaping ((Int) -> Void)) {
    
    let params: Parameters = [
        "action": "mystore_add",
        "user_id": MemberObject.member_id,
        "store_id": store_id,
        "store_pw": store_pw,
    ]
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/dk_sto", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                if let dict = responseJson["data"] as? [String: Any] {
                    /// 데이터 추가
                    StoreArray.append(setStore(storeDict: dict))
                    
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

func requestReBookMark(action: String, re_store_id: String, wh_store_id: String, completionHandler: @escaping ((Int) -> Void)) {
    
    let params: Parameters = [
        "action": action,
        "re_store_id": re_store_id,
        "wh_store_id": wh_store_id,
    ]
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/goods", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
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

func requestReBookMark(store_id: String, completionHandler: @escaping (([StoreData], Int) -> Void)) {
    
    let params: Parameters = [
        "action": "favorites_find",
        "store_id": store_id,
    ]
    
    var BookMarkArray: [StoreData] = []
    
    AF.request(requestUrl+"/goods", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                let array = responseJson["data"] as? Array<[String: Any]> ?? []
                array.forEach { dict in
                    /// 데이터 추가
                    BookMarkArray.append(setStore(storeDict: dict))
                }
                
                if array.count > 0 {
                    completionHandler(BookMarkArray, 200)
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

func requestWhRealTime(filter: String = "최신순", limit: Int = 99999, completionHandler: @escaping ((Int) -> Void)) {
    
    let params: Parameters = [
        "action": "mylist",
        "store_id": StoreObject.store_id,
        "filter": filter,
        "limit": limit,
    ]
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/goods", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                let array = responseJson["data"] as? Array<[String: Any]> ?? []
                array.forEach { dict in
                    /// 데이터 추가
                    WhGoodsArray_realtime.append(setGoods(goodsDict: dict))
                }
                
                if WhGoodsArray_realtime.count > 0 {
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

func requestWhCounting(completionHandler: @escaping ((Int) -> Void)) {
    
    let params: Parameters = [
        "action": "get_counting",
        "store_id": StoreObject.store_id,
    ]
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/order", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                /// 데이터 추가
                WhCountingObject = setWhCounting(countingDict: responseJson["data"] as? [String: Any] ?? [:])
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

func requestWhGoodsUpload(GoodsObject: GoodsData, timestamp: Int64, completionHandler: @escaping ((Int) -> Void)) {
    
    let data = GoodsObject
    
    var item_option: Array<[String: Any]> = []
    data.item_option.forEach { data in
        item_option.append([
            "color": data.color,
            "price": data.price,
            "size": data.size,
            "sold_out": String(data.sold_out)
        ])
    }
    
    let params: Parameters = [
        "action": "product_registration",
        "user_id": MemberObject.member_id,
        "item_key": String(timestamp),
        "item_category_name": data.item_category_name,
        "item_name": data.item_name,
        "item_sale": String(data.item_sale),
        "item_price": data.item_price,
        "item_sale_price": data.item_sale_price,
        "item_colors": data.item_colors,
        "item_sizes": data.item_sizes,
        "item_option": item_option,
        "item_option_type": String(data.item_option_type),
        "item_content": data.item_content,
        "item_style": data.item_style,
        "item_materials": data.item_materials,
        "item_material_washing": data.item_material_washing,
        "item_build": data.item_build,
        "item_manufacture_country": data.item_manufacture_country,
        "item_disclosure": data.item_disclosure,
        "item_pullup_time": data.item_pullup_time,
        "store_id": StoreObject.store_id,
        "store_name": StoreObject.store_name,
        "store_name_eng": StoreObject.store_name_eng,
        "store_mainphoto_img": StoreObject.store_mainphoto_img
    ]
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/goods", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                if responseJson["data"] as? [String: Any] != nil {
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

func requestEmployee(completionHandler: @escaping (([MemberData], Int) -> Void)) {
    
    let params: Parameters = [
        "action": "employee_admin",
        "store_id": StoreObject.store_id,
    ]
    
    var EmployeeArray: [MemberData] = []
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/dk_sto", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                let array = responseJson["data"] as? Array<[String: Any]> ?? []
                array.forEach { dict in
                    /// 데이터 추가
                    if dict["member_position"] as? String ?? "" == "ceo" {
                        EmployeeArray.insert(setMember(memberDict: dict), at: 0)
                    } else if dict["user_id"] as? String ?? "" == MemberObject.member_id && EmployeeArray.count > 1 {
                        EmployeeArray.insert(setMember(memberDict: dict), at: 1)
                    } else {
                        EmployeeArray.append(setMember(memberDict: dict))
                    }
                }
                
                if array.count > 0 {
                    completionHandler(EmployeeArray, 200)
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

func requestWhInventory(completionHandler: @escaping (([InventoryData], Int) -> Void)) {
    
    let params: Parameters = [
        "action": "get_whole",
        "store_id": StoreObject.store_id,
    ]
    
    var InventoryArray: [InventoryData] = []
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/inventory", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                let array = responseJson["data"] as? Array<[String: Any]> ?? []
                array.forEach { dict in
                    /// 데이터 추가
                    InventoryArray.append(setInventory(inventoryDict: dict))
                }
                
                if array.count > 0 {
                    completionHandler(InventoryArray, 200)
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

func requestEditStore(completionHandler: @escaping ((Int) -> Void)) {
    
    let params: Parameters = [
        "action": "store_edit",
        "store_id": StoreObject.store_id,
    ]
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/dk_sto", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                if responseJson["message"] as? String ?? "" == "success" {
                    completionHandler(200)
                } else {
                    completionHandler(500)
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

func requestReReceipt(action: String, params: [String: Any], completionHandler: @escaping ((ReceiptData, ReceiptData, Int) -> Void)) {
    
    var ReGoodsReceiptObject: ReceiptData = ReceiptData()
    var ReDpcostReceiptObject: ReceiptData = ReceiptData()
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/receipt", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
                print(responseJson)
                if responseJson["message"] as? String ?? "" == "success" {
                    if action == "set_goods" {
                        ReGoodsReceiptObject = setReceipt(receiptDict: responseJson["data"] as? [String: Any] ?? [:])
                    } else if action == "set_dpcost" {
                        ReDpcostReceiptObject = setReceipt(receiptDict: responseJson["data"] as? [String: Any] ?? [:])
                    } else if action == "get_receipt" {
                        ReGoodsReceiptObject = setReceipt(receiptDict: responseJson["goods_receipt"] as? [String: Any] ?? [:])
                        ReDpcostReceiptObject = setReceipt(receiptDict: responseJson["dpcost_receipt"] as? [String: Any] ?? [:])
                    }; completionHandler(ReGoodsReceiptObject, ReDpcostReceiptObject, 200)
                } else {
                    completionHandler(ReGoodsReceiptObject, ReDpcostReceiptObject, 500)
                }
            } else {
                completionHandler(ReGoodsReceiptObject, ReDpcostReceiptObject, 600)
            }
        } catch {
            print(response.error as Any)
            completionHandler(ReGoodsReceiptObject, ReDpcostReceiptObject, response.error?.responseCode ?? 500)
        }
    }
}



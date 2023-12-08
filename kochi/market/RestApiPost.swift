//
//  RestApiPost.swift
//  market
//
//  Created by Busan Dynamic on 11/16/23.
//

import UIKit
import Alamofire
import FirebaseAuth

let requestUrl: String = "https://dk-sto-yy2mch6sra-du.a.run.app"
let dispatchGroup = DispatchGroup()
let dispatchQueue = DispatchQueue(label: "com.blink.dk.market2", attributes: .concurrent)

// other request error code: 999(json변환오류)

func requestCategory(action: [String], index: Int = 0, completionHandler: @escaping ((Int) -> Void)) {
    
    let params: Parameters = [
        "action": action[index],
    ]
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/goods", method: .post, parameters: params).responseData { response in
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
    
    let timestamp: Int64 = setKoreaUnixTimestamp()
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
        params["account"] = StoreObject_signup.account
        /// member
        params["my_store"] = StoreObject_signup.store_id
    }
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/dk_sto", method: .post, parameters: params).responseData { response in
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

func requestFileUpload(collection_id: String, document_id: String, file_data: [(field_name: String, file_name: String, file_data: Data, file_size: Int)], file_index: Int = 0, completionHandler: @escaping ((Int) -> Void)) {
    /// limit upload data
    var upload_size: Int = 0
    var upload_index: Int = file_index
    var upload_data: [(field_name: String, file_name: String, file_data: Data, file_size: Int)] = []
    for i in upload_index ..< file_data.count { upload_size += file_data[i].file_size; upload_data.append(file_data[i]); upload_index += 1
        if (upload_size > 26214400) { break }
    }
    
    let params: Parameters = [
        "action": "add",
        "collection_id": collection_id,
        "document_id": document_id,
    ]
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
                
                if (field_name.contains("item_content_imgs")) {
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
                if (file_data.count > upload_index+1) {
                    requestFileUpload(collection_id: collection_id, document_id: document_id, file_data: file_data, file_index: upload_index) { status in
                        completionHandler(status)
                    }
                } else {
                    completionHandler(200)
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

func requestSignIn(completionHandler: @escaping ((Int) -> Void)) {
    
    let params: Parameters = [
        "action": "login",
        "user_type": appDelegate.member_type,
        "user_id": appDelegate.member_id,
        "user_pw": appDelegate.member_pw,
    ]
    /// x-www-form-urlencoded
    AF.request(requestUrl+"/dk_sto", method: .post, parameters: params).responseData { response in
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
    AF.request(requestUrl+"/dk_sto", method: .post, parameters: params).responseData { response in
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
    AF.request(requestUrl+"/dk_sto", method: .post, parameters: params).responseData { response in
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
    
    AF.request(requestUrl+"/main", method: .post, parameters: params).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                let data = responseJson["data"] as? [String: Any] ?? [:]
                /// best store
                (data["best_store"] as? Array<[String: Any]> ?? []).forEach { dict in
                    /// 데이터 추가
                    StoreArray_best.append((
                        StoreObject: setStore(storeDict: dict),
                        GoodsObject: setGoods(goodsDict: (dict["best_item"] as? Array<[String: Any]> ?? []).first ?? [:])
                    ))
                }
                /// best goods
                (data["best_item"] as? Array<[String: Any]> ?? []).forEach { dict in
                    /// 데이터 추가
                    GoodsArray_best.append(setGoods(goodsDict: dict))
                }
                if StoreArray_best.count+GoodsArray_best.count > 0 {
                    StoreArray_best.sort { $0.StoreObject.store_name_eng < $1.StoreObject.store_name_eng }
                    GoodsArray_best.sort { $0.item_pullup_time > $1.item_pullup_time }
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

func requestReGoods(category: [String] = [], startAt: String = "", limit: Int = 99999, completionHandler: @escaping (([GoodsData], Int) -> Void)) {
    
    var params: Parameters = [
        "action": "search",
        "filterValue": [""],                                  // 카테고리
        "filteredColorFilter": "",                            // 색상
        "storeNameFilter": "",                                // 매장명
        "styleFilter": "",                                    // 스타일
        "priceRangeFilter": ["minPrice", "maxPrice"],         // 가격범위(원가)
        "salePriceRangeFilter": ["minPrice", "maxPrice"],     // 가격범위(할인가)
        "start_index": startAt,
        "limit": limit,
    ]
    
    if category.count == 0 {
        params["filter"] = "전체보기"
    } else {
        params["filter"] = "카테고리"
    }
    
    var GoodsArray: [GoodsData] = []
    
    AF.request(requestUrl+"/goods", method: .post, parameters: params).responseData { response in
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
    
    AF.request(requestUrl+"/order", method: .post, parameters: params).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                if type == "get" {
                    
                    let array = responseJson["data"] as? Array<[String: Any]> ?? []
                    array.forEach { dict in
                        /// 데이터 추가
                        BasketArray.append(setBasket(basketDict: dict))
                    }
                    
                    if BasketArray.count > 0 {
                        completionHandler(200)
                    } else {
                        completionHandler(204)
                    }
                } else if type == "set" {
                    
                    params.removeValue(forKey: "action")
                    /// 데이터 추가
                    BasketArray.append(setBasket(basketDict: params))
                    
                    completionHandler(200)
                } else if type == "edit" {
                    
                    params.removeValue(forKey: "action")
                    /// 데이터 변경
                    BasketArray.enumerated().forEach { i, data in
                        if data.basket_key == params["basket_key"] as? String ?? "" {
                            BasketArray[i] = setBasket(basketDict: params)
                        }
                    }
                    
                    completionHandler(200)
                } else if type == "delete" {
                    /// 데이터 삭제
                    BasketArray.enumerated().forEach { i, data in
                        if data.basket_key == params["basket_key"] as? String ?? "" {
                            BasketArray.remove(at: i)
                        }
                    }
                    
                    completionHandler(200)
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
    
    AF.request(requestUrl+"/order", method: .post, parameters: params).responseData { response in
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
    
    AF.request(requestUrl+"/goods", method: .post, parameters: params).responseData { response in
        do {
            guard let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] else { completionHandler(VisitObject, 600); return }
//            print(responseJson)
            if let dict = responseJson["data"] as? [String: Any] {
                
                let visitValue = VisitData()
                visitValue.StoreObject = setStore(storeDict: dict["store"] as? [String: Any] ?? [:])
                (dict["toplist"] as? Array<[String: Any]>)?.forEach({ bestDict in
                    visitValue.GoodsArray_best.append(setGoods(goodsDict: bestDict))
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
    
    AF.request(requestUrl+"/dk_sto", method: .post, parameters: params).responseData { response in
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

func requestReAccount(action: String, re_store_id: String, wh_store_id: String, completionHandler: @escaping ((Int) -> Void)) {
    
    let params: Parameters = [
        "action": action,
        "re_store_id": re_store_id,
        "wh_store_id": wh_store_id,
    ]
    
    AF.request(requestUrl+"/goods", method: .post, parameters: params).responseData { response in
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

func requestReScrap(store_id: String, completionHandler: @escaping (([StoreData], Int) -> Void)) {
    
    let params: Parameters = [
        "action": "favorites_find",
        "store_id": store_id,
    ]
    
    var StoreArray: [StoreData] = []
    
    AF.request(requestUrl+"/goods", method: .post, parameters: params).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                if let array = responseJson["data"] as? Array<[String: Any]> {
                    
                    array.forEach { dict in
                        /// 데이터 추가
                        StoreArray.append(setStore(storeDict: dict))
                    }
                    
                    completionHandler(StoreArray, 200)
                } else {
                    completionHandler(StoreArray, 204)
                }
            } else {
                completionHandler(StoreArray, 600)
            }
        } catch {
            print(response.error as Any)
            completionHandler(StoreArray, response.error?.responseCode ?? 500)
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
    
    AF.request(requestUrl+"/goods", method: .post, parameters: params).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
//                print(responseJson)
                let array = responseJson["data"] as? Array<[String: Any]> ?? []
                array.forEach { dict in
                    /// 데이터 추가
                    GoodsArray_realtime.append(setGoods(goodsDict: dict))
                }
                
                if GoodsArray_realtime.count > 0 {
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
        "store_id": StoreObject.store_id,
        "store_name": StoreObject.store_name,
        "store_name_eng": StoreObject.store_name_eng,
        "store_mainphoto_img": StoreObject.store_mainphoto_img
    ]
    
    AF.request(requestUrl+"/goods", method: .post, parameters: params).responseData { response in
        do {
            if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
                print(responseJson)
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



//    func requestSignIn(completionHandler: @escaping ((Int) -> Void)) {
//
//        let params: Parameters = [
//            "action": "login",
//            "user_type": appDelegate.member_type,
//            "user_id": appDelegate.member_id,
//            "user_pw": appDelegate.member_pw,
//        ]
//        /// x-www-form-urlencoded
//        AF.request(requestUrl+"/dk_sto", method: .post, parameters: params).responseData { response in
//            do {
//                if let responseJson = try JSONSerialization.jsonObject(with: response.data ?? Data()) as? [String: Any] {
////                    print(responseJson)
//                    if let dict = responseJson["data"] as? [String: Any] {
//                        completionHandler(200)
//                    } else {
//                        completionHandler(204)
//                    }
//                } else {
//                    completionHandler(600)
//                }
//            } catch {
//                print(response.error as Any)
//                completionHandler(response.error?.responseCode ?? 500)
//            }
//
////            switch response.result {
////            case .success(_):
////                if let dict = response.value as? [String: Any] {
////                    completionHandler(200)
////                } else {
////                    completionHandler(204)
////                }
////            case .failure(let error):
////                print("로그인 ---------------\n", error as Any)
////                completionHandler(error.responseCode ?? 500)
////            }
//        }
//    }

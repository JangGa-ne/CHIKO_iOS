//
//  RestApiObject.swift
//  market
//
//  Created by Busan Dynamic on 2023/10/16.
//

import UIKit

class CategoryData {
    
    var ColorArray_all: [String: Any] = [:]
    // 색상(색상명:색상코드)
    var ColorArray: Array<[String: Any]> = []
    // 상품(메인>서브>디테일)
    var CategoryArray: Array<[String: Any]> = []
    // 사이즈(상품/메인:사이즈)
    var SizeArray: Array<[String: Any]> = []
    // 스타일(상품/메인(의류):스타일)
    var StyleArray: Array<[String: Any]> = []
    // 주요소재(의류/나머지)
    var MaterialArray: Array<[String: Any]> = []
    // 주요소재및세탁법(의류/소재+세탁법,나머지/세탁법)
    var MaterialWashingInfoArray: Array<[String: Any]> = []
}

class VisitData {
    
    var StoreObject: StoreData = StoreData()
    var GoodsArray_best: [GoodsData] = []
    var GoodsArray_full: [GoodsData] = []
    var GoodsArray_business: [GoodsData] = []
}

class MemberData {
    // 공통
    var fcm_id: String = ""
    var member_type: String = "" // "retailseller", "wholesales"
    var member_grade: String = "" // "ceo", "employee"
    var member_num: String = ""
    var member_id: String = ""
    var member_pw: String = ""
    var member_name: String = ""
    var member_email: String = ""
    var marketing_agree: Bool = false
    var marketing_agree_type: [String] = [] // ["sms", "email"]
    var session_id: String = ""
    var session_time: String = ""
    var end_session_time: String = ""
    var signup_time: String = ""
    var profile_img: String = ""
    var my_store: [String] = []
    // 소매자
    var member_idcard_img: String = ""
    
    var upload_profile_img: [(file_name: String, file_data: Data, file_size: Int)] = []
    var upload_member_idcard_img: [(file_name: String, file_data: Data, file_size: Int)] = []
    
    var upload_files: [(field_name: String, file_name: String, file_data: Data, file_size: Int)] = []
    var load_img: Bool = false
}

class StoreData {
    // 공통
    var ceo_name: String = ""
    var ceo_num: String = ""
    var store_id: String = ""
    var store_type: String = "" // "retailseller", "wholesales"
    var store_tag: [String] = []
    var store_member: [String] = []
    var store_name: String = ""
    var store_name_eng: String = ""
    var store_pw: String = ""
    var store_tel: String = ""
    var account: [String: Any] = [:]
    var store_mainphoto_img: String = ""
    var goods: [String] = []
    var item_content_auto1: String = ""
    var item_content_auto2: String = ""
    var item_content_auto3: String = ""
    var passbook_img: String = ""
    // 소매자
    var onoff_type: String = "" // "online", "offline", "onoffline"
    var store_domain: String = "" // offline 일때
    var store_address_street: String = "" // offline 일때
    var store_address_detail: String = "" // offline 일때
    var store_address_zipcode: String = "" // offline 일때
    var store_favorites: [String] = []
    // 도매자
    var business_reg_status: Bool = true
    var business_reg_num: String = ""
    var business_reg_img: String = ""
    var building_contract_img: String = ""
    var account_counting: Int = 0
    var item_full_counting: Int = 0
    var item_account_counting: Int = 0
    var waiting_step: Int = 0
    
    var upload_store_mainphoto_img: [(file_name: String, file_data: Data, file_size: Int)] = []
    var upload_passbook_img: [(file_name: String, file_data: Data, file_size: Int)] = []
    var upload_business_reg_img: [(file_name: String, file_data: Data, file_size: Int)] = []
    var upload_building_contract_img: [(file_name: String, file_data: Data, file_size: Int)] = []
    
    var upload_files: [(field_name: String, file_name: String, file_data: Data, file_size: Int)] = []
    var load_img: Bool = false
}

func setStore(storeDict: [String: Any]) -> StoreData {
    
    let storeValue = StoreData()
    storeValue.account = storeDict["account"] as? [String: Any] ?? [:]
    storeValue.account_counting = storeDict["account_counting"] as? Int ?? 0
    storeValue.ceo_name = storeDict["ceo_name"] as? String ?? ""
    storeValue.ceo_num = storeDict["ceo_num"] as? String ?? ""
    storeValue.goods = storeDict["goods"] as? [String] ?? []
    storeValue.item_account_counting = storeDict["item_account_counting"] as? Int ?? 0
    storeValue.item_content_auto1 = storeDict["item_content_auto1"] as? String ?? ""
    storeValue.item_content_auto2 = storeDict["item_content_auto2"] as? String ?? ""
    storeValue.item_content_auto3 = storeDict["item_content_auto3"] as? String ?? ""
    storeValue.item_full_counting = storeDict["item_full_counting"] as? Int ?? 0
    storeValue.onoff_type = storeDict["onoff_type"] as? String ?? ""
    storeValue.passbook_img = storeDict["passbook_img"] as? String ?? ""
    storeValue.store_address_street = storeDict["store_address"] as? String ?? ""
    storeValue.store_address_detail = storeDict["store_address_detail"] as? String ?? ""
    storeValue.store_address_zipcode = storeDict["store_address_zipcode"] as? String ?? ""
    storeValue.store_domain = storeDict["store_domain"] as? String ?? ""
    storeValue.store_favorites = storeDict["store_favorites"] as? [String] ?? []
    storeValue.store_id = storeDict["store_id"] as? String ?? ""
    storeValue.store_mainphoto_img = storeDict["store_mainphoto_img"] as? String ?? ""
    storeValue.store_member = storeDict["store_member"] as? [String] ?? []
    storeValue.store_name = storeDict["store_name"] as? String ?? ""
    storeValue.store_name_eng = storeDict["store_name_eng"] as? String ?? ""
    storeValue.store_pw = storeDict["store_pw"] as? String ?? ""
    storeValue.store_tag = storeDict["store_tag"] as? [String] ?? []
    storeValue.store_tel = storeDict["store_tel"] as? String ?? ""
    storeValue.store_type = storeDict["store_type"] as? String ?? ""
    storeValue.waiting_step = Int(storeDict["waiting_step"] as? String ?? "0") ?? 0
    /// 데이터 추가
    return storeValue
}

class GoodsData {
    
    var load: Bool = false
    var user_id: String = ""
    var item_key: String = ""
    var item_mainphoto_img: String = ""
    var item_photo_imgs: [String] = []
    var item_category_name: [String] = []
    var item_name: String = ""
    var item_sale: Bool = false
    var item_price: Int = 0
    var item_sale_price: Int = 0
    var item_colors: [String] = []
    var item_sizes: [String] = []
    var item_materials: [String] = []
    var item_material_washing: [String: Any] = [:]
    var item_style: String = ""
    var item_content: String = ""
    var item_content_imgs: [String] = []
    var item_build: String = ""
    var item_sheet: String = ""
    var item_manufacture_country: String = ""
    var item_disclosure: String = "전체 공개"
    var item_soldout: Bool = false
    var item_soldout_time: String = ""
    var item_pullup_time: String = "0"
    var item_click_count: Int = 0
    var item_order_count: Int = 0
    var item_exposure_count: Int = 0
    var item_favorite_count: Int = 0
    var item_option: [GoodsOptionData] = []
    var item_top_check: Bool = false
    var item_top_grade: Int = 0
    var store_id: String = ""
    var store_name: String = ""
    var store_name_eng: String = ""
    
    var upload_files: [(field_name: String, file_name: String, file_data: Data, file_size: Int)] = []
}

class GoodsOptionData {
    
    var color: String = ""
    var price: Int = 0
    var quantity: Int = 0
    var sequence: Int = 0
    var size: String = ""
    var sold_out: Bool = false
}

func setGoods(goodsDict: [String: Any]) -> GoodsData {
    
    let goodsValue = GoodsData()
    goodsValue.user_id = goodsDict["user_id"] as? String ?? ""
    goodsValue.item_key = goodsDict["item_key"] as? String ?? ""
    goodsValue.item_mainphoto_img = goodsDict["item_mainphoto_img"] as? String ?? ""
    goodsValue.item_photo_imgs = goodsDict["item_photo_imgs"] as? [String] ?? []
    if goodsValue.item_mainphoto_img != "" { goodsValue.item_photo_imgs.insert(goodsValue.item_mainphoto_img, at: 0) }
    goodsValue.item_category_name = goodsDict["item_category_name"] as? [String] ?? []
    goodsValue.item_name = goodsDict["item_name"] as? String ?? ""
    goodsValue.item_sale = Bool(goodsDict["item_sale"] as? String ?? "") ?? false
    goodsValue.item_price = goodsDict["item_price"] as? Int ?? 0
    goodsValue.item_sale_price = goodsDict["item_sale_price"] as? Int ?? 0
    goodsValue.item_colors = goodsDict["item_colors"] as? [String] ?? []
    goodsValue.item_sizes = goodsDict["item_sizes"] as? [String] ?? []
    goodsValue.item_materials = goodsDict["item_materials"] as? [String] ?? []
    goodsValue.item_material_washing = goodsDict["item_material_washing"] as? [String: Any] ?? [:]
    goodsValue.item_style = goodsDict["item_style"] as? String ?? ""
    goodsValue.item_content = goodsDict["item_content"] as? String ?? ""
    goodsValue.item_content_imgs = goodsDict["item_content_imgs"] as? [String] ?? []
    goodsValue.item_build = goodsDict["item_build"] as? String ?? ""
    goodsValue.item_sheet = goodsDict["item_sheet"] as? String ?? ""
    goodsValue.item_manufacture_country = goodsDict["item_sheet"] as? String ?? ""
    goodsValue.item_disclosure = goodsDict["item_disclosure"] as? String ?? ""
    goodsValue.item_soldout = Bool(goodsDict["item_soldout"] as? String ?? "") ?? false
    goodsValue.item_soldout_time = goodsDict["item_soldout_time"] as? String ?? ""
    goodsValue.item_pullup_time = goodsDict["item_pullup_time"] as? String ?? ""
    goodsValue.item_click_count = goodsDict["item_click_count"] as? Int ?? 0
    goodsValue.item_order_count = goodsDict["item_order_count"] as? Int ?? 0
    goodsValue.item_exposure_count = goodsDict["item_exposure_count"] as? Int ?? 0
    goodsValue.item_favorite_count = goodsDict["item_favorite_count"] as? Int ?? 0
    goodsValue.item_top_check = Bool(goodsDict["item_top_check"] as? String ?? "false") ?? false
    goodsValue.item_top_grade = goodsDict["item_top_grade"] as? Int ?? 0
    (goodsDict["item_option"] as? [Any] ?? []).forEach { data in
        let goodsOptionDict = data as? [String: Any] ?? [:]
        let goodsOptionValue = GoodsOptionData()
        goodsOptionValue.color = goodsOptionDict["color"] as? String ?? ""
        goodsOptionValue.price = goodsOptionDict["price"] as? Int ?? 0
        goodsOptionValue.quantity = goodsOptionDict["quantity"] as? Int ?? 0
        goodsOptionValue.size = goodsOptionDict["size"] as? String ?? ""
        goodsOptionValue.sold_out = Bool(goodsOptionDict["sold_out"] as? String ?? "false") ?? false
        /// 데이터 추가
        goodsValue.item_option.append(goodsOptionValue)
    }
    goodsValue.store_id = goodsDict["store_id"] as? String ?? ""
    goodsValue.store_name = goodsDict["store_name"] as? String ?? ""
    goodsValue.store_name_eng = goodsDict["store_name_eng"] as? String ?? ""
    /// 데이터 추가
    return goodsValue
}

class BasketData {
    
    var choice: Bool = true
    var basket_key: String = ""
    var item_price: Int = 0
    var item_key: String = ""
    var item_name: String = ""
    var item_option: [(color: String, price: Int, quantity: Int, size: String, sold_out: Bool)] = []
    var item_mainphoto_img: String = ""
    var item_sale: Bool = false
    var item_sale_price: Int = 0
    var item_total_price: Int = 0
    var item_total_quantity: Int = 0
    var re_store_id: String = ""
    var wh_store_id: String = ""
    var store_name: String = ""
    var user_id: String = ""
}

func setBasket(basketDict: [String: Any]) -> BasketData {
    
    let basketValue = BasketData()
    basketValue.basket_key = basketDict["basket_key"] as? String ?? ""
    basketValue.item_price = basketDict["item_price"] as? Int ?? 0
    basketValue.item_key = basketDict["item_key"] as? String ?? ""
    basketValue.item_name = basketDict["item_name"] as? String ?? ""
    (basketDict["item_option"] as? [Any] ?? []).forEach { data in
        let basketOptionDict = data as? [String: Any] ?? [:]
        /// 데이터 추가
        basketValue.item_option.append((
            color: basketOptionDict["color"] as? String ?? "",
            price: basketOptionDict["price"] as? Int ?? 0,
            quantity: basketOptionDict["quantity"] as? Int ?? 0,
            size: basketOptionDict["size"] as? String ?? "",
            sold_out: Bool(basketOptionDict["sold_out"] as? String ?? "false") ?? false
        ))
    }
    basketValue.item_mainphoto_img = basketDict["item_mainphoto_img"] as? String ?? ""
    basketValue.item_sale = basketDict["item_sale"] as? Bool ?? false
    basketValue.item_sale_price = basketDict["item_sale_price"] as? Int ?? 0
    basketValue.item_total_price = basketDict["item_total_price"] as? Int ?? 0
    basketValue.item_total_quantity = basketDict["item_total_quantity"] as? Int ?? 0
    basketValue.re_store_id = basketDict["re_store_id"] as? String ?? ""
    basketValue.wh_store_id = basketDict["wh_store_id"] as? String ?? ""
    basketValue.store_name = basketDict["store_name"] as? String ?? ""
    basketValue.user_id = basketDict["user_id"] as? String ?? ""
    /// 데이터 추가
    return basketValue
}

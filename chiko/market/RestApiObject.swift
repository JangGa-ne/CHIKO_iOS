//
//  RestApiObject.swift
//  market
//
//  Created by 장 제현 on 2023/10/16.
//

import UIKit

let material_washing = [
    "thickness": ["두꺼움": 0, "보통": 1, "얇음": 2],
    "see_through": ["있음": 3, "보통": 4, "없음": 5],
    "flexibility": ["좋음": 6, "보통": 7, "없음": 8],
    "lining": ["있음": 9, "없음": 10, "기모안감": 11],
    "washing": ["손세탁": 12, "드라이클리닝": 13, "물세탁": 14, "단독세탁": 15, "울세탁": 16, "표백제사용금지": 17, "다림질금지": 18, "세탁기금지": 19]
]

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

class BuildingData {
    
    var building_name: [String] = []
    var building_floor: [String] = []
    var building_room: [String] = []
}

class VisitData {
    
    var StoreObject: StoreData = StoreData()
    var ReGoodsArray_top: [GoodsData] = []
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
    var my_store: String = ""
    var topics: [String: Any] = [:]
    var waiting_step: Int = 0
    // 소매자
    var member_idcard_img: String = ""
    
    var upload_profile_img: [(file_name: String, file_data: Data, file_size: Int)] = []
    var upload_member_idcard_img: [(file_name: String, file_data: Data, file_size: Int)] = []
    
    var upload_files: [(field_name: String, file_name: String, file_data: Data, file_size: Int)] = []
    var load: Bool = false
}

func setMember(memberDict: [String: Any]) -> MemberData {
    
    let memberValue = MemberData()
    memberValue.end_session_time = memberDict["end_session_time"] as? String ?? ""
    memberValue.fcm_id = memberDict["fcm_id"] as? String ?? ""
    memberValue.marketing_agree = Bool(memberDict["marketing_agree"] as? String ?? "false") ?? false
    memberValue.marketing_agree_type = memberDict["marketing_agree_type"] as? [String] ?? []
    memberValue.member_grade = memberDict["member_position"] as? String ?? ""
    memberValue.my_store = memberDict["my_store"] as? String ?? ""
    memberValue.profile_img = memberDict["profile_img"] as? String ?? ""
    memberValue.session_id = memberDict["session_id"] as? String ?? ""
    memberValue.session_time = memberDict["session_time"] as? String ?? ""
    memberValue.signup_time = memberDict["signup_time"] as? String ?? ""
    memberValue.member_email = memberDict["user_email"] as? String ?? ""
    memberValue.member_id = memberDict["user_id"] as? String ?? ""
    memberValue.member_name = memberDict["user_name"] as? String ?? ""
    memberValue.member_num = memberDict["user_num"] as? String ?? ""
    memberValue.member_pw = memberDict["user_pw"] as? String ?? ""
    memberValue.member_type = memberDict["user_type"] as? String ?? ""
    memberValue.member_idcard_img = memberDict["user_idcard_img"] as? String ?? ""
    memberValue.topics = memberDict["topics"] as? [String: Any] ?? [:]
    memberValue.waiting_step = Int(memberDict["waiting_step"] as? String ?? "0") ?? 0
    /// 데이터 추가
    return memberValue
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
    var store_cash: Int = 0
    var best_item: [String] = []
    var best_position: Int = 0
    // 소매자
    var onoff_type: String = "" // "online", "offline", "onoffline"
    var store_domain: String = "" // offline 일때
    var store_address_street: String = "" // offline 일때
    var store_address_detail: String = "" // offline 일때
    var store_address_zipcode: String = "" // offline 일때
    var summary_address: String = ""
    var store_favorites: [String] = []
    var store_delivery: [(address: String, address_detail: String, address_zipcode: String, name: String, nickname: String, num: String)] = []
    var store_delivery_position: Int = 0
    var wechat_id: String = ""
    // 도매자
    var account_counting: Int = 0
    var business_reg_num: String = ""
    var business_reg_status: Bool = true
    var business_reg_img: String = ""
    var building_contract_imgs: [String] = []
    var item_full_counting: Int = 0
    var item_account_counting: Int = 0
    var waiting_step: Int = 0
    
    var upload_store_mainphoto_img: [(file_name: String, file_data: Data, file_size: Int)] = []
    var upload_passbook_img: [(file_name: String, file_data: Data, file_size: Int)] = []
    var upload_business_reg_img: [(file_name: String, file_data: Data, file_size: Int)] = []
    var upload_building_contract_imgs: [(file_name: String, file_data: Data, file_size: Int)] = []
    
    var upload_files: [(field_name: String, file_name: String, file_data: Data, file_size: Int)] = []
    var load: Bool = false
}

func setStore(storeDict: [String: Any]) -> StoreData {
    
    let storeValue = StoreData()
    storeValue.account = storeDict["account"] as? [String: Any] ?? [:]
    storeValue.account_counting = storeDict["account_counting"] as? Int ?? 0
    storeValue.business_reg_num = storeDict["business_reg_num"] as? String ?? ""
    storeValue.business_reg_img = storeDict["business_reg_img"] as? String ?? ""
    storeValue.building_contract_imgs = storeDict["building_contract_imgs"] as? [String] ?? []
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
    storeValue.store_cash = storeDict["store_cash"] as? Int ?? 0
    storeValue.store_address_street = storeDict["store_address"] as? String ?? ""
    storeValue.store_address_detail = storeDict["store_address_detail"] as? String ?? ""
    storeValue.store_address_zipcode = storeDict["store_address_zipcode"] as? String ?? ""
    storeValue.summary_address = storeDict["summary_address"] as? String ?? ""
    storeValue.wechat_id = storeDict["wechat_id"] as? String ?? ""
    storeValue.store_domain = storeDict["store_domain"] as? String ?? ""
    storeValue.store_favorites = storeDict["store_favorites"] as? [String] ?? []
    (storeDict["store_delivery"] as? Array<[String: Any]> ?? []).forEach { dict in
        storeValue.store_delivery.append((
            address: dict["address"] as? String ?? "",
            address_detail: dict["address_detail"] as? String ?? "",
            address_zipcode: dict["address_zipcode"] as? String ?? "",
            name: dict["name"] as? String ?? "",
            nickname: dict["nickname"] as? String ?? "",
            num: dict["num"] as? String ?? ""
        ))
    }
    storeValue.store_delivery_position = storeDict["store_delivery_position"] as? Int ?? 0
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
    storeValue.best_item = storeDict["best_item"] as? [String] ?? []
    storeValue.best_position = storeDict["best_position"] as? Int ?? 0
    /// 데이터 추가
    return storeValue
}

struct GoodsData {
    
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
    var item_build: String = "편물(니트/다이마루)"
    var item_sheet: String = ""
    var item_manufacture_country: String = "대한민국"
    var item_disclosure: String = "전체 공개"
    var item_soldout: Bool = false
    var item_soldout_time: String = ""
    var item_pullup_time: String = "0"
    var item_click_count: Int = 0
    var item_order_count: Int = 0
    var item_exposure_count: Int = 0
    var item_favorite_count: Int = 0
    var item_option: [ItemOptionData] = []
    var item_option_type: Bool = false
    var item_top_check: Bool = false
    var item_top_grade: Int = 0
    var store_id: String = ""
    var store_name: String = ""
    var store_name_eng: String = ""
    var store_mainphoto_img: String = ""
    
    var upload_files: [(field_name: String, file_name: String, file_data: Data, file_size: Int)] = []
}

class ItemOptionData {
    
    var color: String = ""
    var delivery_price: Int = 0
    var enter_date: String = ""
    var enter_quantity: Int = 0
    var enter_price: Int = 0
    var explain: String = ""
    var price: Int = 0
    var quantity: Int = 0
    var sequence: Int = 0
    var size: String = ""
    var sold_out: Bool = false
    var not_delivery_quantity: Int = 0
    var not_delivery_memo: String = ""
    var weight: Double = 0.0
}

func setGoods(goodsDict: [String: Any]) -> GoodsData {
    
    var goodsValue = GoodsData()
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
    goodsValue.item_manufacture_country = goodsDict["item_manufacture_country"] as? String ?? ""
    goodsValue.item_disclosure = goodsDict["item_disclosure"] as? String ?? ""
    goodsValue.item_soldout = Bool(goodsDict["item_soldout"] as? String ?? "") ?? false
    goodsValue.item_soldout_time = goodsDict["item_soldout_time"] as? String ?? ""
    goodsValue.item_pullup_time = goodsDict["item_pullup_time"] as? String ?? "0"
    goodsValue.item_click_count = goodsDict["item_click_count"] as? Int ?? 0
    goodsValue.item_order_count = goodsDict["item_order_count"] as? Int ?? 0
    goodsValue.item_exposure_count = goodsDict["item_exposure_count"] as? Int ?? 0
    goodsValue.item_favorite_count = goodsDict["item_favorite_count"] as? Int ?? 0
    goodsValue.item_top_check = Bool(goodsDict["item_top_check"] as? String ?? "false") ?? false
    goodsValue.item_top_grade = goodsDict["item_top_grade"] as? Int ?? 0
    (goodsDict["item_option"] as? Array<[String: Any]> ?? []).forEach { dict in
        let itemOptionValue = ItemOptionData()
        itemOptionValue.color = dict["color"] as? String ?? ""
        itemOptionValue.delivery_price = dict["delivery_price"] as? Int ?? 0
        itemOptionValue.price = dict["price"] as? Int ?? 0
        itemOptionValue.quantity = dict["quantity"] as? Int ?? 0
        itemOptionValue.size = dict["size"] as? String ?? ""
        itemOptionValue.sold_out = Bool(dict["sold_out"] as? String ?? "false") ?? false
        itemOptionValue.weight = dict["weight"] as? Double ?? 0.0
        goodsValue.item_option.append(itemOptionValue)
    }
    goodsValue.item_option_type = Bool(goodsDict["item_option_type"] as? String ?? "false") ?? false
    goodsValue.store_id = goodsDict["store_id"] as? String ?? ""
    goodsValue.store_name = goodsDict["store_name"] as? String ?? ""
    goodsValue.store_name_eng = goodsDict["store_name_eng"] as? String ?? ""
    goodsValue.store_mainphoto_img = goodsDict["store_mainphoto_img"] as? String ?? ""
    /// 데이터 추가
    return goodsValue
}

class BasketData {
    
    var load: Bool = false
    var choice: Bool = true
    var basket_key: String = ""
    var item_price: Int = 0
    var item_key: String = ""
    var item_name: String = ""
    var item_option: [ItemOptionData] = []
    var item_mainphoto_img: String = ""
    var item_sale: Bool = false
    var item_sale_price: Int = 0
    var item_total_price: Int = 0
    var item_total_quantity: Int = 0
    var re_store_id: String = ""
    var wh_store_id: String = ""
    var store_id: String = ""
    var store_name: String = ""
    var store_name_eng: String = ""
    var user_id: String = ""
}

func setBasket(basketDict: [String: Any]) -> BasketData {
    
    let basketValue = BasketData()
    basketValue.basket_key = basketDict["basket_key"] as? String ?? ""
    basketValue.item_price = basketDict["item_price"] as? Int ?? 0
    basketValue.item_key = basketDict["item_key"] as? String ?? ""
    basketValue.item_name = basketDict["item_name"] as? String ?? ""
    (basketDict["item_option"] as? Array<[String: Any]> ?? []).forEach { dict in
        let itemOptionValue = ItemOptionData()
        itemOptionValue.color = dict["color"] as? String ?? ""
        itemOptionValue.delivery_price = dict["delivery_price"] as? Int ?? 0
        itemOptionValue.price = dict["price"] as? Int ?? 0
        itemOptionValue.quantity = dict["quantity"] as? Int ?? 0
        itemOptionValue.size = dict["size"] as? String ?? ""
        itemOptionValue.sold_out = Bool(dict["sold_out"] as? String ?? "false") ?? false
        basketValue.item_option.append(itemOptionValue)
    }
    basketValue.item_mainphoto_img = basketDict["item_mainphoto_img"] as? String ?? ""
    basketValue.item_sale = Bool(basketDict["item_sale"] as? String ?? "false") ?? false
    basketValue.item_sale_price = basketDict["item_sale_price"] as? Int ?? 0
    basketValue.item_total_price = basketDict["item_total_price"] as? Int ?? 0
    basketValue.item_total_quantity = basketDict["item_total_quantity"] as? Int ?? 0
    basketValue.re_store_id = basketDict["re_store_id"] as? String ?? ""
    basketValue.wh_store_id = basketDict["wh_store_id"] as? String ?? ""
    basketValue.store_id = basketDict["store_id"] as? String ?? ""
    basketValue.store_name = basketDict["store_name"] as? String ?? ""
    basketValue.store_name_eng = basketDict["store_name_eng"] as? String ?? ""
    basketValue.user_id = basketDict["user_id"] as? String ?? ""
    /// 데이터 추가
    return basketValue
}

class ReOrderData {
    
    var total_delivery_weight: Double = 0.0
    var ch_total_delivery_price: Double = 0.0
    var ch_total_item_price: Double = 0.0
    var kr_total_delivery_price: Int = 0
    var kr_total_item_price: Int = 0
    var delivery_address: String = ""
    var delivery_address_detail: String = ""
    var delivery_name: String = ""
    var delivery_nickname: String = ""
    var delivery_num: String = ""
    var delivery_tracking_num: String = ""
    var delivery_price_state: Bool = false
    var order_datetime: String = ""
    var order_id: String = ""
    var order_item: [ReOrderItemData] = []
    var order_key: String = ""
    var order_memo: String = ""
    var order_name: String = ""
    var order_num: String = ""
    var order_grade: String = ""
    var order_state: String = ""
    var order_store_id: String = ""
    var order_store_name: String = ""
    var order_store_eng: String = ""
    var payment_type: String = ""
    var receipt_key: String = ""
    var vat_total_price: Int = 0
}

func setReOrder(orderDict: [String: Any]) -> ReOrderData {
    
    let orderValue = ReOrderData()
    orderValue.total_delivery_weight = orderDict["total_delivery_weight"] as? Double ?? 0.0
    orderValue.ch_total_delivery_price = orderDict["ch_total_delivery_price"] as? Double ?? 0.0
    orderValue.ch_total_item_price = orderDict["ch_total_item_price"] as? Double ?? 0.0
    orderValue.kr_total_delivery_price = orderDict["kr_total_delivery_price"] as? Int ?? 0
    orderValue.kr_total_item_price = orderDict["kr_total_item_price"] as? Int ?? 0
    orderValue.delivery_address = orderDict["delivery_address"] as? String ?? ""
    orderValue.delivery_address_detail = orderDict["delivery_address_detail"] as? String ?? ""
    orderValue.delivery_name = orderDict["delivery_name"] as? String ?? ""
    orderValue.delivery_nickname = orderDict["delivery_nickname"] as? String ?? ""
    orderValue.delivery_num = orderDict["delivery_num"] as? String ?? ""
    orderValue.delivery_tracking_num = orderDict["delivery_tracking_num"] as? String ?? ""
    orderValue.delivery_price_state = Bool(orderDict["delivery_price_state"] as? String ?? "false") ?? false
    orderValue.order_datetime = orderDict["order_datetime"] as? String ?? ""
    orderValue.order_id = orderDict["order_id"] as? String ?? ""
    (orderDict["order_item"] as? Array<[String: Any]> ?? []).forEach { dict in
        orderValue.order_item.append(setReOrderItem(orderItemDict: dict))
    }
    orderValue.order_key = orderDict["order_key"] as? String ?? ""
    orderValue.order_memo = orderDict["order_memo"] as? String ?? ""
    orderValue.order_name = orderDict["order_name"] as? String ?? ""
    orderValue.order_num = orderDict["order_num"] as? String ?? ""
    orderValue.order_grade = orderDict["order_grade"] as? String ?? ""
    orderValue.order_state = orderDict["order_state"] as? String ?? ""
    orderValue.order_store_id = orderDict["order_store_id"] as? String ?? ""
    orderValue.order_store_name = orderDict["order_store_name"] as? String ?? ""
    orderValue.order_store_eng = orderDict["order_store_eng"] as? String ?? ""
    orderValue.payment_type = orderDict["payment_type"] as? String ?? ""
    orderValue.receipt_key = orderDict["receipt_key"] as? String ?? ""
    orderValue.vat_total_price = orderDict["vat_total_price"] as? Int ?? 0
    
    return orderValue
}

class ReOrderItemData {
    
    var load: Bool = false
    var delivery_state: String = ""
    var explain: String = ""
    var item_key: String = ""
    var item_mainphoto_img: String = ""
    var item_name: String = ""
    var item_option: [ItemOptionData] = []
    var item_price: Int = 0
    var item_sale: Bool = false
    var item_sale_price: Int = 0
    var store_id: String = ""
    var store_name: String = ""
    var store_name_eng: String = ""
    var item_total_price: Int = 0
    var item_total_quantity: Int = 0
    var order_state: String = ""
}

func setReOrderItem(orderItemDict: [String: Any]) -> ReOrderItemData {
    
    let orderItemValue = ReOrderItemData()
    orderItemValue.delivery_state = orderItemDict["delivery_state"] as? String ?? ""
    orderItemValue.explain = orderItemDict["explain"] as? String ?? ""
    orderItemValue.item_key = orderItemDict["item_key"] as? String ?? ""
    orderItemValue.item_mainphoto_img = orderItemDict["item_mainphoto_img"] as? String ?? ""
    orderItemValue.item_name = orderItemDict["item_name"] as? String ?? ""
    (orderItemDict["item_option"] as? Array<[String: Any]> ?? []).forEach { dict in
        let itemOptionValue = ItemOptionData()
        itemOptionValue.color = dict["color"] as? String ?? ""
        itemOptionValue.delivery_price = dict["delivery_price"] as? Int ?? 0
        itemOptionValue.enter_date = dict["date"] as? String ?? ""
        itemOptionValue.enter_quantity = dict["enter_quantity"] as? Int ?? 0
        itemOptionValue.explain = dict["explain"] as? String ?? ""
        itemOptionValue.price = dict["price"] as? Int ?? 0
        itemOptionValue.quantity = dict["quantity"] as? Int ?? 0
        itemOptionValue.size = dict["size"] as? String ?? ""
        itemOptionValue.weight = dict["weight"] as? Double ?? 0.0
        orderItemValue.item_option.append(itemOptionValue)
    }
    orderItemValue.item_price = orderItemDict["item_price"] as? Int ?? 0
    orderItemValue.item_sale = Bool(orderItemDict["item_sale"] as? Bool ?? false)
    orderItemValue.item_sale_price = orderItemDict["item_sale_price"] as? Int ?? 0
    orderItemValue.store_id = orderItemDict["store_id"] as? String ?? ""
    orderItemValue.store_name = orderItemDict["store_name"] as? String ?? ""
    orderItemValue.store_name_eng = orderItemDict["store_name_eng"] as? String ?? ""
    orderItemValue.item_total_price = orderItemDict["item_total_price"] as? Int ?? 0
    orderItemValue.item_total_quantity = orderItemDict["item_total_quantity"] as? Int ?? 0
    orderItemValue.order_state = orderItemDict["order_state"] as? String ?? ""
    
    return orderItemValue
}

class WhCountingData {
    
    var before_payment: Int = 0
    var in_stock: Int = 0
    var inspecting: Int = 0
    var pending: Int = 0
    var preparing: Int = 0
    var complete: Int = 0
    var cancel: Int = 0
}

func setWhCounting(countingDict: [String: Any]) -> WhCountingData {
    
    let countingValue = WhCountingData()
    countingValue.before_payment = countingDict["before_payment"] as? Int ?? 0
    countingValue.in_stock = countingDict["in_stock"] as? Int ?? 0
    countingValue.inspecting = countingDict["inspecting"] as? Int ?? 0
    countingValue.pending = countingDict["pending"] as? Int ?? 0
    countingValue.preparing = countingDict["preparing"] as? Int ?? 0
    countingValue.complete = countingDict["complete"] as? Int ?? 0
    countingValue.cancel = countingDict["cancel"] as? Int ?? 0
    
    return countingValue
}

class WhOrderData {
    
    var calculate: String = ""
    var calculate_datetime: String = ""
    var enter_price: Int = 0
    var ch_total_item_price: Double = 0.0
    var ch_vat_total_price: Int = 0
    var delivery_state: String = ""
    var item_key: String = ""
    var item_name: String = ""
    var item_option: [ItemOptionData] = []
    var item_sale_price: Int = 0
    var kr_total_item_price: Int = 0
    var kr_vat_total_price: Int = 0
    var order_date: String = ""
    var processing_key: String = ""
}

func setWhOrder(orderDict: [String: Any]) -> WhOrderData {
    
    let orderValue = WhOrderData()
    orderValue.calculate = orderDict["calculate"] as? String ?? ""
    orderValue.calculate_datetime = orderDict["calculate_datetime"] as? String ?? ""
    orderValue.enter_price = orderDict["cal_price"] as? Int ?? 0
    orderValue.ch_total_item_price = orderDict["ch_total_item_price"] as? Double ?? 0.0
    orderValue.ch_vat_total_price = orderDict["ch_vat_total_price"] as? Int ?? 0
    orderValue.delivery_state = orderDict["delivery_state"] as? String ?? ""
    orderValue.item_key = orderDict["item_key"] as? String ?? ""
    orderValue.item_name = orderDict["item_name"] as? String ?? ""
    (orderDict["item_option"] as? Array<[String: Any]> ?? []).forEach { dict in
        let itemOptionValue = ItemOptionData()
        itemOptionValue.color = dict["color"] as? String ?? ""
        itemOptionValue.enter_price = dict["cal_price"] as? Int ?? 0
        itemOptionValue.enter_quantity = dict["enter_quantity"] as? Int ?? 0
        itemOptionValue.delivery_price = dict["delivery_price"] as? Int ?? 0
        itemOptionValue.price = dict["price"] as? Int ?? 0
        itemOptionValue.quantity = dict["quantity"] as? Int ?? 0
        itemOptionValue.size = dict["size"] as? String ?? ""
        orderValue.item_option.append(itemOptionValue)
    }
    orderValue.item_sale_price = orderDict["item_sale_price"] as? Int ?? 0
    orderValue.kr_total_item_price = orderDict["kr_total_item_price"] as? Int ?? 0
    orderValue.kr_vat_total_price = orderDict["kr_vat_total_price"] as? Int ?? 0
    orderValue.order_date = orderDict["order_date"] as? String ?? ""
    orderValue.processing_key = orderDict["processing_key"] as? String ?? ""
    
    return orderValue
}

class WhNotDeliveryData {
    
    var ch_total_item_price: Double = 0.0
    var ch_vat_total_price: Int = 0
    var delivery_state: String = ""
    var item_key: String = ""
    var item_name: String = ""
    var item_option: [ItemOptionData] = []
    var item_sale_price: Int = 0
    var kr_total_item_price: Int = 0
    var kr_vat_total_price: Int = 0
    var order_date: String = ""
    var processing_key: String = ""
}

func setWhNotDelivery(notDeliveryDict: [String: Any]) -> WhNotDeliveryData {
    
    let notDeliveryValue = WhNotDeliveryData()
    notDeliveryValue.ch_total_item_price = notDeliveryDict["ch_total_item_price"] as? Double ?? 0.0
    notDeliveryValue.ch_vat_total_price = notDeliveryDict["ch_vat_total_price"] as? Int ?? 0
    notDeliveryValue.delivery_state = notDeliveryDict["delivery_state"] as? String ?? ""
    notDeliveryValue.item_key = notDeliveryDict["item_key"] as? String ?? ""
    notDeliveryValue.item_name = notDeliveryDict["item_name"] as? String ?? ""
    (notDeliveryDict["item_option"] as? Array<[String: Any]> ?? []).forEach { dict in
        let itemOptionValue = ItemOptionData()
        itemOptionValue.color = dict["color"] as? String ?? ""
        itemOptionValue.delivery_price = dict["delivery_price"] as? Int ?? 0
        itemOptionValue.price = dict["price"] as? Int ?? 0
        itemOptionValue.quantity = dict["quantity"] as? Int ?? 0
        itemOptionValue.size = dict["size"] as? String ?? ""
        itemOptionValue.not_delivery_quantity = dict["not_delivery_quantity"] as? Int ?? 0
        itemOptionValue.not_delivery_memo = dict["not_delivery_memo"] as? String ?? ""
        notDeliveryValue.item_option.append(itemOptionValue)
    }
    notDeliveryValue.item_sale_price = notDeliveryDict["item_sale_price"] as? Int ?? 0
    notDeliveryValue.kr_total_item_price = notDeliveryDict["kr_total_item_price"] as? Int ?? 0
    notDeliveryValue.kr_vat_total_price = notDeliveryDict["kr_vat_total_price"] as? Int ?? 0
    notDeliveryValue.order_date = notDeliveryDict["order_date"] as? String ?? ""
    notDeliveryValue.processing_key = notDeliveryDict["processing_key"] as? String ?? ""
    
    return notDeliveryValue
}

class ReEnquiryReceiptData {
    
    var load: Bool = false
    var attached_imgs: [String] = []
    var content: String = ""
    var direction: String = ""
    var store_id: String = ""
    var store_name: String = ""
    var read_or_not: Bool = false
    var requested_store_name: String = ""
    var summary_address: String = ""
    var time: String = ""
    var order_key: String = ""
    var order_item: [(
        explain: String,
        item_name: String,
        item_category_name: [String],
        item_option: [ItemOptionData],
        item_total_price: Int
    )] = []
    
    var upload_attached_imgs: [(file_name: String, file_data: Data, file_size: Int)] = []
    var upload_files: [(field_name: String, file_name: String, file_data: Data, file_size: Int)] = []
}

func setReEnquiryReceipt(enquiryReceiptDict: [String: Any]) -> ReEnquiryReceiptData {
    
    let enquiryReceiptValue = ReEnquiryReceiptData()
    enquiryReceiptValue.attached_imgs = enquiryReceiptDict["attached_imgs"] as? [String] ?? []
    enquiryReceiptValue.content = enquiryReceiptDict["content"] as? String ?? ""
    enquiryReceiptValue.direction = enquiryReceiptDict["direction"] as? String ?? ""
    enquiryReceiptValue.store_id = enquiryReceiptDict["store_id"] as? String ?? ""
    enquiryReceiptValue.store_name = enquiryReceiptDict["store_name"] as? String ?? ""
    enquiryReceiptValue.read_or_not = Bool(enquiryReceiptDict["read_or_not"] as? String ?? "false") ?? false
    enquiryReceiptValue.requested_store_name = enquiryReceiptDict["requested_store_name"] as? String ?? ""
    enquiryReceiptValue.summary_address = enquiryReceiptDict["summary_address"] as? String ?? ""
    enquiryReceiptValue.time = enquiryReceiptDict["time"] as? String ?? ""
    enquiryReceiptValue.order_key = enquiryReceiptDict["order_key"] as? String ?? ""
    (enquiryReceiptDict["order_item"] as? Array<[String: Any]> ?? []).forEach { dict in
        var itemOptionArray: [ItemOptionData] = []
        (dict["item_option"] as? Array<[String: Any]> ?? []).forEach { dict in
            let itemOptionValue = ItemOptionData()
            itemOptionValue.color = dict["color"] as? String ?? ""
            itemOptionValue.delivery_price = dict["delivery_price"] as? Int ?? 0
            itemOptionValue.enter_date = dict["date"] as? String ?? ""
            itemOptionValue.enter_quantity = dict["enter_quantity"] as? Int ?? 0
            itemOptionValue.explain = dict["explain"] as? String ?? ""
            itemOptionValue.size = dict["size"] as? String ?? ""
            itemOptionValue.quantity = dict["quantity"] as? Int ?? 0
            itemOptionValue.price = dict["price"] as? Int ?? 0
            itemOptionValue.weight = dict["weight"] as? Double ?? 0.0
            itemOptionArray.append(itemOptionValue)
        }
        enquiryReceiptValue.order_item.append((
            explain: dict["explain"] as? String ?? "",
            item_name: dict["item_name"] as? String ?? "",
            item_category_name: dict["item_category_name"] as? [String] ?? [],
            item_option: itemOptionArray,
            item_total_price: dict["item_total_price"] as? Int ?? 0
        ))
    }
    
    return enquiryReceiptValue
}

class StoreCashData {
    
    var datetime: String = ""
    var ch_cash: Double = 0.0
    var kr_cash: Int = 0
    var receipt_id: String = ""
    var use_cash: Bool = false
    var use_where: String = ""
}

func setStoreCash(storeCashDict: [String: Any]) -> StoreCashData {
    
    let storeCashValue = StoreCashData()
    storeCashValue.datetime = storeCashDict["datetime"] as? String ?? ""
    storeCashValue.ch_cash = storeCashDict["ch_cash"] as? Double ?? 0.0
    storeCashValue.kr_cash = storeCashDict["kr_cash"] as? Int ?? 0
    storeCashValue.receipt_id = storeCashDict["receipt_id"] as? String ?? ""
    storeCashValue.use_cash = Bool(storeCashDict["use_cash"] as? String ?? "false") ?? false
    storeCashValue.use_where = storeCashDict["use_where"] as? String ?? ""
    
    return storeCashValue
}

class InventoryOption {
    
    var color: String = ""
    var date: String = ""
    var price: Int = 0
    var quantity: Int = 0
    var requested_quantity: Int = 0
    var size: String = ""
    var sold_out: Bool = false
    var total_option_quantity: Int = 0
    var weight: Double = 0.0
}

class InventoryData {
    
    var position: Int = 0
    var item_key: String = ""
    var item_name: String = ""
    var item_option: [InventoryOption] = []
    var total_order_price: Int = 0
    var total_order_quantity: Int = 0
}

func setInventory(inventoryDict: [String: Any]) -> InventoryData {
    
    let inventoryValue = InventoryData()
    inventoryValue.item_key = inventoryDict["item_key"] as? String ?? ""
    inventoryValue.item_name = inventoryDict["item_name"] as? String ?? ""
    (inventoryDict["item_option"] as? Array<[String: Any]> ?? []).forEach { dict in
        let inventoryOptionValue = InventoryOption()
        inventoryOptionValue.color = dict["color"] as? String ?? ""
        inventoryOptionValue.date = dict["date"] as? String ?? ""
        inventoryOptionValue.price = dict["price"] as? Int ?? 0
        inventoryOptionValue.quantity = dict["quantity"] as? Int ?? 0
        inventoryOptionValue.requested_quantity = dict["requested_quantity"] as? Int ?? 0
        inventoryOptionValue.size = dict["size"] as? String ?? ""
        inventoryOptionValue.sold_out = Bool(dict["sold_out"] as? String ?? "false") ?? false
        inventoryOptionValue.total_option_quantity = dict["total_option_quantity"] as? Int ?? 0
        inventoryOptionValue.weight = dict["weight"] as? Double ?? 0.0
        inventoryValue.item_option.append(inventoryOptionValue)
    }
    inventoryValue.total_order_price = inventoryDict["total_order_price"] as? Int ?? 0
    inventoryValue.total_order_quantity = inventoryDict["total_order_quantity"] as? Int ?? 0
    
    return inventoryValue
}

class PaymentData {
    
    var exchange_diff: String = ""
    var dpcostperkg: Int = 0
    var exchange_rate: Double = 0.0
}

func setPayment(paymentDict: [String: Any]) -> PaymentData {
    
    let paymentValue = PaymentData()
    paymentValue.exchange_diff = paymentDict["exchange_diff"] as? String ?? ""
    paymentValue.dpcostperkg = paymentDict["dpcostperkg"] as? Int ?? 0
    paymentValue.exchange_rate = paymentDict["exchange_rate"] as? Double ?? 0.0
    
    return paymentValue
}

class ReceiptData {
    
    var AuthCode: String = ""
    var AuthDate: String = ""
    var BuyerEmail: String = ""
    var MID: String = ""
    var Amt: String = ""
    var TID: String = ""
    var GoodsName: String = ""
    var MallReserved: String = ""
    var Currency: String = ""
    var PayMethod: String = ""
    var name: String = ""
    var mallUserID: String = ""
    var MOID: String = ""
    var ResultMsg: String = ""
    var ResultCode: String = ""
    var weight: Double = 0.0
    var kr_price: Int = 0
    var ch_price: Double = 0.0
    var gdre_key: String = ""
    var dpre_key: String = ""
    var order_key: String = ""
    var order_id: String = ""
    var order_name: String = ""
    var order_position: String = ""
    var order_datetime: String = ""
    var payment_type: String = ""
}

func setReceipt(receiptDict: [String: Any]) -> ReceiptData {
    
    let receiptValue = ReceiptData()
    receiptValue.AuthCode = receiptDict["AuthCode"] as? String ?? ""
    receiptValue.AuthDate = receiptDict["AuthDate"] as? String ?? ""
    receiptValue.BuyerEmail = receiptDict["BuyerEmail"] as? String ?? ""
    receiptValue.MID = receiptDict["MID"] as? String ?? ""
    receiptValue.Amt = receiptDict["Amt"] as? String ?? ""
    receiptValue.TID = receiptDict["TID"] as? String ?? ""
    receiptValue.GoodsName = receiptDict["GoodsName"] as? String ?? ""
    receiptValue.MallReserved = receiptDict["MallReserved"] as? String ?? ""
    receiptValue.Currency = receiptDict["Currency"] as? String ?? ""
    receiptValue.PayMethod = receiptDict["PayMethod"] as? String ?? ""
    receiptValue.name = receiptDict["name"] as? String ?? ""
    receiptValue.mallUserID = receiptDict["mallUserID"] as? String ?? ""
    receiptValue.MOID = receiptDict["MOID"] as? String ?? ""
    receiptValue.ResultMsg = receiptDict["ResultMsg"] as? String ?? ""
    receiptValue.ResultCode = receiptDict["ResultCode"] as? String ?? ""
    receiptValue.weight = receiptDict["weight"] as? Double ?? 0.0
    receiptValue.kr_price = receiptDict["kr_price"] as? Int ?? 0
    receiptValue.ch_price = receiptDict["ch_price"] as? Double ?? 0.0
    receiptValue.gdre_key = receiptDict["gdre_key"] as? String ?? ""
    receiptValue.dpre_key = receiptDict["dpre_key"] as? String ?? ""
    receiptValue.order_key = receiptDict["order_key"] as? String ?? ""
    receiptValue.order_id = receiptDict["order_id"] as? String ?? ""
    receiptValue.order_name = receiptDict["order_name"] as? String ?? ""
    receiptValue.order_position = receiptDict["order_position"] as? String ?? ""
    receiptValue.order_datetime = receiptDict["order_datetime"] as? String ?? ""
    receiptValue.payment_type = receiptDict["payment_type"] as? String ?? ""
    
    return receiptValue
}

class NoticeData {
    
    var board_index: String = ""
    var body: String = ""
    var datetime: String = ""
    var order_key: String = ""
    var read_or_not: Bool = false
    var segue: String = ""
    var title: String = ""
    var type: String = ""
}

func setNotice(noticeDict: [String: Any]) -> NoticeData {
    
    let noticeValue = NoticeData()
    noticeValue.board_index = noticeDict["board_index"] as? String ?? ""
    noticeValue.body = noticeDict["body"] as? String ?? ""
    noticeValue.datetime = noticeDict["datetime"] as? String ?? ""
    noticeValue.order_key = noticeDict["order_key"] as? String ?? ""
    noticeValue.read_or_not = Bool(noticeDict["read_or_not"] as? String ?? "false") ?? false
    noticeValue.segue = noticeDict["segue"] as? String ?? ""
    noticeValue.title = noticeDict["title"] as? String ?? ""
    noticeValue.type = noticeDict["type"] as? String ?? ""
    return noticeValue
}

class ChatsData {
    
    var content: String = ""
    var direction: String = ""
    var store_id: String = ""
    var read_or_not: Bool = false
    var time: String = ""
}

func setChats(chatsDict: [String: Any]) -> ChatsData {
    
    let chatsValue = ChatsData()
    chatsValue.content = chatsDict["content"] as? String ?? ""
    chatsValue.direction = chatsDict["direction"] as? String ?? ""
    chatsValue.store_id = chatsDict["store_id"] as? String ?? ""
    chatsValue.read_or_not = Bool(chatsDict["read_or_not"] as? String ?? "false") ?? false
    chatsValue.time = chatsDict["time"] as? String ?? ""
    return chatsValue
}

class ChatbotData {
    
    var content: String = ""
    var direction: String = ""
    var time: String = ""
}

func setChatbot(chatbotDict: [String: Any]) -> ChatbotData {
    
    let chatbotValue = ChatbotData()
    chatbotValue.content = chatbotDict["content"] as? String ?? ""
    chatbotValue.direction = chatbotDict["direction"] as? String ?? ""
    chatbotValue.time = chatbotDict["time"] as? String ?? ""
    return chatbotValue
}

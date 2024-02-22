//
//  RestApiObject.swift
//  market
//
//  Created by Busan Dynamic on 2023/10/16.
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
    var ReGoodsArray_best: [GoodsData] = []
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
    // 소매자
    var member_idcard_img: String = ""
    
    var upload_profile_img: [(file_name: String, file_data: Data, file_size: Int)] = []
    var upload_member_idcard_img: [(file_name: String, file_data: Data, file_size: Int)] = []
    
    var upload_files: [(field_name: String, file_name: String, file_data: Data, file_size: Int)] = []
    var load_img: Bool = false
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
    var upload_building_contract_imgs: [(file_name: String, file_data: Data, file_size: Int)] = []
    
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
    storeValue.store_cash = storeDict["store_cash"] as? Int ?? 0
    storeValue.store_address_street = storeDict["store_address"] as? String ?? ""
    storeValue.store_address_detail = storeDict["store_address_detail"] as? String ?? ""
    storeValue.store_address_zipcode = storeDict["store_address_zipcode"] as? String ?? ""
    storeValue.summary_address = storeDict["summary_address"] as? String ?? ""
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
    
    var upload_files: [(field_name: String, file_name: String, file_data: Data, file_size: Int)] = []
}

class ItemOptionData {
    
    var color: String = ""
    var price: Int = 0
    var quantity: Int = 0
    var sequence: Int = 0
    var size: String = ""
    var sold_out: Bool = false
    var not_delivery_quantity: Int = 0
    var not_delivery_memo: String = ""
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
        itemOptionValue.price = dict["price"] as? Int ?? 0
        itemOptionValue.quantity = dict["quantity"] as? Int ?? 0
        itemOptionValue.size = dict["size"] as? String ?? ""
        itemOptionValue.sold_out = Bool(dict["sold_out"] as? String ?? "false") ?? false
        goodsValue.item_option.append(itemOptionValue)
    }
    goodsValue.item_option_type = Bool(goodsDict["item_option_type"] as? String ?? "false") ?? false
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
    var item_option: [ItemOptionData] = []
    var item_mainphoto_img: String = ""
    var item_sale: Bool = false
    var item_sale_price: Int = 0
    var item_total_price: Int = 0
    var item_total_quantity: Int = 0
    var re_store_id: String = ""
    var wh_store_id: String = ""
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
        itemOptionValue.price = dict["price"] as? Int ?? 0
        itemOptionValue.quantity = dict["quantity"] as? Int ?? 0
        itemOptionValue.size = dict["size"] as? String ?? ""
        itemOptionValue.sold_out = Bool(dict["sold_out"] as? String ?? "false") ?? false
        basketValue.item_option.append(itemOptionValue)
    }
    basketValue.item_mainphoto_img = basketDict["item_mainphoto_img"] as? String ?? ""
    basketValue.item_sale = basketDict["item_sale"] as? Bool ?? false
    basketValue.item_sale_price = basketDict["item_sale_price"] as? Int ?? 0
    basketValue.item_total_price = basketDict["item_total_price"] as? Int ?? 0
    basketValue.item_total_quantity = basketDict["item_total_quantity"] as? Int ?? 0
    basketValue.re_store_id = basketDict["re_store_id"] as? String ?? ""
    basketValue.wh_store_id = basketDict["wh_store_id"] as? String ?? ""
    basketValue.store_name = basketDict["store_name"] as? String ?? ""
    basketValue.store_name_eng = basketDict["store_name_eng"] as? String ?? ""
    basketValue.user_id = basketDict["user_id"] as? String ?? ""
    /// 데이터 추가
    return basketValue
}

class ReOrderData {
    
    var cn_total_item_price: Int = 0
    var kr_total_item_price: Int = 0
    var delivery_address: String = ""
    var delivery_address_detail: String = ""
    var delivery_name: String = ""
    var delivery_nickname: String = ""
    var delivery_num: String = ""
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
    orderValue.cn_total_item_price = orderDict["cn_total_item_price"] as? Int ?? 0
    orderValue.kr_total_item_price = orderDict["kr_total_item_price"] as? Int ?? 0
    orderValue.delivery_address = orderDict["delivery_address"] as? String ?? ""
    orderValue.delivery_address_detail = orderDict["delivery_address_detail"] as? String ?? ""
    orderValue.delivery_name = orderDict["delivery_name"] as? String ?? ""
    orderValue.delivery_nickname = orderDict["delivery_nickname"] as? String ?? ""
    orderValue.delivery_num = orderDict["delivery_num"] as? String ?? ""
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
    
    var delivery_state: String = ""
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
}

func setReOrderItem(orderItemDict: [String: Any]) -> ReOrderItemData {
    
    let orderItemValue = ReOrderItemData()
    orderItemValue.delivery_state = orderItemDict["delivery_state"] as? String ?? ""
    orderItemValue.item_key = orderItemDict["item_key"] as? String ?? ""
    orderItemValue.item_mainphoto_img = orderItemDict["item_mainphoto_img"] as? String ?? ""
    orderItemValue.item_name = orderItemDict["item_name"] as? String ?? ""
    (orderItemDict["item_option"] as? Array<[String: Any]> ?? []).forEach { dict in
        let itemOptionValue = ItemOptionData()
        itemOptionValue.color = dict["color"] as? String ?? ""
        itemOptionValue.price = dict["price"] as? Int ?? 0
        itemOptionValue.quantity = dict["quantity"] as? Int ?? 0
        itemOptionValue.size = dict["size"] as? String ?? ""
        orderItemValue.item_option.append(itemOptionValue)
    }
    orderItemValue.item_price = orderItemDict["item_price"] as? Int ?? 0
    orderItemValue.item_sale = orderItemDict["item_sale"] as? Bool ?? false
    orderItemValue.item_sale_price = orderItemDict["item_sale_price"] as? Int ?? 0
    orderItemValue.store_id = orderItemDict["store_id"] as? String ?? ""
    orderItemValue.store_name = orderItemDict["store_name"] as? String ?? ""
    orderItemValue.store_name_eng = orderItemDict["store_name_eng"] as? String ?? ""
    orderItemValue.item_total_price = orderItemDict["item_total_price"] as? Int ?? 0
    orderItemValue.item_total_quantity = orderItemDict["item_total_quantity"] as? Int ?? 0
    
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
    
    var ch_total_item_price: Int = 0
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
    orderValue.ch_total_item_price = orderDict["ch_total_item_price"] as? Int ?? 0
    orderValue.ch_vat_total_price = orderDict["ch_vat_total_price"] as? Int ?? 0
    orderValue.delivery_state = orderDict["delivery_state"] as? String ?? ""
    orderValue.item_key = orderDict["item_key"] as? String ?? ""
    orderValue.item_name = orderDict["item_name"] as? String ?? ""
    (orderDict["item_option"] as? Array<[String: Any]> ?? []).forEach { dict in
        let itemOptionValue = ItemOptionData()
        itemOptionValue.color = dict["color"] as? String ?? ""
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
    
    var ch_total_item_price: Int = 0
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
    notDeliveryValue.ch_total_item_price = notDeliveryDict["ch_total_item_price"] as? Int ?? 0
    notDeliveryValue.ch_vat_total_price = notDeliveryDict["ch_vat_total_price"] as? Int ?? 0
    notDeliveryValue.delivery_state = notDeliveryDict["delivery_state"] as? String ?? ""
    notDeliveryValue.item_key = notDeliveryDict["item_key"] as? String ?? ""
    notDeliveryValue.item_name = notDeliveryDict["item_name"] as? String ?? ""
    (notDeliveryDict["item_option"] as? Array<[String: Any]> ?? []).forEach { dict in
        let itemOptionValue = ItemOptionData()
        itemOptionValue.color = dict["color"] as? String ?? ""
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
    
    var attached_imgs: [String] = []
    var content: String = ""
    var direction: String = ""
    var store_id: String = ""
    var store_name: String = ""
    var read_or_not: Bool = false
    var requested_store_name: String = ""
    var summary_address: String = ""
    var time: String = ""
    
    var order_item: [(item_name: String, item_category_name: [String], item_option: [(color: String, size: String, quantity: Int, price: Int)])] = []
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
    enquiryReceiptValue.read_or_not = enquiryReceiptDict["read_or_not"] as? Bool ?? false
    enquiryReceiptValue.requested_store_name = enquiryReceiptDict["requested_store_name"] as? String ?? ""
    enquiryReceiptValue.summary_address = enquiryReceiptDict["summary_address"] as? String ?? ""
    enquiryReceiptValue.time = enquiryReceiptDict["time"] as? String ?? ""
    (enquiryReceiptDict["order_item"] as? Array<[String: Any]> ?? []).forEach { dict in
        var item_option: [(color: String, size: String, quantity: Int, price: Int)] = []
        (dict["item_option"] as? Array<[String: Any]> ?? []).forEach { dict in
            item_option.append((
                color: dict["color"] as? String ?? "",
                size: dict["size"] as? String ?? "",
                quantity: dict["quantity"] as? Int ?? 0,
                price: dict["price"] as? Int ?? 0
            ))
        }
        enquiryReceiptValue.order_item.append((
            item_name: dict["item_name"] as? String ?? "",
            item_category_name: dict["item_category_name"] as? [String] ?? [],
            item_option: item_option
        ))
    }
    
    return enquiryReceiptValue
}

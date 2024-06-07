//
//  WhGoodsUploadVC.swift
//  market
//
//  Created by 장 제현 on 11/22/23.
//

import UIKit

class WhGoodsUploadVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var GoodsObject: GoodsData = GoodsData()
    var edit: Bool = false
    
    var ItemArray: [(file_name: String, file_data: Data, file_size: Int)] = []
    
    var option_key: String = ""
    var item_sale: Bool = false
    var notice_sale_price: Bool = true
    var ColorArray: [(option_name: String, option_color: String)] = []
    var SizeArray: [(option_name: String, option_select: Bool)] = []
    var MaterialArray: [(option_name: String, option_percent: String)] = []
    
    var OptionPriceArray: [(color_name: String, size_price: [(size: String, price: Int)])] = []
    var item_option_type: Bool = false
    
    var StyleArray: [String] = []
    var style_row: Int? = nil
    var ContentsArray: [(file_name: String, file_data: Data, file_size: Int)] = []
    var MaterialInfoArray: [String: Any] = [:]
    var WashingInfoArray: [String] = []
    
    var OtherTypeArray: [String: Any] = ["build": "편물(니트/다이마루)", "manufacture_country": "대한민국", "disclosure": "전체 공개"]
    
    var collectionViewContentOffsets: [Int: CGFloat] = [:]
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var upload_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WhGoodsUploadVCdelegate = self
        
        setKeyboard()
        /// Option Key
        if !edit, CategoryObject.CategoryArray.count > 0 {
            option_key = CategoryObject.CategoryArray[0].keys.first ?? ""
        }
        
        if edit { 
            upload_btn.setTitle("상품 수정하기", for: .normal)
        }
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        
        if CategoryObject.ColorArray.count == 0 || CategoryObject.CategoryArray.count == 0 || CategoryObject.SizeArray.count == 0 || CategoryObject.StyleArray.count == 0 || CategoryObject.MaterialArray.count == 0 {
            requestCategory(action: ["color_category", "item_category", "size_category", "style_category", "material_category"]) { _ in
                self.loadingData(all: true)
            }
        } else {
            loadingData(all: true)
        }
        
        upload_btn.addTarget(self, action: #selector(upload_btn(_:)), for: .touchUpInside)
    }
    
    func loadingData(all: Bool = false, index: Int = 0) {
        
        if all || index == 0 {
            SizeArray.removeAll()
            CategoryObject.SizeArray.forEach { data in
                (data[option_key] as? [String: [String]] ?? [:]).forEach { (key: String, value: [String]) in
                    value.forEach { option_name in
                        SizeArray.append((option_name: option_name, option_select: false))
                    }
                }
            }
        }
        
        if all || index == 1 {
            OptionPriceArray.removeAll()
            if GoodsObject.item_colors.count > 0, GoodsObject.item_sizes.count > 0 {
                OptionPriceArray = ColorArray.map { colorData in
                    let size_price = SizeArray.filter { $0.option_select }.compactMap { sizeData in
                        let price = GoodsObject.item_option.isEmpty ? GoodsObject.item_sale_price : GoodsObject.item_option.filter { $0.color == colorData.option_name && $0.size == sizeData.option_name }.map { $0.price <= GoodsObject.item_sale_price ? GoodsObject.item_sale_price : $0.price }.first ?? GoodsObject.item_sale_price
                        return (size: sizeData.option_name, price: price)
                    }
                    return (color_name: colorData.option_name, size_price: size_price)
                }
            } else {
                item_option_type = false; GoodsObject.item_option_type = false
            }
        }

        if all || index == 2 {
            StyleArray.removeAll()
            CategoryObject.StyleArray.forEach { data in
                (data[option_key] as? [String: [String]] ?? [:]).forEach { (key: String, value: [String]) in
                    value.forEach { option_name in
                        StyleArray.append(option_name)
                    }
                }
            }
        }
        
        if edit { edit = false
            
            let data = GoodsObject
            
            customLoadingIndicator(text: "불러오는 중...", animated: true)
            /// 상품 대표 이미지
            data.item_photo_imgs.forEach { _ in ItemArray.append((file_name: "", file_data: Data(), file_size: 0)) }
            data.item_photo_imgs.enumerated().forEach { i, imgUrl in
                dispatchGroup.enter()
                imageUrlStringToData(from: imgUrl) { mimeType, imgData in
                    DispatchQueue.main.async {
                        self.ItemArray[i] = (file_name: "\(i).\((mimeTypes.filter { $0.value == mimeType }.map { $0.key }).first ?? "")", file_data: imgData ?? Data(), file_size: imgData?.count ?? 0); dispatchGroup.leave()
                        UIView.setAnimationsEnabled(false); self.tableView.reloadSections(IndexSet(integer: 0), with: .none); UIView.setAnimationsEnabled(true)
                    }
                }
            }
            /// 사이즈
            SizeArray.enumerated().forEach { i, size in
                if data.item_sizes.contains(size.option_name) { SizeArray[i].option_select = true }
            }
            /// 옵션 단가
            item_option_type = data.item_option_type
            /// 스타일
            StyleArray.enumerated().forEach { i, style in
                if data.item_style.contains(style) { style_row = i }
            }
            /// 상품 상세 이미지
            data.item_content_imgs.forEach { _ in ContentsArray.append((file_name: "", file_data: Data(), file_size: 0)) }
            data.item_content_imgs.enumerated().forEach { i, imgUrl in
                dispatchGroup.enter()
                imageUrlStringToData(from: imgUrl) { mimeType, imgData in
                    DispatchQueue.main.async {
                        self.ContentsArray[i] = (file_name: "\(i).\((mimeTypes.filter { $0.value == mimeType }.map { $0.key }).first ?? "")", file_data: imgData ?? Data(), file_size: imgData?.count ?? 0); dispatchGroup.leave()
                        UIView.setAnimationsEnabled(false); self.tableView.reloadSections(IndexSet(integer: 3), with: .none); UIView.setAnimationsEnabled(true)
                    }
                }
            }
            /// 소재정보 및 세탁법
            data.item_material_washing.forEach { (key: String, value: Any) in
                if key != "washing" {
                    MaterialInfoArray[key] = value as? String ?? ""
                } else {
                    WashingInfoArray = value as? [String] ?? []
                }
            }
            /// 제직 방식 설정
            OtherTypeArray["build"] = data.item_build
            /// 제조국 표기
            OtherTypeArray["manufacture_country"] = data.item_manufacture_country
            /// 공개 방식 설정
            OtherTypeArray["disclosure"] = data.item_disclosure
            
            dispatchGroup.notify(queue: .main) {
                
                self.customLoadingIndicator(animated: false)
                
                self.ItemArray.sort { Int($0.file_name) ?? 0 < Int($1.file_name) ?? 0 }
                self.ContentsArray.sort { Int($0.file_name) ?? 0 < Int($1.file_name) ?? 0 }
                
                self.tableView.reloadData()
                self.loadingData(index: 1)
            }
        }
    }
    
    @objc func upload_btn(_ sender: UIButton) {
        
        GoodsObject.upload_files.removeAll()
        ItemArray.enumerated().forEach { i, data in
            GoodsObject.upload_files.append((field_name: "item_photo_imgs\(i)", file_name: data.file_name, file_data: data.file_data, file_size: data.file_size))
        }
        ContentsArray.enumerated().forEach { i, data in
            GoodsObject.upload_files.append((field_name: "item_content_imgs\(i)", file_name: data.file_name, file_data: data.file_data, file_size: data.file_size))
        }
        
        GoodsObject.item_option.removeAll()
        OptionPriceArray.forEach { (color_name: String, size_price: [(size: String, price: Int)]) in
            size_price.forEach { (size: String, price: Int) in
                let itemOptionValue = ItemOptionData()
                itemOptionValue.color = color_name
                itemOptionValue.price = price
                itemOptionValue.size = size
                itemOptionValue.sold_out = false
                GoodsObject.item_option.append(itemOptionValue)
            }
        }
        
        if ItemArray.count == 0 {
            customAlert(message: "상품 이미지를 첨부해 주세요.", time: 1)
        } else if GoodsObject.item_category_name.count == 0 {
            customAlert(message: "카테고리를 선택해 주세요.", time: 1)
        } else if GoodsObject.item_name == "" {
            customAlert(message: "상품명을 입력해 주세요.", time: 1)
        } else if GoodsObject.item_price == 0 && GoodsObject.item_sale_price == 0 || !notice_sale_price {
            customAlert(message: "단가를 입력해 주세요.", time: 1)
        } else if GoodsObject.item_option.count == 0 {
            customAlert(message: "색상∙사이즈를 설정해 주세요.", time: 1)
        } else {
            
            var timestamp: Int64 = setGMTUnixTimestamp()
            if GoodsObject.item_key != "" { timestamp = Int64(GoodsObject.item_key) ?? setGMTUnixTimestamp() }
            
            customLoadingIndicator(text: "등록중...", animated: true)
            
            var status_code: Int = 500
            /// WhGoods Upload 요청
            dispatchGroup.enter()
            requestWhGoodsUpload(GoodsObject: GoodsObject, timestamp: timestamp) { status in
                
                if self.GoodsObject.upload_files.count > 0, status == 200 {
                    var action = "add"
                    if self.GoodsObject.item_key != "" { action = "edit" }
                    /// File Upload 요청
                    dispatchGroup.enter()
                    requestFileUpload(action: action, collection_id: "goods", document_id: "\(StoreObject.store_id)_\(timestamp)", file_data: self.GoodsObject.upload_files) { fileUrls, status in
                        
                        let dict = fileUrls ?? [:]
                        self.GoodsObject.item_mainphoto_img = dict["item_mainphoto_img"] as? String ?? ""
                        if dict["item_mainphoto_img"] as? String ?? "" != "" {
                            self.GoodsObject.item_photo_imgs = [dict["item_mainphoto_img"] as? String ?? ""]+(dict["item_photo_imgs"] as? [String] ?? [])
                        } else {
                            self.GoodsObject.item_photo_imgs = dict["item_photo_imgs"] as? [String] ?? []
                        }
                        self.GoodsObject.item_content_imgs = dict["item_content_imgs"] as? [String] ?? []
                        
                        status_code = status; dispatchGroup.leave()
                    }
                }
                
                status_code = status; dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                
                self.customLoadingIndicator(animated: false)
                
                switch status_code {
                case 200:
                    /// 데이터 삭제
                    self.GoodsObject.upload_files.removeAll()
                    
                    var message: String = ""
                    if self.GoodsObject.item_key != "" { message = "수정되었습니다." } else { message = "등록되었습니다." }
                    
                    self.alert(title: "", message: message, style: .alert, time: 1) {
                        self.navigationController?.popViewController(animated: true, completion: {
                            if self.GoodsObject.item_key != "" {
                                if let delegate = WhHomeVCdelegate {
                                    WhGoodsArray_realtime[delegate.WhGoodsArray_realtime_row] = self.GoodsObject
                                    UIView.setAnimationsEnabled(false); delegate.tableView.reloadSections(IndexSet(integer: 1), with: .none); UIView.setAnimationsEnabled(true)
                                }
                                if let delegate = WhGoodsVCdelegate {
                                    delegate.loadingData(first: true)
                                }
                                if let delegate = WhGoodsDetailVCdelegate {
                                    delegate.GoodsObject = self.GoodsObject
                                    delegate.item_img.delegate = nil
                                    delegate.viewDidLoad()
                                }
                            } else {
                                if let delegate = WhHomeVCdelegate {
                                    // 데이터 삭제
                                    WhGoodsArray_realtime.removeAll()
                                    
                                    delegate.customLoadingIndicator(text: "불러오는 중...", animated: true)
                                    /// WhRealTime 요청
                                    requestWhRealTime(filter: "최신순", limit: 3) { _ in
                                        delegate.customLoadingIndicator(animated: false)
                                        delegate.tableView.reloadData()
                                    }
                                }
                                if let delegate = WhGoodsVCdelegate {
                                    delegate.loadingData(first: true)
                                }
                            }
                        })
                    }
                default:
                    self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
                }
            }
        }
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

import Nuke

extension WhGoodsUploadVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else if section == 2, OptionPriceArray.count > 0 {
            return OptionPriceArray.count
        } else if section == 3 {
            return 1
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? WhGoodsUploadTC else { return }
        
        if indexPath.section == 0 {
            collectionViewContentOffsets[0] = cell.itemCollectionView.contentOffset.x
        } else if indexPath.section == 1 {
            ([cell.colorCollectionView, cell.sizeCollectionView] as [UICollectionView]).enumerated().forEach { i, collectionView in
                collectionViewContentOffsets[i+1] = collectionView.contentOffset.x
            }
        } else if indexPath.section == 2 {
            collectionViewContentOffsets[3] = cell.optionPriceCollectionView.contentOffset.x
        } else if indexPath.section == 3 {
            ([cell.styleCollectionView, cell.contentCollectionView, cell.materialCollectionView] as [UICollectionView]).enumerated().forEach { i, collectionView in
                collectionViewContentOffsets[i+3+1] = collectionView.contentOffset.x
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhGoodsUploadTC0", for: indexPath) as! WhGoodsUploadTC
            cell.WhGoodsUploadVCdelegate = self
            cell.indexpath_section = indexPath.section
            cell.viewDidLoad()
                
            cell.itemCount_label.text = "\(ItemArray.count)/20"
            
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhGoodsUploadTC1", for: indexPath) as! WhGoodsUploadTC
            cell.WhGoodsUploadVCdelegate = self
            cell.indexpath_section = indexPath.section
            cell.viewDidLoad()
            
            cell.colorCollectionView.isHidden = (ColorArray.count == 0)
            cell.colorCollectionView.contentOffset.x = max(cell.colorCollectionView.contentSize.width - cell.colorCollectionView.bounds.width, 0)
            
            ([cell.itemCategory_btn, cell.color_btn] as [UIButton]).enumerated().forEach { i, btn in
                btn.tag = i; btn.addTarget(cell, action: #selector(cell.category_btn(_:)), for: .touchUpInside)
            }
            
            var category_name: String = ""
            GoodsObject.item_category_name.enumerated().forEach { i, category in
                if i < GoodsObject.item_category_name.count-1 { category_name.append("\(category) > ") } else { category_name.append(category) }
            }
            cell.itemCategory_btn.setTitle(category_name, for: .normal)
            
            ([cell.itemName_tf, cell.itemPrice_tf, cell.itemSalePrice_tf] as [UITextField]).enumerated().forEach { i, tf in
                tf.tag = i
                tf.addTarget(cell, action: #selector(cell.edit_textfield(_:)), for: .editingChanged)
                tf.addTarget(cell, action: #selector(cell.end_textfield(_:)), for: .editingDidEnd)
            }
            
            cell.itemName_tf.placeholder(text: "소매에게 노출할 상품명을 입력해 주세요.")
            cell.itemName_tf.text = GoodsObject.item_name
            
            GoodsObject.item_sale = item_sale
            if item_sale {
                cell.sale_img.image = UIImage(named: "check_on")
                cell.sale_label.textColor = .black
            } else {
                cell.sale_img.image = UIImage(named: "check_off")
                cell.sale_label.textColor = .black.withAlphaComponent(0.3)
            }
            cell.itemPrice_view.isHidden = !item_sale
            cell.itemPrice_tf.placeholder(text: "가격(원가)을 입력해 주세요.")
            if GoodsObject.item_price != 0 {
                cell.itemPrice_tf.text = priceFormatter.string(from: GoodsObject.item_price as NSNumber) ?? ""
            }
            if item_sale {
                cell.itemSalePrice_tf.placeholder(text: "할인된 가격을 입력해 주세요.")
            } else {
                cell.itemSalePrice_tf.placeholder(text: "가격(원가)을 입력해 주세요.")
            }
            if GoodsObject.item_sale_price != 0 {
                cell.itemSalePrice_tf.text = priceFormatter.string(from: GoodsObject.item_sale_price as NSNumber) ?? ""
            }
            cell.noticeItemSalePrice_label.isHidden = notice_sale_price
            cell.sale_btn.isSelected = item_sale
            cell.sale_btn.tag = 0; cell.sale_btn.addTarget(cell, action: #selector(cell.select_btn(_:)), for: .touchUpInside)
            
            GoodsObject.item_option_type = item_option_type
            if item_option_type {
                cell.optionPrice_img.image = UIImage(named: "check_on")
                cell.optionPrice_label.textColor = .black
            } else {
                cell.optionPrice_img.image = UIImage(named: "check_off")
                cell.optionPrice_label.textColor = .black.withAlphaComponent(0.3)
            }
            cell.optionPrice_btn.tag = 1; cell.optionPrice_btn.addTarget(cell, action: #selector(cell.select_btn(_:)), for: .touchUpInside)
            
            return cell
            
        } else if indexPath.section == 2 {
            
            let data = OptionPriceArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhGoodsUploadTC2", for: indexPath) as! WhGoodsUploadTC
            cell.WhGoodsUploadVCdelegate = self
            cell.indexpath_section = indexPath.section
            cell.indexpath_row = indexPath.row
            cell.viewDidLoad()
            /// 색상
            cell.optionColor_view.backgroundColor = UIColor(hex: "#"+(CategoryObject.ColorArray_all[data.color_name] as? String ?? "ffffff"))
            cell.optionColor_label.text = data.color_name
            cell.optionPriceCollectionView_height.constant = CGFloat(data.size_price.count)*44
            
            return cell
        } else if indexPath.section == 3 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhGoodsUploadTC3", for: indexPath) as! WhGoodsUploadTC
            cell.WhGoodsUploadVCdelegate = self
            cell.indexpath_section = indexPath.section
            cell.indexpath_row = indexPath.row
            cell.viewDidLoad()
            /// 스타일
            cell.style_sv.isHidden = !option_key.contains("의류")
            /// 상세내용
            cell.content_tv.contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
            cell.content_tv.backgroundColor = .white
            cell.content_tv.delegate = cell
            cell.content_tv.text = GoodsObject.item_content
            cell.content_btn.addTarget(cell, action: #selector(cell.content_btn(_:)), for: .touchUpInside)
            cell.content_view.isHidden = (ContentsArray.count == 0)
            /// 혼용률
            cell.materialCollectionView.isHidden = (MaterialArray.count == 0 && GoodsObject.item_materials.count == 0)
            cell.materialCollectionView.contentOffset.x = max(cell.materialCollectionView.contentSize.width - cell.materialCollectionView.bounds.width, 0)
            cell.material_btn.tag = 2; cell.material_btn.addTarget(cell, action: #selector(cell.category_btn(_:)), for: .touchUpInside)
            /// 소재정보 및 세탁법
            cell.materialInfo_sv.isHidden = !option_key.contains("의류")
            cell.materialWashing_imgs.forEach { img in img.image = UIImage(named: "check_off") }
            cell.materialWashing_labels.forEach { label in label.textColor = .black.withAlphaComponent(0.3) }
            
            let material: [String: [String: Int]] = ["thickness": ["두꺼움": 0, "보통": 1, "얇음": 2], "see_through": ["있음": 3, "보통": 4, "없음": 5], "flexibility": ["좋음": 6, "보통": 7, "없음": 8], "lining": ["있음": 9, "없음": 10, "기모안감": 11]]
            MaterialInfoArray.forEach { (key: String, value: Any) in
                
                let value = value as? String ?? ""
                let material_btn = UIButton()

                if let map = material[key], let tag = map[value] {
                    material_btn.tag = tag; cell.materialWashing_btn(material_btn)
                }
            }
            let washing: [String: Int] = ["손세탁": 12, "드라이클리닝": 13, "물세탁": 14, "단독세탁": 15, "울세탁": 16, "표백제사용금지": 17, "다림질금지": 18, "세탁기금지": 19]
            WashingInfoArray.forEach { value in
                
                let washing_btn = UIButton()
                
                if let tag = washing[value] {
                    washing_btn.tag = tag; cell.materialWashing_btn(washing_btn)
                }
            }
            cell.materialWashing_btns.forEach { btn in btn.addTarget(cell, action: #selector(cell.materialWashing_btn(_:)), for: .touchUpInside) }
            
            let other_type: [String: [String: Int]] = ["build": ["편물(니트/다이마루)": 0, "직물(우븐)": 1], "manufacture_country": ["대한민국": 2, "대한민국외 국가": 3], "disclosure": ["전체 공개": 4, "거래처만 공개": 5]]
            OtherTypeArray.forEach { (key: String, value: Any) in
                
                let value = value as? String ?? ""
                let otherType_btn = UIButton()
                
                if let map = other_type[key], let tag = map[value] {
                    otherType_btn.tag = tag; cell.otherType_btn(otherType_btn)
                }
            }
            
            cell.otherType_btns.forEach { btn in btn.addTarget(cell, action: #selector(cell.otherType_btn(_:)), for: .touchUpInside) }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2, !item_option_type { return .zero } else { return UITableView.automaticDimension }
    }
}

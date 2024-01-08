//
//  WhGoodsUploadVC.swift
//  market
//
//  Created by Busan Dynamic on 11/22/23.
//

import UIKit

class WhGoodsUploadVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var GoodsObject: GoodsData = GoodsData()
    
    var ItemArray: [(file_name: String, file_data: Data, file_size: Int)] = []
    
    var option_key: String = ""
    var notice_sale_price: Bool = true
    var ColorArray: [(option_name: String, option_color: String)] = []
    var SizeArray: [(option_name: String, option_select: Bool)] = []
    var MaterialArray: [(option_name: String, option_percent: String)] = []
    var item_sale: Bool = false
    
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
        if CategoryObject.CategoryArray.count > 0 {
            option_key = CategoryObject.CategoryArray[0].keys.first ?? ""
        }
        
        loadingData(all: true)
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        
        upload_btn.addTarget(self, action: #selector(upload_btn(_:)), for: .touchUpInside)
    }
    
    func loadingData(all: Bool = false, index: Int = 0) {
        
        let data = GoodsObject
        
        if all || index == 0 {
            SizeArray.removeAll()
            data.item_sizes.removeAll()
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
            data.item_option.removeAll()
            if GoodsObject.item_colors.count > 0, GoodsObject.item_sizes.count > 0 {
                OptionPriceArray = ColorArray.map { data in
                    var size_price: [(size: String, price: Int)] = []
                    SizeArray.filter { $0.option_select }.forEach { 
                        size_price.append((size: $0.option_name, price: GoodsObject.item_sale_price))
                    }
                    return (color_name: data.option_name, size_price: size_price)
                }
            } else {
                item_option_type = false
                data.item_option_type = false
            }
        }
        if all || index == 2 {
            StyleArray.removeAll()
            data.item_style.removeAll()
            CategoryObject.StyleArray.forEach { data in
                (data[option_key] as? [String: [String]] ?? [:]).forEach { (key: String, value: [String]) in
                    value.forEach { option_name in
                        StyleArray.append(option_name)
                    }
                }
            }
        }
    }
    
    @objc func upload_btn(_ sender: UIButton) {
        
        view.endEditing(true)
        
        let data = GoodsObject
        
        data.upload_files.removeAll()
        ItemArray.enumerated().forEach { i, data in
            GoodsObject.upload_files.append((field_name: "item_photo_imgs\(i)", file_name: data.file_name, file_data: data.file_data, file_size: data.file_size))
        }
        ContentsArray.enumerated().forEach { i, data in
            GoodsObject.upload_files.append((field_name: "item_content_imgs\(i)", file_name: data.file_name, file_data: data.file_data, file_size: data.file_size))
        }
        
        data.item_option.removeAll()
        OptionPriceArray.forEach { (color_name: String, size_price: [(size: String, price: Int)]) in
            size_price.forEach { (size: String, price: Int) in
                let itemOptionValue = GoodsOptionData()
                itemOptionValue.color = color_name
                itemOptionValue.price = price
                itemOptionValue.size = size
                itemOptionValue.sold_out = false
                data.item_option.append(itemOptionValue)
            }
        }
        
        if ItemArray.count == 0 {
            customAlert(message: "상품 이미지를 첨부해 주세요.", time: 1)
        } else if data.item_category_name.count == 0 {
            customAlert(message: "카테고리를 선택해 주세요.", time: 1)
        } else if data.item_name == "" {
            customAlert(message: "상품명을 입력해 주세요.", time: 1)
        } else if data.item_price == 0 && data.item_sale_price == 0 || !notice_sale_price {
            customAlert(message: "단가를 입력해 주세요.", time: 1)
        } else if data.item_option.count == 0 {
            customAlert(message: "색상∙사이즈를 설정해 주세요.", time: 1)
        } else {
            
            let timestamp: Int64 = setKoreaUnixTimestamp()
            
            customLoadingIndicator(text: "상품 등록중...", animated: true)
            
            var status_code: Int = 500
            /// WhGoods Upload 요청
            dispatchGroup.enter()
            requestWhGoodsUpload(GoodsObject: GoodsObject, timestamp: timestamp) { status in
                if status == 200, data.upload_files.count > 0 {
                    /// File Upload 요청
                    dispatchGroup.enter()
                    requestFileUpload(collection_id: "goods", document_id: "\(StoreObject.store_id)_\(timestamp)", file_data: data.upload_files) { status in
                        status_code = status; dispatchGroup.leave()
                    }
                } else {
                    status_code = status; dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                
                self.customLoadingIndicator(animated: false)
                
                switch status_code {
                case 200:
                    let alert = UIAlertController(title: "", message: "상품등록 완료!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: { _ in
                        self.navigationController?.popViewController(animated: true, completion: {
                            /// WhRealTime 요청
                            requestWhRealTime(filter: ["최신순"][0], limit: 3) { _ in
                                if let delegate = WhHomeVCdelegate {
                                    delegate.tableView.reloadData()
                                }
                            }
                        })
                    }))
                    self.present(alert, animated: true, completion: nil)
                case 600:
                    self.customAlert(message: "Error occurred during data conversion", time: 1)
                default:
                    self.customAlert(message: "Internal server error", time: 1)
                }
            }
        }
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

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
            
            let data = GoodsObject
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
            data.item_category_name.enumerated().forEach { i, category in
                if i < data.item_category_name.count-1 { category_name.append("\(category) > ") } else { category_name.append(category) }
            }
            cell.itemCategory_btn.setTitle(category_name, for: .normal)
            
            ([cell.itemName_tf, cell.itemPrice_tf, cell.itemSalePrice_tf] as [UITextField]).enumerated().forEach { i, tf in
                tf.tag = i
                tf.addTarget(cell, action: #selector(cell.edit_textfield(_:)), for: .editingChanged)
                tf.addTarget(cell, action: #selector(cell.end_textfield(_:)), for: .editingDidEnd)
            }
            
            cell.itemName_tf.placeholder(text: "소매에게 노출할 상품명을 입력해 주세요.", color: .lightGray)
            cell.itemName_tf.text = data.item_name
            
            data.item_sale = item_sale
            if item_sale {
                cell.sale_img.image = UIImage(named: "check_on")
                cell.sale_label.textColor = .black
            } else {
                cell.sale_img.image = UIImage(named: "check_off")
                cell.sale_label.textColor = .black.withAlphaComponent(0.3)
            }
            cell.itemPrice_view.isHidden = !item_sale
            cell.itemPrice_tf.placeholder(text: "가격(원가)을 입력해 주세요.", color: .lightGray)
            if item_sale {
                cell.itemSalePrice_tf.placeholder(text: "할인된 가격을 입력해 주세요.", color: .lightGray)
            } else {
                cell.itemSalePrice_tf.placeholder(text: "가격(원가)을 입력해 주세요.", color: .lightGray)
            }
            cell.noticeItemSalePrice_label.isHidden = notice_sale_price
            cell.sale_btn.isSelected = item_sale
            cell.sale_btn.tag = 0; cell.sale_btn.addTarget(cell, action: #selector(cell.select_btn(_:)), for: .touchUpInside)
            
            data.item_option_type = item_option_type
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
            
            cell.style_sv.isHidden = !option_key.contains("의류")
            
            cell.content_tv.contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
            cell.content_tv.backgroundColor = .white
            cell.content_tv.delegate = cell
            cell.content_btn.addTarget(cell, action: #selector(cell.content_btn(_:)), for: .touchUpInside)
            cell.content_view.isHidden = (ContentsArray.count == 0)
            
            cell.materialCollectionView.isHidden = (MaterialArray.count == 0)
            cell.materialCollectionView.contentOffset.x = max(cell.materialCollectionView.contentSize.width - cell.materialCollectionView.bounds.width, 0)
            cell.material_btn.tag = 2; cell.material_btn.addTarget(cell, action: #selector(cell.category_btn(_:)), for: .touchUpInside)
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        view.endEditing(true)
    }
}
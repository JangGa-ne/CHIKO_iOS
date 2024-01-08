//
//  ReGoodsDetailVC.swift
//  market
//
//  Created by 장 제현 on 11/11/23.
//

import UIKit
import FirebaseFirestore
import ImageSlideshow
import PanModal

class ReGoodsDetailTC: UITableViewCell {
    
    var OptionArray: [(color: String, price: Int, quantity: Int, sequence: Int, size: String)] = []
    
    @IBOutlet weak var store_img: UIImageView!
    @IBOutlet weak var storeName_label: UILabel!
    @IBOutlet weak var storeNameEng_label: UILabel!
    @IBOutlet weak var store_btn: UIButton!
    
    @IBOutlet weak var item_img: ImageSlideshow!
    @IBOutlet weak var itemImgPage_view: UIVisualEffectView!
    @IBOutlet weak var itemImgPage_label: UILabel!
    @IBOutlet weak var itemImgCount_label: UILabel!
    @IBOutlet weak var itemName_label: UILabel!
    @IBOutlet weak var itemPrice_view: UIView!
    @IBOutlet weak var itemPrice_label: UILabel!
    @IBOutlet weak var itemSalePrice_label: UILabel!
    @IBOutlet weak var itemSalePercent_label: UILabel!
    @IBOutlet weak var categoryName_label: UILabel!
    @IBOutlet weak var categoryName_label_width: NSLayoutConstraint!
    @IBOutlet weak var itemTop_img: UIImageView!
    
    @IBOutlet weak var optionSelect_view: UIView!
    @IBOutlet weak var optionColor_view: UIView!
    @IBOutlet weak var optionSequence_label: UILabel!
    @IBOutlet weak var optionName_label: UILabel!
    @IBOutlet weak var optionDelete_btn: UIButton!
    @IBOutlet weak var optionMinus_btn: UIButton!
    @IBOutlet weak var optionQuantity_label: UILabel!
    @IBOutlet weak var optionPlus_btn: UIButton!
    @IBOutlet weak var optionPrice_label: UILabel!
    
    @IBOutlet weak var itemContent_img: UIImageView!
    
    @IBOutlet weak var itemContent_label: UILabel!
    @IBOutlet weak var itemCategory_label: UILabel!
    @IBOutlet weak var itemColor_label: UILabel!
    @IBOutlet weak var itemSize_label: UILabel!
    @IBOutlet weak var itemStyle_label: UILabel!
    @IBOutlet weak var itemMaterial_label: UILabel!
    @IBOutlet weak var itemKey_label: UILabel!
    
    @IBOutlet var itemMaterialWasingInfo_labels: [UILabel]!
    
    @objc func optionMinus_btn(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard let data = ReGoodsDetailVCdelegate?.OptionArray[sender.tag] else { return }
        if data.quantity > 1 { data.quantity -= 1; optionQuantity_label.text = "\(data.quantity)" }
        optionPrice_label.text = "₩ \(priceFormatter.string(from: data.price*data.quantity as NSNumber) ?? "0")"
        ReGoodsDetailVCdelegate?.setTotalPrice()
    }
    
    @objc func optionPlus_btn(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard let data = ReGoodsDetailVCdelegate?.OptionArray[sender.tag] else { return }
        data.quantity += 1; optionQuantity_label.text = "\(data.quantity)"
        optionPrice_label.text = "₩ \(priceFormatter.string(from: data.price*data.quantity as NSNumber) ?? "0")"
        ReGoodsDetailVCdelegate?.setTotalPrice()
    }
}

extension ReGoodsDetailTC: ImageSlideshowDelegate {
    
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        itemImgPage_label.text = "\(page+1)"
    }
}

class ReGoodsDetailVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var store_id: String = ""
    var item_key: String = ""
    
    var store_mainphoto_img: String = ""
    
    var GoodsObject: GoodsData = GoodsData()
    var OptionArray: [GoodsOptionData] = []
    
    var itemContent_img_height: [Int: CGFloat] = [:]
    
    var total_price: Int = 0
    var total_quantity: Int = 0
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalPrice_label: UILabel!
    @IBOutlet weak var basket_btn: UIButton!
    @IBOutlet weak var order_btn: UIButton!
    
    override func loadView() {
        super.loadView()
        
        guard store_id != "" && item_key != "" else { return }
        
        customLoadingIndicator(animated: true)
        
        requestFindReGoods(store_id: store_id, item_key: item_key) { object, status in
            
            self.store_id = ""; self.item_key = ""; self.customLoadingIndicator(animated: false)
            
            switch status {
            case 200:
                self.GoodsObject = object; self.viewDidLoad()
            case 600:
                self.customAlert(message: "Error occurred during data conversion", time: 1)
            default:
                self.customAlert(message: "Internal server error", time: 1)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard store_id == "" && item_key == "" else { return }
        
        ReGoodsDetailVCdelegate = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = .zero }
        tableView.delegate = self; tableView.dataSource = self
        
        preheatImages(urls: GoodsObject.item_content_imgs.compactMap { URL(string: $0) })
        
        GoodsObject.item_content_imgs.enumerated().forEach { i, imageUrl in
            imageUrlHeight(imageUrl: imageUrl) { height in
                DispatchQueue.main.async {
                    self.itemContent_img_height[i] = height+20
                    UIView.setAnimationsEnabled(false)
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 2)], with: .none)
                    UIView.setAnimationsEnabled(true)
                }
            }
        }
        
        ([basket_btn, order_btn] as [UIButton]).enumerated().forEach { i, btn in
            btn.tag = i; btn.addTarget(self, action: #selector(basket_order_btn(_:)), for: .touchUpInside)
        }
        
        guard GoodsObject.store_id != "" else { return }
        Firestore.firestore().collection("store").document(GoodsObject.store_id).getDocument { ResDocu, error in
            let dict = ResDocu?.data() ?? [:]
            self.store_mainphoto_img = dict["store_mainphoto_img"] as? String ?? ""
            self.tableView.reloadData()
        }
    }
    
    @objc func basket_order_btn(_ sender: UIButton) {
        
        guard OptionArray.count != 0 else { customAlert(message: "상품을 선택해주세요.", time: 1); return }
        
//        if ReBasketArray.filter({ $0.item_key == GoodsObject.item_key }).isEmpty {
//            
//        }
        
        var item_option: Array<[String: Any]> = []
        OptionArray.forEach { data in
            item_option.append([
                "color": data.color,
                "price": data.price,
                "quantity": data.quantity,
                "size": data.size,
                "sold_out": String(data.sold_out)
            ])
        }
        
        let timestamp = setKoreaUnixTimestamp()
        let data = GoodsObject
        var params: [String: Any] = [
            "item_price": data.item_price,
            "item_key": data.item_key,
            "item_name": data.item_name,
            "item_mainphoto_img": data.item_mainphoto_img,
            "item_option": item_option,
            "item_sale": String(data.item_sale),
            "item_sale_price": data.item_sale_price,
            "item_total_price": total_price,
            "item_total_quantity": total_quantity,
            "wh_store_id": data.store_id,
            "store_name": data.store_name,
            "store_name_eng": data.store_name_eng,
        ]
        
        if sender.tag == 0 {
            /// basket
            params["basket_key"] = "ba\(timestamp)"
            
            var type: String = "set"
            ReBasketArray.forEach { data in
                if data.item_key == self.GoodsObject.item_key { params["basket_key"] = data.basket_key; type = "edit" }
            }
            
            customLoadingIndicator(animated: true)
            
            /// ReBasket 요청
            requestReBasket(type: type, params: params) { status in
                
                self.customLoadingIndicator(animated: false)
                
                switch status {
                case 200:
                    self.customAlert(message: "장바구니에 상품이 담겼습니다.", time: 1) {
//                        self.segueViewController(identifier: "ReBasketVC")
                    }
                case 600:
                    self.customAlert(message: "Error occurred during data conversion", time: 1)
                default:
                    self.customAlert(message: "Internal server error", time: 1)
                }
            }
        } else if sender.tag == 1 {
            /// order
            let segue = storyboard?.instantiateViewController(withIdentifier: "ReLiquidateVC") as! ReLiquidateVC
            segue.LiquidateArray = [setBasket(basketDict: params)]
            navigationController?.pushViewController(segue, animated: true)
        }
    }
    
    func setTotalPrice() {
        total_price = 0
        total_quantity = 0
        OptionArray.forEach { data in 
            total_price += (data.price*data.quantity)
            total_quantity += data.quantity
        }
        totalPrice_label.text = "₩ \(priceFormatter.string(from: total_price as NSNumber) ?? "0")"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
        
        ReOrderVCdelegate = nil
        ReBasketVCdelegate = nil
    }
}

extension ReGoodsDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1, OptionArray.count > 0 {
            return OptionArray.count
        } else if section == 2, GoodsObject.item_content_imgs.count > 0 {
            return GoodsObject.item_content_imgs.count
        } else if section == 3 {
            return 1
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let data = GoodsObject
        guard let cell = cell as? ReGoodsDetailTC else { return }
        
        if indexPath.section == 0 {
            setNuke(imageView: cell.store_img, imageUrl: store_mainphoto_img, cornerRadius: 18)
            setImageSlideShew(imageView: cell.item_img, imageUrls: data.item_photo_imgs)
            cell.item_img.pageIndicator = .none
            cell.item_img.slideshowInterval = 3
            cell.item_img.delegate = cell
        } else if indexPath.section == 2 {
            setNuke(imageView: cell.itemContent_img, imageUrl: data.item_content_imgs[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = GoodsObject
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReGoodsDetailTC0", for: indexPath) as! ReGoodsDetailTC
            
            cell.storeNameEng_label.text = data.store_name_eng
            cell.storeName_label.text = data.store_name
            cell.store_btn.addTarget(self, action: #selector(store_btn(_:)), for: .touchUpInside)
            cell.item_img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(item_img(_:))))
            cell.itemImgPage_view.isHidden = !(data.item_photo_imgs.count > 1)
            cell.itemImgCount_label.text = "| \(data.item_photo_imgs.count)"
            cell.itemName_label.text = data.item_name
            cell.itemPrice_label.text = "₩ \(priceFormatter.string(from: data.item_price as NSNumber) ?? "0")"
            cell.itemSalePrice_label.text = "₩ \(priceFormatter.string(from: data.item_sale_price as NSNumber) ?? "0")"
            let percent = ((Double(data.item_price)-Double(data.item_sale_price))/Double(data.item_price)*1000).rounded()/10
            cell.itemSalePercent_label.isHidden = ((percent == 0) || !data.item_sale)
            cell.itemSalePercent_label.text = "↓ \(percent)%"
            cell.categoryName_label.layer.cornerRadius = 7.5
            cell.categoryName_label.clipsToBounds = true
            cell.categoryName_label.text = "\(data.item_category_name)".replacingOccurrences(of: ", ", with: " > ").replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
            cell.categoryName_label_width.constant = stringWidth(text: cell.categoryName_label.text!, fontSize: 12)+20
            cell.itemTop_img.isHidden = !(data.item_top_check)
            cell.optionSelect_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(optionSelect_view(_:))))
            
            return cell
        } else if indexPath.section == 1 {
            
            let data = OptionArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReGoodsDetailTC1", for: indexPath) as! ReGoodsDetailTC
            
            cell.optionColor_view.backgroundColor = .init(hex: "#\(ColorArray[data.color] ?? "ffffff")")
            cell.optionSequence_label.text = "상품 \(data.sequence)."
            if (data.price-GoodsObject.item_sale_price) < 0 {
                cell.optionName_label.text = "\(data.color) + \(data.size) (₩ \(priceFormatter.string(from: (data.price-GoodsObject.item_sale_price) as NSNumber) ?? "0"))"
            } else {
                cell.optionName_label.text = "\(data.color) + \(data.size) (+₩ \(priceFormatter.string(from: (data.price-GoodsObject.item_sale_price) as NSNumber) ?? "0"))"
            }
            cell.optionDelete_btn.tag = indexPath.row; cell.optionDelete_btn.addTarget(self, action: #selector(optionDelete_btn(_:)), for: .touchUpInside)
            cell.optionMinus_btn.tag = indexPath.row; cell.optionMinus_btn.addTarget(cell, action: #selector(cell.optionMinus_btn(_:)), for: .touchUpInside)
            cell.optionQuantity_label.text = "\(data.quantity)"
            cell.optionPlus_btn.tag = indexPath.row; cell.optionPlus_btn.addTarget(cell, action: #selector(cell.optionPlus_btn(_:)), for: .touchUpInside)
            cell.optionPrice_label.text = "₩ \(priceFormatter.string(from: data.price*data.quantity as NSNumber) ?? "0")"
            
            return cell
        } else if indexPath.section == 2 {
            return tableView.dequeueReusableCell(withIdentifier: "ReGoodsDetailTC2", for: indexPath) as! ReGoodsDetailTC
        } else if indexPath.section == 3 || indexPath.section == 4 {
            
            let data = GoodsObject
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReGoodsDetailTC3", for: indexPath) as! ReGoodsDetailTC
            
            cell.itemContent_label.text = data.item_content
            
            cell.itemCategory_label.text = "\(data.item_category_name)".replacingOccurrences(of: ", ", with: " > ").replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
            cell.itemColor_label.text = "\(data.item_colors)".replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
            cell.itemSize_label.text = "\(data.item_sizes)".replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
            cell.itemStyle_label.text = data.item_style
            cell.itemMaterial_label.text = "\(data.item_materials)".replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
            cell.itemKey_label.text = data.item_key
            
            let material_washing = ["thickness": ["두꺼움": 0, "보통": 1, "얇음": 2], "see_through": ["있음": 3, "보통": 4, "없음": 5], "flexibility": ["좋음": 6, "보통": 7, "없음": 8], "lining": ["있음": 9, "없음": 10, "기모안감": 11], "washing": ["손세탁": 12, "드라이클리닝": 13, "물세탁": 14, "단독세탁": 15, "울세탁": 16, "표백제사용금지": 17, "다림질금지": 18, "세탁기금지": 19]]
            data.item_material_washing.forEach { (key: String, value: Any) in
                
                let materialValue = value as? String ?? ""
                let washingValue = value as? [String] ?? []
                print(washingValue)
                if let map = material_washing[key], let tag = map[materialValue] {
                    
                    cell.itemMaterialWasingInfo_labels.forEach { label in
                        
                        switch (label.tag, tag) {
                        case (0...2, 0...2), (3...5, 3...5), (6...8, 6...8), (9...11, 9...11), (12...19, 12...19):
                            label.textColor = (label.tag == tag) ? .black : .black.withAlphaComponent(0.3)
                        case (12...19, 12...19):
                            label.textColor = (label.tag == tag) ? (label.textColor != .black) ? .black : .black.withAlphaComponent(0.3) : label.textColor
                        default:
                            break
                        }
                    }
                }
            }
            
            
//            if data.item_material_washing.count > 0 {
//                
//                cell.itemMaterialThickness_label.text = data.item_material_washing["thickness"] as? String ?? ""
//                cell.itemMaterialSeeThrough_label.text = data.item_material_washing["see_through"] as? String ?? ""
//                cell.itemMaterialFlexibility_label.text = data.item_material_washing["flexibility"] as? String ?? ""
//                cell.itemMaterialLining_label.text = data.item_material_washing["lining"] as? String ?? ""
//                cell.itemMaterialWashing_label.text = "\(data.item_material_washing["washing"] as? [String] ?? [])".replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
//            }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func store_btn(_ sender: UIButton) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReStoreVisitVC") as! ReStoreVisitVC
        segue.store_id = GoodsObject.store_id
        navigationController?.pushViewController(segue, animated: true)
    }
    
    @objc func item_img(_ sender: UITapGestureRecognizer) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ImageSlideVC") as! ImageSlideVC
        segue.imageUrls = GoodsObject.item_photo_imgs
        navigationController?.pushViewController(segue, animated: true)
    }
    
    @objc func optionSelect_view(_ sender: UITapGestureRecognizer) {
        
        if GoodsObject.item_option.count > 0 {
            let segue = storyboard?.instantiateViewController(withIdentifier: "ReGoodsOptionVC") as! ReGoodsOptionVC
            segue.GoodsObject = GoodsObject
            presentPanModal(segue)
        } else {
            customAlert(message: "선택 가능한 상품이 없습니다.", time: 1)
        }
    }
    
    @objc func optionDelete_btn(_ sender: UIButton) {
        OptionArray.remove(at: sender.tag)
        UIView.setAnimationsEnabled(false)
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
        UIView.setAnimationsEnabled(true)
        setTotalPrice()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 2 {
            return itemContent_img_height[indexPath.row] ?? UITableView.automaticDimension
        } else {
            return UITableView.automaticDimension
        }
    }
}
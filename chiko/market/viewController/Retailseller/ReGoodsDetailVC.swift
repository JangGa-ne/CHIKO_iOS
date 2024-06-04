//
//  ReGoodsDetailVC.swift
//  market
//
//  Created by 장 제현 on 11/11/23.
//

/// 번역완료

import UIKit
import FirebaseFirestore
import ImageSlideshow
import PanModal

class ReGoodsDetailTC: UITableViewCell {
    
    var ItemOptionArray: [(color: String, price: Int, quantity: Int, sequence: Int, size: String)] = []
    
    @IBOutlet var labels: [UILabel]!
    
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
    @IBOutlet weak var itemWeaving_label: UILabel!
    @IBOutlet weak var itemCountry_label: UILabel!
    @IBOutlet weak var itemKey_label: UILabel!
    
    @IBOutlet var itemMaterialWasingInfo_labels: [UILabel]!
    
    @objc func optionMinus_btn(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard let data = ReGoodsDetailVCdelegate?.ItemOptionArray[sender.tag] else { return }
        if data.quantity > 1 { data.quantity -= 1; optionQuantity_label.text = "\(data.quantity)" }
        optionPrice_label.text = "₩\(priceFormatter.string(from: data.price*data.quantity as NSNumber) ?? "0")"
        ReGoodsDetailVCdelegate?.setTotalPrice()
    }
    
    @objc func optionPlus_btn(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard let data = ReGoodsDetailVCdelegate?.ItemOptionArray[sender.tag] else { return }
        data.quantity += 1; optionQuantity_label.text = "\(data.quantity)"
        optionPrice_label.text = "₩\(priceFormatter.string(from: data.price*data.quantity as NSNumber) ?? "0")"
        ReGoodsDetailVCdelegate?.setTotalPrice()
    }
}

extension ReGoodsDetailTC: ImageSlideshowDelegate {
    
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        itemImgPage_label.text = "\(page+1)"
        item_img.tag = page
    }
}

class ReGoodsDetailVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var store_id: String = ""
    var item_key: String = ""
    
    var GoodsObject: GoodsData = GoodsData()
    var ItemOptionArray: [ItemOptionData] = []
    
    var itemContent_img_height: [Int: CGFloat] = [:]
    
    var total_price: Int = 0
    var total_quantity: Int = 0
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalPrice_label: UILabel!
    @IBOutlet weak var basket_btn: UIButton!
    @IBOutlet weak var order_btn: UIButton!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in label.text = translation(label.text!) }
        buttons.forEach { btn in btn.setTitle(translation(btn.title(for: .normal)), for: .normal) }
        
        guard store_id != "" && item_key != "" else { return }
        
        customLoadingIndicator(text: "불러오는 중...", animated: true)
        
        requestFindReGoods(store_id: store_id, item_key: item_key) { object, status in
            
            self.store_id = ""; self.item_key = ""; self.customLoadingIndicator(animated: false)
            
            switch status {
            case 200:
                self.GoodsObject = object; self.viewDidLoad()
            default:
                self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard store_id == "" && item_key == "" else { return }
        
        ReGoodsDetailVCdelegate = self
        
        preheatImages(urls: GoodsObject.item_content_imgs.compactMap { URL(string: $0) })
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = .zero }
        tableView.delegate = self; tableView.dataSource = self
        
        GoodsObject.item_content_imgs.enumerated().forEach { i, imageUrl in
            imageUrlHeight(imageUrl: imageUrl) { height in
                DispatchQueue.main.async {
                    self.itemContent_img_height[i] = height+20
                    UIView.setAnimationsEnabled(false); self.tableView.reloadRows(at: [IndexPath(row: i, section: 2)], with: .none); UIView.setAnimationsEnabled(true)
                }
            }
        }
        
        ([basket_btn, order_btn] as [UIButton]).enumerated().forEach { i, btn in
            btn.tag = i; btn.addTarget(self, action: #selector(basket_order_btn(_:)), for: .touchUpInside)
        }
    }
    
    @objc func basket_order_btn(_ sender: UIButton) {
        
        guard ItemOptionArray.count != 0 else { customAlert(message: "상품을 선택해주세요.", time: 1); return }
        
        var item_option: Array<[String: Any]> = []
        ItemOptionArray.forEach { data in
            item_option.append([
                "color": data.color,
                "price": data.price,
                "quantity": data.quantity,
                "size": data.size,
                "sold_out": String(data.sold_out)
            ])
        }
        
        let timestamp = setGMTUnixTimestamp()
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
            
            customLoadingIndicator(text: "불러오는 중...", animated: true)
            
            /// ReBasket 요청
            requestReBasket(type: type, params: params) { status in
                
                self.customLoadingIndicator(animated: false)
                
                switch status {
                case 200:
                    self.customAlert(message: "장바구니에 상품이 담겼습니다.", time: 1) {
//                        self.segueViewController(identifier: "ReBasketVC")
                    }
                default:
                    self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
                }
            }
        } else if sender.tag == 1 {
            /// order
            let segue = storyboard?.instantiateViewController(withIdentifier: "ReLiquidateVC") as! ReLiquidateVC
            segue.LiquidateArray = [setBasket(basketDict: params)]
            navigationController?.pushViewController(segue, animated: true, completion: nil)
        }
    }
    
    func setTotalPrice() {
        total_price = 0
        total_quantity = 0
        ItemOptionArray.forEach { data in 
            total_price += (data.price*data.quantity)
            total_quantity += data.quantity
        }
        totalPrice_label.text = "₩\(priceFormatter.string(from: total_price as NSNumber) ?? "0")"
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
        } else if section == 1, ItemOptionArray.count > 0 {
            return ItemOptionArray.count
        } else if section == 2, GoodsObject.item_content_imgs.count > 0 {
            return GoodsObject.item_content_imgs.count
        } else if section == 3 {
            return 1
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var data = GoodsObject
        guard let cell = cell as? ReGoodsDetailTC else { return }
        
        if indexPath.section == 0 && !data.load { data.load = true
            
            if data.store_mainphoto_img == "" && data.store_id != "" {
                Firestore.firestore().collection("store").document(GoodsObject.store_id).getDocument { docu, error in
                    let dict = docu?.data() ?? [:]
                    setKingfisher(imageView: cell.store_img, imageUrl: dict["store_mainphoto_img"] as? String ?? "", cornerRadius: 18)
                }
            } else {
                setKingfisher(imageView: cell.store_img, imageUrl: data.store_mainphoto_img, cornerRadius: 18)
            }
            setImageSlideShew(imageView: cell.item_img, imageUrls: data.item_photo_imgs, completionHandler: nil)
            cell.item_img.pageIndicator = .none
            cell.item_img.slideshowInterval = 5
            cell.item_img.delegate = cell
        } else if indexPath.section == 2 {
            setKingfisher(imageView: cell.itemContent_img, imageUrl: data.item_content_imgs[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? ReGoodsDetailTC else { return }
        
        if indexPath.section == 0 {
            cancelKingfisher(imageView: cell.store_img)
        } else if indexPath.section == 2 {
            cancelKingfisher(imageView: cell.itemContent_img)
        }; cell.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = GoodsObject
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReGoodsDetailTC0", for: indexPath) as! ReGoodsDetailTC
            
            cell.labels.forEach { label in label.text = translation(label.text!) }
            
            cell.storeNameEng_label.text = data.store_name_eng
            cell.storeName_label.text = data.store_name
            cell.store_btn.setTitle(translation("매장 보기"), for: .normal)
            cell.store_btn.addTarget(self, action: #selector(store_btn(_:)), for: .touchUpInside)
            cell.item_img.delegate = cell
            cell.item_img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(item_img(_:))))
            cell.itemImgPage_view.isHidden = !(data.item_photo_imgs.count > 1)
            cell.itemImgCount_label.text = "| \(data.item_photo_imgs.count)"
            cell.itemName_label.text = data.item_name
            cell.itemPrice_label.text = "₩\(priceFormatter.string(from: data.item_price as NSNumber) ?? "0")"
            cell.itemSalePrice_label.text = "₩\(priceFormatter.string(from: data.item_sale_price as NSNumber) ?? "0")"
            let percent = ((Double(data.item_price)-Double(data.item_sale_price))/Double(data.item_price)*1000).rounded()/10
            cell.itemSalePercent_label.isHidden = ((percent == 0) || !data.item_sale)
            cell.itemSalePercent_label.text = "↓ \(percent)%"
            cell.categoryName_label.layer.cornerRadius = 7.5
            cell.categoryName_label.clipsToBounds = true
            cell.categoryName_label.text = data.item_category_name.map { translation($0) }.joined(separator: " > ")
            cell.categoryName_label_width.constant = stringWidth(text: cell.categoryName_label.text!, fontSize: 12)+20
            cell.itemTop_img.isHidden = !(data.item_top_check)
            cell.optionSelect_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(optionSelect_view(_:))))
            
            return cell
        } else if indexPath.section == 1 {
            
            let data = ItemOptionArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReGoodsDetailTC1", for: indexPath) as! ReGoodsDetailTC
            
            cell.optionColor_view.backgroundColor = .init(hex: "#\(ColorArray[data.color] ?? "ffffff")")
            cell.optionSequence_label.text = "\(translation("상품")) \(data.sequence)."
            if (data.price-GoodsObject.item_sale_price) < 0 {
                cell.optionName_label.text = "\(translation(data.color)) + \(translation(data.size)) (₩\(priceFormatter.string(from: (data.price-GoodsObject.item_sale_price) as NSNumber) ?? "0"))"
            } else {
                cell.optionName_label.text = "\(translation(data.color)) + \(translation(data.size)) (+₩\(priceFormatter.string(from: (data.price-GoodsObject.item_sale_price) as NSNumber) ?? "0"))"
            }
            cell.optionDelete_btn.tag = indexPath.row; cell.optionDelete_btn.addTarget(self, action: #selector(optionDelete_btn(_:)), for: .touchUpInside)
            cell.optionMinus_btn.tag = indexPath.row; cell.optionMinus_btn.addTarget(cell, action: #selector(cell.optionMinus_btn(_:)), for: .touchUpInside)
            cell.optionQuantity_label.text = "\(data.quantity)"
            cell.optionPlus_btn.tag = indexPath.row; cell.optionPlus_btn.addTarget(cell, action: #selector(cell.optionPlus_btn(_:)), for: .touchUpInside)
            cell.optionPrice_label.text = "₩\(priceFormatter.string(from: data.price*data.quantity as NSNumber) ?? "0")"
            
            return cell
        } else if indexPath.section == 2 {
            return tableView.dequeueReusableCell(withIdentifier: "ReGoodsDetailTC2", for: indexPath) as! ReGoodsDetailTC
        } else if indexPath.section == 3 {
            
            let data = GoodsObject
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReGoodsDetailTC3", for: indexPath) as! ReGoodsDetailTC
            
            cell.labels.forEach { label in label.text = translation(label.text!) }
            
            cell.itemContent_label.text = data.item_content
            
            cell.itemCategory_label.text = data.item_category_name.map { translation($0) }.joined(separator: " > ")
            cell.itemColor_label.text = data.item_colors.map { translation($0) }.joined(separator: ", ")
            cell.itemSize_label.text = data.item_sizes.map { translation($0) }.joined(separator: ", ")
            cell.itemStyle_label.text = translation(data.item_style)
            cell.itemMaterial_label.text = data.item_materials.map { text in
                guard let range = text.range(of: " ") else { return text }
                let material = String(text[..<range.lowerBound])
                return translation(material) + text.replacingOccurrences(of: "\(material) ", with: "")
            }.joined(separator: ", ")
            cell.itemWeaving_label.text = data.item_build
            cell.itemCountry_label.text = data.item_manufacture_country
            cell.itemKey_label.text = data.item_key
            
            data.item_material_washing.forEach { (key: String, value: Any) in
                
                guard let map = material_washing[key] else { return }
                let tags: [Int] = (key != "washing") ? [map[value as? String ?? ""]].compactMap { $0 } : (value as? [String] ?? []).compactMap { map[$0] }

                cell.itemMaterialWasingInfo_labels.forEach { label in
                    
                    if tags.contains(label.tag) { label.textColor = .black }
                    
                    switch label.tag {
                    case 13: label.text = translation("드라이\n클리닝")
                    case 17: label.text = translation("표백제\n사용금지")
                    case 18: label.text = translation("다림질\n금지")
                    case 19: label.text = translation("세탁기\n금지")
                    default: break
                    }
                }
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func store_btn(_ sender: UIButton) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReStoreVisitVC") as! ReStoreVisitVC
        segue.store_id = GoodsObject.store_id
        navigationController?.pushViewController(segue, animated: true, completion: nil)
    }
    
    @objc func item_img(_ sender: UITapGestureRecognizer) {
        
        guard let sender = sender.view as? ImageSlideshow else { return }
        let segue = storyboard?.instantiateViewController(withIdentifier: "ImageSlideVC") as! ImageSlideVC
        segue.inputs = sender.images
        segue.indexpath_row = sender.tag
        navigationController?.pushViewController(segue, animated: true, completion: nil)
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
        ItemOptionArray.remove(at: sender.tag)
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

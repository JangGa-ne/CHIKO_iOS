//
//  WhGoodsUploadTC.swift
//  market
//
//  Created by Busan Dynamic on 12/4/23.
//

import UIKit
import PanModal

class WhGoodsUploadCC: UICollectionViewCell {
    
    var WhGoodsUploadVCdelegate: WhGoodsUploadVC = WhGoodsUploadVC()
    var indexpath_row: Int = 0
    
    @IBOutlet weak var item_img: UIImageView!
    @IBOutlet weak var itemRow_label: UILabel!
    
    @IBOutlet weak var color_view: UIView!
    @IBOutlet weak var colorName_label: UILabel!
    
    @IBOutlet weak var sizeName_label: UILabel!
    
    @IBOutlet weak var materialName_label: UILabel!
    
    @IBOutlet weak var optionSize_label: UILabel!
    @IBOutlet weak var optionPrice_tf: UITextField!
    
    @IBOutlet weak var styleName_label: UILabel!
    
    @IBOutlet weak var content_img: UIImageView!
    @IBOutlet weak var contentRow_label: UILabel!
    
    @objc func edit_optionPrice_tf(_ sender: UITextField) {
        let price = priceFormatter.string(from: (Int(sender.text!.replacingOccurrences(of: ",", with: "")) ?? 0) as NSNumber) ?? "0"
        if sender.text! == "0" || sender.text! == "" { sender.text!.removeAll() } else { sender.text! = price }
    }
    
    @objc func end_optionPrice_tf(_ sender: UITextField) {
        
        let data = WhGoodsUploadVCdelegate.GoodsObject
        
        let color = WhGoodsUploadVCdelegate.OptionPriceArray[indexpath_row].color_name
        let size = WhGoodsUploadVCdelegate.OptionPriceArray[indexpath_row].size_price[sender.tag].size
        var price: Int = 0
        
        if sender.text! == "0" || sender.text! == "" {
            price = Int(sender.placeholder!.replacingOccurrences(of: ",", with: "")) ?? 0
        } else {
            price = Int(sender.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        }
        
        if data.item_sale_price > price {
            sender.resignFirstResponder()
            WhGoodsUploadVCdelegate.customAlert(message: "설정한 단가 보다 낮을 수 없습니다.", time: 1) {
                sender.text!.removeAll(); sender.becomeFirstResponder()
            }
        } else if let option = data.item_option.first(where: { $0.color == color && $0.size == size }) {
            WhGoodsUploadVCdelegate.OptionPriceArray[indexpath_row].size_price[sender.tag].price = price
            option.price = price
        }
    }
}

class WhGoodsUploadTC: UITableViewCell {
    
    var WhGoodsUploadVCdelegate: WhGoodsUploadVC = WhGoodsUploadVC()
    var indexpath_section: Int = 0
    var indexpath_row: Int = 0
    
    @IBOutlet weak var itemCount_label: UILabel!
    @IBOutlet weak var itemCollectionView: UICollectionView!
    
    @IBOutlet weak var itemCategory_btn: UIButton!
    
    @IBOutlet weak var itemName_tf: UITextField!
    
    @IBOutlet weak var sale_img: UIImageView!
    @IBOutlet weak var sale_label: UILabel!
    @IBOutlet weak var sale_btn: UIButton!
    @IBOutlet weak var itemPrice_view: UIView!
    @IBOutlet weak var itemPrice_tf: UITextField!
    @IBOutlet weak var itemSalePrice_tf: UITextField!
    @IBOutlet weak var noticeItemSalePrice_label: UILabel!
    
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var color_btn: UIButton!
    
    @IBOutlet weak var sizeCollectionView: UICollectionView!
    
    @IBOutlet weak var optionPrice_img: UIImageView!
    @IBOutlet weak var optionPrice_label: UILabel!
    @IBOutlet weak var optionPrice_btn: UIButton!
    @IBOutlet weak var optionColor_view: UIView!
    @IBOutlet weak var optionColor_label: UILabel!
    @IBOutlet weak var optionPriceCollectionView: UICollectionView!
    @IBOutlet weak var optionPriceCollectionView_height: NSLayoutConstraint!
    
    @IBOutlet weak var content_tv: UITextView!
    @IBOutlet weak var content_btn: UIButton!
    @IBOutlet weak var content_view: UIView!
    @IBOutlet weak var contentCollectionView: UICollectionView!
    
    @IBOutlet weak var style_sv: UIStackView!
    @IBOutlet weak var styleCollectionView: UICollectionView!
    
    @IBOutlet weak var materialCollectionView: UICollectionView!
    @IBOutlet weak var material_btn: UIButton!
    
    @IBOutlet weak var materialInfo_sv: UIStackView!
    @IBOutlet var materialWashing_imgs: [UIImageView]!
    @IBOutlet var materialWashing_labels: [UILabel]!
    @IBOutlet var materialWashing_btns: [UIButton]!
    
    @IBOutlet var otherType_imgs: [UIImageView]!
    @IBOutlet var otherType_labels: [UILabel]!
    @IBOutlet var otherType_btns: [UIButton]!
    
    func viewDidLoad() {
        
        UIView.setAnimationsEnabled(false)
        
        if indexpath_section == 0 {
            
            itemCollectionView.delegate = nil; itemCollectionView.dataSource = nil
            itemCollectionView.dragDelegate = nil; itemCollectionView.dropDelegate = nil
            
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            itemCollectionView.setCollectionViewLayout(layout, animated: true, completion: nil)
            itemCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 10)
            itemCollectionView.contentOffset.x = WhGoodsUploadVCdelegate.collectionViewContentOffsets[0] ?? 0.0
            itemCollectionView.delegate = self; itemCollectionView.dataSource = self
            itemCollectionView.dragDelegate = self; itemCollectionView.dropDelegate = self
        } else if indexpath_section == 1 {
            
            ([colorCollectionView, sizeCollectionView] as [UICollectionView]).enumerated().forEach { i, collectionView in
                
                if collectionView == colorCollectionView { collectionView.backgroundColor = .white }
                
                collectionView.delegate = nil; collectionView.dataSource = nil
                
                let layout = UICollectionViewFlowLayout()
                if collectionView == colorCollectionView {
                    layout.minimumLineSpacing = 5; layout.minimumInteritemSpacing = 5; layout.scrollDirection = .horizontal
                    layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
                } else {
                    layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
                    layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                }
                collectionView.setCollectionViewLayout(layout, animated: true, completion: nil)
                collectionView.contentOffset.x = WhGoodsUploadVCdelegate.collectionViewContentOffsets[i+1] ?? 0.0
                collectionView.delegate = self; collectionView.dataSource = self
            }
        } else if indexpath_section == 2 {
            
            optionPriceCollectionView.delegate = nil; optionPriceCollectionView.dataSource = nil
            
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 0; layout.minimumInteritemSpacing = 0; layout.scrollDirection = .vertical
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            optionPriceCollectionView.setCollectionViewLayout(layout, animated: true, completion: nil)
            optionPriceCollectionView.contentOffset.x = WhGoodsUploadVCdelegate.collectionViewContentOffsets[3] ?? 0.0
            optionPriceCollectionView.delegate = self; optionPriceCollectionView.dataSource = self
        } else if indexpath_section == 3 {
            
            ([styleCollectionView, contentCollectionView, materialCollectionView] as [UICollectionView]).enumerated().forEach { i, collectionView in
                
                if collectionView == materialCollectionView { collectionView.backgroundColor = .white }
                
                collectionView.delegate = nil; collectionView.dataSource = nil
                
                let layout = UICollectionViewFlowLayout()
                if collectionView == materialCollectionView {
                    layout.minimumLineSpacing = 5; layout.minimumInteritemSpacing = 5; layout.scrollDirection = .horizontal
                    layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
                } else {
                    layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
                    layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                }
                collectionView.setCollectionViewLayout(layout, animated: true, completion: nil)
                collectionView.contentOffset.x = WhGoodsUploadVCdelegate.collectionViewContentOffsets[i+3+1] ?? 0.0
                collectionView.delegate = self; collectionView.dataSource = self
            }
        }
        
        UIView.setAnimationsEnabled(true)
    }
    
    @objc func category_btn(_ sender: UIButton) {
        
        WhGoodsUploadVCdelegate.view.endEditing(true)
        
        if sender.tag != 0, WhGoodsUploadVCdelegate.GoodsObject.item_category_name.count == 0 {
            WhGoodsUploadVCdelegate.customAlert(message: "카테고리를 선택해 주세요.", time: 1); return
        }
        
        let segue = WhGoodsUploadVCdelegate.storyboard?.instantiateViewController(withIdentifier: "CategoryVC") as! CategoryVC
        segue.WhGoodsUploadVCdelegate = WhGoodsUploadVCdelegate
        
        if sender.tag == 0 {
            segue.option_type = "category"
        } else if sender.tag == 1 {
            segue.option_type = "color"
        } else if sender.tag == 2 {
            segue.option_type = "material"
        }
        
        WhGoodsUploadVCdelegate.presentPanModal(segue)
    }
    
    @objc func edit_textfield(_ sender: UITextField) {
        
        let data = WhGoodsUploadVCdelegate.GoodsObject
        
        if sender.keyboardType == .numberPad {
            sender.text! = priceFormatter.string(from: (Int(sender.text!.replacingOccurrences(of: ",", with: "")) ?? 0) as NSNumber) ?? ""
        }
        let item_price = Int(itemPrice_tf.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        let item_sale_price = Int(itemSalePrice_tf.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        
        if sender.tag == 0 {
            data.item_name = sender.text!
        } else if sender.tag == 1 {
            
            data.item_price = item_price
            
            if (3000000 < item_price) {
                data.item_price = 3000000
                sender.text = "3,000,000"
                sender.resignFirstResponder()
                WhGoodsUploadVCdelegate.customAlert(message: "최대 300만원까지만 입력 가능합니다.", time: 1) { sender.becomeFirstResponder() }
            }
        } else if sender.tag == 2 {
            
            noticeItemSalePrice_label.isHidden = true
            
            data.item_sale_price = item_sale_price
            
            if !WhGoodsUploadVCdelegate.item_sale {
                data.item_price = data.item_sale_price
                itemPrice_tf.text!.removeAll()
            }
            
            if (3000000 < item_sale_price) {
                data.item_sale_price = 3000000
                sender.text = "3,000,000"
                sender.resignFirstResponder()
                WhGoodsUploadVCdelegate.customAlert(message: "최대 300만원까지만 입력 가능합니다.", time: 1) { sender.becomeFirstResponder() }
            } else if itemPrice_tf.text! != "" && item_price < item_sale_price {
                sender.text = priceFormatter.string(from: item_price as NSNumber) ?? sender.text!
            }
        }
        
        UIView.setAnimationsEnabled(false); WhGoodsUploadVCdelegate.tableView.reloadSections(IndexSet(integer: 2), with: .none); UIView.setAnimationsEnabled(true)
    }
    
    @objc func end_textfield(_ sender: UITextField) {
        
        let item_price = Int(itemPrice_tf.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        let item_sale_price = Int(itemSalePrice_tf.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        
        if sender == itemPrice_tf {
            
            if 100 > item_price {
                sender.text = "100"
                DispatchQueue.main.async { self.itemPrice_tf.resignFirstResponder(); self.itemSalePrice_tf.resignFirstResponder() }
                WhGoodsUploadVCdelegate.customAlert(message: "가격(원가)을 정확히 입력해 주세요.\n(최소 단위: 100원)", time: 2) { self.itemPrice_tf.becomeFirstResponder() }
            } else if item_price <= item_sale_price {
                WhGoodsUploadVCdelegate.notice_sale_price = false; noticeItemSalePrice_label.text = "할인가는 원가보다 크거나 같을 수 없습니다."
            } else if item_sale_price > 0 && Int(item_price/item_sale_price) > 10 {
                WhGoodsUploadVCdelegate.notice_sale_price = false; noticeItemSalePrice_label.text = "할인가는 원가의 10배를 넘을 수 없습니다."
            } else {
                WhGoodsUploadVCdelegate.notice_sale_price = true
            }
            
        } else if sender == itemSalePrice_tf {
            
            if 100 > item_sale_price {
                WhGoodsUploadVCdelegate.notice_sale_price = false; noticeItemSalePrice_label.text = "할인가를 정확히 입력해 주세요.(최소 단위: 100원)"
            } else if WhGoodsUploadVCdelegate.item_sale && item_price/item_sale_price > 10 {
                WhGoodsUploadVCdelegate.notice_sale_price = false; noticeItemSalePrice_label.text = "할인가는 원가의 10배를 넘을 수 없습니다."
            } else if WhGoodsUploadVCdelegate.item_sale && item_price <= item_sale_price {
                WhGoodsUploadVCdelegate.notice_sale_price = false; noticeItemSalePrice_label.text = "할인가는 원가보다 크거나 같을 수 없습니다."
            } else {
                WhGoodsUploadVCdelegate.notice_sale_price = true
            }
        }
        
        WhGoodsUploadVCdelegate.tableView.reloadData()
    }
    
    @objc func select_btn(_ sender: UIButton) {
        
        WhGoodsUploadVCdelegate.view.endEditing(true)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        let data = WhGoodsUploadVCdelegate.GoodsObject
        
        if sender.tag == 0 {
            
            WhGoodsUploadVCdelegate.item_sale = !WhGoodsUploadVCdelegate.item_sale
            data.item_sale = !data.item_sale
            if !WhGoodsUploadVCdelegate.item_sale {
                data.item_price = data.item_sale_price; itemPrice_tf.text!.removeAll()
            }
        } else if sender.tag == 1 {
            
            if data.item_sale_price == 0 {
                WhGoodsUploadVCdelegate.customAlert(message: "단가를 입력해 주세요.", time: 1)
            } else if WhGoodsUploadVCdelegate.ColorArray.count == 0 {
                WhGoodsUploadVCdelegate.customAlert(message: "색상을 설정해 주세요.", time: 1)
            } else if WhGoodsUploadVCdelegate.SizeArray.filter({ $0.option_select }).count == 0 {
                WhGoodsUploadVCdelegate.customAlert(message: "사이즈를 설정해 주세요.", time: 1)
            } else {
                WhGoodsUploadVCdelegate.item_option_type = !WhGoodsUploadVCdelegate.item_option_type
                data.item_option_type = !data.item_option_type
            }
        }
        
        WhGoodsUploadVCdelegate.tableView.reloadData()
    }
    
    @objc func content_btn(_ sender: UIButton) {
        
        WhGoodsUploadVCdelegate.view.endEditing(true)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        if 10-WhGoodsUploadVCdelegate.ContentsArray.count == 0 {
            
            let alert = UIAlertController(title: "", message: "이미지는 최대 10장까지\n등록할 수 있습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
            WhGoodsUploadVCdelegate.present(alert, animated: true, completion: nil)
        } else {
            
            WhGoodsUploadVCdelegate.setPhoto(max: 10-WhGoodsUploadVCdelegate.ContentsArray.count) { photos in
                photos.forEach { photo in
                    self.WhGoodsUploadVCdelegate.ContentsArray.append(photo)
                    self.WhGoodsUploadVCdelegate.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func materialWashing_btn(_ sender: UIButton) {
        
        if sender.frame != .zero {
            WhGoodsUploadVCdelegate.view.endEditing(true)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        
        let data = WhGoodsUploadVCdelegate.GoodsObject
        
        if data.item_category_name.count == 0 {
            WhGoodsUploadVCdelegate.customAlert(message: "카테고리를 선택해 주세요.", time: 1); return
        }
        
        materialWashing_imgs.forEach { img in
            
            switch (img.tag, sender.tag) {
            case (0...2, 0...2), (3...5, 3...5), (6...8, 6...8), (9...11, 9...11):
                img.image = (img.tag == sender.tag) ? UIImage(named: "check_on") : UIImage(named: "check_off")
            case (12...19, 12...19):
                img.image = (img.tag == sender.tag) ? (img.image == UIImage(named: "check_on") ? UIImage(named: "check_off") : UIImage(named: "check_on")) : img.image
            default:
                break
            }
        }
        
        materialWashing_labels.forEach { label in
            
            switch (label.tag, sender.tag) {
            case (0...2, 0...2), (3...5, 3...5), (6...8, 6...8), (9...11, 9...11):
                label.textColor = (label.tag == sender.tag) ? .black : .black.withAlphaComponent(0.3)
            case (12...19, 12...19):
                label.textColor = (label.tag == sender.tag) ? (label.textColor != .black) ? .black : .black.withAlphaComponent(0.3) : label.textColor
            default:
                break
            }
        }
        
        let material_washing = ["두꺼움", "보통", "얇음", "있음", "보통", "없음", "좋음", "보통", "없음", "있음", "없음", "기모안감", "손세탁", "드라이클리닝", "물세탁", "단독세탁", "울세탁", "표백제사용금지", "다림질금지", "세탁기금지"][sender.tag]
        materialWashing_btns.forEach { btn in
            
            switch (btn.tag, btn.tag == sender.tag) {
            case (0...2, true):
                WhGoodsUploadVCdelegate.MaterialInfoArray["thickness"] = material_washing
                data.item_material_washing["thickness"] = material_washing
            case (3...5, true):
                WhGoodsUploadVCdelegate.MaterialInfoArray["see_through"] = material_washing
                data.item_material_washing["see_through"] = material_washing
            case (6...8, true):
                WhGoodsUploadVCdelegate.MaterialInfoArray["flexibility"] = material_washing
                data.item_material_washing["flexibility"] = material_washing
            case (9...11, true):
                WhGoodsUploadVCdelegate.MaterialInfoArray["lining"] = material_washing
                data.item_material_washing["lining"] = material_washing
            case (12...19, true):
                if sender.frame != .zero {
                    btn.isSelected = !btn.isSelected
                    if btn.isSelected {
                        WhGoodsUploadVCdelegate.WashingInfoArray.append(material_washing)
                    } else if let index = WhGoodsUploadVCdelegate.WashingInfoArray.firstIndex(of: material_washing) {
                        WhGoodsUploadVCdelegate.WashingInfoArray.remove(at: index)
                    }
                    data.item_material_washing["washing"] = WhGoodsUploadVCdelegate.WashingInfoArray
                }
            default:
                break
            }
        }
    }
    
    @objc func otherType_btn(_ sender: UIButton) {
            
        if sender.frame != .zero {
            WhGoodsUploadVCdelegate.view.endEditing(true)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        
        let data = WhGoodsUploadVCdelegate.GoodsObject
        
        otherType_imgs.forEach { img in
            
            switch (img.tag, sender.tag) {
            case (0...1, 0...1), (2...3, 2...3), (4...5, 4...5):
                img.image = (img.tag == sender.tag) ? UIImage(named: "check_on") : UIImage(named: "check_off")
            default:
                break
            }
        }
        
        otherType_labels.forEach { label in
            
            switch (label.tag, sender.tag) {
            case (0...1, 0...1), (2...3, 2...3), (4...5, 4...5):
                label.textColor = (label.tag == sender.tag) ? .black : .black.withAlphaComponent(0.3)
            default:
                break
            }
        }
        
        let other_type = ["편물(니트/다이마루)", "직물(우븐)", "대한민국", "대한민국외 국가", "전체 공개", "거래처만 공개"][sender.tag]
        otherType_btns.forEach { btn in
            
            switch (btn.tag, btn.tag == sender.tag) {
            case (0...1, true):
                WhGoodsUploadVCdelegate.OtherTypeArray["build"] = other_type
                data.item_build = other_type
            case (2...3, true):
                WhGoodsUploadVCdelegate.OtherTypeArray["manufacture_country"] = other_type
                data.item_manufacture_country = other_type
            case (4...5, true):
                WhGoodsUploadVCdelegate.OtherTypeArray["disclosure"] = other_type
                data.item_disclosure = other_type
            default:
                break
            }
        }
    }
}

extension WhGoodsUploadTC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == content_tv {
            WhGoodsUploadVCdelegate.GoodsObject.item_content = textView.text!
        }
    }
}

extension WhGoodsUploadTC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == itemCollectionView { return 2 } else { return 1 }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let data = WhGoodsUploadVCdelegate.GoodsObject
        
        if collectionView == itemCollectionView {
            if section == 0, WhGoodsUploadVCdelegate.ItemArray.count < 20 {
                return 1
            } else if section == 1, WhGoodsUploadVCdelegate.ItemArray.count > 0 {
                return WhGoodsUploadVCdelegate.ItemArray.count
            } else {
                return .zero
            }
        } else if collectionView == colorCollectionView, data.item_colors.count > 0 {
            return data.item_colors.count
        } else if collectionView == sizeCollectionView, WhGoodsUploadVCdelegate.SizeArray.count > 0 {
            return WhGoodsUploadVCdelegate.SizeArray.count
        } else if collectionView == optionPriceCollectionView, WhGoodsUploadVCdelegate.OptionPriceArray[indexpath_row].size_price.count > 0 {
            return WhGoodsUploadVCdelegate.OptionPriceArray[indexpath_row].size_price.count
        } else if collectionView == styleCollectionView, WhGoodsUploadVCdelegate.StyleArray.count > 0 {
            return WhGoodsUploadVCdelegate.StyleArray.count
        } else if collectionView == contentCollectionView, WhGoodsUploadVCdelegate.ContentsArray.count > 0 {
            return WhGoodsUploadVCdelegate.ContentsArray.count
        } else if collectionView == materialCollectionView, data.item_materials.count > 0 {
            return data.item_materials.count
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.section == 1, collectionView == itemCollectionView {
            
            let data = WhGoodsUploadVCdelegate.ItemArray[indexPath.row]
            guard let cell = cell as? WhGoodsUploadCC else { return }
            
            cell.item_img.image = UIImage(data: data.file_data)
        } else if indexPath.section == 0, collectionView == contentCollectionView {
            
            let data = WhGoodsUploadVCdelegate.ContentsArray[indexPath.row]
            guard let cell = cell as? WhGoodsUploadCC else { return }
            
            cell.content_img.image = UIImage(data: data.file_data)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = WhGoodsUploadVCdelegate.GoodsObject
        
        if indexPath.section == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WhGoodsUploadCC0", for: indexPath) as! WhGoodsUploadCC
            cell.WhGoodsUploadVCdelegate = WhGoodsUploadVCdelegate
            cell.indexpath_row = indexpath_row
            
            if collectionView == colorCollectionView {
                
                cell.colorName_label.text = data.item_colors[indexPath.row]
                cell.color_view.backgroundColor = UIColor(hex: "#"+(CategoryObject.ColorArray_all[data.item_colors[indexPath.row]] as? String ?? "ffffff"))
                
            } else if collectionView == sizeCollectionView {
                
                let data = WhGoodsUploadVCdelegate.SizeArray[indexPath.row]
                
                cell.sizeName_label.text = data.option_name
                cell.layer.borderWidth = 1
                if data.option_select {
                    cell.layer.borderColor = UIColor.H_8CD26B.cgColor
                    cell.sizeName_label.textColor = .H_8CD26B
                } else {
                    cell.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
                    cell.sizeName_label.textColor = .black.withAlphaComponent(0.3)
                }
                
            } else if collectionView == optionPriceCollectionView {
                
                let data = WhGoodsUploadVCdelegate.OptionPriceArray[indexpath_row].size_price[indexPath.row]
                
                cell.optionSize_label.text = data.size
                cell.optionPrice_tf.placeholder(text: priceFormatter.string(from: WhGoodsUploadVCdelegate.GoodsObject.item_sale_price as NSNumber) ?? "0", color: .lightGray)
                if let option = WhGoodsUploadVCdelegate.GoodsObject.item_option.first(where: { $0.color == WhGoodsUploadVCdelegate.OptionPriceArray[indexpath_row].color_name && data.size == $0.size }), data.price != option.price {
                    WhGoodsUploadVCdelegate.OptionPriceArray[indexpath_row].size_price[indexPath.row].price = option.price
                    cell.optionPrice_tf.text = priceFormatter.string(from: option.price as NSNumber) ?? "0"
                } else if WhGoodsUploadVCdelegate.GoodsObject.item_sale_price < data.price {
                    cell.optionPrice_tf.text = priceFormatter.string(from: data.price as NSNumber) ?? "0"
                } else {
                    cell.optionPrice_tf.text!.removeAll()
                }
                cell.optionPrice_tf.tag = indexPath.row
                cell.optionPrice_tf.addTarget(cell, action: #selector(cell.edit_optionPrice_tf(_:)), for: .editingChanged)
                cell.optionPrice_tf.addTarget(cell, action: #selector(cell.end_optionPrice_tf(_:)), for: .editingDidEnd)
            } else if collectionView == styleCollectionView {
                
                cell.styleName_label.text = WhGoodsUploadVCdelegate.StyleArray[indexPath.row]
                cell.layer.borderWidth = 1
                if WhGoodsUploadVCdelegate.style_row != nil && WhGoodsUploadVCdelegate.style_row ?? 0 == indexPath.row {
                    cell.layer.borderColor = UIColor.H_8CD26B.cgColor
                    cell.styleName_label.textColor = .H_8CD26B
                } else {
                    cell.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
                    cell.styleName_label.textColor = .black.withAlphaComponent(0.3)
                }
                
            } else if collectionView == contentCollectionView {
                cell.contentRow_label.text = " "+String(format: "%02d", indexPath.row+1)
            } else if collectionView == materialCollectionView {
                cell.materialName_label.text = data.item_materials[indexPath.row]
            }
            
            return cell
        } else if indexPath.section == 1 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WhGoodsUploadCC1", for: indexPath) as! WhGoodsUploadCC
            cell.WhGoodsUploadVCdelegate = WhGoodsUploadVCdelegate
            cell.indexpath_row = indexpath_row
            
            if indexPath.row == 0 {
                cell.itemRow_label.text = "  "+"대표"
            } else {
                cell.itemRow_label.text = "  "+String(format: "%02d", indexPath.row+1)
            }
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let data = WhGoodsUploadVCdelegate.GoodsObject
        
        if collectionView == itemCollectionView {
            return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
        } else if collectionView == colorCollectionView {
            return CGSize(width: stringWidth(text: data.item_colors[indexPath.row], fontSize: 14)+64, height: collectionView.frame.height-10)
        } else if collectionView == sizeCollectionView {
            return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
        } else if collectionView == optionPriceCollectionView {
            return CGSize(width: collectionView.frame.width, height: 44)
        } else if collectionView == styleCollectionView {
            return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
        } else if collectionView == contentCollectionView {
            return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
        } else if collectionView == materialCollectionView {
            return CGSize(width: stringWidth(text: data.item_materials[indexPath.row], fontSize: 14)+35, height: collectionView.frame.height-10)
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        WhGoodsUploadVCdelegate.view.endEditing(true)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        let data = WhGoodsUploadVCdelegate.GoodsObject
        
        if collectionView == itemCollectionView, indexPath.section == 0 {
            WhGoodsUploadVCdelegate.setPhoto(max: 20-WhGoodsUploadVCdelegate.ItemArray.count) { photos in
                photos.forEach { photo in
                    self.WhGoodsUploadVCdelegate.ItemArray.append(photo)
                    self.itemCount_label.text = "\(self.WhGoodsUploadVCdelegate.ItemArray.count)/20"
                    collectionView.reloadData()
                }
            }
        } else if collectionView == itemCollectionView, indexPath.section == 1 {
            WhGoodsUploadVCdelegate.ItemArray.remove(at: indexPath.row)
            itemCount_label.text = "\(WhGoodsUploadVCdelegate.ItemArray.count)/20"
        } else if collectionView == colorCollectionView {
            WhGoodsUploadVCdelegate.ColorArray.remove(at: indexPath.row)
            data.item_colors.remove(at: indexPath.row)
            WhGoodsUploadVCdelegate.loadingData(index: 1)
            colorCollectionView.isHidden = (data.item_colors.count == 0)
            UIView.setAnimationsEnabled(false); WhGoodsUploadVCdelegate.tableView.reloadSections(IndexSet(integer: 2), with: .none); UIView.setAnimationsEnabled(true)
        } else if collectionView == sizeCollectionView {
            if data.item_category_name.count == 0 {
                WhGoodsUploadVCdelegate.customAlert(message: "카테고리를 선택해 주세요.", time: 1); return
            }
            WhGoodsUploadVCdelegate.SizeArray[indexPath.row].option_select = !WhGoodsUploadVCdelegate.SizeArray[indexPath.row].option_select
            data.item_sizes = WhGoodsUploadVCdelegate.SizeArray.flatMap { data in data.option_select ? [data.option_name] : [] }
            WhGoodsUploadVCdelegate.loadingData(index: 1)
            UIView.setAnimationsEnabled(false); WhGoodsUploadVCdelegate.tableView.reloadSections(IndexSet(integer: 2), with: .none); UIView.setAnimationsEnabled(true)
        } else if collectionView == optionPriceCollectionView {
            
        } else if collectionView == styleCollectionView {
            WhGoodsUploadVCdelegate.style_row = indexPath.row
            data.item_style = WhGoodsUploadVCdelegate.StyleArray[indexPath.row]
        } else if collectionView == contentCollectionView {
            WhGoodsUploadVCdelegate.ContentsArray.remove(at: indexPath.row)
            content_view.isHidden = (WhGoodsUploadVCdelegate.ContentsArray.count == 0)
        } else if collectionView == materialCollectionView {
            WhGoodsUploadVCdelegate.MaterialArray.remove(at: indexPath.row)
            data.item_materials.remove(at: indexPath.row)
            materialCollectionView.isHidden = (data.item_materials.count == 0)
        }
        collectionView.reloadData()
    }
}

extension WhGoodsUploadTC: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        if indexPath.section == 1 {
            let itemProvider = NSItemProvider(object: "\(WhGoodsUploadVCdelegate.ItemArray[indexPath.row])" as NSString)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = "\(WhGoodsUploadVCdelegate.ItemArray[indexPath.row])"
            return [dragItem]
        } else {
            return []
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard collectionView.hasActiveDrag else { collectionView.reloadData(); return UICollectionViewDropProposal(operation: .forbidden) }
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        if collectionView.indexPathForItem(at: session.location(in: collectionView))?.section == 1 {
            return session.hasItemsConforming(toTypeIdentifiers: ["public.utf8-plain-text"])
        } else {
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        guard let destinationIndexPath = coordinator.destinationIndexPath, destinationIndexPath.section == 1 else { return }
        
        coordinator.items.forEach { dropItem in
            
            guard let sourceIndexPath = dropItem.sourceIndexPath else { return }
            
            collectionView.performBatchUpdates({
                let movedItem = WhGoodsUploadVCdelegate.ItemArray.remove(at: sourceIndexPath.row)
                WhGoodsUploadVCdelegate.ItemArray.insert(movedItem, at: destinationIndexPath.row)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            }, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        collectionView.reloadData()
    }
}

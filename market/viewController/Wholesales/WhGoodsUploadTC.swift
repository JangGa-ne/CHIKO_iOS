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
    
    @objc func optionPrice_tf(_ sender: UITextField) {
        WhGoodsUploadVCdelegate.OptionPriceArray[indexpath_row].size_price[sender.tag].price = Int(sender.text!) ?? 0
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
    
    @IBOutlet weak var style_sv: UIStackView!
    @IBOutlet weak var styleCollectionView: UICollectionView!
    
    @IBOutlet weak var materialCollectionView: UICollectionView!
    @IBOutlet weak var material_btn: UIButton!
    
    @IBOutlet weak var content_tv: UITextView!
    @IBOutlet weak var content_btn: UIButton!
    @IBOutlet weak var content_view: UIView!
    @IBOutlet weak var contentCollectionView: UICollectionView!
    
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
                itemPrice_tf.text = "3,000,000"
                itemPrice_tf.resignFirstResponder()
                WhGoodsUploadVCdelegate.customAlert(message: "최대 300만원까지만 입력 가능합니다.", time: 1) { self.itemPrice_tf.resignFirstResponder() }
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
                itemSalePrice_tf.text = "3,000,000"
                itemSalePrice_tf.resignFirstResponder()
                WhGoodsUploadVCdelegate.customAlert(message: "최대 300만원까지만 입력 가능합니다.", time: 1) { self.itemSalePrice_tf.resignFirstResponder() }
            } else if itemPrice_tf.text! != "" && item_price < item_sale_price {
                itemSalePrice_tf.text = priceFormatter.string(from: item_price as NSNumber) ?? sender.text!
            }
        }
        
        UIView.setAnimationsEnabled(false); WhGoodsUploadVCdelegate.tableView.reloadSections(IndexSet(integer: 2), with: .none); UIView.setAnimationsEnabled(true)
    }
    
    @objc func end_textfield(_ sender: UITextField) {
        
        let item_price = Int(itemPrice_tf.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        let item_sale_price = Int(itemSalePrice_tf.text!.replacingOccurrences(of: ",", with: "")) ?? 0
        
        if (sender == itemPrice_tf) {
            
            if (100 > item_price) {
                itemPrice_tf.text = "100"
                DispatchQueue.main.async { self.itemPrice_tf.resignFirstResponder(); self.itemSalePrice_tf.resignFirstResponder() }
                WhGoodsUploadVCdelegate.customAlert(message: "가격(원가)을 정확히 입력해 주세요.\n(최소 단위: 100원)", time: 2) { self.itemPrice_tf.becomeFirstResponder() }
            } else if (WhGoodsUploadVCdelegate.item_sale && item_price <= item_sale_price) {
                noticeItemSalePrice_label.isHidden = false; noticeItemSalePrice_label.text = "할인가는 원가보다 크거나 같을 수 없습니다."
            } else if (WhGoodsUploadVCdelegate.item_sale && item_sale_price > 0 && Int(item_price/item_sale_price) > 10) {
                noticeItemSalePrice_label.isHidden = false; noticeItemSalePrice_label.text = "할인가는 원가의 10배를 넘을 수 없습니다."
            }
            
        } else if (sender == itemSalePrice_tf) { noticeItemSalePrice_label.isHidden = true
            
            if (100 > item_sale_price) {
                noticeItemSalePrice_label.isHidden = false; noticeItemSalePrice_label.text = "할인가를 정확히 입력해 주세요.(최소 단위: 100원)"
            } else if (item_price/item_sale_price > 10) {
                noticeItemSalePrice_label.isHidden = false; noticeItemSalePrice_label.text = "할인가는 원가의 10배를 넘을 수 없습니다."
            } else if (item_price <= item_sale_price) {
                noticeItemSalePrice_label.isHidden = false; noticeItemSalePrice_label.text = "할인가는 원가보다 크거나 같을 수 없습니다."
            }
        }
        
        WhGoodsUploadVCdelegate.tableView.reloadData()
    }
    
    @objc func select_btn(_ sender: UIButton) {
        
        WhGoodsUploadVCdelegate.view.endEditing(true); UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        let data = WhGoodsUploadVCdelegate.GoodsObject
        
        if sender.tag == 0 {
            
            WhGoodsUploadVCdelegate.item_sale = !WhGoodsUploadVCdelegate.item_sale
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
                WhGoodsUploadVCdelegate.option_price = !WhGoodsUploadVCdelegate.option_price
            }
        }
        
        WhGoodsUploadVCdelegate.tableView.reloadData()
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
            let cell = cell as! WhGoodsUploadCC
            
            cell.item_img.image = UIImage(data: data.file_data)
        } else if indexPath.section == 0, collectionView == contentCollectionView {
            
            let data = WhGoodsUploadVCdelegate.ContentsArray[indexPath.row]
            let cell = cell as! WhGoodsUploadCC
            
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
                cell.optionPrice_tf.tag = indexPath.row; cell.optionPrice_tf.addTarget(cell, action: #selector(cell.optionPrice_tf(_:)), for: .editingChanged)
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

//
//  WhGoodsDetailVC.swift
//  market
//
//  Created by 장 제현 on 12/8/23.
//

import UIKit
import ImageSlideshow
import BSImagePicker

class WhGoodsDetailCC: UICollectionViewCell {
    
    @IBOutlet weak var content_img: UIImageView!
    @IBOutlet weak var contentRow_label: UILabel!
    
    @IBOutlet weak var optionName_label: UILabel!
    @IBOutlet weak var optionPrice: UILabel!
}

class WhGoodsDetailVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var GoodsObject: GoodsData = GoodsData()
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
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
    
    @IBOutlet weak var itemContent_v: UIView!
    @IBOutlet weak var itemContentCollectionView: UICollectionView!
    @IBOutlet weak var itemContent_label: UILabel!
    @IBOutlet weak var itemCategory_label: UILabel!
    @IBOutlet weak var itemColor_label: UILabel!
    @IBOutlet weak var itemSize_label: UILabel!
    @IBOutlet weak var itemStyle_label: UILabel!
    @IBOutlet weak var itemMaterial_label: UILabel!
    @IBOutlet weak var itemWeaving_label: UILabel!
    @IBOutlet weak var itemCountry_label: UILabel!
    @IBOutlet weak var itemDateTime_label: UILabel!
    @IBOutlet weak var itemKey_label: UILabel!
    
    @IBOutlet weak var optionPriceCollectionView: UICollectionView!
    
    @IBOutlet var itemMaterialWasingInfo_labels: [UILabel]!
    
    @IBOutlet weak var edit_btn: UIButton!
    @IBOutlet weak var soldOut_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WhGoodsDetailVCdelegate = self
        
        scrollView.delegate = self
        
        ([itemContentCollectionView, optionPriceCollectionView] as [UICollectionView]).forEach { collectionView in
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            collectionView.setCollectionViewLayout(layout, animated: false)
            collectionView.delegate = self; collectionView.dataSource = self
        }
        
        let data = GoodsObject
        
        setImageSlideShew(imageView: item_img, imageUrls: data.item_photo_imgs, completionHandler: nil)
        item_img.delegate = self
        item_img.pageIndicator = .none
        item_img.slideshowInterval = 5
        item_img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(item_img(_:))))
        
        itemImgPage_view.isHidden = !(data.item_photo_imgs.count > 1)
        itemImgCount_label.text = "| \(data.item_photo_imgs.count)"
        itemName_label.text = data.item_name
        itemPrice_label.text = "₩\(priceFormatter.string(from: data.item_price as NSNumber) ?? "0")"
        itemSalePrice_label.text = "₩\(priceFormatter.string(from: data.item_sale_price as NSNumber) ?? "0")"
        let percent = ((Double(data.item_price)-Double(data.item_sale_price))/Double(data.item_price)*1000).rounded()/10
        itemSalePercent_label.isHidden = ((percent == 0) || !data.item_sale)
        itemSalePercent_label.text = "↓ \(percent)%"
        categoryName_label.layer.cornerRadius = 7.5
        categoryName_label.clipsToBounds = true
        categoryName_label.text = data.item_category_name.map { $0 }.joined(separator: " > ")
        categoryName_label_width.constant = stringWidth(text: categoryName_label.text!, fontSize: 12)+20
        itemTop_img.isHidden = !(data.item_top_check)
        
        itemContent_v.isHidden = (data.item_content_imgs.count == 0)
        itemContent_label.isHidden = (data.item_content == "")
        itemContent_label.text = data.item_content
        
        itemCategory_label.text = data.item_category_name.map { $0 }.joined(separator: " > ")
        itemColor_label.text = data.item_colors.map { $0 }.joined(separator: ", ")
        itemSize_label.text = data.item_sizes.map { $0 }.joined(separator: ", ")
        itemStyle_label.text = data.item_style
        itemMaterial_label.text = data.item_materials.map { $0 }.joined(separator: ", ")
        itemWeaving_label.text = data.item_build
        itemCountry_label.text = data.item_manufacture_country
        itemDateTime_label.text = setTimestampToDateTime(timestamp: Int(data.item_key) ?? 0, dateformat: "yyyy.MM.dd a hh:mm")
        itemKey_label.text = data.item_key
        
//        optionPriceCollectionView.delegate = nil; optionPriceCollectionView.dataSource = nil
        
        itemMaterialWasingInfo_labels.forEach { label in label.textColor = .black.withAlphaComponent(0.3) }
        data.item_material_washing.forEach { (key: String, value: Any) in
            
            guard let map = material_washing[key] else { return }
            let tags: [Int] = (key != "washing") ? [map[value as? String ?? ""]].compactMap { $0 } : (value as? [String] ?? []).compactMap { map[$0] }

            itemMaterialWasingInfo_labels.forEach { label in
                
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
        
        edit_btn.addTarget(self, action: #selector(edit_btn(_:)), for: .touchUpInside)
        soldOut_btn.addTarget(self, action: #selector(soldOut_btn(_:)), for: .touchUpInside)
        soldOut_btn.isHidden = true
    }
                                    
    @objc func item_img(_ sender: UITapGestureRecognizer) {
        
        guard let sender = sender.view as? ImageSlideshow else { return }
        let segue = storyboard?.instantiateViewController(withIdentifier: "ImageSlideVC") as! ImageSlideVC
        segue.inputs = sender.images
        segue.indexpath_row = sender.tag
        navigationController?.pushViewController(segue, animated: true, completion: nil)
    }
    
    @objc func edit_btn(_ sender: UIButton) {
        
        let data = GoodsObject
        let segue = storyboard?.instantiateViewController(withIdentifier: "WhGoodsUploadVC") as! WhGoodsUploadVC
        segue.GoodsObject = data
        segue.edit = true
        if data.item_category_name.count > 0 { segue.option_key = data.item_category_name[0] }
        segue.item_sale = data.item_sale
        data.item_colors.forEach { color in
            segue.ColorArray.append((option_name: color, option_color: ColorArray[color] ?? "ffffff"))
        }
        navigationController?.pushViewController(segue, animated: true, completion: nil)
    }
    
    @objc func soldOut_btn(_ sender: UIButton) {
        alert(title: "", message: "서비스 준비중 입니다...", style: .alert, time: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
        
        WhGoodsUploadVCdelegate = nil
    }
}

extension WhGoodsDetailVC: ImageSlideshowDelegate {
    
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        itemImgPage_label.text = "\(page+1)"
        item_img.tag = page
    }
}

extension WhGoodsDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == itemContentCollectionView, GoodsObject.item_content_imgs.count > 0 {
            return GoodsObject.item_content_imgs.count
        } else if collectionView == optionPriceCollectionView, GoodsObject.item_option.count > 0 {
            return GoodsObject.item_option.count
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? WhGoodsDetailCC else { return }
        
        if collectionView == itemContentCollectionView {
            setNuke(imageView: cell.content_img, imageUrl: GoodsObject.item_content_imgs[indexPath.row])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WhGoodsDetailCC", for: indexPath) as! WhGoodsDetailCC
        
        if collectionView == itemContentCollectionView {
            cell.contentRow_label.text = " "+String(format: "%02d", indexPath.row+1)
        } else if collectionView == optionPriceCollectionView {
            
            let data = GoodsObject.item_option[indexPath.row]
            
            cell.optionName_label.text = "\(data.color) / \(data.size)"
            cell.optionPrice.text = "₩\(priceFormatter.string(from: data.price as NSNumber) ?? "0")"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == itemContentCollectionView {
            return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
        } else if collectionView == optionPriceCollectionView {
            
            let data = GoodsObject.item_option[indexPath.row]
            let option_name: CGFloat = stringWidth(text: "\(data.color) / \(data.size)", fontSize: 14)
            let option_price: CGFloat = stringWidth(text: "₩\(priceFormatter.string(from: data.price as NSNumber) ?? "0")", fontSize: 14)
            
            if option_name > option_price {
                return CGSize(width: option_name+40, height: collectionView.frame.height)
            } else {
                return CGSize(width: option_price+40, height: collectionView.frame.height)
            }
        } else {
            return .zero
        }
    }
}

//
//  WhGoodsDetailVC.swift
//  market
//
//  Created by Busan Dynamic on 12/8/23.
//

import UIKit
import ImageSlideshow
import BSImagePicker

class WhGoodsDetailCC: UICollectionViewCell {
    
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
    
    @IBOutlet weak var itemContent_label: UILabel!
    @IBOutlet weak var itemCategory_label: UILabel!
    @IBOutlet weak var itemColor_label: UILabel!
    @IBOutlet weak var itemSize_label: UILabel!
    @IBOutlet weak var itemStyle_label: UILabel!
    @IBOutlet weak var itemMaterial_label: UILabel!
    @IBOutlet weak var itemKey_label: UILabel!
    
    @IBOutlet weak var optionPriceCollectionView: UICollectionView!
    
    @IBOutlet var itemMaterialWasingInfo_labels: [UILabel]!
    
    @IBOutlet weak var edit_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WhGoodsDetailVCdelegate = self
        
        scrollView.delegate = self
        
        let data = GoodsObject
        
        setImageSlideShew(imageView: item_img, imageUrls: data.item_photo_imgs)
        item_img.pageIndicator = .none
        item_img.slideshowInterval = 3
        item_img.delegate = self
        item_img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(item_img(_:))))
        
        itemImgPage_view.isHidden = !(data.item_photo_imgs.count > 1)
        itemImgCount_label.text = "| \(data.item_photo_imgs.count)"
        itemName_label.text = data.item_name
        itemPrice_label.text = "₩ \(priceFormatter.string(from: data.item_price as NSNumber) ?? "0")"
        itemSalePrice_label.text = "₩ \(priceFormatter.string(from: data.item_sale_price as NSNumber) ?? "0")"
        let percent = ((Double(data.item_price)-Double(data.item_sale_price))/Double(data.item_price)*1000).rounded()/10
        itemSalePercent_label.isHidden = ((percent == 0) || !data.item_sale)
        itemSalePercent_label.text = "↓ \(percent)%"
        categoryName_label.layer.cornerRadius = 7.5
        categoryName_label.clipsToBounds = true
        categoryName_label.text = "\(data.item_category_name)".replacingOccurrences(of: ", ", with: " > ").replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        categoryName_label_width.constant = stringWidth(text: categoryName_label.text!, fontSize: 12)+20
        itemTop_img.isHidden = !(data.item_top_check)
        
        itemContent_label.text = data.item_content
        
        itemCategory_label.text = "\(data.item_category_name)".replacingOccurrences(of: ", ", with: " > ").replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        itemColor_label.text = "\(data.item_colors)".replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        itemSize_label.text = "\(data.item_sizes)".replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        itemStyle_label.text = data.item_style
        itemMaterial_label.text = "\(data.item_materials)".replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        itemKey_label.text = data.item_key
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        optionPriceCollectionView.setCollectionViewLayout(layout, animated: true)
        optionPriceCollectionView.delegate = self; optionPriceCollectionView.dataSource = self
        
        edit_btn.addTarget(self, action: #selector(edit_btn(_:)), for: .touchUpInside)
    }
                                    
    @objc func item_img(_ sender: UITapGestureRecognizer) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ImageSlideVC") as! ImageSlideVC
        segue.imageUrls = GoodsObject.item_photo_imgs
        navigationController?.pushViewController(segue, animated: true)
    }
    
    @objc func edit_btn(_ sender: UIButton) {
        
        let data = GoodsObject
        let segue = storyboard?.instantiateViewController(withIdentifier: "WhGoodsUploadVC") as! WhGoodsUploadVC
        segue.GoodsObject = data
        segue.edit = true
        if data.item_category_name.count > 0 { segue.option_key = data.item_category_name[0] }
        data.item_colors.forEach { color in
            segue.ColorArray.append((option_name: color, option_color: ColorArray[color] ?? "ffffff"))
        }
        segue.item_sale = data.item_sale
        navigationController?.pushViewController(segue, animated: true)
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
    }
}

extension WhGoodsDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if GoodsObject.item_option.count > 0 { return GoodsObject.item_option.count } else { return .zero }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = GoodsObject.item_option[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WhGoodsDetailCC", for: indexPath) as! WhGoodsDetailCC
        
        cell.optionName_label.text = "\(data.color) / \(data.size)"
        cell.optionPrice.text = "₩ \(priceFormatter.string(from: data.price as NSNumber) ?? "0")"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let data = GoodsObject.item_option[indexPath.row]
        let option_name: CGFloat = stringWidth(text: "\(data.color) / \(data.size)", fontSize: 14)
        let option_price: CGFloat = stringWidth(text: "₩ \(priceFormatter.string(from: data.price as NSNumber) ?? "0")", fontSize: 14)
        
        if option_name > option_price {
            return CGSize(width: option_name+40, height: collectionView.frame.height)
        } else {
            return CGSize(width: option_price+40, height: collectionView.frame.height)
        }
    }
}

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
    var ColorArray: [(option_name: String, option_color: String)] = []
    var SizeArray: [(option_name: String, option_select: Bool)] = []
    var MaterialArray: [(option_name: String, option_percent: String)] = []
    var item_sale: Bool = false
    
    var OptionPriceArray: [(color_name: String, size_price: [(size: String, price: Int)])] = []
    var option_price: Bool = false
    
    var WashingArray: [String] = []
    var StyleArray: [String] = []
    var style_row: Int? = nil
    var ContentsArray: [(file_name: String, file_data: Data, file_size: Int)] = []
    
    var collectionViewContentOffsets: [Int: CGFloat] = [:]
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    
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
                    SizeArray.filter { $0.option_select }.forEach { size_price.append((size: $0.option_name, price: GoodsObject.item_sale_price)) }
                    return (color_name: data.option_name, size_price: size_price)
                }
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
        
        let cell = cell as! WhGoodsUploadTC
        
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
            cell.noticeItemSalePrice_label.isHidden = true
            cell.sale_btn.isSelected = item_sale
            cell.sale_btn.tag = 0; cell.sale_btn.addTarget(cell, action: #selector(cell.select_btn(_:)), for: .touchUpInside)
            
            if option_price {
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
            cell.content_btn.addTarget(self, action: #selector(content_btn(_:)), for: .touchUpInside)
            cell.content_view.isHidden = (ContentsArray.count == 0)
            
            cell.materialCollectionView.isHidden = (MaterialArray.count == 0)
            cell.materialCollectionView.contentOffset.x = max(cell.materialCollectionView.contentSize.width - cell.materialCollectionView.bounds.width, 0)
            cell.material_btn.tag = 2; cell.material_btn.addTarget(cell, action: #selector(cell.category_btn(_:)), for: .touchUpInside)
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func content_btn(_ sender: UIButton) {
        
        view.endEditing(true)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        if 10-ContentsArray.count == 0 {
            
            let alert = UIAlertController(title: "", message: "이미지는 최대 10장까지\n등록할 수 있습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            
            setPhoto(max: 10-ContentsArray.count) { photos in
                photos.forEach { photo in
                    self.ContentsArray.append(photo)
                    UIView.setAnimationsEnabled(false)
                    self.tableView.reloadSections(IndexSet(integer: 3), with: .none)
                    UIView.setAnimationsEnabled(true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2, !option_price { return .zero } else { return UITableView.automaticDimension }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        view.endEditing(true)
    }
}

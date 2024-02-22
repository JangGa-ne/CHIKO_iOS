//
//  CategoryVC.swift
//  market
//
//  Created by Busan Dynamic on 11/9/23.
//

import UIKit
import PanModal

class CategoryCC: UICollectionViewCell {
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var lineView: UIView!
}

class CategoryTC: UITableViewCell {
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var color_view: UIView!
}

class CategoryVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    /// 소매자
    var ReGoodsVCdelegate: ReGoodsVC? = nil
    var ReReceiptUploadVCdelegate: ReReceiptUploadVC? = nil
    var ReReceiptUploadTCdelegate: ReReceiptUploadTC? = nil
    /// 도매자
    var WhGoodsUploadVCdelegate: WhGoodsUploadVC? = nil
    
    var option_type: String = ""
    var option_key: String = ""
    var option_row: Int = 0
    
    var option_title: [String] = []
    var indexpath_section: Int = 0
    var option_content: [(option1: [String], option2: [String])] = []
    var indexpath_row: Int = 0
    
    var women_clothes: [(option1: String, option2: [String])] = []
    var isSectionExpanded: Array = Array<Bool>()
    
    @IBOutlet weak var mainTitle_label: UILabel!
    @IBOutlet weak var subTitle_label: UILabel!
    @IBAction func back_btn(_ sender: UIButton) { dismiss(animated: true, completion: nil) }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setKeyboard()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal; layout.minimumLineSpacing = 0; layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.setCollectionViewLayout(layout, animated: true, completion: nil)
        collectionView.delegate = self; collectionView.dataSource = self
        
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = 0 }
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        
        loadingData()
    }
     
    func loadingData() {
        
        if option_type == "category" {
            
            mainTitle_label.text = "카테고리"
        
            var first: Bool = false
            CategoryObject.CategoryArray.forEach { document in
                var document_key: String = ""
                document.forEach { (key: String, value: Any) in document_key = key; option_title.append(key)
                    (value as? [String: [String]] ?? [:]).sorted(by: { $0.key < $1.key }).forEach { (key: String, value: [String]) in
                        if (document_key == "여성의류") {
                            women_clothes.append((option1: key, option2: value))
                            if !first { first = true; option_content.append((option1: [], option2: [])) }
                        } else {
                            option_content.append((option1: value, option2: []))
                        }
                    }
                }
            }
            
            isSectionExpanded = Array(repeating: false, count: women_clothes.count)
            
        } else if option_type == "color" {
            
            mainTitle_label.text = "색상"
            
            CategoryObject.ColorArray.forEach { document in
                document.forEach { (key: String, value: Any) in option_title.append(key)
                    (value as? [String: [String: String]] ?? [:]).forEach { (key: String, value: [String: String]) in
                        var title: [String] = []
                        var color: [String] = []
                        value.forEach { (key: String, value: String) in title.append(key); color.append(value) }
                        option_content.append((option1: title, option2: color))
                    }
                }
            }
            
            let sortedOptions = option_content.map { zip($0.option1, $0.option2).sorted { $0.1 < $1.1 } }
            let sortedOption1 = sortedOptions.map { $0.map { $0.0 } }
            let sortedOption2 = sortedOptions.map { $0.map { $0.1 } }
            option_content = zip(sortedOption1, sortedOption2).map { (option1: $0, option2: $1) }
            
        } else if option_type == "material", let delegate = WhGoodsUploadVCdelegate { 
            
            mainTitle_label.text = "주요소재"
            
            if delegate.option_key.contains("의류") { indexpath_section = 0 } else { indexpath_section = 1 }
            
            CategoryObject.MaterialArray.forEach { document in
                document.forEach { (key: String, value: Any) in option_title.append(key)
                    (value as? [String: [String]] ?? [:]).forEach { (key: String, value: [String]) in
                        option_content.append((option1: value, option2: []))
                    }
                }
            }
        } else if option_type == "size" {
            
            mainTitle_label.text = "사이즈"
            
            option_title.append(option_key)
            CategoryObject.SizeArray.forEach { document in
                (document[option_key] as? [String: [String]] ?? [:]).forEach { (key: String, value: [String]) in
                    option_content.append((option1: value, option2: []))
                }
            }
        }
        
        collectionView.reloadData()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

extension CategoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if option_title.count > 0 { return option_title.count } else { return 0 }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCC", for: indexPath) as! CategoryCC
        
        cell.title_label.text = option_title[indexPath.row]
        cell.lineView.isHidden = (indexPath.row != indexpath_section)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: stringWidth(text: option_title[indexPath.row], fontSize: 14.5, fontWeight: .bold), height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        option_key = option_title[indexPath.row]
        indexpath_section = indexPath.row
        
        collectionView.reloadData()
        tableView.reloadData()
        
        panModalSetNeedsLayoutUpdate()
    }
}

extension CategoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if option_key != "여성의류", option_content.count > 0 {
            return 1
        } else if women_clothes.count > 0 {
            return women_clothes.count
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTC0") as! CategoryTC
        
        cell.tag = section; cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleSection(_:))))
        cell.title_label.text = women_clothes[section].option1
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if option_key != "여성의류" { return .zero } else { return 44 }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if option_key != "여성의류", option_content[indexpath_section].option1.count > 0 {
            return option_content[indexpath_section].option1.count
        } else {
            return isSectionExpanded[section] ? women_clothes[section].option2.count : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTC1", for: indexPath) as! CategoryTC
        
        if option_key != "여성의류" {
            cell.title_label.text = option_content[indexpath_section].option1[indexPath.row]
            cell.color_view.isHidden = (option_type != "color")
            if option_type == "color" { cell.color_view.backgroundColor = UIColor(hex: "#"+option_content[indexpath_section].option2[indexPath.row]) }
        } else {
            cell.title_label.text = "\(indexPath.row+1). \(women_clothes[indexPath.section].option2[indexPath.row])"
            cell.color_view.isHidden = true
        }
        return cell
    }
    
    @objc func toggleSection(_ sender: UITapGestureRecognizer) {
        
        guard let section = sender.view?.tag else { return }
        
        isSectionExpanded[section] = !isSectionExpanded[section]
        tableView.reloadData()
        
        panModalSetNeedsLayoutUpdate()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        /// 소매자(카테고리)
        if let delegate = ReGoodsVCdelegate {
            
            if option_key != "여성의류" {
                
                let optionMain_name = option_title[indexpath_section]
                let optionSub_name = option_content[indexpath_section].option1[indexPath.row]
                
                delegate.item_category_name = [optionMain_name, optionSub_name]
                delegate.categoryName_label.text = "\(optionMain_name) > \(optionSub_name)"
            } else {
                
                let optionMain_name = women_clothes[indexPath.section].option1
                let optionSub_name = women_clothes[indexPath.section].option2[indexPath.row]
                
                delegate.item_category_name = ["여성의류", optionMain_name, optionSub_name]
                delegate.categoryName_label.text = "여성의류 > \(optionMain_name) > \(optionSub_name)"
            }
            
            delegate.categoryAll_label.isHidden = true
            delegate.categoryName_view.isHidden = false
            delegate.categoryName_label_width.constant = stringWidth(text: delegate.categoryName_label.text!, fontSize: 12)+20
            
            dismiss(animated: true) { delegate.loadingData(first: true) }
        }
        /// 소매자(영수증 주문요청)
        if let VCdelegate = ReReceiptUploadVCdelegate, let TCdelegate = ReReceiptUploadTCdelegate {
            
            if option_type == "category", option_key != "" {
                
                dispatchGroup.enter()
                customAlert(message: "카테고리 변경으로 일부 옵션 설정값이 초기화 됩니다.", time: 1) {
                    /// 데이터 삭제
                    VCdelegate.ReEnquiryReceiptObject.order_item[TCdelegate.indexpath_row].item_option.indices.forEach { i in
                        VCdelegate.ReEnquiryReceiptObject.order_item[TCdelegate.indexpath_row].item_option[i].size.removeAll()
                    }
                    
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                
                if self.option_type == "category", self.option_key != "여성의류" {
                        
                    let optionMain_name = self.option_title[self.indexpath_section]
                    let optionSub_name = self.option_content[self.indexpath_section].option1[indexPath.row]
                    
                    VCdelegate.ReEnquiryReceiptObject.order_item[TCdelegate.indexpath_row].item_category_name = [optionMain_name, optionSub_name]
                    VCdelegate.tableView.reloadData()
                } else if self.option_type == "category", self.option_key == "여성의류" {
                        
                    let optionMain_name = self.women_clothes[indexPath.section].option1
                    let optionSub_name = self.women_clothes[indexPath.section].option2[indexPath.row]
                    
                    VCdelegate.ReEnquiryReceiptObject.order_item[TCdelegate.indexpath_row].item_category_name = ["여성의류", optionMain_name, optionSub_name]
                    VCdelegate.tableView.reloadData()
                } else if self.option_type == "color" {
                    VCdelegate.ReEnquiryReceiptObject.order_item[TCdelegate.indexpath_row].item_option[self.option_row].color = self.option_content[self.indexpath_section].option1[indexPath.row]
                } else if self.option_type == "size" {
                    VCdelegate.ReEnquiryReceiptObject.order_item[TCdelegate.indexpath_row].item_option[self.option_row].size = self.option_content[self.indexpath_section].option1[indexPath.row]
                }
                
                self.dismiss(animated: true) { TCdelegate.optionTableView.reloadData() }
            }
        }
        /// 도매자(상품등록)
        if let delegate = WhGoodsUploadVCdelegate {
            
            if option_key != "여성의류" {
                
                let optionMain_name = option_title[indexpath_section]
                let optionSub_name = option_content[indexpath_section].option1[indexPath.row]
                
                if option_type == "category" {
                    
                    if delegate.GoodsObject.item_category_name.count == 0 {
                        
                        delegate.option_key = optionMain_name
                        delegate.GoodsObject.item_category_name = [optionMain_name, optionSub_name]
                        
                        delegate.loadingData(all: true); dismiss(animated: true) { delegate.tableView.reloadData() }; return
                    } else {
                        
                        delegate.option_key = optionMain_name
                        delegate.GoodsObject.item_category_name = [optionMain_name, optionSub_name]
                    }
                    
                } else if option_type == "color" {
                    
                    if delegate.GoodsObject.item_colors.contains(optionSub_name) { customAlert(message: "이미 선택한 색상입니다.", time: 1); return }
                    
                    delegate.ColorArray.append((option_name: optionSub_name, option_color: option_content[indexpath_section].option2[indexPath.row]))
                    delegate.GoodsObject.item_colors.append(optionSub_name)
                    
                    delegate.loadingData(index: 1); dismiss(animated: true) { delegate.tableView.reloadData() }; return
                    
                } else if option_type == "material" {
                    
                    if delegate.GoodsObject.item_materials.contains(optionSub_name) { customAlert(message: "이미 선택한 소재입니다.", time: 1); return }
                    
                    let alert = UIAlertController(title: "", message: "\(optionMain_name) > \(optionSub_name)\n혼용률을 입력해 주세요.", preferredStyle: .alert)
                    alert.addTextField()
                    let sheet_tf = alert.textFields?[0] ?? UITextField()
                    sheet_tf.keyboardType = .numberPad
                    sheet_tf.placeholder(text: "미입력시 퍼센트(%)가 표기 되지 않습니다.", color: .lightGray)
                    sheet_tf.addTarget(self, action: #selector(textfield(_:)), for: .editingChanged)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                        if alert.textFields?[0].text ?? "" == "" {
                            delegate.MaterialArray.append((option_name: optionSub_name, option_percent: ""))
                            delegate.GoodsObject.item_materials.append(optionSub_name)
                        } else {
                            delegate.MaterialArray.append((option_name: optionSub_name, option_percent: "\(alert.textFields?[0].text ?? "0")%"))
                            delegate.GoodsObject.item_materials.append("\(optionSub_name) \(alert.textFields?[0].text ?? "0")%")
                        }
                        self.dismiss(animated: true) { delegate.tableView.reloadData() }
                    }))
                    alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                    present(alert, animated: true, completion: nil); return
                }
                
            } else {
                
                let optionMain_name = women_clothes[indexPath.section].option1
                let optionSub_name = women_clothes[indexPath.section].option2[indexPath.row]
                
                if option_type == "category" {
                    
                    if delegate.GoodsObject.item_category_name.count == 0 {
                        
                        delegate.option_key = option_title[indexpath_section]
                        delegate.GoodsObject.item_category_name = ["여성의류", optionMain_name, optionSub_name]
                        
                        delegate.loadingData(all: true); dismiss(animated: true) { delegate.tableView.reloadData() }; return
                    } else {
                        delegate.option_key = option_title[indexpath_section]
                        delegate.GoodsObject.item_category_name = ["여성의류", optionMain_name, optionSub_name]
                    }
                }
            }
            
            customAlert(message: "카테고리 변경으로 일부 옵션 설정값이 초기화 됩니다.", time: 1) {
                /// 데이터 삭제
                delegate.item_option_type = false
                delegate.style_row = nil
                delegate.ColorArray.removeAll()
                delegate.SizeArray.removeAll()
                delegate.MaterialArray.removeAll()
                delegate.OptionPriceArray.removeAll()
                delegate.StyleArray.removeAll()
                delegate.MaterialInfoArray.removeAll()
                delegate.WashingInfoArray.removeAll()
                delegate.GoodsObject.item_colors.removeAll()
                delegate.GoodsObject.item_sizes.removeAll()
                delegate.GoodsObject.item_materials.removeAll()
                delegate.GoodsObject.item_option.removeAll()
                delegate.GoodsObject.item_style.removeAll()
                delegate.GoodsObject.item_material_washing.removeAll()
                
                delegate.loadingData(all: true); self.dismiss(animated: true) { delegate.tableView.reloadData() }
            }
        }
    }
    
    @objc func textfield(_ sender: UITextField) {
        if (Int(sender.text!) ?? 0 > 100) { sender.text = "100" }
    }
}

extension CategoryVC: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var dragIndicatorBackgroundColor: UIColor {
        return .clear
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(UIScreen.main.bounds.height/1.5)
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeight
    }
}

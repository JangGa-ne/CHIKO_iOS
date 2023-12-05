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
    
    var ReGoodsVCdelegate: ReGoodsVC? = nil
    var WhGoodsUploadVCdelegate: WhGoodsUploadVC? = nil
    
    var option_type: String = ""
    var option_key: String = ""
    
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
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
            
            mainTitle_label.text = "주요 소재"
            
            if delegate.option_key.contains("의류") { indexpath_section = 0 } else { indexpath_section = 1 }
            
            CategoryObject.MaterialArray.forEach { document in
                document.forEach { (key: String, value: Any) in option_title.append(key)
                    (value as? [String: [String]] ?? [:]).forEach { (key: String, value: [String]) in
                        option_content.append((option1: value, option2: []))
                    }
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
                
                delegate.category = [optionMain_name, optionSub_name]
                delegate.categoryName_label.text = "\(optionMain_name) > \(optionSub_name)"
            } else {
                
                let optionMain_name = women_clothes[indexPath.section].option1
                let optionSub_name = women_clothes[indexPath.section].option2[indexPath.row]
                
                delegate.category = ["여성의류", optionMain_name, optionSub_name]
                delegate.categoryName_label.text = "여성의류 > \(optionMain_name) > \(optionSub_name)"
            }
            
            delegate.categoryName_label_width.constant = stringWidth(text: delegate.categoryName_label.text!, fontSize: 12)+20
            
            dismiss(animated: true, completion: nil)
        }
        /// 도매자(상품등록)
        if let VCdelegate = WhGoodsUploadVCdelegate {
            
            let data = VCdelegate.GoodsObject
            
            if option_key != "여성의류" {
                
                let optionMain_name = option_title[indexpath_section]
                let optionSub_name = option_content[indexpath_section].option1[indexPath.row]
                
                if option_type == "category" {
                    
                    if data.item_category_name.count == 0 {
                        
                        VCdelegate.option_key = optionMain_name
                        data.item_category_name = [optionMain_name, optionSub_name]
                        
                        VCdelegate.loadingData(all: true); dismiss(animated: true) { VCdelegate.tableView.reloadData() }; return
                    } else {
                        
                        VCdelegate.option_key = optionMain_name
                        data.item_category_name = [optionMain_name, optionSub_name]
                    }
                    
                } else if option_type == "color" {
                    
                    if data.item_colors.contains(optionSub_name) { customAlert(message: "이미 선택한 색상입니다.", time: 1); return }
                    
                    VCdelegate.ColorArray.append((option_name: optionSub_name, option_color: option_content[indexpath_section].option2[indexPath.row]))
                    data.item_colors.append(optionSub_name)
                    
                    VCdelegate.loadingData(index: 1); dismiss(animated: true) { VCdelegate.tableView.reloadData() }; return
                    
                } else if option_type == "material" {
                    
                    if data.item_materials.contains(optionSub_name) { customAlert(message: "이미 선택한 소재입니다.", time: 1); return }
                    
                    let alert = UIAlertController(title: "", message: "\(optionMain_name) > \(optionSub_name)\n혼용률을 입력해 주세요.", preferredStyle: .alert)
                    alert.addTextField()
                    let sheet_tf = alert.textFields?[0] ?? UITextField()
                    sheet_tf.keyboardType = .numberPad
                    sheet_tf.placeholder(text: "미입력시 퍼센트(%)가 표기 되지 않습니다.", color: .lightGray)
                    sheet_tf.addTarget(self, action: #selector(textfield(_:)), for: .editingChanged)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                        if alert.textFields?[0].text ?? "" == "" {
                            VCdelegate.MaterialArray.append((option_name: optionSub_name, option_percent: ""))
                            data.item_materials.append(optionSub_name)
                        } else {
                            VCdelegate.MaterialArray.append((option_name: optionSub_name, option_percent: "\(alert.textFields?[0].text ?? "0")%"))
                            data.item_materials.append("\(optionSub_name) \(alert.textFields?[0].text ?? "0")%")
                        }
                        self.dismiss(animated: true) { VCdelegate.tableView.reloadData() }
                    }))
                    alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                    present(alert, animated: true, completion: nil); return
                }
                
            } else {
                
                let optionMain_name = women_clothes[indexPath.section].option1
                let optionSub_name = women_clothes[indexPath.section].option2[indexPath.row]
                
                if option_type == "category" {
                    
                    if data.item_category_name.count == 0 {
                        
                        VCdelegate.option_key = option_title[indexpath_section]
                        data.item_category_name = ["여성의류", optionMain_name, optionSub_name]
                        
                        VCdelegate.loadingData(all: true); dismiss(animated: true) { VCdelegate.tableView.reloadData() }; return
                    } else {
                        VCdelegate.option_key = option_title[indexpath_section]
                        data.item_category_name = ["여성의류", optionMain_name, optionSub_name]
                    }
                }
            }
            
            customAlert(message: "카테고리 변경으로 일부 옵션 설정값이 초기화 됩니다.", time: 1) {
                /// 데이터 삭제
                VCdelegate.option_price = false
                VCdelegate.style_row = nil
                VCdelegate.ColorArray.removeAll()
                VCdelegate.SizeArray.removeAll()
                VCdelegate.MaterialArray.removeAll()
                VCdelegate.OptionPriceArray.removeAll()
                VCdelegate.StyleArray.removeAll()
                VCdelegate.MaterialInfoArray.removeAll()
                VCdelegate.WashingInfoArray.removeAll()
                data.item_colors.removeAll()
                data.item_sizes.removeAll()
                data.item_materials.removeAll()
                data.item_option.removeAll()
                data.item_style.removeAll()
                data.item_material_washing.removeAll()
                
                VCdelegate.loadingData(all: true); self.dismiss(animated: true) { VCdelegate.tableView.reloadData() }
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
        return .contentHeight(320)
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeight
    }
}

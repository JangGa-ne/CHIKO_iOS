//
//  ReGoodsVC.swift
//  market
//
//  Created by Busan Dynamic on 11/8/23.
//

import UIKit
import Nuke
import PanModal

class ReGoodsVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var category: [String] = []
    var GoodsArray: [GoodsData] = []
    
    @IBOutlet weak var storeMain_img: UIImageView!
    @IBOutlet weak var choiceStore_btn: UIButton!
    
    @IBOutlet weak var choiceCategory_btn: UIButton!
    @IBOutlet weak var categoryName_label: UILabel!
    @IBOutlet weak var categoryFilter_view: UIView!
    @IBOutlet weak var categoryName_label_width: NSLayoutConstraint!
    @IBOutlet weak var search_tf: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReGoodsVCdelegate = self
        
        setKeyboard()
        
        setNuke(imageView: storeMain_img, imageUrl: StoreArray[store_index].store_mainphoto_img, cornerRadius: 15)
        choiceStore_btn.addTarget(self, action: #selector(choiceStore_btn(_:)), for: .touchUpInside)
        
        choiceCategory_btn.addTarget(self, action: #selector(choiceCategory_btn(_:)), for: .touchUpInside)
        categoryName_label.layer.cornerRadius = 7.5
        categoryName_label.clipsToBounds = true
        categoryName_label_width.constant = stringWidth(text: categoryName_label.text!, fontSize: 12)+20
        categoryFilter_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(categoryFilter_view(_:))))
        search_tf.placeholder(text: "상품명을 입력하세요.", color: .lightGray)
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 22, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        
        loadingData(first: true)
    }
    
    @objc func choiceStore_btn(_ sender: UIButton) {
        segueViewController(identifier: "ChoiceStoreVC")
    }
    
    @objc func choiceCategory_btn(_ sender: UIButton) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "CategoryVC") as! CategoryVC
        segue.ReGoodsVCdelegate = self
        segue.option_type = "category"
        presentPanModal(segue)
    }
    
    @objc func categoryFilter_view(_ sender: UITapGestureRecognizer) {
        
    }
    
    func loadingData(first: Bool = false, startAt: String = "") {
        /// 데이터 삭제
        if first { GoodsArray.removeAll(); tableView.reloadData() }
        
        customLoadingIndicator(animated: true)
        /// ReGoods 요청
        requestReGoods(category: category, startAt: startAt, limit: 10) { ResData, status in
            
            self.customLoadingIndicator(animated: false)
            
            if status == 200 {
                self.GoodsArray += ResData
                preheatImages(urls: self.GoodsArray.compactMap { URL(string: $0.item_mainphoto_img) })
            } else if first, status == 204 {
                self.customAlert(message: "No Data", time: 1)
            } else if first, status == 600 {
                self.customAlert(message: "Error occurred during data conversion", time: 1)
            } else if first, status != 200 {
                self.customAlert(message: "Internal Server Error", time: 1)
            }; self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
        
        ChoiceStoreVCdelegate = nil
        ReGoodsDetailVCdelegate = nil
    }
}

extension ReGoodsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if GoodsArray.count > 0 { return GoodsArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let data = GoodsArray[indexPath.row]
        guard let cell = cell as? ReGoodsTC else { return }
        
        setNuke(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 10)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = GoodsArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReGoodsTC", for: indexPath) as! ReGoodsTC
        
        cell.storeName_btn.setTitle(data.store_name, for: .normal)
        cell.storeName_btn.tag = indexPath.row; cell.storeName_btn.addTarget(self, action: #selector(store_btn(_:)), for: .touchUpInside)
        cell.itemName_label.text = data.item_name
        cell.itemPrice_label.text = "\(priceFormatter.string(from: data.item_price as NSNumber) ?? "0")원"
        cell.itemSalePrice_label.text = "\(priceFormatter.string(from: data.item_sale_price as NSNumber) ?? "0")원"
        let percent = ((Double(data.item_price)-Double(data.item_sale_price))/Double(data.item_price)*1000).rounded()/10
        cell.itemSalePercent_label.isHidden = ((percent == 0) || !data.item_sale)
        cell.itemSalePercent_label.text = "↓ \(percent)%"
        
        if (indexPath.row == GoodsArray.count-1) && !data.load {
            data.load = true
            if data.item_pullup_time != "0" {
                loadingData(startAt: data.item_pullup_time)
            } else {
                loadingData(startAt: data.item_key)
            }
        }
        
        return cell
    }
    
    @objc func store_btn(_ sender: UIButton) {
        
        let data = GoodsArray[sender.tag]
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReStoreVisitVC") as! ReStoreVisitVC
        segue.store_id = data.store_id
        navigationController?.pushViewController(segue, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReGoodsDetailVC") as! ReGoodsDetailVC
        segue.GoodsObject = GoodsArray[indexPath.row]
        navigationController?.pushViewController(segue, animated: true)
    }
}

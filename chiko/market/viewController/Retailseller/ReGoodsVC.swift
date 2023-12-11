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
    
    var item_category_name: [String] = []
    
    var GoodsArray: [GoodsData] = []
    var fetchingMore: Bool = false
    var startIndex: Int = 0
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    @IBOutlet weak var storeMain_img: UIImageView!
    @IBOutlet weak var choiceStore_btn: UIButton!
    
    @IBOutlet weak var choiceCategory_btn: UIButton!
    @IBOutlet weak var categoryAll_label: UILabel!
    @IBOutlet weak var categoryName_view: UIView!
    @IBOutlet weak var categoryName_label: UILabel!
    @IBOutlet weak var categoryFilter_view: UIView!
    @IBOutlet weak var categoryName_label_width: NSLayoutConstraint!
    @IBOutlet weak var search_tf: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReGoodsVCdelegate = self
        
        setKeyboard()
        
//        setNuke(imageView: storeMain_img, imageUrl: StoreObject.store_mainphoto_img, cornerRadius: 15)
//        choiceStore_btn.addTarget(self, action: #selector(choiceStore_btn(_:)), for: .touchUpInside)
        
        choiceCategory_btn.addTarget(self, action: #selector(choiceCategory_btn(_:)), for: .touchUpInside)
        categoryAll_label.layer.cornerRadius = 7.5
        categoryAll_label.clipsToBounds = true
        categoryAll_label.isHidden = false
        categoryName_view.isHidden = true
        categoryName_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(categoryName_view(_:))))
        categoryName_label_width.constant = stringWidth(text: categoryName_label.text!, fontSize: 12)+20
        categoryFilter_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(categoryFilter_view(_:))))
        search_tf.placeholder(text: "상품명을 입력하세요.", color: .lightGray)
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 22, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .lightGray
        refreshControl.addTarget(self, action: #selector(refreshControl(_:)), for: .valueChanged)
        
        loadingData(first: true)
    }
    
    @objc func choiceStore_btn(_ sender: UIButton) {
        segueViewController(identifier: "ChoiceStoreVC")
    }
    
    @objc func choiceCategory_btn(_ sender: UIButton) {
        
        view.endEditing(true)
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "CategoryVC") as! CategoryVC
        segue.ReGoodsVCdelegate = self
        segue.option_type = "category"
        presentPanModal(segue)
    }
    
    @objc func categoryName_view(_ semder: UITapGestureRecognizer) {
        
        view.endEditing(true)
        
        item_category_name.removeAll()
        
        categoryAll_label.isHidden = false
        categoryName_view.isHidden = true
        
        loadingData(first: true)
    }
    
    @objc func categoryFilter_view(_ sender: UITapGestureRecognizer) {
        
    }
    
    @objc func refreshControl(_ sender: UIRefreshControl) {
        loadingData(first: true); refreshControl.endRefreshing()
    }
    
    func loadingData(first: Bool = false, startAt: String = "") {
        /// 데이터 삭제
        if first { GoodsArray.removeAll(); self.tableView.reloadData() }
        /// ReGoods 요청
        requestReGoods(category: item_category_name, startAt: startAt, limit: 10) { array, status in
            
            self.GoodsArray += array
            preheatImages(urls: self.GoodsArray.compactMap { URL(string: $0.item_mainphoto_img) })
            self.fetchingMore = false; self.tableView.reloadData()
            
            guard first else { return }
            
            if status == 204 {
                self.customAlert(message: "No Data", time: 1)
            } else if status == 600 {
                self.customAlert(message: "Error occurred during data conversion", time: 1)
            } else if status != 200 {
                self.customAlert(message: "Internal server error", time: 1)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
        
        ChoiceStoreVCdelegate = nil
        ReGoodsDetailVCdelegate = nil
    }
}

extension ReGoodsVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffsetY: CGFloat = scrollView.contentOffset.y
        let contentHeight: CGFloat = scrollView.contentSize.height
        let frameHeight: CGFloat = scrollView.frame.height
        
        if contentOffsetY > contentHeight-frameHeight && contentOffsetY > 0 && !fetchingMore {
            fetchingMore = true; tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.loadingData(startAt: self.GoodsArray[self.GoodsArray.count-1].item_pullup_time)
            }
        }
    }
}

extension ReGoodsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0, GoodsArray.count > 0 {
            return GoodsArray.count
        } else if section == 1, fetchingMore {
            return 1
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let data = GoodsArray[indexPath.row]
        guard let cell = cell as? ReGoodsTC else { return }
        
        setNuke(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 10)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let data = GoodsArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReGoodsTC", for: indexPath) as! ReGoodsTC
            
            cell.storeName_btn.setTitle(data.store_name, for: .normal)
            cell.storeName_btn.tag = indexPath.row; cell.storeName_btn.addTarget(self, action: #selector(store_btn(_:)), for: .touchUpInside)
            cell.itemName_label.text = data.item_name
            cell.itemPrice_label.text = "₩ \(priceFormatter.string(from: data.item_price as NSNumber) ?? "0")"
            cell.itemSalePrice_label.text = "₩ \(priceFormatter.string(from: data.item_sale_price as NSNumber) ?? "0")"
            let percent = ((Double(data.item_price)-Double(data.item_sale_price))/Double(data.item_price)*1000).rounded()/10
            cell.itemSalePercent_label.isHidden = ((percent == 0) || !data.item_sale)
            cell.itemSalePercent_label.text = "↓ \(percent)%"
            
//            if (indexPath.row == GoodsArray.count-1) && !data.load {
//                data.load = true
//                if data.item_pullup_time != "0" {
//                    loadingData(startAt: data.item_pullup_time)
//                } else {
//                    loadingData(startAt: data.item_key)
//                }
//            }
            
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FetchingMoreTC", for: indexPath) as! FetchingMoreTC
            
            cell.fetchingMore_indicatorView.color = .lightGray
            cell.fetchingMore_indicatorView.startAnimating()
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func store_btn(_ sender: UIButton) {
        
        let data = GoodsArray[sender.tag]
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReStoreVisitVC") as! ReStoreVisitVC
        segue.store_id = data.store_id
        navigationController?.pushViewController(segue, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        view.endEditing(true)
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReGoodsDetailVC") as! ReGoodsDetailVC
        segue.GoodsObject = GoodsArray[indexPath.row]
        navigationController?.pushViewController(segue, animated: true)
    }
}

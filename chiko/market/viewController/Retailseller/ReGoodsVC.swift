//
//  ReGoodsVC.swift
//  market
//
//  Created by Busan Dynamic on 11/8/23.
//

import UIKit
import SideMenu
import Nuke
import PanModal

class ReGoodsVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var detail: Bool = false
    var store_id: String = ""
    var disclosure: String = ""
    
    var isMenuOpen: Bool = false
    
    var item_category_name: [String] = []
    var search: String = ""
    
    var GoodsArray: [GoodsData] = []
    var fetchingMore: Bool = false
    var startIndexChange: Bool = false
    var startIndex: Int = 0
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    @IBOutlet weak var back_v: UIView!
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    @IBOutlet weak var title_img: UIImageView!
    @IBOutlet weak var title_label: UILabel!
    
    @IBOutlet weak var storeMain_img: UIImageView!
    @IBOutlet weak var choiceStore_btn: UIButton!
    
    @IBOutlet weak var choiceCategory_btn: UIButton!
    @IBOutlet weak var categoryAll_label: UILabel!
    @IBOutlet weak var categoryName_view: UIView!
    @IBOutlet weak var categoryName_label: UILabel!
    @IBOutlet weak var categoryFilter_view: UIView!
    @IBOutlet weak var categoryName_label_width: NSLayoutConstraint!
    @IBOutlet weak var search_tf: UITextField!
    @IBOutlet weak var delete_img: UIImageView!
    @IBOutlet weak var delete_btn: UIButton!
    @IBOutlet weak var search_btn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReGoodsVCdelegate = self
        
        setKeyboard()
        
        back_v.isHidden = !detail
        title_img.isHidden = detail
        
//        setKingfisher(imageView: storeMain_img, imageUrl: StoreObject.store_mainphoto_img, cornerRadius: 15)
//        choiceStore_btn.addTarget(self, action: #selector(choiceStore_btn(_:)), for: .touchUpInside)
        
        choiceCategory_btn.addTarget(self, action: #selector(choiceCategory_btn(_:)), for: .touchUpInside)
        categoryAll_label.layer.cornerRadius = 7.5
        categoryAll_label.clipsToBounds = true
        categoryAll_label.isHidden = false
        categoryName_view.isHidden = true
        categoryName_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(categoryName_view(_:))))
        categoryName_label_width.constant = stringWidth(text: categoryName_label.text!, fontSize: 12)+20
        categoryFilter_view.isHidden = true
        categoryFilter_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(categoryFilter_view(_:))))
        search_tf.placeholder(text: "상품명을 입력하세요.", color: .black.withAlphaComponent(0.3))
        search_tf.addTarget(self, action: #selector(edit_search_tf(_:)), for: .editingChanged)
        delete_img.isHidden = true
        delete_btn.isHidden = true
        delete_btn.addTarget(self, action: #selector(delete_btn(_:)), for: .touchUpInside)
        search_btn.addTarget(self, action: #selector(search_btn(_:)), for: .touchUpInside)
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 22, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .black.withAlphaComponent(0.3)
        refreshControl.addTarget(self, action: #selector(refreshControl(_:)), for: .valueChanged)
        
        customLoadingIndicator(text: "불러오는 중...", animated: true)
        
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
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReGoodsFilterVC") as! ReGoodsFilterVC
        let root = UISideMenuNavigationController(rootViewController: segue, settings: .init())
        root.statusBarEndAlpha = .zero
        root.presentationStyle = .viewSlideOutMenuIn
        root.menuWidth = UIScreen.main.bounds.width-100
        present(root, animated: true, completion: nil)
        
//        guard let delegate = ReGoodsFilterVCdelegate else { return }
//
//        if !isMenuOpen {
//            addChild(delegate)
//            view.addSubview(delegate.view)
//            delegate.didMove(toParent: self)
//        }
//
//        let ReGoodsFilterVCwidth = delegate.view.frame.width
//        let ReGoodsFilterVCtransform = CGAffineTransform(translationX: !isMenuOpen ? -ReGoodsFilterVCwidth+100 : 0, y: 0)
//        let scaleTransform = CGAffineTransform(scaleX: !isMenuOpen ? 0.8 : 1.0, y: !isMenuOpen ? 0.8 : 1.0)
//
//        UIView.animate(withDuration: 0.3) {
//            self.view.transform = ReGoodsFilterVCtransform
//            delegate.view.transform = scaleTransform
//        } completion: { _ in
//            if self.isMenuOpen {
//                delegate.view.removeFromSuperview()
//                delegate.removeFromParent()
//            }
//        }
//
//        isMenuOpen = !isMenuOpen
    }
    
    @objc func edit_search_tf(_ sender: UITextField) {
        delete_img.isHidden = (sender.text!.count == 0)
        delete_btn.isHidden = (sender.text!.count == 0)
        tableView.refreshControl = (sender.text!.count == 0) ? refreshControl : nil
    }
    
    @objc func delete_btn(_ sender: UIButton) {
        tableView.refreshControl = refreshControl
        search.removeAll(); search_tf.text!.removeAll(); delete_img.isHidden = true; sender.isHidden = true; loadingData(first: true)
    }
     
    @objc func search_btn(_ sender: UIButton) {
        search_tf.resignFirstResponder()
        if search_tf.text! == "" {
            customAlert(message: "상품명을 입력하세요.", time: 1)
            search.removeAll()
        } else if search_tf.text!.count < 2 {
            customAlert(message: "두글자 이상 입력하세요.", time: 1); return
        } else {
            search = search_tf.text!
        }; loadingData(first: true)
    }
    
    @objc func refreshControl(_ sender: UIRefreshControl) {
        if tableView.refreshControl == nil { return }
        search.removeAll(); search_tf.text!.removeAll(); GoodsArray.removeAll(); tableView.reloadData()
        startIndexChange = false; delete_img.isHidden = true; loadingData(first: true)
    }
    
    func loadingData(first: Bool = false, item_name: String = "", item_pullup_time: String = "0", item_key: String = "0") {
        /// 데이터 삭제
        if first { GoodsArray.removeAll() }
        
        var params: [String: Any] = [
            "action": "search",
            "search": search,
            "item_name": item_name,
            "item_pullup_time": item_pullup_time,
            "item_key": item_key,
            "limit": 10,
        ]
        if item_category_name.count == 0 {
            params["filter"] = "전체보기"
        } else {
            params["filter"] = "카테고리"
            params["filterValue"] = item_category_name
        }
        
        if detail {
            params["store_id"] = store_id
            params["item_disclosure"] = disclosure
        }
        /// ReGoods 요청
        requestReGoods(params: params) { array, status in
            
            self.customLoadingIndicator(animated: false)
            
            if status == 200 {
                
                self.problemAlert(view: self.tableView)
                self.GoodsArray += array
                preheatImages(urls: self.GoodsArray.compactMap { URL(string: $0.item_mainphoto_img) })
                
                if first {
                    self.tableView.reloadData()
                } else {
                    var reload: [IndexPath] = []
                    (self.tableView.numberOfRows(inSection: 0) ..< self.GoodsArray.count).forEach { i in
                        reload.append(IndexPath(row: i, section: 0))
                    }
                    UIView.setAnimationsEnabled(false); self.tableView.beginUpdates(); self.tableView.insertRows(at: reload, with: .none); self.tableView.endUpdates(); UIView.setAnimationsEnabled(true)
                }
            } else if first, status == 204 {
                self.problemAlert(view: self.tableView, type: "nodata"); self.tableView.reloadData()
            } else if first, status != 200 {
                self.problemAlert(view: self.tableView, type: "error"); self.tableView.reloadData()
            }
            
            self.fetchingMore = false; self.refreshControl.endRefreshing()
            UIView.setAnimationsEnabled(false)
            self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
            UIView.setAnimationsEnabled(true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(detail)
        
        ChoiceStoreVCdelegate = nil
        ReStoreVisitVCdelegate = nil
        ReGoodsDetailVCdelegate = nil
    }
}

extension ReGoodsVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffsetY: CGFloat = scrollView.contentOffset.y
        let contentHeight: CGFloat = scrollView.contentSize.height
        let frameHeight: CGFloat = scrollView.frame.height
        
        if contentOffsetY > contentHeight-frameHeight && contentOffsetY > 0 && !fetchingMore && GoodsArray.count > 0 {
            fetchingMore = true; startIndexChange = true; tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                let data = self.GoodsArray[self.GoodsArray.count-1]
                self.loadingData(item_name: data.item_name, item_pullup_time: data.item_pullup_time, item_key: data.item_key)
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
        
        if indexPath.section == 0 {
            
            var data = GoodsArray[indexPath.row]
            guard let cell = cell as? ReGoodsTC else { return }
            
            if !data.load { data.load = true
                setKingfisher(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 10)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            guard let cell = cell as? ReGoodsTC else { return }
            
            cancelKingfisher(imageView: cell.item_img)
            cell.removeFromSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let data = GoodsArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReGoodsTC", for: indexPath) as! ReGoodsTC
            
            cell.storeName_btn.setTitle(data.store_name, for: .normal)
            cell.storeName_btn.tag = indexPath.row; cell.storeName_btn.addTarget(self, action: #selector(store_btn(_:)), for: .touchUpInside)
            cell.itemName_label.text = data.item_name
            cell.itemPrice_label.text = "₩\(priceFormatter.string(from: data.item_price as NSNumber) ?? "0")"
            cell.itemSalePrice_label.text = "₩\(priceFormatter.string(from: data.item_sale_price as NSNumber) ?? "0")"
            let percent = ((Double(data.item_price)-Double(data.item_sale_price))/Double(data.item_price)*1000).rounded()/10
            cell.itemSalePercent_label.isHidden = ((percent == 0) || !data.item_sale)
            cell.itemSalePercent_label.text = "↓ \(percent)%"
            
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FetchingMoreTC", for: indexPath) as! FetchingMoreTC
            
            cell.fetchingMore_indicatorView.color = .black.withAlphaComponent(0.3)
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
        
        if indexPath.section == 0 {
            
            let segue = storyboard?.instantiateViewController(withIdentifier: "ReGoodsDetailVC") as! ReGoodsDetailVC
            segue.GoodsObject = GoodsArray[indexPath.row]
            navigationController?.pushViewController(segue, animated: true)
        }
    }
}

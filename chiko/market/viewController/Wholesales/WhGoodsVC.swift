//
//  WhGoodsVC.swift
//  market
//
//  Created by Busan Dynamic on 1/3/24.
//

import UIKit

class WhGoodsTC: UITableViewCell {
    
    @IBOutlet weak var item_img: UIImageView!
    @IBOutlet weak var itemName_label: UILabel!
    @IBOutlet weak var itemPrice_label: UILabel!
    @IBOutlet weak var itemDisclosure_label: UILabel!
    @IBOutlet weak var itemPullUpTime_label: UILabel!
    @IBOutlet weak var itemDateTime_label: UILabel!
}

class WhGoodsVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var indexpath_row: Int = 0
    
    var GoodsArray: [GoodsData] = []
    var fetchingMore: Bool = false
    var startIndexChange: Bool = false
    var startIndex: Int = 0
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var itemFull_v: UIView!
    @IBOutlet weak var itemFull_lineView: UIView!
    @IBOutlet weak var itemAccount_v: UIView!
    @IBOutlet weak var itemAccount_lineView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ([itemFull_v, itemAccount_v] as [UIView]).enumerated().forEach { i, view in
            view.tag = i; view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(select_v(_:))))
        }
        ([itemFull_lineView, itemAccount_lineView] as [UIView]).enumerated().forEach { i, view in view.isHidden = !(i == indexpath_row) }
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .black.withAlphaComponent(0.3)
        refreshControl.addTarget(self, action: #selector(refreshControl(_:)), for: .valueChanged)
        
        loadingData(first: true)
    }
    
    @objc func select_v(_ sender: UITapGestureRecognizer) {
        
        guard let sender = sender.view else { return }
        
        ([itemFull_lineView, itemAccount_lineView] as [UIView]).enumerated().forEach { i, view in view.isHidden = !(i == sender.tag) }
        indexpath_row = sender.tag
        
        loadingData(first: true)
    }
    
    @objc func refreshControl(_ sender: UIRefreshControl) {
        GoodsArray.removeAll(); tableView.reloadData()
        startIndexChange = false; loadingData(first: true)
    }
    
    func loadingData(first: Bool = false, item_key: String = "0") {
        /// 데이터 삭제
        if first { GoodsArray.removeAll() }
        /// WhGoods 요청
        requestWhGoods(item_disclosure: ["전체 공개", "거래처만 공개"][indexpath_row], item_key: item_key, limit: 10) { array, status in
            
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
        
        setBackSwipeGesture(true)
        
        WhGoodsDetailVCdelegate = nil
    }
}

extension WhGoodsVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffsetY: CGFloat = scrollView.contentOffset.y
        let contentHeight: CGFloat = scrollView.contentSize.height
        let frameHeight: CGFloat = scrollView.frame.height
        
        if contentOffsetY > contentHeight-frameHeight && contentOffsetY > 0 && !fetchingMore && GoodsArray.count > 0 {
            fetchingMore = true; startIndexChange = true; tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                if self.GoodsArray.count > 0 {
                    self.loadingData(item_key: self.GoodsArray[self.GoodsArray.count-1].item_key)
                }
            }
        }
    }
}

extension WhGoodsVC: UITableViewDelegate, UITableViewDataSource {
    
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
            guard let cell = cell as? WhGoodsTC else { return }
            
            if !data.load { data.load = true
                setKingfisher(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 10)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            guard let cell = cell as? WhGoodsTC else { return }
            
            cancelKingfisher(imageView: cell.item_img)
            cell.removeFromSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let data = GoodsArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhGoodsTC", for: indexPath) as! WhGoodsTC
            
            cell.itemName_label.text = data.item_name
            cell.itemPrice_label.text = "₩\(priceFormatter.string(from: data.item_price as NSNumber) ?? "0")"
            cell.itemDisclosure_label.text = data.item_disclosure
            cell.itemPullUpTime_label.text = setTimestampToDateTime(timestamp: Int(data.item_pullup_time) ?? 0)
            cell.itemDateTime_label.text = setTimestampToDateTime(timestamp: Int(data.item_key) ?? 0)
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            let segue = storyboard?.instantiateViewController(withIdentifier: "WhGoodsDetailVC") as! WhGoodsDetailVC
            segue.GoodsObject = GoodsArray[indexPath.row]
            navigationController?.pushViewController(segue, animated: true)
        }
    }
}

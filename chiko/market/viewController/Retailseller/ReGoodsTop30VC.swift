//
//  ReGoodsTop30VC.swift
//  market
//
//  Created by Busan Dynamic on 6/20/24.
//

import UIKit

class ReGoodsTop30VC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var store_id: String = ""
    var GoodsArray: [GoodsData] = []
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .black.withAlphaComponent(0.3)
        refreshControl.addTarget(self, action: #selector(refreshControl(_:)), for: .valueChanged)
        
        customLoadingIndicator(animated: true)
        loadingData()
    }
    
    @objc func refreshControl(_ sender: UIRefreshControl) {
        loadingData(); sender.endRefreshing()
    }
    
    func loadingData() {
        /// 데이터 삭제
        GoodsArray.removeAll(); tableView.reloadData()
        /// Top30 요청
        requestTop30(store_id: store_id) { array, status in
            
            self.customLoadingIndicator(animated: false)
            
            if status == 200 {
                self.problemAlert(view: self.tableView)
                self.GoodsArray = array
            } else if status == 204 {
                self.problemAlert(view: self.tableView, type: "nodata")
            } else {
                self.problemAlert(view: self.tableView, type: "error")
            }; self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
    }
}

extension ReGoodsTop30VC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if GoodsArray.count > 0 { return GoodsArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var data = GoodsArray[indexPath.row]
        guard let cell = cell as? ReGoodsTC else { return }
        
        if !data.load { data.load = true
            setKingfisher(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 10)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            
        guard let cell = cell as? ReGoodsTC else { return }
        
        cancelKingfisher(imageView: cell.item_img)
        cell.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = GoodsArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReGoodsTC", for: indexPath) as! ReGoodsTC
        cell.position_label.text = " \(indexPath.row+1) "
        cell.storeName_btn.setTitle(data.store_name, for: .normal)
        cell.itemName_label.text = data.item_name
        cell.itemPrice_label.text = "₩\(priceFormatter.string(from: data.item_price as NSNumber) ?? "0")"
        cell.itemSalePrice_label.text = "₩\(priceFormatter.string(from: data.item_sale_price as NSNumber) ?? "0")"
        let percent = ((Double(data.item_price)-Double(data.item_sale_price))/Double(data.item_price)*1000).rounded()/10
        cell.itemSalePercent_label.isHidden = ((percent == 0) || !data.item_sale)
        cell.itemSalePercent_label.text = "↓ \(percent)%"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReGoodsDetailVC") as! ReGoodsDetailVC
        segue.GoodsObject = GoodsArray[indexPath.row]
        navigationController?.pushViewController(segue, animated: true, completion: nil)
    }
}

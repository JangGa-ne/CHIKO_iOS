//
//  ReHomeVC.swift
//  market
//
//  Created by Busan Dynamic on 10/31/23.
//

import UIKit

class ReHomeCC: UICollectionViewCell {
    
    var load: Bool = false
    
    @IBOutlet weak var storeNameEng_label: UILabel!
    @IBOutlet weak var storeName_label: UILabel!
    @IBOutlet weak var store_img: UIImageView!
    @IBOutlet weak var item_gv: UIGradientView!
    @IBOutlet weak var item_img: UIImageView!
    @IBOutlet weak var itemName_label: UILabel!
    @IBOutlet weak var itemPrice_label: UILabel!
    @IBOutlet weak var itemPrice_lineView: UIView!
    @IBOutlet weak var itemSalePrice_label: UILabel!
    @IBOutlet weak var itemSalePercent_label: UILabel!
    
    @IBOutlet weak var categoryName_label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    func viewDidLoad() {
        
        tableView.delegate = nil; tableView.dataSource = nil
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
    }
}

extension ReHomeCC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ReGoodsArray_best.count > 0 { return ReGoodsArray_best.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let data = ReGoodsArray_best[indexPath.row]
        guard let cell = cell as? ReGoodsTC else { return }
        
        setNuke(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 10)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = ReGoodsArray_best[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReGoodsTC", for: indexPath) as! ReGoodsTC
        
        if indexPath.row == 0 {
            cell.best_view.layer.borderColor = UIColor.H_8CD26B.cgColor
            cell.best_view.layer.borderWidth = 2
        } else {
            cell.best_view.layer.borderColor = UIColor.clear.cgColor
        }
        cell.best_label.isHidden = !(indexPath.row == 0)
        cell.best_label.layer.cornerRadius = 10
        cell.best_label.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        cell.best_label.clipsToBounds = true
        cell.storeName_btn.setTitle(data.store_name, for: .normal)
        cell.storeName_btn.tag = indexPath.row; cell.storeName_btn.addTarget(self, action: #selector(store_btn(_:)), for: .touchUpInside)
        cell.itemName_label.text = data.item_name
        cell.itemPrice_label.text = "₩ \(priceFormatter.string(from: data.item_price as NSNumber) ?? "0")"
        cell.itemSalePrice_label.text = "₩ \(priceFormatter.string(from: data.item_sale_price as NSNumber) ?? "0")"
        let percent = ((Double(data.item_price)-Double(data.item_sale_price))/Double(data.item_price)*1000).rounded()/10
        cell.itemSalePercent_label.isHidden = ((percent == 0) || !data.item_sale)
        cell.itemSalePercent_label.text = "↓ \(percent)%"
        
        return cell
    }
    
    @objc func store_btn(_ sender: UIButton) {
        
        let data = ReGoodsArray_best[sender.tag]
        let segue = ReHomeVCdelegate?.storyboard?.instantiateViewController(withIdentifier: "ReStoreVisitVC") as! ReStoreVisitVC
        segue.store_id = data.store_id
        ReHomeVCdelegate?.navigationController?.pushViewController(segue, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let segue = ReHomeVCdelegate?.storyboard?.instantiateViewController(withIdentifier: "ReGoodsDetailVC") as! ReGoodsDetailVC
        segue.GoodsObject = ReGoodsArray_best[indexPath.row]
        ReHomeVCdelegate?.navigationController?.pushViewController(segue, animated: true)
    }
}

class ReHomeTC: UITableViewCell {
    
    var indexpath_section: Int = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    func viewDidLoad() {
        
        collectionView.delegate = nil; collectionView.dataSource = nil
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 0; layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.setCollectionViewLayout(layout, animated: true, completion: nil)
        collectionView.delegate = self; collectionView.dataSource = self
        collectionView.decelerationRate = .fast
    }
}

extension ReHomeTC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if indexpath_section == 0, ReStoreArray_best.count > 0 {
            return ReStoreArray_best.count
        } else if indexpath_section == 1, ReGoodsArray_best.count > 0 {
            return 1
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexpath_section == 0 {
            
            let data = ReStoreArray_best[indexPath.row]
            guard let cell = cell as? ReHomeCC else { return }
            
            setNuke(imageView: cell.store_img, imageUrl: data.StoreObject.store_mainphoto_img, cornerRadius: 15)
            setNuke(imageView: cell.item_img, imageUrl: data.GoodsObject.item_mainphoto_img, cornerRadius: 10)
            imageUrlColor(imageUrl: data.StoreObject.store_mainphoto_img, point: cell.store_img.center) { color in
                cell.item_gv.startColor = color.withAlphaComponent(0.0); cell.item_gv.endColor = color.withAlphaComponent(1.0)
                if isDarkBackground(color: color) {
                    cell.itemName_label.textColor = .white
                    cell.itemPrice_label.textColor = .white.withAlphaComponent(0.3)
                    cell.itemPrice_lineView.backgroundColor = .white.withAlphaComponent(0.3)
                    cell.itemSalePrice_label.textColor = .white
                } else {
                    cell.itemName_label.textColor = .black
                    cell.itemPrice_label.textColor = .black.withAlphaComponent(0.3)
                    cell.itemPrice_lineView.backgroundColor = .black.withAlphaComponent(0.3)
                    cell.itemSalePrice_label.textColor = .black
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexpath_section == 0 {
            
            let data = ReStoreArray_best[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReHomeCC0", for: indexPath) as! ReHomeCC
            
            cell.storeNameEng_label.text = data.StoreObject.store_name_eng
            cell.storeName_label.text = data.StoreObject.store_name
            cell.item_gv.layer.cornerRadius = 15
            cell.item_gv.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.itemName_label.text = data.GoodsObject.item_name
            cell.itemPrice_label.text = "₩ \(priceFormatter.string(from: data.GoodsObject.item_price as NSNumber) ?? "0")"
            cell.itemSalePrice_label.text = "₩ \(priceFormatter.string(from: data.GoodsObject.item_sale_price as NSNumber) ?? "0")"
            let percent = ((Double(data.GoodsObject.item_price)-Double(data.GoodsObject.item_sale_price))/Double(data.GoodsObject.item_price)*1000).rounded()/10
            cell.itemSalePercent_label.isHidden = ((percent == 0) || !data.GoodsObject.item_sale)
            cell.itemSalePercent_label.text = "↓ \(percent)%"
            
            return cell
        } else if indexpath_section == 1 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReHomeCC1", for: indexPath) as! ReHomeCC
            cell.viewDidLoad()
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexpath_section == 0 {
            
            let data = ReStoreArray_best[indexPath.row]
            let segue = ReHomeVCdelegate?.storyboard?.instantiateViewController(withIdentifier: "ReGoodsDetailVC") as! ReGoodsDetailVC
            segue.GoodsObject = data.GoodsObject
            ReHomeVCdelegate?.navigationController?.pushViewController(segue, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width-40, height: 290)
    }
}

extension ReHomeTC: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == collectionView {
        
            let spacing = UIScreen.main.bounds.width-40+10
            let index = scrollView.contentOffset.x / spacing
            var new_index: CGFloat = 0.0
            
            if velocity.x > 0 { new_index = ceil(index) } else if velocity.x < 0 { new_index = floor(index) } else { new_index = round(index) }
            
            targetContentOffset.pointee = CGPoint(x: new_index * spacing, y: 0)
        } else {
            targetContentOffset.pointee = targetContentOffset.pointee
        }
    }
}

class ReHomeVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBOutlet weak var storeMain_img: UIImageView!
    @IBOutlet weak var choiceStore_btn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReHomeVCdelegate = self
        
//        setNuke(imageView: storeMain_img, imageUrl: StoreObject.store_mainphoto_img, cornerRadius: 15)
//        choiceStore_btn.addTarget(self, action: #selector(choiceStore_btn(_:)), for: .touchUpInside)
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = .zero }
        tableView.delegate = self; tableView.dataSource = self
        
        preheatImages(urls: ReStoreArray_best.compactMap { URL(string: $0.StoreObject.store_mainphoto_img) })
        preheatImages(urls: ReStoreArray_best.compactMap { URL(string: $0.GoodsObject.item_mainphoto_img) })
        preheatImages(urls: ReGoodsArray_best.compactMap { URL(string: $0.item_mainphoto_img) })
    }
    
    @objc func choiceStore_btn(_ sender: UIButton) {
        segueViewController(identifier: "ChoiceStoreVC")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
        
        ChoiceStoreVCdelegate = nil
        ReGoodsDetailVCdelegate = nil
    }
}

extension ReHomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0, ReStoreArray_best.count > 0 {
            return 1
        } else if section == 1, ReGoodsArray_best.count > 0 {
            return 1
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReHomeTC0", for: indexPath) as! ReHomeTC
            cell.indexpath_section = indexPath.section
            cell.viewDidLoad()
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReHomeTC1", for: indexPath) as! ReHomeTC
            cell.indexpath_section = indexPath.section
            cell.viewDidLoad()
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

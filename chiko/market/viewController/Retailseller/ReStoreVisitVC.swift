//
//  ReStoreVisitVC.swift
//  market
//
//  Created by 장 제현 on 11/20/23.
//

/// 번역완료

import UIKit

class ReStoreVisitCC: UICollectionViewCell {
    
    @IBOutlet weak var item_img: UIImageView!
    @IBOutlet weak var itemName_label: UILabel!
    @IBOutlet weak var itemPrice_label: UILabel!
}

class ReStoreVisitTC: UITableViewCell {
    
    var GoodsArray: [GoodsData] = []
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var store_img: UIImageView!
    @IBOutlet weak var storeNameEng_label: UILabel!
    @IBOutlet weak var storeName_label: UILabel!
    @IBOutlet weak var storeTel_label: UILabel!
    @IBOutlet weak var storeCounting_label: UILabel!
    @IBOutlet weak var storeTag_label: UILabel!
    
    @IBOutlet weak var tiele_label: UILabel!
    @IBOutlet weak var detail_btn: UIButton!
    
    @IBOutlet weak var following_view: UIView!
    @IBOutlet weak var following_img: UIImageView!
    @IBOutlet weak var following_btn: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    func viewDidLoad() {
        
        collectionView.delegate = nil; collectionView.dataSource = nil
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.delegate = self; collectionView.dataSource = self
    }
}

extension ReStoreVisitTC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if GoodsArray.count > 0 { return GoodsArray.count } else { return .zero }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        var data = GoodsArray[indexPath.row]
        guard let cell = cell as? ReStoreVisitCC else { return }
        
        if !data.load { data.load = true
            setKingfisher(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? ReStoreVisitCC else { return }
        
        cancelKingfisher(imageView: cell.item_img)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = GoodsArray[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReStoreVisitCC", for: indexPath) as! ReStoreVisitCC
        
        cell.itemName_label.text = data.item_name
        cell.itemPrice_label.text = "₩\(priceFormatter.string(from: data.item_price as NSNumber) ?? "0")"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let segue = ReStoreVisitVCdelegate?.storyboard?.instantiateViewController(withIdentifier: "ReGoodsDetailVC") as! ReGoodsDetailVC
        segue.GoodsObject = GoodsArray[indexPath.row]
        ReStoreVisitVCdelegate?.navigationController?.pushViewController(segue, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: collectionView.frame.height)
    }
}

class ReStoreVisitVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var store_id: String = ""
    var VisitObject: VisitData = VisitData()
    var following: Bool = false
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReStoreVisitVCdelegate = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .black.withAlphaComponent(0.3)
        refreshControl.addTarget(self, action: #selector(refreshControl(_:)), for: .valueChanged)
        
        customLoadingIndicator(text: "불러오는 중...", animated: true)
        loadingData()
    }
    
    @objc func refreshControl(_ sender: UIRefreshControl) {
        loadingData(); sender.endRefreshing()
    }
    
    func loadingData() {
        /// 데이터 삭제
        VisitObject = VisitData()
        /// ReStore Visit 요청
        requestReStoreVisit(store_id: store_id, limit: 5) { object, status in
            
            self.customLoadingIndicator(animated: false)
            
            switch status {
            case 200:
                self.VisitObject = object
                self.problemAlert(view: self.tableView)
            case 204:
                self.problemAlert(view: self.tableView, type: "nodata")
            default:
                self.problemAlert(view: self.tableView, type: "error")
            }; self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
        
        ReGoodsVCdelegate = nil
    }
}

extension ReStoreVisitVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let data = VisitObject.StoreObject
            guard let cell = cell as? ReStoreVisitTC else { return }
            
            if !data.load { data.load = true
                setKingfisher(imageView: cell.store_img, imageUrl: data.store_mainphoto_img, cornerRadius: 10)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            guard let cell = cell as? ReStoreVisitTC else { return }
            
            cancelKingfisher(imageView: cell.store_img)
            cell.removeFromSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let data = VisitObject.StoreObject
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReStoreVisitTC0", for: indexPath) as! ReStoreVisitTC
            
            cell.storeNameEng_label.text = data.store_name_eng
            cell.storeName_label.text = data.store_name
            cell.storeTel_label.text = "Tel. \(data.store_tel)"
            cell.storeCounting_label.text = "\(translation("스토어찜")) \(data.account_counting) ∙ \(translation("전체상품 수")) \(data.item_full_counting) ∙ \(translation("거래처상품 수")) \(data.item_account_counting)"
            cell.storeTag_label.isHidden = true//(data.store_tag.count == 0)
            data.store_tag.forEach { store_tag in cell.storeTag_label.text!.append("#\(store_tag) ") }
            
            cell.following_img.isHidden = !data.store_favorites.contains(StoreObject.store_id)
            cell.following_btn.addTarget(self, action: #selector(following_btn(_:)), for: .touchUpInside)
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReStoreVisitTC1", for: indexPath) as! ReStoreVisitTC
            
            cell.labels.forEach { label in label.text = translation(label.text!) }
            cell.buttons.forEach { btn in btn.setTitle(translation(btn.title(for: .normal)), for: .normal) }
            
            if indexPath.row == 1 {
                cell.tiele_label.text = "TOP"
                cell.GoodsArray = VisitObject.ReGoodsArray_best
            } else if indexPath.row == 2 {
                cell.tiele_label.text = translation("전체 공개")
                cell.GoodsArray = VisitObject.GoodsArray_full
            } else if indexPath.row == 3 {
                cell.tiele_label.text = translation("거래처만 공개")
                cell.GoodsArray = VisitObject.GoodsArray_business
            }
            cell.detail_btn.tag = indexPath.row; cell.detail_btn.addTarget(self, action: #selector(detail_btn(_:)), for: .touchUpInside)
            cell.viewDidLoad()
            cell.collectionView.isHidden = (indexPath.row == 3 && !(VisitObject.StoreObject.store_favorites.contains(StoreObject.store_id)))
            cell.collectionView.backgroundColor = .white
            
            return cell
        }
    }
    
    @objc func following_btn(_ sender: UIButton) {
        
        let data = VisitObject.StoreObject
        
        var action: String = ""
        if !data.store_favorites.contains(StoreObject.store_id) {
            action = "favorites_add"
        } else {
            action = "favorites_delete"
        }
        
        customLoadingIndicator(animated: true)
        
        /// Scrap Add / Delete 요청
        requestScrap(action: action, re_store_id: StoreObject.store_id, wh_store_id: data.store_id) { status in
            
            self.customLoadingIndicator(animated: false)
            
            switch status {
            case 200:
                
                if action == "favorites_add" {
                    data.store_favorites.append(StoreObject.store_id)
                    data.account_counting += 1
                    imageUrlStringToData(from: self.VisitObject.StoreObject.store_mainphoto_img) { mimeType, imgData in
                        DispatchQueue.main.async {
                            self.customAlert(message: data.store_name, scrap: true, image: UIImage(data: imgData ?? Data()) ?? UIImage(), time: 2)
                        }
                    }
                } else if action == "favorites_delete" {
                    data.store_favorites = data.store_favorites.filter { $0 != StoreObject.store_id }
                    data.account_counting -= 1
                }
                self.tableView.reloadData()
                
                if let delegate = ScrapVCdelegate {
                    delegate.loadingData()
                }
            default:
                self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
            }
        }
    }
    
    @objc func detail_btn(_ sender: UIButton) {
        
        if sender.tag == 3 && !(VisitObject.StoreObject.store_favorites.contains(StoreObject.store_id)) {
            customAlert(message: "'스토어찜'을 하셔야 보실 수 있습니다.", time: 1)
        } else if sender.tag == 1 {
            let segue = storyboard?.instantiateViewController(withIdentifier: "ReGoodsTop30VC") as! ReGoodsTop30VC
            segue.store_id = VisitObject.StoreObject.store_id
            navigationController?.pushViewController(segue, animated: true)
        } else {
            
            let segue = storyboard?.instantiateViewController(withIdentifier: "ReGoodsVC") as! ReGoodsVC
            segue.detail = true
            segue.store_id = VisitObject.StoreObject.store_id
            if sender.tag == 2 {
                segue.disclosure = "전체 공개"
            } else if sender.tag == 3 {
                segue.disclosure = "거래처만 공개"
            }
            navigationController?.pushViewController(segue, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1, VisitObject.ReGoodsArray_best.count == 0 {
            return .zero
        } else {
            return UITableView.automaticDimension
        }
    }
}

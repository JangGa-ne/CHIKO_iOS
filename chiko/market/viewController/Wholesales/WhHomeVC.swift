//
//  WhHomeVC.swift
//  market
//
//  Created by Busan Dynamic on 11/21/23.
//

import UIKit

class WhHomeCC: UICollectionViewCell {
    
    @IBOutlet weak var counting_label: UILabel!
    @IBOutlet weak var title_label: UILabel!
    
    @IBOutlet weak var grade_label: UILabel!
    @IBOutlet weak var item_img: UIImageView!
    @IBOutlet weak var itemName_label: UILabel!
    @IBOutlet weak var itemPrice_label: UILabel!
    @IBOutlet weak var orderCount_label: UILabel!
}

class WhHomeTC: UITableViewCell {
    
    var WhHomeVCdelegate: WhHomeVC = WhHomeVC()
    var indexpath_section: Int = 0
    var indexpath_row: Int = 0
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var collectionView1: UICollectionView!
    @IBOutlet weak var collectionView2: UICollectionView!
    @IBOutlet weak var collectionView3: UICollectionView!
    
    func viewDidLoad() {
        
        if indexpath_section == 1 {
            
            ([collectionView1, collectionView2] as [UICollectionView]).enumerated().forEach { i, collectionView in
                
                collectionView.delegate = nil; collectionView.dataSource = nil
                
                let layout = UICollectionViewFlowLayout()
                if i == 0 {
                    layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
                    layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
                }
                collectionView.setCollectionViewLayout(layout, animated: true, completion: nil)
                collectionView.delegate = self; collectionView.dataSource = self
            }
        } else if indexpath_section == 2 {
            
            preheatImages(urls: WhGoodsArray_realtime.compactMap { URL(string: $0.item_mainphoto_img) })
            
        } else if indexpath_section == 3 {
            
            collectionView3.delegate = nil; collectionView3.dataSource = nil
            
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 1; layout.minimumInteritemSpacing = 1
            collectionView3.setCollectionViewLayout(layout, animated: true, completion: nil)
            collectionView3.delegate = self; collectionView3.dataSource = self
        }
    }
}

extension WhHomeTC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionView1 {
            return 4
        } else if collectionView == collectionView2, WhGoodsArray_realtime.count > 0 {
            return WhGoodsArray_realtime.count
        } else if collectionView == collectionView3 {
            return 7
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView == collectionView2 {
            
            let data = WhGoodsArray_realtime[indexPath.row]
            guard let cell = cell as? WhHomeCC else { return }
            
            setKingfisher(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 7.5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView == collectionView2 {
            
            guard let cell = cell as? WhHomeCC else { return }
            
            cancelKingfisher(imageView: cell.item_img)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WhHomeCC", for: indexPath) as! WhHomeCC
        
        if collectionView == collectionView1 {
            
            cell.backgroundColor = .white
            cell.layer.cornerRadius = 15
            cell.layer.borderWidth = 0.5
            if indexPath.row == indexpath_row {
                cell.layer.borderColor = UIColor.H_8CD26B.cgColor
                cell.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.layer.shadowRadius = 5
                cell.layer.shadowColor = UIColor.H_8CD26B.cgColor
                cell.layer.shadowOpacity = 0.3
                cell.title_label.textColor = .H_8CD26B
            } else {
                cell.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
                cell.layer.shadowOpacity = 0.0
                cell.title_label.textColor = .black.withAlphaComponent(0.3)
            }
            cell.title_label.text = ["최신순", "끌올순", "오래된순", "품절순"][indexPath.row]
            
        } else if collectionView == collectionView2 {
            
            let data = WhGoodsArray_realtime[indexPath.row]
            
            if indexPath.row == 0 {
                cell.grade_label.textColor = .H_8CD26B
            } else {
                cell.grade_label.textColor = .black
            }
            cell.grade_label.text = String(indexPath.row+1)
            
            cell.itemName_label.text = data.item_name
            cell.itemPrice_label.text = "₩ \(priceFormatter.string(from: data.item_price as NSNumber) ?? "0")"
            cell.orderCount_label.text = "\(priceFormatter.string(from: data.item_order_count as NSNumber) ?? "0")건"
            
        } else if collectionView == collectionView3 {
            
            let data = [
                (title: "입금전", counting: WhCountingObject.before_payment),
                (title: "상품입고중", counting: WhCountingObject.in_stock),
                (title: "상품검품중", counting: WhCountingObject.inspecting),
                (title: "배송보류중", counting: WhCountingObject.pending),
                (title: "배송준비중", counting: WhCountingObject.preparing),
                (title: "배송완료", counting: WhCountingObject.complete),
                (title: "취소신청", counting: WhCountingObject.cancel),
            ][indexPath.row]
            
            cell.counting_label.text = priceFormatter.string(from: data.counting as NSNumber) ?? "0"
            cell.title_label.text = data.title
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionView1 {
            return CGSize(width: stringWidth(text: ["최신순", "끌올순", "오래된순", "품절순"][indexPath.row])+30, height: collectionView.frame.height)
        } else if collectionView == collectionView2 {
            return CGSize(width: UIScreen.main.bounds.width-70, height: 60)
        } else if collectionView == collectionView3 {
            return CGSize(width: UIScreen.main.bounds.width/4-18.25, height: collectionView.frame.height/2-0.5)
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == collectionView1 {
            
            indexpath_row = indexPath.row
            
            WhGoodsArray_realtime.removeAll()
            /// WhRealTime 요청
            requestWhRealTime(filter: ["최신순", "끌올순", "오래된순", "품절순"][indexPath.row], limit: 3) { _ in
                collectionView.reloadData(); self.collectionView2.reloadData()
            }
        } else if collectionView == collectionView2 {
            
            WhHomeVCdelegate.WhGoodsArray_realtime_row = indexPath.row
            
            let segue = WhHomeVCdelegate.storyboard?.instantiateViewController(withIdentifier: "WhGoodsDetailVC") as! WhGoodsDetailVC
            segue.GoodsObject = WhGoodsArray_realtime[indexPath.row]
            WhHomeVCdelegate.navigationController?.pushViewController(segue, animated: true)
        } else if collectionView == collectionView3 {
            
            
        }
    }
}

class WhHomeVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var WhGoodsArray_realtime_row: Int = 0
    
    @IBOutlet weak var myPage_btn: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var goodsUpload_view: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WhHomeVCdelegate = self
        
        myPage_btn.addTarget(self, action: #selector(myPage_btn(_:)), for: .touchUpInside)
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        
        goodsUpload_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goodsUpload_view(_:))))
    }
    
    @objc func myPage_btn(_ sender: UIButton) {
        segueViewController(identifier: "WhMyPageVC")
    }
    
    @objc func goodsUpload_view(_ sender: UITapGestureRecognizer) {
        segueViewController(identifier: "WhGoodsUploadVC")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
        
        WhMyPageVCdelegate = nil
        WhGoodsUploadVCdelegate = nil
        WhGoodsDetailVCdelegate = nil
    }
}

extension WhHomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return 1
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "WhHomeTC0", for: indexPath) as! WhHomeTC
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhHomeTC1", for: indexPath) as! WhHomeTC
            cell.WhHomeVCdelegate = self
            cell.indexpath_section = indexPath.section
            cell.viewDidLoad()
            
            return cell
        } else if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhHomeTC2", for: indexPath) as! WhHomeTC
            cell.WhHomeVCdelegate = self
            cell.indexpath_section = indexPath.section
            
            return cell
            
//        } else if indexPath.section == 3 {
//            
//            let cell = tableView.dequeueReusableCell(withIdentifier: "WhHomeTC3", for: indexPath) as! WhHomeTC
//            cell.WhHomeVCdelegate = self
//            cell.indexpath_section = indexPath.section
//            cell.viewDidLoad()
//            
//            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
        }
    }
}

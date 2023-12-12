//
//  WhHomeVC.swift
//  market
//
//  Created by Busan Dynamic on 11/21/23.
//

import UIKit

class WhHomeCC: UICollectionViewCell {
    
    @IBOutlet weak var title_label: UILabel!
    
    @IBOutlet weak var grade_label: UILabel!
    @IBOutlet weak var item_img: UIImageView!
    @IBOutlet weak var itemName_label: UILabel!
    @IBOutlet weak var itemPrice_label: UILabel!
    @IBOutlet weak var orderCount_label: UILabel!
}

class WhHomeTC: UITableViewCell {
    
    var WhHomeVCdelegate: WhHomeVC = WhHomeVC()
    var indexpath_row: Int = 0
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var collectionView1: UICollectionView!
    @IBOutlet weak var collectionView2: UICollectionView!
    
    func viewDidLoad() {
        
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
    }
}

extension WhHomeTC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionView1 {
            return 4
        } else if collectionView == collectionView2, GoodsArray_realtime.count > 0 {
            return GoodsArray_realtime.count
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView == collectionView2 {
            
            let data = GoodsArray_realtime[indexPath.row]
            guard let cell = cell as? WhHomeCC else { return }
            
            setNuke(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 7.5)
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
            
            cell.frame.size.width = UIScreen.main.bounds.width-70
            
            let data = GoodsArray_realtime[indexPath.row]
            
            if indexPath.row == 0 {
                cell.grade_label.textColor = .H_8CD26B
            } else {
                cell.grade_label.textColor = .black
            }
            cell.grade_label.text = String(indexPath.row+1)
            
            cell.itemName_label.text = data.item_name
            cell.itemPrice_label.text = "₩ \(priceFormatter.string(from: data.item_price as NSNumber) ?? "0")"
            cell.orderCount_label.text = "\(priceFormatter.string(from: data.item_order_count as NSNumber) ?? "0")건"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionView1 {
            return CGSize(width: stringWidth(text: ["최신순", "끌올순", "오래된순", "품절순"][indexPath.row])+30, height: collectionView.frame.height)
        } else if collectionView == collectionView2 {
            return CGSize(width: UIScreen.main.bounds.width-70, height: 60)
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == collectionView1 {
            
            indexpath_row = indexPath.row
            
            GoodsArray_realtime.removeAll()
            /// WhRealTime 요청
            requestWhRealTime(filter: ["최신순", "끌올순", "오래된순", "품절순"][indexPath.row], limit: 3) { _ in
                collectionView.reloadData(); self.collectionView2.reloadData()
            }
        } else if collectionView == collectionView2 {
            
            let segue = WhHomeVCdelegate.storyboard?.instantiateViewController(withIdentifier: "WhGoodsDetailVC") as! WhGoodsDetailVC
            segue.GoodsObject = GoodsArray_realtime[indexPath.row]
            WhHomeVCdelegate.navigationController?.pushViewController(segue, animated: true)
        }
    }
}

class WhHomeVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBAction func logout(_ sender: UIButton) { segueViewController(identifier: "SignInVC") }
     
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var goodsUpload_view: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WhHomeVCdelegate = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        
        goodsUpload_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goodsUpload_view(_:))))
    }
    
    @objc func goodsUpload_view(_ sender: UITapGestureRecognizer) {
        segueViewController(identifier: "WhGoodsUploadVC")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
        
        WhGoodsUploadVCdelegate = nil
        WhGoodsDetailVCdelegate = nil
    }
}

extension WhHomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
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
            cell.viewDidLoad()
            
            cell.title_label.text = ["실시간 도매 리스트"][indexPath.row]
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
        }
    }
}

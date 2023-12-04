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
    
    var indexpath_row: Int = 0
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var collectionView1: UICollectionView!
    @IBOutlet weak var collectionView2: UICollectionView!
    
    func viewDidLoad() {
        
        ([collectionView1, collectionView2] as [UICollectionView]).enumerated().forEach { i, collectionView in
            
            collectionView.delegate = nil; collectionView.dataSource = nil
            
            if i == 0 {
                let layout = UICollectionViewFlowLayout()
                layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10
                layout.scrollDirection = .horizontal
                layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
                collectionView.setCollectionViewLayout(layout, animated: true, completion: nil)
            }
            collectionView.delegate = self; collectionView.dataSource = self
        }
    }
}

extension WhHomeTC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionView1 {
            return 5
        } else if collectionView == collectionView2 {
            return 3
        } else {
            return .zero
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
            cell.title_label.text = ["최신순", "끌올순", "찜한순", "오래된순", "품절순"][indexPath.row]
        } else if collectionView == collectionView2 {
            if indexPath.row == 0 {
                cell.grade_label.textColor = .H_8CD26B
            } else {
                cell.grade_label.textColor = .black
            }
            cell.grade_label.text = String(indexPath.row+1)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionView1 {
            return CGSize(width: stringWidth(text: ["최신순", "끌올순", "찜한순", "오래된순", "품절순"][indexPath.row])+30, height: collectionView.frame.height)
        } else if collectionView == collectionView2 {
            return CGSize(width: UIScreen.main.bounds.width-70, height: 60)
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionView1 {
            indexpath_row = indexPath.row
        } else if collectionView == collectionView2 {
            
        }
        collectionView.reloadData()
    }
}

class WhHomeVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBAction func aaaa(_ sender: UIButton) { segueViewController(identifier: "WhGoodsUploadVC") }
    @IBAction func logout(_ sender: UIButton) { segueViewController(identifier: "SignInVC") }
     
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WhHomeVCdelegate = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
        
        WhGoodsUploadVCdelegate = nil
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
            cell.title_label.text = ["실시간 도매 리스트"][indexPath.row]
            cell.viewDidLoad()
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

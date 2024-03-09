//
//  ReBookMarkVC.swift
//  market
//
//  Created by Busan Dynamic on 11/30/23.
//

import UIKit

class ReBookMarkTC: UITableViewCell {
    
    @IBOutlet weak var store_img: UIImageView!
    @IBOutlet weak var storeName_label: UILabel!
    @IBOutlet weak var storeNameEng_label: UILabel!
    @IBOutlet weak var lineView: UIView!
}

class ReBookMarkVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var BookMarkArray: [StoreData] = []
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReBookMarkVCdelegate = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        
        loadingData()
    }
    
    func loadingData() {
        /// 데이터 삭제
        BookMarkArray.removeAll(); tableView.reloadData()
        
        customLoadingIndicator(animated: true)
        
        /// ReBookMark 요청
        requestReBookMark(store_id: StoreObject.store_id) { array, status in
            
            self.customLoadingIndicator(animated: false)
            
            if status == 200 {
                self.problemAlert(view: self.tableView)
                self.BookMarkArray += array; self.tableView.reloadData()
            } else if status == 204 {
                self.problemAlert(view: self.tableView, type: "nodata")
            } else {
                self.problemAlert(view: self.tableView, type: "error")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
    }
}

extension ReBookMarkVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if BookMarkArray.count > 0 { return BookMarkArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let data = BookMarkArray[indexPath.row]
        guard let cell = cell as? ReBookMarkTC else { return }
        
        setKingfisher(imageView: cell.store_img, imageUrl: data.store_mainphoto_img, cornerRadius: 10)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            
        guard let cell = cell as? ReBookMarkTC else { return }
        
        cancelKingfisher(imageView: cell.store_img)
        cell.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = BookMarkArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReBookMarkTC", for: indexPath) as! ReBookMarkTC
        
        cell.storeName_label.text = data.store_name
        cell.storeNameEng_label.text = data.store_name_eng
        cell.lineView.isHidden = (indexPath.row == BookMarkArray.count-1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = BookMarkArray[indexPath.row]
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReStoreVisitVC") as! ReStoreVisitVC
        segue.store_id = data.store_id
        navigationController?.pushViewController(segue, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "팔로우 취소"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let data = BookMarkArray[indexPath.row]
            /// ReBookMark Delete 요청
            requestReBookMark(action: "favorites_delete", re_store_id: StoreObject.store_id, wh_store_id: data.store_id) { status in
                
                switch status {
                case 200:
                    self.BookMarkArray.remove(at: indexPath.row); tableView.deleteRows(at: [indexPath], with: .none)
                case 600:
                    self.customAlert(message: "Error occurred during data conversion", time: 1)
                default:
                    self.customAlert(message: "Internal server error", time: 1)
                }
            }
        }
    }
}

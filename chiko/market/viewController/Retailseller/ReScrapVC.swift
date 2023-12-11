//
//  ReScrapVC.swift
//  market
//
//  Created by Busan Dynamic on 11/30/23.
//

import UIKit

class ReScrapTC: UITableViewCell {
    
    @IBOutlet weak var store_img: UIImageView!
    @IBOutlet weak var storeName_label: UILabel!
    @IBOutlet weak var storeNameEng_label: UILabel!
    @IBOutlet weak var lineView: UIView!
}

class ReScrapVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var ScrapArray: [StoreData] = []
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReScrapVCdelegate = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        
        loadingData()
    }
    
    func loadingData() {
        
        customLoadingIndicator(animated: true)
        
        /// ReScrap 요청
        requestReScrap(store_id: StoreObject.store_id) { array, status in
            
            self.customLoadingIndicator(animated: false)
            
            if status == 200, array != nil {
                self.ScrapArray = array ?? [StoreData()]; self.tableView.reloadData()
            } else if status == 600 {
                self.customAlert(message: "Error occurred during data conversion", time: 1)
            } else {
                self.customAlert(message: "Internal server error", time: 1)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
    }
}

extension ReScrapVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ScrapArray.count > 0 { return ScrapArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let data = ScrapArray[indexPath.row]
        guard let cell = cell as? ReScrapTC else { return }
        
        setNuke(imageView: cell.store_img, imageUrl: data.store_mainphoto_img, cornerRadius: 10)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = ScrapArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReScrapTC", for: indexPath) as! ReScrapTC
        
        cell.storeName_label.text = data.store_name
        cell.storeNameEng_label.text = data.store_name_eng
        cell.lineView.isHidden = (indexPath.row == ScrapArray.count-1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = ScrapArray[indexPath.row]
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReStoreVisitVC") as! ReStoreVisitVC
        segue.store_id = data.store_id
        navigationController?.pushViewController(segue, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "팔로우 취소"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let data = ScrapArray[indexPath.row]
            /// ReAccount Delete 요청
            requestReAccount(action: "favorites_delete", re_store_id: StoreObject.store_id, wh_store_id: data.store_id) { status in
                
                switch status {
                case 200:
                    self.ScrapArray.remove(at: indexPath.row); tableView.deleteRows(at: [indexPath], with: .none)
                case 600:
                    self.customAlert(message: "Error occurred during data conversion", time: 1)
                default:
                    self.customAlert(message: "Internal server error", time: 1)
                }
            }
        }
    }
}

//
//  ScrapVC.swift
//  market
//
//  Created by 장 제현 on 11/30/23.
//

import UIKit

class ScrapTC: UITableViewCell {
    
    @IBOutlet weak var store_img: UIImageView!
    @IBOutlet weak var storeName_label: UILabel!
    @IBOutlet weak var storeNameEng_label: UILabel!
    @IBOutlet weak var lineView: UIView!
}

class ScrapVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var ScrapArray: [StoreData] = []
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ScrapVCdelegate = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        
        loadingData()
    }
    
    func loadingData() {
        /// 데이터 삭제
        ScrapArray.removeAll(); tableView.reloadData()
        
        customLoadingIndicator(text: "불러오는 중...", animated: true)
        
        /// Scrap 요청
        requestScrap(store_id: StoreObject.store_id) { array, status in
            
            self.customLoadingIndicator(animated: false)
            
            if status == 200 {
                self.problemAlert(view: self.tableView)
                self.ScrapArray += array
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

extension ScrapVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ScrapArray.count > 0 { return ScrapArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let data = ScrapArray[indexPath.row]
        guard let cell = cell as? ScrapTC else { return }
        
        if !data.load { data.load = true
            setKingfisher(imageView: cell.store_img, imageUrl: data.store_mainphoto_img, cornerRadius: 10)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            
        guard let cell = cell as? ScrapTC else { return }
        
        cancelKingfisher(imageView: cell.store_img)
        cell.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = ScrapArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScrapTC", for: indexPath) as! ScrapTC
        
        cell.storeName_label.text = data.store_name
        cell.storeNameEng_label.text = data.store_name_eng
        cell.lineView.isHidden = (indexPath.row == ScrapArray.count-1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard StoreObject.store_type == "retailseller" else { return }
        
        let data = ScrapArray[indexPath.row]
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReStoreVisitVC") as! ReStoreVisitVC
        segue.store_id = data.store_id
        navigationController?.pushViewController(segue, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        
        guard StoreObject.store_type == "retailseller" else { return nil }
        
        return "팔로우 취소"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard StoreObject.store_type == "retailseller" else { return }
        
        if editingStyle == .delete {
            
            let data = ScrapArray[indexPath.row]
            /// Scrap Delete 요청
            requestScrap(action: "favorites_delete", re_store_id: StoreObject.store_id, wh_store_id: data.store_id) { status in
                
                switch status {
                case 200:
                    self.ScrapArray.remove(at: indexPath.row); tableView.deleteRows(at: [indexPath], with: .none)
                default:
                    self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
                }
            }
        }
    }
}

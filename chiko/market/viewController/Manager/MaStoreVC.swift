//
//  MaStoreVC.swift
//  market
//
//  Created by Busan Dynamic on 6/28/24.
//

import UIKit
import FirebaseFirestore

class MaStoreTC: UITableViewCell {
    
    @IBOutlet weak var store_img: UIImageView!
    @IBOutlet weak var storeName_label: UILabel!
    @IBOutlet weak var storeNameEng_label: UILabel!
    @IBOutlet weak var lineView: UIView!
}

class MaStoreVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var StoreArray: [StoreData] = []
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        
        AdminListener = Firestore.firestore().collection("store").whereField("store_type", isEqualTo: "wholesales").addSnapshotListener { ref, error in
            /// 데이터 삭제
            self.StoreArray.removeAll(); self.tableView.reloadData()
            
            guard let ref = ref else { return }
            
            ref.documents.forEach { docRef in
                /// 데이터 추가
                self.StoreArray.append(setStore(storeDict: docRef.data()))
            }; self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
    }
}

extension MaStoreVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if StoreArray.count > 0 { return StoreArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let data = StoreArray[indexPath.row]
        guard let cell = cell as? MaStoreTC else { return }
        
        if !data.load { data.load = true
            setKingfisher(imageView: cell.store_img, imageUrl: data.store_mainphoto_img, cornerRadius: 10)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? MaStoreTC else { return }
        
        cancelKingfisher(imageView: cell.store_img)
        cell.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = StoreArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MaStoreTC", for: indexPath) as! MaStoreTC
        
        cell.storeName_label.text = data.store_name
        cell.storeNameEng_label.text = data.store_name_eng
        cell.lineView.isHidden = (indexPath.row == StoreArray.count-1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
}

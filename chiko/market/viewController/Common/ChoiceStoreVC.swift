//
//  ChoiceStoreVC.swift
//  market
//
//  Created by 장 제현 on 2023/10/18.
//

import UIKit

class ChoiceStoreTC: UITableViewCell {
    
    @IBOutlet weak var storeMain_img: UIImageView!
    @IBOutlet weak var storeName_label: UILabel!
    @IBOutlet weak var storeNameEng_label: UILabel!
    @IBOutlet weak var select_lineView: UIView!
}

class ChoiceStoreVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBOutlet weak var back_view: UIView!
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    @IBOutlet weak var navi_label: UILabel!
    @IBOutlet weak var navi_lineView: UIView!
    @IBOutlet weak var logout_btn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchStore_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChoiceStoreVCdelegate = self
        // init
        /// navi
        back_view.isHidden = back_btn_hidden
        navi_label.alpha = 0.0
        navi_lineView.alpha = 0.0
        logout_btn.isHidden = !back_btn_hidden
        logout_btn.addTarget(self, action: #selector(logout_btn(_:)), for: .touchUpInside)
        
        back_btn_hidden = false
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self
        tableView.dataSource = self
        
        searchStore_btn.addTarget(self, action: #selector(searchStore_btn(_:)), for: .touchUpInside)
    }
    
    @objc func logout_btn(_ sender: UIButton) {
        segueViewController(identifier: "SignInVC")
    }
    
    @objc func searchStore_btn(_ sender: UIButton) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "SearchStoreVC") as! SearchStoreVC
        segue.ChoiceStoreVCdelegate = self
        navigationController?.pushViewController(segue, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

extension ChoiceStoreVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if StoreArray.count > 0 { return StoreArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let data = StoreArray[indexPath.row]
        guard let cell = cell as? ChoiceStoreTC else { return }
        
        if !data.load { data.load = true
            setKingfisher(imageView: cell.storeMain_img, imageUrl: data.store_mainphoto_img, cornerRadius: 10)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? ChoiceStoreTC else { return }
        
        cancelKingfisher(imageView: cell.storeMain_img)
        cell.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = StoreArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceStoreTC", for: indexPath) as! ChoiceStoreTC
        
        store_index_select = Bool(UserDefaults.standard.string(forKey: "store_index_select") ?? "false") ?? false
        store_index = UserDefaults.standard.integer(forKey: "store_index")
        
        cell.storeName_label.text = data.store_name
        cell.storeNameEng_label.text = data.store_name_eng
        if store_index_select, store_index == indexPath.row {
            cell.select_lineView.backgroundColor = .H_8CD26B
        } else {
            cell.select_lineView.backgroundColor = .black.withAlphaComponent(0.3)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UserDefaults.standard.setValue("true", forKey: "store_index_select")
        UserDefaults.standard.setValue(indexPath.row, forKey: "store_index")
        tableView.reloadData()
        
        store_index_select = true
        store_index = indexPath.row
        
        customLoadingIndicator(text: "불러오는 중...", animated: true)
        
        if MemberObject.member_type == "retailseller" {
            /// 데이터 삭제
            ReBasketArray.removeAll()
            /// ReBasket 요청
            requestReBasket(type: "get") { _ in
                
                self.customLoadingIndicator(animated: false)
                
                ReHomeVCdelegate = nil
                self.segueTabBarController(identifier: "ReMainTBC", idx: 0)
            }
        } else if MemberObject.member_type == "wholesales" {
            
            customLoadingIndicator(animated: false)
            
            WhHomeVCdelegate = nil
            if StoreArray[store_index].waiting_step == 0 || StoreArray[store_index].waiting_step == 1 {
                segueViewController(identifier: "WhWaitingVC")
            } else if StoreArray[store_index].waiting_step == 2 {
                segueViewController(identifier: "WhHomeVC")
            }
        }
    }
}

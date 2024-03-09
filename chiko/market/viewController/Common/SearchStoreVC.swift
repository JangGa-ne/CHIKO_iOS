//
//  SearchStoreVC.swift
//  market
//
//  Created by Busan Dynamic on 2023/10/18.
//

import UIKit

class SearchStoreTC: UITableViewCell {
    
    @IBOutlet weak var storeMain_img: UIImageView!
    @IBOutlet weak var storeName_label: UILabel!
    @IBOutlet weak var storeNameEng_label: UILabel!
    @IBOutlet weak var select_lineView: UIView!
}

class SearchStoreVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var SignUpMemberVCdelegate: SignUpMemberVC? = nil
    var ChoiceStoreVCdelegate: ChoiceStoreVC? = nil
    
    var search_store_type: String = ""
    var StoreArray_search: [StoreData] = []
    
    @IBAction func back_btn(_ sender: UIButton) { view.endEditing(true); navigationController?.popViewController(animated: true) }
    @IBOutlet weak var navi_label: UILabel!
    @IBOutlet weak var navi_lineView: UIView!
    
    @IBOutlet weak var searchStore_tf: UITextField!
    @IBOutlet weak var searchStore_btn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SearchStoreVCdelegate = self
        
        setKeyboard()
        // init
        /// navi
        navi_label.alpha = 0.0
        navi_lineView.alpha = 0.0
        
        searchStore_tf.placeholder(text: "매장명을 입력하세요.", color: .black.withAlphaComponent(0.3))
        searchStore_btn(UIButton())
        searchStore_btn.addTarget(self, action: #selector(searchStore_btn(_:)), for: .touchUpInside)
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
    }
    
    @objc func searchStore_btn(_ sender: UIButton) {
        /// 데이터 삭제
        StoreArray_search.removeAll()
        
        customLoadingIndicator(animated: true)
        /// Search Store 요청
        requestSearchStore(storeType: search_store_type, storeName: searchStore_tf.text!) { status in
            
            self.customLoadingIndicator(animated: false); self.tableView.reloadData()
            
            switch status {
            case 200:
                break
            case 204:
                self.customAlert(message: "No Data", time: 1)
            case 600:
                self.customAlert(message: "Error occurred during data conversion", time: 1)
            default:
                self.customAlert(message: "Internal server error", time: 1)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

extension SearchStoreVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if StoreArray_search.count > 0 { return StoreArray_search.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let data = StoreArray_search[indexPath.row]
        guard let cell = cell as? SearchStoreTC else { return }
        
        setKingfisher(imageView: cell.storeMain_img, imageUrl: data.store_mainphoto_img, cornerRadius: 10)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? SearchStoreTC else { return }
        
        cancelKingfisher(imageView: cell.storeMain_img)
        cell.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = StoreArray_search[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchStoreTC", for: indexPath) as! SearchStoreTC
        
        cell.storeName_label.text = data.store_name
        cell.storeNameEng_label.text = data.store_name_eng
        if !store_index_select, store_index == indexPath.row {
            cell.select_lineView.backgroundColor = .H_8CD26B
        } else {
            cell.select_lineView.backgroundColor = .black.withAlphaComponent(0.3)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// hidden keyboard
        view.endEditing(true)
        
        let data = StoreArray_search[indexPath.row]
        let alert = UIAlertController(title: "비밀번호 입력", message: "스토어를 등록하기 위해\n 비밀번호를 입력해 주세요.", preferredStyle: .alert)
        alert.addTextField()
        let storePw_tf = alert.textFields?[0] ?? UITextField()
        storePw_tf.keyboardType = .numberPad
        storePw_tf.placeholder(text: "비밀번호를 입력하세요.", color: .black.withAlphaComponent(0.3))
        alert.addAction(UIAlertAction(title: "등록", style: .default, handler: { _ in
            if data.store_pw == storePw_tf.text! {
                /// signup member
                if let delegate = self.SignUpMemberVCdelegate {
                    /// 데이터 삭제
                    StoreObject_signup = StoreData()
                    /// 데이터 추가
                    StoreObject_signup = data
                    delegate.registerSearchStoreName_label.text = data.store_name
                    delegate.registerSearchStore_btn.isSelected = true
                    delegate.registerSearchStore_btn.backgroundColor = .H_8CD26B
                    self.dismiss(animated: true) { self.navigationController?.popViewController(animated: true) }
                }
                /// choice store
                if let delegate = self.ChoiceStoreVCdelegate {
                    /// Store Add 요청
                    requestReStoreAdd(store_id: data.store_id, store_pw: storePw_tf.text!) { status in
                        
                        switch status {
                        case 200:
                            delegate.tableView.reloadData()
                            self.dismiss(animated: true) { self.navigationController?.popViewController(animated: true) }
                        case 204:
                            self.customAlert(message: "No Data", time: 1)
                        case 600:
                            self.customAlert(message: "Error occurred during data conversion", time: 1)
                        default:
                            self.customAlert(message: "Internal server error", time: 1)
                        }
                    }
                }
            } else {
                self.customAlert(message: "비밀번호가 맞지 않습니다.", time: 1)
            }
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func storePw_tf(_ sender: UITextField) {
        
    }
}


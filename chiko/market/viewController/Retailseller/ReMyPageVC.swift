//
//  ReMyPageVC.swift
//  market
//
//  Created by Busan Dynamic on 11/13/23.
//

import UIKit

class ReMyPageTC: UITableViewCell {
    
    @IBOutlet weak var mPay_view: UIView!
    @IBOutlet weak var mPay_label: UILabel!
    @IBOutlet weak var order_view: UIView!
    @IBOutlet weak var basket_view: UIView!
    @IBOutlet weak var basket_noticeView: UIView!
    @IBOutlet weak var scrap_view: UIView!
    @IBOutlet weak var setting_view: UIView!
    
    @IBOutlet weak var title_label: UILabel!
}

class ReMyPageVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    let menus: [(title: String, content: [String])] = [
        (title: "매장관리", content: ["직원관리"]),
        (title: "정보관리", content: ["계좌관리", "사업자관리", "내정보관리"]),
        (title: "고객센터", content: ["문의하기"] as [String]),
    ]
    let segues: [(String, [String])] = [
        ("매장관리", ["EmployeeVC"]),
        ("정보관리", ["AccountVC", "StoreVC", "MemberVC"]),
        ("고객센터", [""] as [String]),
    ]
    
    @IBOutlet weak var storeMain_img: UIImageView!
    @IBOutlet weak var choiceStore_btn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logout_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReMyPageVCdelegate = self
        
//        setNuke(imageView: storeMain_img, imageUrl: StoreObject.store_mainphoto_img, cornerRadius: 15)
//        choiceStore_btn.addTarget(self, action: #selector(choiceStore_btn(_:)), for: .touchUpInside)
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = .zero }
        tableView.delegate = self; tableView.dataSource = self
        
        logout_btn.addTarget(self, action: #selector(logout_btn(_:)), for: .touchUpInside)
    }
    
    @objc func choiceStore_btn(_ sender: UIButton) {
        segueViewController(identifier: "ChoiceStoreVC")
    }
    
    @objc func logout_btn(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive, handler: { _ in
            self.segueViewController(identifier: "SignInVC")
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
        
        ChoiceStoreVCdelegate = nil
        ReBasketVCdelegate = nil
        ReBookMarkVCdelegate = nil
        
        tableView.reloadData()
    }
}

extension ReMyPageVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return menus.count+1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReMyPageTCT") as! ReMyPageTC
        cell.title_label.text = menus[section-1].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return .zero } else { return 54 }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 } else { return menus[section-1].content.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReMyPageTC0", for: indexPath) as! ReMyPageTC
            cell.basket_noticeView.isHidden = (BasketArray.count == 0)
            ([cell.mPay_view, cell.order_view, cell.basket_view, cell.scrap_view, cell.setting_view] as [UIView]).enumerated().forEach { i, view in
                view.tag = i; view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(segue_view(_:))))
            }
            cell.mPay_label.text = priceFormatter.string(from: StoreObject.store_cash as NSNumber) ?? "0"
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReMyPageTC1", for: indexPath) as! ReMyPageTC
            cell.title_label.text = menus[indexPath.section-1].content[indexPath.row]
            return cell
        }
    }
    
    @objc func segue_view(_ sender: UITapGestureRecognizer) {
        
        guard let sender = sender.view else { return }
        
        if sender.tag == 0 {
            
        } else if sender.tag == 1 {
            
        } else if sender.tag == 2 {
            segueViewController(identifier: "ReBasketVC")
        } else if sender.tag == 3 {
            segueViewController(identifier: "ReBookMarkVC")
        } else if sender.tag == 4 {
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section != 0 {
            segueViewController(identifier: segues[indexPath.section-1].1[indexPath.row])
        }
    }
}

//
//  WhMyPageVC.swift
//  market
//
//  Created by Busan Dynamic on 1/2/24.
//

import UIKit

class WhMyPageTC: UITableViewCell {
    
    @IBOutlet weak var store_v: UIView!
    @IBOutlet weak var storeName_label: UILabel!
    @IBOutlet weak var storeNameEng_label: UILabel!
    @IBOutlet weak var storeMain_img: UIImageView!
    @IBOutlet weak var member_v: UIView!
    @IBOutlet weak var memberName_label: UILabel!
    @IBOutlet weak var memberGrade_label: UILabel!
    @IBOutlet weak var memberProfile_img: UIImageView!
    @IBOutlet weak var accountCounting_v: UIView!
    @IBOutlet weak var accountCounting_label: UILabel!
    @IBOutlet weak var itemFullCounting_v: UIView!
    @IBOutlet weak var itemFullCounting_label: UILabel!
    @IBOutlet weak var itemAccountCounting_v: UIView!
    @IBOutlet weak var itemAccountCounting_label: UILabel!
    @IBOutlet weak var mPay_v: UIView!
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var title_bottom: NSLayoutConstraint!
}

class WhMyPageVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    let menus: [(title: String, content: [String])] = [
        (title: "상품관리", content: ["조회/수정", "상품등록"]),
        (title: "주문관리", content: ["오늘의주문", "배송관리"]),
        (title: "정산관리", content: ["매입전잔"]),
        (title: "매장관리", content: ["매장태그관리", "직원관리"]),
        (title: "정보관리", content: ["계좌관리", "사업자수정", "내정보수정"]),
        (title: "고객센터", content: ["자주묻는질문"]),
    ]
    let segues: [(String, [String])] = [
        ("상품관리", ["WhGoodsVC", "WhGoodsUploadVC"]),
        ("주문관리", ["WhOrderVC", ""]),
        ("정산관리", [""]),
        ("매장관리", ["TagVC", "EmployeeVC"]),
        ("정보관리", ["AccountVC", "StoreVC", "MemberVC"]),
        ("고객센터", [""]),
    ]
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logout_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WhMyPageVCdelegate = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = .zero }
        tableView.delegate = self; tableView.dataSource = self
        
        logout_btn.addTarget(self, action: #selector(logout_btn(_:)), for: .touchUpInside)
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
        
        setBackSwipeGesture(true)
        
        MPayVCdelegate = nil
        
        WhGoodsUploadVCdelegate = nil
        WhGoodsDetailVCdelegate = nil
        WhGoodsTop30VCdelegate = nil
        
        WhOrderVCdelegate = nil
        
        AccountVCdelegate = nil
        TagVCdelegate = nil
    }
}

extension WhMyPageVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return menus.count+1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhMyPageTCT") as! WhMyPageTC
        cell.title_label.text = menus[section-1].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return .zero } else { return 54 }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if menus[section-1].content.count > 0 {
            return menus[section-1].content.count
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhMyPageTC1", for: indexPath) as! WhMyPageTC
            
            cell.storeName_label.text = StoreObject.store_name
            cell.storeNameEng_label.text = StoreObject.store_name_eng
            setNuke(imageView: cell.storeMain_img, imageUrl: StoreObject.store_mainphoto_img, cornerRadius: 10)
            cell.memberName_label.text = MemberObject.member_name
            cell.memberGrade_label.text = MemberObject.member_grade
            setNuke(imageView: cell.memberProfile_img, imageUrl: MemberObject.profile_img, cornerRadius: 10)
            
            ([cell.store_v, cell.member_v, cell.accountCounting_v, cell.itemFullCounting_v, cell.itemAccountCounting_v, cell.mPay_v] as [UIView]).enumerated().forEach { i, view in
                view.tag = i; view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(select_v(_:))))
            }
            
            cell.accountCounting_label.text = priceFormatter.string(from: StoreObject.account_counting as NSNumber) ?? "0"
            cell.itemFullCounting_label.text = priceFormatter.string(from: StoreObject.item_full_counting as NSNumber) ?? "0"
            cell.itemAccountCounting_label.text = priceFormatter.string(from: StoreObject.item_account_counting as NSNumber) ?? "0"
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhMyPageTC2", for: indexPath) as! WhMyPageTC
            cell.title_label.text = menus[indexPath.section-1].content[indexPath.row]
            cell.title_bottom.constant = menus[indexPath.section-1].content.count-1 == indexPath.row ? 10 : 0
            return cell
        }
    }
    
    @objc func select_v(_ sender: UITapGestureRecognizer) {
        
        guard let sender = sender.view else { return }
        switch sender.tag {
        case 0:
            break
        case 1:
            break
        case 2:
            break
        case 3:
            let segue = storyboard?.instantiateViewController(withIdentifier: "WhGoodsVC") as! WhGoodsVC
            segue.indexpath_row = 0
            navigationController?.pushViewController(segue, animated: true)
        case 4:
            let segue = storyboard?.instantiateViewController(withIdentifier: "WhGoodsVC") as! WhGoodsVC
            segue.indexpath_row = 1
            navigationController?.pushViewController(segue, animated: true)
        case 5:
            segueViewController(identifier: "MPayVC")
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section != 0, segues[indexPath.section-1].1[indexPath.row] != "" {
            segueViewController(identifier: segues[indexPath.section-1].1[indexPath.row])
        }
    }
}

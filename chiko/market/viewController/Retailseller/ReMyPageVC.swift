//
//  ReMyPageVC.swift
//  market
//
//  Created by 장 제현 on 11/13/23.
//

/// 번역완료

import UIKit

class ReMyPageTC: UITableViewCell {
    
    @IBOutlet var labels: [UILabel]!
    
    @IBOutlet weak var mPay_view: UIView!
    @IBOutlet weak var mPay_label: UILabel!
    
    @IBOutlet weak var member_v: UIView!
    @IBOutlet weak var memberName_label: UILabel!
    @IBOutlet weak var memberGrade_label: UILabel!
    @IBOutlet weak var storeName_label: UILabel!
    
    @IBOutlet weak var order_view: UIView!
    @IBOutlet weak var basket_view: UIView!
    @IBOutlet weak var basket_noticeView: UIView!
    @IBOutlet weak var scrap_view: UIView!
    @IBOutlet weak var setting_view: UIView!
    @IBOutlet weak var enquiryReceipt_view: UIView!
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var title_bottom: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labels.forEach { label in label.text = translation(label.text!) }
    }
}

class ReMyPageVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    let menus: [(title: String, content: [String])] = [
        (title: "매장관리", content: ["직원관리"]),
        (title: "정보관리", content: ["사업자수정", "내정보수정", "배송지관리"]),
        (title: "고객센터", content: ["자주묻는질문"]),
    ]
    let segues: [(String, [String])] = [
        ("매장관리", ["EmployeeVC"]),
        ("정보관리", ["StoreVC", "MemberVC", "ReDeliveryVC"]),
        ("고객센터", [""]),
    ]
    
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var storeMain_img: UIImageView!
    @IBOutlet weak var choiceStore_btn: UIButton!
    @IBOutlet weak var noticeDot_v: UIView!
    @IBOutlet weak var notice_btn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logout_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReMyPageVCdelegate = self
        
        buttons.forEach { btn in btn.setTitle(translation(btn.title(for: .normal)), for: .normal) }
        
//        setKingfisher(imageView: storeMain_img, imageUrl: StoreObject.store_mainphoto_img, cornerRadius: 15)
//        choiceStore_btn.addTarget(self, action: #selector(choiceStore_btn(_:)), for: .touchUpInside)
        noticeDot_v.isHidden = notice_read
        notice_btn.addTarget(self, action: #selector(notice_btn(_:)), for: .touchUpInside)
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = .zero }
        tableView.delegate = self; tableView.dataSource = self
        
        logout_btn.addTarget(self, action: #selector(logout_btn(_:)), for: .touchUpInside)
    }
    
    @objc func choiceStore_btn(_ sender: UIButton) {
        segueViewController(identifier: "ChoiceStoreVC")
    }
    
    @objc func notice_btn(_ sender: UIButton) {
        segueViewController(identifier: "NoticeVC")
    }
    
    @objc func logout_btn(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "", message: translation("로그아웃 하시겠습니까?"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: translation("로그아웃"), style: .destructive, handler: { _ in
            self.segueViewController(identifier: "SignInVC")
        }))
        alert.addAction(UIAlertAction(title: translation("취소"), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
        
        NoticeVCdelegate = nil
        ChoiceStoreVCdelegate = nil
        ReBasketVCdelegate = nil
        ScrapVCdelegate = nil
        
        tableView.reloadData()
    }
}

extension ReMyPageVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return menus.count+1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReMyPageTCT") as! ReMyPageTC
        cell.title_label.text = translation(menus[section-1].title)
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
            
            cell.basket_noticeView.isHidden = (ReBasketArray.count == 0)
            ([cell.mPay_view, cell.member_v, cell.order_view, cell.basket_view, cell.scrap_view, cell.setting_view, cell.enquiryReceipt_view] as [UIView]).enumerated().forEach { i, view in
                view.tag = i; view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(segue_view(_:))))
            }
            cell.mPay_label.text = priceFormatter.string(from: StoreObject.store_cash as NSNumber) ?? "0"
            
            cell.memberName_label.text = MemberObject.member_name
            cell.memberGrade_label.text = MemberObject.member_grade
            cell.storeName_label.text = StoreObject.store_name
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReMyPageTC1", for: indexPath) as! ReMyPageTC
            cell.title_label.text = translation(menus[indexPath.section-1].content[indexPath.row])
            cell.title_bottom.constant = menus[indexPath.section-1].content.count-1 == indexPath.row ? 10 : 0
            return cell
        }
    }
    
    @objc func segue_view(_ sender: UITapGestureRecognizer) {
        
        guard let sender = sender.view else { return }
        
        switch sender.tag {
        case 0: segueViewController(identifier: "MPayVC")
        case 1: segueViewController(identifier: "MemberVC")
        case 2: segueViewController(identifier: "ReOrderVC")
        case 3: segueViewController(identifier: "ReBasketVC")
        case 4: segueViewController(identifier: "ScrapVC")
        case 5: segueViewController(identifier: "SettingVC")
        case 6: segueViewController(identifier: "ReEnquiryReceiptVC")
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section != 0, segues[indexPath.section-1].1[indexPath.row] != "" {
            segueViewController(identifier: segues[indexPath.section-1].1[indexPath.row])
        }
        if indexPath.section != 0, segues[indexPath.section-1].0 == "고객센터" {
            alert(title: "", message: "시스템 점검 중입니다.", style: .alert, time: 1)
        }
    }
}

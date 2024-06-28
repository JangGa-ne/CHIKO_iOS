//
//  MaHome.swift
//  market
//
//  Created by Busan Dynamic on 6/27/24.
//

import UIKit
import FirebaseFirestore

class MaHomeCC: UICollectionViewCell {
    
    @IBOutlet weak var id_label: UILabel!
    @IBOutlet weak var logout_btn: UIButton!
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var content_label: UILabel!
    @IBOutlet weak var content_tf: UITextField!
}

class MaHomeVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical; layout.minimumLineSpacing = 20; layout.minimumInteritemSpacing = 20
        collectionView.setCollectionViewLayout(layout, animated: true, completion: nil)
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 20, right: 20)
        collectionView.delegate = self; collectionView.dataSource = self
        
        AdminListener = Firestore.firestore().collection("admin_data").document("price_info").addSnapshotListener { docRef, error in
            
            let dict: [String: Any] = docRef?.data() ?? [:]
            PaymentObject = setPayment(paymentDict: dict)
            
            self.collectionView.reloadSections(IndexSet(integer: 1))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

extension MaHomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 2
        } else if section == 2 {
            return 1
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaHomeCC1", for: indexPath) as! MaHomeCC
            cell.id_label.text = MemberObject.member_id
            cell.logout_btn.addTarget(self, action: #selector(logout_btn(_:)), for: .touchUpInside)
            return cell
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaHomeCC2", for: indexPath) as! MaHomeCC
            if indexPath.row == 0 {
                cell.title_label.text = "오늘의 환율"
                cell.content_label.text = priceFormatter.string(from: PaymentObject.exchange_rate as NSNumber) ?? "0.0"
            } else if indexPath.row == 1 {
                cell.title_label.text = "기본 물류비(kg)"
                cell.content_label.text = priceFormatter.string(from: PaymentObject.dpcostperkg as NSNumber) ?? "0.0"
            }
            return cell
        } else if indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaHomeCC3", for: indexPath) as! MaHomeCC
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    @objc func logout_btn(_ sender: UIButton) {
        segueViewController(identifier: "SignInVC")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
        } else if indexPath.section == 2 {
            segueViewController(identifier: "MaStoreVC")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            return CGSize(width: UIScreen.main.bounds.width-40, height: 70)
        } else if indexPath.section == 1 {
            return CGSize(width: UIScreen.main.bounds.width/2-30, height: UIScreen.main.bounds.width/2-80)
        } else if indexPath.section == 2 {
            return CGSize(width: UIScreen.main.bounds.width-40, height: 90)
        } else {
            return .zero
        }
    }
}

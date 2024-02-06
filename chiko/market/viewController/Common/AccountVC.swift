//
//  AccountVC.swift
//  market
//
//  Created by Busan Dynamic on 12/12/23.
//

import UIKit

class AccountVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var upload_passbook_img: [(file_name: String, file_data: Data, file_size: Int)] = []
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var accountBank_view: UIView!
    @IBOutlet weak var accountBank_tf: UITextField!
    @IBOutlet weak var checkAccountBank_img: UIImageView!
    @IBOutlet weak var accountName_tf: UITextField!
    @IBOutlet weak var checkAccountName_img: UIImageView!
    @IBOutlet weak var accountNum_tf: UITextField!
    @IBOutlet weak var checkaAccountNum_img: UIImageView!
    @IBOutlet weak var noticeAccountNum_label: UILabel!
    
    @IBOutlet weak var passbook_view: UIView!
    @IBOutlet weak var passbook_img: UIImageView!
    @IBOutlet weak var checkpassbook_img: UIImageView!
    
    @IBOutlet weak var edit_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AccountVCdelegate = self
        
        let account_bank = StoreObject.account["account_bank"] as? String ?? ""
        let account_name = StoreObject.account["account_name"] as? String ?? ""
        let account_num = StoreObject.account["account_num"] as? String ?? ""
        
        accountBank_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(accountBank_view(_:))))
        ([accountBank_tf, accountName_tf, accountNum_tf] as [UITextField]).enumerated().forEach { i, tf in
            tf.text = [account_bank, account_name, account_num][i]
            tf.tag = i
            tf.addTarget(self, action: #selector(edit_tf(_:)), for: .editingChanged)
            tf.addTarget(self, action: #selector(end_tf(_:)), for: .editingDidEnd)
            DispatchQueue.main.async { self.edit_tf(tf) }
        }
        accountBank_tf.isEnabled = false
        ([checkAccountBank_img, checkAccountName_img, checkaAccountNum_img, checkpassbook_img] as [UIImageView]).forEach { img in
            img.isHidden = true
        }
        noticeAccountNum_label.isHidden = true
        
        imageUrlStringToData(from: StoreObject.passbook_img) { imgData in
            DispatchQueue.main.async {
                self.upload_passbook_img.append((file_name: "passbook_img", file_data: imgData ?? Data(), file_size: imgData?.count ?? 0))
                if let imgData = UIImage(data: imgData ?? Data()) {
                    self.passbook_img.image = resizeImage(imgData, targetSize: self.passbook_img.frame.size)
                    self.checkpassbook_img.isHidden = false
                } else {
                    self.passbook_img.image = UIImage()
                    self.checkpassbook_img.isHidden = true
                }
            }
        }
        
        passbook_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(passbook_view(_:))))
    }
    
    @objc func accountBank_view(_ sender: UITapGestureRecognizer) {
        /// hidden keyboard
        view.endEditing(true)
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "BankListVC") as! BankListVC
        segue.member_type = MemberObject.member_type
        presentPanModal(segue)
    }
    
    @objc func edit_tf(_ sender: UITextField) {
        
        let check: UIImageView = [checkAccountBank_img, checkAccountName_img, checkaAccountNum_img][sender.tag]
        let notice: UILabel = [UILabel(), UILabel(), noticeAccountNum_label][sender.tag]
        // init
        check.isHidden = true
        notice.isHidden = true
        
        switch sender.tag {
        case 0:
            if sender.text!.count > 0 { check.isHidden = false }
        case 1:
            if sender.text!.count > 0 { check.isHidden = false }
        case 2:
            if sender.text!.count >= 10 && sender.text!.count <= 14 { check.isHidden = false }
        default:
            break
        }
    }
    
    @objc func end_tf(_ sender: UITextField) {
        
        let check: UIImageView = [checkAccountBank_img, checkAccountName_img, checkaAccountNum_img][sender.tag]
        let notice: UILabel = [UILabel(), UILabel(), noticeAccountNum_label][sender.tag]
        
        notice.isHidden = !check.isHidden
    }
    
    @objc func passbook_view(_ sender: UITapGestureRecognizer) {
        /// hidden keyboard
        view.endEditing(true)
        
        setPhoto(max: 1) { photo in
            self.upload_passbook_img = photo
            self.passbook_img.image = UIImage(data: photo[0].file_data)
            self.checkpassbook_img.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

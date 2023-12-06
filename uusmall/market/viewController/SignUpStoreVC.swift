//
//  SignUpStoreVC.swift
//  market
//
//  Created by Busan Dynamic on 2023/10/18.
//

import UIKit
import PanModal

class SignUpStoreVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var StoreObject: StoreData = StoreData()
    
    @IBAction func back_btn(_ sender: UIButton) { view.endEditing(true); navigationController?.popViewController(animated: true) }
    @IBOutlet weak var navi_label: UILabel!
    @IBOutlet weak var navi_lineView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    // store type
    @IBOutlet weak var storeType_sv: UIStackView!
    @IBOutlet weak var online_btn: UIButton!
    @IBOutlet weak var offline_btn: UIButton!
    @IBOutlet weak var onoffline_btn: UIButton!
    @IBOutlet weak var storeType_lineView: UIView!
    
    @IBOutlet weak var businessRegNum_sv: UIStackView!
    @IBOutlet weak var businessRegNum_tf: UITextField!
    @IBOutlet weak var checkBusinessRegNum_img: UIImageView!
    @IBOutlet weak var noticeBusinessRegNum_label: UILabel!
    @IBOutlet weak var storeNameChi_tf: UITextField!
    @IBOutlet weak var checkStoreNameChi_img: UIImageView!
    @IBOutlet weak var noticeStoreNameChi_label: UILabel!
    @IBOutlet weak var storeNameEng_tf: UITextField!
    @IBOutlet weak var checkStoreNameEng_img: UIImageView!
    @IBOutlet weak var noticeStoreNameEng_label: UILabel!
    @IBOutlet weak var storeTel_tf: UITextField!
    @IBOutlet weak var checkStoreTel_img: UIImageView!
    @IBOutlet weak var noticeStoreTel_label: UILabel!
    @IBOutlet weak var storeAddress_sv: UIStackView!
    @IBOutlet weak var storeAddressStreet_tf: UITextField!
    @IBOutlet weak var checkStoreAddressStreet_img: UIImageView!
    @IBOutlet weak var storeAddressDetail_tf: UITextField!
    @IBOutlet weak var checkStoreAddressDetail_img: UIImageView!
    @IBOutlet weak var storeAddressZipCode_tf: UITextField!
    @IBOutlet weak var checkStoreAddressZipCode_img: UIImageView!
    @IBOutlet weak var domainAddress_sv: UIStackView!
    @IBOutlet weak var domainAddress_tf: UITextField!
    @IBOutlet weak var checkDomainAddress_img: UIImageView!
    @IBOutlet weak var noticeDomainAddress_label: UILabel!
    @IBOutlet weak var bankName_view: UIView!
    @IBOutlet weak var bankName_tf: UITextField!
    @IBOutlet weak var checkBankName_img: UIImageView!
    @IBOutlet weak var depositorName_tf: UITextField!
    @IBOutlet weak var checkDepositorName_img: UIImageView!
    @IBOutlet weak var accountNum_tf: UITextField!
    @IBOutlet weak var checkAccountNum_img: UIImageView!
    @IBOutlet weak var noticeAccountNum_label: UILabel!
    
    @IBOutlet weak var storeMainPhoto_sv: UIStackView!
    @IBOutlet weak var storeMainPhoto_view: UIView!
    @IBOutlet weak var storeMainPhoto_img: UIImageView!
    @IBOutlet weak var checkStoreMainPhoto_img: UIImageView!
    @IBOutlet weak var passbook_sv: UIStackView!
    @IBOutlet weak var passbook_view: UIView!
    @IBOutlet weak var passbook_img: UIImageView!
    @IBOutlet weak var checkpassbook_img: UIImageView!
    @IBOutlet weak var businessReg_sv: UIStackView!
    @IBOutlet weak var businessReg_view: UIView!
    @IBOutlet weak var businessReg_img: UIImageView!
    @IBOutlet weak var checkBusinessReg_img: UIImageView!
    @IBOutlet weak var buildingContract_sv: UIStackView!
    @IBOutlet weak var buildingContract_view: UIView!
    @IBOutlet weak var buildingContract_img: UIImageView!
    @IBOutlet weak var checkBuildingContract_img: UIImageView!
    
    @IBOutlet weak var complete_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SignUpStoreVCdelegate = self
        
        setKeyboard()
        // init
        StoreObject.store_type = MemberObject_signup.member_type
        /// navi
        navi_label.alpha = 0.0
        navi_lineView.alpha = 0.0
        /// placeholder, delegate, edti, return next/done
        for (i, tf) in ([businessRegNum_tf, storeNameChi_tf, storeNameEng_tf, storeTel_tf, storeAddressStreet_tf, storeAddressDetail_tf, storeAddressZipCode_tf, domainAddress_tf, bankName_tf, depositorName_tf, accountNum_tf] as [UITextField]).enumerated() {
            tf.placeholder(text: ["", "", "", "-를 빼고 입력하세요.", "주소", "상세주소", "우편번호", "ex. https://www.example.com", "", "", "", ""][i], color: .black.withAlphaComponent(0.3))
            tf.delegate = self
            tf.tag = i
            tf.addTarget(self, action: #selector(changedEditStoreInfo_if(_:)), for: .editingChanged)
            tf.addTarget(self, action: #selector(endEditStoreInfo_if(_:)), for: .editingDidEnd)
            if tf != domainAddress_tf && tf != accountNum_tf { tf.returnKeyType = .next } else { tf.returnKeyType = .done }
        }
        /// check
        ([checkBusinessRegNum_img, checkStoreNameChi_img, checkStoreNameEng_img, checkStoreTel_img, checkStoreAddressStreet_img, checkStoreAddressDetail_img, checkStoreAddressZipCode_img, checkDomainAddress_img, checkBankName_img, checkDepositorName_img, checkAccountNum_img, checkStoreMainPhoto_img, checkpassbook_img, checkBusinessReg_img, checkBuildingContract_img] as [UIImageView]).forEach { img in
            img.isHidden = true
        }
        /// notice
        ([noticeBusinessRegNum_label, noticeStoreNameChi_label, noticeStoreNameEng_label, noticeStoreTel_label, noticeDomainAddress_label, noticeAccountNum_label] as [UILabel]).forEach { label in
            label.isHidden = true
        }
        
        scrollView.delegate = self
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scrollView(_:))))
        /// store type
        StoreObject.onoff_type = "online"
        for (i, btn) in ([online_btn, offline_btn, onoffline_btn] as [UIButton]).enumerated() {
            btn.tag = i; btn.addTarget(self, action: #selector(storeType_btn(_:)), for: .touchUpInside)
            if btn.tag == 0 { btn.isSelected = true } else { btn.isSelected = false }
        }
        if StoreObject.store_type == "retailseller" {
            businessRegNum_sv.isHidden = true
            storeAddress_sv.isHidden = true
            businessReg_sv.isHidden = true
            buildingContract_sv.isHidden = true
        } else if StoreObject.store_type == "wholesales" {
            storeType_sv.isHidden = true
            storeType_lineView.isHidden = true
            storeAddress_sv.isHidden = true
            domainAddress_sv.isHidden = true
        }
        /// bank info
        bankName_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bankName_view(_:))))
        bankName_tf.isEnabled = false
        /// submit document
        for (i, view) in ([storeMainPhoto_view, passbook_view, businessReg_view, buildingContract_view] as [UIView]).enumerated() {
            view.tag = i; view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(submitDocu_view(_:))))
        }
        /// back submit store
        complete_btn.addTarget(self, action: #selector(complete_btn(_:)), for: .touchUpInside)
    }
    
    @objc func changedEditStoreInfo_if(_ sender: UITextField) {
        
        let notice: [UILabel] = [noticeBusinessRegNum_label, noticeStoreNameChi_label, noticeStoreNameEng_label, noticeStoreTel_label, UILabel(), UILabel(), UILabel(), noticeDomainAddress_label,  UILabel(), UILabel(), noticeAccountNum_label]
        let check: [UIImageView] = [checkBusinessRegNum_img, checkStoreNameChi_img, checkStoreNameEng_img, checkStoreTel_img, checkStoreAddressStreet_img, checkStoreAddressDetail_img, checkStoreAddressZipCode_img, checkDomainAddress_img, checkBankName_img, checkDepositorName_img, checkAccountNum_img, checkStoreMainPhoto_img, checkpassbook_img, checkBusinessReg_img, checkBuildingContract_img]
        // init
        notice[sender.tag].isHidden = true
        check[sender.tag].isHidden = true
    }
    
    @objc func endEditStoreInfo_if(_ sender: UITextField) {
        
        var filterContains: String = ""
        let chineseRange = 0x4E00...0x9FFF
        
        let notice: [UILabel] = [noticeBusinessRegNum_label, noticeStoreNameChi_label, noticeStoreNameEng_label, noticeStoreTel_label, UILabel(), UILabel(), UILabel(), noticeDomainAddress_label,  UILabel(), UILabel(), noticeAccountNum_label]
        let check: [UIImageView] = [checkBusinessRegNum_img, checkStoreNameChi_img, checkStoreNameEng_img, checkStoreTel_img, checkStoreAddressStreet_img, checkStoreAddressDetail_img, checkStoreAddressZipCode_img, checkDomainAddress_img, checkBankName_img, checkDepositorName_img, checkAccountNum_img, checkStoreMainPhoto_img, checkpassbook_img, checkBusinessReg_img, checkBuildingContract_img]
        // init
        notice[sender.tag].isHidden = false
        check[sender.tag].isHidden = true
        
        switch sender {
        case businessRegNum_tf:
            if isChineseBusinessRegNumValid(sender.text!) {
                notice[sender.tag].isHidden = true
                check[sender.tag].isHidden = false
            }
            break
        case storeNameChi_tf:
            filterContains = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~`!@#$%^&*()-+="
            
            let allowedCharacters = NSMutableCharacterSet()
            allowedCharacters.formUnion(with: CharacterSet(charactersIn: filterContains))
            if let characterSetFromRange = NSCharacterSet(range: NSRange(location: chineseRange.lowerBound, length: chineseRange.upperBound-chineseRange.lowerBound+1)) as CharacterSet? {
                allowedCharacters.formUnion(with: characterSetFromRange)
            }
            if sender.text!.count > 0 && sender.text!.rangeOfCharacter(from: allowedCharacters.inverted) == nil {
                notice[sender.tag].isHidden = true
                check[sender.tag].isHidden = false
            }
            break
        case storeNameEng_tf:
            filterContains = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~`!@#$%^&*()-+="
            
            if sender.text!.count > 0 && sender.text!.rangeOfCharacter(from: CharacterSet(charactersIn: filterContains).inverted) == nil {
                notice[sender.tag].isHidden = true
                check[sender.tag].isHidden = false
            }
            break
        case storeTel_tf:
            if isChineseTelNumValid(sender.text!) {
                notice[sender.tag].isHidden = true
                check[sender.tag].isHidden = false
            }
            break
        case storeAddressStreet_tf:
            if sender.text!.count > 0 {
                notice[sender.tag].isHidden = true
                check[sender.tag].isHidden = false
            }
            break
        case storeAddressDetail_tf:
            if sender.text!.count > 0 {
                notice[sender.tag].isHidden = true
                check[sender.tag].isHidden = false
            }
            break
        case storeAddressZipCode_tf:
            if sender.text!.count > 0 {
                notice[sender.tag].isHidden = true
                check[sender.tag].isHidden = false
            }
            break
        case domainAddress_tf:
            if isUrlValid(sender.text!) {
                notice[sender.tag].isHidden = true
                check[sender.tag].isHidden = false
            }
            break
        case depositorName_tf:
            if sender.text!.count > 0 {
                notice[sender.tag].isHidden = true
                check[sender.tag].isHidden = false
            }
            break
        case accountNum_tf:
            if isChineseAccountNumValid(sender.text!) {
                notice[sender.tag].isHidden = true
                check[sender.tag].isHidden = false
            }
            break
        default:
            break
        }
    }
    
    @objc func storeType_btn(_ sender: UIButton) {
        /// hidden keyboard
        view.endEditing(true)
        
        if sender.tag == 0 {
            /// online
            StoreObject.onoff_type = "online"
            online_btn.isSelected = true; offline_btn.isSelected = false; onoffline_btn.isSelected = false
            online_btn.backgroundColor = .H_8CD26B; offline_btn.backgroundColor = .white; onoffline_btn.backgroundColor = .white
            storeAddress_sv.isHidden = true
            storeAddressStreet_tf.text?.removeAll(); storeAddressDetail_tf.text?.removeAll(); storeAddressZipCode_tf.text?.removeAll()
            checkStoreAddressStreet_img.isHidden = true; checkStoreAddressDetail_img.isHidden = true; checkStoreAddressZipCode_img.isHidden = true
            domainAddress_sv.isHidden = false
        } else if sender.tag == 1 {
            /// offline
            StoreObject.onoff_type = "offline"
            online_btn.isSelected = false; offline_btn.isSelected = true; onoffline_btn.isSelected = false
            online_btn.backgroundColor = .white; offline_btn.backgroundColor = .H_8CD26B; onoffline_btn.backgroundColor = .white
            storeAddress_sv.isHidden = false
            domainAddress_sv.isHidden = true
            domainAddress_tf.text?.removeAll()
            checkDomainAddress_img.isHidden = true
            noticeDomainAddress_label.isHidden = true
        } else if sender.tag == 2 {
            /// offline
            StoreObject.onoff_type = "onoffline"
            online_btn.isSelected = false; offline_btn.isSelected = false; onoffline_btn.isSelected = true
            online_btn.backgroundColor = .white; offline_btn.backgroundColor = .white; onoffline_btn.backgroundColor = .H_8CD26B
            storeAddress_sv.isHidden = false
            domainAddress_sv.isHidden = false
        }
    }
    
    @objc func bankName_view(_ sender: UITapGestureRecognizer) {
        /// hidden keyboard
        view.endEditing(true)
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ChineseBankListVC") as! ChineseBankListVC
        presentPanModal(segue)
    }
    
    @objc func submitDocu_view(_ sender: UITapGestureRecognizer) {
        /// hidden keyboard
        view.endEditing(true)
        
        guard let sender = sender.view else { return }
        setPhoto(max: 1) { photo in
            if sender.tag == 0 {
                self.StoreObject.upload_store_mainphoto_img = photo
                self.storeMainPhoto_img.image = UIImage(data: photo[0].file_data)
                self.checkStoreMainPhoto_img.isHidden = false
            } else if sender.tag == 1 {
                self.StoreObject.upload_passbook_img = photo
                self.passbook_img.image = UIImage(data: photo[0].file_data)
                self.checkpassbook_img.isHidden = false
            } else if sender.tag == 2 {
                self.StoreObject.upload_business_reg_img = photo
                self.businessReg_img.image = UIImage(data: photo[0].file_data)
                self.checkBusinessReg_img.isHidden = false
            } else if sender.tag == 3 {
                self.StoreObject.upload_building_contract_img = photo
                self.buildingContract_img.image = UIImage(data: photo[0].file_data)
                self.checkBuildingContract_img.isHidden = false
            }
        }
    }
    
    @objc func complete_btn(_ sender: UIButton) {
        /// hidden keyboard
        view.endEditing(true)
        
        var final_check: Bool = true
        var check_img: [UIImageView] = [checkStoreNameChi_img, checkStoreNameEng_img, checkStoreTel_img, checkBankName_img, checkDepositorName_img, checkAccountNum_img, checkStoreMainPhoto_img, checkpassbook_img]
        
        if StoreObject.store_type == "retailseller" {
            if StoreObject.onoff_type == "online" {
                check_img = check_img+[checkDomainAddress_img]
            } else if StoreObject.onoff_type == "offline" {
                check_img = check_img+[checkStoreAddressStreet_img]
            } else if StoreObject.onoff_type == "onoffline" {
                check_img = check_img+[checkStoreAddressStreet_img, checkDomainAddress_img]
            }
        } else if StoreObject.store_type == "wholesales" {
            check_img = check_img+[checkBusinessRegNum_img, checkBusinessReg_img, checkBuildingContract_img]
        }
        check_img.forEach { img in
            if img.isHidden { customAlert(message: "미입력된 항목이 있거나\n확인되지 않은 항목이 있습니다.", time: 1); final_check = false }
        }
        
        if !final_check { return }
        
        let alert = UIAlertController(title: "매장 등록", message: "기입한 내용이 맞는지 확인바랍니다.\n작성완료 후 수정이 불가하며, 신규작성해야 합니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            if let delegate = SignUpMemberVCdelegate {
                /// 데이터 삭제
                StoreObject_signup = StoreData()
                
                self.StoreObject.store_name = self.storeNameChi_tf.text!
                self.StoreObject.store_name_eng = self.storeNameEng_tf.text!
                self.StoreObject.store_tel = self.storeTel_tf.text!
                self.StoreObject.account = ["account_bank": self.bankName_tf.text!, "account_name": self.depositorName_tf.text!, "account_num": self.accountNum_tf.text!]
                if self.StoreObject.store_type == "retailseller" {
                    self.StoreObject.store_domain = self.domainAddress_tf.text!
                    self.StoreObject.store_address_street = self.storeAddressStreet_tf.text!
                    self.StoreObject.store_address_detail = self.storeAddressDetail_tf.text!
                    self.StoreObject.store_address_zipcode = self.storeAddressZipCode_tf.text!
                } else if self.StoreObject.store_type == "wholesales" {
                    self.StoreObject.business_reg_num = self.businessRegNum_tf.text!
                }
                StoreObject_signup = self.StoreObject
                delegate.new_label.isHidden = false
                delegate.registerSearchStoreName_label.text = "\(self.StoreObject.store_name)(\(self.StoreObject.store_name_eng))"
                delegate.registerSearchStore_btn.isSelected = true
                delegate.registerSearchStore_btn.backgroundColor = .H_8CD26B
            }
            self.dismiss(animated: true) { self.navigationController?.popViewController(animated: true) }
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
        
        ChineseBankListVCdelegate = nil
    }
}

extension SignUpStoreVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
    }
}

extension SignUpStoreVC {
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == businessRegNum_tf {
            storeNameChi_tf.becomeFirstResponder()
        } else if textField == storeNameChi_tf {
            storeNameEng_tf.becomeFirstResponder()
        }
        
        if StoreObject.store_type == "retailseller" {
            if StoreObject.onoff_type == "online" && textField == storeTel_tf {
                if textField == storeTel_tf {
                    domainAddress_tf.becomeFirstResponder()
                } else if textField == domainAddress_tf {
                    domainAddress_tf.resignFirstResponder()
                }
            } else if StoreObject.onoff_type == "offline" && textField == storeAddressZipCode_tf {
                storeAddressZipCode_tf.resignFirstResponder()
            } else if textField.returnKeyType == .done {
                textField.resignFirstResponder()
            } else if let nextTextField = view.viewWithTag(textField.tag+1) as? UITextField {
                nextTextField.becomeFirstResponder()
            }
        } else if StoreObject.store_type == "wholesales" {
            if textField == storeTel_tf {
                storeTel_tf.resignFirstResponder()
            } else if textField.returnKeyType == .done {
                textField.resignFirstResponder()
            } else if let nextTextField = view.viewWithTag(textField.tag+1) as? UITextField {
                nextTextField.becomeFirstResponder()
            }
        }
        return true
    }
}

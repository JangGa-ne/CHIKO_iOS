//
//  SignUpStoreVC.swift
//  market
//
//  Created by Busan Dynamic on 2023/10/18.
//

import UIKit
import PanModal

class SignUpStoreCC: UICollectionViewCell {
    
    @IBOutlet weak var item_img: UIImageView!
    @IBOutlet weak var itemRow_label: UILabel!
}

class SignUpStoreVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBAction func back_btn(_ sender: UIButton) { view.endEditing(true); navigationController?.popViewController(animated: true) }
    @IBOutlet weak var navi_label: UILabel!
    @IBOutlet weak var navi_lineView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    /// 쇼핑몰 종류
    @IBOutlet weak var storeType_sv: UIStackView!
    @IBOutlet weak var online_btn: UIButton!
    @IBOutlet weak var offline_btn: UIButton!
    @IBOutlet weak var onoffline_btn: UIButton!
    @IBOutlet weak var storeType_lineView: UIView!
    /// 사업자 등록번호
    @IBOutlet weak var businessRegNum_sv: UIStackView!
    @IBOutlet weak var businessRegNum_tf: UITextField!
    @IBOutlet weak var checkBusinessRegNum_img: UIImageView!
    @IBOutlet weak var noticeBusinessRegNum_label: UILabel!
    /// 매장명
    @IBOutlet weak var storeNameChi_tf: UITextField!
    @IBOutlet weak var checkStoreNameChi_img: UIImageView!
    @IBOutlet weak var noticeStoreNameChi_label: UILabel!
    /// 매장명 (영어)
    @IBOutlet weak var storeNameEng_tf: UITextField!
    @IBOutlet weak var checkStoreNameEng_img: UIImageView!
    @IBOutlet weak var noticeStoreNameEng_label: UILabel!
    /// 매장 전화번호
    @IBOutlet weak var storeTel_tf: UITextField!
    @IBOutlet weak var checkStoreTel_img: UIImageView!
    @IBOutlet weak var noticeStoreTel_label: UILabel!
    /// 매장 주소
    @IBOutlet weak var storeAddress_sv: UIStackView!
    @IBOutlet weak var storeAddressStreet_tf: UITextField!
    @IBOutlet weak var checkStoreAddressStreet_img: UIImageView!
    @IBOutlet weak var storeAddressDetail_tf: UITextField!
    @IBOutlet weak var checkStoreAddressDetail_img: UIImageView!
    @IBOutlet weak var storeAddressZipCode_tf: UITextField!
    @IBOutlet weak var checkStoreAddressZipCode_img: UIImageView!
    /// 건물/층/호수
    @IBOutlet weak var buildingAddressDetail_sv: UIStackView!
    @IBOutlet weak var buildingAddressDetail_tf: UITextField!
    @IBOutlet weak var buildingAddressDetail_btn: UIButton!
    /// 도메인 주소
    @IBOutlet weak var domainAddress_sv: UIStackView!
    @IBOutlet weak var domainAddress_tf: UITextField!
    @IBOutlet weak var checkDomainAddress_img: UIImageView!
    @IBOutlet weak var noticeDomainAddress_label: UILabel!
    /// 계좌 등록
    @IBOutlet weak var account_sv: UIStackView!
    @IBOutlet weak var accountBank_view: UIView!
    @IBOutlet weak var accountBank_tf: UITextField!
    @IBOutlet weak var checkAccountBank_img: UIImageView!
    @IBOutlet weak var depositorName_tf: UITextField!
    @IBOutlet weak var checkDepositorName_img: UIImageView!
    @IBOutlet weak var accountNum_tf: UITextField!
    @IBOutlet weak var checkAccountNum_img: UIImageView!
    @IBOutlet weak var noticeAccountNum_label: UILabel!
    /// Wechat 아이디
    @IBOutlet weak var wechatId_sv: UIStackView!
    @IBOutlet weak var wechatId_tf: UITextField!
    @IBOutlet weak var checkWechatId_img: UIImageView!
    // 증명 서류 제출
    /// 매장 대표사진
    @IBOutlet weak var storeMainPhoto_sv: UIStackView!
    @IBOutlet weak var storeMainPhoto_view: UIView!
    @IBOutlet weak var storeMainPhoto_img: UIImageView!
    @IBOutlet weak var checkStoreMainPhoto_img: UIImageView!
    /// 통장 사본
    @IBOutlet weak var passbook_sv: UIStackView!
    @IBOutlet weak var passbook_view: UIView!
    @IBOutlet weak var passbook_img: UIImageView!
    @IBOutlet weak var checkpassbook_img: UIImageView!
    /// 사업자 등록증
    @IBOutlet weak var businessReg_sv: UIStackView!
    @IBOutlet weak var businessReg_view: UIView!
    @IBOutlet weak var businessReg_img: UIImageView!
    @IBOutlet weak var checkBusinessReg_img: UIImageView!
    /// 건물 계약서
    @IBOutlet weak var buildingContract_sv: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var complete_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SignUpStoreVCdelegate = self
        
        setKeyboard()
        // init
        StoreObject_signup.store_type = MemberObject_signup.member_type
        /// navi
        navi_label.alpha = 0.0
        navi_lineView.alpha = 0.0
        /// placeholder, delegate, edti, return next/done
        ([businessRegNum_tf, storeNameChi_tf, storeNameEng_tf, storeTel_tf, storeAddressStreet_tf, storeAddressDetail_tf, storeAddressZipCode_tf, domainAddress_tf, accountBank_tf, depositorName_tf, accountNum_tf, wechatId_tf] as [UITextField]).enumerated().forEach { i, tf in
            tf.placeholder(text: ["", "", "", "-를 빼고 입력하세요.", "주소", "상세주소", "우편번호", "ex. www.example.com", "은행명을 입력하세요.", "예금주명을 입력하세요.", "-를 빼고 입력하세요.", "", ""][i], color: .black.withAlphaComponent(0.3))
            tf.delegate = self
            tf.tag = i
            tf.addTarget(self, action: #selector(changedEditStoreInfo_if(_:)), for: .editingChanged)
            tf.addTarget(self, action: #selector(endEditStoreInfo_if(_:)), for: .editingDidEnd)
            if tf != domainAddress_tf && tf != accountNum_tf { tf.returnKeyType = .next } else { tf.returnKeyType = .done }
        }
        /// check
        ([checkBusinessRegNum_img, checkStoreNameChi_img, checkStoreNameEng_img, checkStoreTel_img, checkStoreAddressStreet_img, checkStoreAddressDetail_img, checkStoreAddressZipCode_img, checkDomainAddress_img, checkAccountBank_img, checkDepositorName_img, checkAccountNum_img, checkWechatId_img, checkStoreMainPhoto_img, checkpassbook_img, checkBusinessReg_img] as [UIImageView]).forEach { img in
            img.isHidden = true
        }
        /// notice
        ([noticeBusinessRegNum_label, noticeStoreNameChi_label, noticeStoreNameEng_label, noticeStoreTel_label, noticeDomainAddress_label, noticeAccountNum_label] as [UILabel]).forEach { label in
            label.isHidden = true
        }
        
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scrollView(_:))))
        /// store type
        StoreObject_signup.onoff_type = "online"
        ([online_btn, offline_btn, onoffline_btn] as [UIButton]).enumerated().forEach { i, btn in
            btn.tag = i; btn.addTarget(self, action: #selector(storeType_btn(_:)), for: .touchUpInside)
            if btn.tag == 0 { btn.isSelected = true } else { btn.isSelected = false }
        }
        if StoreObject_signup.store_type == "retailseller" {
            businessRegNum_sv.isHidden = true
            storeAddress_sv.isHidden = true
            buildingAddressDetail_sv.isHidden = true
            account_sv.isHidden = true
            passbook_sv.isHidden = true
            businessReg_sv.isHidden = true
            buildingContract_sv.isHidden = true
        } else if StoreObject_signup.store_type == "wholesales" {
            storeType_sv.isHidden = true
            storeType_lineView.isHidden = true
            storeAddress_sv.isHidden = true
            buildingAddressDetail_sv.isHidden = false
            domainAddress_sv.isHidden = true
            wechatId_sv.isHidden = true
        }
        /// building address detail
        buildingAddressDetail_tf.isEnabled = false
        buildingAddressDetail_btn.addTarget(self, action: #selector(buildingAddressDetail_btn(_:)), for: .touchUpInside)
        /// bank info
        accountBank_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(accountBank_view(_:))))
        accountBank_tf.isEnabled = false
        /// submit document
        ([storeMainPhoto_view, passbook_view, businessReg_view] as [UIView]).enumerated().forEach { i, view in
            view.tag = i; view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(submitDocu_view(_:))))
        }
        /// building contract
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        collectionView.setCollectionViewLayout(layout, animated: true, completion: nil)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 10)
        collectionView.delegate = self; collectionView.dataSource = self
        /// back submit store
        complete_btn.addTarget(self, action: #selector(complete_btn(_:)), for: .touchUpInside)
    }
    
    @objc func changedEditStoreInfo_if(_ sender: UITextField) {
        
        var filterContains: String = ""
        let member_type = MemberObject_signup.member_type
        let chineseRange = 0x4E00...0x9FFF
        let koreanRange = 0xAC00...0xD7AF
        
        let check: UIImageView = [checkBusinessRegNum_img, checkStoreNameChi_img, checkStoreNameEng_img, checkStoreTel_img, checkStoreAddressStreet_img, checkStoreAddressDetail_img, checkStoreAddressZipCode_img, checkDomainAddress_img, checkAccountBank_img, checkDepositorName_img, checkAccountNum_img, checkWechatId_img, checkStoreMainPhoto_img, checkpassbook_img, checkBusinessReg_img][sender.tag]
        let notice: UILabel = [noticeBusinessRegNum_label, noticeStoreNameChi_label, noticeStoreNameEng_label, noticeStoreTel_label, UILabel(), UILabel(), UILabel(), noticeDomainAddress_label, UILabel(), UILabel(), noticeAccountNum_label, UILabel()][sender.tag]
        // init
        check.isHidden = true
        notice.isHidden = true
        
        switch sender {
        case businessRegNum_tf:
//            if isChineseBusinessRegNumValid(sender.text!) { check.isHidden = false }
            if sender.text!.count == 10 { check.isHidden = false }
        case storeNameChi_tf:
            filterContains = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~`!@#$%^&*()-+="
            
            let allowedCharacters = NSMutableCharacterSet()
            allowedCharacters.formUnion(with: CharacterSet(charactersIn: filterContains))
            if let characterSetFromRange = NSCharacterSet(range: NSRange(location: chineseRange.lowerBound, length: chineseRange.upperBound-chineseRange.lowerBound+1)) as CharacterSet? {
                allowedCharacters.formUnion(with: characterSetFromRange)
            }
            if let characterSetFromRange = NSCharacterSet(range: NSRange(location: koreanRange.lowerBound, length: koreanRange.upperBound-koreanRange.lowerBound+1)) as CharacterSet? {
                allowedCharacters.formUnion(with: characterSetFromRange)
            }
            
            if sender.text!.count > 0 && sender.text!.rangeOfCharacter(from: allowedCharacters.inverted) == nil { check.isHidden = false }
        case storeNameEng_tf:
            filterContains = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~`!@#$%^&*()-+="
            
            if sender.text!.count > 0 && sender.text!.rangeOfCharacter(from: CharacterSet(charactersIn: filterContains).inverted) == nil { check.isHidden = false }
        case storeTel_tf:
//            if isChineseTelNumValid(sender.text!) { check.isHidden = false }
            if StoreObject_signup.store_type == "retailseller" {
                check.isHidden = !(sender.text!.count > 0)
            } else if StoreObject_signup.store_type == "wholesales" {
                check.isHidden = !(sender.text!.count >= 8 && sender.text!.count <= 12)
            }
        case storeAddressStreet_tf:
            if sender.text!.count > 0 { check.isHidden = false }
        case storeAddressDetail_tf:
            if sender.text!.count > 0 { check.isHidden = false }
        case storeAddressZipCode_tf:
            if sender.text!.count > 0 { check.isHidden = false }
        case domainAddress_tf:
            if isUrlValid(sender.text!) { check.isHidden = false }
        case depositorName_tf:
            if sender.text!.count > 0 { check.isHidden = false }
        case accountNum_tf:
            if member_type == "retailseller" {
                if isChineseAccountNumValid(sender.text!) { check.isHidden = false }
            } else if member_type == "wholesales" {
                if sender.text!.count >= 10 && sender.text!.count <= 14 { check.isHidden = false }
            }
        case wechatId_tf:
            if sender.text!.count > 0 { check.isHidden = false }
        default:
            break
        }
    }
    
    @objc func endEditStoreInfo_if(_ sender: UITextField) {
        
        let check: UIImageView = [checkBusinessRegNum_img, checkStoreNameChi_img, checkStoreNameEng_img, checkStoreTel_img, checkStoreAddressStreet_img, checkStoreAddressDetail_img, checkStoreAddressZipCode_img, checkDomainAddress_img, checkAccountBank_img, checkDepositorName_img, checkAccountNum_img, checkWechatId_img, checkStoreMainPhoto_img, checkpassbook_img, checkBusinessReg_img][sender.tag]
        let notice: UILabel = [noticeBusinessRegNum_label, noticeStoreNameChi_label, noticeStoreNameEng_label, noticeStoreTel_label, UILabel(), UILabel(), UILabel(), noticeDomainAddress_label, UILabel(), UILabel(), noticeAccountNum_label, UILabel()][sender.tag]
        
        notice.isHidden = !check.isHidden
    }
    
    @objc func storeType_btn(_ sender: UIButton) {
        /// hidden keyboard
        view.endEditing(true)
        
        if sender.tag == 0 {
            /// online
            StoreObject_signup.onoff_type = "online"
            online_btn.isSelected = true; offline_btn.isSelected = false; onoffline_btn.isSelected = false
            online_btn.backgroundColor = .H_8CD26B; offline_btn.backgroundColor = .white; onoffline_btn.backgroundColor = .white
            storeAddress_sv.isHidden = true
            storeAddressStreet_tf.text?.removeAll(); storeAddressDetail_tf.text?.removeAll(); storeAddressZipCode_tf.text?.removeAll()
            checkStoreAddressStreet_img.isHidden = true; checkStoreAddressDetail_img.isHidden = true; checkStoreAddressZipCode_img.isHidden = true
            domainAddress_sv.isHidden = false
        } else if sender.tag == 1 {
            /// offline
            StoreObject_signup.onoff_type = "offline"
            online_btn.isSelected = false; offline_btn.isSelected = true; onoffline_btn.isSelected = false
            online_btn.backgroundColor = .white; offline_btn.backgroundColor = .H_8CD26B; onoffline_btn.backgroundColor = .white
            storeAddress_sv.isHidden = false
            domainAddress_sv.isHidden = true
            domainAddress_tf.text?.removeAll()
            checkDomainAddress_img.isHidden = true
            noticeDomainAddress_label.isHidden = true
        } else if sender.tag == 2 {
            /// offline
            StoreObject_signup.onoff_type = "onoffline"
            online_btn.isSelected = false; offline_btn.isSelected = false; onoffline_btn.isSelected = true
            online_btn.backgroundColor = .white; offline_btn.backgroundColor = .white; onoffline_btn.backgroundColor = .H_8CD26B
            storeAddress_sv.isHidden = false
            domainAddress_sv.isHidden = false
        }
    }
    
    @objc func buildingAddressDetail_btn(_ sender: UIButton) {
        segueViewController(identifier: "BuildingListVC")
    }
    
    @objc func accountBank_view(_ sender: UITapGestureRecognizer) {
        /// hidden keyboard
        view.endEditing(true)
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "BankListVC") as! BankListVC
        segue.member_type = MemberObject_signup.member_type
        presentPanModal(segue)
    }
    
    @objc func submitDocu_view(_ sender: UITapGestureRecognizer) {
        /// hidden keyboard
        view.endEditing(true)
        
        guard let sender = sender.view else { return }
        setPhoto(max: 1) { photo in
            if sender.tag == 0 {
                StoreObject_signup.upload_store_mainphoto_img = photo
                self.storeMainPhoto_img.image = UIImage(data: photo[0].file_data)
                self.checkStoreMainPhoto_img.isHidden = false
            } else if sender.tag == 1 {
                StoreObject_signup.upload_passbook_img = photo
                self.passbook_img.image = UIImage(data: photo[0].file_data)
                self.checkpassbook_img.isHidden = false
            } else if sender.tag == 2 {
                StoreObject_signup.upload_business_reg_img = photo
                self.businessReg_img.image = UIImage(data: photo[0].file_data)
                self.checkBusinessReg_img.isHidden = false
            }
        }
    }
    
    @objc func complete_btn(_ sender: UIButton) {
        /// hidden keyboard
        view.endEditing(true)
        
        var final_check: Bool = true
        var check_img: [UIImageView] = [checkStoreNameChi_img, checkStoreNameEng_img, checkStoreTel_img]
        
        if StoreObject_signup.store_type == "retailseller" {
            if StoreObject_signup.onoff_type == "online" {
                check_img += [checkDomainAddress_img]
            } else if StoreObject_signup.onoff_type == "offline" {
                check_img += [checkStoreAddressStreet_img]
            } else if StoreObject_signup.onoff_type == "onoffline" {
                check_img += [checkStoreAddressStreet_img, checkDomainAddress_img]
            }
            check_img += [checkWechatId_img]
        } else if StoreObject_signup.store_type == "wholesales" {
            check_img += [checkBusinessRegNum_img, checkAccountBank_img, checkDepositorName_img, checkAccountNum_img, checkBusinessReg_img, checkStoreMainPhoto_img, checkpassbook_img]
        }
        check_img.forEach { img in
            if img.isHidden {
                customAlert(message: "미입력된 항목이 있거나\n확인되지 않은 항목이 있습니다.", time: 1); final_check = false
            }
        }
        if StoreObject_signup.store_type == "wholesales" && !buildingAddressDetail_btn.isSelected {
            customAlert(message: "미입력된 항목이 있거나\n확인되지 않은 항목이 있습니다.", time: 1); final_check = false
        }
        
        if !final_check { return }
        
        let alert = UIAlertController(title: "매장 등록", message: "기입한 내용이 맞는지 확인바랍니다.\n작성완료 후 수정이 불가하며, 신규작성해야 합니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            if let delegate = SignUpMemberVCdelegate {
                StoreObject_signup.store_name = self.storeNameChi_tf.text!
                StoreObject_signup.store_name_eng = self.storeNameEng_tf.text!
                StoreObject_signup.store_tel = self.storeTel_tf.text!
                StoreObject_signup.account = ["account_bank": self.accountBank_tf.text!, "account_name": self.depositorName_tf.text!, "account_num": self.accountNum_tf.text!]
                if StoreObject_signup.store_type == "retailseller" {
                    StoreObject_signup.store_domain = self.domainAddress_tf.text!
                    StoreObject_signup.store_address_street = self.storeAddressStreet_tf.text!
                    StoreObject_signup.store_address_detail = self.storeAddressDetail_tf.text!
                    StoreObject_signup.store_address_zipcode = self.storeAddressZipCode_tf.text!
                    StoreObject_signup.wechat_id = self.wechatId_tf.text!
                } else if StoreObject_signup.store_type == "wholesales" {
                    StoreObject_signup.summary_address = self.buildingAddressDetail_tf.text!
                    StoreObject_signup.business_reg_num = self.businessRegNum_tf.text!
                }
                delegate.new_label.isHidden = false
                delegate.registerSearchStoreName_label.text = "\(StoreObject_signup.store_name)(\(StoreObject_signup.store_name_eng))"
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
        
        BuildingListVCdelegate = nil
        BankListVCdelegate = nil
    }
}

extension SignUpStoreVC {
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == businessRegNum_tf {
            storeNameChi_tf.becomeFirstResponder()
        } else if textField == storeNameChi_tf {
            storeNameEng_tf.becomeFirstResponder()
        }
        
        if StoreObject_signup.store_type == "retailseller" {
            if StoreObject_signup.onoff_type == "online" && textField == storeTel_tf {
                if textField == storeTel_tf {
                    domainAddress_tf.becomeFirstResponder()
                } else if textField == domainAddress_tf {
                    domainAddress_tf.resignFirstResponder()
                }
            } else if StoreObject_signup.onoff_type == "offline" && textField == storeAddressZipCode_tf {
                storeAddressZipCode_tf.resignFirstResponder()
            } else if textField.returnKeyType == .done {
                textField.resignFirstResponder()
            } else if let nextTextField = view.viewWithTag(textField.tag+1) as? UITextField {
                nextTextField.becomeFirstResponder()
            }
        } else if StoreObject_signup.store_type == "wholesales" {
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

extension SignUpStoreVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0, StoreObject_signup.upload_building_contract_imgs.count < 50 {
            return 1
        } else if section == 1, StoreObject_signup.upload_building_contract_imgs.count > 0 {
            return StoreObject_signup.upload_building_contract_imgs.count
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            let data = StoreObject_signup.upload_building_contract_imgs[indexPath.row]
            guard let cell = cell as? SignUpStoreCC else { return }
            
            cell.item_img.image = UIImage(data: data.file_data)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SignUpStoreCC0", for: indexPath) as! SignUpStoreCC
            cell.tag = -1; cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectItemAt(_:))))
            return cell
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SignUpStoreCC1", for: indexPath) as! SignUpStoreCC
            cell.tag = indexPath.row; cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectItemAt(_:))))
            cell.itemRow_label.text = "  "+String(format: "%02d", indexPath.row+1)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
    @objc func didSelectItemAt(_ sender: UITapGestureRecognizer) {
        
        view.endEditing(true)
        
        guard let sender = sender.view else { return }
        
        if sender.tag == -1 {
            setPhoto(max: 50-StoreObject_signup.upload_building_contract_imgs.count) { photos in
                photos.forEach { photo in
                    StoreObject_signup.upload_building_contract_imgs.append(photo)
                    self.collectionView.reloadData()
                }
            }
        } else {
            StoreObject_signup.upload_building_contract_imgs.remove(at: sender.tag)
            collectionView.reloadData()
        }
    }
}

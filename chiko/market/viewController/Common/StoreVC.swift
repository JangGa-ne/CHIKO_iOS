//
//  StoreVC.swift
//  market
//
//  Created by Busan Dynamic on 12/12/23.
//

import UIKit

class StoreVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
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
    
    @IBOutlet weak var storeMainPhoto_sv: UIStackView!
    @IBOutlet weak var storeMainPhoto_view: UIView!
    @IBOutlet weak var storeMainPhoto_img: UIImageView!
    @IBOutlet weak var checkStoreMainPhoto_img: UIImageView!
    @IBOutlet weak var businessReg_sv: UIStackView!
    @IBOutlet weak var businessReg_view: UIView!
    @IBOutlet weak var businessReg_img: UIImageView!
    @IBOutlet weak var checkBusinessReg_img: UIImageView!
    
    @IBOutlet weak var edit_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let data = StoreObject
        /// placeholder, delegate, edti, return next/done
        ([businessRegNum_tf, storeNameChi_tf, storeNameEng_tf, storeTel_tf, storeAddressStreet_tf, storeAddressDetail_tf, storeAddressZipCode_tf] as [UITextField]).enumerated().forEach { i, tf in
            tf.placeholder(text: ["", "", "", "-를 빼고 입력하세요.", "주소", "상세주소", "우편번호"][i], color: .black.withAlphaComponent(0.3))
            tf.text = [data.business_reg_num, data.store_name, data.store_name_eng, data.store_tel, data.store_address_street, data.store_address_detail, data.store_address_zipcode][i]
            tf.delegate = self
            tf.tag = i
            tf.addTarget(self, action: #selector(changedEditStoreInfo_if(_:)), for: .editingChanged)
            tf.addTarget(self, action: #selector(endEditStoreInfo_if(_:)), for: .editingDidEnd)
        }
        /// check
        ([checkBusinessRegNum_img, checkStoreNameChi_img, checkStoreNameEng_img, checkStoreTel_img, checkStoreAddressStreet_img, checkStoreAddressDetail_img, checkStoreAddressZipCode_img, checkStoreMainPhoto_img, checkBusinessReg_img] as [UIImageView]).enumerated().forEach { i, img in
            img.isHidden = true
        }
        /// notice
        ([noticeBusinessRegNum_label, noticeStoreNameChi_label, noticeStoreNameEng_label, noticeStoreTel_label] as [UILabel]).enumerated().forEach { i, label in
            label.isHidden = true
        }
        
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scrollView(_:))))
        
        if StoreObject.store_type == "retailseller" {
            businessRegNum_sv.isHidden = true
            storeAddress_sv.isHidden = true
            businessReg_sv.isHidden = true
        } else if StoreObject.store_type == "wholesales" {
            storeAddress_sv.isHidden = true
        }
        
        edit_btn.addTarget(self, action: #selector(edit_btn(_:)), for: .touchUpInside)
    }
    
    @objc func changedEditStoreInfo_if(_ sender: UITextField) {
        
        var filterContains: String = ""
        let chineseRange = 0x4E00...0x9FFF
        
        let notice: UILabel = [noticeBusinessRegNum_label, noticeStoreNameChi_label, noticeStoreNameEng_label, noticeStoreTel_label][sender.tag]
        let check: UIImageView = [checkBusinessRegNum_img, checkStoreNameChi_img, checkStoreNameEng_img, checkStoreTel_img, checkStoreAddressStreet_img, checkStoreAddressDetail_img, checkStoreAddressZipCode_img, checkStoreMainPhoto_img, checkBusinessReg_img][sender.tag]
        
        notice.isHidden = true
        check.isHidden = true
        
        switch sender {
        case businessRegNum_tf:
            if isChineseBusinessRegNumValid(sender.text!) { check.isHidden = false }
        case storeNameChi_tf:
            filterContains = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~`!@#$%^&*()-+="
            
            let allowedCharacters = NSMutableCharacterSet()
            allowedCharacters.formUnion(with: CharacterSet(charactersIn: filterContains))
            if let characterSetFromRange = NSCharacterSet(range: NSRange(location: chineseRange.lowerBound, length: chineseRange.upperBound-chineseRange.lowerBound+1)) as CharacterSet? {
                allowedCharacters.formUnion(with: characterSetFromRange)
            }
            if sender.text!.count > 0 && sender.text!.rangeOfCharacter(from: allowedCharacters.inverted) == nil { check.isHidden = false }
        case storeNameEng_tf:
            filterContains = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~`!@#$%^&*()-+="
            
            if sender.text!.count > 0 && sender.text!.rangeOfCharacter(from: CharacterSet(charactersIn: filterContains).inverted) == nil { check.isHidden = false }
        case storeTel_tf:
            if isChineseTelNumValid(sender.text!) { check.isHidden = false }
        case storeAddressStreet_tf:
            if sender.text!.count > 0 { check.isHidden = false }
        case storeAddressDetail_tf:
            if sender.text!.count > 0 { check.isHidden = false }
        case storeAddressZipCode_tf:
            if sender.text!.count > 0 { check.isHidden = false }
        default:
            break
        }
    }
    
    @objc func endEditStoreInfo_if(_ sender: UITextField) {
        
        let notice: UILabel = [noticeBusinessRegNum_label, noticeStoreNameChi_label, noticeStoreNameEng_label, noticeStoreTel_label][sender.tag]
        let check: UIImageView = [checkBusinessRegNum_img, checkStoreNameChi_img, checkStoreNameEng_img, checkStoreTel_img, checkStoreAddressStreet_img, checkStoreAddressDetail_img, checkStoreAddressZipCode_img, checkStoreMainPhoto_img, checkBusinessReg_img][sender.tag]
        
        notice.isHidden = !check.isHidden
    }
    
    @objc func edit_btn(_ sender: UIButton) {
        
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

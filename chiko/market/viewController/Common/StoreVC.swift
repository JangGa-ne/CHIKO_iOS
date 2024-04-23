//
//  StoreVC.swift
//  market
//
//  Created by Busan Dynamic on 12/12/23.
//

import UIKit

class StoreCC: UICollectionViewCell {
    
    @IBOutlet weak var item_img: UIImageView!
    @IBOutlet weak var itemRow_label: UILabel!
}

class StoreVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var onoff_type: String = ""
    var store_name: String = ""
    var store_name_eng: String = ""
    var store_mainphoto_img: Data = Data()
    var upload_store_mainphoto_img: Data = Data()
    
    var input_check: [Bool] = [false, false, false, false, false, false, false, false, false, false]
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
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
    @IBOutlet weak var storeName_tf: UITextField!
    @IBOutlet weak var checkStoreName_img: UIImageView!
    @IBOutlet weak var noticeStoreName_label: UILabel!
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
    /// 사업자 등록증
    @IBOutlet weak var businessReg_sv: UIStackView!
    @IBOutlet weak var businessReg_view: UIView!
    @IBOutlet weak var businessReg_img: UIImageView!
    @IBOutlet weak var checkBusinessReg_img: UIImageView!
    /// 건물 계약서
    @IBOutlet weak var buildingContract_sv: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var edit_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setKeyboard()
        
        let data = StoreObject
        
        onoff_type = data.onoff_type
        store_name = data.store_name
        store_name_eng = data.store_name_eng
        /// placeholder, delegate, edti, return next/done
        ([businessRegNum_tf, storeName_tf, storeNameEng_tf, storeTel_tf, storeAddressStreet_tf, storeAddressDetail_tf, storeAddressZipCode_tf, buildingAddressDetail_tf, domainAddress_tf, wechatId_tf] as [UITextField]).enumerated().forEach { i, tf in
            tf.placeholder(text: ["", "", "", "-를 빼고 입력하세요.", "주소", "상세주소", "우편번호", "", "ex. www.example.com", "", ""][i], color: .black.withAlphaComponent(0.3))
            tf.text = [data.business_reg_num, data.store_name, data.store_name_eng, data.store_tel, data.store_address_street, data.store_address_detail, data.store_address_zipcode, data.summary_address, data.store_domain, data.wechat_id][i]
            input_check[i] = (tf.text! != "")
            tf.delegate = self
            tf.tag = i
            tf.addTarget(self, action: #selector(changedEditStoreInfo_if(_:)), for: .editingChanged)
            tf.addTarget(self, action: #selector(endEditStoreInfo_if(_:)), for: .editingDidEnd)
            if tf != domainAddress_tf { tf.returnKeyType = .next } else { tf.returnKeyType = .done }
        }
        /// check
        ([checkBusinessRegNum_img, checkStoreName_img, checkStoreNameEng_img, checkStoreTel_img, checkStoreAddressStreet_img, checkStoreAddressDetail_img, checkStoreAddressZipCode_img, checkDomainAddress_img, checkWechatId_img, checkStoreMainPhoto_img, checkBusinessReg_img] as [UIImageView]).forEach { img in
            img.isHidden = true
        }
        /// notice
        ([noticeBusinessRegNum_label, noticeStoreName_label, noticeStoreNameEng_label, noticeStoreTel_label, noticeDomainAddress_label] as [UILabel]).forEach { label in
            label.isHidden = true
        }
        
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scrollView(_:))))
        /// store type
        ([online_btn, offline_btn, onoffline_btn] as [UIButton]).enumerated().forEach { i, btn in
            btn.tag = i; btn.addTarget(self, action: #selector(storeType_btn(_:)), for: .touchUpInside)
            if StoreObject.onoff_type == "online", btn.tag == 0 {
                btn.isSelected = true
                btn.backgroundColor = .H_8CD26B
                storeAddress_sv.isHidden = true
                domainAddress_sv.isHidden = false
            } else if StoreObject.onoff_type == "offline", btn.tag == 1 {
                btn.isSelected = true
                btn.backgroundColor = .H_8CD26B
                storeAddress_sv.isHidden = false
                domainAddress_sv.isHidden = true
            } else if StoreObject.onoff_type == "onoffline", btn.tag == 2 {
                btn.isSelected = true
                btn.backgroundColor = .H_8CD26B
                storeAddress_sv.isHidden = false
                domainAddress_sv.isHidden = false
            } else {
                btn.isSelected = false
                btn.backgroundColor = .white
            }
        }
        if StoreObject.store_type == "retailseller" {
            businessRegNum_sv.isHidden = true
            buildingAddressDetail_sv.isHidden = true
            businessReg_sv.isHidden = true
            buildingContract_sv.isHidden = true
        } else if StoreObject.store_type == "wholesales" {
            storeType_sv.isHidden = true
            storeType_lineView.isHidden = true
            storeAddress_sv.isHidden = true
            buildingAddressDetail_sv.isHidden = false
            domainAddress_sv.isHidden = true
            wechatId_sv.isHidden = true
        }
        /// building address detail
        buildingAddressDetail_tf.isEnabled = false
        buildingAddressDetail_btn.isSelected = data.summary_address != ""
        buildingAddressDetail_btn.backgroundColor = data.summary_address != "" ? .H_8CD26B : .black.withAlphaComponent(0.3)
        buildingAddressDetail_btn.addTarget(self, action: #selector(buildingAddressDetail_btn(_:)), for: .touchUpInside)
        
        StoreObject.upload_store_mainphoto_img.removeAll()
        imageUrlStringToData(from: StoreObject.store_mainphoto_img) { mimeType, imgData in
            DispatchQueue.main.async {
                self.store_mainphoto_img = imgData ?? Data()
                StoreObject.upload_store_mainphoto_img.append((file_name: "store_mainphoto_img.\((mimeTypes.filter { $0.value == mimeType }.map { $0.key }).first ?? "")", file_data: imgData ?? Data(), file_size: imgData?.count ?? 0))
                if let imgData = UIImage(data: imgData ?? Data()) {
                    self.storeMainPhoto_img.image = resizeImage(imgData, targetSize: self.storeMainPhoto_img.frame.size)
//                    self.checkStoreMainPhoto_img.isHidden = false
                } else {
                    self.storeMainPhoto_img.image = UIImage()
//                    self.checkStoreMainPhoto_img.isHidden = true
                }
            }
        }
        StoreObject.upload_business_reg_img.removeAll()
        imageUrlStringToData(from: StoreObject.business_reg_img) { mimeType, imgData in
            DispatchQueue.main.async {
                StoreObject.upload_business_reg_img.append((file_name: "business_reg_img.\((mimeTypes.filter { $0.value == mimeType }.map { $0.key }).first ?? "")", file_data: imgData ?? Data(), file_size: imgData?.count ?? 0))
                if let imgData = UIImage(data: imgData ?? Data()) {
                    self.businessReg_img.image = resizeImage(imgData, targetSize: self.businessReg_img.frame.size)
//                    self.checkBusinessReg_img.isHidden = false
                } else {
                    self.businessReg_img.image = UIImage()
//                    self.checkBusinessReg_img.isHidden = true
                }
            }
        }
        StoreObject.upload_building_contract_imgs.removeAll()
        data.building_contract_imgs.forEach { _ in StoreObject.upload_building_contract_imgs.append((file_name: "", file_data: Data(), file_size: 0)) }
        data.building_contract_imgs.enumerated().forEach { i, imgUrl in
            imageUrlStringToData(from: imgUrl) { mimeType, imgData in
                DispatchQueue.main.async {
                    StoreObject.upload_building_contract_imgs[i] = (file_name: "\(i).\((mimeTypes.filter { $0.value == mimeType }.map { $0.key }).first ?? "")", file_data: imgData ?? Data(), file_size: imgData?.count ?? 0)
                    self.collectionView.reloadData()
                }
            }
        }
        /// submit document
        ([storeMainPhoto_view, businessReg_view] as [UIView]).enumerated().forEach { i, view in
            view.tag = i; view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(submitDocu_view(_:))))
        }
        /// building contract
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 10)
        collectionView.delegate = self; collectionView.dataSource = self
        
        edit_btn.addTarget(self, action: #selector(edit_btn(_:)), for: .touchUpInside)
    }
    
    @objc func changedEditStoreInfo_if(_ sender: UITextField) {
        
        var filterContains: String = ""
        
        let text = sender.text!.replacingOccurrences(of: " ", with: "")
        let member_type = StoreObject.store_type
        
        let check: UIImageView = [checkBusinessRegNum_img, checkStoreName_img, checkStoreNameEng_img, checkStoreTel_img, checkStoreAddressStreet_img, checkStoreAddressDetail_img, checkStoreAddressZipCode_img, UIImageView(), checkDomainAddress_img, checkWechatId_img, checkStoreMainPhoto_img, checkBusinessReg_img][sender.tag]
        let notice: UILabel = [noticeBusinessRegNum_label, noticeStoreName_label, noticeStoreNameEng_label, noticeStoreTel_label, UILabel(), UILabel(), UILabel(), UILabel(), noticeDomainAddress_label, UILabel(), UILabel(), UILabel()][sender.tag]
        // init
        input_check[sender.tag] = false
        notice.isHidden = true
        
        switch sender {
        case businessRegNum_tf:
//            if isChineseBusinessRegNumValid(text) { input_check[sender.tag] = true }
            if text.count == 10 { input_check[sender.tag] = true }
        case storeName_tf:
            let regex = try! NSRegularExpression(pattern: "^[가-힣ㄱ-ㅎㅏ-ㅣ一-龥a-zA-Z~`!@#\\$%^&*\\(\\)-+=]+$", options: .caseInsensitive)
            if regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.count)) != nil { input_check[sender.tag] = true }
        case storeNameEng_tf:
            filterContains = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~`!@#$%^&*()-+="
            if text.count > 0 && text.rangeOfCharacter(from: CharacterSet(charactersIn: filterContains).inverted) == nil { input_check[sender.tag] = true }
        case storeTel_tf:
//            if isChineseTelNumValid(text) { input_check[sender.tag] = true }
            if StoreObject.store_type == "retailseller" {
                input_check[sender.tag] = !(text.count > 0)
            } else if StoreObject.store_type == "wholesales" {
                input_check[sender.tag] = !(text.count >= 8 && text.count <= 12)
            }
        case storeAddressStreet_tf:
            if text.count > 0 { input_check[sender.tag] = true }
        case storeAddressDetail_tf:
            if text.count > 0 { input_check[sender.tag] = true }
        case storeAddressZipCode_tf:
            if text.count > 0 { input_check[sender.tag] = true }
        case domainAddress_tf:
            if isUrlValid(text) { input_check[sender.tag] = true }
        case wechatId_tf:
            if text.count > 0 { input_check[sender.tag] = true }
        default:
            break
        }
    }
    
    @objc func endEditStoreInfo_if(_ sender: UITextField) {
        
        let check: UIImageView = [checkBusinessRegNum_img, checkStoreName_img, checkStoreNameEng_img, checkStoreTel_img, checkStoreAddressStreet_img, checkStoreAddressDetail_img, checkStoreAddressZipCode_img, UIImageView(), checkDomainAddress_img, checkWechatId_img, checkStoreMainPhoto_img, checkBusinessReg_img][sender.tag]
        let notice: UILabel = [noticeBusinessRegNum_label, noticeStoreName_label, noticeStoreNameEng_label, noticeStoreTel_label, UILabel(), UILabel(), UILabel(), UILabel(), noticeDomainAddress_label, UILabel(), UILabel(), UILabel()][sender.tag]
        
        notice.isHidden = input_check[sender.tag]
    }
    
    @objc func storeType_btn(_ sender: UIButton) {
        /// hidden keyboard
        view.endEditing(true)
        
        if sender.tag == 0 {
            /// online
            onoff_type = "online"
            online_btn.isSelected = true; offline_btn.isSelected = false; onoffline_btn.isSelected = false
            online_btn.backgroundColor = .H_8CD26B; offline_btn.backgroundColor = .white; onoffline_btn.backgroundColor = .white
            storeAddress_sv.isHidden = true
            storeAddressStreet_tf.text?.removeAll(); storeAddressDetail_tf.text?.removeAll(); storeAddressZipCode_tf.text?.removeAll()
            checkStoreAddressStreet_img.isHidden = true; checkStoreAddressDetail_img.isHidden = true; checkStoreAddressZipCode_img.isHidden = true
            domainAddress_sv.isHidden = false
        } else if sender.tag == 1 {
            /// offline
            onoff_type = "offline"
            online_btn.isSelected = false; offline_btn.isSelected = true; onoffline_btn.isSelected = false
            online_btn.backgroundColor = .white; offline_btn.backgroundColor = .H_8CD26B; onoffline_btn.backgroundColor = .white
            storeAddress_sv.isHidden = false
            domainAddress_sv.isHidden = true
            domainAddress_tf.text?.removeAll()
            checkDomainAddress_img.isHidden = true
            noticeDomainAddress_label.isHidden = true
        } else if sender.tag == 2 {
            /// offline
            onoff_type = "onoffline"
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
        segue.member_type = StoreObject.store_type
        presentPanModal(segue)
    }
    
    @objc func submitDocu_view(_ sender: UITapGestureRecognizer) {
        /// hidden keyboard
        view.endEditing(true)
        
        guard let sender = sender.view else { return }
        setPhoto(max: 1) { photo in
            if sender.tag == 0 {
                self.upload_store_mainphoto_img = photo[0].file_data
                StoreObject.upload_store_mainphoto_img = photo
                self.storeMainPhoto_img.image = UIImage(data: photo[0].file_data)
                self.checkStoreMainPhoto_img.isHidden = false
            } else if sender.tag == 1 {
                StoreObject.upload_business_reg_img = photo
                self.businessReg_img.image = UIImage(data: photo[0].file_data)
                self.checkBusinessReg_img.isHidden = false
            }
        }
    }
    
    @objc func edit_btn(_ sender: UIButton) {
        
        view.endEditing(true)
        
        var final_check: Bool = true
        input_check.enumerated().forEach { i, check in
            if !check {
                if StoreObject.store_type == "retailseller" {
                    if i != 0 && !(onoff_type == "online" && i >= 4 && i <= 6) && i != 7 && !(onoff_type == "offline" && i == 8) {
                        final_check = false
                    }
                } else if StoreObject.store_type == "wholesales" {
                    if !(i >= 4 && i <= 6) && i != 8 && i != 9 {
                        final_check = false
                    }
                }
            }
        }
        print(input_check)
        if !final_check || (StoreObject.store_type == "wholesales" && !buildingAddressDetail_btn.isSelected) {
            customAlert(message: "미입력된 항목이 있거나\n확인되지 않은 항목이 있습니다.", time: 1); return
        }
        if StoreObject.store_type == "wholesales", (StoreObject.upload_business_reg_img.count == 0 || StoreObject.upload_building_contract_imgs.count == 0) {
            customAlert(message: "증빙 서류 미제출 항목이 있습니다.", time: 1); return
        }
        
        customLoadingIndicator(animated: true)
        
        StoreObject.upload_files.removeAll()
        /// 사업자 등록증
        StoreObject.upload_business_reg_img.forEach { (file_name: String, file_data: Data, file_size: Int) in
            StoreObject.upload_files.append((field_name: "business_reg_img", file_name: file_name, file_data: file_data, file_size: file_size))
        }
        /// 매장 대표사진
        StoreObject.upload_store_mainphoto_img.forEach { (file_name: String, file_data: Data, file_size: Int) in
            StoreObject.upload_files.append((field_name: "store_mainphoto_img", file_name: file_name, file_data: file_data, file_size: file_size))
        }
        /// 건물 계약서
        StoreObject.upload_building_contract_imgs.enumerated().forEach { i, data in
            StoreObject.upload_files.append((field_name: "building_contract_imgs\(i)", file_name: data.file_name, file_data: data.file_data, file_size: data.file_size))
        }
        
        var status_code: Int = 500
        
        var params: [String: Any] = [
            "action": "edit",
            "collection_id": "store",
            "document_id": StoreObject.store_id,
        ]
        /// store
        if StoreObject.store_type == "retailseller" {
            params["onoff_type"] = onoff_type
            params["store_domain"] = domainAddress_tf.text!
            params["store_address"] = storeAddressStreet_tf.text!
            params["store_address_detail"] = storeAddressDetail_tf.text!
            params["store_address_zipcode"] = storeAddressZipCode_tf.text!
            params["wechat_id"] = wechatId_tf.text!
        } else if StoreObject.store_type == "wholesales" {
            params["business_reg_num"] = businessRegNum_tf.text!
            params["summary_address"] = buildingAddressDetail_tf.text!
        }
        params["store_name"] = storeName_tf.text!
        params["store_name_eng"] = storeNameEng_tf.text!
        params["store_tel"] = storeTel_tf.text!
        /// EditDB 요청
        dispatchGroup.enter()
        requestEditDB(params: params) { status in
            
            if status == 200 {
                
                dispatchGroup.enter()
                requestFileUpload(action: "edit", collection_id: "store", document_id: StoreObject.store_id, file_data: StoreObject.upload_files) { fileUrls, status in
                    StoreObject.business_reg_img = fileUrls?["business_reg_img"] as? String ?? ""
                    StoreObject.store_mainphoto_img = fileUrls?["store_mainphoto_img"] as? String ?? ""
                    StoreObject.building_contract_imgs = fileUrls?["building_contract_imgs"] as? [String] ?? []
                    dispatchGroup.leave()
                }
                
                if (self.store_name != self.storeName_tf.text!) || (self.store_name_eng != self.storeNameEng_tf.text!) || (self.store_mainphoto_img != self.upload_store_mainphoto_img), StoreObject.store_type == "wholesales" {
                    dispatchGroup.enter()
                    requestEditStore { status in
                        dispatchGroup.leave()
                    }
                }
            }; status_code = status; dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            
            self.customLoadingIndicator(animated: false)
            
            if status_code == 200 {
                if StoreObject.store_type == "retailseller" {
                    StoreObject.onoff_type = self.onoff_type
                    StoreObject.store_domain = self.domainAddress_tf.text!
                    StoreObject.store_address_street = self.storeAddressStreet_tf.text!
                    StoreObject.store_address_detail = self.storeAddressDetail_tf.text!
                    StoreObject.store_address_zipcode = self.storeAddressZipCode_tf.text!
                    StoreObject.wechat_id = self.wechatId_tf.text!
                } else if StoreObject.store_type == "wholesales" {
                    StoreObject.business_reg_num = self.businessRegNum_tf.text!
                    StoreObject.summary_address = self.buildingAddressDetail_tf.text!
                }
                StoreObject.store_name = self.storeName_tf.text!
                StoreObject.store_name_eng = self.storeNameEng_tf.text!
                StoreObject.store_tel = self.storeTel_tf.text!
                StoreObject.upload_files.removeAll()
                self.alert(title: "", message: "저장되었습니다.", style: .alert, time: 1) {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.alert(title: "", message: "문제가 발생했습니다. 다시 시도해주세요.", style: .alert, time: 1)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
        
        BuildingListVCdelegate = nil
        BankListVCdelegate = nil
    }
}

extension StoreVC {
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == businessRegNum_tf {
            storeName_tf.becomeFirstResponder()
        } else if textField == storeName_tf {
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

extension StoreVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0, StoreObject.upload_building_contract_imgs.count < 50 {
            return 1
        } else if section == 1, StoreObject.upload_building_contract_imgs.count > 0 {
            return StoreObject.upload_building_contract_imgs.count
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            let data = StoreObject.upload_building_contract_imgs[indexPath.row]
            guard let cell = cell as? StoreCC else { return }
            
            cell.item_img.image = UIImage(data: data.file_data)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreCC0", for: indexPath) as! StoreCC
            cell.tag = -1; cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectItemAt(_:))))
            return cell
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreCC1", for: indexPath) as! StoreCC
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
            setPhoto(max: 50-StoreObject.upload_building_contract_imgs.count) { photos in
                photos.forEach { photo in
                    StoreObject.upload_building_contract_imgs.append(photo)
                    self.collectionView.reloadData()
                }
            }
        } else {
            StoreObject.upload_building_contract_imgs.remove(at: sender.tag)
            collectionView.reloadData()
        }
    }
}

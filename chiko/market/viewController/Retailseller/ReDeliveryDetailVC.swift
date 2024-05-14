//
//  ReDeliveryDetailVC.swift
//  market
//
//  Created by 장 제현 on 2/14/24.
//

import UIKit

class ReDeliveryDetailVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var edit: Bool = false
    
    var store_delivery_position: Int = 0
    var store_delivery: [(address: String, address_detail: String, address_zipcode: String, name: String, nickname: String, num: String)] = []
    var indexpath_row: Int = 0
    
    var new_store_delivery_position: Int = 0
    var new_store_delivery: Array<[String: Any]> = []
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var nickName_tf: UITextField!
    @IBOutlet weak var checkNickName_img: UIImageView!
    @IBOutlet weak var address_tf: UITextField!
    @IBOutlet weak var checkAddress_img: UIImageView!
    @IBOutlet weak var addressDetail_tf: UITextField!
    @IBOutlet weak var checkAddressDetail_img: UIImageView!
    @IBOutlet weak var addressZipcode_tf: UITextField!
    @IBOutlet weak var checkAddressZipcode_img: UIImageView!
    @IBOutlet weak var name_tf: UITextField!
    @IBOutlet weak var checkName_img: UIImageView!
    @IBOutlet weak var num_tf: UITextField!
    @IBOutlet weak var checkNum_img: UIImageView!
    
    @IBOutlet weak var storeDeliveryPosition_img: UIImageView!
    @IBOutlet weak var storeDeliveryPosition_btn: UIButton!
    
    @IBOutlet weak var save_btn: UIButton!
    @IBOutlet weak var delete_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setKeyboard()
        
        ([nickName_tf, address_tf, addressDetail_tf, addressZipcode_tf, name_tf, num_tf] as [UITextField]).enumerated().forEach { i, tf in
            tf.placeholder(text: ["배송지명", "주소", "상세주소", "우편번호", "받는사람", "휴대전화"][i], color: .black.withAlphaComponent(0.3))
        }
        
        ([checkNickName_img, checkAddress_img, checkAddressDetail_img, checkAddressZipcode_img, checkName_img, checkNum_img] as [UIImageView]).forEach { img in
            img.isHidden = true
        }
        
        if edit {
            
            let data = store_delivery[indexpath_row]
            
            nickName_tf.text = data.nickname
            address_tf.text = data.address
            addressDetail_tf.text = data.address_detail
            addressZipcode_tf.text = data.address_zipcode
            name_tf.text = data.name
            num_tf.text = data.num
            
            storeDeliveryPosition_img.image = indexpath_row == store_delivery_position ? UIImage(named: "check_on") : UIImage(named: "check_off")
            storeDeliveryPosition_btn.isSelected = indexpath_row == store_delivery_position
        }
        
        storeDeliveryPosition_btn.addTarget(self, action: #selector(storeDeliveryPosition_btn(_:)), for: .touchUpInside)
        
        save_btn.addTarget(self, action: #selector(save_btn(_:)), for: .touchUpInside)
        delete_btn.addTarget(self, action: #selector(delete_btn(_:)), for: .touchUpInside)
    }
    
    @objc func storeDeliveryPosition_btn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        storeDeliveryPosition_img.image = sender.isSelected ? UIImage(named: "check_on") : UIImage(named: "check_off")
        new_store_delivery_position = sender.isSelected ? indexpath_row : (!edit ? 0 : new_store_delivery_position)
    }
    
    @objc func save_btn(_ sender: UIButton) {
        
        view.endEditing(true)
        
        switch "" {
        case address_tf.text!: customAlert(message: "주소를 입력하세요.", time: 1)
        case name_tf.text!: customAlert(message: "받을분의 이름을 입력하세요.", time: 1)
        case num_tf.text!: customAlert(message: "전화번호를 입력하세요.", time: 1)
        default:
            
            if !edit {
                /// 데이터 추가
                store_delivery.append((address: address_tf.text!, address_detail: addressDetail_tf.text!, address_zipcode: addressZipcode_tf.text!, name: name_tf.text!, nickname: nickName_tf.text!, num: num_tf.text!))
            } else {
                /// 데이터 수정
                store_delivery[indexpath_row] = (address: address_tf.text!, address_detail: addressDetail_tf.text!, address_zipcode: addressZipcode_tf.text!, name: name_tf.text!, nickname: nickName_tf.text!, num: num_tf.text!)
            }
            
            store_delivery.forEach { data in
                new_store_delivery.append(["address": data.address, "address_detail": data.address_detail, "address_zipcode": data.address_zipcode, "name": data.name, "nickname": data.nickname, "num": data.num])
            }
            
            let params: [String: Any] = [
                "action": "edit",
                "collection_id": "store",
                "document_id": StoreObject.store_id,
                "store_delivery_position": new_store_delivery_position,
                "store_delivery": new_store_delivery,
            ]
            
            requestEditDB(params: params) { status in
                
                if status == 200 {
                    
                    StoreObject.store_delivery_position = self.new_store_delivery_position
                    StoreObject.store_delivery = self.store_delivery
                    
                    var message: String = ""
                    if self.edit {
                        message = "변경되었습니다."
                    } else {
                        message = "등록되었습니다."
                    }
                    
                    self.alert(title: "", message: message, style: .alert, time: 1) {
                        if let delegate = ReDeliveryVCdelegate {
                            delegate.loadingData()
                        }; self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
                }
            }
        }
    }
    
    @objc func delete_btn(_ sender: UIButton) {
        
        view.endEditing(true)
        
        let alert = UIAlertController(title: "", message: "삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

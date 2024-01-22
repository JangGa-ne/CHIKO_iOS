//
//  BankListVC.swift
//  market
//
//  Created by Busan Dynamic on 10/23/23.
//

import UIKit
import PanModal

class BankListVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let chinaBank: [String] = [
        "中国工商银行 (Industrial and Commercial Bank of China)",
        "中国建设银行 (China Construction Bank)",
        "中国银行 (Bank of China)",
        "中国农业银行 (Agricultural Bank of China)",
        "中国交通银行 (Bank of Communications)",
        "中国邮政储蓄银行 (China Postal Savings Bank)",
        "中国光大银行 (China Everbright Bank)",
        "中国民生银行 (China Minsheng Bank)",
        "中国兴业银行 (Industrial Bank Co., Ltd.)",
        "中国华夏银行 (Hua Xia Bank)",
        "中国中信银行 (China CITIC Bank)",
        "中国招商银行 (China Merchants Bank)",
        "中国浦发银行 (China Merchants Bank)",
        "中国广发银行 (China Guangfa Bank)",
        "中国平安银行 (Ping An Bank)",
    ]
    var chinaBank_row: Int = 0
    
    let koreaBank: [String] = [
        "농협은행",
        "국민은행",
        "신한은행",
        "우리은행",
        "기업은행",
        "하나은행",
        "새마을금고",
        "우체국",
        "SC제일은행",
        "대구은행",
        "부산은행",
        "경남은행",
        "광주은행",
        "신협",
        "수협은행",
        "산업은행",
        "전북은행",
        "제주은행",
        "씨티은행",
        "케이뱅크",
        "카카오뱅크",
        "토스뱅크",
    ]
    var koreaBank_row: Int = 0
    
    @IBOutlet weak var alert_v: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var choice_btn: UIButton!
    @IBAction func back_btn(_ sender: UIButton) { dismiss(animated: true, completion: nil) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BankListVCdelegate = self
        // init
        alert_v.layer.cornerRadius = divice_radius
        
        pickerView.delegate = self; pickerView.dataSource = self
        
        choice_btn.addTarget(self, action: #selector(choice_btn(_:)), for: .touchUpInside)
    }
    
    @objc func choice_btn(_ sender: UIButton) {
        
        if let delegate = SignUpStoreVCdelegate {
            if MemberObject_signup.member_type == "retailseller" {
                delegate.bankName_tf.text! = chinaBank[chinaBank_row]
            } else if MemberObject_signup.member_type == "wholesales" {
                delegate.bankName_tf.text! = koreaBank[koreaBank_row]
            }
            delegate.checkBankName_img.isHidden = false
        }
        dismiss(animated: true, completion: nil)
    }
}

extension BankListVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if MemberObject_signup.member_type == "retailseller", chinaBank.count > 0 {
            return chinaBank.count
        } else if MemberObject_signup.member_type == "wholesales", koreaBank.count > 0 {
            return koreaBank.count
        } else {
            return .zero
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let title_label = UILabel()
        title_label.textColor = .black
        title_label.textAlignment = .center
        if MemberObject_signup.member_type == "retailseller" {
            title_label.font = UIFont.systemFont(ofSize: 14.0)
            title_label.text = chinaBank[row]
        } else if MemberObject_signup.member_type == "wholesales" {
            title_label.font = UIFont.systemFont(ofSize: 16.0)
            title_label.text = koreaBank[row]
        }
        return title_label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if MemberObject_signup.member_type == "retailseller" {
            chinaBank_row = row
        } else if MemberObject_signup.member_type == "wholesales" {
            koreaBank_row = row
        }
    }
}

extension BankListVC: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var showDragIndicator: Bool {
        return false
    }
}

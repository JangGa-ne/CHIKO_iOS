//
//  ChineseBankListVC.swift
//  market
//
//  Created by Busan Dynamic on 10/23/23.
//

import UIKit
import PanModal

class ChineseBankListVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let bankName: [String] = [
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
    var bankName_row: Int = 0
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var choice_btn: UIButton!
    @IBAction func back_btn(_ sender: UIButton) { dismiss(animated: true, completion: nil) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChineseBankListVCdelegate = self
        // init
        pickerView.delegate = self; pickerView.dataSource = self
        
        choice_btn.addTarget(self, action: #selector(choice_btn(_:)), for: .touchUpInside)
    }
    
    @objc func choice_btn(_ sender: UIButton) {
        
        if let delegate = SignUpStoreVCdelegate {
            delegate.bankName_tf.text! = bankName[bankName_row]
            delegate.checkBankName_img.isHidden = false
        }
        dismiss(animated: true, completion: nil)
    }
}

extension ChineseBankListVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if bankName.count > 0 { return bankName.count } else { return .zero }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let title_label = UILabel()
        title_label.font = UIFont.systemFont(ofSize: 14.0)
        title_label.textColor = .black
        title_label.textAlignment = .center
        title_label.text = bankName[row]
        return title_label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        bankName_row = row
    }
}

extension ChineseBankListVC: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var showDragIndicator: Bool {
        return false
    }
}

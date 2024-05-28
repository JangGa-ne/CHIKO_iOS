//
//  VerificationVC.swift
//  market
//
//  Created by 장 제현 on 5/9/24.
//

/// 번역

import UIKit

class VerificationVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var name_tf: UITextField!
    @IBOutlet weak var countryNumber_label: UILabel!
    @IBOutlet weak var number_tf: UITextField!
    @IBOutlet weak var verification_btn: UIButton!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in label.text = translation(label.text!) }
        buttons.forEach { btn in btn.setTitle(translation(btn.title(for: .normal)), for: .normal) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setKeyboard()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.name_tf.becomeFirstResponder()
        }
        
        ([name_tf, number_tf] as [UITextField]).enumerated().forEach { i, tf in
            tf.placeholder(text: ["", "-없이 입력"][i])
            tf.delegate = self
            if i < 1 {
                tf.returnKeyType = .next
            } else {
                tf.returnKeyType = .done
            }
        }
        countryNumber_label.text = system_country
        
        verification_btn.addTarget(self, action: #selector(verification_btn(_:)), for: .touchUpInside)
    }
    
    @objc func verification_btn(_ sender: UIButton) {
        
        guard name_tf.text! != "" && number_tf.text! != "" else { customAlert(message: "미입력된 항목이 있습니다.", time: 1); return }
        
        customLoadingIndicator(animated: true)
        /// Find Member 요청
        requestFindMember(name: name_tf.text!, number: number_tf.text!) { member_id, status in
            if status == 200 {
                /// Phone Number Veritification
                requestPhoneNum(phoneNum: self.number_tf.text!) { status in
                    
                    self.customLoadingIndicator(animated: false)
                    
                    if status == 200 {
                        
                        let segue = self.storyboard?.instantiateViewController(withIdentifier: "CertificationVC") as! CertificationVC
                        segue.member_id = member_id
                        segue.member_num = self.number_tf.text!
                        self.navigationController?.pushViewController(segue, animated: true, completion: {
                            self.number_tf.text?.removeAll()
                        })
                    } else {
                        self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
                    }
                }
            } else {
                self.customLoadingIndicator(animated: false)
                self.customAlert(message: "미가입 회원입니다.\n입력 정보를 확인해 주세요.", time: 1)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

extension VerificationVC {
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == name_tf {
            number_tf.becomeFirstResponder()
        } else if textField == number_tf {
            number_tf.resignFirstResponder(); verification_btn(UIButton())
        }
        return true
    }
}

//
//  PasswordVC.swift
//  market
//
//  Created by Busan Dynamic on 7/8/24.
//

import UIKit
import PanModal
import LocalAuthentication

class PasswordVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var delegate: UIViewController = UIViewController()
    var type: String = "normal"
    var numbers: [Int] = Array(0...9).shuffled()
    var new_password: [String] = []
    var simple_password: [String] = []
    var faceId: Bool = UserDefaults.standard.bool(forKey: "face_id")
    
    var dismissCompletion: (() -> Void)?
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet var number_vs: [UIView]!
    @IBOutlet weak var faceId_v: UIView!
    @IBOutlet weak var faceId_img: UIImageView!
    
    @IBOutlet var number_btns: [UIButton]!
    @IBOutlet weak var rearrange_btn: UIButton!
    @IBOutlet weak var backspace_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MemberObject.member_pw2 == "" && new_password.count == 0 && type == "normal" ? type = "new" : nil
        
        switch type {
        case "normal": title_label.text = "비밀번호를\n입력해주세요"; faceId_img.isHidden = !faceId; faceId ? authenticateUser() : nil
        case "new": title_label.text = "새로운 비밀번호를\n입력해주세요"; faceId_v.isHidden = true
        case "register": title_label.text = "비밀번호를\n입력해주세요"; faceId_img.isHidden = !faceId; faceId ? authenticateUser() : nil
        default: break
        }
        faceId_v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(faceId_v(_:))))
        faceId_img.isHidden = !faceId
        
        number_vs.forEach { view in
            view.backgroundColor = .H_F2F2F7
        }
        
        number_btns.enumerated().forEach { i, btn in
            btn.tag == i ? btn.setTitle(String(numbers[i]), for: .normal) : nil
            btn.addTarget(self, action: #selector(number_btn(_:)), for: .touchUpInside)
        }
        ([rearrange_btn, backspace_btn] as [UIButton]).forEach { btn in
            btn.addTarget(self, action: #selector(btn(_:)), for: .touchUpInside)
        }
    }
    
    @objc func faceId_v(_ sender: UITapGestureRecognizer) {
        
        faceId = !faceId
        faceId_img.isHidden = !faceId
        
        faceId ? authenticateUser() : nil
    }
    
    @objc func number_btn(_ sender: UIButton) {
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        sender.title(for: .normal) ?? "" != "" ? simple_password.append(sender.title(for: .normal) ?? "") : nil
        number_vs.enumerated().forEach { i, view in
            if view.tag == i && i < simple_password.count {
                view.backgroundColor = .H_8CD26B
            } else {
                view.backgroundColor = .H_F2F2F7
            }
        }
        
        guard simple_password.count == 6 else { return }
        
        if type == "new" {
            navigationController?.popViewController(animated: true, completion: {
                let segue = self.delegate.storyboard?.instantiateViewController(withIdentifier: "PasswordVC") as! PasswordVC
                segue.modalPresentationStyle = .overFullScreen
                segue.delegate = self.delegate
                segue.type = self.type == "new" ? "register" : "normal"
                segue.new_password = self.simple_password
                self.delegate.navigationController?.pushViewController(segue, animated: true)
            })
        } else if type == "register" {
            if new_password == simple_password {
                /// 비밀번호 설정
                let params: [String: Any] = [
                    "action": "edit",
                    "collection_id": "member",
                    "document_id": MemberObject.member_id,
                    "user_pw2": simple_password.joined(),
                ]
                requestEditDB(params: params) { status in
                    if status == 200 {
                        MemberObject.member_pw2 = self.simple_password.joined()
                        self.alert(title: "", message: "Face ID 및 암호", style: .alert, time: 1) {
                            UserDefaults.standard.setValue(self.faceId, forKey: "face_id")
                            self.navigationController?.popViewController(animated: true, completion: {
                                let segue = self.delegate.storyboard?.instantiateViewController(withIdentifier: "PasswordVC") as! PasswordVC
                                segue.delegate = self.delegate
                                segue.type = self.type == "new" ? "register" : "normal"
                                segue.faceId = self.faceId
                                self.delegate.navigationController?.pushViewController(segue, animated: true)
                            })
                        }
                    } else {
                        self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
                    }
                }
            } else {
                self.customAlert(message: "비밀번호가 맞지 않습니다.", time: 1) {
                    self.simple_password.removeAll()
                    self.number_vs.enumerated().forEach { i, view in
                        view.backgroundColor = .H_F2F2F7
                    }
                    self.number_btn(UIButton())
                }
            }
        } else if type == "normal" {
            if MemberObject.member_pw2 == simple_password.joined() {
                dismissWithCompletion()
            } else {
                customAlert(message: "비밀번호가 맞지 않습니다.", time: 1) {
                    self.simple_password.removeAll()
                    self.number_vs.enumerated().forEach { i, view in
                        view.backgroundColor = .H_F2F2F7
                    }
                    self.number_btn(UIButton())
                }
            }
        }
        
        print(MemberObject.member_pw2, new_password.joined(), simple_password.joined(), type)
    }
    
    @objc func btn(_ sender: UIButton) {
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        if sender == rearrange_btn {
            numbers.shuffle()
            number_btns.enumerated().forEach { i, btn in
                btn.tag == i ? btn.setTitle(String(numbers[i]), for: .normal) : nil
            }
        } else if sender == backspace_btn && simple_password.count != 0 {
            simple_password.remove(at: simple_password.count-1)
            number_vs.enumerated().forEach { i, view in
                if view.tag == i && i < simple_password.count {
                    view.backgroundColor = .H_8CD26B
                } else {
                    view.backgroundColor = .H_F2F2F7
                }
            }
        }
    }
    
    func authenticateUser() {
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "인증이 필요합니다.") { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.dismissWithCompletion()
                    } else if let error = authenticationError {
                        print(error.localizedDescription)
                        self.faceId = false
                        self.faceId_img.isHidden = true
                    }
                }
            }
        } else {
            print("이 디바이스는 Face ID를 지원하지 않습니다.")
        }
    }
    
    func dismissWithCompletion() {
        type != "new" ? UserDefaults.standard.setValue(faceId, forKey: "face_id") : nil
        navigationController?.popViewController(animated: true, completion: {
            self.dismissCompletion?()
        })
    }
}

extension PasswordVC: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var allowsTapToDismiss: Bool {
        return false
    }
    
    var allowsDragToDismiss: Bool {
        return false
    }
    
    var cornerRadius: CGFloat {
        return 15
    }
    
    var panModalBackgroundColor: UIColor {
        return .black.withAlphaComponent(0.3)
    }
}

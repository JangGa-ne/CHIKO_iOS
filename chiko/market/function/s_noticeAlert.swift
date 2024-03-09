//
//  s_noticeAlert.swift
//  market
//
//  Created by Busan Dynamic on 2023/10/16.
//

import UIKit
import PanModal
import NVActivityIndicatorView

extension UIViewController {
    
    func progressAlert(title: String?, message: String?, style: UIAlertController.Style, time: CGFloat, completion: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let progressBar = UIProgressView(progressViewStyle: .default)
        var progressTimer: Timer!
        
    }
    
    func alert(title: String?, message: String?, style: UIAlertController.Style, time: CGFloat, completion: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now()+time) { alert.dismiss(animated: true) { completion?() } }
        }
    }
    
    func customAlert(message: String, time: CGFloat, completion: (() -> Void)? = nil) {
        
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.prepare(); feedbackGenerator.notificationOccurred(.error)
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
        segue.modalPresentationStyle = .overFullScreen
        segue.message = message
        segue.time = time
        presentPanModal(segue)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+time) { completion?() }
    }
    
    func customLoadingIndicator(text: String = "", animated: Bool) {
        
        let backgroundView: UIView = UIView()
        backgroundView.frame = UIScreen.main.bounds
        backgroundView.backgroundColor = .black.withAlphaComponent(0.3)
        backgroundView.tag = 8597453147
        
        let loading_indicatorView: NVActivityIndicatorView = NVActivityIndicatorView(
            frame: CGRect(x: UIScreen.main.bounds.midX-25, y: UIScreen.main.bounds.midY-25, width: 50, height: 50),
            type: .lineScaleParty,
            color: .white,
            padding: 0
        )
        loading_indicatorView.startAnimating()
        backgroundView.addSubview(loading_indicatorView)
        
        let loadingTitle_label: UILabel = UILabel()
        loadingTitle_label.frame = CGRect(x: UIScreen.main.bounds.midX-100, y: UIScreen.main.bounds.midY+35, width: 200, height: 20)
        loadingTitle_label.textColor = .white
        loadingTitle_label.textAlignment = .center
        loadingTitle_label.text = text
        backgroundView.addSubview(loadingTitle_label)
        
        if animated {
            view.addSubview(backgroundView)
            UIView.animate(withDuration: 0.3) { backgroundView.alpha = 1.0 }
        } else {
            for subView in view.subviews {
                if subView.tag == 8597453147 {
                    UIView.animate(withDuration: 0.3) { backgroundView.alpha = 0.0 } completion: { _ in subView.removeFromSuperview() }
                }
            }
        }
    }
    
    func problemAlert(view: UIView, type: String = "") {
        
        if type == "" {
            view.subviews.compactMap { $0 as? UIStackView }.forEach { $0.removeFromSuperview() } ;return
        } else if view.subviews.contains(where: { $0 is UIStackView }) {
            return
        }
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alpha = 0.7
        
        let img = UIImageView(image: UIImage(named: "refresh"))
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        switch type {
        case "nodata":
            img.image = UIImage(named: "refresh")
            label.text = "결과 없음"
        case "error":
            img.image = UIImage(named: "refresh")
            label.text = "문제가 발생했습니다. 다시 시도해주세요."
            customAlert(message: "피드를 새로 고칠 수 없습니다.", time: 1)
        default:
            break
        }
        
        stackView.addArrangedSubview(img)
        stackView.addArrangedSubview(label)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            img.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

}

class AlertViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var message: String = ""
    var time: CGFloat = 1
    
    @IBOutlet weak var background_v: UIView!
    @IBOutlet weak var message_label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        message_label.text = message
        
        DispatchQueue.main.asyncAfter(deadline: .now()+time) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension AlertViewController: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var allowsTapToDismiss: Bool {
        return false
    }
}

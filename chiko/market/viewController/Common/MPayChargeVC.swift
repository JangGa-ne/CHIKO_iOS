//
//  MPayChargeVC.swift
//  market
//
//  Created by 장 제현 on 3/7/24.
//

import UIKit

class MPayChargeVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var cny_cash: String = "0"
    var krw_cash: String = "0"
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var krw_label: UILabel!
    @IBOutlet weak var cny_label: UILabel!
    @IBOutlet weak var exchangeRate_label: UILabel!
    
    @IBOutlet var number_btns: [UIButton]!
    @IBOutlet weak var charge_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        number_btns.forEach { btn in
            btn.addTarget(self, action: #selector(number_btn(_:)), for: .touchUpInside)
        }
        charge_btn.addTarget(self, action: #selector(charge_btn(_:)), for: .touchUpInside)
    }
    
    @objc func number_btn(_ sender: UIButton) {
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        if cny_cash == "0", sender.tag != 9 { cny_cash.removeAll() }

        if sender.tag != 11, krw_cash.count < 8 {
            switch sender.tag {
            case 0...8: cny_cash.append(String(sender.tag + 1))
            case 9: if !cny_cash.contains(".") { cny_cash.append(".") }
            case 10: if cny_cash != "0" { cny_cash.append("0") }
            default:
                break
            }
        } else if !cny_cash.isEmpty {
            cny_cash.removeLast()
        }
        // . 이하 2자리 입력가능
        if let dotIndex = cny_cash.firstIndex(of: "."), cny_cash.suffix(from: cny_cash.index(after: dotIndex)).count > 2 {
            cny_cash = String(cny_cash.prefix(upTo: cny_cash.index(dotIndex, offsetBy: 3)))
        }
        
        if cny_cash.isEmpty { cny_cash = "0" }
        
        let cny = Double(cny_cash) ?? 0.0
        cny_label.text = "\(priceFormatter.string(from: cny as NSNumber) ?? "0") CNY"
        
        let krw = Int(PaymentObject.exchange_rate * cny)
        krw_cash = String(krw)
        krw_label.text = "\(priceFormatter.string(from: krw as NSNumber) ?? "0") KRW"
    }
    
    @objc func charge_btn(_ sender: UIButton) {
        
        if Int(krw_cash) ?? 0 >= 100 {
//            let segue = storyboard?.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
//            segue.cny_cash = cny_cash.replacingOccurrences(of: ".", with: "")
//            navigationController?.pushViewController(segue, animated: true, completion: nil)
            alert(title: "test", message: "페이충전 되었습니다.", style: .alert, time: 1) {
                StoreObject.store_cash += Int(self.krw_cash) ?? 0
                if let delegate = MPayVCdelegate {
                    delegate.tableView.reloadData()
                }
                if let delegate = ReLiquidateVCdelegate {
                    delegate.reStoreCash_label.text = priceFormatter.string(from: (Int(self.krw_cash) ?? 0) as NSNumber) ?? "0"
                }
            }
        } else {
            customAlert(message: "최소 충전가능 금액은 100 KRW 입니다.", time: 1)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

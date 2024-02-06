//
//  WhNotDeliveryAddVC.swift
//  market
//
//  Created by Busan Dynamic on 2/2/24.
//

import UIKit
import PanModal

class WhNotDeliveryAddTC: UITableViewCell {
    
    var delegate: WhNotDeliveryAddVC = WhNotDeliveryAddVC()
    var indexpath_row: Int = 0
    
    @IBOutlet weak var itemName_label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_height: NSLayoutConstraint!
    
    @IBOutlet weak var option_label: UILabel!
    @IBOutlet weak var notDeliveryQuantity_tf: UITextField!
    @IBOutlet weak var notDeliveryMemo_btn: UIButton!
    
    func viewDidLoad() {
        
        WhNotDeliveryAddTCdelegate = self
        
        delegate.setKeyboard()
        
        tableView.delegate = nil; tableView.dataSource = nil
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
    }
}

extension WhNotDeliveryAddTC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if delegate.WhNotDeliveryArray[indexpath_row].item_option.count > 0 { return delegate.WhNotDeliveryArray[indexpath_row].item_option.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = delegate.WhNotDeliveryArray[indexpath_row].item_option[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhNotDeliveryAddTC2", for: indexPath) as! WhNotDeliveryAddTC
        
        cell.option_label.text = "옵션. \(data.color) / \(data.size)\n가격. \(priceFormatter.string(from: data.price as NSNumber) ?? "0")\n수량. \(priceFormatter.string(from: data.quantity as NSNumber) ?? "0")"
        
        cell.notDeliveryQuantity_tf.paddingLeft(10); cell.notDeliveryQuantity_tf.paddingRight(10)
        cell.notDeliveryQuantity_tf.placeholder(text: "미송상품 수량을 입력하세요.", color: .lightGray)
        if data.not_delivery_quantity == 0 {
            cell.notDeliveryQuantity_tf.text!.removeAll()
        } else {
            cell.notDeliveryQuantity_tf.text = String(data.not_delivery_quantity)
        }
        cell.notDeliveryQuantity_tf.tag = indexPath.row
        cell.notDeliveryQuantity_tf.addTarget(self, action: #selector(edit_notDeliveryQuantity_tf(_:)), for: .editingChanged)
        
        if data.not_delivery_memo == "" {
            cell.notDeliveryMemo_btn.setTitle("배송날짜/품절여부를 입력하세요.", for: .normal)
            cell.notDeliveryMemo_btn.setTitleColor(.lightGray, for: .normal)
        } else {
            cell.notDeliveryMemo_btn.setTitle(data.not_delivery_memo, for: .normal)
            cell.notDeliveryMemo_btn.setTitleColor(.black, for: .normal)
        }
        cell.notDeliveryMemo_btn.padding(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        cell.notDeliveryMemo_btn.tag = indexPath.row
        cell.notDeliveryMemo_btn.addTarget(self, action: #selector(notDeliveryMemo_btn(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func edit_notDeliveryQuantity_tf(_ sender: UITextField) {
        
        let data = delegate.WhNotDeliveryArray[indexpath_row].item_option[sender.tag]
        let quantity: Int = Int(sender.text ?? "0") ?? 0
        
        if quantity == 0 {
            sender.text!.removeAll()
        } else if quantity > data.quantity {
            sender.resignFirstResponder()
            delegate.customAlert(message: "수량 범위 초과 입니다.", time: 1) {
                sender.becomeFirstResponder()
                sender.text = String(data.quantity)
            }
        }
        
        delegate.WhNotDeliveryArray[indexpath_row].item_option[sender.tag].not_delivery_quantity = Int(sender.text!) ?? 0
    }
    
    @objc func notDeliveryMemo_btn(_ sender: UIButton) {
        
        delegate.view.endEditing(true)
        
        let alert = UIAlertController(title: nil, message: "배송날짜/품절여부를 입력하세요.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "배송날짜", style: .default, handler: { UIAlertAction in
            let segue = self.delegate.storyboard?.instantiateViewController(withIdentifier: "CalendarVC") as! CalendarVC
            if let present_date = sender.titleLabel!.text {
                segue.present_date = present_date
            }
            segue.indexpath_row = sender.tag
            segue.present_btn = sender
            self.delegate.presentPanModal(segue)
        }))
        alert.addAction(UIAlertAction(title: "품절처리", style: .default, handler: { UIAlertAction in
            sender.setTitle("품절", for: .normal)
            sender.setTitleColor(.black, for: .normal)
            self.delegate.WhNotDeliveryArray[self.indexpath_row].item_option[sender.tag].not_delivery_memo = "품절"
        }))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { UIAlertAction in
            sender.setTitle("배송날짜/품절여부를 입력하세요.", for: .normal)
            sender.setTitleColor(.lightGray, for: .normal)
            self.delegate.WhNotDeliveryArray[self.indexpath_row].item_option[sender.tag].not_delivery_memo.removeAll()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        delegate.present(alert, animated: true, completion: nil)
    }
}

class WhNotDeliveryAddVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var present_date: String = ""
    var WhOrderArray: [WhOrderData] = []
    var WhNotDeliveryArray: [WhNotDeliveryData] = []
    
    @IBAction func back_btn(_ sender: UIButton) { dismiss(animated: true, completion: nil) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var date_label: UILabel!
    
    @IBOutlet weak var register_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WhNotDeliveryAddVCdelegate = self
        
        date_label.text = present_date
        
        loadingData()
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        
        register_btn.addTarget(self, action: #selector(register_btn(_:)), for: .touchUpInside)
    }
    
    func loadingData() {
        
        WhOrderArray.forEach { data in
            let notDeliveryValue = WhNotDeliveryData()
            notDeliveryValue.ch_total_item_price = data.ch_total_item_price
            notDeliveryValue.ch_vat_total_price = data.ch_vat_total_price
            notDeliveryValue.delivery_state = data.delivery_state
            notDeliveryValue.item_key = data.item_key
            notDeliveryValue.item_name = data.item_name
            data.item_option.forEach { option in
                let itemOptionValue = ItemOptionData()
                itemOptionValue.color = option.color
                itemOptionValue.price = option.price
                itemOptionValue.quantity = option.quantity
                itemOptionValue.size = option.size
                itemOptionValue.not_delivery_quantity = 0
                itemOptionValue.not_delivery_memo = ""
                notDeliveryValue.item_option.append(itemOptionValue)
            }
            notDeliveryValue.item_sale_price = data.item_sale_price
            notDeliveryValue.kr_total_item_price = data.kr_total_item_price
            notDeliveryValue.kr_vat_total_price = data.kr_vat_total_price
            notDeliveryValue.order_date = data.order_date
            notDeliveryValue.processing_key = data.processing_key
            /// 데이터 추가
            WhNotDeliveryArray.append(notDeliveryValue)
        }
    }
    
    @objc func register_btn(_ sender: UIButton) {
        
        let check: Bool = false
        
        if check {
            
            
        } else {
            customAlert(message: "미입력 또는 등록할 상품이 없습니다.", time: 1)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CalendarVCdelegate = nil
    }
}

extension WhNotDeliveryAddVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if WhNotDeliveryArray.count > 0 { return WhNotDeliveryArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = WhNotDeliveryArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhNotDeliveryAddTC1", for: indexPath) as! WhNotDeliveryAddTC
        cell.delegate = self
        cell.indexpath_row = indexPath.row
        cell.viewDidLoad()
        
        cell.itemName_label.text = data.item_name
        cell.tableView_height.constant = CGFloat(data.item_option.count*95)
        
        return cell
    }
}

extension WhNotDeliveryAddVC: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var allowsDragToDismiss: Bool {
        return false
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(0)
    }
}

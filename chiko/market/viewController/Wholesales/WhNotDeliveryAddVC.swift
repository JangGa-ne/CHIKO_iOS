//
//  WhNotDeliveryAddVC.swift
//  market
//
//  Created by 장 제현 on 2/2/24.
//

import UIKit
import PanModal

class WhNotDeliveryAddTC: UITableViewCell {
    
    var delegate: WhNotDeliveryAddVC = WhNotDeliveryAddVC()
    var indexpath_row: Int = 0
    
    var pickerView: UIPickerView = UIPickerView()
    
    @IBOutlet weak var itemName_label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_height: NSLayoutConstraint!
    
    @IBOutlet weak var option_label: UILabel!
    @IBOutlet weak var notDeliveryQuantity_tf: UITextField!
    @IBOutlet weak var notDeliveryMemo_btn: UIButton!
    
    func viewDidLoad() {
        
        WhNotDeliveryAddTCdelegate = self
        
        tableView.delegate = nil; tableView.dataSource = nil
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
    }
}

extension WhNotDeliveryAddTC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if delegate.WhNotDeliveryArray_new[indexpath_row].item_option.count > 0 { return delegate.WhNotDeliveryArray_new[indexpath_row].item_option.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = delegate.WhNotDeliveryArray_new[indexpath_row].item_option[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhNotDeliveryAddTC2", for: indexPath) as! WhNotDeliveryAddTC
        
        delegate.WhNotDeliveryArray.filter { item in
            return item.item_key == delegate.WhNotDeliveryArray_new[indexpath_row].item_key
        }.forEach { item in
            item.item_option.filter { option in
                return option.color == data.color && option.size == data.size
            }.forEach { option in
                delegate.WhNotDeliveryArray_new[indexpath_row].item_option[indexPath.row].not_delivery_quantity = option.not_delivery_quantity
                delegate.WhNotDeliveryArray_new[indexpath_row].item_option[indexPath.row].not_delivery_memo = option.not_delivery_memo
                cell.notDeliveryQuantity_tf.text = String(option.not_delivery_quantity)
                cell.notDeliveryMemo_btn.setTitle(option.not_delivery_memo, for: .normal)
            }
        }
        
        cell.option_label.text = "옵션. \(data.color) / \(data.size)\n가격. \(priceFormatter.string(from: data.price as NSNumber) ?? "0")\n수량. \(priceFormatter.string(from: data.quantity as NSNumber) ?? "0")"
        
        cell.notDeliveryQuantity_tf.paddingLeft(10); cell.notDeliveryQuantity_tf.paddingRight(10)
        cell.notDeliveryQuantity_tf.placeholder(text: "미송상품 수량을 입력하세요.")
        if data.not_delivery_quantity == 0 {
            cell.notDeliveryQuantity_tf.text!.removeAll()
        } else {
            cell.notDeliveryQuantity_tf.text = String(data.not_delivery_quantity)
        }
        cell.notDeliveryQuantity_tf.inputView = cell.pickerView
        cell.pickerView.tag = indexPath.row
        cell.pickerView.delegate = self; cell.pickerView.dataSource = self
        cell.pickerView.selectRow(data.not_delivery_quantity, inComponent: 0, animated: true)
        
        if data.not_delivery_memo == "" {
            cell.notDeliveryMemo_btn.setTitle("배송예정일을 입력하세요.", for: .normal)
            cell.notDeliveryMemo_btn.setTitleColor(.black.withAlphaComponent(0.3), for: .normal)
        } else {
            cell.notDeliveryMemo_btn.setTitle(data.not_delivery_memo, for: .normal)
            cell.notDeliveryMemo_btn.setTitleColor(.black, for: .normal)
        }
        cell.notDeliveryMemo_btn.padding(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        cell.notDeliveryMemo_btn.tag = indexPath.row
        cell.notDeliveryMemo_btn.addTarget(self, action: #selector(notDeliveryMemo_btn(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func notDeliveryMemo_btn(_ sender: UIButton) {
        
        let alert = UIAlertController(title: nil, message: "배송예정일을 입력하세요.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "배송날짜", style: .default, handler: { UIAlertAction in
            let segue = self.delegate.storyboard?.instantiateViewController(withIdentifier: "CalendarVC") as! CalendarVC
            segue.WhNotDeliveryAddVCdelegate = self.delegate
            segue.WhNotDeliveryAddTCdelegate = self
            segue.start_date = self.delegate.present_date
            if let present_date = sender.titleLabel!.text, present_date != "배송예정일을 입력하세요.", present_date != "판매 중지" {
                segue.present_date = present_date
            }
            segue.indexpath_row = sender.tag
            segue.present_btn = sender
            self.delegate.presentPanModal(segue)
        }))
        alert.addAction(UIAlertAction(title: "판매 중지", style: .default, handler: { UIAlertAction in
            sender.setTitle("판매 중지", for: .normal)
            sender.setTitleColor(.black, for: .normal)
            self.delegate.WhNotDeliveryArray_new[self.indexpath_row].item_option[sender.tag].not_delivery_memo = "판매 중지"
        }))
        alert.addAction(UIAlertAction(title: "내용 삭제", style: .destructive, handler: { UIAlertAction in
            sender.setTitle("배송예정일을 입력하세요.", for: .normal)
            sender.setTitleColor(.black.withAlphaComponent(0.3), for: .normal)
            self.delegate.WhNotDeliveryArray_new[self.indexpath_row].item_option[sender.tag].not_delivery_memo.removeAll()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        delegate.present(alert, animated: true, completion: nil)
    }
}

extension WhNotDeliveryAddTC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if delegate.WhNotDeliveryArray_new[indexpath_row].item_option[pickerView.tag].quantity+1 > 0 {
            return delegate.WhNotDeliveryArray_new[indexpath_row].item_option[pickerView.tag].quantity+1
        } else {
            return .zero
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "선택 안함"
        } else {
            return String(row)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: pickerView.tag, section: 0)) as? WhNotDeliveryAddTC else { return }
        
        delegate.WhNotDeliveryArray_new[indexpath_row].item_option[pickerView.tag].not_delivery_quantity = row
        if row == 0 {
            cell.notDeliveryQuantity_tf.text!.removeAll()
        } else {
            cell.notDeliveryQuantity_tf.text = String(row)
        }
    }
}

class WhNotDeliveryAddVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var present_date: String = ""
    
    var WhOrderArray: [WhOrderData] = []
    var WhNotDeliveryArray: [WhNotDeliveryData] = []
    var WhNotDeliveryArray_new: [WhNotDeliveryData] = []
    
    @IBOutlet weak var background_sv: UIStackView!
    
    @IBAction func back_btn(_ sender: UIButton) { dismiss(animated: true, completion: nil) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var date_label: UILabel!
    
    @IBOutlet weak var register_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WhNotDeliveryAddVCdelegate = self
        
        setKeyboard()
        
        loadingData()
        
        background_sv.layer.cornerRadius = 7.5
        background_sv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        
        date_label.text = present_date
        
        register_btn.addTarget(self, action: #selector(register_btn(_:)), for: .touchUpInside)
    }
    
    func loadingData() {
        /// 데이터 삭제
        WhNotDeliveryArray_new.removeAll()
        
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
            WhNotDeliveryArray_new.append(notDeliveryValue)
        }
    }
    
    @objc func register_btn(_ sender: UIButton) {
        
        var check: Bool = true
        
        WhNotDeliveryArray_new.forEach { data in
            data.item_option.forEach { option in
                if (option.not_delivery_quantity != 0 && option.not_delivery_memo == "") || (option.not_delivery_quantity == 0 && option.not_delivery_memo != "") {
                    check = false; return
                }
            }
        }
        
        if check {
            
            customLoadingIndicator(text: "불러오는 중...", animated: true)
            
            var order_date: String = ""
            var params: [String: Any] = [:]
            
            var not_delivery_item: Array<[String: Any]> = []
            WhNotDeliveryArray_new.forEach { data in
                
                order_date = data.order_date
                
                var item_option: Array<[String: Any]> = []
                data.item_option.forEach { option in
                    item_option.append([
                        "color": option.color,
                        "price": option.price,
                        "quantity": option.quantity,
                        "size": option.size,
                        "not_delivery_quantity": option.not_delivery_quantity,
                        "not_delivery_memo": option.not_delivery_memo,
                    ])
                }
                
                not_delivery_item.append([
                    "ch_total_item_price": data.ch_total_item_price,
                    "ch_vat_total_price": data.ch_vat_total_price,
                    "delivery_state": data.delivery_state,
                    "item_key": data.item_key,
                    "item_name": data.item_name,
                    "item_option": item_option,
                    "item_sale_price": data.item_sale_price,
                    "kr_total_item_price": data.kr_total_item_price,
                    "kr_vat_total_price": data.kr_vat_total_price,
                    "order_date": data.order_date,
                    "processing_key": data.processing_key,
                ])
            }
            
            params["order_date"] = order_date
            params["not_delivery_item"] = not_delivery_item
            
            requestWhNotDelivery(parameters: params) { array, status in
                
                self.customLoadingIndicator(animated: false)
                
                switch status {
                case 200:
                    self.alert(title: "", message: "미송상품 등록되었습니다.", style: .alert, time: 2) {
                        if let delegate = WhOrderBatchVCdelegate {
                            delegate.WhNotDeliveryArray = array; delegate.tableView.reloadData()
                        }
                        self.dismiss(animated: true, completion: nil)
                    }
                default:
                    break
                }
            }
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
        if WhNotDeliveryArray_new.count > 0 { return WhNotDeliveryArray_new.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = WhNotDeliveryArray_new[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhNotDeliveryAddTC1", for: indexPath) as! WhNotDeliveryAddTC
        cell.delegate = self
        cell.indexpath_row = indexPath.row
        cell.viewDidLoad()
        
        cell.itemName_label.text = data.item_name
        cell.tableView_height.constant = CGFloat(data.item_option.count*95)
        
        return cell
    }
}

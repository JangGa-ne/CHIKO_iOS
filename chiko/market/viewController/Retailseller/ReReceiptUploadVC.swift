//
//  ReReceiptUploadVC.swift
//  market
//
//  Created by 장 제현 on 2/20/24.
//

/// 번역완료

import UIKit
import PanModal

class ReReceiptUploadCC: UICollectionViewCell {
    
    @IBOutlet var labels: [UILabel]!
    
    @IBOutlet weak var receipt_img: UIImageView!
    @IBOutlet weak var receiptRow_label: UILabel!
}

class ReReceiptUploadTC: UITableViewCell {
    
    var delegate: ReReceiptUploadVC = ReReceiptUploadVC()
    var indexpath_section: Int = 0
    var indexpath_row: Int = 0
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var summaryAddress_tf: UITextField!
    @IBOutlet weak var summaryAddress_btn: UIButton!
    @IBOutlet weak var storeName_tf: UITextField!
    
    @IBOutlet weak var itemNum_label: UILabel!
    @IBOutlet weak var delete_btn: UIButton!
    @IBOutlet weak var itemName_tf: UITextField!
    @IBOutlet weak var itemCategoryName_btn: UIButton!
    @IBOutlet weak var color_btn: UIButton!
    @IBOutlet weak var size_btn: UIButton!
    @IBOutlet weak var quantity_tf: UITextField!
    @IBOutlet weak var delete_v: UIView!
    @IBOutlet weak var optionTableView: UITableView!
    @IBOutlet weak var optionTableView_height: NSLayoutConstraint!
    @IBOutlet weak var optionAdd_btn: UIButton!
    
    @IBOutlet weak var receiptCollecctionView: UICollectionView!
    
    func viewDidLoad() {
        
        ReReceiptUploadTCdelegate = self
        
        if indexpath_section == 1 {
            
            receiptCollecctionView.delegate = nil; receiptCollecctionView.dataSource = nil
            
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            receiptCollecctionView.setCollectionViewLayout(layout, animated: false)
            receiptCollecctionView.contentOffset.x = delegate.collectionViewContentOffsets[indexpath_section] ?? 0.0
            receiptCollecctionView.delegate = self; receiptCollecctionView.dataSource = self
            
        } else if indexpath_section == 2 {
            
            optionTableView.delegate = nil; optionTableView.dataSource = nil
            
            optionTableView.separatorStyle = .none
            optionTableView.contentInset = .zero
            optionTableView.delegate = self; optionTableView.dataSource = self
            
            optionTableView.isHidden = delegate.ReEnquiryReceiptObject.order_item[indexpath_row].item_option.count == 0
            optionTableView_height.constant = CGFloat(45*delegate.ReEnquiryReceiptObject.order_item[indexpath_row].item_option.count)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func delete_btn(_ sender: UIButton) {
        delegate.ReEnquiryReceiptObject.order_item.remove(at: sender.tag)
        delegate.tableView.reloadData()
    }
    
    @objc func end_itemName_tf(_ sender: UITextField) {
        delegate.ReEnquiryReceiptObject.order_item[indexpath_row].item_name = sender.text!
    }
    
    @objc func itemCategoryName_btn(_ sender: UIButton) {
        
        let data = delegate.ReEnquiryReceiptObject.order_item[indexpath_row]
        let segue = delegate.storyboard?.instantiateViewController(withIdentifier: "CategoryVC") as! CategoryVC
        segue.ReReceiptUploadVCdelegate = delegate
        segue.ReReceiptUploadTCdelegate = self
        segue.option_type = "category"
        segue.option_key = data.item_category_name.first ?? ""
        delegate.presentPanModal(segue)
    }
    
    @objc func optionAdd_btn(_ sender: UIButton) {
        delegate.ReEnquiryReceiptObject.order_item[indexpath_row].item_option.append(ItemOptionData())
        delegate.tableView.reloadData()
    }
}

extension ReReceiptUploadTC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if delegate.ReEnquiryReceiptObject.upload_attached_imgs.count > 0 { return delegate.ReEnquiryReceiptObject.upload_attached_imgs.count+1 } else { return 1 }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row != 0 {
            
            let data = delegate.ReEnquiryReceiptObject.upload_attached_imgs[indexPath.row-1]
            guard let cell = cell as? ReReceiptUploadCC else { return }
            
            if let imgData = UIImage(data: data.file_data) {
                cell.receipt_img.image = resizeImage(imgData, targetSize: cell.receipt_img.frame.size)
            } else {
                cell.receipt_img.image = UIImage()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReReceiptUploadCC1", for: indexPath) as! ReReceiptUploadCC
            cell.labels.forEach { label in label.text = translation(label.text!) }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReReceiptUploadCC2", for: indexPath) as! ReReceiptUploadCC
            cell.receiptRow_label.text = "   \(indexPath.row)"
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            delegate.setPhoto(max: 1000) { photos in
                self.delegate.ReEnquiryReceiptObject.upload_attached_imgs.append(contentsOf: photos)
                collectionView.reloadData()
            }
        } else {
            delegate.ReEnquiryReceiptObject.upload_attached_imgs.remove(at: indexPath.row-1)
            collectionView.reloadData()
        }
    }
}

extension ReReceiptUploadTC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if delegate.ReEnquiryReceiptObject.order_item[indexpath_row].item_option.count > 0 { return delegate.ReEnquiryReceiptObject.order_item[indexpath_row].item_option.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = delegate.ReEnquiryReceiptObject.order_item[indexpath_row].item_option[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReReceiptUploadTC4", for: indexPath) as! ReReceiptUploadTC
        
        cell.color_btn.setTitle(data.color != "" ? translation(data.color) : translation("색상"), for: .normal)
        cell.color_btn.setTitleColor(data.color != "" ? .black : .black.withAlphaComponent(0.3), for: .normal)
        cell.color_btn.tag = indexPath.row; cell.color_btn.addTarget(self, action: #selector(color_btn(_:)), for: .touchUpInside)
        cell.size_btn.setTitle(data.size != "" ? translation(data.size) : translation("사이즈"), for: .normal)
        cell.size_btn.setTitleColor(data.size != "" ? .black : .black.withAlphaComponent(0.3), for: .normal)
        cell.size_btn.tag = indexPath.row; cell.size_btn.addTarget(self, action: #selector(size_btn(_:)), for: .touchUpInside)
        cell.quantity_tf.placeholder(text: "수량")
        cell.quantity_tf.text = data.quantity != 0 ? String(data.quantity) : ""
        cell.quantity_tf.tag = indexPath.row; cell.quantity_tf.addTarget(self, action: #selector(edit_quantity_tf(_:)), for: .editingChanged)
        cell.delete_v.tag = indexPath.row; cell.delete_v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(delete_v(_:))))
        
        return cell
    }
    
    @objc func color_btn(_ sender: UIButton) {
        
        if delegate.ReEnquiryReceiptObject.order_item[indexpath_row].item_category_name.count == 0 { delegate.customAlert(message: "카테고리를 선택해 주세요.", time: 1); return }
        
        let data = delegate.ReEnquiryReceiptObject.order_item[indexpath_row]
        let segue = delegate.storyboard?.instantiateViewController(withIdentifier: "CategoryVC") as! CategoryVC
        segue.ReReceiptUploadVCdelegate = delegate
        segue.ReReceiptUploadTCdelegate = self
        segue.option_type = "color"
        segue.option_key = data.item_category_name.first ?? ""
        segue.option_row = sender.tag
        delegate.presentPanModal(segue)
    }
    
    @objc func size_btn(_ sender: UIButton) {
        
        if delegate.ReEnquiryReceiptObject.order_item[indexpath_row].item_category_name.count == 0 { delegate.customAlert(message: "카테고리를 선택해 주세요.", time: 1); return }
        
        let data = delegate.ReEnquiryReceiptObject.order_item[indexpath_row]
        let segue = delegate.storyboard?.instantiateViewController(withIdentifier: "CategoryVC") as! CategoryVC
        segue.ReReceiptUploadVCdelegate = delegate
        segue.ReReceiptUploadTCdelegate = self
        segue.option_type = "size"
        segue.option_key = data.item_category_name.first ?? ""
        segue.option_row = sender.tag
        delegate.presentPanModal(segue)
    }
    
    @objc func edit_quantity_tf(_ sender: UITextField) {
        if Int(sender.text!) ?? 0 == 0 { 
            sender.text!.removeAll()
        } else if Int(sender.text!) ?? 0 > 999 {
            sender.text = "999"
            sender.resignFirstResponder()
            delegate.customAlert(message: "최대 999까지만 입력 가능합니다.", time: 1) { sender.becomeFirstResponder() }
        }
        delegate.ReEnquiryReceiptObject.order_item[indexpath_row].item_option[sender.tag].quantity = Int(sender.text!) ?? 0
    }
    
    @objc func delete_v(_ sender: UITapGestureRecognizer) {
        
        guard let sender = sender.view else { return }
        
        delegate.ReEnquiryReceiptObject.order_item[indexpath_row].item_option.remove(at: sender.tag)
        delegate.tableView.reloadData()
    }
}

class ReReceiptUploadVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var ReEnquiryReceiptObject: ReEnquiryReceiptData = ReEnquiryReceiptData()
    
    var collectionViewContentOffsets: [Int: CGFloat] = [:]
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var goodsAdd_btn: UIButton!
    @IBOutlet weak var register_btn: UIButton!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in label.text = translation(label.text!) }
        buttons.forEach { btn in btn.setTitle(translation(btn.title(for: .normal)), for: .normal) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReReceiptUploadVCdelegate = self
        
        setKeyboard()
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        
        goodsAdd_btn.addTarget(self, action: #selector(goodsAdd_btn(_:)), for: .touchUpInside)
        register_btn.addTarget(self, action: #selector(register_btn(_:)), for: .touchUpInside)
    }
    
    @objc func goodsAdd_btn(_ sender: UIButton) {
        ReEnquiryReceiptObject.order_item.append((explain: "", item_name: "", item_category_name: [], item_option: [ItemOptionData()], item_total_price: 0))
        tableView.reloadData()
    }
    
    @objc func register_btn(_ sender: UIButton) {
        
        var option_count_check: Bool = true
        var option_check: Bool = true
        ReEnquiryReceiptObject.order_item.forEach { data in
            if data.item_option.count == 0 { 
                option_count_check = false; return
            } else {
                data.item_option.forEach { data in
                    if data.color == "" || data.size == "" || data.quantity == 0 { option_check = false; return }
                }
            }
        }
        
        if ReEnquiryReceiptObject.summary_address == "" {
            customAlert(message: "매장주소를 입력해 주세요.", time: 1)
        } else if ReEnquiryReceiptObject.upload_attached_imgs.count == 0 {
            customAlert(message: "영수증 이미지를 첨부해 주세요.", time: 1)
        } else if ReEnquiryReceiptObject.order_item.count == 0 {
            customAlert(message: "상품정보를 입력해 주세요.", time: 1)
        } else if !option_count_check {
            customAlert(message: "상품 옵션을 추가해 주세요.", time: 1)
        } else if !option_check {
            customAlert(message: "미입력된 상품 옵션이 있습니다.", time: 1)
        } else {
            
            customLoadingIndicator(text: "불러오는 중...", animated: true)
            
            var status_code: Int = 500
            
            var order_item: Array<[String: Any]> = []
            ReEnquiryReceiptObject.order_item.forEach { data in
                
                var item_option: Array<[String: Any]> = []
                data.item_option.forEach { data in
                    item_option.append([
                        "color": data.color,
                        "size": data.size,
                        "quantity": data.quantity
                    ])
                }
                
                order_item.append([
                    "item_category_name": data.item_category_name,
                    "item_name": data.item_name,
                    "item_option": item_option,
                ])
            }
            
            let params: [String: Any] = [
                "order_item": order_item,
                "store_name": StoreObject.store_name,
                "content": "",
                "direction": "tomanager",
                "read_or_not": "false",
                "summary_address": ReEnquiryReceiptObject.summary_address,
                "requested_store_name": ReEnquiryReceiptObject.requested_store_name,
                "request_id": MemberObject.member_id,
                "user_id": "admin",
            ]
            /// 데이터 삭제
            ReEnquiryReceiptObject.upload_files.removeAll()
            // 영수증
            ReEnquiryReceiptObject.upload_attached_imgs.enumerated().forEach { (i, data) in
                ReEnquiryReceiptObject.upload_files.append((field_name: "attached_imgs\(i)", file_name: data.file_name, file_data: data.file_data, file_size: data.file_size))
            }
            
            var new_array: [(store_name: String, summary_address: String, timestamp: String, data: [ReEnquiryReceiptData])] = []
            /// ReEnquiryReceipt 요청
            dispatchGroup.enter()
            requestReEnquiryReceipt(parameters: params) { array, status in
                
                if status == 200, let data = array.first?.data.first, data.time != "" {
                    /// ReReceipt FileUpload 요청
                    dispatchGroup.enter()
                    requestEnquiryFileUpload(action: "add", enquiry_time: data.time, comment_time: data.time, file_data: self.ReEnquiryReceiptObject.upload_files) { array, status in
                        
                        if status == 200, let delegate = ReEnquiryReceiptVCdelegate {
                            
                            delegate.ReEnquiryReceiptArray = array
                            delegate.tableView.reloadData()
                            
                            let params: [String: Any] = [
                                "type": "enquiry",
                                "title": "주문요청",
                                "content": "주문요청 들어왔어요!",
                                "user_id": "admin",
                            ]
                            /// Push 요청
                            dispatchGroup.enter()
                            requestPush(params: params) { _ in
                                dispatchGroup.leave()
                            }
                        }
                        
                        new_array = array; dispatchGroup.leave()
                    }
                }
                    
                status_code = status; dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                
                self.customLoadingIndicator(animated: false)
                
                switch status_code {
                case 200:
                    self.alert(title: "", message: "접수되었습니다.", style: .alert, time: 1) {
                        if let delegate = ReEnquiryReceiptVCdelegate {
                            self.navigationController?.popViewController(animated: false)
                            let segue = self.storyboard?.instantiateViewController(withIdentifier: "ReEnquiryReceiptDetailVC") as! ReEnquiryReceiptDetailVC
                            segue.ReEnquiryReceiptArray = new_array
                            delegate.navigationController?.pushViewController(segue, animated: true, completion: {
                                delegate.ReEnquiryReceiptArray = new_array
                                delegate.tableView.reloadData()
                            })
                        } else {
                            self.navigationController?.popViewController(animated: false)
                        }
                    }
                default:
                    self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

extension ReReceiptUploadVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else if section == 2, ReEnquiryReceiptObject.order_item.count > 0 {
            return ReEnquiryReceiptObject.order_item.count
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? ReReceiptUploadTC else { return }
        
        if indexPath.section == 1 {
            collectionViewContentOffsets[indexPath.section] = cell.receiptCollecctionView.contentOffset.x
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReReceiptUploadTC1", for: indexPath) as! ReReceiptUploadTC
            cell.delegate = self
            cell.indexpath_section = indexPath.section
            cell.viewDidLoad()
            
            cell.labels.forEach { label in label.text = translation(label.text!) }
            cell.buttons.forEach { btn in btn.setTitle(translation(btn.title(for: .normal)), for: .normal) }
            
            cell.summaryAddress_tf.isEnabled = false
            cell.summaryAddress_tf.text = ReEnquiryReceiptObject.summary_address
            cell.summaryAddress_btn.backgroundColor = ReEnquiryReceiptObject.summary_address != "" ? .H_8CD26B : .black.withAlphaComponent(0.3)
            cell.summaryAddress_btn.addTarget(self, action: #selector(summaryAddress_btn(_:)), for: .touchUpInside)
            cell.storeName_tf.text = ReEnquiryReceiptObject.requested_store_name
            cell.storeName_tf.addTarget(self, action: #selector(end_storeName_tf(_:)), for: .editingDidEnd)
            
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReReceiptUploadTC2", for: indexPath) as! ReReceiptUploadTC
            cell.delegate = self
            cell.indexpath_section = indexPath.section
            cell.viewDidLoad()
            
            cell.labels.forEach { label in
                if label.text!.contains("한 매장의 영수증 이미지만") {
                    label.text = translation("한 매장의 영수증 이미지만 욜려주세요.\n주문 할 상품에 대하여 동그라미 표시와 순번을 맞게 작성해 주세요.")
                } else {
                    label.text = translation(label.text!)
                }
            }
            
            return cell
            
        } else if indexPath.section == 2 {
            
            let data = ReEnquiryReceiptObject.order_item[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReReceiptUploadTC3", for: indexPath) as! ReReceiptUploadTC
            cell.delegate = self
            cell.indexpath_section = indexPath.section
            cell.indexpath_row = indexPath.row
            cell.viewDidLoad()
            
            cell.buttons.forEach { btn in btn.setTitle(translation(btn.title(for: .normal)), for: .normal) }
            
            cell.itemNum_label.text = (indexPath.row < 9 ? "0" : "") + String(indexPath.row+1) + "."
            cell.delete_btn.tag = indexPath.row; cell.delete_btn.addTarget(cell, action: #selector(cell.delete_btn(_:)), for: .touchUpInside)
            cell.itemName_tf.paddingLeft(10); cell.itemName_tf.paddingRight(10)
            cell.itemName_tf.placeholder(text: "상품명을 입력하세요.")
            cell.itemName_tf.text = data.item_name
            cell.itemName_tf.addTarget(cell, action: #selector(cell.end_itemName_tf(_:)), for: .editingDidEnd)
            let item_category_name = data.item_category_name.map { translation($0) }.joined(separator: " > ")
            cell.itemCategoryName_btn.setTitle(item_category_name != "" ? item_category_name : translation("카테고리"), for: .normal)
            cell.itemCategoryName_btn.setTitleColor(item_category_name != "" ? .black : .black.withAlphaComponent(0.3), for: .normal)
            cell.itemCategoryName_btn.addTarget(cell, action: #selector(cell.itemCategoryName_btn(_:)), for: .touchUpInside)
            cell.optionAdd_btn.addTarget(cell, action: #selector(cell.optionAdd_btn(_:)), for: .touchUpInside)
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func summaryAddress_btn(_ sender: UIButton) {
        segueViewController(identifier: "BuildingListVC")
    }
    
    @objc func end_storeName_tf(_ sender: UITextField) {
        ReEnquiryReceiptObject.requested_store_name = sender.text!
    }
}

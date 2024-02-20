//
//  ReReceiptUploadVC.swift
//  market
//
//  Created by Busan Dynamic on 2/20/24.
//

import UIKit
import PanModal

class ReReceiptUploadCC: UICollectionViewCell {
    
    @IBOutlet weak var option_label: UILabel!
    
    @IBOutlet weak var receipt_img: UIImageView!
    @IBOutlet weak var receiptRow_label: UILabel!
}

class ReReceiptUploadTC: UITableViewCell {
    
    var delegate: ReReceiptUploadVC = ReReceiptUploadVC()
    var indexpath_section: Int = 0
    var indexpath_row: Int = 0
    
    var option_color: String = ""
    var option_size: String = ""
    
    @IBOutlet weak var summaryAddress_tf: UITextField!
    @IBOutlet weak var summaryAddress_btn: UIButton!
    @IBOutlet weak var storeName_tf: UITextField!
    
    @IBOutlet weak var itemNum_label: UILabel!
    @IBOutlet weak var optionAdd_btn: UIButton!
    @IBOutlet weak var itemName_tf: UITextField!
    @IBOutlet weak var option_v: UIView!
    @IBOutlet weak var optionCollectionView: UICollectionView!
    @IBOutlet weak var delete_btn: UIButton!
    
    @IBOutlet weak var goodsAdd_btn: UIButton!
    @IBOutlet weak var receiptCollecctionView: UICollectionView!
    @IBOutlet weak var register_btn: UIButton!
    
    func viewDidLoad() {
        
        ReReceiptUploadTCdelegate = self
        
        if indexpath_section == 1 {
            
            optionCollectionView.delegate = nil; optionCollectionView.dataSource = nil
            
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            optionCollectionView.setCollectionViewLayout(layout, animated: true, completion: nil)
            optionCollectionView.contentOffset.x = delegate.collectionViewContentOffsets[indexpath_section] ?? 0.0
            optionCollectionView.delegate = self; optionCollectionView.dataSource = self
            
        } else if indexpath_section == 2 {
            
            receiptCollecctionView.delegate = nil; receiptCollecctionView.dataSource = nil
            
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            receiptCollecctionView.setCollectionViewLayout(layout, animated: true, completion: nil)
            receiptCollecctionView.contentOffset.x = delegate.collectionViewContentOffsets[indexpath_section] ?? 0.0
            receiptCollecctionView.delegate = self; receiptCollecctionView.dataSource = self
        }
    }
    
    @objc func summaryAddress_btn(_ sender: UIButton) {
        
        delegate.view.endEditing(true)
        
        delegate.segueViewController(identifier: "BuildingListVC")
    }
    
    @objc func optionAdd_btn(_ sender: UIButton) {
        
        delegate.view.endEditing(true)
        
        let segue = delegate.storyboard?.instantiateViewController(withIdentifier: "CategoryVC") as! CategoryVC
        segue.ReReceiptUploadVCdelegate = delegate
        segue.ReReceiptUploadTCdelegate = self
        segue.option_type = "color"
        delegate.presentPanModal(segue)
    }
    
    func setQuantity() {
        
        let alert = UIAlertController(title: "", message: "수량을 입력해 주세요.", preferredStyle: .alert)
        alert.addTextField()
        let sheet_tf = alert.textFields?[0] ?? UITextField()
        sheet_tf.keyboardType = .numberPad
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            if sheet_tf.text ?? "" == "" {
                self.delegate.dismiss(animated: true) {
                    self.delegate.customAlert(message: "수량을 입력해 주세요.", time: 1) {
                        self.setQuantity()
                    }
                }
            } else {
                self.delegate.dismiss(animated: true) {
                    /// 데이터 추가
                    self.delegate.ReReceiptChatObject.order_item[self.indexpath_row].item_option.append((
                        color: self.option_color,
                        size: self.option_size,
                        quantity: Int(sheet_tf.text!) ?? 0
                    ))
                    UIView.setAnimationsEnabled(false); self.delegate.tableView.reloadSections(IndexSet(integer: 1), with: .none); UIView.setAnimationsEnabled(true)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { _ in
            self.option_color.removeAll(); self.option_size.removeAll()
        }))
        delegate.present(alert, animated: true, completion: nil); return
    }
}

extension ReReceiptUploadTC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == optionCollectionView, delegate.ReReceiptChatObject.order_item[indexpath_row].item_option.count > 0 {
            return delegate.ReReceiptChatObject.order_item[indexpath_row].item_option.count
        } else if collectionView == receiptCollecctionView {
            if delegate.ReReceiptChatObject.upload_attached_imgs.count > 0 { return delegate.ReReceiptChatObject.upload_attached_imgs.count+1 } else { return 1 }
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView == receiptCollecctionView, indexPath.row != 0 {
            
            let data = delegate.ReReceiptChatObject.upload_attached_imgs[indexPath.row-1]
            guard let cell = cell as? ReReceiptUploadCC else { return }
            
            if let imgData = UIImage(data: data.file_data) {
                cell.receipt_img.image = resizeImage(imgData, targetSize: cell.receipt_img.frame.size)
            } else {
                cell.receipt_img.image = UIImage()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == optionCollectionView {
            
            let data = delegate.ReReceiptChatObject.order_item[indexpath_row].item_option[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReReceiptUploadCC1", for: indexPath) as! ReReceiptUploadCC
            cell.option_label.text = "\(data.color) / \(data.size) / \(data.quantity)"
            return cell
        } else if collectionView == receiptCollecctionView {
            
            if indexPath.row == 0 {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "ReReceiptUploadCC2", for: indexPath) as! ReReceiptUploadCC
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReReceiptUploadCC3", for: indexPath) as! ReReceiptUploadCC
                cell.receiptRow_label.text = "   \(indexPath.row)"
                return cell
            }
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == optionCollectionView {
            let data = delegate.ReReceiptChatObject.order_item[indexpath_row].item_option[indexPath.row]
            return CGSize(width: stringWidth(text: "\(data.color) / \(data.size) / \(data.quantity)" ,fontSize: 12.1)+40, height: collectionView.frame.height)
        } else if collectionView == receiptCollecctionView {
            return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate.view.endEditing(true)
        
        if collectionView == optionCollectionView {
            delegate.ReReceiptChatObject.order_item[indexpath_row].item_option.remove(at: indexPath.row)
            UIView.setAnimationsEnabled(false); self.delegate.tableView.reloadSections(IndexSet(integer: 1), with: .none); UIView.setAnimationsEnabled(true)
        } else if collectionView == receiptCollecctionView {
            if indexPath.row == 0 {
                delegate.setPhoto(max: 1000) { photos in
                    self.delegate.ReReceiptChatObject.upload_attached_imgs.append(contentsOf: photos)
                    collectionView.reloadData()
                }
            } else {
                delegate.ReReceiptChatObject.upload_attached_imgs.remove(at: indexPath.row-1)
                collectionView.reloadData()
            }
        }
    }
}

class ReReceiptUploadVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var ReReceiptChatObject: ReReceiptChatData = ReReceiptChatData()
    
    var collectionViewContentOffsets: [Int: CGFloat] = [:]
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReReceiptUploadVCdelegate = self
        
        setKeyboard()
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
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
        } else if section == 1, ReReceiptChatObject.order_item.count > 0 {
            return ReReceiptChatObject.order_item.count
        } else if section == 2 {
            return 1
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? ReReceiptUploadTC else { return }
        
        if indexPath.section == 1 {
            collectionViewContentOffsets[indexPath.section] = cell.optionCollectionView.contentOffset.x
        } else if indexPath.section == 2 {
            collectionViewContentOffsets[indexPath.section] = cell.receiptCollecctionView.contentOffset.x
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReReceiptUploadTC1", for: indexPath) as! ReReceiptUploadTC
            cell.delegate = self
            cell.indexpath_section = indexPath.section
            cell.viewDidLoad()
            
            cell.summaryAddress_tf.isEnabled = false
            cell.summaryAddress_tf.text = ReReceiptChatObject.summary_address
            cell.summaryAddress_btn.backgroundColor = ReReceiptChatObject.summary_address != "" ? .H_8CD26B : .black.withAlphaComponent(0.3)
            cell.summaryAddress_btn.addTarget(cell, action: #selector(cell.summaryAddress_btn(_:)), for: .touchUpInside)
            cell.storeName_tf.text = ReReceiptChatObject.requested_store_name
            cell.storeName_tf.addTarget(self, action: #selector(end_storeName_tf(_:)), for: .editingDidEnd)
            
            return cell
            
        } else if indexPath.section == 1 {
            
            let data = ReReceiptChatObject.order_item[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReReceiptUploadTC2", for: indexPath) as! ReReceiptUploadTC
            cell.delegate = self
            cell.indexpath_section = indexPath.section
            cell.indexpath_row = indexPath.row
            cell.viewDidLoad()
            
            cell.itemNum_label.text = (indexPath.row < 9 ? "0" : "") + String(indexPath.row+1) + "."
            cell.itemName_tf.paddingLeft(10); cell.itemName_tf.paddingRight(10)
            cell.itemName_tf.placeholder(text: "상품명을 입력하세요.", color: .lightGray)
            cell.itemName_tf.text = data.item_name
            cell.optionAdd_btn.addTarget(cell, action: #selector(cell.optionAdd_btn(_:)), for: .touchUpInside)
            cell.option_v.isHidden = (data.item_option.count == 0)
            cell.delete_btn.tag = indexPath.row; cell.delete_btn.addTarget(self, action: #selector(delete_btn(_:)), for: .touchUpInside)
            
            return cell
            
        } else if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReReceiptUploadTC3", for: indexPath) as! ReReceiptUploadTC
            cell.delegate = self
            cell.indexpath_section = indexPath.section
            cell.viewDidLoad()
            
            cell.goodsAdd_btn.addTarget(self, action: #selector(goodsAdd_btn(_:)), for: .touchUpInside)
            cell.register_btn.addTarget(self, action: #selector(register_btn(_:)), for: .touchUpInside)
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func end_storeName_tf(_ sender: UITextField) {
        ReReceiptChatObject.requested_store_name = sender.text!
    }
    
    @objc func delete_btn(_ sender: UIButton) {
        
        view.endEditing(true)
        
        ReReceiptChatObject.order_item.remove(at: sender.tag)
        UIView.setAnimationsEnabled(false); tableView.reloadSections(IndexSet(integer: 1), with: .none); UIView.setAnimationsEnabled(true)
    }
    
    @objc func goodsAdd_btn(_ sender: UIButton) {
        
        view.endEditing(true)
        
        ReReceiptChatObject.order_item.append((item_name: "", item_option: []))
        UIView.setAnimationsEnabled(false); tableView.reloadSections(IndexSet(integer: 1), with: .none); UIView.setAnimationsEnabled(true)
    }
    
    @objc func register_btn(_ sender: UIButton) {
        
        var check: Bool = true
        check = ReReceiptChatObject.summary_address != ""
        check = ReReceiptChatObject.order_item.count != 0
        check = ReReceiptChatObject.upload_attached_imgs.count != 0
        ReReceiptChatObject.order_item.forEach { data in
            if data.item_option.count == 0 { check = false; return }
        }
        
        if check {
            
            customLoadingIndicator(animated: true)
            
            let params: [String: Any] = [
                "": ""
            ]
            
        } else {
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
    }
}

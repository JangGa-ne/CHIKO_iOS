//
//  ReLiquidateVC.swift
//  market
//
//  Created by Busan Dynamic on 12/14/23.
//

import UIKit
import PanModal

class ReLiquidateTC: UITableViewCell {
    
    @IBOutlet weak var optionName_label: UILabel!
    @IBOutlet weak var optionQuantity_label: UILabel!
    @IBOutlet weak var optionPrice_label: UILabel!
}

class ReLiquidateCC: UICollectionViewCell {
    
    @IBOutlet weak var deliveryNick_label: UILabel!
    @IBOutlet weak var deliveryAddressStreet_label: UILabel!
    @IBOutlet weak var deliveryAddressDetail_label: UILabel!
}

class ReLiquidateVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var LiquidateArray: [BasketData] = []
    
    var payment_type: String = ""
    
    var order_total: Int = 0
    var total_price: Int = 0
    var total_vat: Int = 0
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var whStoreName_btn: UIButton!
    @IBOutlet weak var item_img: UIImageView!
    @IBOutlet weak var itemName_btn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_heignt: NSLayoutConstraint!
    @IBOutlet weak var itemTotalPrice_label: UILabel!
    @IBOutlet weak var moreItem_sv: UIStackView!
    @IBOutlet weak var moreItem_view: UIView!
    @IBOutlet weak var moreItemCount_label: UILabel!
    
    @IBOutlet weak var orderStoreName_label: UILabel!
    @IBOutlet weak var orderMemberName_label: UILabel!
    @IBOutlet weak var orderMenberNum_label: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var eximbay_view: UIView!
    @IBOutlet weak var eximbay_img: UIImageView!
    @IBOutlet weak var eximbay_label: UILabel!
    @IBOutlet weak var accountTransfer_view: UIView!
    @IBOutlet weak var accountTransfer_img: UIImageView!
    @IBOutlet weak var accountTransfer_label: UILabel!
    @IBOutlet weak var bankTransfer_view: UIView!
    @IBOutlet weak var bankTransfer_img: UIImageView!
    @IBOutlet weak var bankTransfer_label: UILabel!
    @IBOutlet weak var mPay_view: UIView!
    @IBOutlet weak var mPay_img: UIImageView!
    @IBOutlet weak var mPay_label: UILabel!
    
    @IBOutlet weak var mPay_view2: UIView!
    @IBOutlet weak var reStoreName_label: UILabel!
    @IBOutlet weak var reStoreCash_label: UILabel!
    @IBOutlet weak var reStoreCash_btn: UIButton!
    
    @IBOutlet weak var totalPrice1_label: UILabel!
    @IBOutlet weak var totalPrice2_label: UILabel!
    @IBOutlet weak var totalPrice3_label: UILabel!
    
    @IBOutlet weak var agreement1_btn: UIButton!
    @IBOutlet weak var agreement2_btn: UIButton!
    @IBOutlet weak var agreement3_btn: UIButton!
    
    @IBOutlet weak var payment_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 주문상품
        let data = LiquidateArray[0]
        
        whStoreName_btn.setTitle(data.store_name, for: .normal)
        setNuke(imageView: item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 10)
        itemName_btn.setTitle(data.item_name, for: .normal)
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        tableView_heignt.constant = CGFloat(data.item_option.count*50)
        
        var item_total_price: Int = 0
        data.item_option.forEach { data in item_total_price += data.price*data.quantity }
        itemTotalPrice_label.text = "₩ \(priceFormatter.string(from: item_total_price as NSNumber) ?? "0")"
        moreItem_sv.isHidden = !(LiquidateArray.count > 1)
        moreItem_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moreItem_view(_:))))
        moreItemCount_label.text = "\(LiquidateArray.count)개"
        /// 주문정보
        orderStoreName_label.text = "\(StoreObject.store_name)(\(StoreObject.store_name_eng))"
        orderMemberName_label.text = MemberObject.member_name
        orderMenberNum_label.text = MemberObject.member_num
        /// 배송정보
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.setCollectionViewLayout(layout, animated: true, completion: nil)
        collectionView.delegate = self; collectionView.dataSource = self
        /// 결제수단
        ([eximbay_view, accountTransfer_view, bankTransfer_view, mPay_view] as [UIView]).enumerated().forEach { i, view in
            view.tag = i; view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(payment_view(_:))))
        }
        ([eximbay_img, accountTransfer_img, bankTransfer_img, mPay_img] as [UIImageView]).forEach { img in
            img.image = UIImage(named: "check_off")
        }
        ([eximbay_label, accountTransfer_label, bankTransfer_label, mPay_label] as [UILabel]).forEach { label in
            label.textColor = .black.withAlphaComponent(0.3)
        }
        /// M . Pay
        mPay_view2.isHidden = true
        reStoreName_label.text = "\(StoreObject.store_name)의"
        reStoreCash_label.text = priceFormatter.string(from: StoreObject.store_cash as NSNumber) ?? "0"
        reStoreCash_btn.layer.cornerRadius = 10
        reStoreCash_btn.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        reStoreCash_btn.clipsToBounds = true
        
        LiquidateArray.forEach { data in data.item_option.forEach { data in total_price += data.price*data.quantity } }
        order_total = total_price-total_vat
        
        totalPrice1_label.text = "₩ \(priceFormatter.string(from: order_total as NSNumber) ?? "0")"
        totalPrice2_label.text = "₩ \(priceFormatter.string(from: total_price as NSNumber) ?? "0")"
        totalPrice3_label.text = "₩ \(priceFormatter.string(from: total_vat as NSNumber) ?? "0")"
        
        ([agreement1_btn, agreement2_btn, agreement3_btn] as [UIButton]).enumerated().forEach { i, btn in
            btn.tag = i; btn.addTarget(self, action: #selector(agreement_btn(_:)), for: .touchUpInside)
        }
        
        payment_btn.addTarget(self, action: #selector(payment_btn(_:)), for: .touchUpInside)
    }
    
    @objc func moreItem_view(_ sender: UITapGestureRecognizer) {
        
        view.endEditing(true)
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReLiquidateDetailVC") as! ReLiquidateDetailVC
        segue.LiquidateArray = LiquidateArray
        segue.order_total = order_total
        presentPanModal(segue)
    }
    
    @objc func payment_view(_ sender: UITapGestureRecognizer) {
        
        view.endEditing(true)
        
        guard let sender = sender.view else { return }
        
        ([(eximbay_img, eximbay_label), (accountTransfer_img, accountTransfer_label), (bankTransfer_img, bankTransfer_label), (mPay_img, mPay_label)] as [(UIImageView, UILabel)]).enumerated().forEach { i, option in
            option.0.image = (i == sender.tag) ? UIImage(named: "check_on") : UIImage(named: "check_off")
            option.1.textColor = (i == sender.tag) ? .black : .black.withAlphaComponent(0.3)
        }
        
        mPay_view2.isHidden = (sender.tag != 3)
        
        switch sender.tag {
        case 0: payment_type = "eximbay"
        case 1: payment_type = "account"
        case 2: payment_type = "virtual"
        case 3: payment_type = "mpay"
        default:
            break
        }
    }
    
    @objc func agreement_btn(_ sender: UIButton) {
        
        view.endEditing(true)
        
        if sender.tag == 0 {
            
        } else if sender.tag == 1 {
            
        } else if sender.tag == 2 {
            
        }
    }
    
    @objc func payment_btn(_ sender: UIButton) {
        
        view.endEditing(true)
        
        if StoreObject.store_delivery.count == 0 {
            customAlert(message: "배송지를 추가해 주세요.", time: 1)
        } else if payment_type == "" {
            customAlert(message: "결제수단을 선택해 주세요.", time: 1)
        } else if payment_type == "mpay", StoreObject.store_cash < order_total {
            customAlert(message: "M.PAY 잔액이 부족합니다.", time: 1)
        } else {
            
            customLoadingIndicator(animated: true)
            
            /// Liquidate 요청
            requestReLiquidate(LiquidateArray: LiquidateArray, payment_type: payment_type) { status in
                
                self.customLoadingIndicator(animated: false)
                
                switch status {
                case 200:
                    self.customAlert(message: "주문완료", time: 1)
                case 600:
                    self.customAlert(message: "Error occurred during data conversion", time: 1)
                default:
                    self.customAlert(message: "Internal server error", time: 1)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

extension ReLiquidateVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if LiquidateArray[0].item_option.count > 0 { return LiquidateArray[0].item_option.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = LiquidateArray[0].item_option[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReLiquidateTC", for: indexPath) as! ReLiquidateTC
        
        if (data.price-LiquidateArray[0].item_sale_price) < 0 {
            cell.optionName_label.text = "옵션. \(data.color) + \(data.size) (\(priceFormatter.string(from: (data.price-LiquidateArray[0].item_sale_price) as NSNumber) ?? "0"))"
        } else {
            cell.optionName_label.text = "옵션. \(data.color) + \(data.size) (+\(priceFormatter.string(from: (data.price-LiquidateArray[0].item_sale_price) as NSNumber) ?? "0"))"
        }
        cell.optionQuantity_label.text = "수량. \(data.quantity)개"
        cell.optionPrice_label.text = "₩ \(priceFormatter.string(from: (data.price*data.quantity) as NSNumber) ?? "0")"
        
        return cell
    }
}

extension ReLiquidateVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if StoreObject.store_delivery.count > 0 { return StoreObject.store_delivery.count } else { return .zero }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = StoreObject.store_delivery[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReLiquidateCC", for: indexPath) as! ReLiquidateCC
        
        if indexPath.row == StoreObject.store_delivery_position {
            cell.layer.borderColor = UIColor.H_8CD26B.cgColor
            cell.layer.borderWidth = 1
        } else {
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 0
        }
        
        if data.nickname == "" {
            cell.deliveryNick_label.text = "⭐️ 배송지 \(indexPath.row+1)"
        } else {
            cell.deliveryNick_label.text = "⭐️ \(data.nickname)"
        }
        cell.deliveryAddressStreet_label.text = data.address
        cell.deliveryAddressDetail_label.text = data.address_detail
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 240, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        StoreObject.store_delivery_position = indexPath.row; collectionView.reloadData()
    }
}

//
//  ReEnquiryReceiptDetailVC.swift
//  market
//
//  Created by 장 제현 on 2/21/24.
//

import UIKit

class ReEnquiryReceiptDetailCC: UICollectionViewCell {
    
    @IBOutlet weak var receipt_img: UIImageView!
}

class ReEnquiryReceiptDetailTC: UITableViewCell {
    
    @IBOutlet weak var comment_v: UIView!
    @IBOutlet weak var content_sv: UIStackView!
    @IBOutlet weak var content_label: UILabel!
    @IBOutlet weak var datetimeReadorNot_label: UILabel!
}

class ReEnquiryReceiptDetailVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var enquiry_time: String = ""
    var ReEnquiryReceiptArray: [(store_name: String, summary_address: String, timestamp: String, data: [ReEnquiryReceiptData])] = []
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var datetime_label: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var order_v: UIView!
    @IBOutlet weak var order_btn: UIButton!
    @IBOutlet weak var cancel_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReEnquiryReceiptDetailVCdelegate = self
    
        guard let data = ReEnquiryReceiptArray.first else { return }
        
        title_label.text = data.store_name != "" ? "\(data.store_name), \(data.summary_address)" : data.summary_address
        datetime_label.text = setTimestampToDateTime(timestamp: Int(data.timestamp) ?? 0, dateformat: "yyyy.MM.dd a hh:mm")
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.delegate = self; collectionView.dataSource = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        
        order_v.isHidden = !(data.data.count == 2)
        order_btn.addTarget(self, action: #selector(order_btn(_:)), for: .touchUpInside)
    }
    
    @objc func order_btn(_ sender: UIButton) {
        
        var LiquidateArray: [BasketData] = []
        
        if let data = ReEnquiryReceiptArray.first, data.data.count > 0 {
            
            let order_item = data.data[data.data.count-1].order_item
            order_item.filter { $0.explain == "" }.forEach { data in
                
                let liquidateValue = BasketData()
                liquidateValue.store_name = title_label.text!
                liquidateValue.item_name = data.item_name
                liquidateValue.item_option = data.item_option.filter { $0.quantity != 0 && $0.price != 0 }
                liquidateValue.item_total_price = data.item_total_price
                LiquidateArray.append(liquidateValue)
            }
            
            let segue = storyboard?.instantiateViewController(withIdentifier: "ReLiquidateVC") as! ReLiquidateVC
            segue.receipt_mode = true
            segue.LiquidateArray = LiquidateArray
            navigationController?.pushViewController(segue, animated: true)
        } else {
            customAlert(message: "현재 주문할 수 없습니다.\n나중에 다시시도 하세요.", time: 1)
        }
    }
    
    func loadingData() {
        
        customLoadingIndicator(text: "불러오는 중...", animated: true)
        
        var board_index: String = ""
        if let data = ReEnquiryReceiptArray.first, data.data.count > 0, let data = ReEnquiryReceiptArray.first?.data[0] {
            board_index = data.time
        } else {
            return
        }
        
        let params: [String: Any] = [
            "content": "결제완료, 주문요청합니다.",
            "direction": "tomanager",
            "read_or_not": "false",
            "request_id": MemberObject.member_id,
            "user_id": "admin",
            "board_index": board_index,
        ]
        /// ReEnquiry Receipt 요청
        dispatchGroup.enter()
        requestReEnquiryReceipt(parameters: params) { array, status in
            
            if status == 200, let delegate = ReEnquiryReceiptVCdelegate {
                
                delegate.ReEnquiryReceiptArray = array
                delegate.tableView.reloadData()
                
                self.ReEnquiryReceiptArray = array.filter { $0.timestamp == self.enquiry_time }
                
                let params: [String: Any] = [
                    "type": "enquiry",
                    "title": "주문요청",
                    "content": "결제완료, 주문요청합니다.",
                    "user_id": "admin",
                    "board_index": board_index,
                ]
                /// Push 요청
                dispatchGroup.enter()
                requestPush(params: params) { _ in
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            
            self.customLoadingIndicator(animated: false)
            self.tableView.reloadData()
            
            self.order_v.isHidden = !(self.ReEnquiryReceiptArray.first?.data.count ?? 0 == 2)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
    }
}

extension ReEnquiryReceiptDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let data = ReEnquiryReceiptArray.first?.data.first, data.attached_imgs.count > 0 {
            return data.attached_imgs.count
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let data = ReEnquiryReceiptArray.first?.data.first ?? ReEnquiryReceiptData()
        guard let cell = cell as? ReEnquiryReceiptDetailCC else { return }
        
        setKingfisher(imageView: cell.receipt_img, imageUrl: data.attached_imgs[indexPath.row], cornerRadius: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            
        guard let cell = cell as? ReEnquiryReceiptDetailCC else { return }
        
        cancelKingfisher(imageView: cell.receipt_img)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ReEnquiryReceiptDetailCC", for: indexPath) as! ReEnquiryReceiptDetailCC
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = ReEnquiryReceiptArray.first?.data.first ?? ReEnquiryReceiptData()
        let segue = storyboard?.instantiateViewController(withIdentifier: "ImageSlideVC") as! ImageSlideVC
        segue.imageUrls = data.attached_imgs
        segue.indexpath_row = indexPath.row
        navigationController?.pushViewController(segue, animated: true)
    }
}

extension ReEnquiryReceiptDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = ReEnquiryReceiptArray.first?.data, data.count > 1 {
            return data.count-1
        } else {
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let data = ReEnquiryReceiptArray.first?.data[indexPath.row+1] else { return UITableViewCell() }
        let content = data.content.replacingOccurrences(of: " ", with: "")
        let datetime = setTimestampToDateTime(timestamp: Int(data.time) ?? 0, dateformat: "yyyy.MM.dd a hh:mm")
        let read_or_not = data.read_or_not ? "읽음" : ""
        
        switch true {
        case data.direction == "touser":
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReEnquiryReceiptDetailTC1", for: indexPath) as! ReEnquiryReceiptDetailTC
            
            cell.comment_v.layer.cornerRadius = 15
            cell.comment_v.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
            cell.content_sv.isHidden = (data.order_item.count == 0)
            cell.content_label.isHidden = (data.order_item.count != 0)
            
            if data.order_item.count != 0 {
                
                cell.comment_v.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
                cell.comment_v.layer.borderWidth = 1
                cell.comment_v.backgroundColor = .white
                
                cell.content_sv.removeAllSubviews()
                
                var item_total_price: Int = 0
                data.order_item.enumerated().forEach { i, item in
                    
                    let content_label = UILabel()
                    content_label.numberOfLines = 10000
                    content_label.textColor = .black
                    
                    let content: NSMutableAttributedString = NSMutableAttributedString()
                    content.append(NSAttributedString(
                        string: "\(i < 9 ? "0" : "")\(i+1). \(item.item_name)\n",
                        attributes: [.font: UIFont.boldSystemFont(ofSize: 16)]
                    ))
                    content.append(NSAttributedString(
                        string: "\(item.item_category_name)\n"
                            .replacingOccurrences(of: ", ", with: " > ")
                            .replacingOccurrences(of: "\"", with: "")
                            .replacingOccurrences(of: "[", with: "")
                            .replacingOccurrences(of: "]", with: ""),
                        attributes: [
                            .font: UIFont.systemFont(ofSize: 12),
                            .foregroundColor: UIColor.black.withAlphaComponent(0.3)
                        ]
                    ))
                    
                    if item.explain != "" {
                        content.append(NSAttributedString(
                            string: "ㄴ \(item.explain)\n",
                            attributes: [
                                .font: UIFont.systemFont(ofSize: 12),
                                .foregroundColor: UIColor.black.withAlphaComponent(0.7)
                            ]
                        ))
                        content.append(NSAttributedString(string: "\n", attributes: [.font: UIFont.systemFont(ofSize: 10)]))
                        content.append(NSAttributedString(string: "금액: 0", attributes: [.font: UIFont.systemFont(ofSize: 14)]))
                    } else {
                        content.append(NSAttributedString(string: "\n", attributes: [.font: UIFont.systemFont(ofSize: 10)]))
                        
                        var option_total_price: Int = 0
                        item.item_option.forEach { option in
                            option_total_price += option.price * option.quantity
                            content.append(NSAttributedString(
                                string: "- \(option.color)+\(option.size) (\(priceFormatter.string(from: option.price as NSNumber) ?? "0")) / \(priceFormatter.string(from: option.quantity as NSNumber) ?? "0")장\n",
                                attributes: [
                                    .font: UIFont.systemFont(ofSize: 14),
                                    .foregroundColor: UIColor.black.withAlphaComponent(0.7)
                                ]
                            ))
                            if option.explain != "" {
                                content.append(NSAttributedString(
                                    string: "   ㄴ \(option.explain)\n",
                                    attributes: [
                                        .font: UIFont.systemFont(ofSize: 12),
                                        .foregroundColor: UIColor.black.withAlphaComponent(0.7)
                                    ]
                                ))
                            }
                            content.append(NSAttributedString(string: "\n", attributes: [.font: UIFont.systemFont(ofSize: 5)]))
                        }
                        item_total_price += option_total_price
                        content.append(NSAttributedString(string: "금액: \(priceFormatter.string(from: option_total_price as NSNumber) ?? "0")", attributes: [.font: UIFont.systemFont(ofSize: 14)]))
                    }
                    
                    content_label.attributedText = content
                    content_label.frame.size.height = CGFloat(80+item.item_option.count*20)
                    cell.content_sv.addArrangedSubview(content_label)
                    
                    let lineView = UIView()
                    lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
                    lineView.backgroundColor = .black.withAlphaComponent(0.1)
                    cell.content_sv.addArrangedSubview(lineView)
                    
                    if i == data.order_item.count-1 {
                        
                        let itemTotalPrice_label = UILabel()
                        itemTotalPrice_label.numberOfLines = 10000
                        itemTotalPrice_label.textColor = .black
                        itemTotalPrice_label.attributedText = NSAttributedString(string: "총금액: \(priceFormatter.string(from: item_total_price as NSNumber) ?? "0")", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
                        itemTotalPrice_label.frame.size.height = 20
                        cell.content_sv.addArrangedSubview(itemTotalPrice_label)
                    }
                }
                
                cell.content_sv.axis = .vertical
                cell.content_sv.spacing = 15
                cell.content_sv.isLayoutMarginsRelativeArrangement = false
            } else {
                
                cell.comment_v.layer.borderColor = UIColor.clear.cgColor
                cell.comment_v.layer.borderWidth = .zero
                cell.comment_v.backgroundColor = .H_F2F2F7
                
                cell.content_label.text = data.content
            }
            
            cell.datetimeReadorNot_label.text = data.read_or_not ? "\(datetime) ∙ \(read_or_not)" : datetime
            
            return cell
        case data.direction == "tomanager":
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReEnquiryReceiptDetailTC2", for: indexPath) as! ReEnquiryReceiptDetailTC
            
            cell.comment_v.layer.cornerRadius = 15
            cell.comment_v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.content_label.text = data.content.replacingOccurrences(of: "\\n", with: "\n")
            cell.datetimeReadorNot_label.text = data.read_or_not ? "\(read_or_not) ∙ \(datetime)" : datetime
            
            return cell
        case data.direction == "touser", content.contains("접수됨"):
            return tableView.dequeueReusableCell(withIdentifier: "ReEnquiryReceiptDetailTC3", for: indexPath) as! ReEnquiryReceiptDetailTC
        default:
            return UITableViewCell()
        }
    }
}

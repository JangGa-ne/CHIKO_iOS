//
//  ReEnquiryReceiptDetailVC.swift
//  market
//
//  Created by Busan Dynamic on 2/21/24.
//

import UIKit

class ReEnquiryReceiptDetailCC: UICollectionViewCell {
    
    @IBOutlet weak var receipt_img: UIImageView!
}

class ReEnquiryReceiptDetailTC: UITableViewCell {
    
    @IBOutlet weak var comment_v: UIView!
    @IBOutlet weak var content_label: UILabel!
    @IBOutlet weak var datetimeReadorNot_label: UILabel!
}

class ReEnquiryReceiptDetailVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var ReEnquiryReceiptArray: [(store_name: String, summary_address: String, timestamp: String, data: [ReEnquiryReceiptData])] = []
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var datetime_label: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        guard let data = ReEnquiryReceiptArray.first else { return }
        
        title_label.text = data.store_name != "" ? "\(data.store_name) \(data.summary_address)" : data.summary_address
        datetime_label.text = setTimestampToDateTime(timestamp: Int(data.timestamp) ?? 0, dateformat: "yyyy.MM.dd a hh:mm")
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.setCollectionViewLayout(layout, animated: true, completion: nil)
        collectionView.delegate = self; collectionView.dataSource = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
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
        
        setNuke(imageView: cell.receipt_img, imageUrl: data.attached_imgs[indexPath.row], cornerRadius: 10)
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
            cell.content_label.text = data.content.replacingOccurrences(of: "\\n", with: "\n")
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

//
//  ReDeliveryVC.swift
//  market
//
//  Created by Busan Dynamic on 2/14/24.
//

import UIKit

class ReDeliveryTC: UITableViewCell {
    
    @IBOutlet weak var nickName_label: UILabel!
    @IBOutlet weak var storeDeliveryPosition_img: UIImageView!
    @IBOutlet weak var storeDeliveryPosition_btn: UIButton!
    @IBOutlet weak var address_label: UILabel!
    @IBOutlet weak var addressDetail_label: UILabel!
    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var num_label: UILabel!
    @IBOutlet weak var deliveryEdit_btn: UIButton!
}

class ReDeliveryVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    @IBOutlet weak var deliveryAdd_btn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deliveryAdd_btn.addTarget(self, action: #selector(deliveryAdd_btn(_:)), for: .touchUpInside)
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        tableView.delegate = self; tableView.dataSource = self
    }
    
    @objc func deliveryAdd_btn(_ sender: UIButton) {
        segueViewController(identifier: "ReDeliveryDetailVC")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
    }
}

extension ReDeliveryVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if StoreObject.store_delivery.count > 0 { return StoreObject.store_delivery.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = StoreObject.store_delivery[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReDeliveryTC", for: indexPath) as! ReDeliveryTC
        
        cell.nickName_label.text = "⭐️ " + data.nickname != "" ? data.nickname : "배송지\(indexPath.row+1)"
        cell.storeDeliveryPosition_img.image = StoreObject.store_delivery_position == indexPath.row ? UIImage(named: "check_on") : UIImage(named: "check_off")
        cell.storeDeliveryPosition_btn.isSelected = StoreObject.store_delivery_position == indexPath.row
        cell.storeDeliveryPosition_btn.tag = indexPath.row; cell.storeDeliveryPosition_btn.addTarget(self, action: #selector(storeDeliveryPosition_btn(_:)), for: .touchUpInside)
        cell.address_label.text = data.address
        cell.addressDetail_label.text = data.address_detail
        cell.name_label.text = data.name
        cell.num_label.text = data.num
        
        cell.deliveryEdit_btn.tag = indexPath.row; cell.deliveryEdit_btn.addTarget(self, action: #selector(deliveryEdit_btn(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func storeDeliveryPosition_btn(_ sender: UIButton) {
        
        StoreObject.store_delivery_position = sender.tag
        
        let params: [String: Any] = [
            "action": "edit",
            "collection_id": "store",
            "document_id": StoreObject.store_id,
            "store_delivery_position": sender.tag,
        ]
        
        requestEditDB(params: params) { status in
            self.tableView.reloadData()
            if let delegate = ReLiquidateVCdelegate {
                delegate.collectionView.reloadData()
            }
        }
    }
    
    @objc func deliveryEdit_btn(_ sender: UIButton) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "ReDeliveryDetailVC") as! ReDeliveryDetailVC
        segue.edit = true
        segue.store_delivery_position = StoreObject.store_delivery_position
        segue.store_delivery = StoreObject.store_delivery
        segue.indexpath_row = sender.tag
        navigationController?.pushViewController(segue, animated: true)
    }
}

//
//  WhGoodsTop30VC.swift
//  market
//
//  Created by 장 제현 on 12/9/23.
//

import UIKit

class WhGoodsTop30TC: UITableViewCell {
    
    @IBOutlet weak var number_label: UILabel!
    @IBOutlet weak var item_img: UIImageView!
    @IBOutlet weak var itemName_label: UILabel!
    @IBOutlet weak var itemPrice_label: UILabel!
}

class WhGoodsTop30VC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var GoodsArray: [GoodsData] = []
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var edit_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WhGoodsTop30VCdelegate = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
        tableView.dragDelegate = self; tableView.dropDelegate = self; tableView.dragInteractionEnabled = true
        
        edit_btn.alpha = .zero
        edit_btn.addTarget(self, action: #selector(edit_btn(_:)), for: .touchUpInside)
        
        customLoadingIndicator(animated: true)
        
        loadingData()
    }
    
    @objc func edit_btn(_ sender: UIButton) {
        
        let params: [String: Any] = [
            "action": "edit",
            "collection_id": "store",
            "document_id": StoreObject.store_id,
            "best_goods": GoodsArray.map { $0.item_key },
        ]
        /// Edit DB 요청
        requestEditDB(params: params) { status in
            
            if status == 200 {
                UIView.animate(withDuration: 0.5) { self.edit_btn.alpha = 0 }
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            } else {
                self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
            }
        }
    }
    
    func loadingData() {
        /// 데이터 삭제
        GoodsArray.removeAll(); tableView.reloadData()
        /// Top30 요청
        requestTop30 { array, status in
            
            self.customLoadingIndicator(animated: false)
            
            if status == 200 {
                self.problemAlert(view: self.tableView)
                self.GoodsArray = array
            } else if status == 204 {
                self.problemAlert(view: self.tableView, type: "nodata")
            } else {
                self.problemAlert(view: self.tableView, type: "error")
            }; self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
        
        if let delegate = WhGoodsDetailVCdelegate, !delegate.GoodsObject.item_top_check {
            GoodsArray.remove(at: delegate.indexPath_row); tableView.reloadData()
        }; WhGoodsDetailVCdelegate = nil
    }
}

extension WhGoodsTop30VC: UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate, UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if GoodsArray.count > 0 { return GoodsArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var data = GoodsArray[indexPath.row]
        guard let cell = cell as? WhGoodsTop30TC else { return }
        
        if !data.load { data.load = true
            setKingfisher(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 5)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            
        guard let cell = cell as? WhGoodsTop30TC else { return }
        
        cancelKingfisher(imageView: cell.item_img)
        cell.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = GoodsArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhGoodsTop30TC", for: indexPath) as! WhGoodsTop30TC
        
        cell.number_label.text = String(indexPath.row+1)
        cell.itemName_label.text = data.item_name
        cell.itemPrice_label.text = "₩\(priceFormatter.string(from: data.item_price as NSNumber) ?? "0")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let segue = storyboard?.instantiateViewController(withIdentifier: "WhGoodsDetailVC") as! WhGoodsDetailVC
        segue.GoodsObject = GoodsArray[indexPath.row]
        segue.indexPath_row = indexPath.row
        navigationController?.pushViewController(segue, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
//    func tableView(_ tableView: UITableView, dragSessionAllowsMoveOperation session: any UIDragSession) -> Bool {
//        return true
//    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        UIView.animate(withDuration: 0.5) { self.edit_btn.alpha = 1 }
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        
        let data = GoodsArray[sourceIndexPath.row]
        GoodsArray.remove(at: sourceIndexPath.row)
        GoodsArray.insert(data, at: destinationIndexPath.row)
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        let itemProvider = NSItemProvider(object: "\(GoodsArray[indexPath.row])" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = "\(GoodsArray[indexPath.row])"
        
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let preview = UIDragPreviewParameters()
        preview.backgroundColor = .clear
        return preview
    }
    
    func tableView(_ tableView: UITableView, dropPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let preview = UIDragPreviewParameters()
        preview.backgroundColor = .clear
        return preview
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: any UITableViewDropCoordinator) {
        
        guard let destinationIndexPath = coordinator.destinationIndexPath, destinationIndexPath.section == 1 else { return }
        
        coordinator.items.forEach { dropItem in
            
            guard let sourceIndexPath = dropItem.sourceIndexPath else { return }
            
            tableView.performBatchUpdates({
                let movedItem = self.GoodsArray.remove(at: sourceIndexPath.row)
                self.GoodsArray.insert(movedItem, at: destinationIndexPath.row)
                tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
                tableView.insertRows(at: [destinationIndexPath], with: .automatic)
            }, completion: nil)
            
            UIView.animate(withDuration: 0.5) { self.edit_btn.alpha = 1 }
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        }
    }
}

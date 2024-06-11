//
//  WhGoodsTop30VC.swift
//  market
//
//  Created by 장 제현 on 12/9/23.
//

import UIKit

protocol WhGoodsTop30TCdelegate: AnyObject {
    func cellDidBeginMoving(_ cell: WhGoodsTop30TC)
}

class WhGoodsTop30TC: UITableViewCell {
    
    weak var delegateTC: WhGoodsTop30TCdelegate?
    
    @IBOutlet weak var item_img: UIImageView!
    @IBOutlet weak var itemName_label: UILabel!
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
        
        edit_btn.isHidden = true
        edit_btn.addTarget(self, action: #selector(edit_btn(_:)), for: .touchUpInside)
        
        customLoadingIndicator(animated: true)
        
        loadingData()
    }
    
    @objc func edit_btn(_ sender: UIButton) {
        
        
        
        sender.isHidden = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
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

extension WhGoodsTop30VC: UITableViewDelegate, UITableViewDataSource, WhGoodsTop30TCdelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if GoodsArray.count > 0 { return GoodsArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var data = GoodsArray[indexPath.row]
        guard let cell = cell as? WhGoodsTop30TC else { return }
        
        if !data.load { data.load = true
            setKingfisher(imageView: cell.item_img, imageUrl: data.item_mainphoto_img, cornerRadius: 10)
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
        cell.delegateTC = self
        
        cell.itemName_label.text = data.item_name
        
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
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let data = GoodsArray[sourceIndexPath.row]
        GoodsArray.remove(at: sourceIndexPath.row)
        GoodsArray.insert(data, at: destinationIndexPath.row)
    }
    
    func cellDidBeginMoving(_ cell: WhGoodsTop30TC) {
        if let indexPath = tableView.indexPath(for: cell) {
            print("Cell at \(indexPath) began moving.")
            edit_btn.isHidden = false
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        }
    }
}

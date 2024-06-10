//
//  WhGoodsTop30VC.swift
//  market
//
//  Created by 장 제현 on 12/9/23.
//

import UIKit

class WhGoodsTop30TC: UITableViewCell {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WhGoodsTop30VCdelegate = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
    }
    
    func loadingData() {
        
        requestTop30 { array, status in
            
            if status == 200 {
                self.GoodsArray = array
            } else {
                self.customAlert(message: "문제가 발생했습니다. 다시 시도해주세요.", time: 1)
            }; self.tableView.reloadData()
        }
    }
}

extension WhGoodsTop30VC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if GoodsArray.count > 0 { return GoodsArray.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var data = GoodsArray[indexPath.row]
        guard let cell = cell as? WhGoodsTop30TC else { return }
        
        if !data.load { data.load = true
            setKingfisher(imageView: cell.item_img, imageUrl: data.item_mainphoto_img)
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
        
        cell.itemName_label.text = data.item_name
        
        return cell
    }
}

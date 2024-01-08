//
//  ReGoodsFilterVC.swift
//  market
//
//  Created by 장 제현 on 12/11/23.
//

import UIKit

class ReGoodsFilterTC: UITableViewCell {
    
    @IBOutlet weak var title_label: UILabel!
}

class ReGoodsFilterVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        ReGoodsFilterVCdelegate = self
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
    }
    
    
}

extension ReGoodsFilterVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReGoodsFilterTC1", for: indexPath) as! ReGoodsFilterTC
        
        return cell
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ReGoodsFilterTC2", for: indexPath) as! ReGoodsFilterTC
//        
//        return cell
    }
}

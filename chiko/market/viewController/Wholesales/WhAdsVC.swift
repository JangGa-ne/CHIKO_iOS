//
//  WhAdsVC.swift
//  market
//
//  Created by Busan Dynamic on 7/4/24.
//

import UIKit

class WhAdsCC: UICollectionViewCell {
    
    @IBOutlet weak var background_img: UIImageView!
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var content_label: UILabel!
}

class WhAdsTC: UITableViewCell {
    
    let titles: [String] = ["멤버십에\n가입해보세요.", "우리매장 상품을\n최상단 UP!"]
    let contents: [String] = ["특별한 혜택받기!", "끌올"]
       
    @IBOutlet weak var collectionView: UICollectionView!
    
    func viewDidLoad() {
        
        collectionView.delegate = nil; collectionView.dataSource = nil
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.setCollectionViewLayout(layout, animated: true, completion: nil)
        collectionView.delegate = self; collectionView.dataSource = self
    }
}

extension WhAdsTC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if titles.count > 0 { return titles.count } else { return .zero }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WhAdsCC", for: indexPath) as! WhAdsCC
        cell.background_img.isHidden = (indexPath.row != 0)
        cell.title_label.textColor = indexPath.row == 0 ? .white : .black
        cell.title_label.text = titles[indexPath.row]
        cell.content_label.textColor = indexPath.row == 0 ? .white : .black
        cell.content_label.text = contents[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

class WhAdsVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        tableView.delegate = self; tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(false)
    }
}

extension WhAdsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhAdsTC", for: indexPath) as! WhAdsTC
        cell.viewDidLoad()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

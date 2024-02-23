//
//  TagVC.swift
//  market
//
//  Created by Busan Dynamic on 1/25/24.
//

import UIKit

class TagCC: UICollectionViewCell {
    
    @IBOutlet weak var title_label: UILabel!
}

class TagTC: UITableViewCell {
    
    var TagVCdelegate: TagVC = TagVC()
    var indexpath_row: Int = 0
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    func viewDidLoad() {
        
        collectionView.delegate = nil; collectionView.dataSource = nil
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.delegate = self; collectionView.dataSource = self
    }
}

extension TagTC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if TagVCdelegate.tags[indexpath_row].tag.count > 0 { return TagVCdelegate.tags[indexpath_row].tag.count } else { return .zero}
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = TagVCdelegate.tags[indexpath_row].tag[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCC", for: indexPath) as! TagCC
        cell.layer.borderWidth = 1
        
        cell.title_label.text = data.name
        if data.select {
            cell.layer.borderColor = UIColor.H_8CD26B.cgColor
            cell.title_label.textColor = .H_8CD26B
        } else {
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.title_label.textColor = .black.withAlphaComponent(0.3)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = TagVCdelegate.tags[indexpath_row].tag[indexPath.row]
        TagVCdelegate.tags[indexpath_row].tag[indexPath.row].select = !data.select
        
        collectionView.reloadData()
    }
}

class TagVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    var tags: [(title: String, tag: [(name: String, select: Bool)])] = [
        (title: "성별", [
            (name: "여성", select: false),
            (name: "남성", select: false),
            (name: "아동", select: false),
        ]),
        (title: "카테고리", [
            (name: "의류", select: false),
            (name: "신발", select: false),
            (name: "가방", select: false),
            (name: "액세서리", select: false),
            (name: "언더웨어", select: false),
            (name: "시즌상품", select: false),
        ]),
        (title: "연령대", [
            (name: "신생아", select: false),
            (name: "유아", select: false),
            (name: "어린이", select: false),
            (name: "10대", select: false),
            (name: "20대 초반", select: false),
            (name: "20대 중반", select: false),
            (name: "20대 후반", select: false),
            (name: "30대 초반", select: false),
            (name: "30대 중반", select: false),
            (name: "30대 후반", select: false),
            (name: "40대", select: false),
            (name: "50대", select: false),
            (name: "60대", select: false),
        ]),
        (title: "스타일", [
            (name: "로맨틱", select: false),
            (name: "캐주얼", select: false),
            (name: "시크", select: false),
            (name: "오피스", select: false),
            (name: "빈티지", select: false),
            (name: "럭셔리", select: false),
            (name: "섹시", select: false),
            (name: "스몰사이즈", select: false),
            (name: "댄디", select: false),
            (name: "트렌디", select: false),
            (name: "수입보세", select: false),
            (name: "빅사이즈", select: false),
        ]),
    ]
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var save_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TagVCdelegate = self
                
        tags.enumerated().forEach { i, data in
            data.tag.enumerated().forEach { j, data in
                if StoreObject.store_tag.contains(data.name) { tags[i].tag[j].select = true }
            }
        }
        
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.delegate = self; tableView.dataSource = self
        
        save_btn.addTarget(self, action: #selector(save_btn(_:)), for: .touchUpInside)
    }
    
    @objc func save_btn(_ sender: UIButton) {
        
        var store_tag: [String] = []
        tags.forEach { data in data.tag.forEach { data in if data.select { store_tag.append(data.name) } } }
        
        let params: [String: Any] = [
            "action": "edit",
            "collection_id": "store",
            "document_id": StoreObject.store_id,
            "store_tag": store_tag,
        ]
        /// Edit DB 요청
        requestEditDB(params: params) { status in
            
            switch status {
            case 200:
                StoreObject.store_tag = store_tag
                self.alert(title: "", message: "저장되었습니다.", style: .alert, time: 1) {
                    self.navigationController?.popViewController(animated: true)
                }
            case 204:
                self.customAlert(message: "No data", time: 1)
            case 600:
                self.customAlert(message: "Error occurred during data conversion", time: 1)
            default:
                self.customAlert(message: "Internal server error", time: 1)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
    }
}

extension TagVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tags.count > 0 { return tags.count } else { return .zero }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = tags[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagTC", for: indexPath) as! TagTC
        cell.TagVCdelegate = self
        cell.indexpath_row = indexPath.row
        cell.viewDidLoad()
        
        cell.title_label.text = data.title
        
        return cell
    }
}

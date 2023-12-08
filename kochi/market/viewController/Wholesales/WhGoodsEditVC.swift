//
//  WhGoodsEditVC.swift
//  market
//
//  Created by Busan Dynamic on 12/8/23.
//

import UIKit
import BSImagePicker

class WhGoodsEditCC: UICollectionViewCell {
    
    
}

class WhGoodsEditVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var optionPriceCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WhGoodsEditVCdelegate = self
        
        scrollView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10; layout.minimumInteritemSpacing = 10; layout.scrollDirection = .horizontal
        optionPriceCollectionView.setCollectionViewLayout(layout, animated: true)
        optionPriceCollectionView.delegate = self; optionPriceCollectionView.dataSource = self
        
        
    }
}

extension WhGoodsEditVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WhGoodsEditCC", for: indexPath) as! WhGoodsEditCC
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: collectionView.frame.height)
    }
}

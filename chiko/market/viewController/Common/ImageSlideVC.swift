//
//  ImageSlideVC.swift
//  market
//
//  Created by 장 제현 on 12/13/23.
//

/// 번역완료

import UIKit
import ImageSlideshow

class ImageSlideVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var inputs: [InputSource] = []
    var imageUrls: [String] = []
    var indexpath_row: Int = 0
    
    @IBOutlet var labels: [UILabel]!
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var item_img: ImageSlideshow!
    
    override func loadView() {
        super.loadView()
        
        labels.forEach { label in label.text = translation(label.text!) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if inputs.count > 0 {
            item_img.contentScaleMode = .scaleAspectFit
            item_img.setImageInputs(inputs)
            item_img.setCurrentPage(indexpath_row, animated: true)
        } else if imageUrls.count > 0 {
            setImageSlideShew(imageView: item_img, imageUrls: imageUrls, contentMode: .scaleAspectFit) {
                self.item_img.setCurrentPage(self.indexpath_row, animated: true)
            }
        }
        
//        item_img.zoomEnabled = true
        item_img.pageIndicator?.view.tintColor = .white
        item_img.pageIndicatorPosition = .init(horizontal: .center, vertical: .bottom)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
    }
}

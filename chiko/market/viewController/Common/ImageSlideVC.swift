//
//  ImageSlideVC.swift
//  market
//
//  Created by Busan Dynamic on 12/13/23.
//

import UIKit
import ImageSlideshow

class ImageSlideVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var imageUrls: [String] = []
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var item_img: ImageSlideshow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageSlideShew(imageView: item_img, imageUrls: imageUrls, contentMode: .scaleAspectFit)
        item_img.pageIndicator?.view.tintColor = .white
        item_img.slideshowInterval = 3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
    }
}

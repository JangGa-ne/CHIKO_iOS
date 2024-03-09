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
    
    var inputs: [InputSource] = []
    var imageUrls: [String] = []
    var indexpath_row: Int = 0
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var item_img: ImageSlideshow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if inputs.count > 0 {
            item_img.contentScaleMode = .scaleAspectFit
            item_img.setImageInputs(inputs)
        } else if imageUrls.count > 0 {
            setImageSlideShew(imageView: item_img, imageUrls: imageUrls, contentMode: .scaleAspectFit, completionHandler: nil)
        }
        
        dispatchGroup.notify(queue: .main) {
            
            self.item_img.contentScaleMode = .scaleAspectFit
//            self.item_img.zoomEnabled = true
            self.item_img.pageIndicator?.view.tintColor = .white
            self.item_img.setScrollViewPage(self.indexpath_row+1, animated: false)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackSwipeGesture(true)
    }
}

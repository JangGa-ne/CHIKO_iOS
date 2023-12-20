//
//  SafariViewController.swift
//  market
//
//  Created by Busan Dynamic on 12/20/23.
//

import UIKit
import WebKit

class SafariViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .darkContent } else { return .default }
    }
    
    @IBAction func back_btn(_ sender: UIButton) { navigationController?.popViewController(animated: true) }
    
    @IBOutlet weak var WKWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}

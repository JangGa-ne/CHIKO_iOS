//
//  s_base.swift
//  market
//
//  Created by Busan Dynamic on 2023/10/16.
//

import UIKit

extension UIViewController {
    
}

extension UITableViewCell {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
}

class FetchingMoreTC: UITableViewCell {
    
    @IBOutlet weak var fetchingMore_indicatorView: UIActivityIndicatorView!
}

extension UIButton {
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.window?.endEditing(true)
    }
}

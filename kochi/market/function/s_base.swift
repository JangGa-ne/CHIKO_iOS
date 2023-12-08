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

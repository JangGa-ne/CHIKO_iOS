//
//  UICustomSegmentedControl.swift
//  market
//
//  Created by Busan Dynamic on 2023/07/26.
//

import UIKit

final class UICustomSegmentedControl: UISegmentedControl {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        removeBackgroundAndDivider()
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        
        removeBackgroundAndDivider()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func removeBackgroundAndDivider() {
        
      let image = UIImage()
        
      setBackgroundImage(image, for: .normal, barMetrics: .default)
      setBackgroundImage(image, for: .selected, barMetrics: .default)
      setBackgroundImage(image, for: .highlighted, barMetrics: .default)
      
      setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = .H_8CD26B
    }
}

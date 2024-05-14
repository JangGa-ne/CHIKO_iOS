//
//  UISegmentedControlView.swift
//  market
//
//  Created by 장 제현 on 2023/07/26.
//

import UIKit

protocol UISegmentedControlViewDelegate: AnyObject {
    func segmentedControlValueChanged(segmentedControlView: UISegmentedControlView, selectedItem: String)
}

class UISegmentedControlView: UIView {
    
    weak var delegate: UISegmentedControlViewDelegate?

    var radius: CGFloat = 5
    private var buttons: [UIButton] = []
    private var selectedButtonIndex: Int = 0

    var items: [String: Any] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupButtons()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupButtons()
    }

    func setupButtons() {
        
        for (i, item) in items.enumerated() {
            
            let button = UIButton(type: .system)
            
            if i == 0 { button.backgroundColor = .H_8CD26B } else { button.backgroundColor = .white }
            button.tintColor = .clear
            button.layer.cornerRadius = radius
            button.clipsToBounds = true
            button.setTitle(item.key, for: .normal)
            button.setTitleColor(.black.withAlphaComponent(0.3), for: .normal)
            button.setTitleColor(.white, for: .selected)
            button.titleLabel?.font = .boldSystemFont(ofSize: 14)
            button.tag = i
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            addSubview(button); buttons.append(button)
        }
        
        if buttons.count > 0 {
            buttons[selectedButtonIndex].isSelected = true
            delegate?.segmentedControlValueChanged(
                segmentedControlView: self,
                selectedItem: items[buttons[selectedButtonIndex].title(for: .normal) ?? ""] as? String ?? ""
            )
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let buttonWidth = (bounds.width-CGFloat(buttons.count-1)*10) / CGFloat(buttons.count)
        let buttonHeight = bounds.height

        for (i, button) in buttons.enumerated() {
            let xPosition = CGFloat(i) * (buttonWidth+10)
            button.frame = CGRect(x: xPosition, y: 0, width: buttonWidth, height: buttonHeight)
        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        
        guard sender.tag != selectedButtonIndex else { return }

        buttons[selectedButtonIndex].isSelected = false
        buttons[selectedButtonIndex].backgroundColor = .white
        buttons[sender.tag].isSelected = true
        buttons[sender.tag].backgroundColor = .H_8CD26B
        selectedButtonIndex = sender.tag
        delegate?.segmentedControlValueChanged(
            segmentedControlView: self,
            selectedItem: items[buttons[sender.tag].title(for: .normal) ?? ""] as? String ?? ""
        )
    }
    
    var selectedIndex: Int {
        return selectedButtonIndex
    }
}

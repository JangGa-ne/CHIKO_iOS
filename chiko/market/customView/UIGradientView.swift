//
//  UIGradientView.swift
//  legoyang
//
//  Created by 장 제현 on 2022/11/14.
//

import UIKit

class UIGradientView: UIView {
    
    @IBInspectable var startColor: UIColor = .white { didSet { DispatchQueue.main.async { self.updateColors() } } }
    @IBInspectable var endColor: UIColor = .white { didSet { DispatchQueue.main.async { self.updateColors() } } }
    @IBInspectable var startLocation: Double = 1.00 { didSet { DispatchQueue.main.async { self.updateLocations() } } }
    @IBInspectable var endLocation: Double = 0.00 { didSet { DispatchQueue.main.async { self.updateLocations() } } }
    @IBInspectable var horizontalMode: Bool = false { didSet { DispatchQueue.main.async { self.updatePoints() } } }
    @IBInspectable var diagonalMode: Bool = false { didSet { DispatchQueue.main.async { self.updatePoints() } } }

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        
//        DispatchQueue.main.async {
//            self.updatePoints(); self.updateLocations(); self.updateColors()
//        }
//    }
}

//
//  ReGoodsMenuVC.swift
//  market
//
//  Created by 장 제현 on 12/11/23.
//

import UIKit

class ReGoodsContainerVC: UIViewController {
    
    enum MenuState {
        case open
        case close
    }
    
    var menuState: MenuState = .close
    
    var ReGoodsVCdelegate: ReGoodsVC = ReGoodsVC()
    var ReGoodsFilterVCdelegate: ReGoodsMenuVC = ReGoodsMenuVC()
    var ReGoodsFilterNVdelegate: UINavigationController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        addChild(ReGoodsFilterVCdelegate)
        view.addSubview(ReGoodsFilterVCdelegate.view)
        
        let ReGoodsFilterNVdelegate: UINavigationController = UINavigationController(rootViewController: ReGoodsVCdelegate)
        addChild(ReGoodsFilterNVdelegate)
        view.addSubview(ReGoodsFilterNVdelegate.view)
        ReGoodsFilterNVdelegate.didMove(toParent: self)
        self.ReGoodsFilterNVdelegate = ReGoodsFilterNVdelegate
    }
    
    func didTap() {
        
        switch menuState {
        case .open:
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseInOut) {
                self.ReGoodsFilterNVdelegate?.view.frame.origin.x = UIScreen.main.bounds.maxX
            } completion: { done in
                if done { self.menuState = .close }
            }
        case .close:
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseInOut) {
                self.ReGoodsFilterNVdelegate?.view.frame.origin.x = 100
            } completion: { done in
                if done { self.menuState = .open }
            }
        }
    }
}

class ReGoodsMenuVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReGoodsFilterVCdelegate = self
    }
}

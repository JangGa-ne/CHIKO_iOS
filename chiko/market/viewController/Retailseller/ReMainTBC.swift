//
//  ReMainTBC.swift
//  market
//
//  Created by Busan Dynamic on 10/31/23.
//

import UIKit

var ColorArray: [String: String] = [:]

class ReMainTBC: UITabBarController {
    
    override func loadView() {
        super.loadView()
        
        CategoryObject.ColorArray.forEach { dict in
            dict.forEach { (key: String, value: Any) in
                (value as? [String: [String: String]] ?? [:]).forEach { (key: String, value: [String : String]) in
                    value.forEach { (key: String, value: String) in ColorArray[key] = value }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.backgroundEffect = .none
            appearance.stackedLayoutAppearance.normal.iconColor = .clear
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black.withAlphaComponent(0.1), .font: UIFont.boldSystemFont(ofSize: 10)]
            appearance.stackedLayoutAppearance.selected.iconColor = .clear
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.H_8CD26B, .font: UIFont.boldSystemFont(ofSize: 10)]
            tabBar.standardAppearance = appearance
        }
        
        let backgroundView = UIVisualEffectView()
        backgroundView.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: view.frame.maxY)
        backgroundView.effect = UIBlurEffect(style: .light)
        tabBar.insertSubview(backgroundView, at: 0)
        
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 0.5))
        lineView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        tabBar.insertSubview(lineView, at: 1)
        
        tabBar.items!.enumerated().forEach { i, tabBarItem in
            tabBarItem.title = ["홈", "상품리스트", "마이페이지"][i]
        }
    }
}

extension ReMainTBC: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}


//
//  s_animation.swift
//  market
//
//  Created by Busan Dynamic on 2/7/24.
//

import UIKit

class animationSegue: NSObject, UIViewControllerAnimatedTransitioning {
    
    var animationTime: CGFloat = 0.5
    var animationLeft: Bool = false
    var animationRight: Bool = false
    var animationTop: Bool = false
    var animationBottom: Bool = false
    var animationAlpha: Bool = false
    var presenting: Bool = false
    let dimmingView = UIButton()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationTime
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toVC = transitionContext.viewController(forKey: .to), let fromVC = transitionContext.viewController(forKey: .from) else { return }
        
        let containerView = transitionContext.containerView
        
        let finalWidth = toVC.view.bounds.width
        let finalHeight = toVC.view.bounds.height
        
        if presenting {
            
            dimmingView.backgroundColor = .black; dimmingView.alpha = 0.0; dimmingView.frame = containerView.bounds; containerView.addSubview(dimmingView)
            
            if animationLeft { toVC.view.frame = CGRect(x: -finalWidth, y: 0.0, width: finalWidth, height: finalHeight) }
            if animationRight { toVC.view.frame = CGRect(x: finalWidth, y: 0.0, width: finalWidth, height: finalHeight) }
            if animationTop { toVC.view.frame = CGRect(x: 0.0, y: -finalHeight, width: finalWidth, height: finalHeight) }
            if animationBottom { toVC.view.frame = CGRect(x: 0.0, y: finalHeight, width: finalWidth, height: finalHeight) }
            if animationAlpha { toVC.view.frame = CGRect(x: 0.0, y: 0.0, width: finalWidth, height: finalHeight) }
            containerView.addSubview(toVC.view)
        }
        
        let duration = transitionDuration(using: transitionContext)
        let cancel = transitionContext.transitionWasCancelled
        
        UIView.animate(withDuration: duration, animations: {
            
            if !self.animationAlpha {
                
                let transform = {
                    self.dimmingView.alpha = 0.3
                    if self.animationLeft { toVC.view.transform = CGAffineTransform(translationX: finalWidth, y: 0.0) }
                    if self.animationRight { toVC.view.transform = CGAffineTransform(translationX: -finalWidth, y: 0.0) }
                    if self.animationTop { toVC.view.transform = CGAffineTransform(translationX: 0.0, y: finalHeight) }
                    if self.animationBottom { toVC.view.transform = CGAffineTransform(translationX: 0.0, y: -finalHeight) }
                }
                let identity = { self.dimmingView.alpha = 0.0; fromVC.view.transform = .identity }
                
                self.presenting ? transform() : identity()
            } else {
                
                let transform = { self.dimmingView.alpha = 0.3; toVC.view.alpha = 1.0 }
                let identity = { self.dimmingView.alpha = 0.0; fromVC.view.alpha = 0.0 }
                
                self.presenting ? transform() : identity()
            }
        }) { (_) in
            
            transitionContext.completeTransition(!cancel)
        }
    }
}

extension UIViewController: UIViewControllerTransitioningDelegate {
    static let transition: animationSegue = animationSegue()
}

extension WhOrderVC {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        UIViewController.transition.presenting = true; UIViewController.transition.animationTime = 0.2; UIViewController.transition.animationBottom = true; return UIViewController.transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        UIViewController.transition.presenting = false; UIViewController.transition.animationTime = 0.2; UIViewController.transition.animationBottom = true; return UIViewController.transition
    }
}

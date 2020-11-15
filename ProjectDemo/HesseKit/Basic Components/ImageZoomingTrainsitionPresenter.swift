//
//  ImageZoomingTrainsitionPresenter.swift
//  ImageZoomingTransitioning
//
//  Created by Hesse Huang on 23/4/2018.
//  Copyright © 2018 Hesse. All rights reserved.
//

import UIKit

final class ImageZoomingTrainsitionPresenter: NSObject, UIViewControllerAnimatedTransitioning {
    
    // source image view
    let sourceImageView: UIImageView
    let destinationImageView: UIImageView
    
    let duration: TimeInterval
    
    init(from soureImageView: UIImageView, to destinationImageView: UIImageView, duration: TimeInterval = 0.5) {
        self.sourceImageView = soureImageView
        self.destinationImageView = destinationImageView
        self.duration = duration
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else { return }
        let container = transitionContext.containerView
        
        // set `sourceImageView` to be invisible
        sourceImageView.isHidden = true
        destinationImageView.isHidden = true
        
        // insert the toVC.view to the bottom of container view
        toVC.loadViewIfNeeded()
        toVC.view.alpha = 0
        container.insertSubview(toVC.view, at: 0)
        
        // make an identical image view
        let snapshotView = UIImageView(image: sourceImageView.image)
        snapshotView.contentMode = sourceImageView.contentMode
        snapshotView.frame = sourceImageView.convert(sourceImageView.bounds, to: nil)
        container.addSubview(snapshotView)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0,
            options: .curveEaseOut,
            animations: {
                // changing the alphas
                fromVC.view.alpha = 0
                toVC.view.alpha = 1
                // move the snapshotView
                // passing `nil` to get a rect with repect to the key window
                snapshotView.frame = self.destinationImageView.convert(self.destinationImageView.bounds, to: nil)
        },
            completion: { _ in
                fromVC.view.alpha = 1
                toVC.view.alpha = 1
                
                self.sourceImageView.isHidden = false
                self.destinationImageView.isHidden = false
                
                snapshotView.removeFromSuperview()
                transitionContext.completeTransition(true)
        })
        
    }
}

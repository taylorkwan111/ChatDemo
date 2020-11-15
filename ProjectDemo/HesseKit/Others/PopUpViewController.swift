//
//  PopUpViewController.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 28/5/2018.
//  Copyright © 2018 bichenkk. All rights reserved.
//

import UIKit

@objc protocol PopupViewControllerDelegate: NSObjectProtocol {
    @objc optional func popupViewController(_ popupViewController: PopupViewController, willShowPopupView popupView: UIView)
    @objc optional func popupViewController(_ popupViewController: PopupViewController, didShowPopupView popupView: UIView)
    @objc optional func popupViewController(_ popupViewController: PopupViewController, willDismissPopupView popupView: UIView)
    @objc optional func popupViewController(_ popupViewController: PopupViewController, didDismissPopupView popupView: UIView)
    @objc optional func popupViewControllerWillDismiss(_ popupViewController: PopupViewController)
    @objc optional func popupViewControllerDidDismiss(_ popupViewController: PopupViewController)
    @objc optional func popupViewControllerShouldDismiss(_ popupViewController: PopupViewController) -> Bool
    
    @available(iOS 10.0, *)
    @objc optional func popupViewController(_ popupViewController: PopupViewController, shouldReverseDragToDismissAnimationBy animator: UIViewPropertyAnimator) -> Bool
}

class PopupViewController: UIViewController {
    
    /// Set this property with the view as main content to be popped up.
    var popupView: UIView?
    
    private let blackMask = UIView()
    
    /// This value controls the alpha when `blackMask` shows.
    var blackMaskMaxAlpha: CGFloat {
        return 0.3
    }
    
    weak var delegate: PopupViewControllerDelegate?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return presentingViewController?.preferredStatusBarStyle ?? .default
    }
    
    /// Always returns `.overFullScreen`
    override var modalPresentationStyle: UIModalPresentationStyle {
        set { super.modalPresentationStyle = .overFullScreen }
        get { return .overFullScreen }
    }
    
    /// The constraint that controls the vertical position of the popup view.
    var popupViewVerticalConstraint: NSLayoutConstraint?
    
    /// The dismissal animator (UIViewPropertyAnimator), cast it when you use it.
    var dismissalAnimator: NSObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBlackMask()
        if let popupView = popupView {
            setup(popupView: popupView)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presentPopupView()
    }
    
    
    
    // MARK: - Refine
    
    private func setupBlackMask() {
        blackMask.alpha = 0
        blackMask.backgroundColor = .black
        blackMask.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blackMask)
        
        blackMask.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blackMask.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        blackMask.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        blackMask.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    }
    
    private func setup(popupView: UIView) {
        view.addSubview(popupView)
        layout(popupView: popupView)
    }
    
    // MARK: Basic presenting and dismissing animations
    /// This value determines whether the view controller itself should be dismissed when popup view has completed its dismissal animation. The default value of this property is `true`.
    var exitOnPopupViewDismissal: Bool = true
    
    /// Shows the popup view animatedly.
    func presentPopupView() {
        guard let popupView = popupView else { return }
        delegate?.popupViewController?(self, willShowPopupView: popupView)
        let popupViewAnimation = self.presentAnimation(forPopupView: popupView)
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0,
            options: .curveEaseIn,
            animations: {
                self.blackMask.alpha = self.blackMaskMaxAlpha
                popupViewAnimation()
        }, completion: { _ in
            self.delegate?.popupViewController?(self, didShowPopupView: popupView)
        })
    }
    
//    var dismissalAnimator: UIViewPropertyAnimator?
    
    /// Dismiss the popup view animatedly.
    @objc func dismissPopupView() {
        guard delegate?.popupViewControllerShouldDismiss?(self) ?? true else { return }
        guard let popupView = popupView else { return }
        
        if #available(iOS 11.0, *) {
            // In iOS 11.0+, use UIViewPropertyAnimator
            delegate?.popupViewController?(self, willDismissPopupView: popupView)
            let popupViewDismissAnimation = self.dismissAnimation(forPopupView: popupView)
            let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) {
                self.blackMask.alpha = 0.0
                popupViewDismissAnimation()
            }
            animator.addCompletion { position in
                self.delegate?.popupViewController?(self, didDismissPopupView: popupView)
                
                if self.exitOnPopupViewDismissal {
                    self.delegate?.popupViewControllerWillDismiss?(self)
                    self.dismiss(animated: false) {
                        self.delegate?.popupViewControllerDidDismiss?(self)
                    }
                }
            }
            animator.startAnimation()
            dismissalAnimator = animator
            
        } else {
            // In earlier version of iOS, use UIView animation.
            delegate?.popupViewController?(self, willDismissPopupView: popupView)
            let popupViewDismissAnimation = self.dismissAnimation(forPopupView: popupView)
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: .curveEaseInOut,
                animations: {
                    self.blackMask.alpha = 0.0
                    popupViewDismissAnimation()
            }, completion: { _ in
                self.delegate?.popupViewController?(self, didDismissPopupView: popupView)
                
                if self.exitOnPopupViewDismissal {
                    self.delegate?.popupViewControllerWillDismiss?(self)
                    self.dismiss(animated: false) {
                        self.delegate?.popupViewControllerDidDismiss?(self)
                    }
                }
            })
        }
    }
    
    
    /// Layouts the popup view.
    /// By default, the implementation of this method lays out the popup view to the bottom edge of the view controller's view, that is exactly out of sight.
    /// You can override this method to have your own layout implementation.
    func layout(popupView: UIView) {
        guard let superView = popupView.superview else {
            fatalError("popupView.superview needs to be set first.")
        }
        popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
        
        let verticalConstraint = popupView.topAnchor.constraint(equalTo: superView.bottomAnchor)
        verticalConstraint.isActive = true
        popupViewVerticalConstraint = verticalConstraint
        
        superView.setNeedsUpdateConstraints()
    }
    
    
    /// Returns the animation for use when the popup view shows.
    /// You can override this method to have your own presenting animation.
    ///
    /// - Parameter popupView: The popup view to be shown.
    func presentAnimation(forPopupView popupView: UIView) -> () -> Void {
        guard let superView = popupView.superview else {
            fatalError("popupView.superview needs to be set first.")
        }
        popupViewVerticalConstraint?.isActive = false
        
        let verticalConstraint = popupView.centerYAnchor.constraint(equalTo: superView.centerYAnchor)
        verticalConstraint.isActive = true
        popupViewVerticalConstraint = verticalConstraint
        
        superView.setNeedsUpdateConstraints()
        return {
            superView.layoutIfNeeded()
        }
    }
    
    /// Returns the animation for use when the popup view dismisses.
    /// You can override this method to have your own dismissal animation.
    ///
    /// - Parameter popupView: The popup view to be dismissed.
    func dismissAnimation(forPopupView popupView: UIView) -> () -> Void {
        guard let superView = popupView.superview else {
            fatalError("popupView.superview needs to be set first.")
        }
        popupViewVerticalConstraint?.isActive = false
        
        let verticalConstraint = popupView.topAnchor.constraint(equalTo: superView.bottomAnchor)
        verticalConstraint.isActive = true
        popupViewVerticalConstraint = verticalConstraint
        
        superView.setNeedsUpdateConstraints()
        return {
            superView.layoutIfNeeded()
        }
    }
    
    // MARK: - Handling tap to dismiss
    
    /// This value determines whether the view controller itself can be dismissed when tapped on anywhere else except for the popup view. The default vaule of this property is `false`.
    var isTapToDismissEnabled: Bool = false {
        didSet {
            if isTapToDismissEnabled {
                let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapToDismiss(_:)))
                blackMask.addGestureRecognizer(tap)
                tapToDismissGestureRecognizer = tap
            } else {
                if let tap = tapToDismissGestureRecognizer, let view = tap.view {
                    view.removeGestureRecognizer(tap)
                    tap.removeTarget(nil, action: nil)
                    tapToDismissGestureRecognizer = nil
                }
            }
        }
    }
    
    private var tapToDismissGestureRecognizer: UITapGestureRecognizer?
    
    @objc private func handleTapToDismiss(_ sender: UITapGestureRecognizer) {
        dismissPopupView()
    }
    
    // MARK: - Supporting Drag to Dismiss
    
    /// The flag indicating whether Drag to Dismiss is supported or not. The value is `false` by default.
    var isDragToDismissSupported: Bool = false {
        didSet {
            if isDragToDismissSupported {
                let pan = UIPanGestureRecognizer(target: self, action: #selector(handleDragToDismissPanGesture(_:)))
                view.addGestureRecognizer(pan)
                dragToDismissPanGesture = pan
            } else {
                if let pan = dragToDismissPanGesture, let view = pan.view {
                    view.removeGestureRecognizer(pan)
                    pan.removeTarget(nil, action: nil)
                    dragToDismissPanGesture = nil
                }
            }
        }
    }
    
    /// The pan gesture to support Drag to Dismiss. If you set `isDragToDismissSupported` to `true`, it will instantiate an pan object for you.
    private(set) var dragToDismissPanGesture: UIPanGestureRecognizer?
    
    
    /// The action that `dragToDismissPanGesture` is sending.
    @objc private func handleDragToDismissPanGesture(_ sender: UIPanGestureRecognizer) {
        if #available(iOS 10.0, *) {
            switch sender.state {
            case .began:
                // Starts the dismiss animation that implemented with `UIViewPropertyAnimator`
                dismissPopupView()
                guard let animator = dismissalAnimator as? UIViewPropertyAnimator else { return }
                animator.pauseAnimation()
                
            case .changed:
                guard let animator = dismissalAnimator as? UIViewPropertyAnimator else { return }
                // Hopefully transitionY is in range of 0.0 ... 120.0
                let transitionY = sender.translation(in: sender.view).y
                animator.fractionComplete = min(max(0, transitionY), 120) / 120
                
            case .ended:
                guard let animator = dismissalAnimator as? UIViewPropertyAnimator else { return }
     
//                animator.isReversed = delegate?.popupViewController?(self, shouldReverseDragToDismissAnimationBy: animator) ?? false
                
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 10.0)
                
            default:
                break
                
            }
        }
    }
    
}



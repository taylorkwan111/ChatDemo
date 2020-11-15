//
//  BaseNavigationController.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 11/5/2019.
//  Copyright © 2019 Binatir. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return statusBarStyle
    }
    
    var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            if oldValue != statusBarStyle {
                setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
//        setNavigationBarTransparent(true)
        
        //        if !ThisDevice.isiPhoneXsLike {
        //            object_setClass(toolbar, HKToolbar.self)
        //        }
        //        object_setClass(toolbar, HKToolbar.self)
        
        statusBarStyle = topViewController?.preferredStatusBarStyle ?? .default
    }
    
    // The following changes are made because of scanning offline QR code doesn't fit well. More changes or fallback might be applied when needed. (Haven't sync to Provider app)
    private func setNavigationBarTransparent(_ isTransparent: Bool) {
//        navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationBar.shadowImage = UIImage()
    }
    
    private weak var viewControllerBeingPopped: UIViewController?
    private var navigationBarTintColorWhenPopping: UIColor?
    
    override func popViewController(animated: Bool) -> UIViewController? {
        viewControllerBeingPopped = viewControllers.last
        navigationBarTintColorWhenPopping = navigationBar.tintColor
        let viewController = super.popViewController(animated: animated)
        return viewController
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        statusBarStyle = viewController.preferredStatusBarStyle
        setToolbarHidden(viewController.toolbarItems?.isEmpty ?? true, animated: animated)
        
        // Handling transparent navigation bar preferrence specified by child view controllers
        // 4 cases: v -> v, iv -> iv, v -> iv, iv -> v (v for visible, iv for invisible)
        // should consider both pushing a new vc or popping an existing one
        let isVisibleNow = (navigationBar.background?.alpha ?? 0) >= 0.01
        let isVisibleSoon = !viewController.prefersTransparentNavigationBarWhenPushed // pushing is considered only
        
        switch (isVisibleNow, isVisibleSoon) {
        case (true, true), (false, false):
        break // simply do nothing
        case (true, false):
            navigationBar.animateBackground(show: false)
//            viewController.previousViewControllerInNavigationStack?.addFakeBar()
        //            animateSearchPaletteIfPossible(show: false)
        case (false, true):
            navigationBar.animateBackground(show: true)
            //            animateSearchPaletteIfPossible(show: true)
        }
        
        // When popping and then cancelled (only popping)
        navigationController.topViewController?.transitionCoordinator?.notifyWhenInteractionChanges { context in
            if context.isCancelled {
                // Do some clean-ups
                if let style = self.viewControllerBeingPopped?.preferredStatusBarStyle {
                    self.statusBarStyle = style
                }
                navigationController.navigationBar.animateBackground(show: isVisibleNow)
                navigationController.navigationBar.tintColor = self.navigationBarTintColorWhenPopping ?? .themeTint
            }
            self.viewControllerBeingPopped = nil
            self.navigationBarTintColorWhenPopping = nil
        }
        
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        viewController.removeFakeBar()
    }
    
}

extension BaseNavigationController {
    
    // In iOS 11, if set `navigationItem.searchController`, there is a managed searchPalette view that holds search bar and relevent views.
    // This property helps fix transition bug when pushing a new view controller.
    var searchPalette: UIView? {
        if let cls1 = NSClassFromString("_UINavigationControllerPaletteClippingView"),
            let cls2 = NSClassFromString("_UINavigationControllerManagedSearchPalette") {
            var v = view.subviews.first(where: {
                type(of: $0) == cls1
            })
            v = v?.subviews.first(where: {
                type(of: $0) == cls2
            })
            return v
        }
        return nil
    }
    
    func animateSearchPaletteIfPossible(show: Bool) {
        guard let searchPalette = searchPalette else { return }
        UIView.animate(withDuration: 0.25) {
            searchPalette.alpha = show ? 1.0 : 0.0
        }
    }
    
}

extension UIViewController {
    
    private struct PrefersTransparentNavigationBarWhenPushedKey {
        static var key = "prefersTransparentNavigationBarWhenPushed"
    }
    
    var prefersTransparentNavigationBarWhenPushed: Bool {
        get {
            return (objc_getAssociatedObject(self, &PrefersTransparentNavigationBarWhenPushedKey.key) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &PrefersTransparentNavigationBarWhenPushedKey.key, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
}

//// Runtime: Fake navigation bar when transitioning
//extension UIViewController {
//
//    private struct FakeBarKey {
//        static var key = "HesseKit_fakeNavigationBarKey"
//        static var colorKey = "HesseKit_fakeNavigationBarColorKey"
//    }
//
//    // The view to block the transparent/black background when transitioning with BaseNavigationController.
//    // This is used when the receiver is embedded in a non-translucent navigation bar, and with its `extendedLayoutIncludesOpaqueBars` is `false`.
//    private var hk_fakeBar: UIView? {
//        get {
//            return objc_getAssociatedObject(self, &FakeBarKey.key) as? UIView
//        }
//        set {
//            objc_setAssociatedObject(self, &FakeBarKey.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//
//    fileprivate func addFakeBar() {
//        if let superview = view.superview {
//            let fakeBar = UIView()
//            fakeBar.backgroundColor = fakeNavigationBarColor ?? .white
//            fakeBar.frame.size = CGSize(width: superview.bounds.width, height: view.frame.origin.y)
//            superview.addSubview(fakeBar)
//            hk_fakeBar = fakeBar
//        }
//    }
//
//    fileprivate func removeFakeBar() {
//        if let fakeBar = hk_fakeBar {
//            fakeBar.removeFromSuperview()
//            hk_fakeBar = nil
//        }
//    }
//
//    /// The background color used to fill the fake navigation bar when transitioning.
//    var fakeNavigationBarColor: UIColor? {
//        get {
//            return objc_getAssociatedObject(self, &FakeBarKey.colorKey) as? UIColor
//        }
//        set {
//            objc_setAssociatedObject(self, &FakeBarKey.colorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//}

extension UIViewController {
    var previousViewControllerInNavigationStack: UIViewController? {
        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return navigationController?.viewControllers[safe: index - 1]
        }
        return nil
    }
}

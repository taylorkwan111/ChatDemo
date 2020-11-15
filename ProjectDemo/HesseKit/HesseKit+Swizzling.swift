//
//  HesseKit+Swizzling.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 14/5/2018.
//  Copyright © 2018 bichenkk. All rights reserved.
//

import UIKit

// Here using runtime (swizzle/swizzling) to implement some global functionalities.
public extension UIViewController {
    
    static let exchangeViewDidLoad: Void = {
        let os = #selector(UIViewController.viewDidLoad)
        let ss = #selector(UIViewController.swizzledViewDidLoad)
        exchangeImplementations(originalSelector: os, swizzledSelector: ss)
        dprint("SWIZZLE WARNING: 'UIViewController.swizzledViewDidLoad' has been activated!")
    }()
    
    @objc private func swizzledViewDidLoad() {
        // hides backBarButtonItem's title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        // Make room for animation of navigation bar.
        extendedLayoutIncludesOpaqueBars = true
        
        swizzledViewDidLoad()
    }
    
    
    //    private static let exchangeViewWillAppear: Void = {
    //        let os = #selector(UIViewController.viewWillAppear)
    //        let ss = #selector(UIViewController.swizzledViewWillAppear)
    //        exchangeImplementations(originalSelector: os, swizzledSelector: ss)
    //        dprint("SWIZZLE WARNING: 'swizzledViewWillAppear' has been activated!")
    //    }()
    //
    //    private static let exchangeViewWillDisappear: Void = {
    //        let os = #selector(UIViewController.viewWillDisappear)
    //        let ss = #selector(UIViewController.swizzledViewWillDisappear)
    //        exchangeImplementations(originalSelector: os, swizzledSelector: ss)
    //        dprint("SWIZZLE WARNING: 'swizzledViewWillDisappear' has been activated!")
    //    }()
    
    
    //    @objc private func swizzledViewWillAppear() {
    //        swizzledViewWillAppear()
    //        if hidesNavigationBarBackgroundWhenVisible {
    //            navigationController?.viewWillAppearHideBackground()
    //        }
    //
    //    }
    
    //    @objc private func swizzledViewWillDisappear() {
    //        swizzledViewWillDisappear()
    //        if hidesNavigationBarBackgroundWhenVisible {
    //            navigationController?.viewWillDisappearShowBackground()
    //        }
    //    }
    
    
}

@available (iOS 11.0, *)
public extension UIView {
    
    static let exchangeSetAlpha: Void = {
        let os = #selector(setter: alpha)
        let ss = #selector(swizzledSetAlpha(_:))
        exchangeImplementations(originalSelector: os, swizzledSelector: ss)
        dprint("SWIZZLE WARNING: 'UIView.swizzledSetAlpha(_:)' has been activated!")
    }()
    
    @objc private func swizzledSetAlpha(_ alpha: CGFloat) {
        if let loyalAlpha = loyalAlpha, loyalAlpha != alpha {
            if type(of: self) == NSClassFromString("_UIBarBackground") {
                return
            }
        }
        swizzledSetAlpha(alpha)
    }
}


public extension UIView {
    
    private struct Key {
        static var loyalAlpha = "loyalAlpha"
    }
    
    /// A highly loyal ALPHA who won't be changed by system calls.
    /// This property is mainly used to animate navigation bar background
    @available (iOS 11.0, *)
    var loyalAlpha: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &Key.loyalAlpha) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &Key.loyalAlpha, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if let value = newValue {
                alpha = value
            }
        }
    }
}

public extension UISearchBar {
    
    private struct Key {
        static var cancelButtonTitle = "hesseKit_cancelButtonTitle"
    }
    
    var cancelButtonTitle: String? {
        get {
            return objc_getAssociatedObject(self, &Key.cancelButtonTitle) as? String
        }
        set {
            objc_setAssociatedObject(self, &Key.cancelButtonTitle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var cancelButton: UIButton? {
        if let cls: AnyClass = NSClassFromString("UINavigationButton") {
            return subviews.first?.subviews.first(where: { $0.isKind(of: cls) }) as? UIButton
        }
        return nil
    }

    static let exchangeLayoutSubviews: Void = {
        let os = #selector(layoutSubviews)
        let ss = #selector(swizzledLayoutSubviews)
        exchangeImplementations(originalSelector: os, swizzledSelector: ss)
        dprint("SWIZZLE WARNING: 'UISearchBar.exchangeLayoutSubviews' has been activated!")
    }()
    
    @objc private func swizzledLayoutSubviews() {
        swizzledLayoutSubviews()
        if let cancelButtonTitle = cancelButtonTitle {
            cancelButton?.setTitle(cancelButtonTitle, for: .normal)
        }
    }
}


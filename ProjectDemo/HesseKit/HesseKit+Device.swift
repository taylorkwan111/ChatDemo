//
//  HesseKit+Device.swift
//  HesseKit
//
//  Created by Hesse on 17/04/18.
//  Copyright © 2019年 HesseKit. All rights reserved.
//

import UIKit

public class Screen: NSObject {
    
    public static let bounds = CGRect(origin: .zero, size: size)
    public static let size = CGSize(width: width, height: height)
    public static let width = UIScreen.main.bounds.width
    public static let height = UIScreen.main.bounds.height
    
    public static var safeTopSpacing: CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        } else {
            return 0
        }
    }
    public static var safeBottomSpacing: CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        } else {
            return 0
        }
    }
    
    /// 屏幕宽高比。4 = 0.6666; 5 = 0.5633; 6; 0.5622; Plus = 0.5625
    public static let ratio = width / height
    
    public static func capture() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        defer { UIGraphicsEndImageContext() }
        UIApplication.shared.keyWindow?.drawHierarchy(in: bounds, afterScreenUpdates: false)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public static var coveringScreenshot: UIView?
    
    public static func addScreenshotOnKeyWindow() {
        let imageView = UIImageView(image: capture())
        coveringScreenshot = imageView
        UIApplication.shared.keyWindow?.addSubview(imageView)
    }
    
    public static func removeScreenshotFromKeyWindow(animations: ((UIView) -> Void)?) {
        let completion: (Bool) -> Void = { finished in
            coveringScreenshot?.removeFromSuperview()
            coveringScreenshot = nil
        }
        if let animations = animations {
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: .curveEaseInOut,
                animations: {
                    if let coveringScreenshot = coveringScreenshot {
                        animations(coveringScreenshot)
                    }
                },
                completion: completion)
        } else {
            completion(true)
        }
    }
}

public struct ThisDevice {
    
    public enum Device: Int {
        case iPhone4s       = 480
        case iPhoneSE       = 568
        case iPhone8        = 667
        case iPhone8Plus    = 736
        case iPhoneXs       = 812
        case iPhoneXsMax    = 896  // iPhoneXr is 896 but use @2x.
        case others         = 700
        
        var height: CGFloat {
            return CGFloat(rawValue)
        }
    }
    
    /// A flag to determine whether this device is a simulator.
    public static var isSimulator: Bool {
        #if arch(i386) || arch(x86_64)
            return true
        #else
            return false
        #endif
    }
    
    /// A flag to determine whether this device is a real device, not a simulator.
    public static var isRealDevice: Bool {
        return !isSimulator
    }
    
    /// This function detect whether this device is one of the given list of devices.
    ///
    /// - Parameter iPhones: The candidate list.
    /// - Returns: Whether this device is one of the given list of devices
    public static func isOneOf(_ iPhones: Device...) -> Bool {
        return !iPhones.map({ $0.height }).filter({ $0 == Screen.height }).isEmpty
    }
    
    public static var isiPhoneXsLike: Bool {
        return isOneOf(.iPhoneXs, .iPhoneXsMax)
    }
    
    /// A flag to determine whether this device has small screen, e.g. iPhone4s and iPhoneSE
    public static var hasSmallScreen: Bool {
        return isOneOf(.iPhone4s, .iPhoneSE)
    }
    
    /// A flag to determine whether this device has small screen, e.g. iPhone8Plus and iPhoneX (iPhone8 not included)
    public static var hasLargeScreen: Bool {
        return isOneOf(.iPhone8Plus, .iPhoneXs, .iPhoneXsMax)
    }
    
    /// A flag to determine whether this device is running iOS 8.x
    public static var isiOS8: Bool {
        if #available(iOS 8.0, *) {
            if #available(iOS 9.0, *) {} else { return true }
        }
        return false
    }
    /// A flag to determine whether this device is running iOS 9.x
    public static var isiOS9: Bool {
        if #available(iOS 9.0, *) {
            if #available(iOS 10.0, *) {} else { return true }
        }
        return false
    }
    /// A flag to determine whether this device is running iOS 10.x
    public static var isiOS10: Bool {
        if #available(iOS 10.0, *) {
            if #available(iOS 11.0, *) {} else { return true }
        }
        return false
    }
    /// A flag to determine whether this device is running iOS 11.x
    public static var isiOS11: Bool {
        if #available(iOS 11.0, *) {
            if #available(iOS 12.0, *) {} else { return true }
        }
        return false
    }
    /// A flag to determine whether this device is running iOS 12.x
    public static var isiOS21: Bool {
        if #available(iOS 12.0, *) {
            return true
        }
        return false
    }
    
}



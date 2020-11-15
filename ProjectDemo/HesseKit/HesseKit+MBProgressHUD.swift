//
//  HesseKit+MBProgressHUD.swift
//  HesseKit
//
//  Created by Hesse on 17/04/18.
//  Copyright © 2017年 HesseKit. All rights reserved.
//

#if canImport(MBProgressHUD)

import MBProgressHUD

extension UIImage {
    
    static let checkMark: UIImage? = {
        let size = CGSize(width: 37, height: 37)
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.setLineCap(.round)
        context?.setLineWidth(2.0)
        context?.move(to: CGPoint(x: 9, y: 20))
        context?.addLine(to: CGPoint(x: 15, y: 26))
        context?.addLine(to: CGPoint(x: 27, y: 12))
        context?.strokePath()
        return UIGraphicsGetImageFromCurrentImageContext()
    }()
    
    static let errorMark: UIImage? = {
        let size = CGSize(width: 37, height: 37)
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.setLineCap(.round)
        context?.setLineWidth(2.0)
        context?.move(to: CGPoint(x: 5, y: 5))
        context?.addLine(to: CGPoint(x: 32, y: 32))
        context?.move(to: CGPoint(x: 5, y: 32))
        context?.addLine(to: CGPoint(x: 32, y: 5))
        context?.strokePath()
        return UIGraphicsGetImageFromCurrentImageContext()
    }()
}

public extension MBProgressHUD {
    
    /// 变为显示”成功“的HUD
    ///
    /// - Parameters:
    ///   - text: 文字
    ///   - detailText: 小字
    ///   - duration: 显示时长
    func showSuccess(text: String,
                     detailText: String? = nil,
                     disappearAfter duration: TimeInterval = HesseKitConfig.defaultHUDDuration) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        return switchToCustomViewMode(with: .checkMark, labelText: text, detailText: detailText, disappearAfter: duration)
    }
    
    
    /// 变为显示”失败“的HUD
    ///
    /// - Parameters:
    ///   - text: 文字
    ///   - detailText: 小字
    ///   - duration: 显示时长
    func showError(text: String,
                   detailText: String? = nil,
                   disappearAfter duration: TimeInterval = HesseKitConfig.defaultHUDDuration) {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        return switchToCustomViewMode(with: .errorMark, labelText: text, detailText: detailText, disappearAfter: duration)
    }
    
    
    /// 变为显示Loading的HUD
    ///
    /// - Parameters:
    ///   - text: 文字
    ///   - detailText: 小字
    ///   - duration: 显示时长
    func showLoading(text: String,
                     detailText: String? = nil,
                     disappearAfter duration: TimeInterval = HesseKitConfig.defaultHUDDuration) {
        self.label.text = text
        self.label.font = HesseKitConfig.defaultHUDTextFont
        self.detailsLabel.text = detailText
        self.detailsLabel.font = HesseKitConfig.defaultHUDDetailTextFont
        self.mode = .indeterminate
        self.hide(animated: true, afterDelay: duration)
    }
    
    /// 私有方法。将HUD变为相应的样式。
    ///
    /// - Parameters:
    ///   - image: 样式主图
    ///   - labelText: 文字
    ///   - detailText: 小字
    ///   - duration: 显示时长
    private func switchToCustomViewMode(with image: UIImage?,
                                labelText: String,
                                detailText: String? = nil,
                                disappearAfter duration: TimeInterval) {
        let imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.white
        self.customView = imageView
        self.mode = .customView
        self.label.text = labelText
        self.label.font = HesseKitConfig.defaultHUDTextFont
        self.label.numberOfLines = 0
        self.detailsLabel.text = detailText
        self.detailsLabel.font = HesseKitConfig.defaultHUDDetailTextFont
        self.hide(animated: true, afterDelay: duration)
    }
}



public extension UIViewController {
    
    /// 返回正在执行的HUD
    var currentHUD: MBProgressHUD? {
        return MBProgressHUD(view: hudTargetView)
    }
    
    /// 要显示HUD的View。如果是UITableViewController或UICollectionViewController时，将HUD加载在其navigationController的view上。
    var hudTargetView: UIView {
        let isTVCorCVC = isKind(of: UITableViewController.self) || isKind(of: UICollectionViewController.self)
        if isTVCorCVC {
            return navigationController?.view ?? view
        }
        return view
    }
    
    /// 显示一个“正在Loading”的HUD
    ///
    /// - Parameter text: 附加文字
    /// - Returns: MBProgressHUD对象
    func showLoadingHUD(text: String? = HesseKitConfig.LocalizedText.loading) -> MBProgressHUD {
        let customView = UIActivityIndicatorView(style: .whiteLarge)
        customView.startAnimating()
        customView.hidesWhenStopped = true
        let hud = MBProgressHUD.showAdded(to: hudTargetView, animated: true)
        hud.mode = .customView
        hud.customView = customView
        hud.label.text = text
        hud.label.font = HesseKitConfig.defaultHUDTextFont
        return hud
    }
    
    
    /// 显示一个“失败”的HUD，自动消失
    ///
    /// - Parameters:
    ///   - text: 附加文字
    ///   - detailText: 小字
    ///   - duration: 显示时长
    func showErrorHUD(text: String,
                      detailText: String? = nil,
                      duration: TimeInterval = HesseKitConfig.defaultHUDDuration) {
        let hud = MBProgressHUD.showAdded(to: hudTargetView, animated: true)
        hud.showError(text: text, detailText: detailText, disappearAfter: duration)
    }
    
    
    /// 显示一个“成功”的HUD，自动消失
    ///
    /// - Parameters:
    ///   - text: 附加文字
    ///   - detailText: 小字
    ///   - duration: 显示时长
    func showSuccessHUD(text: String,
                        detailText: String? = nil,
                        duration: TimeInterval = HesseKitConfig.defaultHUDDuration) {
        let hud = MBProgressHUD.showAdded(to: hudTargetView, animated: true)
        hud.showSuccess(text: text, detailText: detailText, disappearAfter: duration)
    }
    
    
    /// 显示一个只有文字的HUD，自动消失
    ///
    /// - Parameters:
    ///   - text: 附加文字
    ///   - detailText: 小字
    ///   - duration: 显示时长
    func showTextOnlyHUD(text: String,
                         detailText: String? = nil,
                         disappearAfter duration: TimeInterval = HesseKitConfig.defaultHUDDuration) {
        let hud = MBProgressHUD.showAdded(to: hudTargetView, animated: true)
        hud.mode = .text
        hud.label.text = text
        hud.label.font = HesseKitConfig.defaultHUDTextFont
        hud.detailsLabel.text = detailText
        hud.detailsLabel.font = HesseKitConfig.defaultHUDDetailTextFont
        hud.hide(animated: true, afterDelay: duration)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func showDarkStyleTextHUDOnBottom(text: String,
                                      detailText: String? = nil,
                                      disappearAfter duration: TimeInterval = HesseKitConfig.defaultHUDDuration,
                                      additionalOffset: CGPoint = .zero) {
        let hud = MBProgressHUD.showAdded(to: hudTargetView, animated: true)
        hud.mode = .text
        hud.label.text = text
        hud.label.font = HesseKitConfig.defaultHUDTextFont
        hud.label.numberOfLines = 0
        hud.detailsLabel.text = detailText
        hud.detailsLabel.font = HesseKitConfig.defaultHUDDetailTextFont
        hud.offset = CGPoint(x: additionalOffset.x, y: (Screen.height / 2) - Screen.safeBottomSpacing - (navigationController?.toolbar.bounds.height ?? 0) - 100 + additionalOffset.y)
        hud.bezelView.backgroundColor = .darkGray
        hud.contentColor = .white
        hud.hide(animated: true, afterDelay: duration)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
}

#endif

//
//  HKRedDot.swift
//  HesseKit
//
//  Created by Hesse Huang on 19/2/11.
//  Copyright © 2019年 HesseKit. All rights reserved.
//

import UIKit

extension UIView {
    
    private static let redDotDefaultTag = 74914889
    
    /// Returns the red dot attached on the receiver, if any.
    var redDot: HKLabel? {
        return viewWithTag(UIView.redDotDefaultTag) as? HKLabel
    }
    
    /// Attaches a red dot onto the receiver.
    ///
    /// - Parameters:
    ///   - tag: The tag that would be assigned to the red dot view.
    ///   - center: The center of the red dot, or the top right corner of the receiver if `nil` is passed.
    @discardableResult
    func addRedDot(with tag: Int = UIView.redDotDefaultTag, text: String?, center: CGPoint? = nil, animated: Bool = false) -> HKLabel {
        
        removeRedDot(withTag: tag)
        
        let dot = HKLabel()
        dot.backgroundColor = .red
        dot.tag = tag
        addSubview(dot)

        if text == nil {
            dot.frame.size = CGSize(width: 8, height: 8)
        } else {
            dot.contentInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
            dot.font = .systemFont(ofSize: 11)
            dot.textColor = .white
            dot.text = text
            dot.textAlignment = .center
            dot.sizeToFit()
        }

        let height = ceil(max(dot.bounds.width, dot.bounds.height))
        dot.bounds.size.width = height
        dot.bounds.size.height = height
        dot.center = center ?? CGPoint(x: bounds.size.width, y: 0)
        dot.layer.cornerRadius = height / 2
        dot.layer.masksToBounds = true
        
        if animated {
            dot.transform = CGAffineTransform(scaleX: .leastNonzeroMagnitude, y: .leastNonzeroMagnitude)
            let animations = {
                dot.transform = CGAffineTransform.identity
            }
            UIView.animate(withDuration: 0.4,
                           delay: 1.0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0,
                           options: .curveEaseIn,
                           animations: animations,
                           completion: nil)
        }
        
        return dot
    }
    
    
    /// Removed a red dot on the receiver, if any.
    ///
    /// - Parameter tag: The tag assigned with the red dot.
    func removeRedDot(withTag tag: Int = UIView.redDotDefaultTag, animated: Bool = false) {
        guard let dot = viewWithTag(tag) else { return }
        let animations1 = {
            dot.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }
        let animations2 = {
            dot.alpha = 0.0
        }
        let completion = { (finished: Bool) in
            dot.removeFromSuperview()
        }
        if animated {
            UIView.animate(withDuration: 0.4,
                           delay: 1.0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0,
                           options: .curveEaseIn,
                           animations: animations1,
                           completion: nil)
            UIView.animate(withDuration: 0.35,
                           delay: 1.0,
                           options: .curveLinear,
                           animations: animations2,
                           completion: completion)
        } else {
            animations1()
            animations2()
            completion(true)
        }
        
    }
    
    func addConstraintsToAttachTopRightCornerOfSuperview(offset: UIOffset = .zero) {
        if let view = superview {
            translatesAutoresizingMaskIntoConstraints = false
            centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: offset.horizontal).isActive = true
            centerYAnchor.constraint(equalTo: view.topAnchor, constant: offset.vertical).isActive = true
            widthAnchor.constraint(equalToConstant: bounds.width).isActive = true
            heightAnchor.constraint(equalToConstant: bounds.height).isActive = true
        }
    }

}



extension UITabBarController {
    
    func addRedDotOnTabBarItem(atIndex index: Int, text: String? = nil) {
        tabBarIconImageView(atIndex: index)?.addRedDot(text: text)
    }
    
    func removeRedDotFromTabBarItem(atIndex index: Int) {
        tabBarIconImageView(atIndex: index)?.removeRedDot()
    }
    
}

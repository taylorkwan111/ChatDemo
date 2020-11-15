//
//  BezierPathRoundingView.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 23/8/2018.
//  Copyright © 2018 Binatir. All rights reserved.
//

import UIKit

class BezierPathRoundingView: UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat = LayoutConstant.cornerRadius {
        didSet {
            update()
        }
    }
    
    @IBInspectable
    var topCornersRouding: Bool = false {
        didSet {
            update()
        }
    }
    
    @IBInspectable
    var bottomCornersRouding: Bool = false {
        didSet {
            update()
        }
    }
    
    var maskPaddings: UIEdgeInsets = .zero {
        didSet {
            update()
        }
    }
    
    /// The rounding corners of the view. If this properity is set with non-nil value, `topCornersRouding` and `bottomCornersRouding` will be ignored and take no effect.
    var roundingCorners: UIRectCorner?
    
    private var roundedRect: CGRect = .zero

    private lazy var maskLayer: CAShapeLayer = {
        let mask = CAShapeLayer()
        layer.mask = mask
        return mask
    }()
    
    override func awakeFromNib() {
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        update()
    }
    
    private var roundedPath: UIBezierPath {
        var roundingCorners: UIRectCorner = []
        if let corners = self.roundingCorners {
            roundingCorners = corners
        } else {
            if topCornersRouding {
                roundingCorners.insert([.topLeft, .topRight])
            }
            if bottomCornersRouding {
                roundingCorners.insert([.bottomLeft, .bottomRight])
            }
        }
        return UIBezierPath(roundedRect: roundedRect, byRoundingCorners: roundingCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
    }
    
    
    private func update() {
        roundedRect = bounds
        roundedRect.size.width -= maskPaddings.left + maskPaddings.right
        roundedRect.size.height -= maskPaddings.top + maskPaddings.bottom
        roundedRect.origin.x = maskPaddings.left
        roundedRect.origin.y = maskPaddings.top
        updateMask()
    }
    
    private func updateMask() {
        maskLayer.frame = bounds
        maskLayer.path = roundedPath.cgPath
    }


}

//
//  FilledPageControl.swift
//  PageControls
//
//  Created by Kyle Zaragoza on 8/6/16.
//  Copyright © 2016 Kyle Zaragoza. All rights reserved.
//

import UIKit

enum FilledPageControlItemShape {
    case square, circle
}

class FilledPageControl: UIView {
    
    // MARK: - PageControl
    
    @IBInspectable var pageCount: Int = 0 {
        didSet {
            updateNumberOfPages(with: pageCount)
        }
    }
    @IBInspectable var progress: CGFloat = 0 {
        didSet {
            updateActivePageIndicatorMasks(forProgress: progress)
        }
    }
    var currentPage: Int {
        return Int(round(progress))
    }
    
    var shape: FilledPageControlItemShape = .circle {
        didSet {
            updateActivePageIndicatorMasks(forProgress: progress)
        }
    }
    
    
    // MARK: - Appearance
    
    override var tintColor: UIColor! {
        didSet {
            inactiveLayers.forEach() { $0.backgroundColor = tintColor.cgColor }
        }
    }
    @IBInspectable var inactiveRingWidth: CGFloat = 1 {
        didSet {
            updateActivePageIndicatorMasks(forProgress: progress)
        }
    }
    @IBInspectable var indicatorPadding: CGFloat = 6 {
        didSet {
            layoutPageIndicators(with: inactiveLayers)
        }
    }
    @IBInspectable var indicatorRadius: CGFloat = 3 {
        didSet {
            layoutPageIndicators(with: inactiveLayers)
        }
    }
    
    var indicatorDiameter: CGFloat {
        return indicatorRadius * 2
    }
    var inactiveLayers = [CALayer]()
    
    
    // MARK: - State Update
    
    func updateNumberOfPages(with count: Int) {
        // no need to update
        guard count != inactiveLayers.count else { return }
        // reset current layout
        inactiveLayers.forEach { $0.removeFromSuperlayer() }
        inactiveLayers = [CALayer]()
        // add layers for new page count
        for _ in 0 ..< count {
            let layer = CALayer()
            layer.backgroundColor = self.tintColor.cgColor
            self.layer.addSublayer(layer)
            inactiveLayers.append(layer)
        }
        
        layoutPageIndicators(with: inactiveLayers)
        updateActivePageIndicatorMasks(forProgress: progress)
        self.invalidateIntrinsicContentSize()
    }
    
    
    // MARK: - Layout
    
    func updateActivePageIndicatorMasks(forProgress progress: CGFloat) {
        // ignore if progress is outside of page indicators' bounds
        guard progress >= 0 && progress <= CGFloat(pageCount - 1) else { return }
        
        // mask rect w/ default stroke width
        let insetRect = CGRect(x: 0, y: 0, width: indicatorDiameter, height: indicatorDiameter).insetBy(dx: inactiveRingWidth, dy: inactiveRingWidth)
        let leftPageFloat = trunc(progress)
        let leftPageInt = Int(progress)
        
        // inset right moving page indicator
        let spaceToMove = insetRect.width / 2
        let percentPastLeftIndicator = progress - leftPageFloat
        let additionalSpaceToInsetRight = spaceToMove * percentPastLeftIndicator
        let closestRightInsetRect = insetRect.insetBy(dx: additionalSpaceToInsetRight, dy: additionalSpaceToInsetRight)
        
        // inset left moving page indicator
        let additionalSpaceToInsetLeft = (1 - percentPastLeftIndicator) * spaceToMove
        let closestLeftInsetRect = insetRect.insetBy(dx: additionalSpaceToInsetLeft, dy: additionalSpaceToInsetLeft)
        
        // adjust masks
        for (idx, layer) in inactiveLayers.enumerated() {
            let maskLayer = CAShapeLayer()
            maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
            
            let boundsPath = UIBezierPath(rect: layer.bounds)
            let circlePath: UIBezierPath
            if leftPageInt == idx {
                switch shape {
                case .square:
                    circlePath = UIBezierPath(rect: closestLeftInsetRect)
                case .circle:
                    circlePath = UIBezierPath(ovalIn: closestLeftInsetRect)
                }
                
            } else if leftPageInt + 1 == idx {
                switch shape {
                case .square:
                    circlePath = UIBezierPath(rect: closestRightInsetRect)
                case .circle:
                    circlePath = UIBezierPath(ovalIn: closestRightInsetRect)
                }

            } else {
                switch shape {
                case .square:
                    circlePath = UIBezierPath(rect: insetRect)
                case .circle:
                    circlePath = UIBezierPath(ovalIn: insetRect)
                }
            }
            boundsPath.append(circlePath)
            maskLayer.path = boundsPath.cgPath
            layer.mask = maskLayer
        }
    }
    
    func layoutPageIndicators(with layers: [CALayer]) {
        let layerDiameter = indicatorRadius * 2
        var layerFrame = CGRect(x: 0, y: 0, width: layerDiameter, height: layerDiameter)
        layers.forEach() { (layer: CALayer) in
            layer.cornerRadius = self.indicatorRadius
            layer.frame = layerFrame
            layerFrame.origin.x += layerDiameter + indicatorPadding
        }
    }
    
    override var intrinsicContentSize : CGSize {
        return sizeThatFits(CGSize.zero)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layerDiameter = indicatorRadius * 2
        return CGSize(width: CGFloat(inactiveLayers.count) * layerDiameter + CGFloat(inactiveLayers.count - 1) * indicatorPadding,
                      height: layerDiameter)
    }
}


extension FilledPageControl: UIScrollViewDelegate {
    
    // 随着 scrollView 的 滑动情况刷新 UI，在 UIScrollViewDelegate 的 scrollViewDidScroll(_:) 中调用此方法。
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.bounds.width
        let progressInPage = scrollView.contentOffset.x - (page * scrollView.bounds.width)
        progress = CGFloat(page) + progressInPage
    }
}

//
//  HKGradientView.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 2018/1/15.
//  Copyright © 2018年 HesseKit. All rights reserved.
//

import UIKit

class HKGradientView: UIView {
    
    override var frame: CGRect {
        didSet {
            gradientLayer?.frame = bounds
        }
    }

    private(set) var gradientLayer: CAGradientLayer!
    
    init(frame: CGRect, toColor: UIColor, minAlpha: CGFloat, maxAlpha: CGFloat, from: UIView.GradientLayerChangingDirection, to: UIView.GradientLayerChangingDirection) {
        super.init(frame: frame)
        gradientLayer = addTransparentGradientLayer(frame: frame, toColor: toColor, minAlpha: minAlpha, maxAlpha: maxAlpha, from: from, to: to)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



}

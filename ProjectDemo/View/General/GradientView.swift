//
//  GradientView.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 12/7/2018.
//  Copyright © 2018 Binatir. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor.clear {
        didSet {
            updateLayer()
        }
    }
    @IBInspectable var endColor: UIColor = UIColor.clear {
        didSet {
            updateLayer()
        }
    }

    @IBInspectable var startPoint: CGPoint = CGPoint(x: 0, y: 0) {
        didSet{
            updateLayer()
        }
    }
    
    @IBInspectable var endPoint: CGPoint = CGPoint(x: 0, y: 1) {
        didSet{
            updateLayer()
        }
    }
    
    var isHorizontal: Bool {
        set {
            startPoint = CGPoint(x: 0, y: 0)
            endPoint = CGPoint(x: 1, y: 0)
        }
        get {
            return startPoint == CGPoint(x: 0, y: 0) && endPoint == CGPoint(x: 1, y: 0)
        }
    }
    
    private let gradientLayer = CAGradientLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        updateLayer()
    }
    
    private func updateLayer() {
        gradientLayer.frame = bounds
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.zPosition = -1
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        if gradientLayer.superlayer == nil {
            layer.addSublayer(gradientLayer)
        }
    }
}


//
//  CardLikeContainerView.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 20/8/2018.
//  Copyright © 2018 Binatir. All rights reserved.
//

import UIKit

class CardLikeContainerView: UIView {
    
    @IBInspectable
    var shadowHeight: CGFloat = 4 {
        didSet {
            layer.shadowOffset.height = shadowHeight
        }
    }
    
    @IBInspectable
    var shadowWidth: CGFloat = 0 {
        didSet {
            layer.shadowOffset.width = shadowWidth
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor = #colorLiteral(red: 0.8196078431, green: 0.8196078431, blue: 0.8196078431, alpha: 1) {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float = 0.5 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable
    var shadowBlur: CGFloat = 10 {
        didSet {
            layer.shadowRadius = shadowBlur / 2
        }
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
        layer.cornerRadius = LayoutConstant.cardLikeContainerCornerRadius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: shadowWidth, height: shadowHeight)
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowBlur / 2
    }
}


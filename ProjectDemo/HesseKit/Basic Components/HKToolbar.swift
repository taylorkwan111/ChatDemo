//
//  HKToolbar.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 10/10/2018.
//  Copyright © 2018 Binatir. All rights reserved.
//

import UIKit

class HKToolbar: UIToolbar {
    
    var height: CGFloat {
        return 54
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = height
        return size
    }
    
}

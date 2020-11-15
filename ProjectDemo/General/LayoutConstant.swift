//
//  LayoutConstant.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 15/5/2019.
//  Copyright © 2019 Binatir. All rights reserved.
//

import UIKit

struct LayoutConstant {
    /// Default value is 20.
    static let viewMargin           = CGFloat(20)
    /// Default value is 25.
    static let viewCornerRadius     = CGFloat(25)
    /// Default value is 40.
    static let textFieldHeight      = CGFloat(40)
    /// Default value is 50.
    static let bottomButtonHeight   = CGFloat(50)
    /// Default value is 72% Screen width.
    static let alertWidth           = 270.0 / 375.0 * UIScreen.main.bounds.width
    /// Default value is 75.
    static let labeledGrayTextFieldHeight = CGFloat(75)
    /// Default value is 13.
    static let cardLikeContainerCornerRadius = CGFloat(13)
    /// Default value is 40 (small screen) or 48 (others).
    static var proceedButtonHeight: CGFloat {
        return ThisDevice.hasSmallScreen ? 40 : 48
    }
    /// Default value is 10.
    static let homeCellSpacing      = CGFloat(10)
    
    /// Default value is 4.
    static let cornerRadius         = CGFloat(6)
    
    /// Default value is (20, 20, 20, 20)
    static let viewMargins               = UIEdgeInsets(top: viewMargin,
                                                        left: viewMargin,
                                                        bottom: viewMargin,
                                                        right: viewMargin)
    /// Default value is 20(leading), 20(trailling)
    static let cardLikeCellPadding       = UIEdgeInsets(top: 0,
                                                        left: viewMargin,
                                                        bottom: 0,
                                                        right: viewMargin)
    /// Default value is 36(leading), 36(trailling)
    static let cardLikeTableViewInsets   = UIEdgeInsets(top: 0,
                                                        left: viewMargin + 16,
                                                        bottom: 0,
                                                        right: viewMargin + 16)

}

extension UIEdgeInsets {
    static var viewMargins: UIEdgeInsets {
        return UIEdgeInsets(top: LayoutConstant.viewMargin,
                            left: LayoutConstant.viewMargin,
                            bottom: LayoutConstant.viewMargin,
                            right: LayoutConstant.viewMargin)
    }
}


//
//  UIColorExtension.swift
//  inDinero
//
//  Created by KK Chen on 9/12/2016.
//  Copyright © 2016 inDinero. All rights reserved.
//

import UIKit

extension UIColor {
    
    class var hightlightLightGray: UIColor {
        return UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
    }
    
    class var placeholderLightGray: UIColor {
        return UIColor(red: 113/255.0, green: 116/255.0, blue: 125/255.0, alpha: 1)
    }

    class var themeTint: UIColor {
        return #colorLiteral(red: 0.7917277813, green: 0.8772280812, blue: 0.8928217292, alpha: 1)
    }
    class var themeLightTint: UIColor {
        return #colorLiteral(red: 0.4800236183, green: 0.7993328652, blue: 0.7977005581, alpha: 1)
    }
    
    static var themeBlack: UIColor {
        return UIColor(hexCode: "333333")
    }
    static var themeLightBlack: UIColor {
        return UIColor(hexCode: "808080")
    }

    /// The gray color used when something disabled, eg. a button
    static var themeDisabledGray: UIColor {
        return UIColor(hexCode: "BBBBBB")
    }
    class var themeTextBlack: UIColor {
        return UIColor(hexCode: "161616")
    }
    class var themeTextDarkGray: UIColor {
        return UIColor(hexCode: "606060")
    }
    class var themeTextLightGray: UIColor {
        return UIColor(hexCode: "9B9B9B")
    }
    class var themeHairlineLightGray: UIColor {
        return UIColor(hexCode: "EFEFEF")
    }
    class var themeBackgroundLightGray: UIColor {
        return #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
    }
    class var themeAvailableGreen: UIColor {
        return #colorLiteral(red: 0.2901960784, green: 0.8509803922, blue: 0.3882352941, alpha: 1)
    }
    static var themeMaleBlue: UIColor {
        return #colorLiteral(red: 0.1176470588, green: 0.5647058824, blue: 1, alpha: 1)
    }
    static var themeFemaleRed: UIColor {
        return #colorLiteral(red: 1, green: 0.2784313725, blue: 0.3411764706, alpha: 1)
    }
    static var themeDangerRed: UIColor {
        return #colorLiteral(red: 1, green: 0.1450980392, blue: 0.1529411765, alpha: 1)
    }
    static var themePendingYellow: UIColor {
        return #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    }
    
    static var pdfRed: UIColor {
        return #colorLiteral(red: 0.8862745098, green: 0.3411764706, blue: 0.2980392157, alpha: 1)
    }
    static var txtLightBlue: UIColor {
        return #colorLiteral(red: 0.6078431373, green: 0.7882352941, blue: 1, alpha: 1)
    }

    
    static var searchBarFieldGray: UIColor {
        return UIColor(hexCode: "F5F5F5")
    }
    
    static var tableViewCellDefaultSelectedColor: UIColor {
        return #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)
    }


}

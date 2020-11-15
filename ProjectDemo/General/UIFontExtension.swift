//
//  UIFontExtention.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 11/5/2019.
//  Copyright © 2019 Binatir. All rights reserved.
//

import UIKit

extension UIFont {
    
    static func printAllFontNames() {
        for family: String in UIFont.familyNames {
            let names = UIFont.fontNames(forFamilyName: family)
            print("\(family): \(names)")
        }
    }
    
    static func themeFont(ofSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        let fontName: (_ weight: UIFont.Weight) -> String = {
            switch $0 {
            case UIFont.Weight.thin, UIFont.Weight.light, UIFont.Weight.ultraLight:
                return "FilsonSoft-Light"
            case UIFont.Weight.regular:
                return "FilsonProRegular"
            case UIFont.Weight.bold, UIFont.Weight.heavy, UIFont.Weight.black:
                return "FilsonProBold"
            case UIFont.Weight.semibold:
                return "FilsonSoftMedium"
            default:
                return "GothamLight"
            }
        }
        return UIFont(name: fontName(weight), size: ofSize) ?? UIFont.systemFont(ofSize: ofSize, weight: weight)
    }
    
    static func textFieldFont() -> UIFont {
        let size: CGFloat = CGFloat(17)
        return UIFont.themeFont(ofSize: size, weight: UIFont.Weight.regular)
    }
    
    class var navigationBarTitleFont: UIFont {
        let size: CGFloat = CGFloat(18)
        return UIFont.themeFont(ofSize: size, weight: UIFont.Weight.black)
    }
    
    class var navigationBarLargeTitleFont: UIFont {
        let size: CGFloat = CGFloat(32)
        return UIFont.themeFont(ofSize: size, weight: UIFont.Weight.black)
    }
    
    static func barButtonItemFont() -> UIFont {
        let size: CGFloat = CGFloat(14)
        return UIFont.themeFont(ofSize: size, weight: UIFont.Weight.regular)
    }
    
    class var roundedButtonFont: UIFont {
        return UIFont.themeFont(ofSize: 15, weight: UIFont.Weight.semibold)
    }
    
    static var loginTitle: UIFont {
        return .systemFont(ofSize: 30, weight: .bold)
    }
    static var loginSubtitle: UIFont {
        return .systemFont(ofSize: 20)
    }
    static var loginAdditionalButton: UIFont {
        return .systemFont(ofSize: 15)
    }
}


extension UIFont {
    
    enum ThemeSize: CGFloat {
        case title      = 22.0
        case section    = 20.0
        case regular    = 17.0
        case additional = 15.0
        case tiny       = 13.0
    }
    
    // Theme font option =  0
    static var titleBold: UIFont {
        return .systemFont(ofSize: ThemeSize.title.rawValue, weight: .bold)
    }
    // Theme font option =  1
    static var titleRegular: UIFont {
        return .systemFont(ofSize: ThemeSize.title.rawValue)
    }
    // Theme font option =  2
    static var sectionBold: UIFont {
        return .systemFont(ofSize: ThemeSize.section.rawValue, weight: .bold)
    }
    // Theme font option =  3
    static var sectionRegular: UIFont {
        return .systemFont(ofSize: ThemeSize.section.rawValue)
    }
    // Theme font option =  4
    static var regularBold: UIFont {
        return .systemFont(ofSize: ThemeSize.regular.rawValue, weight: .bold)
    }
    // Theme font option =  5
    static var regularRegular: UIFont {
        return .systemFont(ofSize: ThemeSize.regular.rawValue)
    }
    // Theme font option =  6
    static var additionalBold: UIFont {
        return .systemFont(ofSize: ThemeSize.additional.rawValue, weight: .bold)
    }
    // Theme font option =  7
    static var additionalRegular: UIFont {
        return .systemFont(ofSize: ThemeSize.additional.rawValue)
    }
    // Theme font option =  8
    static var tinyBold: UIFont {
        return .systemFont(ofSize: ThemeSize.tiny.rawValue, weight: .bold)
    }
    // Theme font option =  9
    static var tinyRegular: UIFont {
        return .systemFont(ofSize: ThemeSize.tiny.rawValue)
    }
    
}

extension UILabel {
    @IBInspectable
    var themeFontOption: Int {
        get { return -1 }
        set {
            switch newValue {
            case 0:     font = .titleBold
            case 1:     font = .titleRegular
            case 2:     font = .sectionBold
            case 3:     font = .sectionRegular
            case 4:     font = .regularBold
            case 5:     font = .regularRegular
            case 6:     font = .additionalBold
            case 7:     font = .additionalRegular
            default: break
            }
        }
    }
    
}

extension UIButton {
    @IBInspectable
    var themeFontOption: Int {
        get { return -1 }
        set { titleLabel?.themeFontOption = newValue }
    }
}

class BITitleLabel: HKLabel {
    override func setCustomFont() {
        font = .systemFont(ofSize: 26)
    }
}

class BIBoldTitleLabel: BITitleLabel {
    override func setCustomFont() {
        font = .systemFont(ofSize: 26, weight: .bold)
    }
}

class BISectionLabel: HKLabel {
    override func setCustomFont() {
        font = .systemFont(ofSize: 20)
    }
}

class BIBoldSectionLabel: BISectionLabel {
    override func setCustomFont() {
        font = .systemFont(ofSize: 20, weight: .bold)
    }
}

class BIRegularLabel: HKLabel {
    override func setCustomFont() {
        font = .systemFont(ofSize: 17)
    }
}

class BIBoldRegularLabel: BIRegularLabel {
    override func setCustomFont() {
        font = .systemFont(ofSize: 17, weight: .bold)
    }
}

class BIAdditionalLabel: HKLabel {
    override func setCustomFont() {
        font = .systemFont(ofSize: 15)
    }
}

class BIBoldAdditionalLabel: BIAdditionalLabel {
    override func setCustomFont() {
        font = .systemFont(ofSize: 15, weight: .bold)
    }
}

class BITinyLabel: HKLabel {
    override func setCustomFont() {
        font = .systemFont(ofSize: 13)
    }
}

class BIBoldTinyLabel: BITinyLabel {
    override func setCustomFont() {
        font = .systemFont(ofSize: 13, weight: .bold)
    }
}

class BIAddtionalButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        titleLabel?.font = .systemFont(ofSize: 15)
    }
    
}

class BIBoldAddtionalButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
    }
    
}

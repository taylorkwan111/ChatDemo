//
//  UILabelExtension.swift
//  MSocial
//
//  Created by KK Chen on 12/9/2017.
//  Copyright © 2017 Millennium Hotels and Resorts. All rights reserved.
//

import UIKit

extension UILabel {
    
    func setCrossedText(_ text: String?) {
        let attrString = NSAttributedString(string: text ?? "", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        attributedText = attrString
    }
    
}

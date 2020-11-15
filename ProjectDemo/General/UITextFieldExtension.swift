//
//  UITextFieldExtension.swift
//  inDinero
//
//  Created by KK Chen on 28/1/2017.
//  Copyright © 2017 inDinero. All rights reserved.
//

import UIKit

extension UITextField {
    
    func setPlaceholder(_ placeholder: String, color: UIColor = .placeholderLightGray) {
        let placeholder = NSAttributedString(string: placeholder,
                                 attributes: [NSAttributedString.Key.foregroundColor:color])
        attributedPlaceholder = placeholder
    }
    
}

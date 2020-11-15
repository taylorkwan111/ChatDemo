//
//  HKSearchBar.swift
//  HesseKit
//
//  Created by Hesse Huang on 24/8/2018.
//  Copyright © 2018 HesseKit. All rights reserved.
//

import UIKit

class HKSearchBar: UISearchBar {
    
    @IBInspectable
    var textFieldBackgroundColor: UIColor? {
        set { textField?.backgroundColor = newValue }
        get { return textField?.backgroundColor }
    }
    
}

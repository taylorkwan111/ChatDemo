//
//  GenderSelectionView.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 10/9/2018.
//  Copyright © 2018 Binatir. All rights reserved.
//

import UIKit

final class GenderSelectionView: UIView, XibInitiable {

    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var unknownButton: UIButton!
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: Screen.width, height: 108)
    }

 
}

//
//  HesseKit+SnapKit.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 20/5/2019.
//  Copyright © 2019 HesseKit. All rights reserved.
//

#if canImport(SnapKit)
import SnapKit

extension UIViewController {
    
    var viewOrItsSafeAreaLayoutGuide: ConstraintRelatableTarget {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide
        } else {
            return view
        }
    }
    
}

#endif

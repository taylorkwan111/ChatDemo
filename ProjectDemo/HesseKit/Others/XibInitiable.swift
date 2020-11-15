//
//  XibInitiable.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 31/7/2018.
//  Copyright © 2018 Binatir. All rights reserved.
//

import UIKit

protocol XibInitiable: class {
    static func initFromXib() -> Self
}

extension XibInitiable where Self: UIView {
    static func initFromXib() -> Self {
        return Bundle.main.loadNibNamed(self.description().components(separatedBy: ".").last ?? "", owner: nil, options: nil)![0] as! Self
    }
}

extension UITableViewHeaderFooterView {
    class var nib: UINib? {
        return UINib(nibName: NSStringFromClass(self).components(separatedBy: ".").last ?? "", bundle: nil)
    }
}

extension UITableViewCell {
    var superTableView: UITableView? {
        return superview as? UITableView
    }
    
    class var nib: UINib? {
        return UINib(nibName: NSStringFromClass(self).components(separatedBy: ".").last ?? "", bundle: nil)
    }
}

extension UICollectionReusableView {
    class var nib: UINib? {
        return UINib(nibName: NSStringFromClass(self).components(separatedBy: ".").last ?? "", bundle: nil)
    }
}


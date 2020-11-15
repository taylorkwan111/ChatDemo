//
//  UITableViewExtension.swift
//  MSocial
//
//  Created by KK Chen on 30/8/2017.
//  Copyright © 2017 Millennium Hotels and Resorts. All rights reserved.
//

import UIKit

extension UITableView {
    
    var selfResizingTableHeaderView: UIView? {
        get {
            return tableHeaderView
        }
        set {
            tableHeaderView = newValue
            newValue?.setNeedsLayout()
            newValue?.layoutIfNeeded()
            newValue?.frame.size = newValue?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero
            tableHeaderView = newValue
        }
    }
    
    var selfResizingTableFooterView: UIView? {
        get {
            return tableFooterView
        }
        set {
            tableFooterView = newValue
            newValue?.setNeedsLayout()
            newValue?.layoutIfNeeded()
            newValue?.frame.size = newValue?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero
            tableFooterView = newValue
        }
    }
    
}

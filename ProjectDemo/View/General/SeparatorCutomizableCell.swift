//
//  SeparatorCutomizableCell.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 13/7/2018.
//  Copyright © 2018 Binatir. All rights reserved.
//

#if canImport(SnapKit)
import SnapKit
import UIKit

class SeparatorCutomizableCell: UITableViewCell {
    
    /// The leading space of separator. By default, 13pt. Changing this property triggers the separator relayout.
    var separatorLeadingSpace: CGFloat {
        return 0
    }
    
    var separatorTrailingSpace: CGFloat {
        return 0
    }
    
    var separatorThickness: CGFloat {
        return 3
    }
    
    /// The view that serves as a separator. You may change it for customization.
    let separator = UIView()
    
    /// Whether the separator is hidden or not.
    var isSeparatorHidden: Bool {
        get {
            return separator.isHidden
        }
        set {
            separator.isHidden = newValue
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(separator)
        separator.backgroundColor = .lightGray
        updateLayout()
    }
    
    private func updateLayout() {
        self.snp.removeConstraints()
        self.separator.snp.removeConstraints()
        separator.snp.makeConstraints { make in
            make.height.equalTo(separatorThickness)
            make.bottom.equalTo(self)
            make.leading.equalTo(self).offset(separatorLeadingSpace).priority(750)
            make.trailing.equalTo(self).offset(-separatorTrailingSpace).priority(750)
        }
    }
    
}

#endif

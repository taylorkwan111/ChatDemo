//
//  CircledAvatarView.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 10/9/2018.
//  Copyright © 2018 Binatir. All rights reserved.
//

#if canImport(SnapKit)
import SnapKit
import UIKit

// The avatar view with a camera button.
class CircledAvatarView: UIView {
    
    let avatarButton = UIButton(type: .system)
    let cameraIconImageView = UIImageView(image: UIImage(named: "icon_upload_tiny"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let avatarButtonHeight: CGFloat = 100
        avatarButton.layer.borderColor = UIColor.themeHairlineLightGray.cgColor
        avatarButton.layer.borderWidth = 1
        avatarButton.layer.cornerRadius = LayoutConstant.cornerRadius
        avatarButton.layer.masksToBounds = true
        addSubview(avatarButton)
        avatarButton.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(avatarButtonHeight)
        }
        
        addSubview(cameraIconImageView)
        cameraIconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerX.equalTo(avatarButton.snp.trailing)
            make.bottom.equalTo(avatarButton).offset(4)
        }
    }
    
    
}

#endif

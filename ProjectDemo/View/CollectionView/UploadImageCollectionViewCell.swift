//
//  UploadImageCollectionViewCell.swift
//  CheckCheck
//
//  Created by 邓唯 on 2020/8/18.
//  Copyright © 2020 Binatir. All rights reserved.
//

import UIKit
import SDWebImage

class UploadImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var uploadPhotoImageView: UIImageView!
    @IBOutlet weak var imageTitleLabel: UILabel!
    override func awakeFromNib() {
        
        super.awakeFromNib()
        uploadPhotoImageView.contentMode = .scaleAspectFill
        // Initialization code
    }
    
    
    func setImage(_ image: UIImage) {
        uploadPhotoImageView.do {
            $0.sd_cancelCurrentImageLoad()
            $0.image = image
            $0.layer.masksToBounds = true
        }
    }
    
    func reset() {
        uploadPhotoImageView.do {
            $0.layer.masksToBounds = false
            $0.sd_imageIndicator = SDWebImageActivityIndicator.gray
        }
        iconImageView.do {
            $0.image = UIImage(named: "image_7")
        }
    }
    
    func setImageWithUrL(_ url: URL?) {
        uploadPhotoImageView.do {
            $0.image = nil
            $0.setImage(src: url)
            $0.layer.masksToBounds = true
        }
    }
   
}

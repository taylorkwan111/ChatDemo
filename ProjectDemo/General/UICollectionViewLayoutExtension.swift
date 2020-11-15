//
//  UICollectionViewLayoutExtension.swift
//  Skystar
//
//  Created by Hesse Huang on 25/5/2019.
//  Copyright © 2019 Binatir. All rights reserved.
//

import UIKit

extension UICollectionViewLayout {
    static var imageGalleryFlowLayout: UICollectionViewFlowLayout {
        let itemSpacing: CGFloat = 8.0
        let lineSpacing: CGFloat = 16.0
        let marginPadding: CGFloat = 16.0
        let itemWidth = (UIScreen.main.bounds.width - marginPadding * 2 - itemSpacing * 2) / 3 - 0.5
        let itemHeight = itemWidth * 165 / 109
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = itemSpacing
        layout.minimumLineSpacing = lineSpacing
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        return  layout
    }
}


//
//  HesseKit+FSPagerView.swift
//  HesseKit
//
//  Created by Hesse Huang on 14/5/2018.
//  Copyright © 2018 HesseKit. All rights reserved.
//

#if canImport(FSPagerView)

import FSPagerView

public class HKPagerView: FSPagerView {
    
    var visibleCells: [FSPagerViewCell] {
        guard let innerCollectionView = innerCollectionView else { return [] }
        if numberOfSections(in: innerCollectionView) > 1 {
            fatalError("KWPagerView.visibleCells property is only supported when numberOfSections is 1")
        }
        return innerCollectionView.visibleCells.compactMap {
            $0 as? FSPagerViewCell
        }
    }
    
    var innerLayout: UICollectionViewFlowLayout? {
        return innerCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    var innerCollectionView: UICollectionView? {
        return panGestureRecognizer.view as? UICollectionView
    }

}

public class HKPagerViewCell: FSPagerViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    /// Be sure to call `super.commonInit()`
    func commonInit() {
        // By default there is shadow on each subview, here we remove it.
        contentView.layer.shadowOpacity = 0
    }
    
}

#endif

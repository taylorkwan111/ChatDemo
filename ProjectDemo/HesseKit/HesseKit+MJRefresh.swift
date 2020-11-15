//
//  HesseKit+MJRefresh.swift
//  HesseKit
//
//  Created by Hesse Huang on 11/2/2019.
//  Copyright © 2019 Binatir. All rights reserved.
//

#if canImport(MJRefresh)
import UIKit
import MJRefresh
import Alamofire

class HKRefreshHeader: MJRefreshNormalHeader {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        isAutomaticallyChangeAlpha = true
        lastUpdatedTimeLabel?.isHidden = true
        stateLabel?.textColor = HesseKitConfig.refreshHeaderStateLabelTextColor
        stateLabel?.font = HesseKitConfig.refreshHeaderStateLabelFont
        setTitle(HesseKitConfig.LocalizedText.refreshHeaderIdle, for: .idle)
        setTitle(HesseKitConfig.LocalizedText.refreshHeaderPulling, for: .pulling)
        setTitle(HesseKitConfig.LocalizedText.refreshHeaderRefreshing, for: .refreshing)
    }
    
}

#endif

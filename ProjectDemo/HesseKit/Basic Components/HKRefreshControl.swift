//
//  HKRefreshControl.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 8/10/2018.
//  Copyright © 2018 Binatir. All rights reserved.
//

import UIKit

class HKRefreshControl: UIRefreshControl {
    
    typealias Action = (HKRefreshControl) -> Void
    
    var action: Action?
    
    convenience init(action: @escaping (HKRefreshControl) -> Void) {
        self.init()
        self.action = action
        self.addTarget(self, action: #selector(commitRefreshAction), for: .valueChanged)
    }

    @objc private func commitRefreshAction() {
        action?(self)
    }
    
    override func beginRefreshing() {
        super.beginRefreshing()
        action?(self)
    }
    
}

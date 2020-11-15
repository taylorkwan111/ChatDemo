//
//  BaseCollectionViewController.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 27/5/2018.
//  Copyright © 2018 bichenkk. All rights reserved.
//

import UIKit
#if canImport(Alamofire)
import Alamofire
#endif
#if canImport(MJRefresh)
import MJRefresh
#endif

class BaseCollectionViewController: UICollectionViewController {
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
}

//
//  BaseTableViewController.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 2018/1/15.
//  Copyright © 2018年 bichenkk. All rights reserved.
//

import UIKit
#if canImport(Alamofire)
import Alamofire
#endif

class BaseTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.backgroundColor = .white
        tableView.estimatedRowHeight = 250
        tableView.keyboardDismissMode = .onDrag
    }
    
}


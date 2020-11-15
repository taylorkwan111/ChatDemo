//
//  BaseViewController.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 12/7/2018.
//  Copyright © 2018 Binatir. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        view.backgroundColor = .white
        
    }

    #if DEVELOPMENT
    final func addTestButton() {
        let testItem = UIBarButtonItem(title: "T", style: .plain, target: self, action: #selector(testDataButtonPressed(_:)))
        if navigationItem.rightBarButtonItems?.isEmpty ?? true {
            navigationItem.rightBarButtonItem = testItem
        } else {
            navigationItem.rightBarButtonItems?.append(testItem)
        }
    }

    @IBAction func testDataButtonPressed(_ sender: Any) {
        print("testDataButtonPressed")
    }
    #endif


}

extension UIViewController {
    
    @objc func notifyUserDidLogin() {
    }
    @objc func notifiyUserDidLogout() {
    }
    
}

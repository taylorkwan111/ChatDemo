//
//  LoginNavigationController.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 10/7/2018.
//  Copyright © 2018 Binatir. All rights reserved.
//

import UIKit

class LoginNavigationController: BaseNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notifyUserDidLogin), name: .login, object: nil)
        
        // Fix the left edge pan gesture not working after implementing `navigationController(_:animationControllerFor:from:to:)`
        interactivePopGestureRecognizer?.delegate = nil
    }
}

// MARK: - Notifications

extension LoginNavigationController {
    override func notifyUserDidLogin() {
        // Go to MainTabBarController (Home page)
        dismiss(animated: true, completion: nil)
    }
}

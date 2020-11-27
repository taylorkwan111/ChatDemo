//
//  MainTabBarController.swift
//  ProjectDemo
//
//  Created by 邓唯 on 2020/11/12.
//  Copyright © 2020 Binatir. All rights reserved.
//

import UIKit

/// The tab bar controller with its tab bar hidden, used to manage Home page, Shop list page and Discount list page.
class MainTabBarController: UITabBarController {

    
    let chatViewController: BaseNavigationController = {
        let vc = ChatListTableViewController().then {
            $0.tabBarItem = UITabBarItem(title: NSLocalizedString("chat", bundle: .language, comment: "Tab bar item title").uppercased(),
                                         image: UIImage(named: "chatBlack"),
                                         selectedImage: UIImage(named: "chat"))
        }
        let navigationController = BaseNavigationController(rootViewController: vc).then {
            $0.navigationBar.prefersLargeTitles = false
        }
        return navigationController
    }()
    
    let robotViewController: BaseNavigationController = {
        let vc = RobotViewController().then {
            $0.tabBarItem = UITabBarItem(title: NSLocalizedString("filter", bundle: .language, comment: "Tab bar item title").uppercased(),
                                         image: UIImage(named: "filterBlack"),
                                         selectedImage: UIImage(named: "filter"))
        }
        let navigationController = BaseNavigationController(rootViewController: vc).then {
            $0.navigationBar.prefersLargeTitles = false
        }
        return navigationController
    }()
    
    private var shouldSendLaunchCompleteNotification = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notifyAppLaunchDidComplete), name: .appLaunchDidComplete, object: nil)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tabBar.isTranslucent = false
        
        viewControllers = [
            chatViewController,
            robotViewController
        ]
        viewControllers?.forEach {
            $0.loadViewIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldSendLaunchCompleteNotification {
            shouldSendLaunchCompleteNotification = false
            NotificationCenter.default.post(name: .appLaunchDidComplete, object: nil)
        }
    }
    
}

extension MainTabBarController {
    @objc private func notifyAppLaunchDidComplete() {}
}

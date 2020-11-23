//
//  LaunchViewController.swift
//  Myblex
//
//  Created by Hesse Huang on 24/2/2020.
//  Copyright © 2020 Hesse. All rights reserved.
//

import SnapKit
import UIKit

class LaunchViewController: BaseViewController {
    
    
    var shouldSkipLogin: Bool {
        return false
//        return UserDefaults.standard.userToken != nil
    }
    
    let forceUpdateManager = ForceUpdateManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        NotificationCenter.default.addObserver(self, selector: #selector(notifyAccessTokenExpired), name: .accessTokenExpired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notifyLogout), name: .logout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notifyLanguageDidChange), name: .changeLanguage, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        goMainUIAndCheckUpdates()
    }
    
    private func clearUserDataAndLogout() {
//        UserDefaults.standard.clearUser()
        #if canImport(Intercom)
        Intercom.logout()
        #endif
        navigationController?.popToRootViewController(animated: true)
        
        navigationController?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           self.navigationController?.isNavigationBarHidden = true
       }
}

// MARK: - Handling Notifications

extension LaunchViewController {
    @objc private func notifyAccessTokenExpired() {
        (navigationController ?? self).showFailureAlert(
            title: NSLocalizedString("请再次登录.", bundle: .language, comment: "Alert message"),
                                                        message: NSLocalizedString("你的登录状态已过期", bundle: .language, comment: "Alert message"),
                                                        isTapToDismissEnabled: false,
                                                        confirmTitle: NSLocalizedString("确认", bundle: .language, comment: "Button title"),
                                                        confirmHandler: clearUserDataAndLogout,
                                                        cancelTitle: nil)
    }
    
    @objc private func notifyLogout() {
        clearUserDataAndLogout()
    }
    @objc private func notifyLanguageDidChange() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension LaunchViewController {
    fileprivate func goMainUIAndCheckUpdates() {
        // Avoid pushing one more MainTabBarController.
        if navigationController?.viewControllers.contains(where: { $0 is MainTabBarController }) ?? false {
            return
        }
        _ = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { timer in
            if self.shouldSkipLogin {
                let tabBarController = MainTabBarController()
            self.navigationController?.pushViewController(tabBarController, animated: true)
            } else {
            self.presentIntroductionViewController(animated: false, completion: {
                    let tabBarController = MainTabBarController()
                    self.navigationController?.pushViewController(tabBarController, animated: false)
                })
            }
        })
        
        forceUpdateManager.checkForceUpdateIfNeeded()
    }
}

extension UIViewController {
    /// Present a login UI interface for users to login or register, embeded within a navigation controller.
    func presentIntroductionViewController(animated flag: Bool, completion: (() -> Void)? = nil) {
        let viewController = IntroductionViewController()
        let navigationController = LoginNavigationController(rootViewController: viewController)
        
        // Your code with navigate to another controller
        let vc = (self.navigationController ?? self)
        if #available(iOS 13, *) {
            navigationController.modalPresentationStyle = .fullScreen
            self.modalPresentationStyle = .fullScreen
        }
        vc.present(navigationController, animated: flag, completion: completion)
        
        //        viewController.loadViewIfNeeded()
        //        viewController.view.layoutIfNeeded()
        
    }
    
    public func addBackBarButton() {
        let image = UIImage(named: "ic_nav_back")
        let button = UIBarButtonItem(image: image,
                                     style: .plain,
                                     target: self,
                                     action: #selector(tappedOnBackBarButton(sender:)))
        navigationItem.leftBarButtonItem = button
    }

    @objc open func tappedOnBackBarButton(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
}

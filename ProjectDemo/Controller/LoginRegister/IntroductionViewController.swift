//
//  IntroductionViewController.swift
//  ProjectDemo
//
//  Created by 邓唯 on 2020/11/12.
//  Copyright © 2020 Binatir. All rights reserved.
//

import UIKit
import SwiftyJSON

class IntroductionViewController: UIViewController {

    @IBOutlet weak var nameFormItemView: FormItemView!
    @IBOutlet weak var passwordFormItemView: FormItemView!
    
    @IBOutlet weak var loginView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.setThemeShadow()
        nameFormItemView.do {
            $0.descriptionLabel.text = "Name"
            
        }
        passwordFormItemView.do {
            $0.descriptionLabel.text = "Password"
            
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonDidPress(_ sender: Any) {
        
//        UserDefaults.standard.userToken = "1323243"
            let tabBarController = MainTabBarController()
            self.navigationController?.pushViewController(tabBarController, animated: false)

    }
    
    
}


//extension UIViewController {
//    /// Present a login UI interface for users to login or register, embeded within a navigation controller.
//    func presentIntroductionViewController(animated flag: Bool, completion: (() -> Void)? = nil) {
//        let viewController = IntroductionViewController()
//        let navigationController = LoginNavigationController(rootViewController: viewController)
//        viewController.loadViewIfNeeded()
//        viewController.view.layoutIfNeeded()
//        (self.navigationController ?? self).present(navigationController, animated: flag, completion: completion)
//    }
//}

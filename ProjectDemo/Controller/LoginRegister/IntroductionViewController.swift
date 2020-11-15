//
//  IntroductionViewController.swift
//  CheckCheck
//
//  Created by Hesse Huang on 25/9/2019.
//  Copyright © 2019 Binatir. All rights reserved.
//

import UIKit

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

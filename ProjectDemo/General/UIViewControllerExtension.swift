//
//  UIViewControllerExtension.swift
//  inDinero
//
//  Created by KK Chen on 11/12/16.
//  Copyright © 2016 inDinero. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setupNavigationBarDismissItem() {
        if let image = UIImage(named: "icon_dismiss") {
            let leftButton: UIBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismissButtonPressed(_:)))
            navigationItem.leftBarButtonItem = leftButton
        }
    }
    
    @objc func dismissButtonPressed(_ sender: Any) {
        if let navigationController = navigationController {
            navigationController.dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
}

// keyboard notification handler
extension UIViewController {
    
    func addKeyboardNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    @objc func keyboardWillShow(_ notification: Notification) -> Void {}
    
    @objc func keyboardWillHide(_ notification: Notification) -> Void {}
    
    func animateKeyboard(with notification: Notification, animations: (CGFloat) -> Void) {
        if let useInfo = notification.userInfo {
            let keyboardHeight = (useInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height ?? 0
            animations(keyboardHeight)
        }
        
    }
}

// keyboard dismiss handler
extension UIViewController {
    
    func addDismissKeyboardGesture(to view: UIView) {
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func endEditing() {
        self.view.endEditing(true)
    }
    
}

//
//  NotificationNameExtension.swift
//  inDinero
//
//  Created by KK Chen on 11/13/16.
//  Copyright © 2016 inDinero. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let accessTokenExpired = NSNotification.Name("NOTIFICATION_ACCESS_TOKEN_EXPIRED")
    static let logout = NSNotification.Name("NOTIFICATION_LOGOUT")
    static let login = NSNotification.Name("NOTIFICATION_LOGIN")
    static let changeColor = NSNotification.Name("NOTIFICATION_ACCESS_CHANGE_COLOR")
    static let changeLogo = NSNotification.Name("NOTIFICATION_ACCESS_CHANGE_LOGO")
    static let changeLanguage = NSNotification.Name("NOTIFICATION_ACCESS_CHANGE_LANGUAGE")

    static let autoLogin = NSNotification.Name("notification_autoLogin")
    static let appLaunchDidComplete = NSNotification.Name("notification_appLaunchDidComplete")
    static let userProfileDidUpdate = NSNotification.Name("notification_userProfileDidUpdate")
    static let smsCountdown = Notification.Name("kNotificationSMSCooldownNotification")

    
    
}

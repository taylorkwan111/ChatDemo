//
//  AppDelegate.swift
//  ProjectDemo
//
//  Created by 邓唯 on 2020/11/12.
//  Copyright © 2020 Binatir. All rights reserved.
//

import UIKit
import Then
import Fabric
import Crashlytics
import IQKeyboardManagerSwift
import UserNotifications
import SwiftyJSON
import OneSignal


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var launchOptions: [AnyHashable: Any]?
    var apnsOptions: [AnyHashable: Any]?
    
    #if DEVELOPMENT
    let isDevelopmentEnv = true
    let stripePublishableKey = ""
    let applePayMerchantID = ""
    let onesignalAppID = ""
    #else
    let isDevelopmentEnv = false
    let stripePublishableKey = ""
    let applePayMerchantID = ""
    let onesignalAppID = ""
    #endif
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEVELOPMENT
        dprint("DEVELOPMENT")
        #else
        dprint("PRODUCTION")
        #endif
        
        self.launchOptions = launchOptions
        self.apnsOptions = launchOptions?[.remoteNotification] as? [AnyHashable: Any]
        
        if #available(iOS 11.0, *) {
            UIView.exchangeSetAlpha
        }
        
        UIView.appearance().tintColor = .themeTint
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().shadowImage = UIImage()
//        UserDefaults.standard.userToken = "1323243"
        dprint("Access Token == \(UserDefaults.standard.userToken ?? "nil")")
        
        
        //        // Initialize Stripe
        //        setupStripeConfiguration()
        //        Fabric.with([Crashlytics.self])
        //        initOneSignal(launchOptions: launchOptions)
        
        setupUI()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = NSLocalizedString("Done", bundle: .language, comment: "Done")
        
        HesseKitConfig.LocalizedText.loading = NSLocalizedString("Loading", bundle: .language, comment: "HUD message")
        HesseKitConfig.LocalizedText.refreshHeaderIdle = NSLocalizedString("Pull to refresh", bundle: .language, comment: "HKRefreshHeader: Title of idle refresh header")
        HesseKitConfig.LocalizedText.refreshHeaderPulling = NSLocalizedString("Release to refresh", bundle: .language, comment: "HKRefreshHeader: Title of pulling refresh header")
        HesseKitConfig.LocalizedText.refreshHeaderRefreshing = NSLocalizedString("Loading...", bundle: .language, comment: "HKRefreshHeader: Title of refreshing refresh header")
        //        HesseKitConfig.defaultMaleProfileImage = #imageLiteral(resourceName: "placeholder_avatar")
        //        HesseKitConfig.defaultFemaleProfileImage = #imageLiteral(resourceName: "placeholder_avatar")
        
        return true
    }
    
    
    // MARK: - Private Methods
    private func setupUI() {
        
        let launchViewController = LaunchViewController()
        
        //        let launchViewController = TestViewController()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = BaseNavigationController(rootViewController: launchViewController)
        
        window.rootViewController = navigationController
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        self.window = window
    }
    
    private func setupHesseKit() {
        HesseKitConfig.defaultMaleProfileImage = UIImage(named: "icon_avatar_placeholder")
        HesseKitConfig.defaultFemaleProfileImage = UIImage(named: "icon_avatar_placeholder")
        
    }
    
  
}

// MARK: - OneSignal
extension AppDelegate {
    
    /// Initialize OneSignal SDK with launch options.
    ///
    /// - Parameter launchOptions: The applicationlaunch options.
//    private func initOneSignal(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
//        
//        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
//        
//        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
//        OneSignal.initWithLaunchOptions(launchOptions,
//                                        appId: onesignalAppID,
//                                        handleNotificationReceived: didReceive(pushNotification:),
//                                        handleNotificationAction: didOpenPushNotification(with:),
//                                        settings: onesignalInitSettings)
//        
//        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
//    }
    
    /// The method to be called when a notification is received.
    ///
    /// If the app is in foreground, this method will be called immediately.
    ///
    /// To support calling it in background, the notification should have `content_available` set to `true`.
    ///
    /// - Parameter pushNotification: The OSNotification object provided by OneSignal.
//    @objc private func didReceive(pushNotification: OSNotification?) {
//        // TODO: Test & inspect the notification contents.
//        guard let pushNotification = pushNotification else { return }
//        let userInfo = pushNotification.payload.additionalData
//        NotificationCenter.default.post(name: .applePushNotification, object: self, userInfo: userInfo)
//        dprint("didReceive(pushNotification with userInfo = \(String(describing: userInfo))")
//    }
    
    /// The method to be called when a user reacts to a notification received.
    ///
    /// - Parameter result: The OSNotificationOpenedResult object provided by OneSignal.
    @objc private func didOpenPushNotification(with result: OSNotificationOpenedResult?) {
        // TODO: Test & inspect the notification contents.
        guard let result = result else { return }
        let userInfo = result.notification.payload.additionalData
        dprint("didOpenPushNotification(with result userInfo = \(String(describing: userInfo))")
        handlePushNotificationOpenAction(by: result)
    }
    
    func setUserPushNotificationServiceAlias(userId: String) {
        OneSignal.sendTag("userId", value: userId)
    }
    
    func deleteUserPushNotificationServiceAlias() {
        OneSignal.deleteTag("userId")
    }
    
    /// Once the push notification is tapped, this method is called.
    ///
    /// - Parameter result: Object from OneSignal.
    private func handlePushNotificationOpenAction(by result: OSNotificationOpenedResult) {
        let additionalData = result.notification.payload.additionalData
        dprint(additionalData ?? [:])
    }
}


// MARK: UISceneSession Lifecycle
@available(iOS 13.0, *)
extension AppDelegate {
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}

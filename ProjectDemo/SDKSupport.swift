//
//  SDKSupport.swift
//  Coinfind
//
//  Created by Hesse Huang on 19/11/2019.
//  Copyright © 2019 Hesse. All rights reserved.
//

import UIKit
#if canImport(SwiftyJSON)
import SwiftyJSON
#endif

class SDKSupport {
    
    #if DEVELOPMENT
    let stripePublishableKey = ""
    let applePayMerchantID = ""
    let onesignalAppID = ""
    #else
    let stripePublishableKey = ""
    let applePayMerchantID = ""
    let onesignalAppID = ""
    #endif
    
    static let shared = SDKSupport()
    
    /// Whether the app's UI is stable enough for handling push notifications which possibly opens a view controller.
    var isAppUIPrepared: Bool = false {
        didSet {
            if !oldValue && isAppUIPrepared {
                additionalActionAfterAppUIDidPrepared?()
                additionalActionAfterAppUIDidPrepared = nil
            }
        }
    }
    
    // The action after `isAppUIPrepared` changed from `false` to `true`. Possibly opening a new view controller.
    private var additionalActionAfterAppUIDidPrepared: (() -> Void)?
    
    private init() {}
    
    func initEmbeddedSDKs(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        #if canImport(Firebase)
        initFirebase()
        #endif
        
        #if canImport(Stripe)
        initStripe()
        #endif
//
//        #if canImport(OneSignal)
//        initOneSignal(launchOptions)
//        #endif
//
        #if canImport(FBSDKCoreKit)
        initFacebook(application: application, launchOptions: launchOptions)
        #endif
    }
}

// MARK: - Firebase
#if canImport(Firebase)
import Firebase
private extension SDKSupport {
    func initFirebase() {
        FirebaseApp.configure()
    }
}
#endif

// MARK: - Stripe
#if canImport(Stripe)
import Stripe

private extension SDKSupport {
    func initStripe() {
        STPPaymentConfiguration.shared().do {
            $0.publishableKey = stripePublishableKey
            $0.appleMerchantIdentifier = applePayMerchantID
            $0.companyName = "Myblex Inc."
            $0.requiredBillingAddressFields = .none     // No billing address required.
            $0.requiredShippingAddressFields = nil      // No shipping address required.
            $0.additionalPaymentOptions = []
        }
        STPTheme.default().do {
            $0.primaryBackgroundColor = .themeBackgroundLightGray
            $0.accentColor = .themeTint
        }
    }
}
#endif

// MARK: - Facebook
#if canImport(FBSDKCoreKit)
import FBSDKCoreKit

private extension SDKSupport {
    func initFacebook(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

#endif

// MARK: - OneSignal
#if canImport(OneSignal)
import OneSignal

private extension SDKSupport {
    
    /// Initialize OneSignal SDK with launch options.
    ///
//    /// - Parameter launchOptions: The applicationlaunch options.
//    func initOneSignal(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
//        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
//        
//        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
//        OneSignal.initWithLaunchOptions(launchOptions,
//                                        appId: onesignalAppID,
//                                        handleNotificationReceived: didReceive(pushNotification:),
//                                        handleNotificationAction: didOpenPushNotification(with:),
//                                        settings: onesignalInitSettings)
//        
//        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
//        
//        OneSignal.promptForPushNotifications(userResponse: nil)
//    }
//    
    /// The method to be called when a notification is received.
    ///
    /// If the app is in foreground, this method will be called immediately.
    ///
    /// To support calling it in background, the notification should have `content_available` set to `true`.
    ///
    /// - Parameter pushNotification: The OSNotification object provided by OneSignal.
//    @objc private func didReceive(pushNotification: OSNotification?) {
//        guard let pushNotification = pushNotification else { return }
//        let userInfo = pushNotification.payload.additionalData
//        NotificationCenter.default.post(name: .applePushNotification, object: self, userInfo: userInfo)
//        #if canImport(SwiftyJSON)
//        dprint("didReceive(pushNotification with userInfo =\n \(JSON(userInfo ?? [:]))")
//        #else
//        dprint("didReceive(pushNotification with userInfo = \(String(describing: userInfo))")
//        #endif
//    }
    
    /// The method to be called when a user reacts to a notification received.
    ///
    /// - Parameter result: The OSNotificationOpenedResult object provided by OneSignal.
    @objc private func didOpenPushNotification(with result: OSNotificationOpenedResult?) {
        guard let result = result else { return }
        let userInfo = result.notification.payload.additionalData
        #if canImport(SwiftyJSON)
        dprint("didOpenPushNotification(with result userInfo =\n \(JSON(userInfo ?? [:]))")
        #else
        dprint("didOpenPushNotification(with result userInfo = \(String(describing: userInfo))")
        #endif
        handlePushNotificationOpenAction(by: result)
    }
    
    /// Once the push notification is tapped, this method is called.
    ///
    /// - Parameter result: Object from OneSignal.
    private func handlePushNotificationOpenAction(by result: OSNotificationOpenedResult) {
        let additionalData = result.notification.payload.additionalData
        dprint(additionalData ?? [:])
        
//        let json = JSON(additionalData ?? [:])
//        if let id = json["user_to_sell_item_id"].string?.toInt {
//            if isAppUIPrepared {
//                UIViewController.getCurrentViewController()?.pushUserToSellItemDetailViewControllerIfPossible(userToSellItemId: id)
//            } else {
//                additionalActionAfterAppUIDidPrepared = {
//                    UIViewController.getCurrentViewController()?.pushUserToSellItemDetailViewControllerIfPossible(userToSellItemId: id)
//                }
//            }
//        }
    }
    
}

extension SDKSupport {
    func setOneSignalTag(userId: String) {
        OneSignal.sendTag("userId", value: userId)
    }
    
    func deleteOneSignalTag() {
        OneSignal.deleteTag("userId")
    }
}

//extension Notification.Name {
//    static let applePushNotification = Notification.Name("kNotificationApplePushNotification")
//}
//
//extension UIViewController {
//    
//    func addObserverForPushNotification() {
//        NotificationCenter.default.addObserver(self, selector: #selector(notifyDidReceivePushNotification(_:)), name: .applePushNotification, object: nil)
//    }
//    
//    @objc func notifyDidReceivePushNotification(_ notification: Notification) {}
//    
//}

#endif

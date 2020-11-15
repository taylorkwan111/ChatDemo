//
//  ForceUpdateManager.swift
//  Kawa
//
//  Created by Hesse Huang on 1/2/2019.
//  Copyright © 2019 bichenkk. All rights reserved.
//

import UIKit

class ForceUpdateManager: NSObject {
    
    // Apple ID for Elephant Ground
    let appId = "1480641143"
    
    // MARK: - Check for Updates
    
    private var hasForceUpdatesChecked: Bool = false
    
    func checkForceUpdateIfNeeded() {
        if !hasForceUpdatesChecked {
            hasForceUpdatesChecked = true
            checkForceUpdate()
        }
    }
    
    private func checkForceUpdate() {
        func openAppStore() {
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appId)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        func openAppStoreAndExit() {
            openAppStore()
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                exit(0)
            }
        }
        
        NetworkManager.shared.sendGetAppVersionRequest()
            .onError { error in

            }
            .onSuccess { json in
                let title = NSLocalizedString("New Updates", bundle: .language, comment: "Alert message")
                let message = NSLocalizedString("Please update to the latest version of EG Coffee in App Store.", bundle: .language, comment: "Alert message")
                let updateNow = NSLocalizedString("Update Now", bundle: .language, comment: "Button title guiding users to update Kawa app immediately")
                let later = NSLocalizedString("Later", bundle: .language, comment: "Button title")
                
                let needForceUpdate = json["force_update"].boolValue
                if needForceUpdate {
                    UIViewController.getCurrentViewController()?.showSuccessAlert(
                        title: title,
                        message: message,
                        isTapToDismissEnabled: false,
                        cancelTitle: updateNow,
                        cancelHandler: openAppStoreAndExit)
                } else {
                    let lastPresentedLatestVersionKey = "kawaLastPresentedLatestVersionKey"
                    let presentedLatestVersion = UserDefaults.standard.string(forKey: lastPresentedLatestVersionKey)
                    let latestVersion = json["latest_version"].stringValue

                    if appVersion.isOldAppVersion(comparedWith: latestVersion) {
                        if (presentedLatestVersion?.isOldAppVersion(comparedWith: latestVersion) ?? true) {
                            UserDefaults.standard.set(latestVersion, forKey: lastPresentedLatestVersionKey)
                            UIViewController.getCurrentViewController()?.showSuccessAlert(
                                title: title,
                                message: message,
                                isTapToDismissEnabled: false,
                                confirmTitle: updateNow,
                                confirmHandler: openAppStore,
                                cancelTitle: later,
                                cancelHandler: nil)
                        }
                    }
                }
        }
    }
}

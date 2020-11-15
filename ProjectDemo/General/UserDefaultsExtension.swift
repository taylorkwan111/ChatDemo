//
//  UserDefaultsExtension.swift
//  inDinero
//
//  Created by KK Chen on 1/1/2017.
//  Copyright © 2017 inDinero. All rights reserved.
//

import Foundation

enum StoreKey: String {
    case userLanguage = "userLanguage"
    case userId = "UserID"
    case userEmail = "UserEmail"
    case userToken = "UserToken"
    case userFirstName = "UserFirstName"
    case userLastName = "UserLastName"
    case userCurrency = "UserCurrency"
    case userFacebookId = "UserFacebookId"
    case userInstagramId = "UserInstagramId"
    case uuid = "UUID"
    case isPushPermissionAsked = "isPushPermissionAsked"
    case isLocationPermissionAsked = "isLocationPermissionAsked"
    case isCurrencyAsked = "isCurrencyAsked"
    case isLanguageAsked = "isLanguageAsked"
    case isTutorialViewShown = "isTutorialViewShown"
    case userPaymentMethodStripeId = "userPaymentMethodStripeId"

}

extension UserDefaults {
    
    var userLanguage: String {
        get {
            if let language = string(forKey: StoreKey.userLanguage.rawValue) {
                return language
            }
            if let language = Bundle.main.preferredLocalizations.first {
                return language
            }
            return "en"
        }
        set {
            set(newValue, forKey: StoreKey.userLanguage.rawValue)
        }
    }
    
    var userId: Int? {
        get {
            return integer(forKey: StoreKey.userId.rawValue)
        }
        set {
            set(newValue, forKey: StoreKey.userId.rawValue)
        }
    }
    
    var userEmail: String? {
        get {
            return string(forKey: StoreKey.userEmail.rawValue)
        }
        set {
            set(newValue, forKey: StoreKey.userEmail.rawValue)
        }
    }
    
    var userToken: String? {
        get {
            return string(forKey: StoreKey.userToken.rawValue)
        }
        set {
            set(newValue, forKey: StoreKey.userToken.rawValue)
        }
    }
    
    var userFirstName: String? {
        get {
            return string(forKey: StoreKey.userFirstName.rawValue)
        }
        set {
            set(newValue, forKey: StoreKey.userFirstName.rawValue)
        }
    }
    
    var userLastName: String? {
        get {
            return string(forKey: StoreKey.userLastName.rawValue)
        }
        set {
            set(newValue, forKey: StoreKey.userLastName.rawValue)
        }
    }
        
    var userCurrency: String {
        get {
            return string(forKey: StoreKey.userCurrency.rawValue) ?? "USD"
        }
        set {
            set(newValue, forKey: StoreKey.userCurrency.rawValue)
        }
    }
    
    var userFacebookId: String? {
        get {
            return string(forKey: StoreKey.userFacebookId.rawValue)
        }
        set {
            set(newValue, forKey: StoreKey.userFacebookId.rawValue)
        }
    }
    
    var userInstagramId: String? {
        get {
            return string(forKey: StoreKey.userInstagramId.rawValue)
        }
        set {
            set(newValue, forKey: StoreKey.userInstagramId.rawValue)
        }
    }
    
    var isPushPermissionAsked: Bool {
        get {
            return bool(forKey: StoreKey.isPushPermissionAsked.rawValue) 
        }
        set {
            set(newValue, forKey: StoreKey.isPushPermissionAsked.rawValue)
        }
    }
    
    var isLocationPermissionAsked: Bool {
        get {
            return bool(forKey: StoreKey.isLocationPermissionAsked.rawValue)
        }
        set {
            set(newValue, forKey: StoreKey.isLocationPermissionAsked.rawValue)
        }
    }
    
    var isCurrencyAsked: Bool {
        get {
            return bool(forKey: StoreKey.isCurrencyAsked.rawValue)
        }
        set {
            set(newValue, forKey: StoreKey.isCurrencyAsked.rawValue)
        }
    }
    
    var isLanguageAsked: Bool {
        get {
            return bool(forKey: StoreKey.isLanguageAsked.rawValue)
        }
        set {
            set(newValue, forKey: StoreKey.isLanguageAsked.rawValue)
        }
    }
    
    var isTutorialViewShown: Bool {
        get {
            return bool(forKey: StoreKey.isTutorialViewShown.rawValue)
        }
        set {
            set(newValue, forKey: StoreKey.isTutorialViewShown.rawValue)
        }
    }
    
    var uuid: String? {
        get {
            return string(forKey: StoreKey.uuid.rawValue)
        }
        set {
            set(newValue, forKey: StoreKey.uuid.rawValue)
        }
    }
    
    var userPaymentMethodStripeId: String? {
        get {
            return string(forKey: StoreKey.userPaymentMethodStripeId.rawValue)
        }
        set {
            self.set(newValue, forKey: StoreKey.userPaymentMethodStripeId.rawValue)
        }
    }
    
}

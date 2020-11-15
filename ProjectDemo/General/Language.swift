//
//  Language.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 3/5/2018.
//  Copyright © 2018 bichenkk. All rights reserved.
//

import Foundation

public extension Bundle {
    
    /// Returns the bundle with localized string files for the current user language.
    ///
    /// - Important: You should setup the languages in project setting. Failure to do so is a programmer error.
    static var language = bundle(for: .current) ?? .main
    
    static func bundle(for language: Language) -> Bundle? {
        if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj") {
            return Bundle(path: path)
        }
        return nil
    }
}

extension Locale {
    static var languageAssociated = Locale(identifier: Language.current.associatedLocaleIdentifier)
}

public enum Language: String {
    
    case english = "en-HK"
    case traditionalChinese = "zh-Hant"
    
    var associatedLocaleIdentifier: String {
        switch self {
        case .english:
            return "en-HK"
        case .traditionalChinese:
            return "zh-Hant-HK"
        }
    }
    
    var description: String {
        switch self {
        case .english:
            return "English"
        case .traditionalChinese:
            return "Traditional Chinese"
        }
    }
    
    var name: String {
        switch self {
        case .english:
            return "English"
        case .traditionalChinese:
            return "繁體中文"
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .english:
            return NSLocalizedString("English", bundle: .language, comment: "Text in Language Settings")
        case .traditionalChinese:
            return NSLocalizedString("Chinese(Traditional)", bundle: .language, comment: "Text in Language Settings")
        }
    }
        
    static var allCases: [Language] {
        return [/*.english, */.traditionalChinese, /*.simplifiedChinese*/]
    }
    
    static var current = Language(rawValue: UserDefaults.standard.userLanguage) ?? mostSuitableLanguageBasedOnSystem {
        didSet {
            if current == oldValue { return }
            
            // store locally
            UserDefaults.standard.userLanguage = current.rawValue
            
            // update the bundle for localized strings
            Bundle.language = Bundle.bundle(for: .current) ?? .main
            
            // update the associated locale
            Locale.languageAssociated = Locale(identifier: current.associatedLocaleIdentifier)
            
            // post a notification to inform that the current language did change
            NotificationCenter.default.post(name: .changeLanguage, object: nil)
        }
    }

    static var mostSuitableLanguageBasedOnSystem: Language {
        return .traditionalChinese
    }
    
}

extension TimeInterval {
    
    var readableTimeIntervalDescription: String {
        let value = Int(self)
        switch value {
        case -1.minutes ..< 0 :
            return NSLocalizedString("Just now", bundle: .language, comment: "Text describing time elapsed")
        case -60.minutes ..< -1.minutes:
            let m = value / -1.minutes
            let format = NSLocalizedString("%d minute(s) ago", bundle: .language, comment: "Text describing time elapsed")
            return String(format: format, m)
        case -24.hours ..< -1.hours:
            let h = value / -1.hours
            let format = NSLocalizedString("%d hour(s) ago", bundle: .language, comment: "Text describing time elapsed")
            return String(format: format, h)
        case -30.days ..< -1.days:
            let d = value / -1.days
            let format = NSLocalizedString("%d day(s) ago", bundle: .language, comment: "Text describing time elapsed")
            return String(format: format, d)
        case -12.months ..< -1.months:
            let m = value / -1.months
            let format = NSLocalizedString("%d month(s) ago", bundle: .language, comment: "Text describing time elapsed")
            return String(format: format, m)
        default:
            let y = value / -1.years
            let format = NSLocalizedString("%d year(s) ago", bundle: .language, comment: "Text describing time elapsed")
            return String(format: format, y)
        }
    }
    
}

//
//  HesseKitConfig.swift
//  HesseKit
//
//  Created by Hesse Huang on 25/5/2019.
//  Copyright © 2019 HesseKit. All rights reserved.
//

import UIKit

/// A general configuration object that other HesseKit components would possibly use.
public final class HesseKitConfig: NSObject {
    
    let shared = HesseKitConfig()
    
    private override init() {
        super.init()
    }
    
    /// The default placeholder image for use profile image.
    public static var defaultPlaceholderImage = UIImage.image(withPureColor: #colorLiteral(red: 0.8814839784, green: 0.8814839784, blue: 0.8814839784, alpha: 1), for: CGRect(x: 0, y: 0, width: 1, height: 1), rounded: false)
    
    /// The default rouneded placeholder image for use profile image.
    public static func defaultRoundedPlaceholderImage(size: CGSize) -> UIImage? {
        UIImage.image(withPureColor: #colorLiteral(red: 0.8814839784, green: 0.8814839784, blue: 0.8814839784, alpha: 1), for: CGRect(origin: .zero, size: size), rounded: true)
    }

    /// The fallback image when passing `nil` when set image.
    public static var defaultNilSrcFallbackImage: UIImage?

    /// The image to use for male users when fetching his profile image.
    public static var defaultMaleProfileImage: UIImage? = defaultPlaceholderImage
    
    /// The image to use for female users when fetching her profile image.
    public static var defaultFemaleProfileImage: UIImage? = defaultPlaceholderImage
    
    /// The existing duration for a MBProgressHUD view.
    public static var defaultHUDDuration: TimeInterval = 1.5
    
    /// The font applied to HUD label.text.
    public static var defaultHUDTextFont: UIFont = .systemFont(ofSize: 15)
    
    /// The font applied to HUD detailLabel.text.
    public static var defaultHUDDetailTextFont: UIFont = .systemFont(ofSize: 13)
    
    /// This struct stores multiple localized strings.
    public struct LocalizedText {
        /// The text for "Loading"
        public static var loading: String = "Loading"
        public static var refreshHeaderIdle: String = "Pull to refresh"
        public static var refreshHeaderPulling: String = "Release to refresh"
        public static var refreshHeaderRefreshing: String = "Loading..."
    }
    
    /// The text color of MJRefresh state label.
    public static var refreshHeaderStateLabelTextColor: UIColor = .lightGray
    /// The font of MJRefresh state label.
    public static var refreshHeaderStateLabelFont: UIFont = .systemFont(ofSize: 15)
    
    /// The parser for list results. It takes the network response (json object) as argument and returns a tuple specifying the total amount of data, and the current offset, respectively.
    /// You should returns (0, 0) for unsuccessful unwrappings.
    public static var networkJSONListPaginationUnwrapper: (Any) -> (Int, Int) = { response in
        if let dict = response as? [String: Any], let total = dict["total"] as? Int, let offset = dict["offset"] as? Int {
            return (total, offset)
        }
        return (0, 0)
    }
    
}

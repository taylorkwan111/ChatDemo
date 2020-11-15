//
//  General.swift
//  Visa
//
//  Created by KK Chen on 6/4/2017.
//  Copyright © 2017 bichenkk. All rights reserved.
//

import Foundation

extension Int {
    static var hkPhoneLength: Int {
        return 8
    }
}


fileprivate let jsDateFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000Z'"
    return fmt
}()

extension DateFormatter {
    static let defaultLocal: DateFormatter = {
        let fmt = DateFormatter()
        fmt.locale = .en_hk
        fmt.timeStyle = .short
        fmt.dateStyle = .short
        return fmt
    }()
}

/// Translate the JS string to Swift `Date`.
func localDate(byParsingJsString jsStr: String) -> Date? {
    return jsDateFormatter.date(from: jsStr)?.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
}

/// Translate the JS string to a readable time string.
func readableLocalTime(byParsingJsString jsStr: String?, with formatter: DateFormatter = DateFormatter.defaultLocal) -> String? {
    if let jsStr = jsStr, let date = localDate(byParsingJsString: jsStr) {
        return formatter.string(from: date)
    }
    return nil
}

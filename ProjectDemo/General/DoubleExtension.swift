//
//  DoubleExtension.swift
//  Visa
//
//  Created by KK Chen on 14/3/2017.
//  Copyright © 2017 bichenkk. All rights reserved.
//

import Foundation

extension Double {
    
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
}

extension Optional where Wrapped == Double {
    
    var priceString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        if let price = self {
            let formattedString = numberFormatter.string(from: NSNumber(value: price))
            return formattedString ?? ""
        }
        return ""
    }
}

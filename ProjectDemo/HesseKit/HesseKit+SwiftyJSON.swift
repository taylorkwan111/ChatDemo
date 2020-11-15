//
//  HesseKit+SwiftyJSON.swift
//  HesseKit
//
//  Created by Hesse Huang on 2018/2/12.
//  Copyright © 2018年 HesseKit. All rights reserved.
//

#if canImport(SwiftyJSON)

import SwiftyJSON

public extension JSON {
    
    init(fileName: String) {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "js"),
            let data = try? Data(contentsOf: url) {
            do {
                try self.init(data: data)
                return
            } catch {
                
            }
        }
        self.init(NSNull())
    }
    
    var intValues: [Int] {
        return arrayObject as? [Int] ?? []
    }
    
    var doubleValues: [Double] {
        return arrayObject as? [Double] ?? []
    }
    
    var stringValues: [String] {
        return arrayObject as? [String] ?? []
    }
    
    var urls: [URL?] {
        return array?.map({ $0.url }) ?? []
    }
}

// MARK: - JSON Warpper Model Protocol

public protocol JSONWrapperModel {
    
    var json: JSON { get }
    
    init(json: JSON)

}

public extension JSON {
    func array<T: JSONWrapperModel>(of type: T.Type) -> [T] {
        return arrayValue.map({ type.init(json: $0) })
    }
}

public extension Notification {
    var userInfoJSON: JSON {
        if let userInfo = userInfo { return JSON(userInfo) }
        return .null
    }
}

#endif

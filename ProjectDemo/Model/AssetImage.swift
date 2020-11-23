//
//  AssetImage.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 15/9/2018.
//  Copyright © 2018 Binatir. All rights reserved.
//

import SwiftyJSON

struct AssetImage: JSONWrapperModel {
    let json: JSON
    
    var id: Int {
        return json["id"].intValue
    }
    
    var url: URL? {
        return json["url"].url
    }
    
    var format: String {
        return json["format"].stringValue
    }
    
    var width: CGFloat? {
        if let w = json["width"].int {
            return CGFloat(w)
        }
        return nil
    }
    
    var height: CGFloat? {
        if let h = json["height"].int {
            return CGFloat(h)
        }
        return nil
    }
    
    var administratorID: Int? {
        return json["administrator_id"].intValue
    }
    
    var userID: Int? {
        return json["userID"].intValue
    }
    
    var createdAt: String {
        return json["created_at"].stringValue
    }
    
    var updatedAt: String {
        return json["updated_at"].stringValue
    }
    
    init(json: JSON) {
        self.json = json
    }
}


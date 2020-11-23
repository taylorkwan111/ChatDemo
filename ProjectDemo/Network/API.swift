//
//  API.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 16/3/2018.
//  Copyright © 2018 bichenkk. All rights reserved.
//

#if canImport(SwiftyJSON)
import SwiftyJSON

struct APIError: Error {
    
    /*
     this.id = 'PARAM_REQUIRED'
     this.id = 'VALIDATION_ERROR'
     this.id = 'INVALID_QUERY'
     this.id = 'INVALID_REQUEST'
     this.id = 'DUPLICATED_RECORD'
     this.id = 'INVALID_LOGIN_EMAIL'
     this.id = 'INVALID_LOGIN_PASSWORD'
     this.id = 'INVALID_LOGIN_USER'
     this.id = 'AUTHENTICATION_ERROR'
     this.id = 'INVALID_TOKEN'
     this.id = 'REVOKED_TOKEN'
     this.id = 'EXPIRED_TOKEN'
     this.id = 'INVALID_PERMISSION'
     this.id = 'INVALID_USER'
     this.id = 'NOT_FOUND'
     this.id = 'INTERNAL_SERVER_ERROR'
     
     OK: 200,
     CREATED: 201,
     NO_CONTENT: 204,
     BAD_REQUEST: 400,
     UNAUTHORISED: 401,
     INVALID_SCOPE: 403,
     NOT_FOUND: 404,
     TOO_MANY_REQUEST: 429,
     INTERNAL_SERVER_ERROR: 500,
     SERVICE_UNAVAILABLE: 503,
     */
    
    enum ID: String {
        case paramRequired          = "PARAM_REQUIRED"
        case validationError        = "VALIDATION_ERROR"
        case invalidQuery           = "INVALID_QUERY"
        case invalidRequest         = "INVALID_REQUEST"
        case duplicatedRecord       = "DUPLICATED_RECORD"
        case invalidLoginEmail      = "INVALID_LOGIN_EMAIL"
        case invalidLoginPassword   = "INVALID_LOGIN_PASSWORD"
        case invalidLoginUser       = "INVALID_LOGIN_USER"
        case authenticationError    = "AUTHENTICATION_ERROR"
        case invalidToken           = "INVALID_TOKEN"
        case revokedToken           = "REVOKED_TOKEN"
        case expiredToken           = "EXPIRED_TOKEN"
        case invalidPermission      = "INVALID_PERMISSION"
        case invalidUser            = "INVALID_USER"
        case notFound               = "NOT_FOUND"
        case internalServerError    = "INTERNAL_SERVER_ERROR"
    }
    
    let json: JSON
    
    var id: String {
        return json["errors"].arrayValue.first?["id"].string ?? ""
    }

    var code: Int {
        return json["errors"].arrayValue.first?["code"].int ?? 0
    }
    
    var message: String {
        return json["errors"].arrayValue.first?["message"].string ?? ""
    }
    
    var field: String? {
        return json["errors"].arrayValue.first?["field"].string
    }
    
}

extension Error {
    func has(id: APIError.ID, code: Int, field: String? = nil) -> Bool {
        if let error = self as? APIError {
            return error.id == id.rawValue && error.code == code && (field == nil ? true : error.field == field)
        }
        return false
    }
}
#endif

/// Server side APIs
struct API {
    
    /// The server domain
    #if DEVELOPMENT
    static let domain = "http://127.0.0.1:10000/photo/process?model=rain_princess"
    #else
    static let domain = "http://127.0.0.1:10000/photo/process?model=rain_princess"
    #endif
    
    static var termsOfService: String {
        return "https://mobidoc.hk/terms"
    }
    static var privacyPolicy: String {
        return "https://mobidoc.hk/privacy"
    }
    
    static var assetImage: String {
        return domain + "/asset_image"
    }
    static var authentication: String {
        return domain + "/authentication"
    }
    static var user: String {
        return domain + "/user"
    }
    static var me: String {
        return domain + "/me"
    }
    static var editPassword: String {
        return domain + "/me/password"
    }
    static var forgotPassword: String {
        return domain + "/utility/forgot_password"
    }

}

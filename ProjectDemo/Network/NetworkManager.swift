//
//  NetworkManager.swift
//  MSocial
//
//  Created by KK Chen on 14/10/2017.
//  Copyright © 2017 Millennium Hotels and Resorts. All rights reserved.
//

#if canImport(Alamofire)

import UIKit
import Alamofire

public typealias DataRequest = Alamofire.DataRequest

public struct NetworkError: LocalizedError {
    
    var title = "Unknown Error"
    var message = "Please try again later."
    var code = 9999
    private var _description = "Unknown Error"
    
    init() {
    }
    
    init(title: String, message: String, code: Int) {
        self.title = title
        self.message = message
        self.code = code
        self._description = self.title
    }
}

class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    
    let datePostingFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt
    }()
    
    let pageLimit: Int = 10
    
    @discardableResult
    func request(url: String, method: HTTPMethod, parameters: Parameters?) -> DataRequest {
        dprint("API: \(method.rawValue) \(url)")
        var headers: HTTPHeaders = ["Accept": "application/json"]
        if let apiToken = UserDefaults.standard.userToken, !apiToken.isEmpty {
            headers["Authorization"] = "Bearer \(apiToken)"
            headers["Accept-Language"] = "en" // TODO: Support multiple languages if needed.
        }
        let parameterEncoding: ParameterEncoding = method == .get ? URLEncoding.queryString : JSONEncoding.default
        return AF.request(url, method: method, parameters: parameters, encoding: parameterEncoding, headers: headers)
            .validate()
            .validate(contentType: ["application/json", "text/json"])
            .responseJSON { (response) in
                let statusCode = response.response?.statusCode ?? -1
                if statusCode == 401, let apiToken = UserDefaults.standard.userToken, !apiToken.isEmpty {
                    NotificationCenter.default.post(name: .accessTokenExpired, object: nil)
                }
        }
    }
    
    func uploadAsset(image: UIImage, description: String?) -> UploadRequest {
        var headers: HTTPHeaders = [:]
//        headers["Accept-Language"] = "en" // TODO: Support multiple languages if needed.
//        if let apiToken = UserDefaults.standard.userToken, !apiToken.isEmpty {
//            headers["Authorization"] = "Bearer \(apiToken)"
//        }
        let imgData = image.orientationFixed.jpegData(compressionQuality: 0.8)!
        return AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "file", fileName: "file.jpg", mimeType: "image/jpg")
            if let descriptionData = description?.data(using: .utf8) {
                multipartFormData.append(descriptionData, withName: "description")
            }
            if let widthData = "\(Int(image.size.width))".data(using: .utf8) {
                multipartFormData.append(widthData, withName: "width")
            }
            if let heightData = "\(Int(image.size.height))".data(using: .utf8) {
                multipartFormData.append(heightData, withName: "height")
            }
        },
                         to: "http://92shmw.natappfree.cc/photo/process?model=rain_princess",
                         headers: headers)
    }
    
//    @discardableResult
//    func sendFilterImage(image: UIImage) -> DataRequest {
////        var parameters = [String: Any]()
////        parameters["file"] = image
//        var headers: HTTPHeaders = [:]
//        headers["Accept-Language"] = "en"
//        let imgData = image.orientationFixed.jpegData(compressionQuality: 0.2)!
//        return AF.upload(multipartFormData: { multipartFormData in
//            multipartFormData.append(imgData, withName: "file", fileName: "file.jpg", mimeType: "image/jpg")
////            if let descriptionData = description?.data(using: .utf8) {
////                multipartFormData.append(descriptionData, withName: "description")
////            }
////            if let widthData = "\(Int(image.size.width))".data(using: .utf8) {
////                multipartFormData.append(widthData, withName: "width")
////            }
////            if let heightData = "\(Int(image.size.height))".data(using: .utf8) {
////                multipartFormData.append(heightData, withName: "height")
////            }
//        },
//        to: API.domain,
//        headers: headers)
//    }
//    
    
    @discardableResult
    func sendCheckRegisterPhoneNumberRequest(phone: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["phone_number"] = phone
        return request(url: API.domain + "/utility/check_register_phone_number",
                       method: .post,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendCheckRegisterEmailRequest(email: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["email"] = email
        return request(url: API.domain + "/utility/check_register_email",
                       method: .post,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendRegisterRequest(name: String,
        email: String,
                             password: String,
                             referralCode: String?,
                             facebookToken: String? = nil,
                             appleAuthenCodeString: String? = nil) -> DataRequest {
        var parameters = [String: Any]()
        parameters["name"] = name
        parameters["email"] = email
        parameters["password"] = password
//        parameters["profile_image_url"] = profileImageUrl
        parameters["referral_code"] = referralCode
        parameters["facebook_token"] = facebookToken
        parameters["apple_code"] = appleAuthenCodeString
        return request(url: API.domain + "/user",
                       method: .post,
                       parameters: parameters)
    }
    
//    @discardableResult
//       func sendRegisterRequest(name: String,
//                                email: String,
//                                profileImageUrl: String?,
//                                appleAuthenCodeString: String? = nil) -> DataRequest {
//           var parameters = [String: Any]()
//           parameters["name"] = name
//           parameters["email"] = email
//           parameters["password"] = "12345678"
//           parameters["profile_image_url"] = profileImageUrl
//           parameters["apple_id"] = appleAuthenCodeString
//           return request(url: API.domain + "/user",
//                          method: .post,
//                          parameters: parameters,
//                          encoding: nil,
//                          successHandler: nil,
//                          failureHandler: nil)
//       }
    
    @discardableResult
    func sendFacebookAuthRequest(fbToken: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["facebook_token"] = fbToken
        addDeviceRelatedInfo(into: &parameters)
        return request(url: API.domain + "/authentication/facebook",
                       method: .post,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendAppleIDAuthRequest(authorizationCode: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["apple_code"] = authorizationCode
        addDeviceRelatedInfo(into: &parameters)
        return request(url: API.domain + "/authentication/apple",
                       method: .post,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendCheckAppleExistenceIDRequest(userIdentifier: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["apple_id"] = userIdentifier
        return request(url: API.domain + "/utility/check_apple_id",
                       method: .post,
                       parameters: parameters)
    }
    
    
    // Response contains access token only.
    @discardableResult
    func sendLoginEmailRequest(email: String, password: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["email"] = email
        parameters["password"] = password
        addDeviceRelatedInfo(into: &parameters)
        return request(url: API.domain + "/authentication",
                       method: .post,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendFindPlanOrdersRequest(offset: Int) -> DataRequest {
        return request(url: API.domain + "/plan_order",
                       method: .get,
                       parameters: ["$offset": offset])
        
    }
    
    @discardableResult
    func sendCreatePlanOrderRequest(planId: Int, discountCode: String?) -> DataRequest {
        var parameters = [String: Any]()
        parameters["plan_id"] = planId
        parameters["discount_code"] = discountCode
        return request(url: API.domain + "/plan_order",
                       method: .post,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendGetPlanOrderRequest(id: Int) -> DataRequest {
        return request(url: API.domain + "/plan_order/\(id)",
            method: .get,
            parameters: nil)
    }
    
    @discardableResult
    func sendGetPromotionCodeRequest(code: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["code"] = code
        return request(url: API.domain + "/promotion_code",
                       method: .get,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendGetDiscountCodeRequest(code: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["code"] = code
        return request(url: API.domain + "/discount_code",
                       method: .get,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendGettingUserProfileRequest() -> DataRequest {
        return request(url: API.domain + "/me",
                       method: .get,
                       parameters: nil)
    }
    
    @discardableResult
    func sendUpdatePasswordRequest(oldPassword: String, newPassword: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["old_password"] = oldPassword
        parameters["password"] = newPassword
        return request(url: API.domain + "/me/password",
                       method: .patch,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendUpdateProfileRequest(name:String?, email:String?, profileImageUrl: String?, appReviewed: Bool?) -> DataRequest{
        var parameters = [String: Any]()
        parameters["name"] = name
        parameters["email"] = email
        parameters["profile_image_url"] = profileImageUrl == nil ? NSNull() : profileImageUrl
        parameters["app_reviewed"] = appReviewed
        return request(url: API.domain + "/me",
                       method: .patch,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendUpdateEmailRequest(email: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["email"] = email
        addDeviceRelatedInfo(into: &parameters)
        return request(url: API.domain + "/me/email",
                       method: .post,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendForgotPasswordRequest(email: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["email"] = email
        addDeviceRelatedInfo(into: &parameters)
        return request(url: API.domain + "/utility/forgot_password",
                       method: .post,
                       parameters: parameters)
    }
    
    
    
    @discardableResult
    func sendFindPlansRequest() -> DataRequest {
        return request(url: API.domain + "/plan",
                       method: .get,
                       parameters: nil)
    }
    
    
    @discardableResult
    func sendGetPlanRequest(id: Int) -> DataRequest {
        return request(url: API.domain + "/plan/\(id)",
            method: .get,
            parameters: nil)
    }
    
    @discardableResult
    func sendFindBrandRequest() -> DataRequest {
        var parameters = [String: Any]()
        parameters["$limit"] = 100000
        return request(url: API.domain + "/brand",
                       method: .get,
                       parameters: nil)
    }
    
    @discardableResult
    func sendFindCategoryRequest(brandId: Int) -> DataRequest {
        var parameters = [String: Any]()
        parameters["brand_id"] = brandId
        parameters["$limit"] = 100000
        return request(url: API.domain + "/product_category",
                       method: .get,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendFindServiceLevelRequest() -> DataRequest {
        return request(url: API.domain + "/service_level",
                       method: .get,
                       parameters: nil)
    }
    
    @discardableResult
    func sendGetServiceLevelRequest(serviceLevelId: Int) -> DataRequest {
        var parameters = [String: Any]()
        parameters["id"] = serviceLevelId
        //        parameters["title"] = serviceLevelTitle
        //        parameters["credit"] = serviceLevelToken
        return request(url: API.domain + "/service_level",
                       method: .get,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendGetAppVersionRequest() -> DataRequest {
        return request(url: API.domain + "/app_version",
                       method: .get,
                       parameters: ["device": "ios", "version": appVersion, "app": "client"])
    }
    
    @discardableResult
    func sendGetStripeEphemeralKeyRequest(stripeVersion: String) -> DataRequest {
        return request(url: API.domain + "/utility/get_stripe_ephemeral_keys",
                       method: .get,
                       parameters: ["stripe_version": stripeVersion])
    }
    
    
    
    
    private func addDeviceRelatedInfo(into parameters: inout [String: Any]) {
        parameters["app"] = "client"
        parameters["app_version"] = appVersion
        parameters["device"] = "ios"
        parameters["device_version"] = UIDevice.current.systemVersion
    }
    
    // MARK: - Check Request List (User)
    @discardableResult
    func sendFindProductCheckRequest(statuses: [String], offset: Int) -> DataRequest {
        var parameters = [String: Any]()
        if statuses.count == 1 {
            parameters["status"] = statuses[0]
        } else if statuses.count == 2 {
            parameters["$or[0][status]"] = statuses[0]
            parameters["$or[1][status]"] = statuses[1]
        }
        parameters["role"] = "user"
        parameters["$offset"] = offset
        return request(url: API.domain + "/product_check_request",
                       method: .get,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendFindProductWithoutStatusCheckRequest(offset: Int) -> DataRequest {
        var parameters = [String: Any]()
        parameters["role"] = "user"
        parameters["$offset"] = offset
        return request(url: API.domain + "/product_check_request",
                       method: .get,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendFindProductPendingCheckRequest() -> DataRequest {
        var parameters = [String: Any]()
        parameters["$or[0][status]"] = "checker_check_pending"
        parameters["role"] = "user"
        return request(url: API.domain + "/product_check_request",
                       method: .get,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendGetProductCheckRequestForUser(id: Int) -> DataRequest {
        var parameters = [String: Any]()
        parameters["role"] = "user"
        return request(url: API.domain + "/product_check_request/\(id)",
            method: .get,
            parameters: parameters)
    }
    
    @discardableResult
    func sendGetProductCheckRequestForChecker(id: Int) -> DataRequest {
        var parameters = [String: Any]()
        parameters["role"] = "checker"
        return request(url: API.domain + "/product_check_request/\(id)",
            method: .get,
            parameters: parameters)
    }
    
    @discardableResult
    func sendCreateProductCheckRequest(productTitle: String,
                                       brandId: Int,
                                       categoryId: Int,
                                       serviceLevelId: Int,
                                       userRemark: String?,
                                       images: [[String: Any]]) -> DataRequest {
        var parameters = [String: Any]()
        parameters["product_title"] = productTitle
        parameters["brand_id"] = brandId
        parameters["category_id"] = categoryId
        parameters["service_level_id"] = serviceLevelId
        parameters["user_remark"] = userRemark
        parameters["images"] = images.isEmpty ? nil : images
        parameters["role"] = "user"
        return request(url: API.domain + "/product_check_request",
                       method: .post,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendUpdateProductCheckRequestRequest(id: Int,
                                              userRemark: String?,
                                              images: [[String: Any]]) -> DataRequest {
        var parameters = [String: Any]()
        parameters["status"] = "checker_check_pending"
        parameters["user_remark"] = userRemark
        parameters["images"] = images.isEmpty ? nil : images
        return request(url: API.domain + "/product_check_request/\(id)?role=user",
            method: .patch,
            parameters: parameters)
    }
    // MARK: - Check Request List (Feed)
    
    @discardableResult
    func sendFindRequestFeedCommentsRequest(checkRequstId: Int, offset: Int) -> DataRequest {
        var parameters = [String: Any]()
        parameters["$offset"] = offset
        parameters["$limit"] = 25
        return request(url: API.domain + "/product_check_request_feed/\(checkRequstId)/comment",
            method: .get,
            parameters: parameters)
        
    }
    
    @discardableResult
    func sendFindProductCheckFeedRequest(offset: Int, keyword: String? = nil, brandId: Int? = nil) -> DataRequest {
        var parameters = [String: Any]()
        parameters["$limit"] = 10
        parameters["$offset"] = offset
        parameters["brand_id"] = brandId
        parameters["keyword"] = keyword
        parameters["$sort[created_at]"] = -1
        return request(url: API.domain + "/product_check_request_feed",
                       method: .get,
                       parameters: parameters)
    }
    
    @discardableResult
    func sendGetProductCheckFeedRequest(id: Int) -> DataRequest {
        return request(url: API.domain + "/product_check_request_feed/\(id)",
            method: .get,
            parameters: nil)
    }
    
    @discardableResult
    func sendFindCompletedTotalRequest() -> DataRequest {
        return request(url: API.domain + "/product_check_request_feed_total",
                       method: .get,
                       parameters: nil)
    }
    
    @discardableResult
    func sendAddCommentRequest(id: Int, comment: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["comment"] = comment
        return request(url: API.domain + "/product_check_request_feed/\(id)/comment",
            method: .post,
            parameters: parameters)
    }
    
    @discardableResult
    func sendDeleteCommentRequest(id: Int) -> DataRequest {
        return request(url: API.domain + "/product_check_request_feed/comment/\(id)",
            method: .delete,
            parameters: nil)
    }
    
    @discardableResult
    func sendLikeOrUnlikeFeedItemRequest(id: Int, toLike: Bool) -> DataRequest {
        var parameters = [String: Any]()
        parameters["like"] = toLike
        return request(url: API.domain + "/product_check_request_feed/\(id)/like",
            method: .post,
            parameters: parameters)
    }
    
    // MARK: - Check Request List (Checker)
    
    
    @discardableResult
    func sendCheckerFindCheckRequestsRequest(statuses: [String], offset: Int, checkId: Int?, query: String?) -> DataRequest {
        var parameters = [String: Any]()
        parameters["checker_id"] = checkId
        if statuses.count == 1 {
            parameters["status"] = statuses[0]
        } else if statuses.count == 2 {
            parameters["$or[0][status]"] = statuses[0]
            parameters["$or[1][status]"] = statuses[1]
        }
        if let query = query {
            parameters["$or[0][uuid][$like]"] = "%\(query)%"
        }
        parameters["role"] = "checker"
        parameters["$offset"] = offset
        return request(url: API.domain + "/product_check_request",
                       method: .get,
                       parameters: parameters)
    }
    
    @discardableResult
       func sendCheckerFindCheckRequestsWithoutStatusRequest(offset: Int, checkId: Int?) -> DataRequest {
           var parameters = [String: Any]()
           parameters["role"] = "checker"
           parameters["$offset"] = offset
           return request(url: API.domain + "/product_check_request",
                          method: .get,
                          parameters: parameters)
       }
    
    @discardableResult
    func sendCheckerGetCheckRequestRequest(id: Int) -> DataRequest {
        var parameters = [String: Any]()
        parameters["role"] = "checker"
        return request(url: API.domain + "/product_check_request/\(id)",
            method: .get,
            parameters: parameters)
    }
    
    /// <#Description#>
    /// - Parameter id: <#id description#>
    /// - Parameter status: <#status description#>
    /// - Parameter result: String or NSNull()
    /// - Parameter checkerCheckSummary: <#checkerCheckSummary description#>
    /// - Parameter checkId: Int or NSNull()
    @discardableResult
    func sendCheckerUpdateCheckRequestRequest(id: Int,
                                              status: String?,
                                              result: Any?,
                                              summary: String?,
                                              checkerId: Any?) -> DataRequest {
        var parameters = [String: Any]()
        parameters["status"] = status
        parameters["result"] = result
        parameters["checker_check_summary"] = summary
        parameters["checker_id"] = checkerId
        return request(url: API.domain + "/product_check_request/\(id)?role=checker",
            method: .patch,
            parameters: parameters)
    }
    
    // MARK: - Deprecated APIs
    
    
}

#if canImport(SwiftyJSON)
import SwiftyJSON

extension DataRequest {
    
    func onError(handler: @escaping (Error) -> Void) -> Self {
        return responseJSON { response in
            guard response.value == nil else { return }
            if let data = response.data, !data.isEmpty {
                let apiError = APIError(json: JSON(data))
                dprint("------- Error \(apiError.code) -------")
                dprint((response.request?.httpMethod ?? "N/A") + " " + (response.request?.url?.absoluteString ?? "N/A"))
                dprint(apiError.json)
                handler(apiError)
            } else if let error = response.error {
                handler(error)
            }
        }
    }
    
    @discardableResult
    func onSuccess(handler: @escaping (SwiftyJSON.JSON) -> Void) -> Self {
        return responseJSON { response in
            if let value = response.value {
                handler(JSON(value))
                dprint("-------- Success --------")
                dprint((response.request?.httpMethod ?? "N/A") + " " + (response.request?.url?.absoluteString ?? "N/A"))
                dprint(JSON(value))
            }
        }
    }
    
    @discardableResult
    func finally(handler: @escaping () -> Void) -> Self {
        return responseJSON { _ in
            handler()
        }
    }
    
}
#endif

#if canImport(MBProgressHUD)
import MBProgressHUD

extension Error {
    var codeDescription: String? {
        let format = NSLocalizedString("Code %d", bundle: .language, comment: "HUD message, followed by a error code")
        switch self {
        case let err as APIError:
            return String(format: format, err.code)
        case let err as AFError:
            if case .responseValidationFailed(.unacceptableStatusCode(let code)) = err {
                return String(format: format, code)
            }
        case let err as NSError:
            return String(format: format, err.code)
        default:
            break
        }
        return nil
    }
    var isCancel: Bool {
        (self as NSError).code == NSURLErrorCancelled
    }
}

extension MBProgressHUD {
    func showServerError(_ error: Error?) {
        var text = NSLocalizedString("Network Error", bundle: .language, comment: "HUD message")
        var detailText: String?
        if let error = error {
            let format = NSLocalizedString("Code %d", bundle: .language, comment: "HUD message, followed by a error code")
            switch error {
            case let err as APIError:
                text = err.message
                detailText = String(format: format, locale: .languageAssociated, err.code)
            case let err as AFError:
                if case .responseValidationFailed(.unacceptableStatusCode(let code)) = err {
                    detailText = String(format: format, locale: .languageAssociated, code)
                }
            case let err as NSError:
                if err.code == NSURLErrorNotConnectedToInternet {
                    text = NSLocalizedString("We couldn’t connect to the server.", bundle: .language, comment: "HUD message")
                    detailText = NSLocalizedString("Please check your network.", bundle: .language, comment: "HUD message")
                } else {
                    detailText = String(format: format, locale: .languageAssociated, err.code)
                }
            default:
                break
            }
        }
        showError(text: text, detailText: detailText)
        #if DEVELOPMENT
        button.setTitle("Reason", for: .normal)
        button.addTarget(self, action: #selector(showJSONButtonDidPress(_:)), for: .touchUpInside)
        button.apiServerError = error
        #endif
    }
    
    #if DEVELOPMENT
    @objc private func showJSONButtonDidPress(_ sender: UIButton) {
        guard let hudTargetView = superview else { return }
        let hud = MBProgressHUD.showAdded(to: hudTargetView, animated: true)
        hud.mode = .text
        hud.label.textAlignment = .left
        hud.label.numberOfLines = 0
        if let error = button.apiServerError as? APIError {
            hud.label.text = error.json.rawString()
        } else if let error = button.apiServerError as NSError? {
            hud.label.text = error.localizedDescription
        }
        hud.button.setTitle("Hide", for: .normal)
        hud.button.addTarget(self, action: #selector(hideButtonDidPress(_:)), for: .touchUpInside)
    }
    
    @objc private func hideButtonDidPress(_ sender: UIButton) {
        hide(animated: true)
    }
    #endif
    
}
#if DEVELOPMENT
fileprivate extension UIButton {
    
    static var apiServerErrorKey = "hesse_apiServerErrorKey"
    
    var apiServerError: Error? {
        get {
            return objc_getAssociatedObject(self, &UIButton.apiServerErrorKey) as? Error
        }
        set {
            objc_setAssociatedObject(self, &UIButton.apiServerErrorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
#endif

extension UIViewController {
    func showServerErrorHUD(_ error: Error?) {
        let hud = MBProgressHUD.showAdded(to: hudTargetView, animated: true)
        hud.showServerError(error)
    }
}
#endif

#endif

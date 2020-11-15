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

public typealias SuccessHandler = (_ response: AnyObject?, _ statusCode: Int) -> Void
public typealias FailureHandler = (_ error: NetworkError?) -> Void
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
    
    var suppressesOnErrorIfCancelled: Bool = false
    
    let pageLimit: Int = 10
    
    @discardableResult
    func request(url: String, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding?, successHandler: SuccessHandler?, failureHandler: FailureHandler?) -> DataRequest {
        print("API: \(method.rawValue) \(url)")
        var headers: [String: String] = ["Accept": "application/json"]
        if let apiToken = UserDefaults.standard.userToken, !apiToken.isEmpty {
            headers["Authorization"] = "Bearer \(apiToken)"
            headers["Accept-Language"] = "zh-Hant" // TODO: Support multiple languages if needed.
        }
        let parameterEncoding: ParameterEncoding = encoding ?? (method == .get ? URLEncoding.queryString : JSONEncoding.default)
         return Alamofire.request(url, method: method, parameters: parameters, encoding: parameterEncoding, headers: headers)
            .validate()
            .validate(contentType: ["application/json", "text/json"])
            .responseJSON { (response) in
                let statusCode = response.response?.statusCode ?? -1
                switch response.result {
                case .failure(let error):
                    if statusCode == 401, let apiToken = UserDefaults.standard.userToken, !apiToken.isEmpty {
                        NotificationCenter.default.post(name: .accessTokenExpired, object: nil)
                    }
                    do {
                        if let data = response.data,
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                            let name = json["name"] as? String,
                            let message = json["message"] as? String {
                            if (statusCode == 401 && url == API.authentication) {
                                let error = NetworkError(title: "Invalid Login", message: "Please check your email and password again.", code: statusCode)
                                failureHandler?(error)
                                return
                            } else if (statusCode == 401) {
                                let error = NetworkError(title: "Session Expired", message: "Please login again.", code: statusCode)
                                failureHandler?(error)
                                return
                            }
                            let error = NetworkError(title: name, message: message, code: statusCode)
                            failureHandler?(error)
                            return
                        }
                    } catch {
                        print("CANNOT GET JSON")
                    }
                    print("ERROR: \(error)") // HTTP URL response
                    let error = NetworkError(title: error.localizedDescription, message: error.localizedDescription, code: statusCode)
                    failureHandler?(error)
                case .success:
                    successHandler?(response.result.value as AnyObject?, statusCode)
                }
        }
    }
    
    func uploadAsset(image: UIImage,
                     description: String?,
                     successHandler: ((_ jsonDict: [String: Any]) -> Void)?,
                     failureHandler: FailureHandler?) {
        guard let apiToken = UserDefaults.standard.userToken, !apiToken.isEmpty else {
            let error = NetworkError(title: "Invalid Permission", message: "Access token is required.", code: -1)
            failureHandler?(error)
            return
        }
        let imgData = image.orientationFixed.jpegData(compressionQuality: 0.2)!
//        Alamofire.upload(
//            multipartFormData: { multipartFormData in
//                multipartFormData.append(imgData, withName: "file", fileName: "file.jpg", mimeType: "image/jpg")
//                if let descriptionData = description?.data(using: .utf8) {
//                    multipartFormData.append(descriptionData, withName: "description")
//                }
//                if let widthData = "\(Int(image.size.width))".data(using: .utf8) {
//                    multipartFormData.append(widthData, withName: "width")
//                }
//                if let heightData = "\(Int(image.size.height))".data(using: .utf8) {
//                    multipartFormData.append(heightData, withName: "height")
//                }
//        },
//            to: API.assetImage,
//            headers: ["Authorization": "Bearer \(apiToken)"])
//        { (result) in
//            switch result {
//            case .success(let uploadRequest, _, _):
//                uploadRequest.validate().responseJSON { response in
//                    if let value = response.result.value as? [String: Any] {
//                        successHandler?(value)
//                    } else {
//                        failureHandler?(NetworkError())
//                    }
//                }
//                
//            case .failure(let encodingError):
//                let error = NetworkError(title: encodingError.localizedDescription, message: encodingError.localizedDescription, code: -1)
//                failureHandler?(error)
//            }
//        }
    }
    
    @discardableResult
    func sendCheckRegisterPhoneNumberRequest(phone: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["phone_number"] = phone
        return request(url: API.domain + "/utility/check_register_phone_number",
                       method: .post,
                       parameters: parameters,
                       encoding: nil,
                       successHandler: nil,
                       failureHandler: nil)
    }
    
    @discardableResult
    func sendCheckRegisterEmailRequest(email: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["email"] = email
        return request(url: API.domain + "/utility/check_register_email",
                       method: .post,
                       parameters: parameters,
                       encoding: nil,
                       successHandler: nil,
                       failureHandler: nil)
    }
    
    @discardableResult
    func sendRegistrationRequest(lastName: String,
                                 firstName: String,
                                 email: String,
                                 phoneNumber: String,
                                 password: String,
                                 smsCode: String) -> DataRequest {
        var parameters = [String: Any]()
        if lastName.areChinese && firstName.areChinese {
            parameters["last_name"] = ""
            parameters["first_name"] = ""
            parameters["last_name_tc"] = lastName
            parameters["first_name_tc"] = firstName
        } else {
            parameters["last_name"] = lastName
            parameters["first_name"] = firstName
            parameters["last_name_tc"] = ""
            parameters["first_name_tc"] = ""
        }
        parameters["email"] = email
        parameters["phone_number"] = phoneNumber
        parameters["password"] = password
        parameters["phone_sms"] = smsCode
        return request(url: API.user,
                       method: .post,
                       parameters: parameters,
                       encoding: nil,
                       successHandler: nil,
                       failureHandler: nil)
    }

    // Response contains access token only.
    @discardableResult
    func sendEmailLoginRequest(email: String, password: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["email"] = email
        parameters["password"] = password
        addDeviceRelatedInfo(into: &parameters)
        return request(url: API.authentication,
                       method: .post,
                       parameters: parameters,
                       encoding: nil,
                       successHandler: nil,
                       failureHandler: nil)
    }
    
    @discardableResult
    func sendPasswordAuthRequest(phone: String, password: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["phone_number"] = phone
        parameters["password"] = password
        addDeviceRelatedInfo(into: &parameters)
        return request(url: API.authentication,
                       method: .post,
                       parameters: parameters,
                       encoding: nil,
                       successHandler: nil,
                       failureHandler: nil)
    }
    
    @discardableResult
    func sendFacebookAuthRequest(fbToken: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["facebook_token"] = fbToken
        addDeviceRelatedInfo(into: &parameters)
        return request(url: API.domain + "/authentication/facebook",
                       method: .post,
                       parameters: parameters,
                       encoding: nil,
                       successHandler: nil,
                       failureHandler: nil)
    }
    
    @discardableResult
    func sendAppleIDAuthRequest(authorizationCode: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["apple_code"] = authorizationCode
        addDeviceRelatedInfo(into: &parameters)
        return request(url: API.domain + "/authentication/apple",
                       method: .post,
                       parameters: parameters,
                       encoding: nil,
                       successHandler: nil,
                       failureHandler: nil)
    }
    
    @discardableResult
    func sendCheckRegisterPhoneSMSRequest(phone: String, smsCode: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["phone_number"] = phone
        parameters["phone_sms"] = smsCode
        addDeviceRelatedInfo(into: &parameters)
        return request(url: API.domain + "/utility/check_register_phone_sms",
                       method: .post,
                       parameters: parameters,
                       encoding: nil,
                       successHandler: nil,
                       failureHandler: nil)
    }
    
    @discardableResult
    func sendGettingUserProfileRequest() -> DataRequest {
        return request(url: API.me,
                       method: .get,
                       parameters: nil,
                       encoding: nil,
                       successHandler: nil,
                       failureHandler: nil)
    }
    
    @discardableResult
    func sendUpdatePasswordRequest(oldPassword: String, newPassword: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["old_password"] = oldPassword
        parameters["password"] = newPassword
        return request(url: API.editPassword,
                       method: .patch,
                       parameters: parameters,
                       encoding: nil,
                       successHandler: nil,
                       failureHandler: nil)
    }
    
    @discardableResult
    func sendUpdateEmailRequest(email: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["email"] = email
        addDeviceRelatedInfo(into: &parameters)
        return request(url: API.domain + "/me/email",
                       method: .post,
                       parameters: parameters,
                       encoding: nil,
                       successHandler: nil,
                       failureHandler: nil)
    }
    
    @discardableResult
    func sendResetPasswordRequest(email: String) -> DataRequest {
        var parameters = [String: Any]()
        parameters["email"] = email
        addDeviceRelatedInfo(into: &parameters)
        return request(url: API.forgotPassword,
                       method: .post,
                       parameters: parameters,
                       encoding: nil,
                       successHandler: nil,
                       failureHandler: nil)
    }

    
    
    @discardableResult
    func sendGetStripeEphemeralKeyRequest(stripeVersion: String) -> DataRequest {
        return request(url: API.domain + "/utility/get_stripe_ephemeral_keys",
                       method: .get,
                       parameters: ["stripe_version": stripeVersion],
                       encoding: nil,
                       successHandler: nil,
                       failureHandler: nil)
    }
    
    @discardableResult
    func sendGetAppVersionRequest() -> DataRequest {
        return request(url: API.domain + "/app_version",
                       method: .get,
                       parameters: ["device": "ios", "version": appVersion, "app": "client"],
                       encoding: nil,
                       successHandler: nil,
                       failureHandler: nil)
    }

    
    private func addDeviceRelatedInfo(into parameters: inout [String: Any]) {
        parameters["app"] = "patient"
        parameters["app_version"] = appVersion
        parameters["device"] = "ios"
        parameters["device_version"] = UIDevice.current.systemVersion
    }
    
    // MARK: - Deprecated APIs
    
    
}

extension NetworkManager {
    /// The date formatter for posting date information to server.
    static let datePostingFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt
    }()
}

#if canImport(SwiftyJSON)
import SwiftyJSON

extension DataRequest {
    
    func onError(handler: @escaping (Error) -> Void) -> Self {
        return responseJSON { response in
            guard response.result.isFailure else { return }
            if NetworkManager.shared.suppressesOnErrorIfCancelled {
                if let error = response.error as NSError?, error.code == NSURLErrorCancelled {
                    return
                }
            }
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
            if let value = response.result.value {
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
                detailText = String(format: format, locale: .languageAssociated, err.code)
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

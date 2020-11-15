//
//  StripePaymentModule.swift

//  MobiDoc-Patient
//
//  Created by Hesse Huang on 28/1/2019.
//  Copyright © 2019 Binatir. All rights reserved.
//

#if canImport(Stripe)

import Foundation
import Alamofire
import Stripe

// Payment gateway using Stripe
class StripePaymentModule: NSObject {
    
    class EphemeralKeyProvider: NSObject, STPCustomerEphemeralKeyProvider {
        func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
            NetworkManager.shared.sendGetStripeEphemeralKeyRequest(stripeVersion: apiVersion)
                .validate(statusCode: 200..<300)
                .responseJSON { responseJSON in
                    switch responseJSON.result {
                    case .success(let json):
                        completion(json as? [String: AnyObject], nil)
                    case .failure(let error):
                        completion(nil, error)
                    }
                }
                .onSuccess { json in
                    // For printing the json.
            }
        }
    }
    
    let keyProvider: EphemeralKeyProvider
    let customerContext: STPCustomerContext
    let paymentContext: STPPaymentContext
    
    
    /// Initialize the payment module.
    ///
    /// - Parameters:
    ///   - amountValue: The amount in original unit, say like for HK$100, pass 100.
    ///   - currency: Which currency to pay.
    ///   - hostViewController: Which view controller is calling.
    ///   - paymentContextDelegate: The Stripe payment context object.
    init(amountValue: Double,
         currency: String,
         defaultPaymentMethodStripeId: String?,
         hostViewController: UIViewController,
         paymentContextDelegate: STPPaymentContextDelegate) {
        let keyProvider = EphemeralKeyProvider()
        let customerContext = STPCustomerContext(keyProvider: keyProvider)
        customerContext.includeApplePayPaymentMethods = false
        let paymentContext = STPPaymentContext(customerContext: customerContext,
                                               configuration: STPPaymentConfiguration.shared(),
                                               theme: STPTheme.default())
        paymentContext.defaultPaymentMethod = defaultPaymentMethodStripeId
        paymentContext.delegate = paymentContextDelegate
        paymentContext.hostViewController = hostViewController
        paymentContext.paymentAmount = Int(amountValue * 100) // Convert to cents, which is required by Stripe.
        paymentContext.paymentCurrency = currency
        
        self.keyProvider = keyProvider
        self.customerContext = customerContext
        self.paymentContext = paymentContext
    }
    
}

#endif

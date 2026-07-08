//
//  AddCardViewModel.swift
//  EPG
//
//  Created by Mohd Arsad on 08/11/22.
//

import Foundation
import UIKit

class AddCardViewModel {

}

//MARK: - APIs
extension AddCardViewModel {
    
    /// Validate Entered data
    /// - Parameters:
    ///   - card: card number
    ///   - expiryDate: expiry date
    ///   - cvvCode: cvv code
    /// - Returns: validated parameters and error message
    func validate(card: String?, expiryDate: String?, cvvCode: String?) -> (params: [String: Any]?, errorMessage: String?)? {
        guard let cardNo = card, cardNo.count > 0 else {
            return (params: nil, errorMessage: EPGConstant.shared.enter_card_number)
        }
        guard let expiry = expiryDate, expiry.count > 0 else {
            return (params: nil, errorMessage: EPGConstant.shared.enter_expiry_date)
        }
        guard let cvv = cvvCode, cvv.count > 0 else {
            return (params: nil, errorMessage: EPGConstant.shared.enter_cvv)
        }
        let numberOnly = cardNo.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        var params: [String: Any] = [:]
        params["VerifyCode"] = cvv
        params["ExpiryMonth"] = expiry.components(separatedBy: "/").first ?? ""
        params["ExpiryYear"] = expiry.components(separatedBy: "/").last ?? ""
        params["CardNumber"] = numberOnly
        return (params: params, errorMessage: nil)
    }
    
    
    /// Expiry Date Validation
    /// - Parameter dateStr: entered expiry date
    /// - Returns: valid
    func expDateValidation(dateStr:String) -> Bool {

        let currentYear = Calendar.current.component(.year, from: Date()) % 100   // This will give you current year (i.e. if 2019 then it will be 19)
        let currentMonth = Calendar.current.component(.month, from: Date()) // This will give you current month (i.e if June then it will be 6)

        let enteredYear = Int(dateStr.suffix(2)) ?? 0 // get last two digit from entered string as year
        let enteredMonth = Int(dateStr.prefix(2)) ?? 0 // get first two digit from entered string as month

        if enteredYear > currentYear {
            return (1 ... 12).contains(enteredMonth)
        } else if currentYear == enteredYear {
            if enteredMonth >= currentMonth {
                return (1 ... 12).contains(enteredMonth)
            }
        }
        return false
    }
 
    /// Preauthenticated params
    /// - Parameter cardInfo: card parameters
    /// - Returns: complete parameters
    func getPreAuthenticateParams(cardInfo: [String: Any]) -> [String: Any] {
        var params: [String: Any] = cardInfo
        params["UserName"] = EPGPayment.shared.merchantUserName
        params["Customer"] = EPGPayment.shared.customerName
        params["Instrument"] = "C"
        params["TransactionID"] = EPGPayment.shared.transactionId
        params["AuthenticationToken"] = EPGPayment.shared.authenticationToken
        params["Client"] = RestAPI.shared.getAgentParams()
        return params
    }
    
    func getPreAuthenticationData(cardParams: [String: Any], completion: @escaping(_ response: PreAuthenticateResponse?) -> ()) {
        let fullParams = ["PreAuthenticateInApp": getPreAuthenticateParams(cardInfo: cardParams)]

        // ============================================================
        // 🔍 [EPG-DEBUG] PreAuthenticate REQUEST
        // ============================================================
        EPGLogger.debug("\n🔍 [EPG-DEBUG] ===== PreAuthenticate REQUEST =====")
        EPGLogger.debug("   ➤ Params: \(fullParams)")
        EPGLogger.debug("🔍 [EPG-DEBUG] =====================================\n")
        // ============================================================

        ActivityIndicator.showActivity()
        RestAPI.shared.preAuthenticate(params: fullParams) { response in
            DispatchQueue.main.async {
                ActivityIndicator.hideActivity()

                // ============================================================
                // 🔍 [EPG-DEBUG] PreAuthenticate RESPONSE
                // ============================================================
                EPGLogger.debug("\n🔍 [EPG-DEBUG] ===== PreAuthenticate RESPONSE =====")
                if let response = response {
                    EPGLogger.debug("   ➤ ResponseCode: \(response.PreAuthenticateInApp?.ResponseCode ?? "nil")")
                    EPGLogger.debug("   ➤ ResponseDescription: \(response.PreAuthenticateInApp?.ResponseDescription ?? "nil")")
                    EPGLogger.debug("   ➤ ChallengeRequired: \(response.PreAuthenticateInApp?.ChallengeRequired ?? "nil")")
                    EPGLogger.debug("   ➤ RedirectionURL: \(response.PreAuthenticateInApp?.RedirectionURL ?? "nil")")
                    EPGLogger.debug("   ➤ transaction.ResponseCode: \(response.transaction?.ResponseCode ?? "nil")")
                    EPGLogger.debug("   ➤ transaction.ResponseDescription: \(response.transaction?.ResponseDescription ?? "nil")")
                } else {
                    EPGLogger.debug("   ❌ Response is nil")
                }
                EPGLogger.debug("🔍 [EPG-DEBUG] ======================================\n")
                // ============================================================

                completion(response)
            }
        }
    }
    // Validate Card Number
//    func getValidateCardParams(cardNumber: String) -> [String: Any] {
//           var params: [String: Any] = [:]
//        print("paramssssssss",params)
//           params["CardNumber"] = cardNumber
////           params["UserName"] = EPGPayment.shared.merchantUserName
////           params["Customer"] = EPGPayment.shared.customerName
//           params["TransactionID"] = EPGPayment.shared.transactionId
////           params["AuthenticationToken"] = EPGPayment.shared.authenticationToken
////           params["Client"] = RestAPI.shared.getAgentParams()
//           return params
//       }
    func getValidateCardParams(cardNumber: String) -> [String: Any] {
        EPGLogger.debug("cardNumber: \(cardNumber)")
        EPGLogger.debug("customerName: \(EPGPayment.shared.customerName ?? "nil")")
        EPGLogger.debug("authenticationToken: \(EPGPayment.shared.authenticationToken ?? "nil")")
        EPGLogger.debug("transactionId: \(EPGPayment.shared.transactionId ?? "nil")")
        EPGLogger.debug("password set: \(EPGPayment.shared.password != nil)")
  
        var params: [String: Any] = [:]
        
        var requestBody: [String: Any] = [
            "Customer": EPGPayment.shared.customerName ?? "",
            "Store": "MobileSDK",
            "Terminal": "MobileSDK",
            "AuthenticationToken": EPGPayment.shared.authenticationToken ?? "",
            "TransactionID": EPGPayment.shared.transactionId ?? "",
            "CardNumber": cardNumber.replacingOccurrences(of: " ", with: ""),
            "UserName": EPGPayment.shared.merchantUserName ?? ""
        ]

        // Password is merchant-supplied via EPGPaymentRequest — never hardcoded.
        if let password = EPGPayment.shared.password, !password.isEmpty {
            requestBody["Password"] = password
        }

        params["GetEmvco3DS2AcsDetail"] = requestBody
        
        return params
    }
    


    // MARK: - Recurrence PreAuth
    // Mirror of Android: viewModel.preAuthCall(isRecurrencePayment: true)
    // In recurrence mode CardNumber & ExpiryMonth/Year are NOT sent — only CVV (VerifyCode).
    // The server already knows the saved card from CardMask / TransactionID.
    // isSubsequentRecurrenceCode = true is sent ONLY for this recurrence PreAuth call.
    func getPreAuthenticateParamsRecurrence(cvv: String) -> [String: Any] {
        var params: [String: Any] = [:]
        params["VerifyCode"]                  = cvv
        params["UserName"]                    = EPGPayment.shared.merchantUserName
        params["Customer"]                    = EPGPayment.shared.customerName
        params["Instrument"]                  = "C"
        params["TransactionID"]               = EPGPayment.shared.transactionId
        params["AuthenticationToken"]         = EPGPayment.shared.authenticationToken
        params["Client"]                      = RestAPI.shared.getAgentParams()
        // Sent only in the recurrence flow — flags this PreAuth call as a
        // subsequent (saved-card) recurrence transaction, not a fresh card entry.
        params["IsSubsequentRecurrence"]  = true
        // CardNumber, ExpiryMonth, ExpiryYear intentionally omitted for recurrence
        return params
    }

    func getPreAuthenticationDataRecurrence(cvv: String, completion: @escaping(_ response: PreAuthenticateResponse?) -> ()) {
        let bodyParams = getPreAuthenticateParamsRecurrence(cvv: cvv)
        let fullParams = ["PreAuthenticateInApp": bodyParams]

        EPGLogger.recurrence("===== Recurrence PreAuthenticate REQUEST =====")
        EPGLogger.recurrence("  Body: \(bodyParams)")
        EPGLogger.recurrence("  Full Params: \(fullParams)")
        if let isSubsequent = bodyParams["IsSubsequentRecurrence"] {
            EPGLogger.recurrence("  IsSubsequentRecurrence: \(isSubsequent)")
        }

        // Pretty-print the exact JSON body being sent, for full visibility.
        if let jsonData = try? JSONSerialization.data(withJSONObject: fullParams, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            EPGLogger.recurrence("  JSON Body:\n\(jsonString)")
        }

        ActivityIndicator.showActivity()
        RestAPI.shared.preAuthenticate(params: fullParams) { response in
            DispatchQueue.main.async {
                ActivityIndicator.hideActivity()

                EPGLogger.recurrence("===== Recurrence PreAuthenticate RESPONSE =====")
                if let response = response {
                    EPGLogger.recurrence("  ResponseCode: \(response.PreAuthenticateInApp?.ResponseCode ?? "nil")")
                    EPGLogger.recurrence("  ChallengeRequired: \(response.PreAuthenticateInApp?.ChallengeRequired ?? "nil")")
                } else {
                    EPGLogger.warning("  Response is nil")
                }

                completion(response)
            }
        }
    }

       func validateCardData(cardNumber: String, completion: @escaping (_ response: EmvCo3DS2AcsDetailResponse?) -> ()) {
           let params = getValidateCardParams(cardNumber: cardNumber)

           // ============================================================
           // 🔍 [EPG-DEBUG] ValidateCard REQUEST
           // ============================================================
           EPGLogger.debug("\n🔍 [EPG-DEBUG] ===== ValidateCard REQUEST =====")
           EPGLogger.debug("   ➤ Params: \(params)")
           EPGLogger.debug("🔍 [EPG-DEBUG] =================================\n")
           // ============================================================

           ActivityIndicator.showActivity()
           RestAPI.shared.validateCard(params: params) { response in
               // ============================================================
               // 🔍 [EPG-DEBUG] ValidateCard RESPONSE
               // ============================================================
               EPGLogger.debug("\n🔍 [EPG-DEBUG] ===== ValidateCard RESPONSE =====")
               if let response = response {
                   EPGLogger.debug("   ➤ ResponseCode: \(response.transaction?.responseCode ?? "nil")")
                   EPGLogger.debug("   ➤ ResponseDescription: \(response.transaction?.responseDescription ?? "nil")")
                   EPGLogger.debug("   ➤ isSDKEnabled: \(String(describing: response.transaction?.isSDKEnabled))")
                   EPGLogger.debug("   ➤ acsThreeDSVersion: \(response.transaction?.acsThreeDSVersion ?? "nil")")
               } else {
                   EPGLogger.debug("   ❌ Response is nil")
               }
               EPGLogger.debug("🔍 [EPG-DEBUG] ==================================\n")
               // ============================================================

               EPGLogger.debug("CardDataREsponse>>>>>>>>>>>> \(String(describing: response))")
               DispatchQueue.main.async {
                   ActivityIndicator.hideActivity()
                   completion(response)
               }
           }
       }

}

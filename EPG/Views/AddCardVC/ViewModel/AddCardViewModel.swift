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
        ActivityIndicator.showActivity()
        RestAPI.shared.preAuthenticate(params: ["PreAuthenticateInApp": getPreAuthenticateParams(cardInfo: cardParams)]) { response in
            DispatchQueue.main.async {
                ActivityIndicator.hideActivity()
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
        print("cardNumber:", cardNumber)
           print("customerName:", EPGPayment.shared.customerName ?? "nil")
           print("authenticationToken:", EPGPayment.shared.authenticationToken ?? "nil")
           print("transactionId:", EPGPayment.shared.transactionId ?? "nil")
  
        var params: [String: Any] = [:]
        
        params["GetEmvco3DS2AcsDetail"] = [
            "Customer": EPGPayment.shared.customerName ?? "DefaultCustomer",
            "Password":"Comtrust@20182018",
            "Store": "MobileSDK",
            "Terminal": "MobileSDK",
            "AuthenticationToken": EPGPayment.shared.authenticationToken ?? "",
            "TransactionID": EPGPayment.shared.transactionId ?? "",
            "CardNumber": cardNumber.replacingOccurrences(of: " ", with: ""),
            "UserName":EPGPayment.shared.merchantUserName ?? ""
        ]
        
        return params
    }
    


       func validateCardData(cardNumber: String, completion: @escaping (_ response: EmvCo3DS2AcsDetailResponse?) -> ()) {
           ActivityIndicator.showActivity()
           RestAPI.shared.validateCard(params:  getValidateCardParams(cardNumber: cardNumber)) { response in
               print("CardDataREsponse>>>>>>>>>>>>",response)
               DispatchQueue.main.async {
                   ActivityIndicator.hideActivity()
                   completion(response)
               }
           }
       }

}


   

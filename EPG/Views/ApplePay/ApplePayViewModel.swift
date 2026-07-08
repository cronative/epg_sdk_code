//
//  ApplePayViewModel.swift
//  EPG
//
//  Created by Mohd Arsad on 06/03/2023.
//

import Foundation
import UIKit
import PassKit

class ApplePayViewModel {
    var sessionResponse: WalletSessionResponse? {
        didSet {
            self.bindCreateSessionModelToController()
        }
    }
    var paymentSubmitResponse: WalletSessionResponse? {
        didSet {
            self.bindSubmitPaymentModelToController()
        }
    }
    var applePayPaymentToken: PKPaymentToken?
    var paymentMethodResponse: [String: Any] = [:]
    
    var bindCreateSessionModelToController : (() -> ()) = {}
    var bindSubmitPaymentModelToController : (() -> ()) = {}
}

//MARK: - APIs
extension ApplePayViewModel {
    private func createWalletSessionParams() -> [String: Any] {
        var paramObject: [String: Any] = [:]
        paramObject["TransactionID"] = EPGPayment.shared.transactionId ?? ""
        paramObject["Customer"] = EPGPayment.shared.customerName ?? ""
        // SessionID and AuthenticationToken are two distinct fields — mirrors Android's
        // WalletCreateSession(transactionID, customer, sessionID, authenticationToken, userName, password).
        paramObject["SessionID"] = EPGPayment.shared.walletSessionID ?? ""
        paramObject["AuthenticationToken"] = EPGPayment.shared.authenticationToken ?? ""
        paramObject["UserName"] = EPGPayment.shared.merchantUserName ?? ""
        if let password = EPGPayment.shared.password, !password.isEmpty {
            paramObject["Password"] = password
        }

        let params: [String: Any] = ["WalletCreateSession": paramObject]

        EPGLogger.recurrence("===== WalletCreateSession REQUEST =====")
        EPGLogger.recurrence("  Body: \(paramObject)")
        if let jsonData = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            EPGLogger.recurrence("  JSON Body:\n\(jsonString)")
        }

        return params
    }
    private func walletPaymentData() -> [String: Any]? {
       
        guard let token = self.applePayPaymentToken else {
            return nil
        }
        let type = token.paymentMethod.type
        let network = token.paymentMethod.network
        let displayName = token.paymentMethod.displayName
        
        print("PaymentData Size:", token.paymentData.count)

        if let jsonString = String(data: token.paymentData, encoding: .utf8) {
            print("Apple Pay JSON:")
            print(jsonString)
        } else {
            print("Unable to convert paymentData to String")
        }
        
        let applePayResponse = EPGHelper.getObject(paymentData: token.paymentData) ?? [:]
        
        var paymentMethod: [String: Any] = [:]
        paymentMethod["displayName"] = displayName ?? ""
        paymentMethod["network"] = network?.rawValue ?? ""
        paymentMethod["type"] = type.title
        
        var paymentDetails: [String: Any] = [:]
        paymentDetails["paymentData"] = applePayResponse
        paymentDetails["paymentMethod"] = paymentMethod
        paymentDetails["transactionIdentifier"] = token.transactionIdentifier
        
        guard let paymentJSONString = EPGHelper.getJSONString(object: paymentDetails) else {
            return nil
        }
        if EPGPayment.shared.isPrintMsgEnabled {
            print("JSON String: \(paymentJSONString)")
        }
        
        var paramObject: [String: Any] = [:]
        paramObject["TransactionID"] = EPGPayment.shared.transactionId ?? ""
        // SessionID and AuthenticationToken are two distinct fields, same as WalletCreateSession.
        paramObject["SessionID"] = EPGPayment.shared.walletSessionID ?? ""
        paramObject["AuthenticationToken"] = EPGPayment.shared.authenticationToken ?? ""
        paramObject["Customer"] = EPGPayment.shared.customerName ?? ""
        paramObject["UserName"] = EPGPayment.shared.merchantUserName ?? ""
        paramObject["WalletResponseJSON"] = paymentJSONString
        
        let params: [String: Any] = ["WalletSubmitPayload": paramObject]

        EPGLogger.recurrence("===== WalletSubmitPayload REQUEST =====")
        EPGLogger.recurrence("  Body: \(paramObject)")
        if let jsonData = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            EPGLogger.recurrence("  JSON Body:\n\(jsonString)")
        }

        return params
    }
    
    func createWalletSession() {
        ActivityIndicator.showActivity()
        RestAPI.shared.createWalletSession(params: self.createWalletSessionParams()) { response in
            DispatchQueue.main.async {
                ActivityIndicator.hideActivity()

                // Store SessionID from WalletCreateSession response —
                // this will be passed in WalletSubmitPayload.
                if let sessionID = response?.transaction?.SessionID, !sessionID.isEmpty {
                    EPGLogger.recurrence("WalletCreateSession — SessionID received: \(sessionID)")
                    EPGPayment.shared.walletSessionID = sessionID
                } else {
                    EPGLogger.warning("WalletCreateSession — SessionID NOT found in response, ResponseCode: \(response?.transaction?.ResponseCode ?? "nil")")
                }

                self.sessionResponse = response
            }
        }
    }
    
    func walletSubmitPayment(completion: @escaping(_ isSuccess: Bool) -> ()) {
        guard let params = self.walletPaymentData() else {
            completion(false)
            return
        }
      //  completion(true)
        ActivityIndicator.showActivity()
        RestAPI.shared.walletSubmitSession(paymentParams: params) { response in
            DispatchQueue.main.async {
                ActivityIndicator.hideActivity()
//                self.paymentSubmitResponse = response
                completion(true)
            }
        }
    }
}


/*
 let version = jsonData!["version"] as? String ?? ""
 let data = jsonData!["data"] as? String ?? ""
 let signature = jsonData!["signature"] as? String ?? ""
 let ephemeralPublicKey = (jsonData!["header"] as? [String: String] ?? [:])["ephemeralPublicKey"] ?? ""
 let publicKeyHash = (jsonData!["header"] as! [String: String])["publicKeyHash"]! as String
 let transactionId = (jsonData!["header"] as! [String: String])["transactionId"]! as String
 
 var payStr = "{\"data\":\"\(data)\",\"signature\":\"\(signature)\",\"header\":{\"publicKeyHash\":\"\(publicKeyHash)\",\"ephemeralPublicKey\":\"\(ephemeralPublicKey)\",\"transactionId\":\"\(transactionId)\"},\"version\":\"\(version)\"}"
 */

//
//  GooglePayViewModel.swift
//  EPG
//
//  Created by Mohd Arsad on 21/03/2023.
//

import Foundation
import UIKit
import PassKit

class GooglePayViewModel {
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
extension GooglePayViewModel {
    private func createWalletSessionParams() -> [String: Any] {
        var paramObject: [String: Any] = [:]
        paramObject["TransactionID"] = EPGPayment.shared.transactionId ?? ""
        paramObject["SessionID"] = EPGPayment.shared.authenticationToken ?? ""
        paramObject["Customer"] = EPGPayment.shared.customerName ?? ""
        paramObject["UserName"] = EPGPayment.shared.merchantUserName ?? ""
        
        let params: [String: Any] = ["WalletCreateSession": paramObject]
        return params
    }
    private func walletPaymentData() -> [String: Any]? {
       
        guard let token = self.applePayPaymentToken else {
            return nil
        }
        let type = token.paymentMethod.type
        let network = token.paymentMethod.network
        let displayName = token.paymentMethod.displayName
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
        paramObject["SessionID"] = EPGPayment.shared.authenticationToken ?? ""
        paramObject["Customer"] = EPGPayment.shared.customerName ?? ""
        paramObject["UserName"] = EPGPayment.shared.merchantUserName ?? ""
        paramObject["WalletResponseJSON"] = paymentJSONString
        
        let params: [String: Any] = ["WalletSubmitPayload": paramObject]
        if EPGPayment.shared.isPrintMsgEnabled {
            print("Wallet Payment Payload Params: \(EPGHelper.getJSONString(object: params) ?? "")")
        }
        return params
    }
    
    func createWalletSession() {
        ActivityIndicator.showActivity()
        RestAPI.shared.createWalletSession(params: self.createWalletSessionParams()) { response in
            DispatchQueue.main.async {
                ActivityIndicator.hideActivity()
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

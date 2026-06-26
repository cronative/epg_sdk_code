//
//  PaymentDetailViewModel.swift
//  EPG
//
//  Created by Mohd Arsad on 08/11/22.
//

import Foundation
import UIKit

internal protocol PaymentDetailDelegate {
    func paymentDetailDelegate(onSuccess paymentSuccess: Bool)
    func paymentDetailDelegate(otpVerifyFailed errorMessage: String?, isBackPressed: Bool)
    func paymentDetailDelegate(addCardFailed errorMessage: String?)
}

class PaymentDetailViewModel {
    
    var paymentResponse: PaymentDataResponse? {
        didSet {
            self.bindPaymentModelToController()
        }
    }
    var preWalletResponse: WalletSessionResponse? {
        didSet {
            self.bindWalletModelToController()
        }
    }
    
    var bindPaymentModelToController : (() -> ()) = {}
    var bindWalletModelToController : (() -> ()) = {}
}

//MARK: - APIs
extension PaymentDetailViewModel {
    
    private func getPaymentDataParams() -> [String: Any] {
        var params: [String: Any] = [:]
        params["UserName"] = EPGPayment.shared.merchantUserName
        params["Client"] = RestAPI.shared.getAgentParams()
        params["Language"] = LocalizationSystem.shared.isArabicActive ? "ar" : "en"
        params["TransactionID"] = EPGPayment.shared.transactionId
        params["AuthenticationToken"] = EPGPayment.shared.authenticationToken
        params["Customer"] = EPGPayment.shared.customerName
        if EPGPayment.shared.isPrintMsgEnabled {
            print("Get Payment Data Params: \(params)")
        }
        return params
    }
    
    private func getPreWalletParams(walletName: String) -> [String: Any] {
        var params: [String: Any] = [:]
        params["Language"] = LocalizationSystem.shared.isArabicActive ? "ar" : "en"
        params["Client"] = RestAPI.shared.getAgentParams()
        params["TransactionID"] = EPGPayment.shared.transactionId
        params["Customer"] = EPGPayment.shared.customerName
        params["WalletName"] = walletName
        params["AuthenticationToken"] = EPGPayment.shared.authenticationToken
        params["UserName"] = EPGPayment.shared.merchantUserName
        if EPGPayment.shared.isPrintMsgEnabled {
            print("Pre Wallet Params: \(params)")
        }
        return params
    }
    
    func getPaymentData() {
        ActivityIndicator.showActivity()
        RestAPI.shared.getPaymentData(params: ["PaymentDataInApp": getPaymentDataParams()]) { response in
            DispatchQueue.main.async {
                ActivityIndicator.hideActivity()
                self.paymentResponse = response
            }
        }
    }
    
    func cancelTransaction(completion: @escaping(_ isCancelled: Bool) -> ()) {
        ActivityIndicator.showActivity()
        RestAPI.shared.cancelTransaction { isCancelled in
            DispatchQueue.main.async {
                ActivityIndicator.hideActivity()
                if EPGPayment.shared.isPrintMsgEnabled {
                    print("isCancelled: \(isCancelled)")
                }
                completion(isCancelled)
            }
        }
    }
    
    func createPreWallet(walletName: String) {
        ActivityIndicator.showActivity()
        RestAPI.shared.preWalletInApp(params: ["PreWalletInApp": self.getPreWalletParams(walletName: walletName)]) { response in
            DispatchQueue.main.async {
                ActivityIndicator.hideActivity()
                self.preWalletResponse = response
            }
        }
    }
}

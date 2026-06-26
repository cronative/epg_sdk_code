//
//  EPGApplePay.swift
//  EPG
//
//  Created by Mohd Arsad on 07/12/22.
//

import Foundation
import UIKit
import PassKit

typealias PaymentCompletionHandler = (Bool, String) -> Void

internal class EPGApplePay: NSObject {
    
    static let shared = EPGApplePay()
    var superController: UIViewController?
    var completionHandler: PaymentCompletionHandler!
    var applePayViewModel: ApplePayViewModel!
    
    static let supportedNetworks: [PKPaymentNetwork] = [.amex, .discover, .masterCard, .visa]

    class func applePayStatus() -> (canMakePayments: Bool, canSetupCards: Bool) {
        return (PKPaymentAuthorizationController.canMakePayments(),
                PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks))
    }
    
    func initiateApplePay(viewController: UIViewController, amount: NSDecimalNumber, completion: @escaping PaymentCompletionHandler) {
        self.superController = viewController
        self.completionHandler = completion
        self.setupViewModel(amount: amount)
    }
    
    func setupViewModel(amount: NSDecimalNumber) {
        self.applePayViewModel = ApplePayViewModel()
        self.applePayViewModel.createWalletSession()
        self.applePayViewModel.bindCreateSessionModelToController = {
            guard let _ = self.applePayViewModel.sessionResponse else {
                return
            }
            //Wallet Session Created
            self.startApplePay(amount: amount)
        }
        self.applePayViewModel.bindSubmitPaymentModelToController = {
            guard let response = self.applePayViewModel.paymentSubmitResponse else {
                self.completionHandler(false, "Response not available")
                return
            }
            //Wallet Payment Submitted
            if EPGPayment.shared.isPrintMsgEnabled {
                print("Payment Submitted to Server: \(response)")
            }
            self.completionHandler(true, "Success")
        }
    }
    
    private func startApplePay(amount: NSDecimalNumber) {
        
        let total = PKPaymentSummaryItem(label: "Total", amount: amount, type: .final)
        
        // Create a payment request.
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = [total]
        paymentRequest.merchantIdentifier = EPGPayment.shared.merchantIdentifier!
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = "AE"
        paymentRequest.currencyCode = "AED"
        paymentRequest.supportedNetworks = EPGApplePay.supportedNetworks
        
        if let controller = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest), let superController = self.superController {
            controller.delegate = self
            superController.present(controller, animated: true, completion: nil)
        } else {
            self.completionHandler(false, "Apple Pay not initiated")
        }
    }
}

extension EPGApplePay: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        let applePayResponse = String(data: payment.token.paymentData, encoding: .utf8) ?? ""
        let type = payment.token.paymentMethod.type
        let network = payment.token.paymentMethod.network
        let displayName = payment.token.paymentMethod.displayName
        
        self.applePayViewModel.paymentMethodResponse = ["displayName": "\(displayName ?? "")", "network": "\(network?.rawValue ?? "")", "type": "\(type.title)"]
        if EPGPayment.shared.isPrintMsgEnabled {
            print("Payment Methods: \(self.applePayViewModel.paymentMethodResponse) \nResponse: \(applePayResponse)")
        }
        self.applePayViewModel.applePayPaymentToken = payment.token
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
 
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) {
            self.submitPayload()
        }
    }
    
    func submitPayload() {
        print("Wallet Submit Payment Started...")
        self.applePayViewModel.walletSubmitPayment { isSuccess in
            print("walletSubmitPayment: \(isSuccess)")
            self.completionHandler(isSuccess, "Success")
        }
    }
}

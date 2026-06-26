//
//  EPG.swift
//  EMVco
//  Created by eand ePayment on 12/11/24.
//

import Foundation
import UIKit

public protocol EMVcoDelegate: AnyObject {
    func epgPayment(delegate result: EMVcoResult?)
}

var epgRootController: UIViewController?
//internal var selectedTheme: Theme = .auto
extension String {
    /// Removes all whitespaces from the string
    func removingWhitespaces() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
}
public class EMVcoPayment: NSObject {
   
    public static let shared = EMVcoPayment()
    public var delegate: EMVcoDelegate?
//    public var theme: Theme = .auto {
//        didSet {
//            selectedTheme = self.theme
//        }
//    }
//    public var isApplePaySupported: Bool {
//        return EPGApplePay.applePayStatus().canMakePayments
//    }
//    
    internal let isPrintMsgEnabled = false
    internal var merchantUserName: String?
    internal var transactionId: String?
    internal var authenticationToken: String?
    internal var merchantIdentifier: String?
    internal var customerName: String?
    internal var callBackURL: String?
    internal var amountToPayText: String?
    internal var showVat: Bool = true
    internal var addressIP: String = "192.168.21.8"
    internal var port: String = "443"
    internal var agent: String = "mozilla"
    internal var sdkKey: String = "ios"
    internal var sdkVersion: String = "1.0"
    internal var currency: String = "AED"
    internal var amount: String = "0.0"
//    internal var epgApplePayRequest: EPGPaymentApplePayRequest?
    
    public var epgRequest: EPGPaymentRequest?
    
    public init(controller: UIViewController) {
        super.init()
//        self.setupSDK(with: controller)
    }
    
    public override init() {
    }
    
    public func initiatePayment(with request: EPGPaymentRequest) {
        self.epgRequest = request
//        self.startPayment()
    }
    
//    public func initiatePaymentApplePay(with request: EPGPaymentApplePayRequest) {
////        self.epgApplePayRequest = request
//        self.startApplePay()
//    }
}

//MARK: - Private & Internal Functions
extension EMVcoPayment {
    internal func validate() -> String? {
        guard let merchantName = self.epgRequest?.merchantUserName, merchantName.removingWhitespaces().count > 0 else {
            return EMVcoConstant.shared.validate_merchant_name
        }
        guard let transactionId = self.epgRequest?.transactionId, transactionId.removingWhitespaces().count > 0 else {
            return EMVcoConstant.shared.validate_trans_id
        }
        guard let authToken = self.epgRequest?.authenticationToken, authToken.removingWhitespaces().count > 0 else {
            return EMVcoConstant.shared.validate_auth_token
        }
        guard let customerName = self.epgRequest?.customerName, customerName.removingWhitespaces().count > 0 else {
            return EMVcoConstant.shared.validate_customer_name
        }
        guard let callBack = self.epgRequest?.callBackURL, callBack.removingWhitespaces().count > 0 else {
            return EMVcoConstant.shared.validate_callback_url
        }
        return nil
    }
    
//    internal func validateApplePay() -> String? {
//        guard let merchantName = self.epgApplePayRequest?.merchantUserName, merchantName.removingWhitespaces().count > 0 else {
//            return EPGConstant.shared.validate_merchant_name
//        }
//        guard let merchantIdentifier = self.epgApplePayRequest?.merchantIdentifier, merchantIdentifier.removingWhitespaces().count > 0 else {
//            return EPGConstant.shared.validate_merchant_name
//        }
//        guard let transactionId = self.epgApplePayRequest?.transactionId, transactionId.removingWhitespaces().count > 0 else {
//            return EPGConstant.shared.validate_trans_id
//        }
//        guard let sessionId = self.epgApplePayRequest?.sessionId, sessionId.removingWhitespaces().count > 0 else {
//            return EPGConstant.shared.validate_auth_token
//        }
//        guard let customerName = self.epgApplePayRequest?.customerName, customerName.removingWhitespaces().count > 0 else {
//            return EPGConstant.shared.validate_customer_name
//        }
//        guard let _ = self.epgApplePayRequest?.amount else {
//            return EPGConstant.shared.validate_amount
//        }
//        return nil
//    }
    
//    private func setupSDK(with controller: UIViewController) {
//        epgRootController = controller
//        LocalizationSystem.shared.refreshLanguageStatus()
//        IQKeyboardManager.shared.enable = true
//        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
//    }
//    
//    private func mapAllData() {
//        if let request = self.epgRequest {
//            EPGPayment.shared.epgRequest            = request
//            EPGPayment.shared.delegate              = request.delegate
//            EPGPayment.shared.merchantUserName      = request.merchantUserName
//            EPGPayment.shared.transactionId         = request.transactionId
//            EPGPayment.shared.authenticationToken   = request.authenticationToken
//            EPGPayment.shared.customerName          = request.customerName
//            EPGPayment.shared.callBackURL           = request.callBackURL
//            EPGPayment.shared.amountToPayText       = request.amountToPayText ?? "Amount to Pay"
//            EPGPayment.shared.showVat               = request.showVat
//            EPGPayment.shared.addressIP             = Internet.shared.getIPAddress()
//            EPGPayment.shared.theme                 = request.theme
//            APIConstant.shared.baseURL              = request.baseURL
//        } else if let request = self.epgApplePayRequest {
//            EPGPayment.shared.epgApplePayRequest    = request
//            EPGPayment.shared.delegate              = request.delegate
//            EPGPayment.shared.merchantUserName      = request.merchantUserName
//            EPGPayment.shared.merchantIdentifier    = request.merchantIdentifier
//            EPGPayment.shared.authenticationToken    = request.sessionId
//            EPGPayment.shared.transactionId         = request.transactionId
//            EPGPayment.shared.customerName          = request.customerName
//            EPGPayment.shared.addressIP             = Internet.shared.getIPAddress()
//            EPGPayment.shared.amount                = "\(request.amount)"
//            APIConstant.shared.baseURL              = request.baseURL
//        }
//    }
    
//    private func startPayment() {
//        self.mapAllData()
//        guard let bundle = EPGHelper.bundle else {
//            return
//        }
//        let vc = PaymentDetailVC(nibName: "PaymentDetailVC", bundle: bundle)
//        vc.delegate = EPGPayment.shared.delegate
//        epgRootController?.navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    private func startApplePay() {
//        self.mapAllData()
//        self.delegate = EPGPayment.shared.delegate
//        let amount = EPGPayment.shared.amount.getDecimalNumber()
//        EPGApplePay.shared.initiateApplePay(viewController: epgRootController!, amount: amount, completion: { isSuccess, message in
//            if let delegate = self.delegate {
//                if EPGPayment.shared.isPrintMsgEnabled {
//                    print("Final Completion: \(delegate), Message: \(message), Success: \(isSuccess)")
//                }
//            }
//            self.delegate?.epgPayment(delegate: EPGResult.get(with: message, isSuccess: isSuccess))
//            epgRootController?.navigationController?.popViewController(animated: false)
//        })
//    }
}

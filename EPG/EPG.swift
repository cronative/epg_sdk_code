//
//  EPGPayment.swift
//  EPG
//
//  Created by Mohd Arsad on 17/08/22.
//

import Foundation
import UIKit

public protocol EPGDelegate: AnyObject {
    func epgPayment(delegate result: EPGResult?)
}

var epgRootController: UIViewController?
internal var selectedTheme: Theme = .auto

public class EPGPayment: NSObject {
   
    public static let shared = EPGPayment()
    public var delegate: EPGDelegate?
    public var theme: Theme = .auto {
        didSet {
            selectedTheme = self.theme
        }
    }
    public var isApplePaySupported: Bool {
        return EPGApplePay.applePayStatus().canMakePayments
    }
    
    internal let isPrintMsgEnabled = false
    internal var merchantUserName: String?
    internal var transactionId: String?
    internal var authenticationToken: String?
    internal var password: String?
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
    internal var epgApplePayRequest: EPGPaymentApplePayRequest?
    /// Populated from GetEmvco3DS2AcsDetail response — used by EMVco's createTransaction(),
    /// never hardcoded in UI code.
    internal var directoryServerID: String?
    internal var acsThreeDSVersion: String?
    /// Wallet-specific SessionID for Apple Pay's WalletCreateSession — kept separate
    /// from authenticationToken, mirroring Android's WalletCreateSession which sends
    /// SessionID and AuthenticationToken as two distinct fields.
    internal var walletSessionID: String?
    
    public var epgRequest: EPGPaymentRequest?
    
    public init(controller: UIViewController) {
        super.init()
        self.setupSDK(with: controller)
    }
    
    public override init() {
    }
    
    public func initiatePayment(with request: EPGPaymentRequest) {
        self.epgRequest = request
        self.startPayment()
    }
    
    public func initiatePaymentApplePay(with request: EPGPaymentApplePayRequest) {
        self.epgApplePayRequest = request
        self.startApplePay()
    }
}

//MARK: - Private & Internal Functions
extension EPGPayment {
    internal func validate() -> String? {
        guard let merchantName = self.epgRequest?.merchantUserName, merchantName.removingWhitespaces().count > 0 else {
            return EPGConstant.shared.validate_merchant_name
        }
        guard let transactionId = self.epgRequest?.transactionId, transactionId.removingWhitespaces().count > 0 else {
            return EPGConstant.shared.validate_trans_id
        }
        guard let authToken = self.epgRequest?.authenticationToken, authToken.removingWhitespaces().count > 0 else {
            return EPGConstant.shared.validate_auth_token
        }
        guard let customerName = self.epgRequest?.customerName, customerName.removingWhitespaces().count > 0 else {
            return EPGConstant.shared.validate_customer_name
        }
        guard let callBack = self.epgRequest?.callBackURL, callBack.removingWhitespaces().count > 0 else {
            return EPGConstant.shared.validate_callback_url
        }
        return nil
    }
    
    internal func validateApplePay() -> String? {
        guard let merchantName = self.epgApplePayRequest?.merchantUserName, merchantName.removingWhitespaces().count > 0 else {
            return EPGConstant.shared.validate_merchant_name
        }
        guard let merchantIdentifier = self.epgApplePayRequest?.merchantIdentifier, merchantIdentifier.removingWhitespaces().count > 0 else {
            return EPGConstant.shared.validate_merchant_name
        }
        guard let transactionId = self.epgApplePayRequest?.transactionId, transactionId.removingWhitespaces().count > 0 else {
            return EPGConstant.shared.validate_trans_id
        }
        guard let sessionId = self.epgApplePayRequest?.sessionId, sessionId.removingWhitespaces().count > 0 else {
            return EPGConstant.shared.validate_session_id
        }
        guard let authToken = self.epgApplePayRequest?.authenticationToken, authToken.removingWhitespaces().count > 0 else {
            return EPGConstant.shared.validate_auth_token
        }
        guard let customerName = self.epgApplePayRequest?.customerName, customerName.removingWhitespaces().count > 0 else {
            return EPGConstant.shared.validate_customer_name
        }
        guard let _ = self.epgApplePayRequest?.amount else {
            return EPGConstant.shared.validate_amount
        }
        return nil
    }
    
    private func setupSDK(with controller: UIViewController) {
        epgRootController = controller
        LocalizationSystem.shared.refreshLanguageStatus()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    private func mapAllData() {
        if let request = self.epgRequest {
            EPGPayment.shared.epgRequest            = request
            EPGPayment.shared.delegate              = request.delegate
            EPGPayment.shared.merchantUserName      = request.merchantUserName
            EPGPayment.shared.transactionId         = request.transactionId
            EPGPayment.shared.authenticationToken   = request.authenticationToken
            EPGPayment.shared.customerName          = request.customerName
            EPGPayment.shared.password              = request.password
            EPGPayment.shared.directoryServerID     = request.directoryServerID
            EPGPayment.shared.callBackURL           = request.callBackURL
            EPGPayment.shared.amountToPayText       = request.amountToPayText ?? "Amount to Pay"
            EPGPayment.shared.showVat               = request.showVat
            EPGPayment.shared.addressIP             = Internet.shared.getIPAddress()
            EPGPayment.shared.theme                 = request.theme
            APIConstant.shared.baseURL              = request.baseURL

            // ============================================================
            // 🔍 [EPG-DEBUG] mapAllData — request values
            // ============================================================
            print("🔍 [EPG-DEBUG] ===== mapAllData =====")
            print("   ➤ merchantUserName   : \(request.merchantUserName)")
            print("   ➤ transactionId      : \(request.transactionId)")
            print("   ➤ customerName       : \(request.customerName)")
            print("   ➤ directoryServerID  : \(request.directoryServerID ?? "nil")")
            print("   ➤ baseURL            : \(request.baseURL)")
            print("   ➤ callBackURL        : \(request.callBackURL)")
            print("🔍 [EPG-DEBUG] ============================")
            // ============================================================

        } else if let request = self.epgApplePayRequest {
            EPGPayment.shared.epgApplePayRequest    = request
            EPGPayment.shared.delegate              = request.delegate
            EPGPayment.shared.merchantUserName      = request.merchantUserName
            EPGPayment.shared.merchantIdentifier    = request.merchantIdentifier
            // SessionID and AuthenticationToken are two distinct fields in the
            // WalletCreateSession request — never collapse them into one.
            EPGPayment.shared.walletSessionID       = request.sessionId
            EPGPayment.shared.authenticationToken   = request.authenticationToken
            EPGPayment.shared.transactionId         = request.transactionId
            EPGPayment.shared.customerName          = request.customerName
            EPGPayment.shared.password              = request.password
            EPGPayment.shared.addressIP             = Internet.shared.getIPAddress()
            EPGPayment.shared.amount                = "\(request.amount)"
            APIConstant.shared.baseURL              = request.baseURL

            EPGLogger.debug("===== mapAllData (Apple Pay) =====")
            EPGLogger.debug("  merchantUserName   : \(request.merchantUserName)")
            EPGLogger.debug("  transactionId      : \(request.transactionId)")
            EPGLogger.debug("  walletSessionID    : \(request.sessionId)")
            EPGLogger.debug("  authenticationToken: \(request.authenticationToken)")
        }
    }
    
    private func startPayment() {
        self.mapAllData()

        print("🔍 [EPG-DEBUG] startPayment called — pushing PaymentDetailVC")

        guard let bundle = EPGHelper.bundle else {
            print("❌ [EPG-DEBUG] EPGHelper.bundle is nil — cannot push PaymentDetailVC")
            return
        }
        let vc = PaymentDetailVC(nibName: "PaymentDetailVC", bundle: bundle)
        vc.delegate = EPGPayment.shared.delegate
        epgRootController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func startApplePay() {
        self.mapAllData()
        self.delegate = EPGPayment.shared.delegate
        let amount = EPGPayment.shared.amount.getDecimalNumber()
        EPGApplePay.shared.initiateApplePay(viewController: epgRootController!, amount: amount, completion: { isSuccess, message in
            if let delegate = self.delegate {
                if EPGPayment.shared.isPrintMsgEnabled {
                    print("Final Completion: \(delegate), Message: \(message), Success: \(isSuccess)")
                }
            }
            self.delegate?.epgPayment(delegate: EPGResult.get(with: message, isSuccess: isSuccess))
            epgRootController?.navigationController?.popViewController(animated: false)
        })
    }
}

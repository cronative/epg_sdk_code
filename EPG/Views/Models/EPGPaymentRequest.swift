//
//  EPGPaymentRequest.swift
//  EPG
//
//  Created by Mohd Arsad on 08/11/22.
//

import Foundation
import UIKit

public final class EPGPaymentRequest: NSObject {
    public var delegate: EPGDelegate?
    public var merchantUserName: String
    public var transactionId: String
    public var authenticationToken: String
    public var customerName: String
    public var callBackURL: String
    public var amountToPayText: String?
    public var showVat: Bool = true
    /// Merchant password — used in GetEmvco3DS2AcsDetail API call. Merchant-supplied, never hardcoded.
    public var password: String?
    /// EMVCo 3DS directory server identifier for the merchant's card scheme.
    /// Merchant-supplied so it is never hardcoded inside the SDK.
    public var directoryServerID: String?
    public var theme: Theme = .auto {
        didSet {
            selectedTheme = self.theme
        }
    }
    public var baseURL: String
    
    public init(
        delegate: EPGDelegate? = nil,
        merchantUserName: String,
        transactionId: String,
        authenticationToken: String,
        customerName: String,
        callBackURL: String,
        amountToPayText: String? = nil,
        showVat: Bool = true,
        theme: Theme = .auto,
        baseURL: String,
        password: String? = nil,
        directoryServerID: String? = nil
    ) {
        self.delegate = delegate
        self.merchantUserName = merchantUserName
        self.transactionId = transactionId
        self.authenticationToken = authenticationToken
        self.customerName = customerName
        self.callBackURL = callBackURL
        self.amountToPayText = amountToPayText
        self.showVat = showVat
        self.theme = theme
        self.baseURL = baseURL
        self.password = password
        self.directoryServerID = directoryServerID
    }
}


public final class EPGPaymentApplePayRequest: NSObject {
    
    public var delegate: EPGDelegate?
    public var merchantUserName: String
    public var merchantIdentifier: String
    public var sessionId: String
    /// AuthenticationToken — required by the WalletCreateSession API.
    /// Mirrors Android's WalletCreateSession.authenticationToken (separate from sessionId).
    public var authenticationToken: String
    public var transactionId: String
    public var customerName: String
    public var amount: NSDecimalNumber = 0.0
    public var baseURL: String
    /// Merchant password — used in WalletCreateSession. Merchant-supplied, never hardcoded.
    public var password: String?
    
    public init(
        delegate: EPGDelegate? = nil,
        merchantUserName: String,
        merchantIdentifier: String,
        sessionId: String,
        authenticationToken: String,
        transactionId: String,
        customerName: String,
        amount: NSDecimalNumber,
        baseURL: String,
        password: String? = nil
    ) {
        self.delegate = delegate
        self.merchantIdentifier = merchantIdentifier
        self.sessionId = sessionId
        self.authenticationToken = authenticationToken
        self.merchantUserName = merchantUserName
        self.transactionId = transactionId
        self.customerName = customerName
        self.amount = amount
        self.baseURL = baseURL
        self.password = password
    }
}

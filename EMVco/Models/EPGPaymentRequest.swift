//
//  EPGPaymentRequest.swift
//  EMVco
//
//  Created by eand ePayment on 12/11/24.
//

import Foundation
import UIKit

public final class EPGPaymentRequest: NSObject {
    public var delegate: EMVcoDelegate?
    public var merchantUserName: String
    public var transactionId: String
    public var authenticationToken: String
    public var customerName: String
    public var callBackURL: String
    public var amountToPayText: String?
    public var showVat: Bool = true
    public var baseURL: String
    
    public init(delegate: EMVcoDelegate? = nil, merchantUserName: String, transactionId: String, authenticationToken: String, customerName: String, callBackURL: String, amountToPayText: String? = nil, showVat: Bool = true, baseURL: String) {
        self.delegate = delegate
        self.merchantUserName = merchantUserName
        self.transactionId = transactionId
        self.authenticationToken = authenticationToken
        self.customerName = customerName
        self.callBackURL = callBackURL
        self.amountToPayText = amountToPayText
        self.showVat = showVat
        self.baseURL = baseURL
    }
}


public final class EPGPaymentApplePayRequest: NSObject {
    
    public var delegate: EMVcoDelegate?
    public var merchantUserName: String
    public var merchantIdentifier: String
    public var sessionId: String
    public var transactionId: String
    public var customerName: String
    public var amount: NSDecimalNumber = 0.0
    public var baseURL: String
    
    public init(delegate: EMVcoDelegate? = nil, merchantUserName: String, merchantIdentifier: String, sessionId: String, transactionId: String, customerName: String, amount: NSDecimalNumber, baseURL: String) {
        self.delegate = delegate
        self.merchantIdentifier = merchantIdentifier
        self.sessionId = sessionId
        self.merchantUserName = merchantUserName
        self.transactionId = transactionId
        self.customerName = customerName
        self.amount = amount
        self.baseURL = baseURL
    }
}


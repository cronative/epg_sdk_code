//
//  aReqRequest.swift
//  FrameWork-V2
//
//  Created by eand ePayment on 05/11/24.
//
import Foundation

struct MobilePhone: Codable {
    let cc: String
    let subscriber: String
}

struct MessageExtension: Codable {
    let name: String
    let id: String
    let criticalityIndicator: Bool
    let data: Data
}
class ThreeDSRequest: Codable {
    var messageType: String
    var messageVersion: String
    var messageCategory: String
    var deviceChannel: String
    var threeDSCompInd: String
    var threeDSRequestorID: String
    var threeDSServerRefNumber: String
    var threeDSServerTransID: String
    var threeDSServerURL: String
    var challengeWindowSize: String
    var oobContinue: Bool
    var whiteListStatusSource: String
    var sdkMaxTimeout: String
    var threeDSRequestorName: String
    var threeDSRequestorURL: String
    var browserAcceptHeader: String
    var browserJavascriptEnabled: Bool
    var browserLanguage: String
    var browserUserAgent: String
    var acctNumber: String
    var notificationURL: String
    var threeDSRequestorAuthenticationInd: String
    var addrMatch: String
    var billAddrCity: String
    var email: String
    var purchaseDate: String
    var shipAddrCity: String
    var billAddrLine1: String
    var purchaseAmount: String
    var shipAddrCountry: String
    var browserTZ: String
    var mobilePhone: MobilePhone
    var billAddrPostCode: String
    var homePhone: MobilePhone
    var shipAddrPostCode: String
    var billAddrState: String
    var workPhone: MobilePhone
    var cardholderName: String
    var browserScreenHeight: String
    var merchantName: String
    var browserJavaEnabled: Bool
    var mcc: String
    var purchaseCurrency: String
    var cardExpiryDate: String
    var acquirerBIN: String
    var purchaseExponent: String
    var browserColorDepth: String
    var billAddrCountry: String
    var threeDSServerOperatorID: String
    var shipAddrLine1: String
    var browserScreenWidth: String
    var acquirerMerchantID: String
    var shipAddrState: String
    var merchantCountryCode: String
    var messageExtension: [MessageExtension]

    // Initializer
    init(messageType: String, messageVersion: String, messageCategory: String, deviceChannel: String, threeDSCompInd: String, threeDSRequestorID: String, threeDSServerRefNumber: String, threeDSServerTransID: String, threeDSServerURL: String, challengeWindowSize: String, oobContinue: Bool, whiteListStatusSource: String, sdkMaxTimeout: String, threeDSRequestorName: String, threeDSRequestorURL: String, browserAcceptHeader: String, browserJavascriptEnabled: Bool, browserLanguage: String, browserUserAgent: String, acctNumber: String, notificationURL: String, threeDSRequestorAuthenticationInd: String, addrMatch: String, billAddrCity: String, email: String, purchaseDate: String, shipAddrCity: String, billAddrLine1: String, purchaseAmount: String, shipAddrCountry: String, browserTZ: String, mobilePhone: MobilePhone, billAddrPostCode: String, homePhone: MobilePhone, shipAddrPostCode: String, billAddrState: String, workPhone: MobilePhone, cardholderName: String, browserScreenHeight: String, merchantName: String, browserJavaEnabled: Bool, mcc: String, purchaseCurrency: String, cardExpiryDate: String, acquirerBIN: String, purchaseExponent: String, browserColorDepth: String, billAddrCountry: String, threeDSServerOperatorID: String, shipAddrLine1: String, browserScreenWidth: String, acquirerMerchantID: String, shipAddrState: String, merchantCountryCode: String, messageExtension: [MessageExtension]) {
        self.messageType = messageType
        self.messageVersion = messageVersion
        self.messageCategory = messageCategory
        self.deviceChannel = deviceChannel
        self.threeDSCompInd = threeDSCompInd
        self.threeDSRequestorID = threeDSRequestorID
        self.threeDSServerRefNumber = threeDSServerRefNumber
        self.threeDSServerTransID = threeDSServerTransID
        self.threeDSServerURL = threeDSServerURL
        self.challengeWindowSize = challengeWindowSize
        self.oobContinue = oobContinue
        self.whiteListStatusSource = whiteListStatusSource
        self.sdkMaxTimeout = sdkMaxTimeout
        self.threeDSRequestorName = threeDSRequestorName
        self.threeDSRequestorURL = threeDSRequestorURL
        self.browserAcceptHeader = browserAcceptHeader
        self.browserJavascriptEnabled = browserJavascriptEnabled
        self.browserLanguage = browserLanguage
        self.browserUserAgent = browserUserAgent
        self.acctNumber = acctNumber
        self.notificationURL = notificationURL
        self.threeDSRequestorAuthenticationInd = threeDSRequestorAuthenticationInd
        self.addrMatch = addrMatch
        self.billAddrCity = billAddrCity
        self.email = email
        self.purchaseDate = purchaseDate
        self.shipAddrCity = shipAddrCity
        self.billAddrLine1 = billAddrLine1
        self.purchaseAmount = purchaseAmount
        self.shipAddrCountry = shipAddrCountry
        self.browserTZ = browserTZ
        self.mobilePhone = mobilePhone
        self.billAddrPostCode = billAddrPostCode
        self.homePhone = homePhone
        self.shipAddrPostCode = shipAddrPostCode
        self.billAddrState = billAddrState
        self.workPhone = workPhone
        self.cardholderName = cardholderName
        self.browserScreenHeight = browserScreenHeight
        self.merchantName = merchantName
        self.browserJavaEnabled = browserJavaEnabled
        self.mcc = mcc
        self.purchaseCurrency = purchaseCurrency
        self.cardExpiryDate = cardExpiryDate
        self.acquirerBIN = acquirerBIN
        self.purchaseExponent = purchaseExponent
        self.browserColorDepth = browserColorDepth
        self.billAddrCountry = billAddrCountry
        self.threeDSServerOperatorID = threeDSServerOperatorID
        self.shipAddrLine1 = shipAddrLine1
        self.browserScreenWidth = browserScreenWidth
        self.acquirerMerchantID = acquirerMerchantID
        self.shipAddrState = shipAddrState
        self.merchantCountryCode = merchantCountryCode
        self.messageExtension = messageExtension
    }
}

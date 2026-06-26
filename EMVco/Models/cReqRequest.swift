//
//  cReqRequest.swift
//  FrameWork-V2
//
//  Created by eand ePayment on 05/11/24.
//

import Foundation

struct CReqRequest: Codable {
    // Conditional
    let threeDSRequestorAppURL: String?
    
    // Required
    let threeDSServerTransID: String?
    let acsTransID: String?
    
    // Conditional
    let challengeAddCode: String?
    let challengeCancel: String?
    let challengeDataEntry: String?
    let challengeDataEntryTwo: String?
    let challengeHTMLDataEntry: String?
    let challengeNoEntry: String?
    
    // Required
    let challengeWindowSize: String?
    
    // Conditional
    let deviceBindingDataEntry: String?
    let infoContinueIndicator: String?
    let messageExtension: String?
    
    // Required
    let messageType: String?
    let messageVersion: String?
    
    // Conditional
    let oobAppStatus: String?
    let oobAppURLInd: String?
    let oobContinue: String?
    let resendChallenge: String?
    
    // Required
    let sdkCounterStoA: String?
    let sdkTransID: String?
    
    // Conditional
    let trustListDataEntry: String?
    
    // Coding keys to map the JSON keys to Swift properties
    private enum CodingKeys: String, CodingKey {
        case threeDSRequestorAppURL
        case threeDSServerTransID
        case acsTransID
        case challengeAddCode
        case challengeCancel
        case challengeDataEntry
        case challengeDataEntryTwo
        case challengeHTMLDataEntry
        case challengeNoEntry
        case challengeWindowSize
        case deviceBindingDataEntry
        case infoContinueIndicator
        case messageExtension
        case messageType
        case messageVersion
        case oobAppStatus
        case oobAppURLInd
        case oobContinue
        case resendChallenge
        case sdkCounterStoA
        case sdkTransID
        case trustListDataEntry
    }
}

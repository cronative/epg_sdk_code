//
//  ChallengeParameters.swift
//  FrameWork-V2
//
//  Created by eand ePayment on 09/11/24.
//

struct ChallengeParameters {
    let transactionID: String            // 3DS Server Transaction ID
    let acsTransactionID: String         // ACS Transaction ID
    let acsReferenceNumber: String       // ACS Reference Number
    let acsSignedContent: String        // ACS Signed Content
    let threeDSRequestorAppURL: String   // Three DS Requestor App URL
}

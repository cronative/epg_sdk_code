//
//  Transaction.swift
//  FrameWork-V2
//
//  Created by eand ePayment on 09/11/24.
//

import Foundation

// Custom error types
enum SDKRuntimeException: Error {
    case generalError(String)
}

enum InvalidInputException: Error {
    case invalidInput(String)
}

protocol Transaction {
    // Method to return authentication request parameters
    func getAuthenticationRequestParameters() throws -> AuthenticationRequestParameters?
//    func getPreAuthenticateParams(cardInfo: [String: Any]) -> [String: Any] {
//        var params: [String: Any] = cardInfo
//        params["UserName"] = EPGPayment.shared.merchantUserName
//        params["Customer"] = EPGPayment.shared.customerName
//        params["Instrument"] = "C"
//        params["TransactionID"] = EPGPayment.shared.transactionId
//        params["AuthenticationToken"] = EPGPayment.shared.authenticationToken
//        params["Client"] = RestAPI.shared.getAgentParams()
//        return params
//    }
//    
//    func getPreAuthenticationData(cardParams: [String: Any], completion: @escaping(_ response: PreAuthenticateResponse?) -> ()) {
//        ActivityIndicator.showActivity()
//        RestAPI.shared.preAuthenticate(params: ["PreAuthenticateInApp": getPreAuthenticateParams(cardInfo: cardParams)]) { response in
//            DispatchQueue.main.async {
//                ActivityIndicator.hideActivity()
//                completion(response)
//            }
//        }
//    }
    
    // Method to initiate the challenge process
    func doChallenge(
       
        challengeParameters: ChallengeParameters,
        challengeStatusReceiver: ChallengeStatusReceiver,
        timeOut: Int
    ) throws
    
    // Method to return progress view (processing screen)
    func getProgressView() throws -> ProgressDialog?
    
    // Method to clean up resources held by the Transaction object
    func close()
}

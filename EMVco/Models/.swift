

//
//  AuthenticationRequestParameters.swift
//  FrameWork-V2
//
//  Created by eand ePayment on 05/11/24.
//

import Foundation

struct AuthenticationRequestParameters: Codable {
    let sdkAppId: String
    let sdkEphemeralPublicKey: String
    let sdkReferenceNumber: String
    let sdkTransId: String
    let messageVersion: String
    let deviceData: String
}

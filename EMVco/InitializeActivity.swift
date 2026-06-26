//
//  InitializeActivity.swift
//  FrameWork-V2
//
//  Created by eand ePayment on 09/11/24.
//

import Foundation
import UIKit

// Define custom exceptions to mirror those in Kotlin
enum SDKError: Error {
    case invalidInput(String)
    case alreadyInitialized(String)
    case notInitialized(String)
    case runtimeError(String)
}

public class AuthenticationRequestParameters: Codable {
    public let sdkAppId: String
    public let sdkEphemeralPublicKey: String
    public let sdkReferenceNumber: String
    public let sdkTransId: String
    public let messageVersion: String
    public let deviceData: String

    public init(sdkAppId: String,
                sdkEphemeralPublicKey: String,
                sdkReferenceNumber: String,
                sdkTransId: String,
                messageVersion: String,
                deviceData: String) {
        self.sdkAppId = sdkAppId
        self.sdkEphemeralPublicKey = sdkEphemeralPublicKey
        self.sdkReferenceNumber = sdkReferenceNumber
        self.sdkTransId = sdkTransId
        self.messageVersion = messageVersion
        self.deviceData = deviceData
    }
}

//class GetPreAuthenticateParamsOne {
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
//}
class InitializeActivity {
    var SUPPORTED_PROTOCOL_VERSION = ""
    private var isSDKInitialized = false
    private var configParameters: ConfigParameters? = nil
    
    func initialize(
        configParameters: ConfigParameters?,
        locale: String?,
        uiCustomization: UiCustomization?
    ) throws {
        
        // Check if SDK is already initialized
        guard !isSDKAlreadyInitialized() else {
            throw SDKError.alreadyInitialized("SDK is already initialized.")
        }
        
        // Validate configParameters
        guard let configParameters = configParameters, !configParameters.isEmpty else {
            throw SDKError.invalidInput("Config parameters cannot be empty.")
        }
        let selectedLocale = locale?.isEmpty == false ? locale! : Locale.current.identifier
        
        do {
            self.configParameters = configParameters
            let uiConfig: UiCustomization

            do {
                if let existingCustomization = uiCustomization {
                    uiConfig = existingCustomization.applyDefault()
                } else {
                    uiConfig = try UiCustomization.create()
                }
            } catch {
                // Handle the error appropriately here
                fatalError("Failed to create UiCustomization: \(error)")
            }
            
            // Insert SDK initialization code here using `configParameters`, `selectedLocale`, and `uiConfig`
            
            isSDKInitialized = true
        } catch {
            throw SDKError.runtimeError("Failed to initialize SDK: \(error.localizedDescription)")
        }
    }
    
    private func isSDKAlreadyInitialized() -> Bool {
        return isSDKInitialized
    }
    
    func createTransaction(directoryServerID: String?, messageVersion: String?) throws -> Transaction {
        
        // Check if SDK is initialized
        guard isSDKAlreadyInitialized() else {
            throw SDKError.notInitialized("SDK is not initialized.")
        }
        
        // Validate directoryServerID
        guard let directoryServerID = directoryServerID, directoryServerID.count == 5 else {
            throw SDKError.invalidInput("Invalid Directory Server ID. It must be a 5-character string.")
        }
        let protocolVersion: String
        // Validate messageVersion or use the highest supported version if not provided
        if let messageVersion = messageVersion {
               protocolVersion = messageVersion
           } else if let maxVersion = SUPPORTED_PROTOCOL_VERSION.max() {
               protocolVersion = String(maxVersion)
           } else {
               throw SDKError.runtimeError("No protocol versions are supported.")
           }
       
        

        do {
            let transactionId = UUID().uuidString
            let keyPairGenerator = try KeyPairGenerator()
            let ephemeralKeyPair = try keyPairGenerator.generateKeyPair()
            
            let encryptedDeviceData = try getDeviceDataJson(transactionId: transactionId, configParameters: configParameters)
            
            let authenticationRequest = AuthenticationRequestParameters(
                sdkAppId: getOrCreateSDKAppID(),
                sdkEphemeralPublicKey: ephemeralKeyPair.publicKey,
                sdkReferenceNumber: configParameters?.sdkReferenceNumber ?? "",
                sdkTransId: transactionId,
                messageVersion: protocolVersion,
                deviceData: encryptedDeviceData
            )
            
            return TransactionImpl(authenticationRequestParameters: authenticationRequest)
               
        } catch {
            throw SDKError.runtimeError("Failed to create transaction: \(error.localizedDescription)")
        }
    }
    
    func cleanup() throws {
        guard isSDKAlreadyInitialized() else {
            throw SDKError.notInitialized("SDK is not initialized.")
        }
        
        do {
            // Perform cleanup, such as clearing caches or resetting config parameters
            configParameters?.clear()
            configParameters = nil
            Warning.clearWarnings()
            
            isSDKInitialized = false
        } catch {
            throw SDKError.runtimeError("Failed to cleanup SDK: \(error.localizedDescription)")
        }
    }
    
    func getSDKVersion() throws -> String {
        guard isSDKAlreadyInitialized() else {
            throw SDKError.notInitialized("SDK is not initialized.")
        }
        
        return "3DS SDK Version 2.2.0"  // Replace with actual version
    }
    
    func getWarnings() throws -> [Warning] {
        guard isSDKAlreadyInitialized() else {
            throw SDKError.notInitialized("SDK is not initialized.")
        }
        
        return Warning.getWarnings()
    }
}

// Supporting functions for generating key pairs, device data, and obtaining SDK App ID
class KeyPairGenerator {
    func generateKeyPair() throws -> (publicKey: String, privateKey: String) {
        // Generate key pair logic
        return ("PublicKeyExample", "PrivateKeyExample")
    }
}

func getDeviceDataJson(transactionId: String, configParameters: ConfigParameters?) throws -> String {
    // Placeholder for actual device data retrieval logic
    return "{}"
}

func getOrCreateSDKAppID() -> String {
    // Placeholder for actual SDK App ID retrieval or generation logic
    return UUID().uuidString
}

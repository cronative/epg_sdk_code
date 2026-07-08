//
//  ThreeDS2ServiceImplementation.swift
//  EPG-Demo
//
//  Created by eand ePayment on 04/10/24.
//

import Foundation

// Custom Exception Types
enum SDKInitializationError: Error {
    case alreadyInitialized
    case invalidInput(String)
    case runtimeError(String)
    case notInitialized
}
enum SdkError: Error {
    case sdkNotInitialized
}

// Transaction Struct
class ThreeDSTransaction {
    var transactionId: String
    var directoryServerID: String
    var messageVersion: String?
    
    init(id: String, directoryServerID: String, messageVersion: String?) {
        self.transactionId = id
        self.directoryServerID = directoryServerID
        self.messageVersion = messageVersion
    }
}

// Conforming to the ThreeDS2Service protocol
class ThreeDS2ServiceImplementation: ThreeDS2Service {
    
    private var isInitialized = false
    private var sdkWarnings: [Warning] = []
    
    // 1. initialize method
    func initialize(applicationContext: Any, configParameters: ConfigParameters, locale: String?, uiCustomization: UiCustomization?) throws {
        if isInitialized {
            throw SDKInitializationError.alreadyInitialized
        }
        
        // Retrieve a specific parameter from configParameters
        guard let configValue = try configParameters.getParamValue(paramName: "someConfigValue"), !configValue.isEmpty else {
            throw SDKInitializationError.invalidInput("configParameters is invalid.")
        }
        
        // Perform necessary security checks and device information collection here
        performSecurityChecks()
        collectDeviceInformation()
        
        // Logging initialization details
        print("Initializing SDK with config: \(configValue)")
        
        if let locale = locale {
            print("Locale: \(locale)")
        } else {
            print("Using default locale.")
        }
        
        do {
            if let uiCustomization = uiCustomization {
                let buttonCustomization = try uiCustomization.getButtonCustomization(for: .submit)
                print("UI Customization: Button Title = \(buttonCustomization.title), Button Color = \(buttonCustomization.color), Font Style = \(buttonCustomization.fontStyle), Font Size = \(buttonCustomization.fontSize)")
            }
            isInitialized = true
            print("SDK initialized successfully.")
        } catch {
            // Handle the error if getButtonCustomization throws
            print("Error: \(error)")
        }
    }
    
    // 2. createTransaction method
    func createTransaction(directoryServerID: String, messageVersion: String?) throws -> ThreeDSTransaction {
        if !isInitialized {
            throw SDKInitializationError.notInitialized
        }
        
        guard !directoryServerID.isEmpty else {
            throw SDKInitializationError.invalidInput("Directory Server ID is invalid.")
        }
        
        // Generating a transaction ID
        let transactionId = UUID().uuidString
        
        // Creating a transaction object with optional messageVersion
        let transaction = ThreeDSTransaction(id: transactionId, directoryServerID: directoryServerID, messageVersion: messageVersion)
        
        // Log the creation of a new transaction
        print("Transaction created with ID: \(transactionId) for DS: \(directoryServerID)")
        
        return transaction
    }
    
    // 3. cleanup method
    func cleanup() {
        if isInitialized {
            print("Cleaning up SDK resources.")
            // Perform cleanup operations here, like releasing resources.
            isInitialized = false
        } else {
            print("SDK was not initialized, no cleanup needed.")
        }
    }
    
    // 4. getSDKVersion method
    func getSDKVersion() -> String {
        guard isInitialized else {
            return "SDK not initialized"
        }
        
        return "1.0.0"  // Replace with actual SDK version
    }
    
    // 5. getWarnings method
    func getWarnings() throws -> [String] {
        // Throw an error if the SDK is not initialized
        guard isInitialized else {
            throw SdkError.sdkNotInitialized
        }
        
        // Convert the warnings to a list of messages and return them
        return sdkWarnings.map { $0.getMessage() }
    }
    
    // Helper Functions
    func performSecurityChecks() {
        // Implement security checks required during SDK initialization
        print("Performing security checks...")
    }
    
    func collectDeviceInformation() {
        // Implement device information collection for the 3DS protocol
        print("Collecting device information...")
    }
}

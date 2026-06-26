//
//  Transaction.swift
//  EPG-Framw
//
//  Created by eand ePayment on 17/10/24.
//

import Foundation
import UIKit

public class EntryPoints {
    
    // Store reference to InitializeActivity
    private var initializeActivity = InitializeActivity()
    
    // Initializer with a view controller owner
    public init(owner: UIViewController) {
        print("EntryPoints initialized with owner: \(owner)")
    }

    // Initialize method
    public func initialize(configParameters: ConfigParameters?, locale: String, uiCustomization: UiCustomization?) {
        do {
            try initializeActivity.initialize(configParameters: configParameters, locale: locale, uiCustomization: uiCustomization)
        } catch let error as SDKError {
            print("SDK initialization failed: \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }

    // Create a transaction
    func createTransaction(directoryServerID: String?, messageVersion: String?) -> Transaction? {
        do {
            return try initializeActivity.createTransaction(directoryServerID: directoryServerID, messageVersion: messageVersion)
        } catch let error as SDKError {
            print("Transaction creation failed: \(error)")
            return nil
        } catch {
            print("Unexpected error: \(error)")
            return nil
        }
    }

    // Cleanup method
    public func cleanup() {
        do {
            try initializeActivity.cleanup()
        } catch let error as SDKError {
            print("Cleanup failed: \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }

    // Get SDK version
    public func getSDKVersion() -> String {
        do {
            return try initializeActivity.getSDKVersion()
        } catch let error as SDKError {
            print("Failed to retrieve SDK version: \(error)")
            return "Unknown"
        } catch {
            print("Unexpected error: \(error)")
            return "Unknown"
        }
    }

    // Get warnings
  func getWarnings() -> [Warning] {
        do {
            return try initializeActivity.getWarnings()
        } catch let error as SDKError {
            print("Failed to retrieve warnings: \(error)")
            return []
        } catch {
            print("Unexpected error: \(error)")
            return []
        }
    }
}

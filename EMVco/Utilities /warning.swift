//
//  Untitled.swift
//  FrameWork-V2
//
//  Created by eand ePayment on 31/10/24.
//

import Foundation
import UIKit

class Warning {
    private let id: String
    private let message: String
    private let severity: Severity

    // Enum to represent severity levels
    enum Severity {
        case low, medium, high
    }

    // Static list to store all warnings
    private static var warningList = [Warning]()

    init(id: String, message: String, severity: Severity) {
        self.id = id
        self.message = message
        self.severity = severity
    }

    // Method to add a warning to the list
    static func addWarning(_ warning: Warning) {
        warningList.append(warning)
    }

    // Method to retrieve the list of all warnings
    static func getWarnings() -> [Warning] {
        return warningList
    }

    // Method to clear the warning list
    static func clearWarnings() {
        warningList.removeAll()
    }

    // Methods to return the warning details
    func getID() -> String {
        return id
    }

    func getMessage() -> String {
        return message
    }

    func getSeverity() -> Severity {
        return severity
    }
}

class SdkSecurityManager {
    // Perform all initialization security checks
    func performSecurityChecks() -> [Warning] {
        var warnings = [Warning]()

        if isDeviceJailbroken() {
            warnings.append(Warning(id: "SW01", message: "The device is jailbroken.", severity: .high))
        }

        if !isSdkIntegrityIntact() {
            warnings.append(Warning(id: "SW02", message: "The integrity of the SDK has been tampered.", severity: .high))
        }

        if isRunningOnEmulator() {
            warnings.append(Warning(id: "SW03", message: "An emulator is being used to run the App.", severity: .high))
        }

        if isDebuggerAttached() {
            warnings.append(Warning(id: "SW04", message: "A debugger is attached to the App.", severity: .medium))
        }

        if !isOsVersionSupported() {
            warnings.append(Warning(id: "SW05", message: "The OS or the OS version is not supported.", severity: .high))
        }

        return warnings
    }

    // Security Check 1: Check if the device is jailbroken/rooted
    private func isDeviceJailbroken() -> Bool {
        // Check for known jailbreak files and paths
        return FileManager.default.fileExists(atPath: "/Applications/Cydia.app") ||
               FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
    }

    // Security Check 2: Check SDK integrity
    private func isSdkIntegrityIntact() -> Bool {
        return !hasUnwantedPackages() && !hasTamperingIndicators() // Placeholder for actual integrity logic
    }

    // Security Check 3: Check if running on an emulator
    private func isRunningOnEmulator() -> Bool {
        return TARGET_OS_SIMULATOR != 0
    }

    // Security Check 4: Check if a debugger is attached
    private func isDebuggerAttached() -> Bool {
        return isatty(1) != 0
    }

    // Security Check 5: Check if the OS version is supported
    private func isOsVersionSupported() -> Bool {
        let minSupportedVersion: Double = 12.0
        let maxSupportedVersion: Double = 17.0
        let currentVersion = Double(UIDevice.current.systemVersion) ?? 0.0
        return currentVersion >= minSupportedVersion && currentVersion <= maxSupportedVersion
    }

    private func hasUnwantedPackages() -> Bool {
        // Since there's no direct iOS equivalent for checking installed packages like in Android, use alternative methods as necessary
        return false // Placeholder
    }

    private func hasTamperingIndicators() -> Bool {
        // Check build properties and app debuggable status
        return Bundle.main.infoDictionary?["SignerIdentity"] != nil || isatty(1) != 0
    }
}

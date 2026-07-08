//
//  warning.swift
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

    enum Severity {
        case low, medium, high
    }

    private static var warningList = [Warning]()

    init(id: String, message: String, severity: Severity) {
        self.id       = id
        self.message  = message
        self.severity = severity
    }

    static func addWarning(_ warning: Warning) {
        warningList.append(warning)
    }

    static func getWarnings() -> [Warning] {
        return warningList
    }

    static func clearWarnings() {
        warningList.removeAll()
    }

    func getID() -> String      { return id }
    func getMessage() -> String { return message }
    func getSeverity() -> Severity { return severity }
}

class SdkSecurityManager {

    func performSecurityChecks() -> [Warning] {
        var warnings = [Warning]()

        if isDeviceJailbroken() {
            warnings.append(Warning(id: "SW01", message: "The device is jailbroken.", severity: .high))
        }
        if !isSdkIntegrityIntact() {
            warnings.append(Warning(id: "SW02", message: "The integrity of the SDK has been tampered.", severity: .high))
        }
        if isRunningOnSimulator() {
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

    private func isDeviceJailbroken() -> Bool {
        return FileManager.default.fileExists(atPath: "/Applications/Cydia.app") ||
               FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
    }

    private func isSdkIntegrityIntact() -> Bool {
        return !hasUnwantedPackages() && !hasTamperingIndicators()
    }

    // Fixed: TARGET_OS_SIMULATOR is a C macro — use ProcessInfo instead
    private func isRunningOnSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    private func isDebuggerAttached() -> Bool {
        return isatty(1) != 0
    }

    private func isOsVersionSupported() -> Bool {
        let minSupportedVersion: Double = 12.0
        let maxSupportedVersion: Double = 18.0
        let currentVersion = Double(UIDevice.current.systemVersion) ?? 0.0
        return currentVersion >= minSupportedVersion && currentVersion <= maxSupportedVersion
    }

    private func hasUnwantedPackages() -> Bool {
        return false
    }

    private func hasTamperingIndicators() -> Bool {
        return Bundle.main.infoDictionary?["SignerIdentity"] != nil || isatty(1) != 0
    }
}

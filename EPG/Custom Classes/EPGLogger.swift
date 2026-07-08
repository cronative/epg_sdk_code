//
//  EPGLogger.swift
//  EPG
//
//  Created by Nikunj Munjiyasara on 29/06/26.
//

import Foundation
import os.log

struct EPGLogger {
    
    private static let subsystem = "com.epg.sdk"
    
    private static let recurrenceLog = OSLog(subsystem: subsystem, category: "RECURRENCE")
    private static let debugLog      = OSLog(subsystem: subsystem, category: "DEBUG")
    private static let networkLog    = OSLog(subsystem: subsystem, category: "NETWORK")

    static func recurrence(_ message: String) {
        os_log("🔁 %{public}@", log: recurrenceLog, type: .default, message)
        print("🔁 [EPG] \(message)")
    }

    static func debug(_ message: String) {
        os_log("🔍 %{public}@", log: debugLog, type: .default, message)
        print("🔍 [EPG] \(message)")
    }

    static func network(_ message: String) {
        os_log("🌐 %{public}@", log: networkLog, type: .default, message)
        print("🌐 [EPG] \(message)")
    }

    static func error(_ message: String) {
        os_log("❌ %{public}@", log: debugLog, type: .error, message)
        print("❌ [EPG] \(message)")
    }
    
    static func warning(_ message: String) {
        os_log("⚠️ %{public}@", log: debugLog, type: .fault, message)
        print("⚠️ [EPG] \(message)")
    }
}

//
//  ThreeDS2Service.swift
//  EPG-Demo
//
//  Created by eand ePayment on 04/10/24.
//

import Foundation

// Define a protocol for ThreeDS2Service
protocol ThreeDS2Service {
    func initialize(applicationContext: Any, configParameters: ConfigParameters, locale: String?, uiCustomization: UiCustomization?) throws
    func createTransaction(directoryServerID: String, messageVersion: String?) throws -> ThreeDSTransaction
    func cleanup()
    func getSDKVersion() -> String
    func getWarnings() throws-> [String]
}

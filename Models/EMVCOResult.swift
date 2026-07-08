////
////  EPGResult.swift
////  EMVco
////
////  Created by eand ePayment on 12/11/24.
////
//
//import Foundation
//import UIKit
//
//public final class EMVcoResult: NSObject {
//    
//    public let errorMessage: String?
//    public let success: Bool
//    public let transactionId: String
//    public let cancelledbyUser: Bool
//    
//    public init(errorMessage: String?, success: Bool, transactionId: String, cancelledbyUser: Bool = false) {
//        self.errorMessage = errorMessage
//        self.success = success
//        self.transactionId = transactionId
//        self.cancelledbyUser = cancelledbyUser
//    }
//    
//    public static func get(with errorMessage: String?, isSuccess: Bool) -> EMVcoResult {
//        return EMVcoResult(errorMessage: errorMessage, success: isSuccess, transactionId: EMVcoPayment.shared.transactionId ?? "")
//    }
//}

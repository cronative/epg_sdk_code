//
//  EPGResult.swift
//  EPG
//
//  Created by Mohd Arsad on 08/11/22.
//

import Foundation
import UIKit

public final class EPGResult: NSObject {
    
    public let errorMessage: String?
    public let success: Bool
    public let transactionId: String
    public let cancelledbyUser: Bool
    
    public init(errorMessage: String?, success: Bool, transactionId: String, cancelledbyUser: Bool = false) {
        self.errorMessage = errorMessage
        self.success = success
        self.transactionId = transactionId
        self.cancelledbyUser = cancelledbyUser
    }
    
    public static func get(with errorMessage: String?, isSuccess: Bool) -> EPGResult {
        return EPGResult(errorMessage: errorMessage, success: isSuccess, transactionId: EPGPayment.shared.transactionId ?? "")
    }
}

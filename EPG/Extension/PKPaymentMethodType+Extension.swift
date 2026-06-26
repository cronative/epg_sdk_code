//
//  PKPaymentMethodType+Extension.swift
//  EPG
//
//  Created by Mohd Arsad on 06/03/2023.
//

import Foundation
import PassKit

extension PKPaymentMethodType {
    var title: String {
        switch self {
        case .unknown:
            return "unknown"
        case .debit:
            return "debit"
        case .credit:
            return "credit"
        case .prepaid:
            return "prepaid"
        case .store:
            return "store"
        case .eMoney:
            return "eMoney"
        @unknown default:
            return "unknown"
        }
    }
}

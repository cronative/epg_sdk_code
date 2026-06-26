//
//  Array+Extension.swift
//  EPG
//
//  Created by Mohd Arsad on 25/10/22.
//

import Foundation
import UIKit

extension Array {
    func chunks(size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

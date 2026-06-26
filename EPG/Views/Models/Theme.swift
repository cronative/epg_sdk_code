//
//  Theme.swift
//  EPG
//
//  Created by Mohd Arsad on 08/11/22.
//

import Foundation
import UIKit

//MARK: - Public
public enum Theme: Int {
    case theme1 // = "Theme1" //With Corner
    case theme2 // = "Theme2"
    case auto // = "Auto"
}

extension Theme: Hashable {

    public func hash(into hasher: inout Hasher) {

        switch self {
        case .theme1:
            break
        case .theme2:
            break
        case .auto:
            break
        }
    }
}

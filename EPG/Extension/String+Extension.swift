//
//  String+Extension.swift
//  EPG-Demo
//
//  Created by Mohd Arsad on 16/08/22.
//

import Foundation
import UIKit

extension String {
    func chunks(size: Int) -> [String] {
        map { $0 }.chunks(size: size).compactMap { String($0) }
    }
    
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    func getDecimalNumber() -> NSDecimalNumber {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        return formatter.number(from: self) as? NSDecimalNumber ?? 0
    }
    
    func formattedCardNumber() -> String {
        let numbersOnlyEquivalent = replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: nil)
        return numbersOnlyEquivalent.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    /// Remove characters from given set from the string. Looks for characters
    /// from set in the whole string, not only its beginning and end.
    ///
    /// - Parameter set: Character set, with characters we want to remove
    /// - Returns: New String with characters from given set removed
    func removingCharactersInSet(_ set: CharacterSet) -> String {
        let stringParts = self.components(separatedBy: set)
        let notEmptyStringParts = stringParts.filter { text in
            text.isEmpty == false
        }
        let result = notEmptyStringParts.joined(separator: "")
        return result
    }
    
    
    /// Remove whitespace and newlines characters from the string. Looks for
    /// characters from set in the whole string, not only its beginning and end.
    ///
    /// - Returns: New String with whitespace and newline characters removed
    func removingWhitespaceAndNewlines() -> String {
        return self.removingCharactersInSet(CharacterSet.whitespacesAndNewlines)
    }
}

extension String {
    var toDictionary: [String: Any]? {
        let data = Data(self.utf8)
        do {
            // make sure this JSON is in the format we expect
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return json
            }
            return nil
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            return nil
        }
    }
}

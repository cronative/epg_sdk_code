//
//  CardValidator.swift
//  EPG-Demo
//
//  Created by Mohd Arsad on 15/08/22.
//

import Foundation
import UIKit

class Validator {
    
    static let shared = Validator()
    
    enum Card: String {
        case amex = "AMEX"
        case visa = "Visa"
        case masterCard = "MasterCard"
        case unknown = "Unknown"
    }
    
    func checkCardNumber(paymentMethod: PaymentDataResponse.Instrument, cardNumber: String) -> (type: CreditCardType, formatted: String, valid: Bool, brand: PaymentDataResponse.Brand?) {
        
        let brands = paymentMethod.Brands?.Brand ?? []
        
        // Get only numbers from the input string
        let numberOnly = cardNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        var valid = false
        let type = CCValidator.typeCheckingPrefixOnly(creditCardNumber: numberOnly)
    
        for brand in brands {
            let cardRegex = brand.Validation ?? ""
            if self.matchesRegex(regex: cardRegex, text: numberOnly) && self.isLuhnValid(ccNumber: numberOnly) {
                valid = true
                break
            }
        }
        let formatted = self.getFormatterNumber(cardNumber: numberOnly)
        let brand = paymentMethod.Brands?.Brand?.filter({ $0.Name == type.rawValue }).first
        
        // return the tuple
        return (type, formatted, valid, brand)
    }
    
    func checkCVV(type: CreditCardType, brand: PaymentDataResponse.Brand, cvv: String) -> (formatted: String, valid: Bool) {
        
        // Get only numbers from the input string
        let numberOnly = cvv.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var valid = false
        
        var cardRegex = brand.VerifyInfo ?? ""
        if type == .AmericanExpress {
            cardRegex = "SCC|[0-9]{4}"
        }
        let isValid = self.matchesRegex(regex: cardRegex, text: numberOnly)
        if isValid {
            valid = true
        }
        
        // return the tuple
        return (numberOnly, valid)
    }
    
    
    private func matchesRegex(regex: String, text: String) -> Bool {
        let emailRegEx = regex
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: text)
    }
    
    private func getFormatterNumber(cardNumber: String) -> String {
        var formatted = ""
        var formatted4 = ""
        for character in cardNumber {
            if formatted4.count == 4 {
                formatted += formatted4 + " "
                formatted4 = ""
            }
            formatted4.append(character)
        }
        formatted += formatted4 // the rest
        return formatted
    }
    
    private func isLuhnValid(ccNumber: String) -> Bool {
        var sum = 0
        var alternate = false
        for i in (0...(ccNumber.count - 1)).reversed() {
            var n = NSString(string: ccNumber[i]).integerValue
            if (alternate) {
                n *= 2
                if (n > 9) {
                    n = n % 10 + 1
                }
            }
            sum += n
            alternate = !alternate
        }
        return sum % 10 == 0
    }
}

/*
 func checkCVV(paymentMethod: PaymentDataResponse.Instrument, cvv: String) -> (type: Validator.Card, formatted: String, valid: Bool, brand: PaymentDataResponse.Brand?) {
     
     let brands = paymentMethod.Brands?.Brand ?? []
     
     // Get only numbers from the input string
     let numberOnly = cvv.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
     
     var type: Validator.Card = .unknown
     var valid = false
     
     for brand in brands {
         let cardRegex = brand.VerifyInfo ?? ""
         let isValid = self.matchesRegex(regex: cardRegex, text: numberOnly)
         if isValid {
             valid = true
             type = Validator.Card(rawValue: brand.Name ?? "") ?? .unknown
             break
         }
     }
     let brand = paymentMethod.Brands?.Brand?.filter({ $0.Name == type.rawValue }).first
     
     // return the tuple
     return (type, numberOnly, valid, brand)
 }
 */

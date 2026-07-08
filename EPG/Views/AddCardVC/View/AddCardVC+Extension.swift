//
//  AddCardVC+Extension.swift
//  EPG
//
//  Created by Mohd Arsad on 08/11/22.
//

import Foundation
import UIKit

//MARK: - UITextFieldDelegate Initialization & Card Entry Validation


extension AddCardVC: UITextFieldDelegate {
    
    @objc func onTextFieldChange(_ textField: UITextField) {
//        self.checkValidation(textField: textField)
        if textField == self.expiryTF {
            self.cardSKValidLbl.text = self.expiryTF.text ?? ""
            self.expiryDateStatusLbl.isHidden = true
        } else if textField == self.cvvTF {
            let cvv = self.cvvTF.text ?? ""
            
            var xStr: String = ""
            for _ in 0..<cvv.count { xStr += "*" }
            self.cardSKCVVLbl.text = xStr
            self.cvvStatusLbl.isHidden = true
        } else if textField == self.cardNoTF {
            let count = self.cardNoTF.text?.count ?? 0
            if count == 19 {
                self.cardSKCardNoLbl.text = self.cardNoTF.text ?? ""
            }else {
                let totalVal = (self.cardNoTF.text ?? "").replacingOccurrences(of: " ", with: "")
                
                let finalStr = totalVal
                let chunks = finalStr.chunks(size: 4)
                self.cardSKCardNoLbl.text = chunks.joined(separator: " ")
            }
            self.cardNoValidateStatusLbl.isHidden = true
            self.checkCardType()
            // Recurrence flow — skip card validation API call entirely.
            // Card number field is hidden; server already has the saved card on file.
            if !self.isRecurrencePayment {
                if checkValidationOnCardChange(textField: self.cardNoTF) {
                    self.addCardViewModel.validateCardData(cardNumber: self.cardNoTF.text ?? "") { response in
                        let responseDescription = String(describing: response)
                        EPGLogger.debug("Response of validateCardData === \(responseDescription)")
                        
                        guard let response = response else {
                            EPGHelper.showAlert(controller: self, message: EPGConstant.shared.authentication_failed) { isComplete in
                                if isComplete { self.dismiss(animated: true) }
                            }
                            return
                        }
                        self.isSDKEnabled = response.transaction?.isSDKEnabled ?? false
                        // Check if the SDK is enabled (isSDKEnabled is true) based on the response
                       
                        
                        // Proceed with other response checks
                        if response.transaction?.responseCode == "0" {
                            self.ConfirmButtonVisibilityUpdate(isButtonVisible: true)
                        } else {
                            self.ConfirmButtonVisibilityUpdate(isButtonVisible: false)
                        }
                    }
                }
            }
        }
     
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }
        let updatedText = oldText.replacingCharacters(in: r, with: string)

        if textField == self.expiryTF {
            if string == "" {
                if updatedText.count == 2 {
                    textField.text = "\(updatedText.prefix(1))"
                    return false
                }
            } else if updatedText.count == 1 {
                if updatedText > "1" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.expiryTF.text = "0\(updatedText)/"
                    })
                }
            } else if updatedText.count == 2 {
                if updatedText <= "12" {
                    textField.text = "\(updatedText)/"
                }
                return false
            } else if updatedText.count > 5 {
                return false
            }
            self.cardSKValidLbl.text = textField.text ?? ""
        } else if textField == self.cvvTF {
            return updatedText.count <= 4
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.cardNoIconIV.tintColor = .lightGray
        self.expiryIV.tintColor = .lightGray
        self.cvvIV.tintColor = .lightGray
        if textField == self.cardNoTF {
            self.cardNoIconIV.tintColor = .label
        } else if textField == self.expiryTF {
            self.expiryIV.tintColor = .label
        } else {
            self.cvvIV.tintColor = .label
        }
        
        if textField == self.cvvTF {
            if self.showingFront {
                self.flipCardView(isShowFront: false)
            }
        } else {
            if !self.showingFront {
                self.flipCardView(isShowFront: true)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        self.checkValidation(textField: textField, isEnd: true)
        if textField == self.cvvTF {
            if !self.showingFront {
                self.flipCardView(isShowFront: true)
            }
        }
        
        self.cardNoIconIV.tintColor = .lightGray
        self.expiryIV.tintColor = .lightGray
        self.cvvIV.tintColor = .lightGray
    }
}

//MARK: - All Validation Methods
extension AddCardVC {
    /// Check All Entry Validation
    /// - Parameters:
    ///   - textField: current active textfield
    ///   - isEnd: function work at endEditing
//    func checkValidation(textField: UITextField, isEnd: Bool = false) {
//        if textField == self.cardNoTF {
//            self.cardNoValidateStatusLbl.isHidden = true
//            if var number = textField.text, number.count > 0 {
//                number = number.replacingOccurrences(of: " ", with: "")
//
//                let validData = Validator.shared.checkCardNumber(paymentMethod: self.paymentMethod!, cardNumber: number)
//                var isValid = validData.valid
//                if isValid && number.count < 15 {
//                    isValid = false
//                }
//                let type = validData.type
//                if type == .NotRecognized || !isValid {
//                    self.cardNoValidateStatusLbl.isHidden = false
//                }
//
//                var cvvnumber = self.cvvTF.text ?? ""
//                cvvnumber = cvvnumber.replacingOccurrences(of: " ", with: "")
//                if cvvnumber.count > 0, let brand = validData.brand {
//                    let validDataCVV = Validator.shared.checkCVV(type: validData.type, brand: brand, cvv: cvvnumber)
//                    let isValid = validDataCVV.valid
//                    if cvvnumber.count == 0 || isValid {
//                        self.cvvStatusLbl.isHidden = true
//                    } else {
//                        self.cvvStatusLbl.text = "CVC not valid"
//                        self.cvvStatusLbl.isHidden = false
//                    }
//                } else {
//                    self.cvvStatusLbl.isHidden = true
//                }
//
//                //Update the card image by entered card type
//                self.cardNoTypeIV.isHidden = false
//                self.cardSKTypeIV.isHidden = false
//
//                switch validData.type {
//                case .NotRecognized:
//                    self.cardNoTypeIV.isHidden = true
//                    self.cardSKTypeIV.isHidden = true
//                    break
//                case .AmericanExpress:
//                    self.cardNoTypeIV.image = UIImage(named: "amex1", in: EPGHelper.bundle, with: nil)
//                    self.cardSKTypeIV.image = UIImage(named: "amex2", in: EPGHelper.bundle, with: nil)
//                    break
//                case .Visa:
//                    self.cardNoTypeIV.image = UIImage(named: "visa1", in: EPGHelper.bundle, with: nil)
//                    self.cardSKTypeIV.image = UIImage(named: "visa2", in: EPGHelper.bundle, with: nil)
//                    break
//                case .MasterCard:
//                    self.cardNoTypeIV.image = UIImage(named: "master1", in: EPGHelper.bundle, with: nil)
//                    self.cardSKTypeIV.image = UIImage(named: "master2", in: EPGHelper.bundle, with: nil)
//                    break
//                default:
//                    self.cardNoTypeIV.isHidden = true
//                    self.cardSKTypeIV.isHidden = true
//                    break
//                }
//            }
//        } else if textField == self.expiryTF {
//            let text = self.expiryTF.text ?? ""
//            if text.count == 5 {
//                let isValid = self.addCardViewModel.expDateValidation(dateStr: text)
//                self.expiryDateStatusLbl.isHidden = isValid
//            } else {
//                if text.count == 0 {
//                    self.expiryDateStatusLbl.isHidden = true
//                } else {
//                    self.expiryDateStatusLbl.isHidden = isEnd ? false : true
//                }
//            }
//            self.expiryCvvSeperateLbl.isHidden = (self.expiryDateStatusLbl.isHidden && self.cvvStatusLbl.isHidden)
//        } else if textField == self.cvvTF {
//            let text = self.cvvTF.text ?? ""
//
//            var number = self.cardNoTF.text ?? ""
//            number = number.replacingOccurrences(of: " ", with: "")
//
//            let validDataNo = Validator.shared.checkCardNumber(paymentMethod: self.paymentMethod!, cardNumber: number)
//            if validDataNo.valid, let brand = validDataNo.brand {
//                let validData = Validator.shared.checkCVV(type: validDataNo.type, brand: brand, cvv: text)
//                let isValid = validData.valid
//                if text.count == 0 || isValid {
//                    self.cvvStatusLbl.isHidden = true
//                } else {
//                    self.cvvStatusLbl.text = "CVC not valid"
//                    self.cvvStatusLbl.isHidden = false
//                }
//            }
//            self.expiryCvvSeperateLbl.isHidden = (self.expiryDateStatusLbl.isHidden && self.cvvStatusLbl.isHidden)
//        }
//        self.payButtonVisibilityUpdate()
//    }
    
    func checkValidation(textField: UITextField, isEnd: Bool = false) {
        
        if textField == self.cardNoTF {
            var number = textField.text ?? ""
            number = number.replacingOccurrences(of: " ", with: "")
            if number.count > 0 {
                
                let validData = Validator.shared.checkCardNumber(paymentMethod: self.paymentMethod!, cardNumber: number)
                var isValid = validData.valid
                if isValid && number.count < 15 {
                    isValid = false
                }
                if validData.type == .NotRecognized || !isValid {
                    self.cardNoValidateStatusLbl.isHidden = false
                    self.cardNoValidateStatusLbl.text = "card_no_invalid".localize
                } else {
                    self.cardNoValidateStatusLbl.isHidden = true
                }
                
                self.cvvValidation()
            } else {
                self.cardNoValidateStatusLbl.text = "enter_card_number".localize
                self.cardNoValidateStatusLbl.isHidden = false
            }
        } else if textField == self.expiryTF {
            let text = self.expiryTF.text ?? ""
            if text.count == 5 {
                self.expiryDateStatusLbl.text = "expiry_invalid".localize
                let isValid = self.addCardViewModel.expDateValidation(dateStr: text)
                self.expiryDateStatusLbl.isHidden = isValid
            } else if text.count == 0 {
                self.expiryDateStatusLbl.text = "enter_expiry".localize
                self.expiryDateStatusLbl.isHidden = false
            } else {
                self.expiryDateStatusLbl.text = "expiry_invalid".localize
                self.expiryDateStatusLbl.isHidden = false
            }
            self.expiryCvvSeperateLbl.isHidden = (self.expiryDateStatusLbl.isHidden && self.cvvStatusLbl.isHidden)
        } else if textField == self.cvvTF {
            self.cvvValidation()
        }
        self.payButtonVisibilityUpdate()
    }
    func checkValidationOnCardChange(textField: UITextField, isEnd: Bool = false) -> Bool {
        
        if textField == self.cardNoTF {
            var number = textField.text ?? ""
            number = number.replacingOccurrences(of: " ", with: "")
            
            if number.count > 0 {
                let validData = Validator.shared.checkCardNumber(paymentMethod: self.paymentMethod!, cardNumber: number)
                var isValid = validData.valid
                
                if isValid && number.count < 15 {
                    isValid = false
                }
                
                if validData.type == .NotRecognized || !isValid {
                    self.cardNoValidateStatusLbl.isHidden = false
                    self.cardNoValidateStatusLbl.text = "card_no_invalid".localize
                } else {
                    self.cardNoValidateStatusLbl.isHidden = true
                }
                
                return isValid
            } else {
                self.cardNoValidateStatusLbl.text = "enter_card_number".localize
                self.cardNoValidateStatusLbl.isHidden = false
                return false
            }
        }
        
        return false // Return false if textField is not cardNoTF
    }

    
    func cvvValidation() {
        let text = self.cvvTF.text ?? ""
        var number = self.cardNoTF.text ?? ""
        number = number.replacingOccurrences(of: " ", with: "")
        
        let validDataNo = Validator.shared.checkCardNumber(paymentMethod: self.paymentMethod!, cardNumber: number)
        var isCardNoValid = validDataNo.valid
        if isCardNoValid && number.count < 15 {
            isCardNoValid = false
        }
        if validDataNo.type == .NotRecognized || !isCardNoValid {
            isCardNoValid = false
        } else {
            self.cardNoValidateStatusLbl.isHidden = true
        }
        
        
        if isCardNoValid, let brand = validDataNo.brand {
            let validData = Validator.shared.checkCVV(type: validDataNo.type, brand: brand, cvv: text)
            let isValid = validData.valid
            if isValid {
                self.cvvStatusLbl.isHidden = true
            } else if text.count == 0 {
                self.cvvStatusLbl.isHidden = false
                self.cvvStatusLbl.text = "enter_cvv_number".localize
            } else {
                self.cvvStatusLbl.text = "cvv_invalid".localize
                self.cvvStatusLbl.isHidden = false
            }
        } else if text.count == 0 {
            self.cvvStatusLbl.isHidden = false
            self.cvvStatusLbl.text = "enter_cvv_number".localize
        } else if text.count > 2 {
            self.cvvStatusLbl.isHidden = true
        } else {
            self.cvvStatusLbl.text = "cvv_invalid".localize
            self.cvvStatusLbl.isHidden = false
        }
        self.expiryCvvSeperateLbl.isHidden = (self.expiryDateStatusLbl.isHidden && self.cvvStatusLbl.isHidden)
    }
    
    func checkCardType() {
        var number = self.cardNoTF.text ?? ""
        number = number.replacingOccurrences(of: " ", with: "")
        
        guard number.count > 0 else {
            return
        }
        let validData = Validator.shared.checkCardNumber(paymentMethod: self.paymentMethod!, cardNumber: number)
        
        //Update the card image by entered card type
        self.cardNoTypeIV.isHidden = false
        self.cardSKTypeIV.isHidden = false
        
        switch validData.type {
        case .NotRecognized:
            self.cardNoTypeIV.isHidden = true
            self.cardSKTypeIV.isHidden = true
            break
        case .AmericanExpress:
            self.cardNoTypeIV.image = UIImage(named: "amex1", in: EPGHelper.bundle, with: nil)
            self.cardSKTypeIV.image = UIImage(named: "amex2", in: EPGHelper.bundle, with: nil)
            break
        case .Visa:
            self.cardNoTypeIV.image = UIImage(named: "visa1", in: EPGHelper.bundle, with: nil)
            self.cardSKTypeIV.image = UIImage(named: "visa2", in: EPGHelper.bundle, with: nil)
            break
        case .MasterCard:
            self.cardNoTypeIV.image = UIImage(named: "master1", in: EPGHelper.bundle, with: nil)
            self.cardSKTypeIV.image = UIImage(named: "master2", in: EPGHelper.bundle, with: nil)
            break
        default:
            self.cardNoTypeIV.isHidden = true
            self.cardSKTypeIV.isHidden = true
            break
        }
    }
    /// Enable visibility and active for payment confirm button
    func payButtonVisibilityUpdate() {
//       var isValid = (self.cardNoValidateStatusLbl.isHidden == true) && (self.expiryDateStatusLbl.isHidden == true) && (self.cvvStatusLbl.isHidden == true)
//        if self.cardNoTF.text?.count == 0 || self.expiryTF.text?.count == 0 || self.cvvTF.text?.count == 0 {
//            isValid = false
//        }
//        if isValid {
            self.confirmBtn.alpha = 1.0
            self.confirmBtn.isUserInteractionEnabled = true
//        } else {
//            self.confirmBtn.alpha = 0.6
//            self.confirmBtn.isUserInteractionEnabled = false
//        }
    }
    func ConfirmButtonVisibilityUpdate(isButtonVisible: Bool) {

        if isButtonVisible {
            self.confirmBtn.alpha = 1.0
            self.confirmBtn.isUserInteractionEnabled = true
        } else {
            self.confirmBtn.alpha = 0.6
            self.confirmBtn.isUserInteractionEnabled = false
        }
    }
    
}

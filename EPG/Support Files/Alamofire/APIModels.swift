//
//  APIModels.swift
//  EPG-Demo
//
//  Created by Mohd Arsad on 24/10/22.
//

import Foundation

// MARK: - WalletType

enum WalletType: String {
    case mWallet    = "mWallet"
    case eWallet    = "eWallet"
    case samsungPay = "Samsung Pay"
    case tabby      = "Tabby"
    case smiles     = "Smiles"
    case payIT      = "PAYIT"
    case applePay   = "Apple Pay"
    case postPay    = "PostPay"
    case blueWallet = "Blue Wallet"
    case bluePrepaid = "Blue Prepaid"
    case binance    = "Binance"
    case knet       = "KNET"
    case spotii     = "Spotii"
    case dcb        = "DCB"
    case googlePay  = "GooglePay"
    case tamara     = "Tamara"
    case none       = ""
}

// MARK: - PaymentDataResponse
// All nested structs use manual init(data: [String: Any]) — NOT Decodable.
// This matches the original pattern and avoids conflicts with EMVco's Transaction type.

struct PaymentDataResponse {

    struct Amount {
        let Printable: String?
        let Value: String?
        init(data: [String: Any]) {
            self.Printable = data["Printable"] as? String
            self.Value     = data["Value"] as? String
        }
    }

    struct Brand {
        let AuthTypes: String?
        let ExpiryDate: String?
        let Fees: Amount?
        let Name: String?
        let ShowInfo: String?
        let Text: String?
        let Total: Amount?
        let Validation: String?
        let VerifyInfo: String?
        init(data: [String: Any]) {
            self.AuthTypes  = data["AuthTypes"] as? String
            self.ExpiryDate = data["ExpiryDate"] as? String
            self.Fees       = Amount(data: data["Fees"] as? [String: Any] ?? [:])
            self.Name       = data["Name"] as? String
            self.ShowInfo   = data["ShowInfo"] as? String
            self.Text       = data["Text"] as? String
            self.Total      = Amount(data: data["Total"] as? [String: Any] ?? [:])
            self.Validation = data["Validation"] as? String
            self.VerifyInfo = data["VerifyInfo"] as? String
        }
    }

    struct BrandObject {
        let Brand: [Brand]?
        init(data: [String: Any]) {
            var brands: [Brand] = []
            if let arr = data["Brand"] as? [[String: Any]] {
                brands = arr.map { PaymentDataResponse.Brand(data: $0) }
            } else if let obj = data["Brand"] as? [String: Any] {
                brands = [PaymentDataResponse.Brand(data: obj)]
            }
            self.Brand = brands
        }
    }

    struct Instrument {
        let Name: String?
        let Symbol: String?
        let Text: String?
        let Brands: BrandObject?
        var isSelected: Bool?
        var imageName: String?

        init(data: [String: Any]) {
            self.Name      = data["Name"] as? String
            self.Symbol    = data["Symbol"] as? String
            self.Text      = data["Text"] as? String
            self.Brands    = BrandObject(data: data["Brands"] as? [String: Any] ?? [:])
            self.imageName = ""
            self.isSelected = false
        }

        init(name: String, symbol: String, text: String, brand: PaymentDataResponse.BrandObject?, imageName: String?) {
            self.Name      = name
            self.Symbol    = symbol
            self.Text      = text
            self.Brands    = brand
            self.imageName = imageName
            self.isSelected = false
        }
    }

    struct InstrumentObject {
        let Instrument: [Instrument]?
        init(data: [String: Any]) {
            if let obj = data["Instrument"] as? [String: Any] {
                self.Instrument = [PaymentDataResponse.Instrument(data: obj)]
            } else {
                let arr = data["Instrument"] as? [[String: Any]] ?? []
                self.Instrument = arr.map { PaymentDataResponse.Instrument(data: $0) }
            }
        }
    }

    struct Wallet {
        var walletType: WalletType = .none
        var jsonString: String?
        init(name: String, json: String) {
            self.walletType = WalletType(rawValue: name) ?? .none
            self.jsonString = json
        }
    }

    struct PaymentWallet {
        var wallets: [Wallet] = []
        init(data: [String: Any]) {
            if let wallet = data["Wallet"] as? [String: Any] {
                let name    = wallet["WalletName"] as? String ?? ""
                let jsonStr = wallet["JSonString"] as? String ?? ""
                self.wallets = [Wallet(name: name, json: jsonStr)]
            } else {
                let array = data["Wallet"] as? [[String: Any]] ?? []
                self.wallets = array.map {
                    Wallet(name: $0["WalletName"] as? String ?? "",
                           json: $0["JSonString"] as? String ?? "")
                }
            }
        }
    }

    struct Merchant {
        let City: String?
        let Country: String?
        let Name: String?
        let Provider: String?
        let Store: String?
        let Terminal: String?
        let Logo: String?
        init(data: [String: Any]) {
            self.City     = data["City"] as? String
            self.Country  = data["Country"] as? String
            self.Name     = data["Name"] as? String
            self.Provider = data["Provider"] as? String
            self.Store    = data["Store"] as? String
            self.Terminal = data["Terminal"] as? String
            self.Logo     = data["Logo"] as? String
        }
    }

    struct TransactionObject {
        let AskAutoPayCardHolderName: String?
        let ReturnPath: String?
        let Amount: Amount?
        let Currency: String?
        let OrderID: String?
        let OrderName: String?
        /// Smiles Points value from server e.g. "500 PTS" — shown in UI only if matches ^\d+ PTS$
        let OrderInfo: String?
        /// Masked saved card shown in recurrence flow e.g. "XXXX-XXXX-XXXX-1234"
        let CardMask: String?

        init(data: [String: Any]) {
            self.AskAutoPayCardHolderName = data["AskAutoPayCardHolderName"] as? String
            self.ReturnPath = data["ReturnPath"] as? String
            self.CardMask   = data["CardMask"] as? String
            self.Amount     = PaymentDataResponse.Amount(data: data["Amount"] as? [String: Any] ?? [:])

            if let currencyObj = data["Currency"] as? [String: Any] {
                self.Currency = currencyObj["Code"] as? String
            } else {
                self.Currency = nil
            }

            if let orderObj = data["Order"] as? [String: Any] {
                self.OrderID   = orderObj["ID"] as? String
                self.OrderName = orderObj["Name"] as? String
                self.OrderInfo = orderObj["Info"] as? String
            } else {
                self.OrderID   = nil
                self.OrderName = nil
                self.OrderInfo = nil
            }
        }
    }

    // MARK: ResponseParameter
    // Mirror of Android: ResponseParameter inside PaymentDataInApp
    struct ResponseParameter {
        let applePayAcceptedCards: String?
        let applePayMerchantID: String?
        let applePayCountyCode: String?
        let applePayMerchantCapabilities: String?
        let threeDsServerTransactionID: String?
        let acsThreeDSVersion: String?
        let acsThreeDSMethodURL: String?
        let isSDKEnable: Bool?
        let isRecurrenceTransaction: [String]?

        init(data: [String: Any]) {
            self.applePayAcceptedCards        = data["ApplePay_AcceptedCards"] as? String
            self.applePayMerchantID           = data["ApplePay_MerchantID"] as? String
            self.applePayCountyCode           = data["ApplePay_CountyCode"] as? String
            self.applePayMerchantCapabilities = data["ApplePay_MerchantCapabilities"] as? String
            self.threeDsServerTransactionID   = data["ThreeDsServerTransactionID"] as? String
            self.acsThreeDSVersion            = data["AcsThreeDSVersion"] as? String
            self.acsThreeDSMethodURL          = data["AcsThreeDSMethodURL"] as? String
            // Server sends IsSDKEnable as a STRING ("True"/"False"), not a JSON Bool.
            if let boolValue = data["IsSDKEnable"] as? Bool {
                self.isSDKEnable = boolValue
            } else if let stringValue = data["IsSDKEnable"] as? String {
                self.isSDKEnable = (stringValue.lowercased() == "true")
            } else {
                self.isSDKEnable = nil
            }

            if let arr = data["IsRecurrenceTransaction"] as? [String] {
                self.isRecurrenceTransaction = arr
            } else if let single = data["IsRecurrenceTransaction"] as? String {
                self.isRecurrenceTransaction = [single]
            } else {
                self.isRecurrenceTransaction = nil
            }
        }
    }

    // MARK: PaymentData
    struct PaymentData {
        let UniqueID: String?
        let ResponseCode: String?
        let ResponseDescription: String?
        let version: String?
        let Merchant: Merchant?
        let Instruments: InstrumentObject?
        let Transaction: TransactionObject?
        let PaymentWallets: PaymentWallet?
        let ResponseParameter: ResponseParameter?
        /// true when server returns IsRecurrenceTransaction = true at top level
        let isRecurrenceTransaction: Bool?

        init(data: [String: Any]) {
            self.UniqueID            = data["UniqueID"] as? String
            self.ResponseCode        = data["ResponseCode"] as? String
            self.ResponseDescription = data["ResponseDescription"] as? String
            self.version             = data["version"] as? String
            self.Merchant      = PaymentDataResponse.Merchant(data: data["Merchant"] as? [String: Any] ?? [:])
            self.Instruments   = InstrumentObject(data: data["Instruments"] as? [String: Any] ?? [:])
            self.Transaction   = TransactionObject(data: data["Transaction"] as? [String: Any] ?? [:])
            self.PaymentWallets = PaymentWallet(data: data["PaymentWallets"] as? [String: Any] ?? [:])

            if let rpData = data["ResponseParameter"] as? [String: Any] {
                self.ResponseParameter = PaymentDataResponse.ResponseParameter(data: rpData)
            } else {
                self.ResponseParameter = nil
            }

            // Server sends IsRecurrenceTransaction as a STRING ("true"/"false"), not a JSON Bool.
            // Handle both forms so this never silently fails to nil.
            if let boolValue = data["IsRecurrenceTransaction"] as? Bool {
                self.isRecurrenceTransaction = boolValue
            } else if let stringValue = data["IsRecurrenceTransaction"] as? String {
                self.isRecurrenceTransaction = (stringValue.lowercased() == "true")
            } else {
                self.isRecurrenceTransaction = nil
            }
        }
    }

    let PaymentDataInApp: PaymentData?
    let transaction: EPGTransaction?

    init(data: [String: Any]) {
        self.PaymentDataInApp = PaymentData(data: data["PaymentDataInApp"] as? [String: Any] ?? [:])
        self.transaction      = EPGTransaction(data: data["Transaction"] as? [String: Any] ?? [:])
    }
}

// MARK: - PreAuthenticateResponse

struct PreAuthenticateResponse {

    struct PreAuthenticate {
        let ResponseCode: String?
        let ResponseDescription: String?
        let UniqueID: String?
        let ChallengeRequired: String?
        let ResponseClass: String?
        let ResponseClassDescription: String?
        let RedirectionURL: String?

        init(data: [String: Any]) {
            self.ResponseCode            = data["ResponseCode"] as? String
            self.ResponseDescription     = data["ResponseDescription"] as? String
            self.UniqueID                = data["UniqueID"] as? String
            self.ChallengeRequired       = data["ChallengeRequired"] as? String
            self.ResponseClass           = data["ResponseClass"] as? String
            self.ResponseClassDescription = data["ResponseClassDescription"] as? String
            self.RedirectionURL          = data["RedirectionURL"] as? String
        }
    }

    let PreAuthenticateInApp: PreAuthenticate?
    let transaction: EPGTransaction?

    init(data: [String: Any]) {
        self.PreAuthenticateInApp = PreAuthenticate(data: data["PreAuthenticateInAppResponse"] as? [String: Any] ?? [:])
        self.transaction          = EPGTransaction(data: data["Transaction"] as? [String: Any] ?? [:])
    }
}

// MARK: - EmvCo3DS2AcsDetailResponse
// Uses JSONDecoder so it stays Decodable

struct EmvCo3DS2AcsDetailResponse: Decodable {
    var transaction: TransactionEmvCo3DS2AcsDetailResponse?

    struct TransactionEmvCo3DS2AcsDetailResponse: Decodable {
        let uniqueID: String?
        let responseCode: String?
        let responseDescription: String?
        let acsThreeDSVersion: String?
        let threeDsServerTransactionID: String?
        let language: String?
        let responseClass: String?
        let responseClassDescription: String?
        var isSDKEnabled: Bool? = true

        enum CodingKeys: String, CodingKey {
            case uniqueID                  = "UniqueID"
            case responseCode              = "ResponseCode"
            case responseDescription       = "ResponseDescription"
            case acsThreeDSVersion         = "AcsThreeDSVersion"
            case threeDsServerTransactionID = "ThreeDsServerTransactionID"
            case language                  = "Language"
            case responseClass             = "ResponseClass"
            case responseClassDescription  = "ResponseClassDescription"
            case isSDKEnabled              = "isSDKEnabled"
        }
    }

    enum CodingKeys: String, CodingKey {
        case transaction = "Transaction"
    }

    init(data: [String: Any]) throws {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        self = try JSONDecoder().decode(EmvCo3DS2AcsDetailResponse.self, from: jsonData)
        self.transaction?.isSDKEnabled = true
    }
}

// MARK: - EPGTransaction
// Renamed from 'Transaction' to avoid conflict with EMVco's Transaction type

struct EPGTransaction {

    struct ResponseParam {
        let name: String?
        let value: String?
        init(data: [String: Any]) {
            self.name  = data["Name"] as? String
            self.value = data["Value"] as? String
        }
    }

    let ResponseCode: String?
    let ResponseClass: String?
    let ResponseDescription: String?
    let ResponseClassDescription: String?
    let UniqueID: String?
    let UserEmail: String?
    let UserType: String?
    let RedirectionRequired: String?
    let RedirectionURL: String?
    let ResponseParameters: [ResponseParam]?
    /// SessionID returned in WalletCreateSession response —
    /// must be passed back in WalletSubmitPayload.
    let SessionID: String?

    init(data: [String: Any]) {
        self.ResponseCode             = data["ResponseCode"] as? String
        self.ResponseDescription      = data["ResponseDescription"] as? String
        self.UniqueID                 = data["UniqueID"] as? String
        self.ResponseClass            = data["ResponseClass"] as? String
        self.ResponseClassDescription = data["ResponseClassDescription"] as? String
        self.UserEmail                = data["UserEmail"] as? String
        self.UserType                 = data["UserType"] as? String
        self.RedirectionRequired      = data["RedirectionRequired"] as? String
        self.RedirectionURL           = data["RedirectionURL"] as? String
        self.SessionID                = data["SessionID"] as? String

        if let obj = data["ResponseParameters"] as? [String: Any],
           let params = obj["Parameters"] as? [[String: Any]] {
            self.ResponseParameters = params.map { ResponseParam(data: $0) }
        } else {
            self.ResponseParameters = nil
        }
    }
}

// MARK: - CancelTransactionResponse

struct CancelTransactionResponse {

    struct CancelTransaction {
        let ResponseCode: String?
        let ResponseDescription: String?
        let UniqueID: String?
        let TransactionID: String?
        let ResponseClass: String?
        let ResponseClassDescription: String?
        let RedirectionURL: String?

        init(data: [String: Any]) {
            self.ResponseCode             = data["ResponseCode"] as? String
            self.ResponseDescription      = data["ResponseDescription"] as? String
            self.UniqueID                 = data["UniqueID"] as? String
            self.TransactionID            = data["TransactionID"] as? String
            self.ResponseClass            = data["ResponseClass"] as? String
            self.ResponseClassDescription = data["ResponseClassDescription"] as? String
            self.RedirectionURL           = data["ReturnURL"] as? String
        }
    }

    let transaction: CancelTransaction?

    init(data: [String: Any]) {
        self.transaction = CancelTransaction(data: data["Transaction"] as? [String: Any] ?? [:])
    }
}

// MARK: - WalletSessionResponse

struct WalletSessionResponse {
    let transaction: EPGTransaction?

    init(data: [String: Any]) {
        self.transaction = EPGTransaction(data: data["Transaction"] as? [String: Any] ?? [:])
    }
}

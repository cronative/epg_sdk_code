//
//  APIModels.swift
//  EPG-Demo
//
//  Created by Mohd Arsad on 24/10/22.
//

import Foundation

enum WalletType: String, Decodable {
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

struct PaymentDataResponse: Decodable {
    
    struct Amount: Decodable {
        let Printable: String?
        let Value: String?
        
        init(data: [String: Any]) {
            self.Printable = data["Printable"] as? String
            self.Value = data["Value"] as? String
        }
    }
    
    struct Brand: Decodable {
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
            self.AuthTypes = data["AuthTypes"] as? String
            self.ExpiryDate = data["ExpiryDate"] as? String
            self.Fees = Amount(data: data["Fees"] as? [String: Any] ?? [:])
            self.Name = data["Name"] as? String
            self.ShowInfo = data["ShowInfo"] as? String
            self.Text = data["Text"] as? String
            self.Total = Amount(data: data["Total"] as? [String: Any] ?? [:])
            self.Validation = data["Validation"] as? String
            self.VerifyInfo = data["VerifyInfo"] as? String
        }
    }
    
    struct BrandObject: Decodable {
        let Brand: [Brand]?
        
        init(data: [String: Any]) {
            var brands: [Brand] = []
            if let brandDataArr = data["Brand"] as? [[String: Any]] {
                for dataObj in brandDataArr {
                    brands.append(PaymentDataResponse.Brand(data: dataObj))
                }
            } else if let brandDataObj = data["Brand"] as? [String: Any] {
                brands.append(PaymentDataResponse.Brand(data: brandDataObj))
            }
            self.Brand = brands
        }
    }
    
    struct Instrument: Decodable {
        let Name: String?
        let Symbol: String?
        let Text: String?
        let Brands: BrandObject?
        var isSelected: Bool?
        var imageName: String?
        
        init(data: [String: Any]) {
            self.Name = data["Name"] as? String
            self.Symbol = data["Symbol"] as? String
            self.Text = data["Text"] as? String
            self.Brands = BrandObject(data: data["Brands"] as? [String: Any] ?? [:])
            self.imageName = ""
            self.isSelected = false
        }
        
        init(name: String, symbol: String, text: String, brand: PaymentDataResponse.BrandObject?, imageName: String?) {
            self.Name = name
            self.Symbol = symbol
            self.Text = text
            self.Brands = brand
            self.imageName = imageName
            self.isSelected = false
        }
    }
    
    struct InstrumentObject: Decodable {
        let Instrument: [Instrument]?
        
        init(data: [String: Any]) {
            if let instrumentsDataObj = data["Instrument"] as? [String: Any] {
                let instrumentsDataArr = data["Instrument"] as? [[String: Any]] ?? []
                let instruments: [Instrument] = [PaymentDataResponse.Instrument(data: instrumentsDataObj)]
                self.Instrument = instruments
            } else {
                let instrumentsDataArr = data["Instrument"] as? [[String: Any]] ?? []
                
                var instruments: [Instrument] = []
                for dataObj in instrumentsDataArr {
                    instruments.append(PaymentDataResponse.Instrument(data: dataObj))
                }
                self.Instrument = instruments
            }
        }
    }
    
    struct Wallet: Decodable {
        var walletType: WalletType = .none
        var jsonString: String?
        
        init(name: String, json: String) {
            self.walletType = WalletType(rawValue: name) ?? .none
            self.jsonString = json
        }
    }
    
    struct PaymentWallet: Decodable {
        var wallets: [Wallet] = []
        
        init(data: [String: Any]) {
            if let wallet = data["Wallet"] as? [String: Any] {
                let jsonStr = wallet["JSonString"] as? String ?? ""
                let name = wallet["WalletName"] as? String ?? ""
                self.wallets = [Wallet(name: name, json: jsonStr)]
            } else {
                let array = data["Wallet"] as? [[String: Any]] ?? []
                
                self.wallets = []
                for object in array {
                    let jsonStr = object["JSonString"] as? String ?? ""
                    let name = object["WalletName"] as? String ?? ""
                    self.wallets.append(Wallet(name: name, json: jsonStr))
                }
            }
        }
    }
    
    struct Merchant: Decodable {
        let City: String?
        let Country: String?
        let Name: String?
        let Provider: String?
        let Store: String?
        let Terminal: String?
        let Logo: String?
        
        init(data: [String: Any]) {
            self.City = data["City"] as? String
            self.Country = data["Country"] as? String
            self.Name = data["Name"] as? String
            self.Provider = data["Provider"] as? String
            self.Store = data["Store"] as? String
            self.Terminal = data["Terminal"] as? String
            self.Logo = data["Logo"] as? String
        }
    }
    
    struct TransactionObject: Decodable {
        let AskAutoPayCardHolderName: String?
        let ReturnPath: String?
        let Amount: Amount?
        let Currency: String?
        let OrderID: String?
        let OrderName: String?
        
        init(data: [String: Any]) {
            self.AskAutoPayCardHolderName = data["AskAutoPayCardHolderName"] as? String
            self.ReturnPath = data["ReturnPath"] as? String
            self.Amount = PaymentDataResponse.Amount(data: data["Amount"] as? [String: Any] ?? [:])
            
            if let currencyObj = data["Currency"] as? [String: Any], let currency = currencyObj["Code"] as? String {
                self.Currency = currency
            } else {
                self.Currency = nil
            }
            
            if let orderObj = data["Order"] as? [String: Any], let orderId = orderObj["ID"] as? String, let orderName = orderObj["Name"] as? String {
                self.OrderID = orderId
                self.OrderName = orderName
            } else {
                self.OrderID = nil
                self.OrderName = nil
            }
        }
    }
    
    struct PaymentData: Decodable {
        let UniqueID: String?
        let ResponseCode: String?
        let ResponseDescription: String?
        let version: String?
        let Merchant: Merchant?
        let Instruments: InstrumentObject?
        let Transaction: TransactionObject?
        let PaymentWallets: PaymentWallet?
        
        init(data: [String: Any]) {
            self.UniqueID = data["UniqueID"] as? String
            self.ResponseCode = data["ResponseCode"] as? String
            self.ResponseDescription = data["ResponseDescription"] as? String
            self.version = data["version"] as? String
            self.Merchant = PaymentDataResponse.Merchant(data: data["Merchant"] as? [String: Any] ?? [:])
            self.Instruments = InstrumentObject(data: data["Instruments"] as? [String: Any] ?? [:])
            self.Transaction = TransactionObject(data: data["Transaction"] as? [String: Any] ?? [:])
            self.PaymentWallets = PaymentWallet(data: data["PaymentWallets"] as? [String: Any] ?? [:])
        }
    }
    
    let PaymentDataInApp: PaymentData?
    let transaction: Transaction?
    
    init(data: [String: Any]) {
        self.PaymentDataInApp = PaymentData(data: data["PaymentDataInApp"] as? [String: Any] ?? [:])
        self.transaction = Transaction(data: data["Transaction"] as? [String: Any] ?? [:])
    }
}

struct PreAuthenticateResponse: Decodable {
    
    struct PreAuthenticate: Decodable {
        let ResponseCode: String?
        let ResponseDescription: String?
        let UniqueID: String?
        let ChallengeRequired: String?
        let ResponseClass: String?
        let ResponseClassDescription: String?
        let RedirectionURL: String?
        
        init(data: [String: Any]) {
            self.ResponseCode = data["ResponseCode"] as? String
            self.ResponseDescription = data["ResponseDescription"] as? String
            self.UniqueID = data["UniqueID"] as? String
            self.ChallengeRequired = data["ChallengeRequired"] as? String
            self.ResponseClass = data["ResponseClass"] as? String
            self.ResponseClassDescription = data["ResponseClassDescription"] as? String
            self.RedirectionURL = data["RedirectionURL"] as? String
        }
    }
    
    let PreAuthenticateInApp: PreAuthenticate?
    let transaction: Transaction?
    
    init(data: [String: Any]) {
        self.PreAuthenticateInApp = PreAuthenticate(data: data["PreAuthenticateInAppResponse"] as? [String: Any] ?? [:])
        self.transaction = Transaction(data: data["Transaction"] as? [String: Any] ?? [:])
    }
}
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
            case uniqueID = "UniqueID"
            case responseCode = "ResponseCode"
            case responseDescription = "ResponseDescription"
            case acsThreeDSVersion = "AcsThreeDSVersion"
            case threeDsServerTransactionID = "ThreeDsServerTransactionID"
            case language = "Language"
            case responseClass = "ResponseClass"
            case responseClassDescription = "ResponseClassDescription"
            case isSDKEnabled = "isSDKEnabled"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case transaction = "Transaction"
    }
    init(data: [String: Any]) throws {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let decoder = JSONDecoder()
            self = try decoder.decode(EmvCo3DS2AcsDetailResponse.self, from: jsonData)
            self.transaction?.isSDKEnabled = true
        }
}

struct Transaction: Decodable {
    
    struct ResponseParam: Decodable {
        let name: String?
        let value: String?
        
        init(data: [String: Any]) {
            self.name = data["Name"] as? String
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
    
    init(data: [String: Any]) {
        self.ResponseCode = data["ResponseCode"] as? String
        self.ResponseDescription = data["ResponseDescription"] as? String
        self.UniqueID = data["UniqueID"] as? String
        self.ResponseClass = data["ResponseClass"] as? String
        self.ResponseClassDescription = data["ResponseClassDescription"] as? String
        
        self.UserEmail                  = data["UserEmail"] as? String
        self.UserType                   = data["UserType"] as? String
        
        self.RedirectionRequired        = data["RedirectionRequired"] as? String
        self.RedirectionURL             = data["RedirectionURL"] as? String
        if let object = data["ResponseParameters"] as? [String: Any], let params = object["Parameters"] as? [[String: Any]] {
            self.ResponseParameters = params.map({ ResponseParam(data: $0) })
        } else {
            self.ResponseParameters = nil
        }
    }
}

struct CancelTransactionResponse: Decodable {
    
    struct CancelTransaction: Decodable {
        let ResponseCode: String?
        let ResponseDescription: String?
        let UniqueID: String?
        let TransactionID: String?
        let ResponseClass: String?
        let ResponseClassDescription: String?
        let RedirectionURL: String?
        
        init(data: [String: Any]) {
            self.ResponseCode = data["ResponseCode"] as? String
            self.ResponseDescription = data["ResponseDescription"] as? String
            self.UniqueID = data["UniqueID"] as? String
            self.TransactionID = data["TransactionID"] as? String
            self.ResponseClass = data["ResponseClass"] as? String
            self.ResponseClassDescription = data["ResponseClassDescription"] as? String
            self.RedirectionURL = data["ReturnURL"] as? String
        }
    }

    let transaction: CancelTransaction?
    
    init(data: [String: Any]) {
        self.transaction = CancelTransaction(data: data["Transaction"] as? [String: Any] ?? [:])
    }
}

struct WalletSessionResponse: Decodable {
    let transaction: Transaction?
    
    init(data: [String: Any]) {
        self.transaction = Transaction(data: data["Transaction"] as? [String: Any] ?? [:])
    }
}

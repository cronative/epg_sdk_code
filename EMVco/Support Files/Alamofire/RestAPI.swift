//
//  RestAPI.swift
//  EPG
//
//  Created by Mohd Arsad on 14/10/22.
//

import Foundation

class RestAPI: NSObject {
    
    static let shared = RestAPI()
    
    func getHeader() -> HTTPHeaders {
        let headers = HTTPHeaders([
            HTTPHeader(name: "Content-Type", value: "application/json"),
            HTTPHeader(name: "Accept", value: "application/json"),
            HTTPHeader(name: "Cache-Control", value: "no-cache")
        ])
        return headers
    }
    
    func getAgentParams() -> [String: Any] {
        var clientParams: [String: Any] = [:]
        clientParams["AddressIP"] = EMVcoPayment.shared.addressIP
        clientParams["Port"] = EMVcoPayment.shared.port
        clientParams["Agent"] = EMVcoPayment.shared.agent
        clientParams["SDK_Key"] = EMVcoPayment.shared.sdkKey
        clientParams["SDK_Version"] = EMVcoPayment.shared.sdkVersion
        return clientParams
    }
}

extension RestAPI {
    
    func getPaymentData(params: [String: Any], completion: @escaping (_ response: PaymentDataResponse?) -> ()) {
        let urlStr = APIConstant.shared.baseURL
        
        AF.request(urlStr, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.getHeader()).response { response in
            guard response.error == nil else {
                completion(nil)
                return
            }
            guard let data = response.data else { completion(nil); return }
            if EMVcoPayment.shared.isPrintMsgEnabled {
                print("getPaymentData: \(String(data: data, encoding: .utf8) ?? "")")
            }
            do {
                //Validate data into your decodable model by JSONDecoder and use as your need
                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    completion(nil)
                    return
                }
                let responseModel = PaymentDataResponse(data: jsonObject)
                completion(responseModel)
            } catch {
                //Show default message when data are not parsed into defined format
                print(error)
                completion(nil)
            }
        }
    }
    
    func preAuthenticate(params: [String: Any], completion: @escaping (_ response: PreAuthenticateResponse?) -> ()) {
        let urlStr = APIConstant.shared.baseURL
        AF.request(urlStr, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.getHeader()).response { response in
            guard response.error == nil else { completion(nil); return }
            guard let data = response.data else { completion(nil); return }
            if EMVcoPayment.shared.isPrintMsgEnabled {
                print("preAuthenticate: \(String(data: data, encoding: .utf8) ?? "")")
            }
            do {
                //Validate data into your decodable model by JSONDecoder and use as your need
                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    completion(nil)
                    return
                }
                let responseModel = PreAuthenticateResponse(data: jsonObject)
                completion(responseModel)
            } catch {
                //Show default message when data are not parsed into defined format
                print(error)
                completion(nil)
            }
        }
    }
    func validateCard(params: [String: Any], completion: @escaping (_ response: EmvCo3DS2AcsDetailResponse?) -> ()) {
        let urlStr = APIConstant.shared.baseURL
        AF.request(urlStr, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.getHeader()).response { response in
            guard response.error == nil else { completion(nil); return }
            guard let data = response.data else { completion(nil); return }
            if EMVcoPayment.shared.isPrintMsgEnabled {
                print("preAuthenticate: \(String(data: data, encoding: .utf8) ?? "")")
            }
            do {
                //Validate data into your decodable model by JSONDecoder and use as your need
                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    completion(nil)
                    return
                }
                    let responseModel = try EmvCo3DS2AcsDetailResponse(data: jsonObject)
                completion(responseModel)
            } catch {
                //Show default message when data are not parsed into defined format
                print(error)
                completion(nil)
            }
        }
    }
    
    func cancelTransaction(completion: @escaping (_ isCancelled: Bool) -> ()) {
        let urlStr = APIConstant.shared.baseURL
        
        var paramObject: [String: Any] = [:]
        paramObject["TransactionID"] = EMVcoPayment.shared.transactionId ?? ""
        paramObject["CancelledByPayer"] = "True"
        paramObject["UserName"] = EMVcoPayment.shared.merchantUserName ?? ""
        paramObject["AuthenticationToken"] = EMVcoPayment.shared.authenticationToken
        
        let params: [String: Any] = ["CancelPayment": paramObject]
        
        AF.request(urlStr, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.getHeader()).response { response in
            guard response.error == nil else { completion(false); return }
            guard let data = response.data else { completion(false); return }
            if EMVcoPayment.shared.isPrintMsgEnabled {
                print("Cancel API Response: \(String(data: data, encoding: .utf8) ?? "")")
            }
            do {
                //Validate data into your decodable model by JSONDecoder and use as your need
                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    completion(false)
                    return
                }
                let responseModel = CancelTransactionResponse(data: jsonObject)
                completion(responseModel.transaction?.ResponseCode == "0")
            } catch {
                //Show default message when data are not parsed into defined format
                print(error)
                completion(false)
            }
        }
    }
    
//    func createWalletSession(params: [String: Any],completion: @escaping (_ response: WalletSessionResponse?) -> ()) {
//        let urlStr = APIConstant.shared.baseURL
//        AF.request(urlStr, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.getHeader()).response { response in
//            guard response.error == nil else { completion(nil); return }
//            guard let data = response.data else { completion(nil); return }
//            if EPGPayment.shared.isPrintMsgEnabled {
//                print("Create Wallet Session API Response: \(String(data: data, encoding: .utf8) ?? "")")
//            }
//            do {
//                //Validate data into your decodable model by JSONDecoder and use as your need
//                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
//                    completion(nil)
//                    return
//                }
//                let responseModel = WalletSessionResponse(data: jsonObject)
//                completion(responseModel)
//            } catch {
//                //Show default message when data are not parsed into defined format
//                print(error)
//                completion(nil)
//            }
//        }
//    }
//    
//    func walletSubmitSession(paymentParams: [String: Any], completion: @escaping (_ response: WalletSessionResponse?) -> ()) {
//        let urlStr = APIConstant.shared.baseURL
//        AF.request(urlStr, method: .post, parameters: paymentParams, encoding: JSONEncoding.default, headers: self.getHeader()).response { response in
//            guard response.error == nil else { completion(nil); return }
//            guard let data = response.data else { completion(nil); return }
//            if EPGPayment.shared.isPrintMsgEnabled {
//                print("Wallet Submit Data API Response: \(String(data: data, encoding: .utf8) ?? "")")
//            }
//            do {
//                //Validate data into your decodable model by JSONDecoder and use as your need
//                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
//                    completion(nil)
//                    return
//                }
//                let responseModel = WalletSessionResponse(data: jsonObject)
//                completion(responseModel)
//            } catch {
//                //Show default message when data are not parsed into defined format
//                print(error)
//                completion(nil)
//            }
//        }
//    }
    
//    func preWalletInApp(params: [String: Any], completion: @escaping (_ response: WalletSessionResponse?) -> ()) {
//        let urlStr = APIConstant.shared.baseURL
//        
//        AF.request(urlStr, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.getHeader()).response { response in
//            guard response.error == nil else {
//                completion(nil)
//                return
//            }
//            guard let data = response.data else { completion(nil); return }
//            if EPGPayment.shared.isPrintMsgEnabled {
//                print("Pre Wallet In App API Response: \(String(data: data, encoding: .utf8) ?? "")")
//            }
//            do {
//                //Validate data into your decodable model by JSONDecoder and use as your need
//                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
//                    completion(nil)
//                    return
//                }
//                let responseModel = WalletSessionResponse(data: jsonObject)
//                completion(responseModel)
//            } catch {
//                //Show default message when data are not parsed into defined format
//                print(error)
//                completion(nil)
//            }
//        }
//    }
//    
    func getWalletTransactionId(params: [String: Any], completion: @escaping (_ transactionId: String?) -> ()) {
        let urlStr = APIConstant.shared.baseURL
        AF.request(urlStr, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.getHeader()).response { response in
            guard response.error == nil else { completion(nil); return }
            guard let data = response.data else { completion(nil); return }
            if EMVcoPayment.shared.isPrintMsgEnabled {
                print("getWalletTransactionId API Response: \(String(data: data, encoding: .utf8) ?? "")")
            }
            do {
                //Validate data into your decodable model by JSONDecoder and use as your need
                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    completion(nil)
                    return
                }
                guard let transaction =  jsonObject["Transaction"] as? [String: Any], let transactionId = transaction["TransactionID"] as? String else {
                    completion(nil)
                    return
                }
                completion(transactionId)
            } catch {
                //Show default message when data are not parsed into defined format
                print(error)
                completion(nil)
            }
        }
    }
}

extension RestAPI {
   
    func clearCache() {
        
        let cstorage = HTTPCookieStorage.shared
        if let cookies = cstorage.cookies(for: URL(string: APIConstant.shared.baseURL)!) {
            for cookie in cookies {
                cstorage.deleteCookie(cookie)
            }
        }
        
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        let fileManager = FileManager.default
        do {
            let dirContent = try FileManager.default.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil, options: [])
            for file in dirContent {
                do {
                    try fileManager.removeItem(at: file)
                    print("Removed At: \(file.absoluteString)")
                }
                catch let error as NSError {
                    print(error)
                }
            }
        }
        catch let error as NSError {
            print(error)
        }
    }
}

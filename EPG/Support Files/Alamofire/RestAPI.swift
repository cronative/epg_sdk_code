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
        clientParams["AddressIP"] = EPGPayment.shared.addressIP
        clientParams["Port"] = EPGPayment.shared.port
        clientParams["Agent"] = EPGPayment.shared.agent
        clientParams["SDK_Key"] = EPGPayment.shared.sdkKey
        clientParams["SDK_Version"] = EPGPayment.shared.sdkVersion
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
            if EPGPayment.shared.isPrintMsgEnabled {
                print("getPaymentData: \(String(data: data, encoding: .utf8) ?? "")")
            }
            do {
                //Validate data into your decodable model by JSONDecoder and use as your need
                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    completion(nil)
                    return
                }

                // ============================================================
                // 🔍 [EPG-DEBUG] FULL RAW JSON DUMP — getPaymentData
                // ============================================================
                if let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                   let prettyString = String(data: prettyData, encoding: .utf8) {
                    // Split into chunks — os_log truncates very long single messages
                    let chunkSize = 800
                    var idx = prettyString.startIndex
                    var chunkNum = 1
                    EPGLogger.network("===== FULL getPaymentData RAW JSON (start) =====")
                    while idx < prettyString.endIndex {
                        let end = prettyString.index(idx, offsetBy: chunkSize, limitedBy: prettyString.endIndex) ?? prettyString.endIndex
                        EPGLogger.network("[chunk \(chunkNum)] \(prettyString[idx..<end])")
                        idx = end
                        chunkNum += 1
                    }
                    EPGLogger.network("===== FULL getPaymentData RAW JSON (end) =====")
                }

                EPGLogger.network("===== PaymentDataInApp RAW RESPONSE =====")
                if let paymentDataInApp = jsonObject["PaymentDataInApp"] as? [String: Any] {

                    // ============================================================
                    // 🔍 [EPG-DEBUG] Print ONLY PaymentDataInApp — full raw JSON, chunked
                    // ============================================================
                    if let pdiData = try? JSONSerialization.data(withJSONObject: paymentDataInApp, options: .prettyPrinted),
                       let pdiString = String(data: pdiData, encoding: .utf8) {
                        let chunkSize = 800
                        var idx = pdiString.startIndex
                        var chunkNum = 1
                        EPGLogger.network("📦 ===== PaymentDataInApp FULL JSON (start) =====")
                        while idx < pdiString.endIndex {
                            let end = pdiString.index(idx, offsetBy: chunkSize, limitedBy: pdiString.endIndex) ?? pdiString.endIndex
                            EPGLogger.network("📦 [chunk \(chunkNum)] \(pdiString[idx..<end])")
                            idx = end
                            chunkNum += 1
                        }
                        EPGLogger.network("📦 ===== PaymentDataInApp FULL JSON (end) =====")
                    }
                    // ============================================================

                    EPGLogger.network("  ResponseCode: \(paymentDataInApp["ResponseCode"] ?? "nil")")
                    EPGLogger.network("  IsRecurrenceTransaction (top-level): \(String(describing: paymentDataInApp["IsRecurrenceTransaction"]))  type: \(type(of: paymentDataInApp["IsRecurrenceTransaction"]))")

                    if let transaction = paymentDataInApp["Transaction"] as? [String: Any] {
                        EPGLogger.network("  Transaction.CardMask: \(transaction["CardMask"] ?? "nil")")
                        EPGLogger.network("  Transaction keys: \(transaction.keys.sorted())")
                    }

                    if let respParam = paymentDataInApp["ResponseParameter"] as? [String: Any] {
                        EPGLogger.network("  ResponseParameter.IsRecurrenceTransaction: \(String(describing: respParam["IsRecurrenceTransaction"]))  type: \(type(of: respParam["IsRecurrenceTransaction"]))")
                        EPGLogger.network("  ResponseParameter keys: \(respParam.keys.sorted())")
                    } else {
                        EPGLogger.warning("  ResponseParameter NOT FOUND in response")
                    }

                    EPGLogger.network("  All PaymentDataInApp keys: \(paymentDataInApp.keys.sorted())")
                } else {
                    EPGLogger.error("  PaymentDataInApp key NOT FOUND in response")
                    EPGLogger.network("  Top-level keys: \(jsonObject.keys.sorted())")
                }
                // ============================================================

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
            if EPGPayment.shared.isPrintMsgEnabled {
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

            // ============================================================
            // 🔍 [EPG-DEBUG] validateCard REQUEST
            // ============================================================
            EPGLogger.network("\n🔍 [EPG-DEBUG] ===== validateCard REQUEST =====")
            EPGLogger.network("   ➤ URL: \(urlStr)")
            EPGLogger.network("   ➤ Params: \(params)")
            EPGLogger.network("🔍 [EPG-DEBUG] =================================\n")
            // ============================================================

            AF.request(urlStr, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.getHeader()).response { response in
                guard response.error == nil else {
                    EPGLogger.error("validateCard — network error: \(response.error?.localizedDescription ?? "unknown")")
                    completion(nil)
                    return
                }
                guard let data = response.data else {
                    EPGLogger.error("validateCard — response data is nil")
                    completion(nil)
                    return
                }

                // ============================================================
                // 🔍 [EPG-DEBUG] validateCard RAW RESPONSE
                // ============================================================
                EPGLogger.network("\n🔍 [EPG-DEBUG] ===== validateCard RAW RESPONSE =====")
                EPGLogger.network("   ➤ Status Code: \(response.response?.statusCode ?? -1)")
                EPGLogger.network("   ➤ Raw Body: \(String(data: data, encoding: .utf8) ?? "nil")")
                EPGLogger.network("🔍 [EPG-DEBUG] ======================================\n")
                // ============================================================

                if EPGPayment.shared.isPrintMsgEnabled {
                    EPGLogger.network("preAuthenticate: \(String(data: data, encoding: .utf8) ?? "")")
                }
                do {
                    //Validate data into your decodable model by JSONDecoder and use as your need
                    guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        EPGLogger.error("validateCard — failed to serialize JSON object")
                        completion(nil)
                        return
                    }
                    let responseModel = try EmvCo3DS2AcsDetailResponse(data: jsonObject)

                    // ============================================================
                    // 🔍 [EPG-DEBUG] validateCard PARSED RESPONSE
                    // ============================================================
                    EPGLogger.network("\n🔍 [EPG-DEBUG] ===== validateCard PARSED RESPONSE =====")
                    EPGLogger.network("   ➤ responseCode: \(responseModel.transaction?.responseCode ?? "nil")")
                    EPGLogger.network("   ➤ responseDescription: \(responseModel.transaction?.responseDescription ?? "nil")")
                    EPGLogger.network("   ➤ acsThreeDSVersion: \(responseModel.transaction?.acsThreeDSVersion ?? "nil")")
                    EPGLogger.network("   ➤ threeDsServerTransactionID: \(responseModel.transaction?.threeDsServerTransactionID ?? "nil")")
                    EPGLogger.network("   ➤ isSDKEnabled: \(String(describing: responseModel.transaction?.isSDKEnabled))")
                    EPGLogger.network("🔍 [EPG-DEBUG] =========================================\n")
                    // ============================================================

                    completion(responseModel)
                } catch {
                    //Show default message when data are not parsed into defined format
                    EPGLogger.error("validateCard — decode error: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }
    
    func cancelTransaction(completion: @escaping (_ isCancelled: Bool) -> ()) {
        let urlStr = APIConstant.shared.baseURL
        
        var paramObject: [String: Any] = [:]
        paramObject["TransactionID"] = EPGPayment.shared.transactionId ?? ""
        paramObject["CancelledByPayer"] = "True"
        paramObject["UserName"] = EPGPayment.shared.merchantUserName ?? ""
        paramObject["AuthenticationToken"] = EPGPayment.shared.authenticationToken
        
        let params: [String: Any] = ["CancelPayment": paramObject]
        
        AF.request(urlStr, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.getHeader()).response { response in
            guard response.error == nil else { completion(false); return }
            guard let data = response.data else { completion(false); return }
            if EPGPayment.shared.isPrintMsgEnabled {
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
    
    func createWalletSession(params: [String: Any],completion: @escaping (_ response: WalletSessionResponse?) -> ()) {
        let urlStr = APIConstant.shared.baseURL
        AF.request(urlStr, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.getHeader()).response { response in
            guard response.error == nil else { completion(nil); return }
            guard let data = response.data else { completion(nil); return }
            if EPGPayment.shared.isPrintMsgEnabled {
                print("Create Wallet Session API Response: \(String(data: data, encoding: .utf8) ?? "")")
            }
            do {
                //Validate data into your decodable model by JSONDecoder and use as your need
                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    completion(nil)
                    return
                }
                let responseModel = WalletSessionResponse(data: jsonObject)
                completion(responseModel)
            } catch {
                //Show default message when data are not parsed into defined format
                print(error)
                completion(nil)
            }
        }
    }
    
    func walletSubmitSession(paymentParams: [String: Any], completion: @escaping (_ response: WalletSessionResponse?) -> ()) {
        let urlStr = APIConstant.shared.baseURL
        AF.request(urlStr, method: .post, parameters: paymentParams, encoding: JSONEncoding.default, headers: self.getHeader()).response { response in
            guard response.error == nil else { completion(nil); return }
            guard let data = response.data else { completion(nil); return }
            if EPGPayment.shared.isPrintMsgEnabled {
                print("Wallet Submit Data API Response: \(String(data: data, encoding: .utf8) ?? "")")
            }
            do {
                //Validate data into your decodable model by JSONDecoder and use as your need
                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    completion(nil)
                    return
                }
                let responseModel = WalletSessionResponse(data: jsonObject)
                completion(responseModel)
            } catch {
                //Show default message when data are not parsed into defined format
                print(error)
                completion(nil)
            }
        }
    }
    
    func preWalletInApp(params: [String: Any], completion: @escaping (_ response: WalletSessionResponse?) -> ()) {
        let urlStr = APIConstant.shared.baseURL
        
        AF.request(urlStr, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.getHeader()).response { response in
            guard response.error == nil else {
                completion(nil)
                return
            }
            guard let data = response.data else { completion(nil); return }
            if EPGPayment.shared.isPrintMsgEnabled {
                print("Pre Wallet In App API Response: \(String(data: data, encoding: .utf8) ?? "")")
            }
            do {
                //Validate data into your decodable model by JSONDecoder and use as your need
                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    completion(nil)
                    return
                }
                let responseModel = WalletSessionResponse(data: jsonObject)
                completion(responseModel)
            } catch {
                //Show default message when data are not parsed into defined format
                print(error)
                completion(nil)
            }
        }
    }
    
    func getWalletTransactionId(params: [String: Any], completion: @escaping (_ transactionId: String?) -> ()) {
        let urlStr = APIConstant.shared.baseURL
        AF.request(urlStr, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.getHeader()).response { response in
            guard response.error == nil else { completion(nil); return }
            guard let data = response.data else { completion(nil); return }
            if EPGPayment.shared.isPrintMsgEnabled {
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

//
//  Untitled.swift
//  FrameWork-V2
//
//  Created by eand ePayment on 10/11/24.
//
//struct TransactionRes: Decodable {
//    
//    struct ResponseParam: Decodable {
//        let name: String?
//        let value: String?
//        
//        init(data: [String: Any]) {
//            self.name = data["Name"] as? String
//            self.value = data["Value"] as? String
//        }
//    }
//    
//    let ResponseCode: String?
//    let ResponseClass: String?
//    let ResponseDescription: String?
//    let ResponseClassDescription: String?
//    let UniqueID: String?
//    
//    let UserEmail: String?
//    let UserType: String?
//    
//    let RedirectionRequired: String?
//    let RedirectionURL: String?
//    let ResponseParameters: [ResponseParam]?
//    
//    init(data: [String: Any]) {
//        self.ResponseCode = data["ResponseCode"] as? String
//        self.ResponseDescription = data["ResponseDescription"] as? String
//        self.UniqueID = data["UniqueID"] as? String
//        self.ResponseClass = data["ResponseClass"] as? String
//        self.ResponseClassDescription = data["ResponseClassDescription"] as? String
//        
//        self.UserEmail                  = data["UserEmail"] as? String
//        self.UserType                   = data["UserType"] as? String
//        
//        self.RedirectionRequired        = data["RedirectionRequired"] as? String
//        self.RedirectionURL             = data["RedirectionURL"] as? String
//        if let object = data["ResponseParameters"] as? [String: Any], let params = object["Parameters"] as? [[String: Any]] {
//            self.ResponseParameters = params.map({ ResponseParam(data: $0) })
//        } else {
//            self.ResponseParameters = nil
//        }
//    }
//}
//
//struct PreAuthenticateResponse: Decodable {
//    
//    struct PreAuthenticate: Decodable {
//        let ResponseCode: String?
//        let ResponseDescription: String?
//        let UniqueID: String?
//        let ChallengeRequired: String?
//        let ResponseClass: String?
//        let ResponseClassDescription: String?
//        let RedirectionURL: String?
//        
//        init(data: [String: Any]) {
//            self.ResponseCode = data["ResponseCode"] as? String
//            self.ResponseDescription = data["ResponseDescription"] as? String
//            self.UniqueID = data["UniqueID"] as? String
//            self.ChallengeRequired = data["ChallengeRequired"] as? String
//            self.ResponseClass = data["ResponseClass"] as? String
//            self.ResponseClassDescription = data["ResponseClassDescription"] as? String
//            self.RedirectionURL = data["RedirectionURL"] as? String
//        }
//    }
//    
//    let PreAuthenticateInApp: PreAuthenticate?
//    let transaction: TransactionRes?
//    
//    init(data: [String: Any]) {
//        self.PreAuthenticateInApp = PreAuthenticate(data: data["PreAuthenticateInAppResponse"] as? [String: Any] ?? [:])
//        self.transaction = TransactionRes(data: data["Transaction"] as? [String: Any] ?? [:])
//    }
//}

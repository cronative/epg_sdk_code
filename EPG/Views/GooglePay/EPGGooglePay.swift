//
//  EPGGooglePay.swift
//  EPG
//
//  Created by Mohd Arsad on 21/03/2023.
//

import Foundation
import UIKit
import PassKit

internal class EPGGoglePay: NSObject {
    
    static let shared = EPGGoglePay()
    var superController: UIViewController?
    var completionHandler: PaymentCompletionHandler!
    var googlePayViewModel: GooglePayViewModel!
    
    private var googlePayURL: URL?
    
    func initiateGooglePay(viewController: UIViewController, amount: NSDecimalNumber, completion: @escaping PaymentCompletionHandler) {
        self.superController = viewController
        self.completionHandler = completion
        self.setupViewModel(amount: amount)
    }
    
    func setupViewModel(amount: NSDecimalNumber) {
        self.googlePayViewModel = GooglePayViewModel()
        self.googlePayViewModel.createWalletSession()
        self.googlePayViewModel.bindCreateSessionModelToController = {
            guard let _ = self.googlePayViewModel.sessionResponse else {
                return
            }
            //Wallet Session Created
            self.startGooglePay(amount: "\(amount)")
        }
        self.googlePayViewModel.bindSubmitPaymentModelToController = {
            guard let response = self.googlePayViewModel.paymentSubmitResponse else {
                self.completionHandler(false, "Response not available")
                return
            }
            //Wallet Payment Submitted
            if EPGPayment.shared.isPrintMsgEnabled {
                print("Payment Submitted to Server: \(response)")
            }
            self.completionHandler(true, "Success")
        }
    }
    
    private func startGooglePay(amount: String) {
        let paValue = "Client_upi_key"  //payee address upi id
        let pnValue = "Merchant Name"     // payee name
        let trValue = "1234ABCD"        //tansaction Id
        let urlValue = "http://www.facebook.com" //url for reference
        let mcValue = "1234"  // retailer category code :- user id
        let tnValue = "Purchase in Merchant" //transction Note
        let amValue = "1"  //amount to pay
        let cuValue = "AED"    //currency
        
        let str =  "gpay://upi/pay?pa=\(paValue)&pn=\(pnValue)&tr=\(trValue)&mc=\(mcValue)&tn=\(tnValue)&am=\(amValue)&cu=\(cuValue)"
        guard let urlString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }

        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    func createGooglePayURL() {
        
        /*
        var googlePayURL = URL(string: "")
        googlePayURL?.scheme = "upi"
       
        
        Uri uri =
        new Uri.Builder()
            .scheme("upi")
            .authority("pay")
            .appendQueryParameter("pa", "test@axisbank")
            .appendQueryParameter("pn", "Test Merchant")
            .appendQueryParameter("mc", "1234")
            .appendQueryParameter("tr", "123456789")
            .appendQueryParameter("tn", "test transaction note")
            .appendQueryParameter("am", "10.01")
            .appendQueryParameter("cu", "INR")
            .appendQueryParameter("url", "https://test.merchant.website")
            .build();
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setData(uri);
        intent.setPackage(GOOGLE_TEZ_PACKAGE_NAME);
        startActivityForResult(intent, TEZ_REQUEST_CODE);
        
        */
    }
}

//
//  VerifyOTP.swift
//  EPG-Demo
//
//  Created by Mohd Arsad on 26/10/22.
//

import UIKit
import WebKit

class VerifyOTP: UIViewController {
    
    @IBOutlet weak var hdrLbl: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var innerCardView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var otp1TF: UITextField!
    @IBOutlet weak var otp2TF: UITextField!
    @IBOutlet weak var otp3TF: UITextField!
    @IBOutlet weak var otp4TF: UITextField!
    @IBOutlet weak var otp5TF: UITextField!
    @IBOutlet weak var otp6TF: UITextField!
    
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var secondLbl: UILabel!
    @IBOutlet weak var resentOTPLbl: UILabel!
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var resendView: UIView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var webView: WKWebView!
    
    private var secondsRemaining = 120
    private var isCancelled: Bool = false
    var isWebRequest: Bool = false
    var webURL: String?
    var superController: PaymentDetailVC?
    var delegate: PaymentDetailDelegate?
    var headerTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupView()
        }
        if let title = headerTitle {
            self.hdrLbl.text = title
        }
    }

    override func viewWillLayoutSubviews() {
        self.innerCardView.setShadow(shadowColor: .black.withAlphaComponent(0.07), shadowRadius: 10.0, cornerRadius: 0.0, side: .bottomSide, opacity: 0.87)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    @IBAction func onClickBackBtn(_ sender: Any) {
        EPGHelper.showConfirmAlert(message: EPGConstant.shared.confirm_cancel_payment) { isSuccess in
            if isSuccess {
                if Internet.isAvailable {
                    self.webView.stopLoading()
                    self.cancelTransaction(completion: { isCancelled in
                        self.isCancelled = true
                        if EPGPayment.shared.isPrintMsgEnabled {
                            print("paymentDetailDelegate(otpVerifyFailed: nil, isBackPressed: true)")
                        }
                        self.delegate?.paymentDetailDelegate(otpVerifyFailed: nil, isBackPressed: true)
                        self.superController?.navigationController?.popViewController(animated: false)
                    })
                } else {
                    EPGHelper.showAlert(message: EPGConstant.shared.internet_connection)
                }
            }
        }
    }
    @IBAction func onClickResendBtn(_ sender: Any) {
        self.secondsRemaining = 30
        self.setupTimer()
    }
    @IBAction func onClickSubmitBtn(_ sender: Any) {
        self.dismiss(animated: false) {
            if EPGPayment.shared.isPrintMsgEnabled {
                print("paymentDetailDelegate(onSuccess: true)")
            }
            self.delegate?.paymentDetailDelegate(onSuccess: true)
        }
    }
}

//MARK: - UIGestureRecognizerDelegate
extension VerifyOTP : UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

extension VerifyOTP {
    
    private func setupTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
            if self.secondsRemaining == 0 {
                Timer.invalidate()
                self.resendView.isHidden = false
                self.otpView.isHidden = true
            }
            if self.secondsRemaining > 0 {
                let min = self.secondsRemaining / 60
                let sec = self.secondsRemaining % 60
                
                let minNo = min < 10 ? "0\(min)" : "\(min)"
                let secNo = sec < 10 ? "0\(sec)" : "\(sec)"
                
                self.secondLbl.text = "\(minNo):\(secNo)"
                self.secondsRemaining -= 1
                
                self.resendView.isHidden = true
                self.otpView.isHidden = false
            }
        }
    }
}

//MARK: - Textfield Delegates
extension VerifyOTP: UITextFieldDelegate {
    
    func setupView() {
        self.view.backgroundColor = .mainOTPBackground
        self.cardView.backgroundColor = .scrollBackground
        
        if self.isWebRequest {
            self.scrollView.isHidden = true
            self.webView.isHidden = false
            self.webView.navigationDelegate = self
            
            guard let url = URL(string: self.webURL ?? "") else {
                return
            }
            self.webView.navigationDelegate = self
            self.webView.load(URLRequest(url: url))
        } else {
            self.scrollView.isHidden = false
            self.webView.isHidden = true
            
            self.otp1TF.backgroundColor = .mainOTPBackground
            self.otp2TF.backgroundColor = .mainOTPBackground
            self.otp3TF.backgroundColor = .mainOTPBackground
            self.otp4TF.backgroundColor = .mainOTPBackground
            self.otp5TF.backgroundColor = .mainOTPBackground
            self.otp6TF.backgroundColor = .mainOTPBackground
            self.innerCardView.backgroundColor = .systemBackground
            self.warningView.backgroundColor = .mainOTPBackground
            self.resendView.isHidden = true
            
            self.otp1TF.becomeFirstResponder()
            self.setupTextField()
            self.setupTimer()
        }
    }
    
    private func setupTextField() {
        self.otp1TF.delegate = self
        self.otp2TF.delegate = self
        self.otp3TF.delegate = self
        self.otp4TF.delegate = self
        self.otp5TF.delegate = self
        self.otp6TF.delegate = self
        self.otp1TF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.otp2TF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.otp3TF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.otp4TF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.otp5TF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.otp6TF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length + range.location > (textField.text?.count)! {
            return false
        }
        let newLength: Int = (textField.text?.count)! + string.count - range.length
        return newLength <= 1
    }
    
    @objc func textFieldDidChange(_ theTextField: UITextField) {
        
        if theTextField == self.otp1TF {
            if theTextField.text?.count == 1 {
                self.otp2TF.becomeFirstResponder()
            }
        }
        else if theTextField == self.otp2TF {
            if theTextField.text?.count == 1 {
                self.otp3TF.becomeFirstResponder()
            } else {
                let  char = self.otp2TF.text?.cString(using: String.Encoding.utf8)!
                let isBackSpace = strcmp(char, "\\b")
                
                if (isBackSpace == -92) {
                    self.otp1TF.becomeFirstResponder()
                }
            }
        }
        else if theTextField == self.otp3TF {
            if theTextField.text?.count == 1 {
                self.otp4TF.becomeFirstResponder()
            } else {
                let  char = self.otp3TF.text?.cString(using: String.Encoding.utf8)!
                let isBackSpace = strcmp(char, "\\b")
                
                if (isBackSpace == -92) {
                    self.otp2TF.becomeFirstResponder()
                }
            }
        }
        else if theTextField == self.otp4TF {
            if theTextField.text?.count == 1 {
                self.otp5TF.becomeFirstResponder()
            } else {
                let  char = self.otp4TF.text?.cString(using: String.Encoding.utf8)!
                let isBackSpace = strcmp(char, "\\b")
                
                if (isBackSpace == -92) {
                    self.otp3TF.becomeFirstResponder()
                }
            }
        }
        else if theTextField == self.otp5TF {
            if theTextField.text?.count == 1 {
                self.otp6TF.becomeFirstResponder()
            } else {
                let  char = self.otp5TF.text?.cString(using: String.Encoding.utf8)!
                let isBackSpace = strcmp(char, "\\b")
                
                if (isBackSpace == -92) {
                    self.otp4TF.becomeFirstResponder()
                }
            }
        }
        else if theTextField == self.otp6TF {
            if theTextField.text?.count == 1{
                self.otp6TF.resignFirstResponder()
            } else {
                let  char = self.otp6TF.text?.cString(using: String.Encoding.utf8)!
                let isBackSpace = strcmp(char, "\\b")
                
                if (isBackSpace == -92) {
                    self.otp5TF.becomeFirstResponder()
                }
            }
        }
    }
    
    func cancelTransaction(completion: @escaping(_ isCancelled: Bool) -> ()) {
        ActivityIndicator.showActivity()
        RestAPI.shared.cancelTransaction { isCancelled in
            DispatchQueue.main.async {
                ActivityIndicator.hideActivity()
                if EPGPayment.shared.isPrintMsgEnabled {
                    print("isCancelled: \(isCancelled)")
                }
                completion(isCancelled)
            }
        }
    }
}

extension VerifyOTP: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let urlStr = navigationAction.request.url?.absoluteString {
            if EPGPayment.shared.isPrintMsgEnabled {
                print("Navigation URL: \(urlStr)")
            }
            if urlStr.contains(EPGPayment.shared.callBackURL ?? "") && self.isCancelled == false {
                if EPGPayment.shared.isPrintMsgEnabled {
                    print("decidePolicyFor: URL contains")
                }
                self.delegate?.paymentDetailDelegate(onSuccess: true)
                self.superController?.navigationController?.popViewController(animated: false)
                decisionHandler(.cancel)
                return
            }
      }
      decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        ActivityIndicator.showActivity()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        ActivityIndicator.hideActivity()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ActivityIndicator.hideActivity()
    }
}

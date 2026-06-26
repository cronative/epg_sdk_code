//
//  AddCardVC.swift
//  EPG-Demo
//
//  Created by Mohd Arsad on 18/10/22.
//

import UIKit
import FrameWork_V2

class AddCardVC: BottomPopupViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var outerCardView: UIView!
    @IBOutlet weak var hdrLbl: UILabel!
    @IBOutlet weak var cardNoView: UIView!
    @IBOutlet weak var cardNoTypeIV: UIImageView!
    @IBOutlet weak var cardNoTF: TextFieldFormatter!
    @IBOutlet weak var cardNoIconIV: UIImageView!
    @IBOutlet weak var expiryView: UIView!
    @IBOutlet weak var expiryIV: UIImageView!
    @IBOutlet weak var expiryTF: UITextField!
    @IBOutlet weak var cvvView: UIView!
    @IBOutlet weak var cvvIV: UIImageView!
    @IBOutlet weak var cvvInfoIV: UIImageView!
    @IBOutlet weak var cvvTF: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var entryCardView: UIView!
    @IBOutlet weak var cardInfoView: UIView!
    @IBOutlet weak var backCardView: UIView!
    @IBOutlet weak var cardSKHolderNameLbl: UILabel!
    @IBOutlet weak var cardSKValidStackView: UIStackView!
    @IBOutlet weak var cardSKValidFixedLbl: UILabel!
    @IBOutlet weak var cardSKValidLbl: UILabel!
    @IBOutlet weak var cardSKCardNoLbl: UILabel!
    @IBOutlet weak var cardSKTypeBackView: UIView!
    @IBOutlet weak var cardSKTypeIV: UIImageView!
    @IBOutlet weak var cardSKCVVLbl: UILabel!
    @IBOutlet weak var cardNoValidateStatusLbl: UILabel!
    @IBOutlet weak var expiryDateStatusLbl: UILabel!
    @IBOutlet weak var expiryCvvSeperateLbl: UILabel!
    @IBOutlet weak var cvvStatusLbl: UILabel!
    @IBOutlet weak var cvvDetailMainView: UIView!
    @IBOutlet weak var entryCardStackView: UIStackView!
    @IBOutlet weak var cvvExpiryStackView: UIStackView!
    
    //MARK: - Constant & Variables
    var showingFront = true
    var addCardViewModel: AddCardViewModel!
    var paymentMethod: PaymentDataResponse.Instrument?
    var superController: PaymentDetailVC?
    var delegate: PaymentDetailDelegate?
    var isSDKEnabled: Bool = false  

    
    //MARK: - Initiate Process
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setLocalization()
        self.setupBlurView()
        self.cvvDetailMainView.isHidden = true
        self.setupViewModel()
//        self.setupKeyboard(textField: self.cardNoTF, scrollView: self.scrollView)
//        self.setupKeyboard(textField: self.expiryTF, scrollView: self.scrollView)
//        self.setupKeyboard(textField: self.cvvTF, scrollView: self.scrollView)
        
        if LocalizationSystem.shared.isArabicActive {
            self.cardSKValidStackView.flip()
            self.cardSKValidFixedLbl.flip()
            self.cardSKValidLbl.flip()
            
            self.cardSKTypeBackView.flip()
            self.cardSKTypeIV.flip()
            
            self.cardNoView.flip()
            self.cardNoTypeIV.flip()
            self.cardNoTF.flip()
            
            self.cvvExpiryStackView.flip()
            self.expiryTF.flip()
            self.cvvTF.flip()
            self.cvvIV.flip()
        }
    }


    override func viewWillLayoutSubviews() {
        
        var cardCorner: CGFloat = 0.0
        var textfieldCorner: CGFloat = 0.0
        switch selectedTheme {
        case .theme1, .auto:
            cardCorner = 20.0
            textfieldCorner = 12.0
        case .theme2:
            cardCorner = 0.0
            textfieldCorner = 0.0
        }
        
        self.outerCardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.outerCardView.layer.cornerRadius = cardCorner
        self.cvvDetailMainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.cvvDetailMainView.layer.cornerRadius = cardCorner
        self.cvvDetailMainView.layer.masksToBounds = true
        self.cardNoView.layer.cornerRadius = textfieldCorner
        self.expiryView.layer.cornerRadius = textfieldCorner
        self.cvvView.layer.cornerRadius = textfieldCorner
        self.entryCardView.layer.cornerRadius = cardCorner
        self.confirmBtn.setGradient(cornerRadius: textfieldCorner, firstColor: .greenStartColor, secoundColor: .greenEndColor)
        self.shadowView.setShadow(shadowColor: .label, shadowRadius : 20.0, cornerRadius : textfieldCorner, side: .bottomSide, opacity: 0.30)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let height = UIScreen.main.bounds.height * 0.7
        if height < 400 {
            self.scrollView.isScrollEnabled = true
        } else if height < 680 {
            self.scrollView.isScrollEnabled = false
        } else {
            self.scrollView.isScrollEnabled = false
        }
    }
    
    func setLocalization() {
        self.hdrLbl.text = "enter_card_details".localize
        self.cardSKValidFixedLbl.text = "valid_thru".localize
        self.confirmBtn.setTitle("confirm_continue".localize, for: .normal)
        self.cardSKValidLbl.textAlignment = LocalizationSystem.shared.isArabicActive ? .left : .right
        let image = UIImage(named: "back_trans", in: EPGHelper.bundle, with: .none)?.localize
        self.backBtn.setBackgroundImage(image, for: .normal)
        self.cardSKCardNoLbl.textAlignment = .left
        self.cardSKValidLbl.textAlignment = .right
        self.cardSKValidFixedLbl.textAlignment = .right
    }
    
    override var popupHeight: CGFloat {
        var height = UIScreen.main.bounds.height * 0.7
        if height < 400 {
            height = UIScreen.main.bounds.height * 0.9
        } else if height < 680 {
            return 680.0
        }
        return height
    }
    
    override var popupTopCornerRadius: CGFloat {
        var cardCorner: CGFloat = 0.0
        switch selectedTheme {
        case .theme1, .auto:
            cardCorner = 20.0
        case .theme2:
            cardCorner = 0.0
        }
        return cardCorner
    }
    
    func setupBlurView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemUltraThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.backgroundColor = .black.withAlphaComponent(0.1)
        blurEffectView.frame = UIScreen.main.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.cvvDetailMainView.addSubview(blurEffectView)
        self.cvvDetailMainView.sendSubviewToBack(blurEffectView)
    }

    @IBAction func onClickBackBtn(_ sender: Any) {
        self.view.backgroundColor = .clear
        self.dismiss(animated: true)
    }
    @IBAction func onClickCVVInfoBtn(_ sender: Any) {
        self.cvvDetailMainView.isHidden = false
    }
    @IBAction func onClickConfirmBtn(_ sender: Any) {
        self.view.endEditing(true)
        if isSDKEnabled {
                let initializer = InitializeActivity()
            let configParameters = ConfigParameters()
                do {
                    // Add the parameters to the ConfigParameters object
                      try configParameters.addParam(paramName: "sdkReferenceNumber", paramValue: "123456789")
                      try configParameters.addParam(paramName: "sdkMaxTimeout", paramValue: "60")
                      try configParameters.addParam(paramName: "sdkVersion", paramValue: "1.0.0")
                      try configParameters.addParam(paramName: "baseUrl", paramValue: "https://demo-ipg.ctdev.comtrust.ae:7443")
                      try configParameters.addParam(paramName: "merchantUsername", paramValue: "merchantUser123")
                      try configParameters.addParam(paramName: "customerName", paramValue: "John Doe")
                      try configParameters.addParam(paramName: "transactionID", paramValue: "txn_001122")
                      try configParameters.addParam(paramName: "authToken", paramValue: "sampleAuthToken123")
                      try configParameters.addParam(paramName: "cardNumber", paramValue: "4111111111111111")
                      try configParameters.addParam(paramName: "verifyCode", paramValue: "123")
                      try configParameters.addParam(paramName: "expiryMonth", paramValue: "12")
                      try configParameters.addParam(paramName: "expiryYear", paramValue: "25")
                    try initializer.initialize(configParameters: configParameters, locale: nil, uiCustomization: nil)

                    try initializer.createTransaction(directoryServerID: "11228", messageVersion: "hai") { result in
                                switch result {
                                case .success(let transaction):
                                    // Process the transaction here
                                    print("Transaction successful: \(transaction)")
                                case .failure(let error):
                                    // Handle any errors that occurred during transaction creation
                                    print("Error during transaction creation: \(error)")
                                }
                            }
                            
                    // Process the transaction here, or handle the transaction further
                } catch {
                    print("Error creating transaction: \(error)")
                }
                return  // Exit the method to prevent proceeding with other logic
            }
            
        self.checkValidation(textField: self.cardNoTF, isEnd: true)
        self.checkValidation(textField: self.expiryTF, isEnd: true)
        self.checkValidation(textField: self.cvvTF, isEnd: true)
        
        var isValid = (self.cardNoValidateStatusLbl.isHidden == true) && (self.expiryDateStatusLbl.isHidden == true) && (self.cvvStatusLbl.isHidden == true)
         if self.cardNoTF.text?.count == 0 || self.expiryTF.text?.count == 0 || self.cvvTF.text?.count == 0 {
             isValid = false
         }
        guard isValid else {
            print("Some Error Happens")
            return
        }
        
        let validateResponse = self.addCardViewModel.validate(card: self.cardNoTF.text, expiryDate: self.expiryTF.text, cvvCode: self.cvvTF.text)
        guard let params = validateResponse?.params else {
            EPGHelper.showAlert(controller: self, message: validateResponse?.errorMessage ?? "")
            return
        }
        if Internet.isAvailable {
            self.addCardViewModel.getPreAuthenticationData(cardParams: params) { response in
                guard let response = response else {
                    EPGHelper.showAlert(controller: self, message: EPGConstant.shared.authentication_failed) { isComplete in
                        if isComplete { self.dismiss(animated: true) }
                    }
                    return
                }
                guard response.PreAuthenticateInApp?.ResponseCode == "0" && response.transaction?.ResponseCode == nil else {
                    let msg = response.transaction?.ResponseDescription ?? (response.PreAuthenticateInApp?.ResponseDescription ?? "Response Not Available")
                    EPGHelper.showAlert(controller: self, message: msg) { isComplete in
                        if isComplete {
                            self.dismiss(animated: true) {
                                if EPGPayment.shared.isPrintMsgEnabled {
                                    print("paymentDetailDelegate(addCardFailed: \(msg)")
                                }
                                self.delegate?.paymentDetailDelegate(addCardFailed: msg)
                            }
                        }
                    }
                    return
                }
                
                let isOTPRequired = response.PreAuthenticateInApp?.ChallengeRequired ?? "false"
                let urlStr = response.PreAuthenticateInApp?.RedirectionURL
                if isOTPRequired == "true" {
                    self.dismiss(animated: false) {
                        let vc = VerifyOTP(nibName: "VerifyOTP", bundle: EPGHelper.bundle)
                        vc.modalPresentationStyle = .overFullScreen
                        vc.isWebRequest = true
                        vc.webURL = urlStr
                        vc.delegate = self.delegate
                        vc.superController = self.superController
                        self.superController?.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    self.dismiss(animated: false) {
                        if EPGPayment.shared.isPrintMsgEnabled {
                            print("AddCard: paymentDetailDelegate(onSuccess: true)")
                        }
                        self.delegate?.paymentDetailDelegate(onSuccess: true)
                    }
                }
            }
        } else {
            self.navigationController?.popViewController(animated: false)
            EPGHelper.showAlert(message: EPGConstant.shared.internet_connection)
        }
    }
    @IBAction func onClickCVVDetailMainBtn(_ sender: Any) {
        self.cvvDetailMainView.isHidden = true
    }
}


//MARK: - Initialise Methods
extension AddCardVC {
    /// Setup view model to manage validation
    func setupViewModel() {
        self.view.backgroundColor = .clear
        self.cardNoTypeIV.isHidden = true
        self.cardSKTypeIV.isHidden = true
        self.addCardViewModel = AddCardViewModel()
        self.setupTextField()
    }
    
    /// Seutp all testfield with initial data
    func setupTextField() {
        self.cardNoTF.delegate = self
        self.expiryTF.delegate = self
        self.cvvTF.delegate = self
        self.cardNoTF.addTarget(self, action: #selector(onTextFieldChange(_:)), for: .editingChanged)
        self.expiryTF.addTarget(self, action: #selector(onTextFieldChange(_:)), for: .editingChanged)
        self.cvvTF.addTarget(self, action: #selector(onTextFieldChange(_:)), for: .editingChanged)
        self.cardNoTF.pattern = "NNNN NNNN NNNN NNNN NNN"
        self.cardNoValidateStatusLbl.isHidden = true
        self.expiryDateStatusLbl.isHidden = true
        self.cvvStatusLbl.isHidden = true
        self.payButtonVisibilityUpdate()
        
        self.cardNoIconIV.tintColor = .lightGray
        self.expiryIV.tintColor = .lightGray
        self.cvvIV.tintColor = .lightGray
        
        self.cardSKCardNoLbl.text = "XXXX XXXX XXXX XXXX"
        self.cardSKValidLbl.text = "MM/YY"
        self.cardSKCVVLbl.text = ""
        
        self.cardNoIconIV.image = UIImage(named: "card_ic", in: EPGHelper.bundle, with: nil)?.withRenderingMode(.alwaysTemplate).withTintColor(.lightGray)
        self.expiryIV.image = UIImage(named: "calendar", in: EPGHelper.bundle, with: nil)?.withRenderingMode(.alwaysTemplate).withTintColor(.lightGray)
        self.cvvIV.image = UIImage(named: "cvv", in: EPGHelper.bundle, with: nil)?.withRenderingMode(.alwaysTemplate).withTintColor(.lightGray)
        self.cvvInfoIV.image = UIImage(named: "info", in: EPGHelper.bundle, with: nil)?.withRenderingMode(.alwaysTemplate).withTintColor(.lightGray)
    }
    
    /// Flip Card Eskelton Image
    /// - Parameter isShowFront: showcard image
    func flipCardView(isShowFront: Bool) {
        self.showingFront = isShowFront
        let animateTime: TimeInterval = 0.4
        if self.showingFront {
            let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
            self.shadowView.alpha = 0.0
            UIView.transition(with: self.backCardView, duration: animateTime, options: transitionOptions, animations: {
                self.backCardView.isHidden = true
            })
            UIView.transition(with: self.cardInfoView, duration: animateTime, options: transitionOptions, animations: {
                self.cardInfoView.isHidden = false
            })
            UIView.animate(withDuration: 1.0, delay: 0.0) {
                self.shadowView.alpha = 1.0
            }
        } else {
            self.shadowView.alpha = 0.0
            let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
            UIView.transition(with: self.cardInfoView, duration: animateTime, options: transitionOptions, animations: {
                self.cardInfoView.isHidden = true
            })
            UIView.transition(with: self.backCardView, duration: animateTime, options: transitionOptions, animations: {
                self.backCardView.isHidden = false
            })
            UIView.animate(withDuration: 1.0, delay: 0.0) {
                self.shadowView.alpha = 1.0
            }
        }
    }
}

//
//  AddCardVC.swift
//  EPG-Demo
//
//  Created by Mohd Arsad on 18/10/22.
//

import UIKit


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
    /// Set by PaymentDetailVC when server returns IsRecurrenceTransaction = true
    var isRecurrencePayment: Bool = false {
        didSet {
            EPGLogger.recurrence("isRecurrencePayment set to: \(isRecurrencePayment)")
        }
    }
    /// Full PaymentDataInApp response — needed for recurrence CardMask display
    var paymentDataResponse: PaymentDataResponse.PaymentData? {
        didSet {
            EPGLogger.recurrence("paymentDataResponse received")
            EPGLogger.recurrence("  isRecurrenceTransaction: \(String(describing: paymentDataResponse?.isRecurrenceTransaction))")
            EPGLogger.recurrence("  CardMask: \(String(describing: paymentDataResponse?.Transaction?.CardMask))")
        }
    }

    
    //MARK: - Pending recurrence data (set before viewDidLoad in case constructor
    // already triggers a view load — guarantees configureRecurrenceUI always
    // sees the correct values regardless of UIKit's internal load timing).
    private var pendingIsRecurrencePayment: Bool?
    private var pendingPaymentDataResponse: PaymentDataResponse.PaymentData?

    /// Call this BEFORE presenting the view controller, instead of setting
    /// isRecurrencePayment / paymentDataResponse directly. This avoids the race
    /// where touching vc.view (even indirectly via property assignment ordering)
    /// can trigger viewDidLoad before properties are applied.
    func configureForRecurrence(isRecurrencePayment: Bool, paymentDataResponse: PaymentDataResponse.PaymentData?) {
        self.pendingIsRecurrencePayment = isRecurrencePayment
        self.pendingPaymentDataResponse = paymentDataResponse
        self.isRecurrencePayment = isRecurrencePayment
        self.paymentDataResponse = paymentDataResponse
        EPGLogger.recurrence("configureForRecurrence called — isRecurrencePayment: \(isRecurrencePayment)")

        // If the view has ALREADY loaded by the time this is called (race condition
        // case), re-run configureRecurrenceUI now so the UI catches up.
        if self.isViewLoaded {
            EPGLogger.recurrence("View already loaded — re-running configureRecurrenceUI now")
            self.configureRecurrenceUI()
        }
    }

    //MARK: - Initiate Process
    override func viewDidLoad() {
        super.viewDidLoad()

        // Apply any pending recurrence values that were queued before the view loaded.
        if let pending = pendingIsRecurrencePayment {
            self.isRecurrencePayment = pending
        }
        if let pendingData = pendingPaymentDataResponse {
            self.paymentDataResponse = pendingData
        }

        // Do any additional setup after loading the view.
        self.setLocalization()
        self.setupBlurView()
        self.cvvDetailMainView.isHidden = true
        self.setupViewModel()
        self.configureRecurrenceUI()
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

        // MARK: - Recurrence Flow
        // Mirror of Android: AddCardBottomSheet.clickPayButton() with isRecurrencePayment = true
        // Only CVV is validated; CardNumber & Expiry are omitted — server already has the saved card.
        if isRecurrencePayment {
            EPGLogger.recurrence("Confirm tapped — recurrence flow")
            guard let cvv = self.cvvTF.text, cvv.count > 0 else {
                EPGLogger.warning("CVV is empty")
                EPGHelper.showAlert(controller: self, message: EPGConstant.shared.enter_cvv)
                return
            }
            EPGLogger.recurrence("Calling PreAuthenticate with CVV only — no card/expiry sent")
            if Internet.isAvailable {
                self.addCardViewModel.getPreAuthenticationDataRecurrence(cvv: cvv) { response in
                    guard let response = response else {
                        EPGHelper.showAlert(controller: self, message: EPGConstant.shared.authentication_failed) { _ in
                            self.dismiss(animated: true)
                        }
                        return
                    }
                    EPGLogger.recurrence("PreAuth response received")
                    EPGLogger.recurrence("  ResponseCode: \(response.PreAuthenticateInApp?.ResponseCode ?? "nil")")
                    EPGLogger.recurrence("  ChallengeRequired: \(response.PreAuthenticateInApp?.ChallengeRequired ?? "nil")")
                    EPGLogger.recurrence("  RedirectionURL: \(response.PreAuthenticateInApp?.RedirectionURL ?? "nil")")
                    guard response.PreAuthenticateInApp?.ResponseCode == "0" && response.transaction?.ResponseCode == nil else {
                        let msg = response.transaction?.ResponseDescription ?? (response.PreAuthenticateInApp?.ResponseDescription ?? "Response Not Available")
                        EPGLogger.error("PreAuth failed: \(msg)")
                        EPGHelper.showAlert(controller: self, message: msg) { _ in
                            self.dismiss(animated: true) {
                                self.delegate?.paymentDetailDelegate(addCardFailed: msg)
                            }
                        }
                        return
                    }
                    let isOTPRequired = response.PreAuthenticateInApp?.ChallengeRequired ?? "false"
                    let urlStr = response.PreAuthenticateInApp?.RedirectionURL
                    EPGLogger.recurrence("OTP Required: \(isOTPRequired)")
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
                            self.delegate?.paymentDetailDelegate(onSuccess: true)
                        }
                    }
                }
            } else {
                EPGHelper.showAlert(message: EPGConstant.shared.internet_connection)
            }
            return
        }

        if isSDKEnabled {
                let initializer = InitializeActivity()
            let configParameters = ConfigParameters()
                do {
                    // Add the parameters to the ConfigParameters object — all values pulled
                    // dynamically from EPGPayment.shared / entered card fields, no hardcoding.
                      try configParameters.addParam(paramName: "sdkReferenceNumber", paramValue: EPGPayment.shared.transactionId ?? "")
                      try configParameters.addParam(paramName: "sdkMaxTimeout", paramValue: "60")
                      try configParameters.addParam(paramName: "sdkVersion", paramValue: EPGPayment.shared.sdkVersion)
                      try configParameters.addParam(paramName: "baseUrl", paramValue: APIConstant.shared.baseURL)
                      try configParameters.addParam(paramName: "merchantUsername", paramValue: EPGPayment.shared.merchantUserName ?? "")
                      try configParameters.addParam(paramName: "customerName", paramValue: EPGPayment.shared.customerName ?? "")
                      try configParameters.addParam(paramName: "transactionID", paramValue: EPGPayment.shared.transactionId ?? "")
                      try configParameters.addParam(paramName: "authToken", paramValue: EPGPayment.shared.authenticationToken ?? "")
                      try configParameters.addParam(paramName: "cardNumber", paramValue: (self.cardNoTF.text ?? "").replacingOccurrences(of: " ", with: ""))
                      try configParameters.addParam(paramName: "verifyCode", paramValue: self.cvvTF.text ?? "")
                      try configParameters.addParam(paramName: "expiryMonth", paramValue: (self.expiryTF.text ?? "").components(separatedBy: "/").first ?? "")
                      try configParameters.addParam(paramName: "expiryYear", paramValue: (self.expiryTF.text ?? "").components(separatedBy: "/").last ?? "")
                    try initializer.initialize(configParameters: configParameters, locale: nil, uiCustomization: nil)

                    // directoryServerID & messageVersion come from the card validation
                    // (GetEmvco3DS2AcsDetail) response — never hardcoded.
                    if let transaction = try? initializer.createTransaction(directoryServerID: EPGPayment.shared.directoryServerID ?? "", messageVersion: EPGPayment.shared.acsThreeDSVersion) {
                        EPGLogger.debug("Transaction created: \(transaction)")
                    } else {
                        EPGLogger.error("Error creating transaction")
                    }
                            
                    // Process the transaction here, or handle the transaction further
                } catch {
                    EPGLogger.error("Error creating transaction: \(error)")
                }
//                return  // Exit the method to prevent proceeding with other logic
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


//MARK: - Recurrence Payment UI
// Mirror of Android: AddCardBottomSheet.configureRecurrencePaymentUi()
extension AddCardVC {

    func configureRecurrenceUI() {
        EPGLogger.recurrence("configureRecurrenceUI called — isRecurrencePayment: \(isRecurrencePayment)")
        guard isRecurrencePayment else {
            EPGLogger.recurrence("Not a recurrence payment — normal card flow")
            return
        }
        EPGLogger.recurrence("✅ Recurrence flow ACTIVE — card number & expiry shown read-only, CVV editable")

        self.cardNoView.isHidden              = false
        self.expiryView.isHidden              = false
        self.cardNoValidateStatusLbl.isHidden = true
        self.expiryDateStatusLbl.isHidden     = true

        // Format CardMask into groups of 4 with spaces: "424242******4242" → "4242 42** **** 4242"
        let rawMask = paymentDataResponse?.Transaction?.CardMask ?? ""
        let formattedMask = rawMask.isEmpty ? "XXXX XXXX XXXX XXXX" : formatCardMask(rawMask)

        EPGLogger.recurrence("CardMask raw: \(rawMask)  formatted: \(formattedMask)")

        // Set in textfield (bypass TextFieldFormatter pattern engine)
        self.cardNoTF.pattern = ""
        self.cardNoTF.setRawText(formattedMask)
        self.cardNoTF.isUserInteractionEnabled = false
        self.cardNoTF.isEnabled  = false
        self.cardNoTF.delegate   = nil

        // Set in card skeleton preview
        self.cardSKCardNoLbl.text = formattedMask

        // Detect card type from first digit(s) and show logo
        showCardLogoForMask(rawMask)

        // Expiry — show locked XX/XX
        self.expiryTF.text = "XX/XX"
        self.expiryTF.isUserInteractionEnabled = false
        self.expiryTF.isEnabled  = false
        self.expiryTF.delegate   = nil
        self.cardSKValidLbl.text      = "XX/XX"
        self.cardSKValidFixedLbl.text = "valid_thru".localize

        // Force enable confirm button
        self.confirmBtn.alpha = 1.0
        self.confirmBtn.isUserInteractionEnabled = true
        self.confirmBtn.isEnabled = true
    }

    /// Format a raw CardMask string into groups of 4 separated by spaces.
    /// e.g. "424242******4242" → "4242 42** **** 4242"
    ///      "4111111111111111" → "4111 1111 1111 1111"
    private func formatCardMask(_ mask: String) -> String {
        // Strip any existing spaces first
        let stripped = mask.replacingOccurrences(of: " ", with: "")
        var result = ""
        for (i, char) in stripped.enumerated() {
            if i > 0 && i % 4 == 0 { result += " " }
            result.append(char)
        }
        return result
    }

    /// Detect card type from first 1–2 digits of CardMask and update logo imageviews.
    private func showCardLogoForMask(_ mask: String) {
        let digits = mask.replacingOccurrences(of: " ", with: "")
        guard !digits.isEmpty else { return }

        let first  = String(digits.prefix(1))
        let first2 = String(digits.prefix(2))

        let (icon, logo): (String?, String?)
        switch first {
        case "4":                              // Visa
            icon = "visa1"; logo = "visa2"
        case "5" where ["51","52","53","54","55"].contains(first2),
             "2" where Int(first2) ?? 0 >= 22: // Mastercard
            icon = "master1"; logo = "master2"
        case "3" where ["34","37"].contains(first2): // Amex
            icon = "amex1"; logo = "amex2"
        default:
            icon = nil; logo = nil
        }

        if let icon = icon, let logo = logo {
            self.cardNoTypeIV.image = UIImage(named: icon, in: EPGHelper.bundle, with: nil)
            self.cardSKTypeIV.image = UIImage(named: logo, in: EPGHelper.bundle, with: nil)
            self.cardNoTypeIV.isHidden = false
            self.cardSKTypeIV.isHidden = false
        } else {
            self.cardNoTypeIV.isHidden = true
            self.cardSKTypeIV.isHidden = true
        }
    }
}

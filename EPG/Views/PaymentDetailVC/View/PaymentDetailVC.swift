//
//  PaymentDetailVC.swift
//  EPG
//
//  Created by Mohd Arsad on 17/10/22.
//

import UIKit

class PaymentDetailVC: UIViewController {
    
    @IBOutlet weak var upperBackgroundIV: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var hdrLbl: UILabel!
    @IBOutlet weak var paymentDescriptionFixedLbl: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var merchantView: UIView!
    @IBOutlet weak var merchantNameFixedLbl: UILabel!
    @IBOutlet weak var merchantNameLbl: UILabel!
    @IBOutlet weak var merchantLogo: UIImageView!
    @IBOutlet weak var merchantLogo2: UIImageView!
    @IBOutlet weak var orderIdView: UIView!
    @IBOutlet weak var orderIdLbl: UILabel!
    @IBOutlet weak var orderIdFixedLbl: UILabel!
    @IBOutlet weak var pointsView: UIView!
    @IBOutlet weak var pointsLbl: UILabel!
    @IBOutlet weak var pointsFixedLbl: UILabel!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var amountFixedLbl: UILabel!
    @IBOutlet weak var amountTaxFixedLbl: UILabel!
    @IBOutlet weak var paymentMethodFixedLbl: UILabel!
    @IBOutlet weak var paymentMethodCV: UICollectionView!
    @IBOutlet weak var subOptionTitleLbl: UILabel! //Please Select Prefered Method
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraints: NSLayoutConstraint! //100 default
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var payBtn: UIButton!
    
    var paymentMethods: [PaymentDataResponse.Instrument] = []
    var bnplData: [PaymentDataResponse.Wallet] = []
    var mobilePaymentsData: [PaymentDataResponse.Wallet] = []
    var delegate: EPGDelegate?
    var paymentDetailViewModel: PaymentDetailViewModel!
    var subOptionSelecedIndex: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        IQKeyboardManager.shared.enable = true
//        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        self.setLocalization()
        self.setupViewModel()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch selectedTheme {
        case .theme1, .auto:
            return .lightContent
        case .theme2:
            return .darkContent
        }
    }
    
    func setLocalization() {
        self.hdrLbl.text = "payment".localize
        self.paymentDescriptionFixedLbl.text = "payment_description".localize
        self.orderIdFixedLbl.text = "order_id".localize
        self.pointsFixedLbl.text = "order_name".localize
        self.amountFixedLbl.text = "amount".localize
        self.paymentMethodFixedLbl.text = "payment_method".localize
        self.payBtn.setTitle("pay".localize, for: .normal)
        self.cancelBtn.setTitle("cancel".localize, for: .normal)
    }
    
    override func viewWillLayoutSubviews() {
        self.cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        var cardCorner: CGFloat = 0.0
        switch selectedTheme {
        case .theme1, .auto:
            cardCorner = 12.0
            self.cardView.layer.cornerRadius = 25.0
            self.upperBackgroundIV.isHidden = false
            self.hdrLbl.isHidden = false
            self.merchantLogo2.isHidden = true
            self.merchantLogo.isHidden = false
            self.hdrLbl.textColor = .white
            self.view.backgroundColor = UIColor.mainBackground
            let image = UIImage(named: "back_trans2", in: EPGHelper.bundle, with: .none)?.localize
            self.backBtn.setBackgroundImage(image, for: .normal)
        case .theme2:
            cardCorner = 0.0
            self.cardView.layer.cornerRadius = 0.0
            self.upperBackgroundIV.isHidden = true
            self.hdrLbl.isHidden = true
            self.merchantLogo2.isHidden = false
            self.merchantLogo.isHidden = true
            self.hdrLbl.textColor = .label
            self.view.backgroundColor = .systemBackground
            let image = UIImage(named: "back_trans", in: EPGHelper.bundle, with: .none)?.localize
            self.backBtn.setBackgroundImage(image, for: .normal)
            self.view.backgroundColor = UIColor.background
        }
        self.merchantView.setShadow(shadowColor: .black.withAlphaComponent(0.07), shadowRadius: 10.0, cornerRadius: cardCorner, side: .bottomSide, opacity: 0.87)
        self.orderIdView.setShadow(shadowColor: .black.withAlphaComponent(0.07), shadowRadius: 10.0, cornerRadius: cardCorner, side: .bottomSide, opacity: 0.87)
        self.pointsView.setShadow(shadowColor: .black.withAlphaComponent(0.07), shadowRadius: 10.0, cornerRadius: cardCorner, side: .bottomSide, opacity: 0.87)
        self.amountView.setShadow(shadowColor: .black.withAlphaComponent(0.07), shadowRadius: 10.0, cornerRadius: cardCorner, side: .bottomSide, opacity: 0.87)
        self.payBtn.setGradient(cornerRadius: cardCorner, firstColor: .greenStartColor, secoundColor: .greenEndColor)
        self.cancelBtn.setBorder(width: 1.0, color: .label.withAlphaComponent(0.2), cornerRadius: cardCorner)
    }
    
    //MARK: - IBActions
    @IBAction func onClickBackBtn(_ sender: Any) {
        EPGHelper.showConfirmAlert(message: EPGConstant.shared.confirm_cancel_payment) { isSuccess in
            if isSuccess {
                if Internet.isAvailable {
                    self.paymentDetailViewModel.cancelTransaction { isCancelled in
                        let cancelledResult = EPGResult(errorMessage: EPGConstant.shared.cancelled_by_user, success: false, transactionId: "", cancelledbyUser: true)
                        self.delegate?.epgPayment(delegate: cancelledResult)
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    EPGHelper.showAlert(message: EPGConstant.shared.internet_connection)
                }
            }
        }
    }
    @IBAction func onClickCancelBtn(_ sender: Any) {
        EPGHelper.showConfirmAlert(message: EPGConstant.shared.confirm_cancel_payment) { isSuccess in
            if isSuccess {
                if Internet.isAvailable {
                    self.paymentDetailViewModel.cancelTransaction { isCancelled in
                        let cancelledResult = EPGResult(errorMessage: EPGConstant.shared.cancelled_by_user, success: false, transactionId: "", cancelledbyUser: true)
                        self.delegate?.epgPayment(delegate: cancelledResult)
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    EPGHelper.showAlert(message: EPGConstant.shared.internet_connection)
                }
            }
        }
    }
    @IBAction func onClickPayBtn(_ sender: Any) {
        guard let selectedPaymentMethod = self.paymentMethods.filter({ $0.isSelected ?? false }).first else {
            return
        }
        if selectedPaymentMethod.Symbol == "BNPL" { //Buy Now Pay later
            if Internet.isAvailable {
                if self.bnplData.count > 0 {
                    let type = self.bnplData[self.subOptionSelecedIndex].walletType
                    self.paymentDetailViewModel.createPreWallet(walletName: type.rawValue)
                }
            }
        } else if selectedPaymentMethod.Symbol == "MobPay" { //Mobile Payment
            
        } else if selectedPaymentMethod.Symbol == "C" {
            var height = UIScreen.main.bounds.height * 0.7
            if height < 400 {
                height = UIScreen.main.bounds.height * 0.9
            } else if height < 680 {
                height = 680.0
            }
            
            let vc = AddCardVC(nibName: "AddCardVC", bundle: EPGHelper.bundle!)
            vc.view.frame.size.width = UIScreen.main.bounds.width
            vc.view.frame.size.height = height
            vc.superController = self
            vc.paymentMethod = selectedPaymentMethod
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        } else {
            if EPGPayment.shared.isPrintMsgEnabled {
                print("No Option Selected \(selectedPaymentMethod.Symbol ?? "")")
            }
        }
    }
}

//MARK: - PaymentDetailDelegate
extension PaymentDetailVC: PaymentDetailDelegate {
    func paymentDetailDelegate(onSuccess paymentSuccess: Bool) {
        if EPGPayment.shared.isPrintMsgEnabled {
            print("paymentDetailDelegate(onSuccess: \(paymentSuccess)")
        }
        self.delegate?.epgPayment(delegate: EPGResult.get(with: nil, isSuccess: true))
        self.navigationController?.popViewController(animated: false)
    }
    
    func paymentDetailDelegate(otpVerifyFailed errorMessage: String?, isBackPressed: Bool) {
        if EPGPayment.shared.isPrintMsgEnabled {
            print("PaymentDetail: paymentDetailDelegate(otpVerifyFailed: \(isBackPressed)")
        }
        if isBackPressed {
            let cancelledResult = EPGResult(errorMessage: EPGConstant.shared.cancelled_by_user, success: false, transactionId: "", cancelledbyUser: true)
            self.delegate?.epgPayment(delegate: cancelledResult)
        } else {
            self.delegate?.epgPayment(delegate: EPGResult.get(with: EPGConstant.shared.otp_verification_failed, isSuccess: false))
        }
        self.navigationController?.popViewController(animated: false)
    }
    
    func paymentDetailDelegate(addCardFailed errorMessage: String?) {
        if EPGPayment.shared.isPrintMsgEnabled {
            print("PaymentDetail: paymentDetailDelegate(addCardFailed")
        }
        self.delegate?.epgPayment(delegate: EPGResult.get(with: EPGConstant.shared.add_card_failed, isSuccess: false))
        self.navigationController?.popViewController(animated: false)
    }
}

//MARK: - Initialise
extension PaymentDetailVC {
    func setupViewModel() {
        self.paymentDetailViewModel = PaymentDetailViewModel()
        self.setupColorVisibility()
        self.resetAllData()
        self.getPaymentDataWithValidation()
        self.setupCollectionView()
        self.paymentDetailViewModel.bindPaymentModelToController = {
            self.setPaymentDetails()
        }
        self.paymentDetailViewModel.bindWalletModelToController = {
            let isSuccess = self.paymentDetailViewModel.preWalletResponse?.transaction?.ResponseCode == "0"
            if isSuccess {
                let isRedirection = (self.paymentDetailViewModel.preWalletResponse?.transaction?.RedirectionRequired ?? "") == "true"
                if isRedirection {
                    let redirectionURL = self.paymentDetailViewModel.preWalletResponse?.transaction?.RedirectionURL ?? ""
                    
                    let vc = VerifyOTP(nibName: "VerifyOTP", bundle: EPGHelper.bundle)
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isWebRequest = true
                    vc.webURL = redirectionURL
                    vc.delegate = self
                    vc.superController = self
                    vc.headerTitle = ""
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if let redirectionURL = self.paymentDetailViewModel.preWalletResponse?.transaction?.ResponseParameters?.filter({ $0.name == "href" }).first?.value {
                    let vc = VerifyOTP(nibName: "VerifyOTP", bundle: EPGHelper.bundle)
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isWebRequest = true
                    vc.webURL = redirectionURL
                    vc.delegate = self
                    vc.superController = self
                    vc.headerTitle = ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                let message = self.paymentDetailViewModel.preWalletResponse?.transaction?.ResponseDescription ?? ""
                EPGHelper.showAlert(message: message) { isComplete in
                    if isComplete {
                        if Internet.isAvailable {
                            self.paymentDetailViewModel.cancelTransaction(completion: { isCancelled in
                                if EPGPayment.shared.isPrintMsgEnabled {
                                    print("PaymentDetail: epgPayment(delegate: EPGResult.get(with: \(message), isSuccess: false))")
                                }
                                self.delegate?.epgPayment(delegate: EPGResult.get(with: message, isSuccess: false))
                                self.navigationController?.popViewController(animated: false)
                            })
                        } else {
                            EPGHelper.showAlert(message: EPGConstant.shared.internet_connection)
                        }
                    }
                }
            }
        }
    }
    
    func setupColorVisibility() {
        self.scrollView.isHidden = true
        self.hdrLbl.font = UIFont.systemFont(ofSize: 24.0, weight: .semibold)
        self.hdrLbl.textColor = .white
        self.payBtn.alpha = 1.0
        self.payBtn.isUserInteractionEnabled = true
        
        self.view.backgroundColor = UIColor.mainBackground
        self.cardView.backgroundColor = UIColor.background
        self.cancelBtn.backgroundColor = .clear
        
        self.merchantView.backgroundColor = .systemBackground
        self.orderIdView.backgroundColor = .systemBackground
        self.pointsView.backgroundColor = .systemBackground
        self.amountView.backgroundColor = .systemBackground
        self.cancelBtn.setTitleColor(.lightGray, for: .normal)
    }
    
    func resetAllData() {
        self.merchantNameLbl.text = ""
        self.orderIdLbl.text = ""
        self.pointsLbl.text = ""
        self.amountLbl.text = ""
    }
}

//MARK: - Validate & Get Data
extension PaymentDetailVC {
    func setPaymentDetails() {
        guard let response = self.paymentDetailViewModel.paymentResponse else {
            EPGHelper.showAlert(message: EPGConstant.shared.authentication_failed) { isComplete in
                if isComplete {
                    self.navigationController?.popViewController(animated: false)
                }
            }
            return
        }
        self.scrollView.isHidden = false
        
        let paymentData = response.PaymentDataInApp
        let transaction = response.transaction
        
        guard paymentData?.ResponseCode == "0" && transaction?.ResponseCode == nil else {
            let msg = transaction?.ResponseDescription ?? (paymentData?.ResponseDescription ?? EPGConstant.shared.payment_data_not_available)
            EPGHelper.showAlert(message: msg) { isComplete in
                if isComplete {
                    if EPGPayment.shared.isPrintMsgEnabled {
                        print("PaymentDetail: epgPayment(delegate: EPGResult.get(with: \(msg), isSuccess: false))")
                    }
                    self.delegate?.epgPayment(delegate: EPGResult.get(with: msg, isSuccess: false))
                    self.navigationController?.popViewController(animated: false)
                }
            }
            return
        }
        var paymentMethods = (paymentData?.Instruments?.Instrument ?? []).filter({ $0.Symbol == "C"  })
        if paymentMethods.count > 0 {
            paymentMethods[0].isSelected = true
            paymentMethods[0].imageName = "card_ic"
           
            /*
            //MARK: -============== Mobile Payments ==============
            let walletsMP = paymentData?.PaymentWallets?.wallets ?? []
            self.mobilePaymentsData = []
            if let wallet = walletsMP.filter({ $0.walletType == .applePay }).first  {
                self.mobilePaymentsData.append(wallet)
            }
            if let wallet = walletsMP.filter({ $0.walletType == .samsungPay }).first  {
                self.mobilePaymentsData.append(wallet)
            }
            if let wallet = walletsMP.filter({ $0.walletType == .googlePay }).first  {
                self.mobilePaymentsData.append(wallet)
            }
            if self.mobilePaymentsData.count > 0 {
                let method = PaymentDataResponse.Instrument(name: "Mobile Payment", symbol: "MobPay", text: "Mobile Payment", brand: nil, imageName: "mobilePayment")
                paymentMethods.append(method)
            }
            */
            
            //MARK: -============== BPNL ==============
            let wallets = paymentData?.PaymentWallets?.wallets ?? []
            self.bnplData = []
            if let wallet = wallets.filter({ $0.walletType == .tabby }).first  {
                self.bnplData.append(wallet)
            }
            if let wallet = wallets.filter({ $0.walletType == .postPay }).first  {
                self.bnplData.append(wallet)
            }
            if let wallet = wallets.filter({ $0.walletType == .tamara }).first  {
                self.bnplData.append(wallet)
            }
            if self.bnplData.count > 0 {
                let text = LocalizationSystem.shared.isArabicActive ? "اشتر الآن وادفع لاحقًا" : "Buy Now Pay Later"
                let method = PaymentDataResponse.Instrument(name: "Buy Now Pay Later", symbol: "BNPL", text: text, brand: nil, imageName: "bnpl")
                paymentMethods.append(method)
            }
            /*
            //MARK: -============== UAEPGS ==============
            let methodUAEPGS = PaymentDataResponse.Instrument(name: "UAEPGS", symbol: "UAEPGS", text: "UAEPGS", brand: nil, imageName: "")
            paymentMethods.append(methodUAEPGS)
            */
        }
        self.paymentMethods = paymentMethods
        self.paymentMethodCV.reloadData()
        
        EPGPayment.shared.currency = paymentData?.Transaction?.Currency ?? "AED"
        EPGPayment.shared.amount   = paymentData?.Transaction?.Amount?.Value ?? "0.0"
        
        self.amountLbl.text         = paymentData?.Transaction?.Amount?.Printable ?? "0.0"
        self.orderIdLbl.text        = "#" + (paymentData?.Transaction?.OrderID ?? "0.0")
        self.merchantNameLbl.text   = paymentData?.Merchant?.Name ?? ""
        self.pointsLbl.text         = paymentData?.Transaction?.OrderName ?? ""
        self.merchantLogo.image     = EPGHelper.convertBase64StringToImage(imageBase64String: paymentData?.Merchant?.Logo ?? "")
        self.merchantLogo2.image     = EPGHelper.convertBase64StringToImage(imageBase64String: paymentData?.Merchant?.Logo ?? "")
    }
    
    func getPaymentDataWithValidation() {
        let validateErrorString = EPGPayment.shared.validate()
        guard validateErrorString == nil else {
            EPGHelper.showAlert(message: validateErrorString ?? "Failed") { isComplete in
                if EPGPayment.shared.isPrintMsgEnabled {
                    print("PaymentDetail: epgPayment(delegate: EPGResult.get(with: \(validateErrorString ?? "Failed"), isSuccess: false))")
                }
                self.delegate?.epgPayment(delegate: EPGResult.get(with: validateErrorString ?? "Failed", isSuccess: false))
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        if Internet.isAvailable {
            self.paymentDetailViewModel.getPaymentData()
        } else {
            self.navigationController?.popViewController(animated: true)
            EPGHelper.showAlert(message: EPGConstant.shared.internet_connection)
        }
    }
}

//
//  NewAddCardVC.swift
//  EPG
//

import UIKit

class NewAddCardVC: BottomPopupViewController {

    // MARK: - Properties
    var backBtn: UIButton            = UIButton(type: .system)
    var scrollView: UIScrollView     = UIScrollView()
    var shadowView: UIView           = UIView()
    var outerCardView: UIView        = UIView()
    var hdrLbl: UILabel              = UILabel()

    var cardNoView: UIView           = UIView()
    var cardNoTypeIV: UIImageView    = UIImageView()
    var cardNoTF: TextFieldFormatter = TextFieldFormatter()
    var cardNoIconIV: UIImageView    = UIImageView()
    var cardNoValidateStatusLbl: UILabel = UILabel()

    var expiryView: UIView           = UIView()
    var expiryIV: UIImageView        = UIImageView()
    var expiryTF: UITextField        = UITextField()
    var expiryDateStatusLbl: UILabel = UILabel()

    var cvvView: UIView              = UIView()
    var cvvIV: UIImageView           = UIImageView()
    var cvvInfoIV: UIImageView       = UIImageView()
    var cvvTF: UITextField           = UITextField()
    var cvvStatusLbl: UILabel        = UILabel()
    var expiryCvvSeperateLbl: UILabel = UILabel()

    var confirmBtn: UIButton         = UIButton(type: .system)

    var entryCardView: UIView        = UIView()
    var cardInfoView: UIView         = UIView()
    var cardSKHolderNameLbl: UILabel = UILabel()
    var cardSKValidStackView: UIStackView = UIStackView()
    var cardSKValidFixedLbl: UILabel = UILabel()
    var cardSKValidLbl: UILabel      = UILabel()
    var cardSKCardNoLbl: UILabel     = UILabel()
    var cardSKTypeBackView: UIView   = UIView()
    var cardSKTypeIV: UIImageView    = UIImageView()
    var backCardView: UIView         = UIView()
    var cardSKCVVLbl: UILabel        = UILabel()
    var cvvDetailMainView: UIView    = UIView()
    var entryCardStackView: UIStackView = UIStackView()
    var cvvExpiryStackView: UIStackView = UIStackView()

    private var acceptedCardsStack   = UIStackView()
    private var pciBadgeStack        = UIStackView()
    private var bottomBar            = UIView()
    private var totalFixedLbl        = UILabel()
    private var amountLbl            = UILabel()
    private var vatLbl               = UILabel()
    private var smilesBanner         = UIView()
    private var smilesBannerLbl      = UILabel()
    private var smilesBannerHeight: NSLayoutConstraint?

    var totalAmount: String = ""
    var vatText: String     = ""
    var smilesInfo: String  = ""

    private let cardGradientLayer    = CAGradientLayer()

    var showingFront    = true
    var addCardViewModel: AddCardViewModel!
    var paymentMethod:  PaymentDataResponse.Instrument?
    var superController: PaymentDetailVC?
    var delegate:       PaymentDetailDelegate?
    var isSDKEnabled:   Bool = false
    private var isCVVVisible = false

    var isRecurrencePayment: Bool = false {
        didSet { EPGLogger.recurrence("isRecurrencePayment set to: \(isRecurrencePayment)") }
    }
    var paymentDataResponse: PaymentDataResponse.PaymentData? {
        didSet {
            EPGLogger.recurrence("paymentDataResponse received")
            EPGLogger.recurrence("  CardMask: \(String(describing: paymentDataResponse?.Transaction?.CardMask))")
        }
    }
    private var pendingIsRecurrencePayment: Bool?
    private var pendingPaymentDataResponse: PaymentDataResponse.PaymentData?

    private let pad: CGFloat         = 20
    private let fieldH: CGFloat      = 64
    private let fieldCorner: CGFloat = 10
    private let cp: CGFloat          = 10

    // MARK: - configureForRecurrence
    func configureForRecurrence(isRecurrencePayment: Bool, paymentDataResponse: PaymentDataResponse.PaymentData?) {
        self.pendingIsRecurrencePayment = isRecurrencePayment
        self.pendingPaymentDataResponse = paymentDataResponse
        self.isRecurrencePayment        = isRecurrencePayment
        self.paymentDataResponse        = paymentDataResponse
        EPGLogger.recurrence("configureForRecurrence called — isRecurrencePayment: \(isRecurrencePayment)")
        if self.isViewLoaded {
            self.configureRecurrenceUI()
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let pending = pendingIsRecurrencePayment { self.isRecurrencePayment = pending }
        if let data    = pendingPaymentDataResponse  { self.paymentDataResponse  = data }

        buildUI()
        setLocalization()
        setupBlurView()
        cvvDetailMainView.isHidden = true
        setupViewModel()
        configureRecurrenceUI()

        EPGLogger.debug("Smiles smilesInfo received: '\(smilesInfo)'")
        if !smilesInfo.isEmpty {
            configureSmilesPointsBanner(info: smilesInfo)
        } else {
            EPGLogger.debug("Smiles smilesInfo is empty — banner will stay hidden")
        }

        if LocalizationSystem.shared.isArabicActive {
            cardSKValidStackView.flip(); cardSKValidFixedLbl.flip(); cardSKValidLbl.flip()
            cardSKTypeBackView.flip(); cardSKTypeIV.flip()
            cardNoView.flip(); cardNoTypeIV.flip(); cardNoTF.flip()
            cvvExpiryStackView.flip(); expiryTF.flip(); cvvTF.flip(); cvvIV.flip()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardGradientLayer.frame        = cardInfoView.bounds
        cardInfoView.layer.cornerRadius = 16; cardInfoView.clipsToBounds = true
        backCardView.layer.cornerRadius = 16; backCardView.clipsToBounds = true

        let tfCorner:   CGFloat = (selectedTheme == .theme2) ? 0 : fieldCorner
        let cardCorner: CGFloat = (selectedTheme == .theme2) ? 0 : 20

        outerCardView.layer.maskedCorners    = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        outerCardView.layer.cornerRadius     = cardCorner
        cvvDetailMainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cvvDetailMainView.layer.cornerRadius  = cardCorner
        cvvDetailMainView.layer.masksToBounds = true
        cardNoView.layer.cornerRadius        = tfCorner
        expiryView.layer.cornerRadius        = tfCorner
        cvvView.layer.cornerRadius           = tfCorner
        entryCardView.layer.cornerRadius     = cardCorner
        if confirmBtn.isEnabled {
            confirmBtn.backgroundColor = UIColor(red: 0.85, green: 0.12, blue: 0.12, alpha: 1)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
        scrollView.isScrollEnabled = UIScreen.main.bounds.height * 0.7 < 680
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
    }

    override var popupHeight: CGFloat {
        var h = UIScreen.main.bounds.height * 0.7
        if h < 400 { h = UIScreen.main.bounds.height * 0.9 }
        else if h < 680 { return 680 }
        return h
    }
    override var popupTopCornerRadius: CGFloat { (selectedTheme == .theme2) ? 0 : 20 }

    // MARK: - Build UI
    private func buildUI() {
        view.backgroundColor = .clear

        outerCardView.backgroundColor = .systemBackground
        outerCardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(outerCardView)

        let drag = UIView()
        drag.backgroundColor = UIColor.systemGray4
        drag.layer.cornerRadius = 2.5
        drag.translatesAutoresizingMaskIntoConstraints = false
        outerCardView.addSubview(drag)

        // X button — white bg, radius 5
        backBtn.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)), for: .normal)
        backBtn.tintColor = .label
        backBtn.backgroundColor = .white
        backBtn.layer.cornerRadius = 5
        backBtn.clipsToBounds = true
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.addTarget(self, action: #selector(onClickBackBtn(_:)), for: .touchUpInside)
        outerCardView.addSubview(backBtn)

        hdrLbl.font = .systemFont(ofSize: 20, weight: .bold)
        hdrLbl.textColor = .label
        hdrLbl.translatesAutoresizingMaskIntoConstraints = false
        outerCardView.addSubview(hdrLbl)

        // No visible divider
        let headerDivider = UIView()
        headerDivider.backgroundColor = .clear
        headerDivider.translatesAutoresizingMaskIntoConstraints = false
        outerCardView.addSubview(headerDivider)

        shadowView.backgroundColor = .systemBackground
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        outerCardView.addSubview(shadowView)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.addSubview(scrollView)

        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)

        // White card container
        let cardContainer = UIView()
        cardContainer.backgroundColor     = .systemBackground
        cardContainer.layer.cornerRadius  = 16
        cardContainer.layer.shadowColor   = UIColor.black.cgColor
        cardContainer.layer.shadowOpacity = 0.08
        cardContainer.layer.shadowRadius  = 12
        cardContainer.layer.shadowOffset  = CGSize(width: 0, height: 2)
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(cardContainer)

        // Card preview
        entryCardView.backgroundColor = .systemBackground
        entryCardView.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(entryCardView)
        buildCardPreview(in: entryCardView)

        // Fields
        buildCardNumberField(in: cardContainer)
        buildExpiryAndCVVRow(in: cardContainer)

        // Validation labels
        for lbl in [cardNoValidateStatusLbl, expiryCvvSeperateLbl, expiryDateStatusLbl, cvvStatusLbl] {
            lbl.font = .systemFont(ofSize: 11)
            lbl.textColor = .systemRed
            lbl.isHidden = true
            lbl.translatesAutoresizingMaskIntoConstraints = false
            cardContainer.addSubview(lbl)
        }

        // Accepted cards (inside white card)
        buildAcceptedCardsRow(in: cardContainer)

        // PCI badge (outside white card, in grey content)
        buildPCIBadge(in: content)

        buildCVVDetailView()
        buildSmilesBanner(in: content)
        buildBottomBar(in: content)

        // MARK: - Constraints
        NSLayoutConstraint.activate([
            outerCardView.topAnchor.constraint(equalTo: view.topAnchor),
            outerCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            outerCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            outerCardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            drag.topAnchor.constraint(equalTo: outerCardView.topAnchor, constant: 10),
            drag.centerXAnchor.constraint(equalTo: outerCardView.centerXAnchor),
            drag.widthAnchor.constraint(equalToConstant: 36),
            drag.heightAnchor.constraint(equalToConstant: 5),

            hdrLbl.topAnchor.constraint(equalTo: drag.bottomAnchor),
            hdrLbl.leadingAnchor.constraint(equalTo: outerCardView.leadingAnchor, constant: pad),
            hdrLbl.trailingAnchor.constraint(lessThanOrEqualTo: backBtn.leadingAnchor, constant: -8),
            hdrLbl.heightAnchor.constraint(equalToConstant: 56),

            backBtn.centerYAnchor.constraint(equalTo: hdrLbl.centerYAnchor),
            backBtn.trailingAnchor.constraint(equalTo: outerCardView.trailingAnchor, constant: -pad),
            backBtn.widthAnchor.constraint(equalToConstant: 36),
            backBtn.heightAnchor.constraint(equalToConstant: 36),

            headerDivider.topAnchor.constraint(equalTo: hdrLbl.bottomAnchor),
            headerDivider.leadingAnchor.constraint(equalTo: outerCardView.leadingAnchor),
            headerDivider.trailingAnchor.constraint(equalTo: outerCardView.trailingAnchor),
            headerDivider.heightAnchor.constraint(equalToConstant: 0),

            shadowView.topAnchor.constraint(equalTo: headerDivider.bottomAnchor),
            shadowView.leadingAnchor.constraint(equalTo: outerCardView.leadingAnchor),
            shadowView.trailingAnchor.constraint(equalTo: outerCardView.trailingAnchor),
            shadowView.bottomAnchor.constraint(equalTo: outerCardView.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: shadowView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor),

            content.topAnchor.constraint(equalTo: scrollView.topAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            cardContainer.topAnchor.constraint(equalTo: content.topAnchor, constant: 12),
            cardContainer.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 10),
            cardContainer.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -10),

            entryCardView.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: cp),
            entryCardView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: cp),
            entryCardView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -cp),
            entryCardView.heightAnchor.constraint(equalTo: entryCardView.widthAnchor, multiplier: 0.58),

            cardNoView.topAnchor.constraint(equalTo: entryCardView.bottomAnchor, constant: 12),
            cardNoView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: cp),
            cardNoView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -cp),
            cardNoView.heightAnchor.constraint(equalToConstant: fieldH),

            cardNoValidateStatusLbl.topAnchor.constraint(equalTo: cardNoView.bottomAnchor, constant: 3),
            cardNoValidateStatusLbl.leadingAnchor.constraint(equalTo: cardNoView.leadingAnchor, constant: 4),

            cvvExpiryStackView.topAnchor.constraint(equalTo: cardNoValidateStatusLbl.bottomAnchor, constant: 6),
            cvvExpiryStackView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: cp),
            cvvExpiryStackView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -cp),
            cvvExpiryStackView.heightAnchor.constraint(equalToConstant: fieldH),

            expiryDateStatusLbl.topAnchor.constraint(equalTo: cvvExpiryStackView.bottomAnchor, constant: 3),
            expiryDateStatusLbl.leadingAnchor.constraint(equalTo: cvvExpiryStackView.leadingAnchor, constant: 4),

            cvvStatusLbl.topAnchor.constraint(equalTo: cvvExpiryStackView.bottomAnchor, constant: 3),
            cvvStatusLbl.leadingAnchor.constraint(equalTo: cvvExpiryStackView.centerXAnchor, constant: 14),

            expiryCvvSeperateLbl.topAnchor.constraint(equalTo: cvvExpiryStackView.bottomAnchor, constant: 3),
            expiryCvvSeperateLbl.leadingAnchor.constraint(equalTo: cvvExpiryStackView.leadingAnchor, constant: 4),

            // hint label below cvvExpiryStackView
            cvvHintLbl.topAnchor.constraint(equalTo: cvvExpiryStackView.bottomAnchor, constant: 4),
            cvvHintLbl.leadingAnchor.constraint(equalTo: cvvExpiryStackView.centerXAnchor, constant: 10),
            cvvHintLbl.trailingAnchor.constraint(equalTo: cvvExpiryStackView.trailingAnchor),

            // divider above accepted cards
            cardDivider.topAnchor.constraint(equalTo: cvvHintLbl.bottomAnchor, constant: 12),
            cardDivider.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 10),
            cardDivider.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -10),
            cardDivider.heightAnchor.constraint(equalToConstant: 1),

            // accepted cards
            acceptedCardsStack.topAnchor.constraint(equalTo: cardDivider.bottomAnchor, constant: 12),
            acceptedCardsStack.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor),
            acceptedCardsStack.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: -cp),

            // PCI outside white card
            pciBadgeStack.topAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: 12),
            pciBadgeStack.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            pciBadgeStack.leadingAnchor.constraint(greaterThanOrEqualTo: content.leadingAnchor, constant: pad),
            pciBadgeStack.trailingAnchor.constraint(lessThanOrEqualTo: content.trailingAnchor, constant: -pad),
        ])
    }

    // Store refs for constraints set in buildUI
    private var cvvHintLbl  = UILabel()
    private var cardDivider = UIView()

    // MARK: - Card Preview
    private func buildCardPreview(in parent: UIView) {
        cardInfoView.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(cardInfoView)

        if let img = UIImage(named: "card_front", in: EPGHelper.bundle, with: nil) ?? UIImage(named: "card_front") {
            let iv = UIImageView(image: img)
            iv.contentMode = .scaleAspectFill; iv.clipsToBounds = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            cardInfoView.insertSubview(iv, at: 0)
            NSLayoutConstraint.activate([
                iv.topAnchor.constraint(equalTo: cardInfoView.topAnchor),
                iv.leadingAnchor.constraint(equalTo: cardInfoView.leadingAnchor),
                iv.trailingAnchor.constraint(equalTo: cardInfoView.trailingAnchor),
                iv.bottomAnchor.constraint(equalTo: cardInfoView.bottomAnchor),
            ])
        } else {
            cardGradientLayer.colors = [
                UIColor(red: 0.85, green: 0.15, blue: 0.12, alpha: 1).cgColor,
                UIColor(red: 1.0,  green: 0.55, blue: 0.50, alpha: 1).cgColor,
                UIColor(red: 1.0,  green: 0.82, blue: 0.80, alpha: 1).cgColor
            ]
            cardGradientLayer.locations   = [0.0, 0.55, 1.0]
            cardGradientLayer.startPoint  = CGPoint(x: 0, y: 1)
            cardGradientLayer.endPoint    = CGPoint(x: 1, y: 0)
            cardInfoView.layer.insertSublayer(cardGradientLayer, at: 0)
        }

        cardSKValidStackView.axis = .vertical; cardSKValidStackView.alignment = .leading; cardSKValidStackView.spacing = 1
        cardSKValidStackView.translatesAutoresizingMaskIntoConstraints = false
        cardInfoView.addSubview(cardSKValidStackView)

        cardSKValidFixedLbl.font = .systemFont(ofSize: 8, weight: .medium)
        cardSKValidFixedLbl.textColor = UIColor.white.withAlphaComponent(0.75)
        cardSKValidStackView.addArrangedSubview(cardSKValidFixedLbl)

        cardSKValidLbl.font = .systemFont(ofSize: 13, weight: .semibold)
        cardSKValidLbl.textColor = .white
        cardSKValidStackView.addArrangedSubview(cardSKValidLbl)

        cardSKTypeBackView.translatesAutoresizingMaskIntoConstraints = false
        cardInfoView.addSubview(cardSKTypeBackView)
        cardSKTypeIV.contentMode = .scaleAspectFit
        cardSKTypeIV.image = makeMastercardLogo()
        cardSKTypeIV.translatesAutoresizingMaskIntoConstraints = false
        cardSKTypeBackView.addSubview(cardSKTypeIV)

        cardSKCardNoLbl.font = .monospacedSystemFont(ofSize: 20, weight: .bold)
        cardSKCardNoLbl.textColor = .white
        cardSKCardNoLbl.translatesAutoresizingMaskIntoConstraints = false
        cardInfoView.addSubview(cardSKCardNoLbl)

        cardSKHolderNameLbl.isHidden = true
        cardSKHolderNameLbl.translatesAutoresizingMaskIntoConstraints = false
        cardInfoView.addSubview(cardSKHolderNameLbl)

        // Back face
        backCardView.backgroundColor = .clear
        backCardView.layer.cornerRadius = 16; backCardView.clipsToBounds = true
        backCardView.isHidden = true
        backCardView.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(backCardView)

        if let backImg = UIImage(named: "card_back", in: EPGHelper.bundle, with: nil) ?? UIImage(named: "card_back") {
            let biv = UIImageView(image: backImg)
            biv.contentMode = .scaleAspectFill; biv.clipsToBounds = true
            biv.translatesAutoresizingMaskIntoConstraints = false
            backCardView.insertSubview(biv, at: 0)
            NSLayoutConstraint.activate([
                biv.topAnchor.constraint(equalTo: backCardView.topAnchor),
                biv.leadingAnchor.constraint(equalTo: backCardView.leadingAnchor),
                biv.trailingAnchor.constraint(equalTo: backCardView.trailingAnchor),
                biv.bottomAnchor.constraint(equalTo: backCardView.bottomAnchor),
            ])
        }

        let stripe = UIView(); stripe.backgroundColor = UIColor(white: 0.1, alpha: 0.85)
        stripe.translatesAutoresizingMaskIntoConstraints = false; backCardView.addSubview(stripe)

        let sigStrip = UIView(); sigStrip.backgroundColor = .white
        sigStrip.translatesAutoresizingMaskIntoConstraints = false; backCardView.addSubview(sigStrip)

        let hatchView = UIView(); hatchView.backgroundColor = UIColor.systemGray5
        hatchView.translatesAutoresizingMaskIntoConstraints = false; sigStrip.addSubview(hatchView)

        cardSKCVVLbl.font = .monospacedSystemFont(ofSize: 16, weight: .semibold)
        cardSKCVVLbl.textColor = .darkText; cardSKCVVLbl.textAlignment = .right
        cardSKCVVLbl.translatesAutoresizingMaskIntoConstraints = false; sigStrip.addSubview(cardSKCVVLbl)

        let backLogo = UIImageView(); backLogo.image = nil; backLogo.isHidden = true
        backLogo.contentMode = .scaleAspectFit; backLogo.tag = 9902
        backLogo.translatesAutoresizingMaskIntoConstraints = false; backCardView.addSubview(backLogo)

        NSLayoutConstraint.activate([
            cardInfoView.topAnchor.constraint(equalTo: parent.topAnchor),
            cardInfoView.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            cardInfoView.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            cardInfoView.bottomAnchor.constraint(equalTo: parent.bottomAnchor),

            cardSKValidStackView.topAnchor.constraint(equalTo: cardInfoView.topAnchor, constant: 18),
            cardSKValidStackView.leadingAnchor.constraint(equalTo: cardInfoView.leadingAnchor, constant: 18),

            cardSKTypeBackView.topAnchor.constraint(equalTo: cardInfoView.topAnchor, constant: 16),
            cardSKTypeBackView.trailingAnchor.constraint(equalTo: cardInfoView.trailingAnchor, constant: -20),
            cardSKTypeBackView.widthAnchor.constraint(equalToConstant: 54),
            cardSKTypeBackView.heightAnchor.constraint(equalToConstant: 34),

            cardSKTypeIV.topAnchor.constraint(equalTo: cardSKTypeBackView.topAnchor),
            cardSKTypeIV.leadingAnchor.constraint(equalTo: cardSKTypeBackView.leadingAnchor),
            cardSKTypeIV.trailingAnchor.constraint(equalTo: cardSKTypeBackView.trailingAnchor),
            cardSKTypeIV.bottomAnchor.constraint(equalTo: cardSKTypeBackView.bottomAnchor),

            cardSKCardNoLbl.bottomAnchor.constraint(equalTo: cardInfoView.bottomAnchor, constant: -18),
            cardSKCardNoLbl.leadingAnchor.constraint(equalTo: cardInfoView.leadingAnchor, constant: 20),
            cardSKCardNoLbl.trailingAnchor.constraint(equalTo: cardInfoView.trailingAnchor, constant: -20),

            backCardView.topAnchor.constraint(equalTo: parent.topAnchor),
            backCardView.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            backCardView.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            backCardView.bottomAnchor.constraint(equalTo: parent.bottomAnchor),

            stripe.topAnchor.constraint(equalTo: backCardView.topAnchor, constant: 28),
            stripe.leadingAnchor.constraint(equalTo: backCardView.leadingAnchor),
            stripe.trailingAnchor.constraint(equalTo: backCardView.trailingAnchor),
            stripe.heightAnchor.constraint(equalToConstant: 46),

            sigStrip.centerYAnchor.constraint(equalTo: backCardView.centerYAnchor, constant: 10),
            sigStrip.leadingAnchor.constraint(equalTo: backCardView.leadingAnchor, constant: 20),
            sigStrip.trailingAnchor.constraint(equalTo: backCardView.trailingAnchor, constant: -20),
            sigStrip.heightAnchor.constraint(equalToConstant: 44),

            hatchView.topAnchor.constraint(equalTo: sigStrip.topAnchor),
            hatchView.bottomAnchor.constraint(equalTo: sigStrip.bottomAnchor),
            hatchView.leadingAnchor.constraint(equalTo: sigStrip.leadingAnchor),
            hatchView.widthAnchor.constraint(equalTo: sigStrip.widthAnchor, multiplier: 0.72),

            cardSKCVVLbl.centerYAnchor.constraint(equalTo: sigStrip.centerYAnchor),
            cardSKCVVLbl.trailingAnchor.constraint(equalTo: sigStrip.trailingAnchor, constant: -10),
            cardSKCVVLbl.leadingAnchor.constraint(equalTo: hatchView.trailingAnchor, constant: 6),

            backLogo.bottomAnchor.constraint(equalTo: backCardView.bottomAnchor, constant: -16),
            backLogo.trailingAnchor.constraint(equalTo: backCardView.trailingAnchor, constant: -16),
            backLogo.widthAnchor.constraint(equalToConstant: 54),
            backLogo.heightAnchor.constraint(equalToConstant: 34),
        ])
    }

    // MARK: - Card number field
    private func buildCardNumberField(in parent: UIView) {
        cardNoView.backgroundColor    = UIColor.systemGray6
        cardNoView.layer.cornerRadius = fieldCorner; cardNoView.clipsToBounds = true
        cardNoView.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(cardNoView)
        cardNoIconIV.isHidden = true; cardNoTypeIV.isHidden = true

        let floatLbl = UILabel()
        floatLbl.text = "Card number"; floatLbl.font = .systemFont(ofSize: 16)
        floatLbl.textColor = .placeholderText; floatLbl.tag = 9910
        floatLbl.translatesAutoresizingMaskIntoConstraints = false
        cardNoView.addSubview(floatLbl)

        cardNoTF.borderStyle = .none; cardNoTF.font = .systemFont(ofSize: 16)
        cardNoTF.placeholder = ""; cardNoTF.keyboardType = .numberPad
        cardNoTF.translatesAutoresizingMaskIntoConstraints = false
        cardNoView.addSubview(cardNoTF)

        NSLayoutConstraint.activate([
            // Float label — starts centered, animates to top on focus
            floatLbl.leadingAnchor.constraint(equalTo: cardNoView.leadingAnchor, constant: 14),
            floatLbl.trailingAnchor.constraint(equalTo: cardNoView.trailingAnchor, constant: -14),
            floatLbl.centerYAnchor.constraint(equalTo: cardNoView.centerYAnchor),
            // TF — bottom half of field, always left-aligned
            cardNoTF.leadingAnchor.constraint(equalTo: cardNoView.leadingAnchor, constant: 14),
            cardNoTF.trailingAnchor.constraint(equalTo: cardNoView.trailingAnchor, constant: -14),
            cardNoTF.bottomAnchor.constraint(equalTo: cardNoView.bottomAnchor, constant: -10),
            cardNoTF.heightAnchor.constraint(equalToConstant: 22),
        ])

        cardNoTF.addTarget(self, action: #selector(animateCardNoFloat(_:)), for: .editingDidBegin)
        cardNoTF.addTarget(self, action: #selector(animateCardNoFloat(_:)), for: .editingDidEnd)
        cardNoTF.addTarget(self, action: #selector(animateCardNoFloat(_:)), for: .editingChanged)
        cardNoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(focusCardNo)))
    }

    // MARK: - Expiry + CVV row
    private func buildExpiryAndCVVRow(in parent: UIView) {
        cvvExpiryStackView.axis = .horizontal; cvvExpiryStackView.distribution = .fillEqually
        cvvExpiryStackView.spacing = 10; cvvExpiryStackView.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(cvvExpiryStackView)

        // Expiry
        expiryView.backgroundColor = UIColor.systemGray6
        expiryView.layer.cornerRadius = fieldCorner; expiryView.clipsToBounds = true
        cvvExpiryStackView.addArrangedSubview(expiryView); expiryIV.isHidden = true

        let expiryFloat = UILabel()
        expiryFloat.text = "Expiry date"; expiryFloat.font = .systemFont(ofSize: 16)
        expiryFloat.textColor = .placeholderText; expiryFloat.tag = 9911
        expiryFloat.translatesAutoresizingMaskIntoConstraints = false
        expiryView.addSubview(expiryFloat)

        expiryTF.placeholder = ""; expiryTF.font = .systemFont(ofSize: 16)
        expiryTF.borderStyle = .none; expiryTF.keyboardType = .numberPad
        expiryTF.translatesAutoresizingMaskIntoConstraints = false
        expiryView.addSubview(expiryTF)

        NSLayoutConstraint.activate([
            expiryFloat.leadingAnchor.constraint(equalTo: expiryView.leadingAnchor, constant: 14),
            expiryFloat.trailingAnchor.constraint(equalTo: expiryView.trailingAnchor, constant: -8),
            expiryFloat.centerYAnchor.constraint(equalTo: expiryView.centerYAnchor),
            expiryTF.leadingAnchor.constraint(equalTo: expiryView.leadingAnchor, constant: 14),
            expiryTF.trailingAnchor.constraint(equalTo: expiryView.trailingAnchor, constant: -8),
            expiryTF.bottomAnchor.constraint(equalTo: expiryView.bottomAnchor, constant: -10),
            expiryTF.heightAnchor.constraint(equalToConstant: 22),
        ])
        expiryTF.addTarget(self, action: #selector(animateExpiryFloat(_:)), for: .editingDidBegin)
        expiryTF.addTarget(self, action: #selector(animateExpiryFloat(_:)), for: .editingDidEnd)
        expiryTF.addTarget(self, action: #selector(animateExpiryFloat(_:)), for: .editingChanged)
        expiryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(focusExpiry)))

        // CVV
        cvvView.backgroundColor = UIColor.systemGray6
        cvvView.layer.cornerRadius = fieldCorner; cvvView.clipsToBounds = true; cvvView.layer.borderWidth = 0
        cvvExpiryStackView.addArrangedSubview(cvvView); cvvIV.isHidden = true

        let cvvFloat = UILabel()
        cvvFloat.text = "CVV"; cvvFloat.font = .systemFont(ofSize: 16)
        cvvFloat.textColor = .placeholderText; cvvFloat.tag = 9912
        cvvFloat.translatesAutoresizingMaskIntoConstraints = false
        cvvView.addSubview(cvvFloat)

        cvvTF.placeholder = ""; cvvTF.font = .systemFont(ofSize: 16)
        cvvTF.borderStyle = .none; cvvTF.keyboardType = .numberPad; cvvTF.isSecureTextEntry = true
        cvvTF.translatesAutoresizingMaskIntoConstraints = false; cvvView.addSubview(cvvTF)

        cvvInfoIV.image = UIImage(systemName: "eye"); cvvInfoIV.tintColor = .secondaryLabel
        cvvInfoIV.contentMode = .scaleAspectFit; cvvInfoIV.isUserInteractionEnabled = true
        cvvInfoIV.translatesAutoresizingMaskIntoConstraints = false
        cvvInfoIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickCVVInfoBtn(_:))))
        cvvView.addSubview(cvvInfoIV)

        NSLayoutConstraint.activate([
            cvvFloat.leadingAnchor.constraint(equalTo: cvvView.leadingAnchor, constant: 14),
            cvvFloat.trailingAnchor.constraint(equalTo: cvvInfoIV.leadingAnchor, constant: -6),
            cvvFloat.centerYAnchor.constraint(equalTo: cvvView.centerYAnchor),
            cvvTF.leadingAnchor.constraint(equalTo: cvvView.leadingAnchor, constant: 14),
            cvvTF.trailingAnchor.constraint(equalTo: cvvInfoIV.leadingAnchor, constant: -6),
            cvvTF.bottomAnchor.constraint(equalTo: cvvView.bottomAnchor, constant: -10),
            cvvTF.heightAnchor.constraint(equalToConstant: 22),
            cvvInfoIV.trailingAnchor.constraint(equalTo: cvvView.trailingAnchor, constant: -12),
            cvvInfoIV.centerYAnchor.constraint(equalTo: cvvView.centerYAnchor),
            cvvInfoIV.widthAnchor.constraint(equalToConstant: 22),
            cvvInfoIV.heightAnchor.constraint(equalToConstant: 22),
        ])
        cvvTF.addTarget(self, action: #selector(animateCVVFloat(_:)), for: .editingDidBegin)
        cvvTF.addTarget(self, action: #selector(animateCVVFloat(_:)), for: .editingDidEnd)
        cvvTF.addTarget(self, action: #selector(animateCVVFloat(_:)), for: .editingChanged)
        cvvView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(focusCVV)))

        // "3 digit security code" hint — right aligned below CVV
        cvvHintLbl.text = "3 digit security code"
        cvvHintLbl.font = .systemFont(ofSize: 11); cvvHintLbl.textColor = .tertiaryLabel
        cvvHintLbl.textAlignment = .left
        cvvHintLbl.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(cvvHintLbl)
    }

    // MARK: - Accepted cards
    private func buildAcceptedCardsRow(in parent: UIView) {
        // Divider above accepted cards
        cardDivider.backgroundColor = UIColor.systemGray5
        cardDivider.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(cardDivider)

        acceptedCardsStack.axis = .horizontal; acceptedCardsStack.spacing = 8
        acceptedCardsStack.alignment = .center
        acceptedCardsStack.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(acceptedCardsStack)

        let lbl = UILabel(); lbl.text = "Accepted cards :"; lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .secondaryLabel; acceptedCardsStack.addArrangedSubview(lbl)

        for (img, w) in [(makeMastercardLogo(), 32), (makeVisaLogo(), 40), (makeAmexLogo(), 32)] as [(UIImage, CGFloat)] {
            let iv = UIImageView(image: img); iv.contentMode = .scaleAspectFit
            iv.widthAnchor.constraint(equalToConstant: w).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 22).isActive = true
            acceptedCardsStack.addArrangedSubview(iv)
        }
    }

    // MARK: - PCI Badge
    private func buildPCIBadge(in parent: UIView) {
        pciBadgeStack.axis = .horizontal; pciBadgeStack.spacing = 10; pciBadgeStack.alignment = .center
        pciBadgeStack.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(pciBadgeStack)

        let pciIV = UIImageView()
        pciIV.image = UIImage(named: "pci_dss", in: EPGHelper.bundle, with: nil) ?? UIImage(named: "pci_dss")
        pciIV.contentMode = .scaleAspectFit
        pciIV.widthAnchor.constraint(equalToConstant: 56).isActive = true
        pciIV.heightAnchor.constraint(equalToConstant: 36).isActive = true
        pciBadgeStack.addArrangedSubview(pciIV)

        let txt = UILabel()
        txt.text = "100% Secure Payment by e&\nenterprise Safe and Secure"
        txt.font = .systemFont(ofSize: 11); txt.textColor = .secondaryLabel
        txt.numberOfLines = 0; txt.lineBreakMode = .byWordWrapping; txt.textAlignment = .left
        txt.setContentCompressionResistancePriority(.required, for: .vertical)
        pciBadgeStack.addArrangedSubview(txt)
    }

    // MARK: - CVV Detail overlay
    private func buildCVVDetailView() {
        cvvDetailMainView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        cvvDetailMainView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cvvDetailMainView)

        let closeBtn2 = UIButton(type: .system)
        closeBtn2.setTitle("✕ Close", for: .normal); closeBtn2.setTitleColor(.white, for: .normal)
        closeBtn2.translatesAutoresizingMaskIntoConstraints = false
        closeBtn2.addTarget(self, action: #selector(onClickCVVDetailMainBtn(_:)), for: .touchUpInside)
        cvvDetailMainView.addSubview(closeBtn2)

        let msg = UILabel()
        msg.text = "CVV is the 3-digit security code\non the back of your card."
        msg.textColor = .white; msg.font = .systemFont(ofSize: 15); msg.numberOfLines = 0; msg.textAlignment = .center
        msg.translatesAutoresizingMaskIntoConstraints = false
        cvvDetailMainView.addSubview(msg)

        NSLayoutConstraint.activate([
            cvvDetailMainView.topAnchor.constraint(equalTo: view.topAnchor),
            cvvDetailMainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cvvDetailMainView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cvvDetailMainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            closeBtn2.topAnchor.constraint(equalTo: cvvDetailMainView.topAnchor, constant: 60),
            closeBtn2.trailingAnchor.constraint(equalTo: cvvDetailMainView.trailingAnchor, constant: -20),
            msg.centerXAnchor.constraint(equalTo: cvvDetailMainView.centerXAnchor),
            msg.centerYAnchor.constraint(equalTo: cvvDetailMainView.centerYAnchor),
            msg.leadingAnchor.constraint(equalTo: cvvDetailMainView.leadingAnchor, constant: 40),
            msg.trailingAnchor.constraint(equalTo: cvvDetailMainView.trailingAnchor, constant: -40),
        ])
    }

    // MARK: - Smiles Banner
    private func buildSmilesBanner(in parent: UIView) {
        smilesBanner.backgroundColor = UIColor(red: 0.85, green: 0.97, blue: 0.88, alpha: 1)
        smilesBanner.layer.cornerRadius = 12
        smilesBanner.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        smilesBanner.clipsToBounds = true; smilesBanner.isHidden = true
        smilesBanner.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(smilesBanner)

        let checkIV = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkIV.tintColor = UIColor(red: 0.10, green: 0.65, blue: 0.30, alpha: 1)
        checkIV.contentMode = .scaleAspectFit
        checkIV.widthAnchor.constraint(equalToConstant: 18).isActive = true
        checkIV.heightAnchor.constraint(equalToConstant: 18).isActive = true

        smilesBannerLbl.font = .systemFont(ofSize: 14, weight: .semibold)
        smilesBannerLbl.textColor = UIColor(red: 0.05, green: 0.45, blue: 0.20, alpha: 1)

        let stack = UIStackView(arrangedSubviews: [checkIV, smilesBannerLbl])
        stack.axis = .horizontal; stack.alignment = .center; stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        smilesBanner.addSubview(stack)

        NSLayoutConstraint.activate([
            smilesBanner.topAnchor.constraint(equalTo: pciBadgeStack.bottomAnchor, constant: 10),
            smilesBanner.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            smilesBanner.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            stack.centerXAnchor.constraint(equalTo: smilesBanner.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: smilesBanner.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: smilesBanner.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: smilesBanner.trailingAnchor, constant: -16),
        ])
        smilesBannerHeight = smilesBanner.heightAnchor.constraint(equalToConstant: 0)
        smilesBannerHeight?.isActive = true
    }

    func configureSmilesPointsBanner(info: String) {
        EPGLogger.debug("Smiles configureSmilesPointsBanner called with: '\(info)'")
        let regex = try? NSRegularExpression(pattern: #"^\d+ PTS$"#)
        let isMatch = regex?.firstMatch(in: info, range: NSRange(info.startIndex..., in: info)) != nil
        EPGLogger.debug("Smiles isMatch: \(isMatch) — banner: \(isMatch ? "SHOWN ✅" : "HIDDEN ❌")")
        smilesBannerHeight?.constant = isMatch ? 36 : 0
        smilesBanner.isHidden        = !isMatch
        smilesBannerLbl.text         = isMatch ? "\(info) Redeemed" : ""
        smilesBanner.superview?.layoutIfNeeded()
    }

    // MARK: - Bottom Bar
    private func buildBottomBar(in parent: UIView) {
        bottomBar.backgroundColor = .systemBackground
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(bottomBar)

        let div = UIView(); div.backgroundColor = UIColor.systemGray5
        div.translatesAutoresizingMaskIntoConstraints = false; bottomBar.addSubview(div)

        totalFixedLbl.text = "Total amount to pay"; totalFixedLbl.font = .systemFont(ofSize: 15, weight: .semibold)
        totalFixedLbl.textColor = .label; totalFixedLbl.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(totalFixedLbl)

        amountLbl.text = totalAmount.isEmpty ? EPGPayment.shared.amountToPayText ?? "" : totalAmount
        amountLbl.font = .systemFont(ofSize: 16, weight: .bold); amountLbl.textColor = .label
        amountLbl.textAlignment = .right; amountLbl.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(amountLbl)

        vatLbl.text = vatText.isEmpty ? "5% VAT incl." : vatText
        vatLbl.font = .systemFont(ofSize: 12); vatLbl.textColor = .secondaryLabel
        vatLbl.textAlignment = .right; vatLbl.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(vatLbl)

        confirmBtn.setTitle("Pay now", for: .normal)
        confirmBtn.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .disabled)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        confirmBtn.backgroundColor = UIColor.systemGray3
        confirmBtn.layer.cornerRadius = 26; confirmBtn.clipsToBounds = true; confirmBtn.isEnabled = false
        confirmBtn.translatesAutoresizingMaskIntoConstraints = false
        confirmBtn.addTarget(self, action: #selector(onClickConfirmBtn(_:)), for: .touchUpInside)
        bottomBar.addSubview(confirmBtn)

        NSLayoutConstraint.activate([
            bottomBar.topAnchor.constraint(equalTo: smilesBanner.bottomAnchor),
            bottomBar.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: parent.bottomAnchor),

            div.topAnchor.constraint(equalTo: bottomBar.topAnchor),
            div.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor),
            div.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor),
            div.heightAnchor.constraint(equalToConstant: 1),

            totalFixedLbl.topAnchor.constraint(equalTo: div.bottomAnchor, constant: 14),
            totalFixedLbl.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: pad),

            amountLbl.topAnchor.constraint(equalTo: totalFixedLbl.topAnchor),
            amountLbl.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -pad),
            amountLbl.leadingAnchor.constraint(greaterThanOrEqualTo: totalFixedLbl.trailingAnchor, constant: 8),

            vatLbl.topAnchor.constraint(equalTo: amountLbl.bottomAnchor, constant: 2),
            vatLbl.trailingAnchor.constraint(equalTo: amountLbl.trailingAnchor),

            confirmBtn.topAnchor.constraint(equalTo: vatLbl.bottomAnchor, constant: 10),
            confirmBtn.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: pad),
            confirmBtn.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -pad),
            confirmBtn.heightAnchor.constraint(equalToConstant: 52),
            confirmBtn.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor),
        ])
    }

    @objc private func keyboardWillShow(_ n: Notification) {}
    @objc private func keyboardWillHide(_ n: Notification) {}

    // MARK: - Float animations
    @objc private func focusCardNo()  { cardNoTF.becomeFirstResponder() }
    @objc private func focusExpiry()  { expiryTF.becomeFirstResponder() }
    @objc private func focusCVV()     { cvvTF.becomeFirstResponder() }

    @objc private func animateCardNoFloat(_ sender: UITextField) {
        guard let lbl = cardNoView.viewWithTag(9910) as? UILabel else { return }
        animateFloat(lbl: lbl, tf: sender)
    }
    @objc private func animateExpiryFloat(_ sender: UITextField) {
        guard let lbl = expiryView.viewWithTag(9911) as? UILabel else { return }
        animateFloat(lbl: lbl, tf: sender)
    }
    @objc private func animateCVVFloat(_ sender: UITextField) {
        guard let lbl = cvvView.viewWithTag(9912) as? UILabel else { return }
        animateFloat(lbl: lbl, tf: sender)
    }
    private func animateFloat(lbl: UILabel, tf: UITextField) {
        let shouldFloat = tf.isFirstResponder || !(tf.text?.isEmpty ?? true)
        UIView.animate(withDuration: 0.2) {
            if shouldFloat {
                // Scale 0.75 from left edge — compensate X shift caused by center-based scaling
                // When scaling 0.75x from center, label shifts right by (width * 0.125)
                // Negate that shift so left edge stays at same X as textfield
                let scaleX: CGFloat = 0.75
                let offsetX = lbl.bounds.width * (1 - scaleX) / 2  // compensate center-scale drift
                lbl.transform = CGAffineTransform(translationX: -offsetX, y: -14)
                    .scaledBy(x: scaleX, y: scaleX)
                lbl.textColor = .secondaryLabel
            } else {
                lbl.transform = .identity
                lbl.textColor = .placeholderText
            }
        }
    }

    // MARK: - Pay button state
    private func updatePayButtonState() {
        if isRecurrencePayment {
            setPayButtonEnabled((cvvTF.text?.count ?? 0) >= 3)
        } else {
            let cardOk   = (cardNoTF.text?.replacingOccurrences(of: " ", with: "").count ?? 0) >= 15
            let expiryOk = (expiryTF.text?.count ?? 0) == 5
            let cvvOk    = (cvvTF.text?.count ?? 0) >= 3
            let noErrors = cardNoValidateStatusLbl.isHidden && expiryDateStatusLbl.isHidden && cvvStatusLbl.isHidden
            setPayButtonEnabled(cardOk && expiryOk && cvvOk && noErrors)
        }
    }
    private func setPayButtonEnabled(_ enabled: Bool) {
        confirmBtn.isEnabled = enabled; confirmBtn.isUserInteractionEnabled = enabled; confirmBtn.alpha = 1.0
        confirmBtn.backgroundColor = enabled ? UIColor(red: 0.85, green: 0.12, blue: 0.12, alpha: 1) : UIColor.systemGray3
    }

    // MARK: - Logo helpers
    func makeMastercardLogo() -> UIImage {
        let size = CGSize(width: 40, height: 26)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor(red: 0.93, green: 0.18, blue: 0.18, alpha: 1).setFill()
        UIBezierPath(ovalIn: CGRect(x: 0, y: 2, width: 22, height: 22)).fill()
        UIColor(red: 1.0, green: 0.60, blue: 0.0, alpha: 1).setFill()
        UIBezierPath(ovalIn: CGRect(x: 14, y: 2, width: 22, height: 22)).fill()
        UIColor(red: 1.0, green: 0.40, blue: 0.0, alpha: 0.65).setFill()
        let ov = UIBezierPath()
        ov.addArc(withCenter: CGPoint(x: 11, y: 13), radius: 11, startAngle: -0.8, endAngle: 0.8, clockwise: true)
        ov.addArc(withCenter: CGPoint(x: 25, y: 13), radius: 11, startAngle: .pi - 0.8, endAngle: .pi + 0.8, clockwise: false)
        ov.fill()
        let img = UIGraphicsGetImageFromCurrentImageContext()!; UIGraphicsEndImageContext(); return img
    }
    func makeVisaLogo() -> UIImage {
        let size = CGSize(width: 48, height: 18)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        "VISA".draw(in: CGRect(x: 2, y: 0, width: 44, height: 18), withAttributes: [.font: UIFont.systemFont(ofSize: 16, weight: .bold), .foregroundColor: UIColor(red: 0.1, green: 0.2, blue: 0.6, alpha: 1)])
        let img = UIGraphicsGetImageFromCurrentImageContext()!; UIGraphicsEndImageContext(); return img
    }
    func makeAmexLogo() -> UIImage {
        let size = CGSize(width: 36, height: 22)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor(red: 0.1, green: 0.45, blue: 0.75, alpha: 1).setFill()
        UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 36, height: 22), cornerRadius: 4).fill()
        "AMEX".draw(in: CGRect(x: 4, y: 6, width: 28, height: 12), withAttributes: [.font: UIFont.systemFont(ofSize: 8, weight: .bold), .foregroundColor: UIColor.white])
        let img = UIGraphicsGetImageFromCurrentImageContext()!; UIGraphicsEndImageContext(); return img
    }

    // MARK: - Localization
    func setLocalization() {
        hdrLbl.text = "card_payment".localize
        cardSKValidFixedLbl.text = "valid_thru".localize
        confirmBtn.setTitle("Pay now", for: .normal)
        cardSKValidLbl.textAlignment = LocalizationSystem.shared.isArabicActive ? .left : .right
        cardSKCardNoLbl.textAlignment = .left; cardSKValidFixedLbl.textAlignment = .right
    }
    func setupBlurView() {}

    // MARK: - Actions
    @IBAction func onClickBackBtn(_ sender: Any) { view.backgroundColor = .clear; dismiss(animated: true) }
    @IBAction func onClickCVVInfoBtn(_ sender: Any) {
        isCVVVisible = !isCVVVisible
        cvvTF.isSecureTextEntry = !isCVVVisible
        cvvInfoIV.image = UIImage(systemName: isCVVVisible ? "eye.slash" : "eye")
        if showingFront { flipCardView(isShowFront: false) }
    }
    @IBAction func onClickCVVDetailMainBtn(_ sender: Any) { cvvDetailMainView.isHidden = true }

    @IBAction func onClickConfirmBtn(_ sender: Any) {
        view.endEditing(true)
        if isRecurrencePayment {
            guard let cvv = cvvTF.text, cvv.count > 0 else {
                EPGHelper.showAlert(controller: self, message: EPGConstant.shared.enter_cvv); return
            }
            guard Internet.isAvailable else { EPGHelper.showAlert(message: EPGConstant.shared.internet_connection); return }
            addCardViewModel.getPreAuthenticationDataRecurrence(cvv: cvv) { [weak self] response in
                guard let self = self else { return }
                guard let response = response else {
                    EPGHelper.showAlert(controller: self, message: EPGConstant.shared.authentication_failed) { _ in self.dismiss(animated: true) }; return
                }
                guard response.PreAuthenticateInApp?.ResponseCode == "0" && response.transaction?.ResponseCode == nil else {
                    let msg = response.transaction?.ResponseDescription ?? (response.PreAuthenticateInApp?.ResponseDescription ?? "Response Not Available")
                    EPGHelper.showAlert(controller: self, message: msg) { _ in self.dismiss(animated: true) { self.delegate?.paymentDetailDelegate(addCardFailed: msg) } }; return
                }
                let isOTP = response.PreAuthenticateInApp?.ChallengeRequired ?? "false"
                let urlStr = response.PreAuthenticateInApp?.RedirectionURL
                if isOTP == "true" {
                    self.dismiss(animated: false) {
                        let vc = VerifyOTP(nibName: "VerifyOTP", bundle: EPGHelper.bundle)
                        vc.modalPresentationStyle = .overFullScreen; vc.isWebRequest = true; vc.webURL = urlStr
                        vc.delegate = self.delegate; vc.superController = self.superController
                        self.superController?.navigationController?.pushViewController(vc, animated: true)
                    }
                } else { self.dismiss(animated: false) { self.delegate?.paymentDetailDelegate(onSuccess: true) } }
            }
            return
        }
        if isSDKEnabled {
            let init2 = InitializeActivity(); let cfg = ConfigParameters()
            do {
                try cfg.addParam(paramName: "sdkReferenceNumber", paramValue: EPGPayment.shared.transactionId ?? "")
                try cfg.addParam(paramName: "sdkMaxTimeout",      paramValue: "60")
                try cfg.addParam(paramName: "sdkVersion",         paramValue: EPGPayment.shared.sdkVersion)
                try cfg.addParam(paramName: "baseUrl",            paramValue: APIConstant.shared.baseURL)
                try cfg.addParam(paramName: "merchantUsername",   paramValue: EPGPayment.shared.merchantUserName ?? "")
                try cfg.addParam(paramName: "customerName",       paramValue: EPGPayment.shared.customerName ?? "")
                try cfg.addParam(paramName: "transactionID",      paramValue: EPGPayment.shared.transactionId ?? "")
                try cfg.addParam(paramName: "authToken",          paramValue: EPGPayment.shared.authenticationToken ?? "")
                try cfg.addParam(paramName: "cardNumber",         paramValue: (cardNoTF.text ?? "").replacingOccurrences(of: " ", with: ""))
                try cfg.addParam(paramName: "verifyCode",         paramValue: cvvTF.text ?? "")
                try cfg.addParam(paramName: "expiryMonth",        paramValue: (expiryTF.text ?? "").components(separatedBy: "/").first ?? "")
                try cfg.addParam(paramName: "expiryYear",         paramValue: (expiryTF.text ?? "").components(separatedBy: "/").last ?? "")
                try init2.initialize(configParameters: cfg, locale: nil, uiCustomization: nil)
                if let t = try? init2.createTransaction(directoryServerID: EPGPayment.shared.directoryServerID ?? "", messageVersion: EPGPayment.shared.acsThreeDSVersion) {
                    EPGLogger.debug("Transaction: \(t)")
                }
            } catch { EPGLogger.error("Error: \(error)") }
        }
        checkValidation(textField: cardNoTF, isEnd: true)
        checkValidation(textField: expiryTF, isEnd: true)
        checkValidation(textField: cvvTF,    isEnd: true)
        var isValid = cardNoValidateStatusLbl.isHidden && expiryDateStatusLbl.isHidden && cvvStatusLbl.isHidden
        if (cardNoTF.text?.count ?? 0) == 0 || (expiryTF.text?.count ?? 0) == 0 || (cvvTF.text?.count ?? 0) == 0 { isValid = false }
        guard isValid else { return }
        let vr = addCardViewModel.validate(card: cardNoTF.text, expiryDate: expiryTF.text, cvvCode: cvvTF.text)
        guard let params = vr?.params else { EPGHelper.showAlert(controller: self, message: vr?.errorMessage ?? ""); return }
        guard Internet.isAvailable else { navigationController?.popViewController(animated: false); EPGHelper.showAlert(message: EPGConstant.shared.internet_connection); return }
        addCardViewModel.getPreAuthenticationData(cardParams: params) { [weak self] response in
            guard let self = self else { return }
            guard let response = response else {
                EPGHelper.showAlert(controller: self, message: EPGConstant.shared.authentication_failed) { if $0 { self.dismiss(animated: true) } }; return
            }
            guard response.PreAuthenticateInApp?.ResponseCode == "0" && response.transaction?.ResponseCode == nil else {
                let msg = response.transaction?.ResponseDescription ?? (response.PreAuthenticateInApp?.ResponseDescription ?? "Response Not Available")
                EPGHelper.showAlert(controller: self, message: msg) { if $0 { self.dismiss(animated: true) { self.delegate?.paymentDetailDelegate(addCardFailed: msg) } } }; return
            }
            let isOTP = response.PreAuthenticateInApp?.ChallengeRequired ?? "false"
            let urlStr = response.PreAuthenticateInApp?.RedirectionURL
            if isOTP == "true" {
                self.dismiss(animated: false) {
                    let vc = VerifyOTP(nibName: "VerifyOTP", bundle: EPGHelper.bundle)
                    vc.modalPresentationStyle = .overFullScreen; vc.isWebRequest = true; vc.webURL = urlStr
                    vc.delegate = self.delegate; vc.superController = self.superController
                    self.superController?.navigationController?.pushViewController(vc, animated: true)
                }
            } else { self.dismiss(animated: false) { self.delegate?.paymentDetailDelegate(onSuccess: true) } }
        }
    }
}

// MARK: - Setup ViewModel
extension NewAddCardVC {
    func setupViewModel() {
        view.backgroundColor = .clear; cardNoTypeIV.isHidden = true; cardSKTypeIV.isHidden = true
        addCardViewModel = AddCardViewModel(); setupTextField()
    }
    func setupTextField() {
        cardNoTF.delegate = self; expiryTF.delegate = self; cvvTF.delegate = self
        cardNoTF.addTarget(self, action: #selector(onTextFieldChange(_:)), for: .editingChanged)
        expiryTF.addTarget(self, action: #selector(onTextFieldChange(_:)), for: .editingChanged)
        cvvTF.addTarget(self,    action: #selector(onTextFieldChange(_:)), for: .editingChanged)
        cardNoTF.pattern = "NNNN NNNN NNNN NNNN NNN"
        cardNoValidateStatusLbl.isHidden = true; expiryDateStatusLbl.isHidden = true; cvvStatusLbl.isHidden = true
        payButtonVisibilityUpdate()
        cardNoIconIV.tintColor = .lightGray; expiryIV.tintColor = .lightGray; cvvIV.tintColor = .lightGray
        cardSKCardNoLbl.text = "0000 0000 0000 0000"; cardSKValidLbl.text = "MM/YY"; cardSKCVVLbl.text = ""
        cardNoIconIV.image = UIImage(named: "card_ic",  in: EPGHelper.bundle, with: nil)?.withRenderingMode(.alwaysTemplate).withTintColor(.lightGray)
        expiryIV.image     = UIImage(named: "calendar", in: EPGHelper.bundle, with: nil)?.withRenderingMode(.alwaysTemplate).withTintColor(.lightGray)
        cvvIV.image        = UIImage(named: "cvv",      in: EPGHelper.bundle, with: nil)?.withRenderingMode(.alwaysTemplate).withTintColor(.lightGray)
    }
    func flipCardView(isShowFront: Bool) {
        showingFront = isShowFront
        let opts: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        shadowView.alpha = 0
        if isShowFront {
            UIView.transition(with: backCardView, duration: 0.4, options: opts, animations: { self.backCardView.isHidden = true })
            UIView.transition(with: cardInfoView, duration: 0.4, options: opts, animations: { self.cardInfoView.isHidden = false })
        } else {
            UIView.transition(with: cardInfoView, duration: 0.4, options: opts, animations: { self.cardInfoView.isHidden = true })
            UIView.transition(with: backCardView, duration: 0.4, options: opts, animations: { self.backCardView.isHidden = false })
        }
        UIView.animate(withDuration: 1.0) { self.shadowView.alpha = 1 }
    }
}

// MARK: - Recurrence UI
extension NewAddCardVC {
    func configureRecurrenceUI() {
        guard isRecurrencePayment else { return }
        EPGLogger.recurrence("✅ Recurrence ACTIVE")
        cardNoView.isHidden = false; expiryView.isHidden = false
        cardNoValidateStatusLbl.isHidden = true; expiryDateStatusLbl.isHidden = true

        let rawMask = paymentDataResponse?.Transaction?.CardMask ?? ""
        let formatted = rawMask.isEmpty ? "XXXX XXXX XXXX XXXX" : formatCardMask(rawMask)
        EPGLogger.recurrence("CardMask formatted: \(formatted)")

        cardNoTF.pattern = ""; cardNoTF.setRawText(formatted)
        DispatchQueue.main.async { self.animateCardNoFloat(self.cardNoTF) }
        cardNoTF.isUserInteractionEnabled = false; cardNoTF.isEnabled = false; cardNoTF.delegate = nil

        cardSKCardNoLbl.text = formatted
        showCardLogoForMask(rawMask)

        expiryTF.text = "XX/XX"
        DispatchQueue.main.async { self.animateExpiryFloat(self.expiryTF) }
        expiryTF.isUserInteractionEnabled = false; expiryTF.isEnabled = false; expiryTF.delegate = nil
        cardSKValidLbl.text = "XX/XX"; cardSKValidFixedLbl.text = "valid_thru".localize
        setPayButtonEnabled(false)
    }

    private func formatCardMask(_ mask: String) -> String {
        let s = mask.replacingOccurrences(of: " ", with: "")
        var r = ""; for (i, c) in s.enumerated() { if i > 0 && i % 4 == 0 { r += " " }; r.append(c) }; return r
    }

    private func showCardLogoForMask(_ mask: String) {
        let d = mask.replacingOccurrences(of: " ", with: ""); guard !d.isEmpty else { return }
        let f1 = String(d.prefix(1)); let f2 = String(d.prefix(2))
        let (icon, logo): (String?, String?)
        switch f1 {
        case "4": icon = "visa1"; logo = "visa2"
        case "5" where ["51","52","53","54","55"].contains(f2), "2" where (Int(f2) ?? 0) >= 22: icon = "master1"; logo = "master2"
        case "3" where ["34","37"].contains(f2): icon = "amex1"; logo = "amex2"
        default: icon = nil; logo = nil
        }
        if let icon = icon, let logo = logo {
            cardNoTypeIV.image = UIImage(named: icon, in: EPGHelper.bundle, with: nil)
            cardSKTypeIV.image = UIImage(named: logo, in: EPGHelper.bundle, with: nil)
            cardNoTypeIV.isHidden = false; cardSKTypeIV.isHidden = false
            let bl = backCardView.viewWithTag(9902) as? UIImageView
            bl?.image = UIImage(named: logo, in: EPGHelper.bundle, with: nil); bl?.isHidden = false
        } else {
            cardNoTypeIV.isHidden = true; cardSKTypeIV.isHidden = true
            (backCardView.viewWithTag(9902) as? UIImageView)?.isHidden = true
        }
    }
}

// MARK: - UITextFieldDelegate
extension NewAddCardVC: UITextFieldDelegate {
    @objc func onTextFieldChange(_ textField: UITextField) {
        if textField == expiryTF {
            cardSKValidLbl.text = expiryTF.text ?? ""; expiryDateStatusLbl.isHidden = true
        } else if textField == cvvTF {
            cardSKCVVLbl.text = String(repeating: "*", count: cvvTF.text?.count ?? 0); cvvStatusLbl.isHidden = true
        } else if textField == cardNoTF {
            let count = cardNoTF.text?.count ?? 0
            cardSKCardNoLbl.text = count == 19
                ? (cardNoTF.text ?? "")
                : (cardNoTF.text ?? "").replacingOccurrences(of: " ", with: "").chunks(size: 4).joined(separator: " ")
            cardNoValidateStatusLbl.isHidden = true; checkCardType()
            if !isRecurrencePayment, checkValidationOnCardChange(textField: cardNoTF) {
                addCardViewModel.validateCardData(cardNumber: cardNoTF.text ?? "") { [weak self] response in
                    guard let self = self else { return }
                    guard let response = response else {
                        EPGHelper.showAlert(controller: self, message: EPGConstant.shared.authentication_failed) { if $0 { self.dismiss(animated: true) } }; return
                    }
                    self.isSDKEnabled = response.transaction?.isSDKEnabled ?? false
                    self.ConfirmButtonVisibilityUpdate(isButtonVisible: response.transaction?.responseCode == "0")
                }
            }
        }
        updatePayButtonState()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let old = textField.text, let r = Range(range, in: old) else { return true }
        let updated = old.replacingCharacters(in: r, with: string)
        if textField == expiryTF {
            if string == "" { if updated.count == 2 { textField.text = "\(updated.prefix(1))"; return false } }
            else if updated.count == 1 { if updated > "1" { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self.expiryTF.text = "0\(updated)/" } } }
            else if updated.count == 2 { if updated <= "12" { textField.text = "\(updated)/" }; return false }
            else if updated.count > 5  { return false }
            cardSKValidLbl.text = textField.text ?? ""
        } else if textField == cvvTF { return updated.count <= 4 }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        cardNoIconIV.tintColor = .lightGray; expiryIV.tintColor = .lightGray; cvvIV.tintColor = .lightGray
        if textField == cardNoTF { cardNoIconIV.tintColor = .label }
        else if textField == expiryTF { expiryIV.tintColor = .label }
        else { cvvIV.tintColor = .label }
        if textField == cvvTF { if showingFront { flipCardView(isShowFront: false) } }
        else { if !showingFront { flipCardView(isShowFront: true) } }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == cvvTF, !showingFront { flipCardView(isShowFront: true) }
        cardNoIconIV.tintColor = .lightGray; expiryIV.tintColor = .lightGray; cvvIV.tintColor = .lightGray
    }
}

// MARK: - Validation
extension NewAddCardVC {
    func checkValidation(textField: UITextField, isEnd: Bool = false) {
        if textField == cardNoTF {
            let n = (textField.text ?? "").replacingOccurrences(of: " ", with: "")
            if n.count > 0 {
                let vd = Validator.shared.checkCardNumber(paymentMethod: paymentMethod!, cardNumber: n)
                var ok = vd.valid; if ok && n.count < 15 { ok = false }
                cardNoValidateStatusLbl.isHidden = (vd.type != .NotRecognized && ok)
                cardNoValidateStatusLbl.text     = "card_no_invalid".localize; cvvValidation()
            } else { cardNoValidateStatusLbl.text = "enter_card_number".localize; cardNoValidateStatusLbl.isHidden = false }
        } else if textField == expiryTF {
            let t = expiryTF.text ?? ""
            if t.count == 5 { expiryDateStatusLbl.text = "expiry_invalid".localize; expiryDateStatusLbl.isHidden = addCardViewModel.expDateValidation(dateStr: t) }
            else if t.count == 0 { expiryDateStatusLbl.text = "enter_expiry".localize; expiryDateStatusLbl.isHidden = false }
            else { expiryDateStatusLbl.text = "expiry_invalid".localize; expiryDateStatusLbl.isHidden = false }
            expiryCvvSeperateLbl.isHidden = expiryDateStatusLbl.isHidden && cvvStatusLbl.isHidden
        } else if textField == cvvTF { cvvValidation() }
        payButtonVisibilityUpdate()
    }
    func checkValidationOnCardChange(textField: UITextField, isEnd: Bool = false) -> Bool {
        guard textField == cardNoTF else { return false }
        let n = (textField.text ?? "").replacingOccurrences(of: " ", with: "")
        guard n.count > 0 else { cardNoValidateStatusLbl.text = "enter_card_number".localize; cardNoValidateStatusLbl.isHidden = false; return false }
        let vd = Validator.shared.checkCardNumber(paymentMethod: paymentMethod!, cardNumber: n)
        var ok = vd.valid; if ok && n.count < 15 { ok = false }
        if vd.type == .NotRecognized || !ok { cardNoValidateStatusLbl.isHidden = false; cardNoValidateStatusLbl.text = "card_no_invalid".localize }
        else { cardNoValidateStatusLbl.isHidden = true }
        return ok
    }
    func cvvValidation() {
        let txt = cvvTF.text ?? ""
        let n = (cardNoTF.text ?? "").replacingOccurrences(of: " ", with: "")
        let vdNo = Validator.shared.checkCardNumber(paymentMethod: paymentMethod!, cardNumber: n)
        var cardOk = vdNo.valid; if cardOk && n.count < 15 { cardOk = false }
        if vdNo.type == .NotRecognized || !cardOk { cardOk = false } else { cardNoValidateStatusLbl.isHidden = true }
        if cardOk, let brand = vdNo.brand {
            let vd = Validator.shared.checkCVV(type: vdNo.type, brand: brand, cvv: txt)
            if vd.valid { cvvStatusLbl.isHidden = true }
            else if txt.count == 0 { cvvStatusLbl.isHidden = false; cvvStatusLbl.text = "enter_cvv_number".localize }
            else { cvvStatusLbl.text = "cvv_invalid".localize; cvvStatusLbl.isHidden = false }
        } else if txt.count == 0 { cvvStatusLbl.isHidden = false; cvvStatusLbl.text = "enter_cvv_number".localize }
        else if txt.count > 2 { cvvStatusLbl.isHidden = true }
        else { cvvStatusLbl.text = "cvv_invalid".localize; cvvStatusLbl.isHidden = false }
        expiryCvvSeperateLbl.isHidden = expiryDateStatusLbl.isHidden && cvvStatusLbl.isHidden
    }
    func checkCardType() {
        let n = (cardNoTF.text ?? "").replacingOccurrences(of: " ", with: ""); guard n.count > 0 else { return }
        let vd = Validator.shared.checkCardNumber(paymentMethod: paymentMethod!, cardNumber: n)
        let bl = backCardView.viewWithTag(9902) as? UIImageView
        cardNoTypeIV.isHidden = false; cardSKTypeIV.isHidden = false
        switch vd.type {
        case .NotRecognized: cardNoTypeIV.isHidden = true; cardSKTypeIV.isHidden = true; bl?.isHidden = true
        case .AmericanExpress:
            cardNoTypeIV.image = UIImage(named: "amex1", in: EPGHelper.bundle, with: nil)
            cardSKTypeIV.image = UIImage(named: "amex2", in: EPGHelper.bundle, with: nil)
            bl?.image = UIImage(named: "amex2", in: EPGHelper.bundle, with: nil); bl?.isHidden = false
        case .Visa:
            cardNoTypeIV.image = UIImage(named: "visa1", in: EPGHelper.bundle, with: nil)
            cardSKTypeIV.image = UIImage(named: "visa2", in: EPGHelper.bundle, with: nil)
            bl?.image = UIImage(named: "visa2", in: EPGHelper.bundle, with: nil); bl?.isHidden = false
        case .MasterCard:
            cardNoTypeIV.image = UIImage(named: "master1", in: EPGHelper.bundle, with: nil)
            cardSKTypeIV.image = UIImage(named: "master2", in: EPGHelper.bundle, with: nil)
            bl?.image = UIImage(named: "master2", in: EPGHelper.bundle, with: nil); bl?.isHidden = false
        default: cardNoTypeIV.isHidden = true; cardSKTypeIV.isHidden = true; bl?.isHidden = true
        }
    }
    func payButtonVisibilityUpdate()                        { updatePayButtonState() }
    func ConfirmButtonVisibilityUpdate(isButtonVisible: Bool) { setPayButtonEnabled(isButtonVisible) }
}

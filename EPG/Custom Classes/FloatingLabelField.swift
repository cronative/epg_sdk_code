//
//  FloatingLabelField.swift
//  EPG
//
//  Reusable floating label field — placeholder shown initially,
//  animates up as a small label when field is focused or has text.
//

import UIKit

class FloatingLabelField: UIView {

    // MARK: - Public
    var text: String? {
        get { textField.text }
        set {
            textField.text = newValue
            updateFloatingState(animated: false)
        }
    }
    var placeholder: String = "" {
        didSet {
            floatingLbl.text = placeholder
            textField.placeholder = ""   // placeholder hidden — floating label shows it
        }
    }
    var keyboardType: UIKeyboardType = .default {
        didSet { textField.keyboardType = keyboardType }
    }
    var isSecureTextEntry: Bool = false {
        didSet { textField.isSecureTextEntry = isSecureTextEntry }
    }
    var isEditable: Bool = true {
        didSet {
            textField.isEnabled = isEditable
            textField.isUserInteractionEnabled = isEditable
            backgroundColor = isEditable ? UIColor.systemGray6 : UIColor.systemGray5
        }
    }
    var font: UIFont = .systemFont(ofSize: 16) {
        didSet { textField.font = font }
    }
    weak var delegate: UITextFieldDelegate? {
        didSet { textField.delegate = delegate }
    }
    override var inputAccessoryView: UIView? {
        get { textField.inputAccessoryView }
        set { textField.inputAccessoryView = newValue }
    }

    // MARK: - Internal TextField (so existing addTarget calls still work)
    let textField = UITextField()

    // MARK: - Private
    private let floatingLbl    = UILabel()
    private var floatTopConstraint: NSLayoutConstraint!
    private var floatCenterConstraint: NSLayoutConstraint!

    private let floatingFont: UIFont  = .systemFont(ofSize: 11, weight: .regular)
    private let normalFont:   UIFont  = .systemFont(ofSize: 16)
    private let floatColor:   UIColor = .secondaryLabel
    private let normalColor:  UIColor = .placeholderText

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor    = UIColor.systemGray6
        layer.cornerRadius = 10
        clipsToBounds      = true

        // Floating label
        floatingLbl.font      = normalFont
        floatingLbl.textColor = normalColor
        floatingLbl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(floatingLbl)

        // TextField (no border, no placeholder — floating label handles it)
        textField.borderStyle = .none
        textField.font        = normalFont
        textField.textColor   = .label
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)

        // Constraints
        floatCenterConstraint = floatingLbl.centerYAnchor.constraint(equalTo: centerYAnchor)
        floatTopConstraint    = floatingLbl.topAnchor.constraint(equalTo: topAnchor, constant: 8)
        floatTopConstraint.isActive   = false
        floatCenterConstraint.isActive = true

        NSLayoutConstraint.activate([
            floatingLbl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            floatingLbl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            textField.heightAnchor.constraint(equalToConstant: 22),
        ])

        // Observe text field events
        textField.addTarget(self, action: #selector(editingBegan), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(editingEnded), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    // MARK: - Actions
    @objc private func editingBegan() {
        updateFloatingState(animated: true)
    }
    @objc private func editingEnded() {
        updateFloatingState(animated: true)
    }
    @objc private func textChanged() {
        updateFloatingState(animated: false)
    }

    // MARK: - Float logic
    private func updateFloatingState(animated: Bool) {
        let shouldFloat = textField.isFirstResponder || !(textField.text?.isEmpty ?? true)

        let animations = {
            if shouldFloat {
                self.floatCenterConstraint.isActive = false
                self.floatTopConstraint.isActive    = true
                self.floatingLbl.font      = self.floatingFont
                self.floatingLbl.textColor = self.floatColor
            } else {
                self.floatTopConstraint.isActive    = false
                self.floatCenterConstraint.isActive = true
                self.floatingLbl.font      = self.normalFont
                self.floatingLbl.textColor = self.normalColor
            }
            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: animations)
        } else {
            animations()
        }
    }

    // MARK: - Force float (for recurrence pre-fill)
    func setTextWithFloat(_ text: String) {
        textField.text = text
        updateFloatingState(animated: false)
    }

    // MARK: - Passthrough first responder
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }
    @discardableResult
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
    override var isFirstResponder: Bool { textField.isFirstResponder }
}

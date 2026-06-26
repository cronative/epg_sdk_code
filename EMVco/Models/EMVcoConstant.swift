//
//  EPGConstant.swift
//  EMVco
//
//  Created by eand ePayment on 12/11/24.
//

import Foundation
import UIKit

internal class EMVcoConstant {
    
    static let shared = EMVcoConstant()
    var internet_connection      = "check_internet_connection".localize
    var authentication_failed    = "authentication_failed".localize
    var enter_card_number        = "please_enter_card_number".localize
    var enter_expiry_date        = "please_enter_expiry_date".localize
    var enter_cvv                = "please_enter_cvv".localize
    var confirm_cancel_payment   = "sure_cancel_payment".localize
    var validate_merchant_name   = "merchant_name_required".localize
    var validate_merchant_identifier   = "merchant_identifier_required".localize
    var validate_trans_id        = "transaction_id_required".localize
    var validate_auth_token      = "authentication_token_required".localize
    var validate_session_id      = "authentication_session_required".localize
    var validate_customer_name   = "customer_name_required".localize
    var validate_callback_url    = "callback_url_required".localize
    var otp_verification_failed  = "otp_authentication_faled".localize
    var add_card_failed          = "add_card_failed".localize
    var payment_data_not_available = "payment_data_not_available".localize
    var validate_amount          = "amount_required".localize
    var cancelled_by_user        = "cancelled_by_user".localize
}

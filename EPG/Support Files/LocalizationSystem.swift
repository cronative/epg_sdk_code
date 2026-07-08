//
//  LocalizationSystem.swift
//  DIFX
//
//  Created by Mohd Arsad on 14/10/22.
//

import Foundation
import UIKit

internal class LocalizationSystem: NSObject {
    
    static let shared = LocalizationSystem()
    var isArabicActive: Bool = false
    
    override init() {
        super.init()
    }
    
    func refreshLanguageStatus() {
        if let appleLanguage = (UserDefaults.standard.object(forKey: "AppleLanguages") as? [String])?.first {
            self.isArabicActive = appleLanguage.lowercased().contains("ar")
        }
    }
    
    func getString(for key: String) -> String {
        switch key {
        case "alert":
            return self.isArabicActive ? "إنذار" : "Alert"
        case "ok":
            return self.isArabicActive ? "حسنا" : "OK"
        case "confirm":
            return self.isArabicActive ? "يتأكد" : "Confirm"
        case "payment":
            return self.isArabicActive ? "دفع" : "Payment"
        case "payment_description":
            return self.isArabicActive ? "وصف الدفع" : "Payment Description"
        case "order_id":
            return self.isArabicActive ? "معرف الطلب" : "Order ID"
        case "order_name":
            return self.isArabicActive ? "اسم النظام" : "Order Name"
        case "amount":
            return self.isArabicActive ? "مقدار" : "Amount"
        case "payment_method":
            return self.isArabicActive ? "طريقة الدفع" : "Payment Method"
        case "pay":
            return self.isArabicActive ? "يدفع" : "Pay"
        case "cancel":
            return self.isArabicActive ? "إلغاء" : "Cancel"
        case "enter_card_details":
            return self.isArabicActive ? "أدخل تفاصيل البطاقة" : "Enter card details"
        case "valid_thru":
            return self.isArabicActive ? "VALID THRU" : "VALID THRU"
        case "card_no_invalid":
            return self.isArabicActive ? "رقم البطاقة غير صالح" : "Card Number is Invalid"
        case "expiry_invalid":
            return self.isArabicActive ? "تاريخ الانتهاء غير صحيح" : "Expiry Date Invalid"
        case "cvv_invalid":
            return self.isArabicActive ? "CVC غير صالح" : "Invalid CVC"
        case "enter_card_number":
            return self.isArabicActive ? "ادخل رقم البطاقة" : "Enter Card Number"
        case "enter_expiry":
            return self.isArabicActive ? "أدخل تاريخ انتهاء الصلاحية" : "Enter Expiry Date"
        case "enter_cvv_number":
            return self.isArabicActive ? "أدخل رقم CVC" : "Enter CVC Number"
        case "confirm_continue":
            return self.isArabicActive ? "ادفع الآن" : "Pay Now"
        case "card_payment":
            return self.isArabicActive ? "الدفع بالبطاقة" : "Card Payment"
        case "check_internet_connection":
            return self.isArabicActive ? "الرجاء التحقق من اتصال الانترنت الخاص بك!" : "Please check your internet connection!"
        case "authentication_failed":
            return self.isArabicActive ? "المصادقة فشلت!" : "Authentication Failed!"
        case "please_enter_card_number":
            return self.isArabicActive ? "من فضلك ادخل رقم بطاقتك" : "Please enter your card number"
        case "please_enter_expiry_date":
            return self.isArabicActive ? "من فضلك ادخل تاريخ انتهاء الصلاحية" : "Please enter expiry date"
        case "please_enter_cvv":
            return self.isArabicActive ? "الرجاء إدخال CVV" : "Please enter CVV"
        case "sure_cancel_payment":
            return self.isArabicActive ? "هل أنت متأكد من أنك تريد إلغاء الدفع الخاص بك؟" : "Are you sure want to cancel your payment?"
        case "merchant_name_required":
            return self.isArabicActive ? "اسم مارشانت مطلوب!" : "Marchant Name Required!"
        case "merchant_identifier_required":
            return self.isArabicActive ? "مطلوب معرف مارشانت!" : "Marchant Identifier Required!"
        case "transaction_id_required":
            return self.isArabicActive ? "مطلوب معرف المعاملة!" : "Transaction Id Required!"
        case "authentication_token_required":
            return self.isArabicActive ? "مطلوب رمز المصادقة!" : "Authentication Token Required!"
        case "authentication_session_required":
            return self.isArabicActive ? "مطلوب معرف الجلسة!" : "Session Id Required!"
        case "customer_name_required":
            return self.isArabicActive ? "اسم الزبون مطلوب!" : "Customer Name Required!"
        case "callback_url_required":
            return self.isArabicActive ? "عنوان URL لمعاودة الاتصال مطلوب!" : "Callback URL Required!"
        case "otp_authentication_faled":
            return self.isArabicActive ? "فشل التحقق من OTP!" : "OTP Verification Failed!"
        case "add_card_failed":
            return self.isArabicActive ? "فشلت إضافة البطاقة!" : "Add Card Failed!"
        case "payment_data_not_available":
            return self.isArabicActive ? "بيانات الدفع غير متوفرة!" : "Payment Data Not Available!"
        case "amount_required":
            return self.isArabicActive ? "المبلغ المطلوب" : "Amount Required!"
        case "cancelled_by_user":
            return self.isArabicActive ? "تم الإلغاء بواسطة المستخدم" : "Cancelled by User"
        default:
            return ""
        }
    }
}

extension String {
    var localize: String {
        return LocalizationSystem.shared.getString(for: self)
    }
}

extension UIImage {
    var localize: UIImage? {
        if let cgImage = self.cgImage {
            return LocalizationSystem.shared.isArabicActive ? UIImage(cgImage: cgImage, scale: 1.0, orientation: .down) : self
        }
        return nil
    }
}

extension UIView {
    func flip() {
        self.transform = CGAffineTransform(scaleX: -1, y: 1);
    }
}

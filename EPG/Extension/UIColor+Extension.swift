//
//  UIColor+Extension.swift
//  EPG
//
//  Created by Mohd Arsad on 17/10/22.
//

import Foundation
import UIKit

extension UIColor {
    
    class func CustomColorFromHexaWithAlpha (_ hex:String, alpha:CGFloat) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    class func AppColor() -> UIColor {
        let hex = "ECECEC"
        return UIColor.CustomColorFromHexaWithAlpha(hex, alpha: 1.0)
    }
    class func AppBgColor() -> UIColor {
        let hex = "ECECEC"
        return UIColor.CustomColorFromHexaWithAlpha(hex, alpha: 1.0)
    }
    class func GreenStartColor() -> UIColor {
        let hex = "008952"
        return UIColor.CustomColorFromHexaWithAlpha(hex, alpha: 1.0)
    }
    class func GreenEndColor() -> UIColor {
        let hex = "005643"
        return UIColor.CustomColorFromHexaWithAlpha(hex, alpha: 1.0)
    }
    class func WhiteStartColor() -> UIColor {
        let hex = "FFFFFF"
        return UIColor.CustomColorFromHexaWithAlpha(hex, alpha: 1.0)
    }
    class func WhiteEndColor() -> UIColor {
        let hex = "FFFFFF"
        return UIColor.CustomColorFromHexaWithAlpha(hex, alpha: 0.0)
    }
    class func ShadowColor() -> UIColor {
        let hex = "52576D"
        return UIColor.CustomColorFromHexaWithAlpha(hex, alpha: 0.2)
    }
    class func ProfileCardStartColor() -> UIColor {
        let hex = "52576D"
        return UIColor.CustomColorFromHexaWithAlpha(hex, alpha: 1.0)
    }
    class func ProfileCardEndColor() -> UIColor {
        let hex = "33323D"
        return UIColor.CustomColorFromHexaWithAlpha(hex, alpha: 1.0)
    }
    class func tabbyColor() -> UIColor {
        let hex = "3EEDBF"
        return UIColor.CustomColorFromHexaWithAlpha(hex, alpha: 1.0)
    }
    class func tamaraColor() -> UIColor {
        let hex = "F3C287"
        return UIColor.CustomColorFromHexaWithAlpha(hex, alpha: 1.0)
    }
    class func postpayColor() -> UIColor {
        let hex = "3EBAD2"
        return UIColor.CustomColorFromHexaWithAlpha(hex, alpha: 1.0)
    }
        
    // Color with Opacity
    class func BlackWith(alpha:CGFloat) -> UIColor {
        let hex = "000000"
        return UIColor.CustomColorFromHexaWithAlpha(hex, alpha: alpha)
    }
    
    
    func with(alpha: CGFloat) -> UIColor {
        return self.withAlphaComponent(alpha)
    }
    
}

extension UIColor {
    
    static var background: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                return traits.userInterfaceStyle == .dark ?
                UIColor(red: 46/255.0, green: 46/255.0, blue: 46/255.0, alpha: 1) :
                UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)
        }
    }
    
    static var mainBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                return traits.userInterfaceStyle == .dark ?
                UIColor(red: 77/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1) :
                UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1)
        }
    }
    
    static var mainOTPBackground: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ?
            UIColor(red: 77/255.0, green: 74/255.0, blue: 74/255.0, alpha: 1) :
            UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1)
        }
    }
    
    static var scrollBackground: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ?
            UIColor(red: 46/255.0, green: 46/255.0, blue: 46/255.0, alpha: 1) :
            UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
        }
    }
}


extension UIColor {
    
    private static func customColorFromHexaWithAlpha (_ hex:String, alpha:CGFloat) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    static var lightWhite: UIColor {
        let hex = "FAFAFA"
        return customColorFromHexaWithAlpha(hex, alpha: 1.0)
    }
    
    static var whiteStartColor: UIColor {
        let hex = "FFFFFF"
        return customColorFromHexaWithAlpha(hex, alpha: 0.5)
    }
    
    static var whiteEndColor: UIColor {
        let hex = "FFFFFF"
        return customColorFromHexaWithAlpha(hex, alpha: 0.0)
    }
    
    static var greenStartColor: UIColor {
        let hex = "059494"
        return customColorFromHexaWithAlpha(hex, alpha: 1.0)
    }
    
    static var greenEndColor: UIColor {
        let hex = "057794"
        return customColorFromHexaWithAlpha(hex, alpha: 1.0)
    }
}


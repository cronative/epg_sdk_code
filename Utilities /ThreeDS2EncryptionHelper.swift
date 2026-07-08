//
//  3DSEncryptionHelper.swift
//  EPG-Demo
//
//  Created by eand ePayment on 03/10/24.
//

import Foundation
import CryptoKit
//import SwiftyRSA // If you are using a third-party library for RSA
import UIKit
import CoreLocation
public class ThreeDS2EncryptionHelper {
    
    
    
    
        public func getDeviceInfo() -> [String: Any] {
            // C001 Platform
            let platform = "iOS"
    
            // C002 Device Model
            var systemInfo = utsname()
            uname(&systemInfo)
            let deviceModel = withUnsafePointer(to: &systemInfo.machine) {
                $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                    String(cString: $0)
                }
            }
    
            func getFontFamilyNames() -> [String] {
                  return UIFont.familyNames
              }
            func getFontNamesForFamilyNames(familyNames: [String]) -> [String: [String]] {
                   var fontNamesDict = [String: [String]]()
                   for familyName in familyNames {
                       fontNamesDict[familyName] = UIFont.fontNames(forFamilyName: familyName)
                   }
                   return fontNamesDict
               }
            func hasPhysicalKeyboard() -> Bool {
                    // This is a placeholder; further implementation needed to detect a physical keyboard
                    return false
                }
            // C003 OS Name
            let osName = "iOS"
    
            // C004 OS Version
            let osVersion = UIDevice.current.systemVersion
    
            // C005 Locale
            let locale = Locale.current.identifier
    
            // C006 Time Zone
            let timeZone = TimeZone.current.identifier
            var interfaceIdiom: String
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                interfaceIdiom = "iPhone"
            case .pad:
                interfaceIdiom = "iPad"
            case .carPlay:
                interfaceIdiom = "CarPlay"
            case .tv:
                interfaceIdiom = "AppleTV"
            case .mac:
                interfaceIdiom = "Mac" // In case the app is running on macOS
            case .unspecified:
                interfaceIdiom = "Unspecified"
            @unknown default:
                interfaceIdiom = "Unknown"
            }
    
            // C008 Screen Resolution
            let screenResolution = UIScreen.main.bounds.size
            let screenResolutionStr = "\(Int(screenResolution.width))x\(Int(screenResolution.height))"
    
            // C009 Device Name
            let deviceName = UIDevice.current.name
    
            // C010 IP Address
            let ipAddress = getIPAddress() ?? "Unknown"
    
//             C011 Latitude and C012 Longitude
            let locationManager = CLLocationManager()
            locationManager.requestWhenInUseAuthorization()
    
            var latitude: String = "Unknown"
            var longitude: String = "Unknown"
    
            if CLLocationManager.locationServicesEnabled() {
                if let location = locationManager.location {
                    latitude = String(location.coordinate.latitude)
                    longitude = String(location.coordinate.longitude)
                }
            }
//    
            // C013 Application Package Name (Bundle Identifier)
            let appPackageName = Bundle.main.bundleIdentifier ?? "Unknown"
    
            // C014 SDK App ID (Generating a UUID)
            let sdkAppId = UUID().uuidString
    
            // C015 SDK Version (Assuming 2.1.0 for example)
            let sdkVersion = "2.1.0"
    
            // C016 SDK Ref Number (Assumed value)
            let sdkRefNumber = "sdkVendorRef12345"
    
            // C017 DateTime (UTC) in YYYYMMDDHHMMSS
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            let dateTime = dateFormatter.string(from: Date())
    
            // C018 SDK Transaction ID (Generating a UUID)
            let sdkTransId = UUID().uuidString
    
            // DPNA (Dynamic or static values)
        
    
            // SW (Dynamic or static values)
            let sw: [String] = ["SW01", "SW04"]
            let identifierForVendor = UIDevice.current.identifierForVendor?.uuidString ?? "N/A"
    
                    let fontFamilyNames = getFontFamilyNames()// Example software/service info
            let selectedFontName = fontFamilyNames.first ?? "System Font"
            let fontNamesForFamilies = getFontNamesForFamilyNames(familyNames: fontFamilyNames)
            // I005 - System Font
                    let systemFontName = UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName
    
                    // I006 - Standard Label Font Size
                    let labelFontSize = String(describing: UIFont.labelFontSize)
    
                    // I007 - Standard Button Font Size
                    let buttonFontSize = String(describing: UIFont.buttonFontSize)
    
                    // I008 - Small System Font Size
                    let smallSystemFontSize = String(describing: UIFont.smallSystemFontSize)
    
                    // I009 - Standard System Font Size
                    let systemFontSize = String(describing: UIFont.systemFontSize)
            // I010 - System Locale
                   let systemLocale = Locale.current.identifier
    
                   // I011 - Available Locale Identifiers
                   let availableLocaleIdentifiers = NSLocale.availableLocaleIdentifiers
    
                   // I012 - Preferred Languages
                   let preferredLanguages = Locale.preferredLanguages
    
                   let defaultTimeZoneOffset = String(TimeZone.current.secondsFromGMT() / 60)
    
                   // I014 - App Store Receipt URL
                   let appStoreReceiptURL = Bundle.main.appStoreReceiptURL?.absoluteString ?? "N/A"
    
            // D017 - Challenge Window Size (width x height)
                    let challengeWindowSize = "\(UIScreen.main.bounds.size.width)x\(UIScreen.main.bounds.size.height)"
            let deviceId = identifierForVendor
            // D022 - DeviceType
                   let deviceType: String
                   switch UIDevice.current.userInterfaceIdiom {
                   case .phone, .pad:
                       deviceType = "03" // Tablet/Mobile
                   case .tv:
                       deviceType = "02" // TV-connected
                   case .carPlay:
                       deviceType = "99" // Other
                   case .mac:
                       deviceType = "01" // Desktop
                   default:
                       deviceType = "99" // Other (Catch-all)
                   }
            // D023 - InputType
                  let inputType: [String]
                  if hasPhysicalKeyboard() {
                      inputType = ["01"] // Physical Keyboard
                  } else if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
                      inputType = ["02"] // Touch Keyboard
                  } else {
                      inputType = ["99"] // Other
                  }
    
                  // D024 - OutputType
                  let outputType: [String] = ["01", "02"] // Display and Audio for mobile/tablet devices
    
                  // D025 - LogoPreferenceColour
                  let logoPreferenceColour = "01" // Full Colour (can be customized)
            // D026 - UserID
                   let userId = "UserAccountHash123456" // Placeholder for a unique user ID hash
    
                   // D027 - Languages (IETF BCP 47 format, same as Preferred Languages)
                   let languages = preferredLanguages
    
                   // D028 - OriginatingDeviceID (can be the same as DeviceId)
                   let originatingDeviceId = deviceId
    
                   // D029 - External IP Address (IPv4 or IPv6 format)
                   let externalIpAddress = ipAddress // Placeholder, fetch real external IP address dynamically
            let browserAcceptHeaders = "RE02"
    
                  // D031 - Browser-User-Agent (Return RE02 for non-browser devices)
                  let browserUserAgent = "RE02"
    
                  // D032 - Device-ID-Type (Use key-based software identifier for iOS)
                  let deviceIdType = "03" // Key-based software identifier
    
                  // D033 - OriginatingDeviceIDType (Use software identifier for originating device)
                  let originatingDeviceIdType = "03" // Key-based software identifier
    
            // Constructing the JSON Dictionary
         
    
            let deviceInfo: [String: Any] = [
//                "DV": "1.6",  // Example version
                "C001": platform,
                "C002": deviceModel,
                "C003": osName,
                "C004": osVersion,
                "C005": locale,
                "C006": timeZone,
                "C008": screenResolutionStr,
                "C009": deviceName,
                "C010": ipAddress,
                "C011": latitude,
                "C012": longitude,
                "C013": appPackageName,
                "C014": sdkAppId,
                "C015": sdkVersion,
                "C016": sdkRefNumber,
                "C017": dateTime,
                "C018": sdkTransId,
//                "C010": "RE01",
//                "C011": "RE03"
////                "SW": sw,
//                "I001": identifierForVendor,
//                "I002": interfaceIdiom,
//                "I003": selectedFontName,
//                "I004": fontNamesForFamilies,
//                "I005": systemFontName,  // System font
//                "I006": labelFontSize,  // Label font size
//                "I007": buttonFontSize,  // Button font size
//                "I008": smallSystemFontSize,  // Small system font size
//                "I009": systemFontSize, // Standard system font size
//                "I010": systemLocale,  // System locale
//                "I011": availableLocaleIdentifiers,  // Available locale identifiers
//                "I012": preferredLanguages,  // Preferred languages
//                "I013": defaultTimeZoneOffset,  // Default time zone offset
//                "I014": appStoreReceiptURL,  // App Store receipt URL
//                "D001": platform,
//                "D002":deviceModel,
//                "D003":osName,
//                "D005":locale,
//                "D006":timeZone,
//                "D008":screenResolutionStr,
//                "D013":appPackageName,
//                "D015":sdkVersion,
//                "D016":sdkRefNumber,
//                "D017": challengeWindowSize,
//                "D021": deviceId,
//                "D022": deviceType,
//                "D023": inputType,  // InputType
//                "D024": outputType,  // OutputType
//                "D025": logoPreferenceColour, //
//                "D026": userId,  // UserID
//                "D027": languages,  // Languages
//                "D028": originatingDeviceId,  // OriginatingDeviceID
//                "D029": externalIpAddress,  // External IP Address
//                "D030": browserAcceptHeaders,  // Browser-Accept Headers
//                "D031": browserUserAgent,  // Browser-User-Agent
//                "D032": deviceIdType,  // Device-ID-Type (Key-based software identifier)
//                "D033": originatingDeviceIdType,// OriginatingDeviceIDType (Software-based)
//                "D034":dateTime,
//                "D035":sdkTransId
    
            ]

    
            return deviceInfo
        }
    
    
    
        // Function to get the local IP address
        private func getIPAddress() -> String? {
            var address: String?
            var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
    
            if getifaddrs(&ifaddr) == 0 {
                var ptr = ifaddr
                while ptr != nil {
                    defer { ptr = ptr?.pointee.ifa_next }
    
                    guard let interface = ptr?.pointee else { continue }
                    let name = String(cString: interface.ifa_name)
    
                    if name == "en0" {
                        var addr = interface.ifa_addr.pointee
    
                        if addr.sa_family == UInt8(AF_INET) {
                            let ipAddr = withUnsafePointer(to: &addr) {
                                $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {
                                    $0.pointee.sin_addr
                                }
                            }
    
                            let ip = String(cString: inet_ntoa(ipAddr))
                            address = ip
                        }
                    }
                }
    
                freeifaddrs(ifaddr)
            }
    
            return address
        }

    }

   



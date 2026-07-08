//
//  EPGHelper.swift
//  EPG
//
//  Created by Mohd Arsad on 17/08/22.
//

import Foundation
import UIKit

class EPGHelper {
    
    class var bundle: Bundle? {
        if let urlString = Bundle.main.path(forResource: "EPG", ofType: "framework", inDirectory: "Frameworks") {
            return (Bundle(url: NSURL(fileURLWithPath: urlString) as URL))
        }
        return nil
    }
    
    class var isArabicActive: Bool {
        return false
    }
    
    class func showAlert(controller: UIViewController? = nil, message: String) {
        let alert = UIAlertController(title: "alert".localize, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localize, style: .cancel, handler: { action in
            alert.dismiss(animated: true)
        }))
        if let controller = controller {
            controller.present(alert, animated: true)
        } else {
            epgRootController?.present(alert, animated: true)
        }
    }
    
    class func showAlert(controller: UIViewController? = nil, message: String, completion: @escaping(_ isComplete: Bool) -> ()) {
        let alert = UIAlertController(title: "alert".localize, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localize, style: .cancel, handler: { action in
            alert.dismiss(animated: true) {
                completion(true)
            }
        }))
        if let controller = controller {
            controller.present(alert, animated: true)
        } else {
            epgRootController?.present(alert, animated: true)
        }
    }
    
    class func showConfirmAlert(message: String, completion: @escaping(_ isSuccess: Bool) -> ()) {
        let alert = UIAlertController(title: "alert".localize, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "confirm".localize, style: .default, handler: { action in
            alert.dismiss(animated: true) {
                completion(true)
            }
        }))
        alert.addAction(UIAlertAction(title: "cancel".localize, style: .cancel, handler: { action in
            alert.dismiss(animated: true) {
                completion(false)
            }
        }))
        epgRootController?.present(alert, animated: true)
    }
    
    class func convertBase64StringToImage(imageBase64String: String) -> UIImage? {
        if let imageData = Data(base64Encoded: imageBase64String) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    class func getJSONString(paymentData: Data) -> String? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: paymentData, options: []) as? [String: Any]
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject ?? [:], options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        }
        catch {
            return nil
        }
    }
    
    class func getJSONString(object: [String: Any]) -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: object, options: []) {
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        }
        return nil
    }
    
    class func getObject(paymentData: Data) -> [String: Any]? {
        do {
            let object = try JSONSerialization.jsonObject(with: paymentData)

            print("Parsed object:", object)

            return object as? [String: Any]

        } catch {
            print("JSON Error:", error)
            return nil
        }
    }
}

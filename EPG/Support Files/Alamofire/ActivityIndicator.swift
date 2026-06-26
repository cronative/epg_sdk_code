//
//  ActivityIndicator.swift
//  EPG
//
//  Created by Mohd Arsad on 14/10/22.
//

import Foundation
import UIKit

class ActivityIndicator {

    //Show Indicator
    class func showActivity(tag: Int = 10024) {
        let currentWindow: UIWindow? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        let backgroundview = UIView(frame: UIScreen.main.bounds)
        backgroundview.tag = tag;
        backgroundview.backgroundColor = .clear// .black.withAlphaComponent(0.5)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.backgroundColor = .black.withAlphaComponent(0.2)
        blurEffectView.frame = UIScreen.main.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundview.addSubview(blurEffectView)
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actInd.center = backgroundview.center
        actInd.style = UIActivityIndicatorView.Style.large
        actInd.color = .white
        actInd.startAnimating()
        backgroundview.addSubview(actInd)
        backgroundview.bringSubviewToFront(actInd)
        currentWindow?.addSubview(backgroundview)
    }
    
    //Hide Indicator
    class func hideActivity(tag: Int = 10024) {
        let currentWindow: UIWindow? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        currentWindow?.viewWithTag(tag)?.removeFromSuperview()
    }
}

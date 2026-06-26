//
//  UIView+Extension.swift
//  EPG-Demo
//
//  Created by Mohd Arsad on 16/08/22.
//

import Foundation
import UIKit

extension UIView {
    
    enum ShadowSide {
        case center
        case bottomSide
        case upSide
    }
    
    func setCircleCorner() {
        self.layer.cornerRadius = self.bounds.height / 2
        self.clipsToBounds = true
    }
    
    func setBorder(width: CGFloat, color: UIColor, cornerRadius: CGFloat) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = cornerRadius
    }
    
    func setShadow(shadowColor: UIColor, shadowRadius : CGFloat = 0.0, cornerRadius : CGFloat = 0.0, side: ShadowSide, opacity: Float = 0.40) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = shadowRadius
        
        switch side {
        case .center:
            self.layer.shadowOffset = .zero
            break
        case .bottomSide:
            self.layer.shadowOffset = CGSize(width: 0, height: 15)
            break
        case .upSide:
            self.layer.shadowOffset = CGSize(width: 0, height: -10)
            break
        }
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = false
        self.layer.cornerRadius = cornerRadius
        
    }
    
    func setCenterUpShadow(shadowColor: UIColor, shadowRadius : CGFloat = 0.0, cornerRadius : CGFloat = 0.0, opacity: Float = 0.40) {
        
        if self.layer.sublayers != nil {
            for shadow in self.layer.sublayers! {
                shadow.removeFromSuperlayer()
            }
        }
        let newLayer = CALayer()
        let margin: CGFloat = 5.0
        newLayer.frame = self.layer.bounds.inset(by: UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin))
        newLayer.masksToBounds = false
        newLayer.shadowColor = shadowColor.cgColor
        newLayer.shadowOpacity = opacity
        newLayer.shadowRadius = shadowRadius
        newLayer.shadowOffset = .zero
        newLayer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        newLayer.shouldRasterize = false
        newLayer.cornerRadius = cornerRadius
        self.layer.addSublayer(newLayer)
    }
}

//MARK: - Gradient
extension UIView {
    /// Set Greadient on any View From Start to end
    ///
    /// - Parameters:
    ///   - cornerRadius: set corner Radius for the View , give any value in float
    ///   - firstColor: give initial color or Start color
    ///   - secoundColor: give End  color or Start color
    internal  func setGradient(cornerRadius : CGFloat, firstColor : UIColor, secoundColor : UIColor) {
        if self.layer.sublayers != nil {
            for gradient in self.layer.sublayers! {
                if ((gradient as? CAGradientLayer) != nil) {
                    gradient.removeFromSuperlayer()
                }
            }
        }
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [firstColor.cgColor, secoundColor.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.cornerRadius = cornerRadius
        gradient.frame = self.bounds
        self.layer.cornerRadius = cornerRadius
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    internal  func removeGradient() {
        if self.layer.sublayers != nil {
            for gradient in self.layer.sublayers! {
                if ((gradient as? CAGradientLayer) != nil) {
                    gradient.removeFromSuperlayer()
                }
            }
        }
    }
}

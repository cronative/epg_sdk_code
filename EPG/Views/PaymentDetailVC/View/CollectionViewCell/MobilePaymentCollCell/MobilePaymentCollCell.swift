//
//  MobilePaymentCollCell.swift
//  EPG
//
//  Created by Mohd Arsad on 21/03/2023.
//

import UIKit

class MobilePaymentCollCell: UICollectionViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var logoIV: UIImageView!
    @IBOutlet weak var logoCardView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.cardView.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.logoCardView.layer.cornerRadius = self.logoCardView.bounds.width / 2
        self.logoCardView.clipsToBounds = true
    }
    
    func setData(wallet: PaymentDataResponse.Wallet, isSelected: Bool) {
        self.titleLbl.text = wallet.walletType.rawValue
        self.titleLbl.backgroundColor = .clear
        switch wallet.walletType {
        case .samsungPay:
            self.logoIV.image = UIImage(named: "samsungPay", in: EPGHelper.bundle, with: nil)
        case .applePay:
            self.logoIV.image = UIImage(named: "applePay", in: EPGHelper.bundle, with: nil)
        case .googlePay:
            self.logoIV.image = UIImage(named: "googlePay", in: EPGHelper.bundle, with: nil)
        default:
            self.logoIV.image = nil
        }
        
        var borderColor: UIColor = .black.withAlphaComponent(0.3)
        var backgroundColor: UIColor = .black.withAlphaComponent(0.03)
        var borderWidth: CGFloat = 1.5
        
        if isSelected {
            borderWidth = 1.5
            
            switch wallet.walletType {
            case .samsungPay:
                borderColor = UIColor(red: 22/255.0, green: 65/255.0, blue: 147/255.0, alpha: 1.0)
                backgroundColor = borderColor.withAlphaComponent(0.1)
            case .applePay:
                borderColor = .black
                backgroundColor = borderColor.withAlphaComponent(0.1)
            case .googlePay:
                borderColor = .black
                backgroundColor = borderColor.withAlphaComponent(0.1)
            default:
                self.logoIV.image = nil
            }
        } else {
            borderWidth = 0.0
        }
        self.logoCardView.setBorder(width: borderWidth, color: borderColor, cornerRadius: self.logoCardView.bounds.height / 2)
        self.logoCardView.backgroundColor = backgroundColor
        self.logoIV.tintColor = borderColor
        self.titleLbl.textColor = borderColor
    }
}

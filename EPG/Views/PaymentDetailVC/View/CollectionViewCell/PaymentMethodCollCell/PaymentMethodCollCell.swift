//
//  PaymentMethodCollCell.swift
//  EPG-Demo
//
//  Created by Mohd Arsad on 17/10/22.
//

import UIKit

class PaymentMethodCollCell: UICollectionViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var radioIV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    var method: PaymentDataResponse.Instrument? {
        didSet {
            self.updateDetails()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateDetails() {
        guard let method = self.method else { return }
        self.titleLbl.text = method.Text
        self.icon.image = UIImage(named: method.imageName ?? "", in: EPGHelper.bundle, with: nil)
        
        var corner: CGFloat = 0.0
        switch EPGPayment.shared.theme {
        case .theme1, .auto:
            corner = 12.0
        case .theme2:
            corner = 0.0
        }
        
        if method.isSelected ?? false {
            self.radioIV.image = UIImage(named: "radio_selected", in: EPGHelper.bundle, with: nil)
            self.cardView.backgroundColor = UIColor.greenStartColor.withAlphaComponent(0.1)
            self.cardView.setBorder(width: 1.0, color: UIColor.greenStartColor, cornerRadius: corner)
        } else {
            self.radioIV.image = UIImage(named: "radio_normal", in: EPGHelper.bundle, with: nil)
            self.cardView.backgroundColor = .black.withAlphaComponent(0.03)
            self.cardView.setBorder(width: 0.0, color: .black, cornerRadius: corner)
        }
    }
}

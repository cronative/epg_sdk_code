//
//  SubOptionCollCell.swift
//  EPG
//
//  Created by Mohd Arsad on 15/03/2023.
//

import UIKit

class SubOptionCollCell: UICollectionViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var logoIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cardView.layer.cornerRadius = 25
        self.cardView.clipsToBounds = true
        self.cardView.layer.shadowRadius = 10.0
        self.cardView.layer.shadowOpacity = 0.1
        self.cardView.layer.shadowColor = UIColor.black.cgColor
    }
    
    func setData(isSelected: Bool, imageName: String, activeBackgroundColor: UIColor, activeImageColor: UIColor) {
        if isSelected {
            self.cardView.backgroundColor = activeBackgroundColor
            self.logoIV.tintColor = activeImageColor
        } else {
            self.cardView.backgroundColor = .systemGray6
            self.logoIV.tintColor = UIColor.label.withAlphaComponent(0.3)
        }
        self.logoIV.image = UIImage(named: imageName, in: EPGHelper.bundle, with: nil)
    }
}

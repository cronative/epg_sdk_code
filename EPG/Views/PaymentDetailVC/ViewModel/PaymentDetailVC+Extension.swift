//
//  PaymentDetailVC+Extension.swift
//  EPG
//
//  Created by Mohd Arsad on 25/10/22.
//

import Foundation
import UIKit

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension PaymentDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setupCollectionView() {
        self.paymentMethodCV.delegate = self
        self.paymentMethodCV.dataSource = self
        self.paymentMethodCV.register(UINib(nibName: "PaymentMethodCollCell", bundle: EPGHelper.bundle!), forCellWithReuseIdentifier: "PaymentMethodCollCell")
        self.paymentMethodCV.reloadData()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "AddCardCollCell", bundle: EPGHelper.bundle!), forCellWithReuseIdentifier: "AddCardCollCell")
        self.collectionView.register(UINib(nibName: "SubOptionCollCell", bundle: EPGHelper.bundle!), forCellWithReuseIdentifier: "SubOptionCollCell")
        self.collectionView.register(UINib(nibName: "MobilePaymentCollCell", bundle: EPGHelper.bundle!), forCellWithReuseIdentifier: "MobilePaymentCollCell")
        self.collectionView.reloadData()
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.paymentMethodCV == collectionView {
            return self.paymentMethods.count
        } else if collectionView == self.collectionView {
            if let selectedSymbol = self.paymentMethods.filter({ $0.isSelected ?? false }).first?.Symbol {
                if selectedSymbol == "BNPL" {
                    return self.bnplData.count
                } else if selectedSymbol == "MobPay" {
                    return self.mobilePaymentsData.count
                }
            }
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.paymentMethodCV == collectionView {
            let cell = self.paymentMethodCV.dequeueReusableCell(withReuseIdentifier: "PaymentMethodCollCell", for: indexPath) as! PaymentMethodCollCell
            cell.method = self.paymentMethods[indexPath.row]
            return cell
        } else {
            let paymentMethod = self.paymentMethods.filter({ $0.isSelected ?? false }).first
            if paymentMethod?.Symbol == "MobPay" {
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "MobilePaymentCollCell", for: indexPath) as! MobilePaymentCollCell
                let object = self.mobilePaymentsData[indexPath.row]
                if object.walletType == .applePay || object.walletType == .samsungPay || object.walletType == .googlePay {
                    cell.isUserInteractionEnabled = true
                    cell.setData(wallet: object, isSelected: indexPath.row == self.subOptionSelecedIndex)
                } else {
                    cell.logoIV.image = nil
                    cell.titleLbl.text = ""
                    cell.isUserInteractionEnabled = false
                }
                return cell
            } else if paymentMethod?.Symbol == "BNPL" {
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "SubOptionCollCell", for: indexPath) as! SubOptionCollCell
                cell.isUserInteractionEnabled = true
                
                let object = self.bnplData[indexPath.row]
                if object.walletType == .tabby {
                    cell.setData(isSelected: indexPath.row == self.subOptionSelecedIndex, imageName: "tabby", activeBackgroundColor: .tabbyColor(), activeImageColor: .black)
                } else if object.walletType == .postPay {
                    cell.setData(isSelected: indexPath.row == self.subOptionSelecedIndex, imageName: "postpay", activeBackgroundColor: .postpayColor(), activeImageColor: .white)
                } else if object.walletType == .tamara {
                    cell.setData(isSelected: indexPath.row == self.subOptionSelecedIndex, imageName: "tamara", activeBackgroundColor: .tamaraColor(), activeImageColor: .black)
                } else {
                    cell.logoIV.image = nil
                }
                return cell
            } else {
                return UICollectionViewCell()
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.paymentMethodCV {
            self.paymentMethods = self.paymentMethods.map({ object -> PaymentDataResponse.Instrument in
                var t = object
                t.isSelected = false
                return t
            })
            self.paymentMethods[indexPath.row].isSelected = true
            self.paymentMethodCV.reloadData()
//            self.paymentMethodCV.scrollToItem(at: indexPath, at: LocalizationSystem.shared.isArabicActive ? .left : .right, animated: true)
            
            self.collectionView.isHidden = true
            self.subOptionTitleLbl.isHidden = true
            self.subOptionSelecedIndex = 0
            self.collectionView.reloadData()
            
            if let object = self.paymentMethods.filter({ $0.isSelected ?? false }).first, let selectedSymbol = object.Symbol {
                self.subOptionTitleLbl.text = object.Name ?? ""
                if selectedSymbol == "BNPL" {
                    self.collectionViewHeightConstraints.constant = 50.0
                    self.collectionView.reloadData()
                    self.collectionView.isHidden = false
                    self.subOptionTitleLbl.isHidden = true
                } else if selectedSymbol == "MobPay" {
                    self.collectionViewHeightConstraints.constant = 105.0
                    self.collectionView.reloadData()
                    self.collectionView.isHidden = false
                    self.subOptionTitleLbl.isHidden = true
                } else if selectedSymbol == "UAEPGS" {
                    print("UAEPGS Selected")
                }
            }
        } else if collectionView == self.collectionView {
            self.subOptionSelecedIndex = indexPath.row
            self.collectionView.reloadData()
//            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.paymentMethodCV == collectionView {
            return CGSize(width: 118.0, height: 100.0)
        } else {
            if let selectedSymbol = self.paymentMethods.filter({ $0.isSelected ?? false }).first?.Symbol {
                if selectedSymbol == "BNPL" {
                    return CGSize(width: 125.0, height: 50.0) //5/2
                } else if selectedSymbol == "MobPay" {
                    return CGSize(width: 70.0, height: 105.0) //2/3
                }
            }
            return CGSize(width: 175.0, height: 100.0)
        }
    }
}

//
//  BottomPopupViewController.swift
//  Trendyol
//
//  Created by Emre on 11.09.2018.
//

import UIKit

class BottomPopupViewController: UIViewController, BottomPopupAttributesDelegate {
    private var transitionHandler: BottomPopupTransitionHandler?
    weak var popupDelegate: BottomPopupDelegate?
    
    // MARK: Initializations
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    internal override func viewDidLoad() {
        
        super.viewDidLoad()
        transitionHandler?.notifyViewLoaded(withPopupDelegate: popupDelegate)
        popupDelegate?.bottomPopupViewLoaded()
        self.view.accessibilityIdentifier = popupViewAccessibilityIdentifier
    }
    
    internal override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        curveTopCorners()
        popupDelegate?.bottomPopupWillAppear()
    }
    
    internal override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        popupDelegate?.bottomPopupDidAppear()
    }
    
    internal override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        popupDelegate?.bottomPopupWillDismiss()
    }
    
    internal override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        popupDelegate?.bottomPopupDidDismiss()
    }
    
    //MARK: Private Methods
    
    private func initialize() {
        transitionHandler = BottomPopupTransitionHandler(popupViewController: self)
        transitioningDelegate = transitionHandler
        modalPresentationStyle = .custom
    }
    
    private func curveTopCorners() {
        let path = UIBezierPath(roundedRect: self.view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: popupTopCornerRadius, height: 0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.view.bounds
        maskLayer.path = path.cgPath
        self.view.layer.mask = maskLayer
    }
    
    //MARK: BottomPopupAttributesDelegate Variables
    
    internal var popupHeight: CGFloat { return BottomPopupConstants.kDefaultHeight }
    
    internal var popupTopCornerRadius: CGFloat { return BottomPopupConstants.kDefaultTopCornerRadius }
    
    internal var popupPresentDuration: Double { return BottomPopupConstants.kDefaultPresentDuration }
    
    internal var popupDismissDuration: Double { return BottomPopupConstants.kDefaultDismissDuration }
    
    internal var popupShouldDismissInteractivelty: Bool { return BottomPopupConstants.dismissInteractively }
    
    internal var popupDimmingViewAlpha: CGFloat { return BottomPopupConstants.kDimmingViewDefaultAlphaValue }
    
    internal var popupShouldBeganDismiss: Bool { return BottomPopupConstants.shouldBeganDismiss }
    
    internal var popupViewAccessibilityIdentifier: String { return BottomPopupConstants.defaultPopupViewAccessibilityIdentifier }
}

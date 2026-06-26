//
//  ProgressDialog.swift
//  FrameWork-V2
//
//  Created by eand ePayment on 09/11/24.
//

import UIKit

class ProgressDialog {
    private var dialog: UIView
    private var activityIndicator: UIActivityIndicatorView

    init(parentView: UIView) {
        // Create the dialog (a simple view that covers the screen)
        dialog = UIView(frame: parentView.bounds)
        dialog.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        // Add an activity indicator to show loading
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = dialog.center
        activityIndicator.startAnimating()

        dialog.addSubview(activityIndicator)
    }

    func show() {
        // Show the progress dialog
        dialog.isHidden = false
    }

    func dismiss() {
        // Hide the progress dialog
        dialog.isHidden = true
        activityIndicator.stopAnimating()
    }
}

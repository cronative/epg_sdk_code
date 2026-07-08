//
//  TransactionImpl.swift
//  FrameWork-V2
//
//  Created by eand ePayment on 09/11/24.
//

import UIKit

// Convert the Kotlin class to Swift
class TransactionImpl: Transaction {
    private var authenticationRequestParameters: AuthenticationRequestParameters?
    private var progressDialog: ProgressDialog?

    // Constructor (initializer)
    init(authenticationRequestParameters: AuthenticationRequestParameters?) {
        self.authenticationRequestParameters = authenticationRequestParameters
    }

    func getAuthenticationRequestParameters() throws -> AuthenticationRequestParameters? {
        // Return the authentication request parameters
        return authenticationRequestParameters
    }

    func doChallenge(
        challengeParameters: ChallengeParameters,
        challengeStatusReceiver: ChallengeStatusReceiver,
        timeOut: Int
    ) throws {
        // Implement challenge flow logic here
        // For example, initiate a challenge using the provided parameters
    }
    func getProgressView() throws -> ProgressDialog? {
        // Check for the current active scene and get its window
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }) else {
            throw SDKRuntimeException.generalError("Unable to retrieve the key window for the progress dialog.")
        }
        
        // Return a ProgressDialog to show during processing
        if progressDialog == nil {
            progressDialog = ProgressDialog(parentView: window.rootViewController?.view ?? window)
        }
        return progressDialog
    }
    func close() {
        progressDialog?.dismiss()
        progressDialog = nil
        // Nullify authentication request parameters
        authenticationRequestParameters = nil
    }
}

//
//  ChallengeStatusReceiver.swift
//  FrameWork-V2
//
//  Created by eand ePayment on 09/11/24.
//

protocol ChallengeStatusReceiver {
    // Called when the challenge process is completed
    func completed(completionEvent: CompletionEvent)
    
    // Called when the Cardholder cancels the transaction
    func cancelled()
    
    // Called when the challenge process reaches timeout
    func timedout()
    
    // Called when a protocol error occurs
    func protocolError(protocolErrorEvent: ProtocolErrorEvent)
    
    // Called when a runtime error occurs
    func runtimeError(runtimeErrorEvent: RuntimeErrorEvent)
}

import Foundation

public class AuthenticationRequestParameters: Codable {
    public let sdkAppId: String
    public let sdkEphemeralPublicKey: String
    public let sdkReferenceNumber: String
    public let sdkTransId: String
    public let messageVersion: String
    public let deviceData: String

    public init(sdkAppId: String,
                sdkEphemeralPublicKey: String,
                sdkReferenceNumber: String,
                sdkTransId: String,
                messageVersion: String,
                deviceData: String) {
        self.sdkAppId = sdkAppId
        self.sdkEphemeralPublicKey = sdkEphemeralPublicKey
        self.sdkReferenceNumber = sdkReferenceNumber
        self.sdkTransId = sdkTransId
        self.messageVersion = messageVersion
        self.deviceData = deviceData
    }
}

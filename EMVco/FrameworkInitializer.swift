import Foundation
import SwiftyRSA
import UIKit

public class FrameworkInitializer {
    
    private let pemString = """
    -----BEGIN CERTIFICATE-----
    MIIFAjCCA+qgAwIBAgIQCoLFqfZB+HA456cdaNZaZzANBgkqhkiG9w0BAQsFADBI
    MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMSIwIAYDVQQDExlE
    aWdpQ2VydCBBc3N1cmVkIElEIENBIEcyMB4XDTIzMDMzMDAwMDAwMFoXDTI2MDMz
    MDIzNTk1OVowezELMAkGA1UEBhMCQUUxEjAQBgNVBAcTCUFidSBEaGFiaTEvMC0G
    A1UEChMmRXRpc2FsYXQgVGVsZWNvbW11bmljYXRpb24gQ29ycG9yYXRpb24xCzAJ
    BgNVBAsTAklUMRowGAYDVQQDExFEZW1vIE1lcmNoYW50IEVQRzCCASIwDQYJKoZI
    hvcNAQEBBQADggEPADCCAQoCggEBALCiFVJEhg0Zs8SktdaxgEfQciZToFaDXo4k
    mUg2Rr3CVXP3q7eQSzQKkWTJLGyPb+WGl9mgtZc7ldBFyNqYEiA3ZDfGeaOuOSN8
    2J0LHcYjsJUyPJyVdPMELJeIg0OxdFr8E06uDKnwHRrO1KFCc0L+WXwZ/wbINIFP
    8sYcJh9i9saXXsdKW1QSNCACKlj5IXXf+qzBO/AO+66V/Phq2D5ZD6g8bEx6GMxr
    TV9FWRPVvbzGNi9gtcKPhoaaIp6OWKtoQHBizUgTZovo0mRWqH7+L30HZrX1N5x8
    szk+RRIaqMZLaJL/6T5rBIqyxCvysg/uDhjBq6RSYV9m7GCsfVkCAwEAAaOCAbMw
    ggGvMB8GA1UdIwQYMBaAFLHP9qHl5oHFZkeNeIR3e/mBy0qmMB0GA1UdDgQWBBTL
    eUlq8g9P1Thh9E/D0K7+FPUv/DAMBgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIF
    oDATBgNVHSUEDDAKBggrBgEFBQcDAjBCBgNVHSAEOzA5MDcGCWCGSAGG/WwGATAq
    MCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BTMH0GA1Ud
    HwR2MHQwOKA2oDSGMmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFz
    c3VyZWRJRENBRzIuY3JsMDigNqA0hjJodHRwOi8vY3JsNC5kaWdpY2VydC5jb20v
    RGlnaUNlcnRBc3N1cmVkSURDQUcyLmNybDB3BggrBgEFBQcBAQRrMGkwJAYIKwYB
    BQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0
    cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEQ0FHMi5j
    cnQwDQYJKoZIhvcNAQELBQADggEBAFImgch+82gDKOJm82F4ojIuGE/WeYTXN+Th
    +QjnJyg07banRSCR9Ya1v1mcvzaHW7Gl3q2TVzoIoyjKmLU5JZ2tE9ge/rCE8yCi
    FyNXvnMWXrhIzvoL4Xozf2+/UAf4xNLmtDQ0cvYS5FcCIivCUsWshrLyfH+rNBMh
    Shn3hWDQB5yj24DgGdMgPztzi4REynu53ZcTC3MelmtQhE66O/5XpKuid31oP/tB
    ySu5fV+AUpVhXnE7+FybJBzG0yCGtlIWPvYXe2yJzWvcTXvu9QADO2IzSe6BZQSk
    6JD8yTLNeF+Tz3Ud+6N0gaBcQoo/072X9Wu8a/vxEjB3jQg607Y=
    -----END CERTIFICATE-----
    """

    private let privateKeyPEM = """
    -----BEGIN PRIVATE KEY-----
    MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCwohVSRIYNGbPE
    pLXWsYBH0HImU6BWg16OJJlINka9wlVz96u3kEs0CpFkySxsj2/lhpfZoLWXO5XQ
    RcjamBIgN2Q3xnmjrjkjfNidCx3GI7CVMjyclXTzBCyXiINDsXRa/BNOrgyp8B0a
    ztShQnNC/ll8Gf8GyDSBT/LGHCYfYvbGl17HSltUEjQgAipY+SF13/qswTvwDvuu
    lfz4atg+WQ+oPGxMehjMa01fRVkT1b28xjYvYLXCj4aGmiKejliraEBwYs1IE2aL
    6NJkVqh+/i99B2a19TecfLM5PkUSGqjGS2iS/+k+awSKssQr8rIP7g4YwaukUmFf
    ZuxgrH1ZAgMBAAECggEAIS+Co/891E5E6SgtBdY5jMSL/clucXKjHD+iEOApsFNH
    rM8WkxloF7H4mR/22bqlQlFkTD4WgABw6D2EPBWgKi9eA+ClT+xWzeUR6YeCI4zn
    C1Dx9FVcMKBTJHFAgEJh4wpDMmAe/vqe7T940Ydjkm2pMFjOAl8xBi6YJUJ6oyCr
    ffqepmjLEr7xec7nEvUgfcrv+AaLP901+UhbzLYYroey//W7/pFldBeM1FDQaGVF
    O11Ld6mmkkOfy8Y165hw8op8H692NDsL3MiG9AHMAGAGRro6Vvb6TZ54PoEPJyPE
    4HL8Qg8VyYxXstDVjh5gHPV4a9QzbFqftANwvE7NFQKBgQDAJVmk7WDG5zRGCOIR
    slEHBLDnbPibZifg3sd5VGgIpZFHtq4IMycBraEqq9X11IUk+4CjHZUj4ZVpaFR0
    aho73J7msnT7KJ1uAxC2bG3p17TmnyM+UPzl692gc1LEruIBuAB0fxsNzXw+sVCF
    RFunFgxNAtp9SluzkaFzvfXUrwKBgQDrVP+BkbzOgRNRGjcinOF019ykyYN9vy47
    9pM3a1Y3ZLYzm0y731SLlNye04CWbjSOrczoJbXmlVB6e4UUJbna690710LWbttI
    mrdjv6yzNv5Mcq6j6PHjnBr4ToK+HK3PSC2KSsEe38RaoGJs1UD2krmz6yofeWtg
    t9rJietgdwKBgBtYdXSab+5+0xqwgvP/y7ZS/ZZCFPOQy1YefocO8ytf3Ng28Hes
    R/3eJxS6ld3BnB1SSdFtEV+k6C2zMmnK++bPFDJC7ZEdC6Kvfv5nWhEwqMc1mL9y
    qTtToRwHrZzeQr354N6zhDcnqmoFtC7zNpQF+EQxhsTUA08AB9lADK9zAoGAEWEt
    nXwN3ZJawtqUx9GeNOrcOK9JLrg3yeXj6Wvb6itd6WHGwPk1XTmZMYGdNX7eEstz
    HpHqZSUR1Hna0ioXF7vjks/K99soBqymbo9xSar+DNdLXn+NnamhtETYEwI7M9u4
    wUXUDVupPKgrnK4DJjKf1FHBwqFM9M+fMNMmtvECgYBZtiUKCSGRUANtdgJmd5xq
    6yNHzicKqC4v2fjjmbz4Xj1ZsLMNf37QeRqF8OmcddUtaWfLDv9NrPbFz2DrwVgx
    g7ygQI7gczzmjg5ziM4fPL/1GbRJ3fRlzfvQJvk5SlbbfECOAKhMkyVWIQttIpnS
    KQJB3pHn9zrdccJ7sYJYSA==
    -----END PRIVATE KEY-----
    """

    
    public init() {
        
        extractPublicKey()
        
        // Create an instance of ThreeDS2EncryptionHelper
    }

    struct DeviceDataJson: Codable {
        let version: String
        let dd: [String: String]
        let dpna: [String: String]
        let sw: [String]
    }

    private var swiftyPublicKey: PublicKey?
        private var swiftyPrivateKey: PrivateKey?

        private func extractPublicKey() {
            do {
               
                // Encrypting Data Example
                let encryptedData = try getDeviceInfoAndEncrypt()
                print("Encrypted Data: \(encryptedData)")
                
                // Decrypting the data using private key
                if let decryptedData = try? decryptData(using: privateKeyPEM, encryptedData: encryptedData) {
                    print("Decrypted Data: \(decryptedData)")
                }
            } catch {
                print("Error extracting Public Key: \(error.localizedDescription)")
            }
        }

    
    public func getDeviceInfoAndEncrypt() throws -> String {
        let encryptionHelper = ThreeDS2EncryptionHelper()
        let deviceInfo = encryptionHelper.getDeviceInfo() // Get all device information
    
            var ddValues = [String: String]()
        var listWarningResult: [String] = []
        var dpnaValues = [String: String]()
        let excludedValues = ["RE01", "RE02", "RE03", "RE04"]

        // Step 2: Filter the device data
        for (key, value) in deviceInfo {
            // Ensure the value is a string
            if let stringValue = value as? String {
                // Trim whitespaces from the key for proper comparison
                let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)

                // Now check if the **value** is in excludedValues
                if excludedValues.contains(stringValue) {
                    print("Value \(stringValue) found in excludedValues")
                    // Assign to dpnaValues if the value is in excludedValues
                    dpnaValues[trimmedKey] = stringValue
                  
                } else {
                    print("Value \(stringValue) not found in excludedValues")
                    // Otherwise, assign to ddValues
                    ddValues[trimmedKey] = stringValue
                   
                }
            } 
        }
        // Initialize the security manager
        let securityManager = SdkSecurityManager()

        // Perform security checks and process warnings
        let warnings = securityManager.performSecurityChecks()
        if !warnings.isEmpty {
            for warning in warnings {
                listWarningResult.append(warning.getID())
            }
        }
  let deviceDataJson = DeviceDataJson(version: "1.6", dd: ddValues, dpna: dpnaValues, sw: listWarningResult)
            let jsonData = try JSONEncoder().encode(deviceDataJson)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw NSError(domain: "Failed to convert deviceInfo to String", code: -1, userInfo: nil)
        }
 

        do {
            let certificate = try X509Certificate(pemEncoded: pemString)
            print("Certificate extracted successfully: \(certificate)")

            let swiftyPublicKey = try certificate.publicKey()
            print("Public Key extracted successfully: \(String(describing: swiftyPublicKey))")

            // Encrypt the JSON string
            let encryptedData = try encryptData(using: swiftyPublicKey, data: jsonString)
            return encryptedData
        } catch {
            throw error
        }
    }

   

    private func encryptData(using publicKey: PublicKey, data: String) throws -> String {
        do {
            let clearMessage = try ClearMessage(string: data, using: .utf8)
            let encrypted = try clearMessage.encrypted(with: publicKey, padding: .PKCS1)
            return encrypted.base64String
        } catch {
            throw error
        }
    }
       
        // Function to decrypt data using private key
    private func decryptData(using privateKeyPEM: String, encryptedData: String) throws -> String {
        // Convert encryptedData from Base64-encoded string to Data
        guard let encryptedData = Data(base64Encoded: encryptedData) else {
            throw NSError(domain: "Invalid Base64 string", code: -1, userInfo: nil)
        }

        let privateKey = try PrivateKey(pemEncoded: privateKeyPEM)
        
        let encrypted = EncryptedMessage(data: encryptedData)
        let clearMessage = try encrypted.decrypted(with: privateKey, padding: .PKCS1)
        return try clearMessage.string(encoding: .utf8)
    }
    }

    // X509Certificate Class
    class X509Certificate {
        private let certificate: SecCertificate

        init(pemEncoded pemString: String) throws {
            let cleanedPem = pemString
                .replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
                .replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
                .replacingOccurrences(of: "\n", with: "")

            guard let data = Data(base64Encoded: cleanedPem) else {
                throw NSError(domain: "Invalid PEM", code: -1, userInfo: nil)
            }

            guard let cert = SecCertificateCreateWithData(nil, data as CFData) else {
                throw NSError(domain: "Unable to create certificate", code: -1, userInfo: nil)
            }

            self.certificate = cert
        }

        func publicKey() throws -> PublicKey {
            var error: Unmanaged<CFError>?
            guard let key = SecCertificateCopyKey(certificate) else {
                throw NSError(domain: "Failed to extract public key", code: -1, userInfo: nil)
            }

            guard let publicKeyData = SecKeyCopyExternalRepresentation(key, &error) else {
                throw error!.takeRetainedValue()
            }

            return try PublicKey(data: publicKeyData as Data)
        }
    }
// String extension to chunk data into smaller parts
extension String {
    func chunked(into size: Int) -> [String] {
        var chunks: [String] = []
        var startIndex = self.startIndex

        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: size, limitedBy: self.endIndex) ?? self.endIndex
            let chunk = String(self[startIndex..<endIndex])
            chunks.append(chunk)
            startIndex = endIndex
        }

        return chunks
    }
}


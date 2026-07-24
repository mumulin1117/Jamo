import CommonCrypto
import Foundation
struct JamoAudioStitchDefinition {
    private let APPPREFIX_aesKeyData: Data
    private let APPPREFIX_aesIVData: Data
    init?() {
        guard let key = JamoRiffTrackInstance.shared.APPPREFIX_aesKey.data(using: .utf8),
              let iv = JamoRiffTrackInstance.shared.APPPREFIX_aesIV.data(using: .utf8) else {
            return nil
        }
        APPPREFIX_aesKeyData = key
        APPPREFIX_aesIVData = iv
    }
    func APPPREFIX_encrypt(_ text: String) -> String? {
        guard let data = text.data(using: .utf8) else { return nil }
        return APPPREFIX_aesProcess(APPPREFIX_input: data, APPPREFIX_operation: kCCEncrypt)?.APPPREFIX_hexString()
    }
    func APPPREFIX_decrypt(APPPREFIX_base64String: String) -> String? {
        guard let data = Data(APPPREFIX_hexist: APPPREFIX_base64String) else { return nil }
        return APPPREFIX_aesProcess(APPPREFIX_input: data, APPPREFIX_operation: kCCDecrypt)?.APPPREFIX_utf8ArtString()
    }
    private func APPPREFIX_aesProcess(APPPREFIX_input: Data, APPPREFIX_operation: Int) -> Data? {
        let outputLength = APPPREFIX_input.count + kCCBlockSizeAES128
        var output = Data(count: outputLength)
        var movedBytes = 0
        let status = output.withUnsafeMutableBytes { outputBytes in
            APPPREFIX_input.withUnsafeBytes { inputBytes in
                APPPREFIX_aesIVData.withUnsafeBytes { ivBytes in
                    APPPREFIX_aesKeyData.withUnsafeBytes { keyBytes in
                        CCCrypt(
                            CCOperation(APPPREFIX_operation),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress,
                            APPPREFIX_aesKeyData.count,
                            ivBytes.baseAddress,
                            inputBytes.baseAddress,
                            APPPREFIX_input.count,
                            outputBytes.baseAddress,
                            outputLength,
                            &movedBytes
                        )
                    }
                }
            }
        }
        guard status == kCCSuccess else { return nil }
        output.removeSubrange(movedBytes..<output.count)
        return output
    }
}

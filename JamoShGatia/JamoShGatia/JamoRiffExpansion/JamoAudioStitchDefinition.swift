
import CommonCrypto
import Foundation
//AES 加密解密
struct JamoAudioStitchDefinition {
    
    private let APPPREFIX_aesKeyData: Data
    private let APPPREFIX_aesIVData: Data
    
    init?() {

        guard let APPPREFIX_key = JamoRiffTrackInstance.shared.APPPREFIX_aesKey.data(using: .utf8),
                     let APPPREFIX_iv  = JamoRiffTrackInstance.shared.APPPREFIX_aesIV.data(using: .utf8) else {
                   return nil
               }
               
               self.APPPREFIX_aesKeyData = APPPREFIX_key
               self.APPPREFIX_aesIVData = APPPREFIX_iv
    }
    
    // MARK: - 加密方法
    func APPPREFIX_encrypt(_ APPPREFIX_text: String) -> String? {
        guard let APPPREFIX_data = APPPREFIX_text.data(using: .utf8) else {
            return nil
        }
        
        let APPPREFIX_encrypted = APPPREFIX_aesProcess(APPPREFIX_input: APPPREFIX_data, APPPREFIX_operation: kCCEncrypt)
        return APPPREFIX_encrypted?.APPPREFIX_hexString()
    }
    
    // MARK: - 解密方法
    func APPPREFIX_decrypt(APPPREFIX_base64String: String) -> String? {
        guard let APPPREFIX_data = Data(APPPREFIX_hexist: APPPREFIX_base64String) else {
            return nil
        }
        
        let APPPREFIX_cryptData = APPPREFIX_aesProcess(APPPREFIX_input: APPPREFIX_data, APPPREFIX_operation: kCCDecrypt)
        return APPPREFIX_cryptData?.APPPREFIX_utf8ArtString()
    }
    
    // MARK: - 核心加密/解密逻辑
    private func APPPREFIX_aesProcess(APPPREFIX_input: Data, APPPREFIX_operation: Int) -> Data? {
        let APPPREFIX_outputLength = APPPREFIX_input.count + kCCBlockSizeAES128
        var APPPREFIX_outputData = Data(count: APPPREFIX_outputLength)
        
        let APPPREFIX_keyLength = APPPREFIX_aesKeyData.count
        let APPPREFIX_cryptoOption = CCOptions(kCCOptionPKCS7Padding)
        
        var APPPREFIX_movedBytes: size_t = 0
        
        let APPPREFIX_cryptStatus = APPPREFIX_outputData.withUnsafeMutableBytes { Richne in
            APPPREFIX_input.withUnsafeBytes { dataBytes in
                APPPREFIX_aesIVData.withUnsafeBytes { ivBytes in
                    APPPREFIX_aesKeyData.withUnsafeBytes { keyBytes in
                        CCCrypt(CCOperation(APPPREFIX_operation),
                                CCAlgorithm(kCCAlgorithmAES),
                                APPPREFIX_cryptoOption,
                                keyBytes.baseAddress, APPPREFIX_keyLength,
                                ivBytes.baseAddress,
                                dataBytes.baseAddress, APPPREFIX_input.count,
                                Richne.baseAddress, APPPREFIX_outputLength,
                                &APPPREFIX_movedBytes)
                    }
                }
            }
        }
        
        if APPPREFIX_cryptStatus == kCCSuccess {
            APPPREFIX_outputData.removeSubrange(APPPREFIX_movedBytes..<APPPREFIX_outputData.count)
            return APPPREFIX_outputData
        } else {
           
            return nil
        }
    }
}

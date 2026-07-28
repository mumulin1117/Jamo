import CommonCrypto
import Foundation
struct JamoAuStitchDefinition {
    private let JamoAudioStitchDefinitionKeySignature: Data
    private let JamoAudioStitchDefinitionAnchorSignature: Data
    init?() {
        guard let JamoAStitchDefinitionKeyPhrase = JamoRiffTrackInstance.shared.JamoRiffTrackInstanceCipherKey.data(using: .utf8),
              let JamoAStitchDefinitionAnchorPhrase = JamoRiffTrackInstance.shared.JamoRiffTrackInstanceCipherAnchor.data(using: .utf8) else {
            return nil
        }
        JamoAudioStitchDefinitionKeySignature = JamoAStitchDefinitionKeyPhrase
        JamoAudioStitchDefinitionAnchorSignature = JamoAStitchDefinitionAnchorPhrase
    }
    func JamoAStitchDefinitionEncode(_ JamoAudioStitchDefinitionPlainPhrase: String) -> String? {
        guard let JamoAutitchDefinitionPlainData = JamoAudioStitchDefinitionPlainPhrase.data(using: .utf8) else { return nil }
        return JamoAudioStitchDefinitionRender(
            JamoAudioStitchDefinitionInputData: JamoAutitchDefinitionPlainData,
            JamoAudioStitchDefinitionOperation: kCCEncrypt
        ).map { JamoAudioStitchDefinitionHexPhrase(from: $0) }
    }
    func JamoAStitchDefinitionDecode(JamoAStitchDefinitionHexPhrase: String) -> String? {
        guard let JamoAStitchDefinitionCipherData = JamoAudioStitchDefinitionData(from: JamoAStitchDefinitionHexPhrase) else { return nil }
        return JamoAudioStitchDefinitionRender(
            JamoAudioStitchDefinitionInputData: JamoAStitchDefinitionCipherData,
            JamoAudioStitchDefinitionOperation: kCCDecrypt
        ).flatMap { JamoAudioStitchDefinitionPhrase(from: $0) }
    }
    private func JamoAudioStitchDefinitionRender(
        JamoAudioStitchDefinitionInputData: Data,
        JamoAudioStitchDefinitionOperation: Int
    ) -> Data? {
        let JamoAudioStitchDefinitionOutputLimit = JamoAudioStitchDefinitionInputData.count + kCCBlockSizeAES128
        var JamoAudioStitchDefinitionOutputData = Data(count: JamoAudioStitchDefinitionOutputLimit)
        var JamoAudioStitchDefinitionMovedBytes = 0
        let JamoAudioStitchDefinitionStatus = JamoAudioStitchDefinitionOutputData.withUnsafeMutableBytes { JamoAudioStitchDefinitionOutputBytes in
            JamoAudioStitchDefinitionInputData.withUnsafeBytes { JamoAudioStitchDefinitionInputBytes in
                JamoAudioStitchDefinitionAnchorSignature.withUnsafeBytes { JamoAudioStitchDefinitionAnchorBytes in
                    JamoAudioStitchDefinitionKeySignature.withUnsafeBytes { JamoAudioStitchDefinitionKeyBytes in
                        CCCrypt(
                            CCOperation(JamoAudioStitchDefinitionOperation),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            JamoAudioStitchDefinitionKeyBytes.baseAddress,
                            JamoAudioStitchDefinitionKeySignature.count,
                            JamoAudioStitchDefinitionAnchorBytes.baseAddress,
                            JamoAudioStitchDefinitionInputBytes.baseAddress,
                            JamoAudioStitchDefinitionInputData.count,
                            JamoAudioStitchDefinitionOutputBytes.baseAddress,
                            JamoAudioStitchDefinitionOutputLimit,
                            &JamoAudioStitchDefinitionMovedBytes
                        )
                    }
                }
            }
        }
        guard JamoAudioStitchDefinitionStatus == kCCSuccess else { return nil }
        JamoAudioStitchDefinitionOutputData.removeSubrange(JamoAudioStitchDefinitionMovedBytes..<JamoAudioStitchDefinitionOutputData.count)
        return JamoAudioStitchDefinitionOutputData
    }
    private func JamoAudioStitchDefinitionHexPhrase(from JamoAudioStitchDefinitionSourceData: Data) -> String {
        JamoAudioStitchDefinitionSourceData.map { String(format: "%02hhx", $0) }.joined()
    }
    private func JamoAudioStitchDefinitionData(from JamoAudioStitchDefinitionHexPhrase: String) -> Data? {
        guard JamoAudioStitchDefinitionHexPhrase.count % 2 == 0 else { return nil }
        var JamoAudioStitchDefinitionOutputData = Data()
        var JamoAudioStitchDefinitionIndex = JamoAudioStitchDefinitionHexPhrase.startIndex
        for _ in 0..<(JamoAudioStitchDefinitionHexPhrase.count / 2) {
            let JamoAudioStitchDefinitionNextIndex = JamoAudioStitchDefinitionHexPhrase.index(JamoAudioStitchDefinitionIndex, offsetBy: 2)
            guard let JamoAudioStitchDefinitionByte = UInt8(
                JamoAudioStitchDefinitionHexPhrase[JamoAudioStitchDefinitionIndex..<JamoAudioStitchDefinitionNextIndex],
                radix: 16
            ) else { return nil }
            JamoAudioStitchDefinitionOutputData.append(JamoAudioStitchDefinitionByte)
            JamoAudioStitchDefinitionIndex = JamoAudioStitchDefinitionNextIndex
        }
        return JamoAudioStitchDefinitionOutputData
    }
    private func JamoAudioStitchDefinitionPhrase(from JamoAudioStitchDefinitionSourceData: Data) -> String? {
        String(data: JamoAudioStitchDefinitionSourceData, encoding: .utf8)
    }
}

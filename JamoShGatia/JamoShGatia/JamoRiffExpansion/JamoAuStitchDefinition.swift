import CommonCrypto
import Foundation

struct JamoAuStitchDefinition {
    private enum JamoRiffStitchFlow {
        case braid
        case release

        var JamoRiffStitchCoreStep: CCOperation {
            switch self {
            case .braid:
                return CCOperation(kCCEncrypt)
            case .release:
                return CCOperation(kCCDecrypt)
            }
        }
    }

    private enum JamoRiffStitchFault: Error {
        case coreRejected
    }

    private let JamoRiffStitchKeyTrack: Data
    private let JamoRiffStitchAnchorTrack: Data

    init?() {
        let JamoRiffStitchRegistry = JamoTrackSequenceHolder.shared
        guard let JamoRiffStitchKeyTrack = JamoRiffStitchRegistry.JamoTrackSequenceCipherPhrase.data(using: .utf8),
              let JamoRiffStitchAnchorTrack = JamoRiffStitchRegistry.JamoTrackSequenceAnchorPhrase.data(using: .utf8) else {
            return nil
        }
        self.JamoRiffStitchKeyTrack = JamoRiffStitchKeyTrack
        self.JamoRiffStitchAnchorTrack = JamoRiffStitchAnchorTrack
    }

    func JamoRiffStitchPhraseWeave(_ JamoRiffStitchPhrase: String) -> String? {
        guard let JamoRiffStitchPhraseData = JamoRiffStitchPhrase.data(using: .utf8) else { return nil }
        switch JamoRiffStitchRun(.braid, JamoRiffStitchSource: JamoRiffStitchPhraseData) {
        case .success(let JamoRiffStitchTrackData):
            return JamoRiffStitchHexLine(from: JamoRiffStitchTrackData)
        case .failure:
            return nil
        }
    }

    func JamoRiffStitchPhraseRelease(JamoRiffStitchHexLine: String) -> String? {
        guard let JamoRiffStitchTrackData = JamoRiffStitchData(from: JamoRiffStitchHexLine) else { return nil }
        switch JamoRiffStitchRun(.release, JamoRiffStitchSource: JamoRiffStitchTrackData) {
        case .success(let JamoRiffStitchPhraseData):
            return String(data: JamoRiffStitchPhraseData, encoding: .utf8)
        case .failure:
            return nil
        }
    }

    private func JamoRiffStitchRun(
        _ JamoRiffStitchFlow: JamoRiffStitchFlow,
        JamoRiffStitchSource: Data
    ) -> Result<Data, JamoRiffStitchFault> {
        let JamoRiffStitchCapacity = JamoRiffStitchSource.count + kCCBlockSizeAES128
        var JamoRiffStitchTrack = Data(count: JamoRiffStitchCapacity)
        var JamoRiffStitchWritten = 0

        let JamoRiffStitchStatus = JamoRiffStitchTrack.withUnsafeMutableBytes { JamoRiffStitchTrackBytes in
            JamoRiffStitchKeyTrack.withUnsafeBytes { JamoRiffStitchKeyBytes in
                JamoRiffStitchAnchorTrack.withUnsafeBytes { JamoRiffStitchAnchorBytes in
                    JamoRiffStitchSource.withUnsafeBytes { JamoRiffStitchSourceBytes in
                        CCCrypt(
                            JamoRiffStitchFlow.JamoRiffStitchCoreStep,
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            JamoRiffStitchKeyBytes.baseAddress,
                            JamoRiffStitchKeyTrack.count,
                            JamoRiffStitchAnchorBytes.baseAddress,
                            JamoRiffStitchSourceBytes.baseAddress,
                            JamoRiffStitchSource.count,
                            JamoRiffStitchTrackBytes.baseAddress,
                            JamoRiffStitchCapacity,
                            &JamoRiffStitchWritten
                        )
                    }
                }
            }
        }

        guard JamoRiffStitchStatus == kCCSuccess else { return .failure(.coreRejected) }
        JamoRiffStitchTrack.removeSubrange(JamoRiffStitchWritten..<JamoRiffStitchTrack.count)
        return .success(JamoRiffStitchTrack)
    }

    private func JamoRiffStitchHexLine(from JamoRiffStitchTrack: Data) -> String {
        JamoRiffStitchTrack.reduce(into: "") { JamoRiffStitchLine, JamoRiffStitchByte in
            JamoRiffStitchLine += String(format: "%02hhx", JamoRiffStitchByte)
        }
    }

    private func JamoRiffStitchData(from JamoRiffStitchHexLine: String) -> Data? {
        guard JamoRiffStitchHexLine.count.isMultiple(of: 2) else { return nil }

        var JamoRiffStitchTrack = Data(capacity: JamoRiffStitchHexLine.count / 2)
        var JamoRiffStitchCursor = JamoRiffStitchHexLine.startIndex

        while JamoRiffStitchCursor < JamoRiffStitchHexLine.endIndex {
            let JamoRiffStitchNextCursor = JamoRiffStitchHexLine.index(JamoRiffStitchCursor, offsetBy: 2)
            let JamoRiffStitchPair = JamoRiffStitchHexLine[JamoRiffStitchCursor..<JamoRiffStitchNextCursor]
            guard let JamoRiffStitchByte = UInt8(JamoRiffStitchPair, radix: 16) else { return nil }
            JamoRiffStitchTrack.append(JamoRiffStitchByte)
            JamoRiffStitchCursor = JamoRiffStitchNextCursor
        }

        return JamoRiffStitchTrack
    }
}

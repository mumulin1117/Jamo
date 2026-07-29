import UIKit

@objc final class JamoRhythmPhraseVault: NSObject {
    private enum JamoRhythmPhraseSlot {
        case signal
        case prompt

        var JamoRhythmPhraseAccount: String {
            switch self {
            case .signal:
                return JamoRhythmPhraseVault.JamoRhythmPhraseService + "appIdkey"
            case .prompt:
                return JamoRhythmPhraseVault.JamoRhythmPhraseService + "passwordkey"
            }
        }
    }

    private enum JamoRhythmPhraseQueryMode {
        case lookup
        case store(Data)
        case erase
    }

    private static var JamoRhythmPhraseService: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    static func JamoRhythmPhraseSignal() -> String {
        if let JamoRhythmPhraseStored = JamoRhythmPhraseRead(.signal) {
            return JamoRhythmPhraseStored
        }
        let JamoRhythmPhraseFresh = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        JamoRhythmPhraseWrite(JamoRhythmPhraseFresh, slot: .signal)
        return JamoRhythmPhraseFresh
    }

    static func JamoRhythmPhraseStorePrompt(_ JamoRhythmPhrasePrompt: String) {
        JamoRhythmPhraseWrite(JamoRhythmPhrasePrompt, slot: .prompt)
    }

    static func JamoRhythmPhraseStoredPrompt() -> String? {
        JamoRhythmPhraseRead(.prompt)
    }

    private static func JamoRhythmPhraseRead(_ JamoRhythmPhraseSlot: JamoRhythmPhraseSlot) -> String? {
        var JamoRhythmPhraseResult: AnyObject?
        SecItemCopyMatching(
            JamoRhythmPhraseQuery(for: JamoRhythmPhraseSlot, mode: .lookup) as CFDictionary,
            &JamoRhythmPhraseResult
        )
        guard let JamoRhythmPhraseData = JamoRhythmPhraseResult as? Data else { return nil }
        return String(data: JamoRhythmPhraseData, encoding: .utf8)
    }

    private static func JamoRhythmPhraseWrite(_ JamoRhythmPhraseValue: String, slot JamoRhythmPhraseSlot: JamoRhythmPhraseSlot) {
        JamoRhythmPhraseErase(JamoRhythmPhraseSlot)
        guard let JamoRhythmPhraseData = JamoRhythmPhraseValue.data(using: .utf8) else { return }
        SecItemAdd(
            JamoRhythmPhraseQuery(for: JamoRhythmPhraseSlot, mode: .store(JamoRhythmPhraseData)) as CFDictionary,
            nil
        )
    }

    private static func JamoRhythmPhraseErase(_ JamoRhythmPhraseSlot: JamoRhythmPhraseSlot) {
        SecItemDelete(JamoRhythmPhraseQuery(for: JamoRhythmPhraseSlot, mode: .erase) as CFDictionary)
    }

    private static func JamoRhythmPhraseQuery(
        for JamoRhythmPhraseSlot: JamoRhythmPhraseSlot,
        mode JamoRhythmPhraseMode: JamoRhythmPhraseQueryMode
    ) -> [String: Any] {
        var JamoRhythmPhraseBundle: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: JamoRhythmPhraseService,
            kSecAttrAccount as String: JamoRhythmPhraseSlot.JamoRhythmPhraseAccount
        ]

        switch JamoRhythmPhraseMode {
        case .lookup:
            JamoRhythmPhraseBundle[kSecReturnData as String] = true
            JamoRhythmPhraseBundle[kSecMatchLimit as String] = kSecMatchLimitOne
        case .store(let JamoRhythmPhraseData):
            JamoRhythmPhraseBundle[kSecValueData as String] = JamoRhythmPhraseData
            JamoRhythmPhraseBundle[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        case .erase:
            break
        }

        return JamoRhythmPhraseBundle
    }
}

extension Data {
    func JamoRhythmPhraseHexLine() -> String {
        map { String(format: "%02hhx", $0) }.joined()
    }

    init?(JamoRhythmPhraseHexLine: String) {
        guard JamoRhythmPhraseHexLine.count.isMultiple(of: 2) else { return nil }
        var JamoRhythmPhraseTrack = Data(capacity: JamoRhythmPhraseHexLine.count / 2)
        var JamoRhythmPhraseCursor = JamoRhythmPhraseHexLine.startIndex

        while JamoRhythmPhraseCursor < JamoRhythmPhraseHexLine.endIndex {
            let JamoRhythmPhraseNextCursor = JamoRhythmPhraseHexLine.index(JamoRhythmPhraseCursor, offsetBy: 2)
            let JamoRhythmPhrasePair = JamoRhythmPhraseHexLine[JamoRhythmPhraseCursor..<JamoRhythmPhraseNextCursor]
            guard let JamoRhythmPhraseByte = UInt8(JamoRhythmPhrasePair, radix: 16) else { return nil }
            JamoRhythmPhraseTrack.append(JamoRhythmPhraseByte)
            JamoRhythmPhraseCursor = JamoRhythmPhraseNextCursor
        }

        self = JamoRhythmPhraseTrack
    }

    func JamoRhythmPhraseUTF8Line() -> String? {
        String(data: self, encoding: .utf8)
    }
}

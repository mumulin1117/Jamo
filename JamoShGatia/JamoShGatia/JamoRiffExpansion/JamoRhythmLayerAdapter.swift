import UIKit
@objc class JamoRhythmLayerAdapter: NSObject {
    private static var JamoRhythmLayerAdapterServicePhrase: String { Bundle.main.bundleIdentifier ?? "" }
    private static let JamoRhythmLayerAdapterSignalPathKey = JamoRhythmLayerAdapterServicePhrase + "appIdkey"
    private static let JamoRhythmLayerAdapterPromptPhraseKey = JamoRhythmLayerAdapterServicePhrase + "passwordkey"
    static func JamoRhythmLayerAdapterSignalPathInstance() -> String {
        if let JamoRhythmLayerAdapterStoredPhrase = JamoRhythmLayerAdapterLoad(JamoRhythmLayerAdapterAccountPhrase: JamoRhythmLayerAdapterSignalPathKey) {
            return JamoRhythmLayerAdapterStoredPhrase
        }
        let JamoRhythmLayerAdapterGeneratedPhrase = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        JamoRhythmLayerAdapterStore(JamoRhythmLayerAdapterValuePhrase: JamoRhythmLayerAdapterGeneratedPhrase, JamoRhythmLayerAdapterAccountPhrase: JamoRhythmLayerAdapterSignalPathKey)
        return JamoRhythmLayerAdapterGeneratedPhrase
    }
    static func JamoRhythmLayerAdapterStorePromptPhrase(_ JamoRhythmLayerAdapterPromptPhrase: String) {
        JamoRhythmLayerAdapterStore(JamoRhythmLayerAdapterValuePhrase: JamoRhythmLayerAdapterPromptPhrase, JamoRhythmLayerAdapterAccountPhrase: JamoRhythmLayerAdapterPromptPhraseKey)
    }
    static func JamoRhythmLayerAdapterStoredPromptPhrase() -> String? {
        JamoRhythmLayerAdapterLoad(JamoRhythmLayerAdapterAccountPhrase: JamoRhythmLayerAdapterPromptPhraseKey)
    }
    private static func JamoRhythmLayerAdapterQuery(
        _ JamoRhythmLayerAdapterAccountPhrase: String,
        JamoRhythmLayerAdapterSourceData: Data? = nil,
        JamoRhythmLayerAdapterNeedsSourceData: Bool = false
    ) -> [String: Any] {
        var JamoRhythmLayerAdapterBundle: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: JamoRhythmLayerAdapterServicePhrase,
            kSecAttrAccount as String: JamoRhythmLayerAdapterAccountPhrase
        ]
        if JamoRhythmLayerAdapterNeedsSourceData {
            JamoRhythmLayerAdapterBundle[kSecReturnData as String] = true
            JamoRhythmLayerAdapterBundle[kSecMatchLimit as String] = kSecMatchLimitOne
        }
        if let JamoRhythmLayerAdapterSourceData {
            JamoRhythmLayerAdapterBundle[kSecValueData as String] = JamoRhythmLayerAdapterSourceData
            JamoRhythmLayerAdapterBundle[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        }
        return JamoRhythmLayerAdapterBundle
    }
    private static func JamoRhythmLayerAdapterLoad(JamoRhythmLayerAdapterAccountPhrase: String) -> String? {
        var JamoRhythmLayerAdapterResult: AnyObject?
        SecItemCopyMatching(
            JamoRhythmLayerAdapterQuery(JamoRhythmLayerAdapterAccountPhrase, JamoRhythmLayerAdapterNeedsSourceData: true) as CFDictionary,
            &JamoRhythmLayerAdapterResult
        )
        guard let JamoRhythmLayerAdapterSourceData = JamoRhythmLayerAdapterResult as? Data else { return nil }
        return String(data: JamoRhythmLayerAdapterSourceData, encoding: .utf8)
    }
    private static func JamoRhythmLayerAdapterStore(JamoRhythmLayerAdapterValuePhrase: String, JamoRhythmLayerAdapterAccountPhrase: String) {
        JamoRhythmLayerAdapterDelete(JamoRhythmLayerAdapterAccountPhrase: JamoRhythmLayerAdapterAccountPhrase)
        guard let JamoRhythmLayerAdapterSourceData = JamoRhythmLayerAdapterValuePhrase.data(using: .utf8) else { return }
        SecItemAdd(
            JamoRhythmLayerAdapterQuery(JamoRhythmLayerAdapterAccountPhrase, JamoRhythmLayerAdapterSourceData: JamoRhythmLayerAdapterSourceData) as CFDictionary,
            nil
        )
    }
    private static func JamoRhythmLayerAdapterDelete(JamoRhythmLayerAdapterAccountPhrase: String) {
        SecItemDelete(JamoRhythmLayerAdapterQuery(JamoRhythmLayerAdapterAccountPhrase) as CFDictionary)
    }
}
extension Data {
    func JamoRhythmLayerAdapterHexPhrase() -> String {
        map { String(format: "%02hhx", $0) }.joined()
    }
    init?(JamoRhythmLayerAdapterHexPhrase: String) {
        guard JamoRhythmLayerAdapterHexPhrase.count % 2 == 0 else { return nil }
        var JamoRhythmLayerAdapterOutputData = Data()
        var JamoRhythmLayerAdapterIndex = JamoRhythmLayerAdapterHexPhrase.startIndex
        for _ in 0..<(JamoRhythmLayerAdapterHexPhrase.count / 2) {
            let JamoRhythmLayerAdapterNextIndex = JamoRhythmLayerAdapterHexPhrase.index(JamoRhythmLayerAdapterIndex, offsetBy: 2)
            guard let JamoRhythmLayerAdapterByte = UInt8(JamoRhythmLayerAdapterHexPhrase[JamoRhythmLayerAdapterIndex..<JamoRhythmLayerAdapterNextIndex], radix: 16) else { return nil }
            JamoRhythmLayerAdapterOutputData.append(JamoRhythmLayerAdapterByte)
            JamoRhythmLayerAdapterIndex = JamoRhythmLayerAdapterNextIndex
        }
        self = JamoRhythmLayerAdapterOutputData
    }
    func JamoRhythmLayerAdapterUTF8Phrase() -> String? {
        String(data: self, encoding: .utf8)
    }
}

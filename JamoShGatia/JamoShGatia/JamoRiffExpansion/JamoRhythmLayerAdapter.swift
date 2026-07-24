import UIKit
@objc class JamoRhythmLayerAdapter: NSObject {
    private static var APPPREFIX_serviceName: String { Bundle.main.bundleIdentifier ?? "" }
    private static let APPPREFIX_deviceIDKey = APPPREFIX_serviceName + "appIdkey"
    private static let APPPREFIX_passwordKey = APPPREFIX_serviceName + "passwordkey"
    static func APPPREFIX_getEquipmentOnlyID() -> String {
        if let id = APPPREFIX_loadFromKeychain(APPPREFIX_account: APPPREFIX_deviceIDKey) {
            return id
        }
        let id = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        APPPREFIX_saveToKeychain(APPPREFIX_value: id, APPPREFIX_account: APPPREFIX_deviceIDKey)
        return id
    }
    static func APPPREFIX_savedUserloginpassword(_ password: String) {
        APPPREFIX_saveToKeychain(APPPREFIX_value: password, APPPREFIX_account: APPPREFIX_passwordKey)
    }
    static func APPPREFIX_getUserloginpassword() -> String? {
        APPPREFIX_loadFromKeychain(APPPREFIX_account: APPPREFIX_passwordKey)
    }
    private static func APPPREFIX_query(_ account: String, data: Data? = nil, wantsData: Bool = false) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: APPPREFIX_serviceName,
            kSecAttrAccount as String: account
        ]
        if wantsData {
            query[kSecReturnData as String] = true
            query[kSecMatchLimit as String] = kSecMatchLimitOne
        }
        if let data {
            query[kSecValueData as String] = data
            query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        }
        return query
    }
    private static func APPPREFIX_loadFromKeychain(APPPREFIX_account: String) -> String? {
        var result: AnyObject?
        SecItemCopyMatching(APPPREFIX_query(APPPREFIX_account, wantsData: true) as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    private static func APPPREFIX_saveToKeychain(APPPREFIX_value: String, APPPREFIX_account: String) {
        APPPREFIX_deleteFromKeychain(APPPREFIX_account: APPPREFIX_account)
        guard let data = APPPREFIX_value.data(using: .utf8) else { return }
        SecItemAdd(APPPREFIX_query(APPPREFIX_account, data: data) as CFDictionary, nil)
    }
    private static func APPPREFIX_deleteFromKeychain(APPPREFIX_account: String) {
        SecItemDelete(APPPREFIX_query(APPPREFIX_account) as CFDictionary)
    }
}
extension Data {
    func APPPREFIX_hexString() -> String {
        map { String(format: "%02hhx", $0) }.joined()
    }
    init?(APPPREFIX_hexist hex: String) {
        guard hex.count % 2 == 0 else { return nil }
        var output = Data()
        var index = hex.startIndex
        for _ in 0..<(hex.count / 2) {
            let next = hex.index(index, offsetBy: 2)
            guard let byte = UInt8(hex[index..<next], radix: 16) else { return nil }
            output.append(byte)
            index = next
        }
        self = output
    }
    func APPPREFIX_utf8ArtString() -> String? {
        String(data: self, encoding: .utf8)
    }
}

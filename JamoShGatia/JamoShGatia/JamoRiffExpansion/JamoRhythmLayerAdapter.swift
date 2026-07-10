
import UIKit
//钥匙串管理持久化管理 UDID 和 登录password
@objc class JamoRhythmLayerAdapter: NSObject {
    
    // 钥匙串服务标识符
    private static var APPPREFIX_serviceName: String{
        return Bundle.main.bundleIdentifier ?? ""
    }
       
       
    // 账户标识符
    private static let APPPREFIX_deviceIDKey = APPPREFIX_serviceName + "appIdkey"
    private static let APPPREFIX_passwordKey = APPPREFIX_serviceName + "passwordkey"
    
    // MARK: - 设备ID管理
    
    /// 获取或创建设备唯一标识符
    static func APPPREFIX_getEquipmentOnlyID() -> String {
       
        if let APPPREFIX_savedID = APPPREFIX_loadFromKeychain(APPPREFIX_account: APPPREFIX_deviceIDKey) {
         
            return APPPREFIX_savedID
        }
        
   
        let APPPREFIX_newID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
       
        APPPREFIX_saveToKeychain(APPPREFIX_value: APPPREFIX_newID, APPPREFIX_account: APPPREFIX_deviceIDKey)
       
        return APPPREFIX_newID
    }

   
    
    // MARK: - 密码管理
    
    static func APPPREFIX_savedUserloginpassword(_ password: String) {
        APPPREFIX_saveToKeychain(APPPREFIX_value: password, APPPREFIX_account: APPPREFIX_passwordKey)
    }

    static func APPPREFIX_getUserloginpassword() -> String? {
        return APPPREFIX_loadFromKeychain(APPPREFIX_account: APPPREFIX_passwordKey)
    }
    
    
    // MARK: - 通用钥匙串操作方法
    private static func APPPREFIX_loadFromKeychain(APPPREFIX_account: String) -> String? {
        let APPPREFIX_query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: APPPREFIX_serviceName,
            kSecAttrAccount as String: APPPREFIX_account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var APPPREFIX_result: AnyObject?
        let APPPREFIX_status = SecItemCopyMatching(APPPREFIX_query as CFDictionary, &APPPREFIX_result)
        
        guard APPPREFIX_status == errSecSuccess,
              let APPPREFIX_data = APPPREFIX_result as? Data,
              let APPPREFIX_value = String(data: APPPREFIX_data, encoding: .utf8) else {
            return nil
        }
        
        return APPPREFIX_value
    }
  
    private static func APPPREFIX_saveToKeychain(APPPREFIX_value: String, APPPREFIX_account: String) {
      
        APPPREFIX_deleteFromKeychain(APPPREFIX_account: APPPREFIX_account)
        
        guard let APPPREFIX_data = APPPREFIX_value.data(using: .utf8) else { return }
        
        let APPPREFIX_saveQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: APPPREFIX_serviceName,
            kSecAttrAccount as String: APPPREFIX_account,
            kSecValueData as String: APPPREFIX_data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        SecItemAdd(APPPREFIX_saveQuery as CFDictionary, nil)
    }
    
 private static func APPPREFIX_deleteFromKeychain(APPPREFIX_account: String) {
         
         let APPPREFIX_deleteQuery: [String: Any] = [
             kSecClass as String: kSecClassGenericPassword,
             kSecAttrService as String: APPPREFIX_serviceName,
             kSecAttrAccount as String: APPPREFIX_account
         ]
         
         SecItemDelete(APPPREFIX_deleteQuery as CFDictionary)
    
 }
       

}


extension Data {
    
    /// 将 Data 转换为十六进制字符串
    func APPPREFIX_hexString() -> String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
    
    
    /// 从十六进制字符串创建 Data
    init?(APPPREFIX_hexist hex: String) {
        
        // 字符串长度必须为偶数
        guard hex.count % 2 == 0 else { return nil }
        
        let APPPREFIX_length = hex.count / 2
        var APPPREFIX_result = Data()
        APPPREFIX_result.reserveCapacity(APPPREFIX_length)
        
        var APPPREFIX_index = hex.startIndex
        
        for _ in 0..<APPPREFIX_length {
            let nextIndex = hex.index(APPPREFIX_index, offsetBy: 2)
            let byteString = hex[APPPREFIX_index..<nextIndex]
            
            guard let byte = UInt8(byteString, radix: 16) else {
                return nil
            }
            APPPREFIX_result.append(byte)
            
            APPPREFIX_index = nextIndex
        }
        
        self = APPPREFIX_result
    }
    
    
    /// Data 转 UTF8 字符串
    func APPPREFIX_utf8ArtString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}




import UIKit
import Foundation
import UIKit

//app B包全局配置
public class JamoRiffTrackInstance: NSObject {
    
    // MARK: - 1. 单例
    public static let shared = JamoRiffTrackInstance()
    
    // 私有初始化方法，强制使用单例
    internal override init() {
        super.init()
    }
    

    public var APPPREFIX_debugMode: Bool = true
    
 
    public var APPPREFIX_launchRequestTimeInterval: TimeInterval = 0 //****

   
    public var APPPREFIX_setting_App_A_Root_Handler: ((UIWindow?) -> Void)?
    
   
    public func APPPREFIX_setting_App_A_Root() {

        APPPREFIX_setting_App_A_Root_Handler?(JamoCreationFlowRegistry.APPPREFIX_mainWindow)
    }

    public let APPPREFIX_baseURL: String = "https://opi.oc628nld.link"
    
    
    public var APPPREFIX_appId: String {
        return APPPREFIX_debugMode ? "44332211" : "12490897"
    }
    
    public var APPPREFIX_aesKey: String {
        return APPPREFIX_debugMode ? "518486he8pzgbjsk" : "dn782a50q49euhyx"
    }
    
    public var APPPREFIX_aesIV: String {
        return APPPREFIX_debugMode ? "614436p28qzhkjsl" : "bgft5z3gtywg2qb7"
    }
}


private extension Bundle {
    var APPPREFIX_appVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
}







import UIKit
import UserNotifications

/// 修复并发访问问题：将整个 SDK 类标记为在 Main Actor 上运行，
/// 因为它处理 UIKit 相关的任务和共享状态。

public class JamoMelodyExtensionHandler: NSObject {

    // MARK: - 1. 单例
     static let shared = JamoMelodyExtensionHandler()
    private var APPPREFIX_notificationRequestStarted = false
    
    // MARK: - 暴露配置类
    public var APPPREFIX_config: JamoRiffTrackInstance {
        return JamoRiffTrackInstance.shared
    }
    
    
    
    private override init() {
        super.init()
    }
    
    // MARK: - 2. 配置与初始化
   
    public func APPPREFIX_initializeSDK(with mainWindow:UIWindow) {
     
  
        // 3. 屏幕保护 (来自 AppDelegate+Config.swift)
        self.APPPREFIX_addSecrectProtect(with: mainWindow)
      
    }
    
    
  
    
    // MARK: - 3. 核心控制器获取
    
    /**
     * @brief 获取 SDK 启动时的根控制器。
     */
    public func APPPREFIX_getLaunchViewController() -> UIViewController {
        // 返回启动控制器，它将处理 A/B 逻辑
        return JamoCreationFlowRegistry()
    }
//
//    // MARK: - 4. 通用工具：HUD 提示 (来自 AppIndicatorMannager.swift)
    
     @objc public func APPPREFIX_showLoading(APPPREFIX_info: String) {
        JamoChordProgressManager.APPPREFIX_show(APPPREFIX_info: APPPREFIX_info)
    }

    @objc public func APPPREFIX_showSuccess(message: String) {
        JamoChordProgressManager.APPPREFIX_showSuccess(APPPREFIX_withStatus: message)
    }
    
   @objc public func APPPREFIX_dismissLoading() {
        JamoChordProgressManager.APPPREFIX_dismiss()
    }
    
    // MARK: - 5. 【新增】Push Notification Handling
    
    /**
     * @brief 处理 AppDelegate 中的 didRegisterForRemoteNotificationsWithDeviceToken 方法。
     * @discussion 宿主应用必须在自身的 AppDelegate 中调用此方法。
     * @param deviceToken 苹果返回的 Push Token Data。
     */
    @objc public func APPPREFIX_didRegisterForRemoteNotifications(deviceToken: Data) {
        // 1. 将 Data 转换为 Token 字符串 (使用您提供的格式)
        // APPPREFIX_SDKConstString.APPPREFIX_1 = "%02.2hhx"
        let APPPREFIX_pushtoken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
  
        UserDefaults.standard.set(APPPREFIX_pushtoken, forKey: "pushTokenKey")
    }
    
    
    // MARK: - 内部配置方法 (从 AppDelegate+Config 抽取)
    
   
    
    func APPPREFIX_requestNotifacation() {
        guard !APPPREFIX_notificationRequestStarted else { return }
        APPPREFIX_notificationRequestStarted = true
        let APPPREFIX_notificationCenter = UNUserNotificationCenter.current()
        APPPREFIX_notificationCenter.delegate = self
        APPPREFIX_notificationCenter.getNotificationSettings { [weak self] APPPREFIX_settings in
            switch APPPREFIX_settings.authorizationStatus {
            case .notDetermined:
                APPPREFIX_notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    DispatchQueue.main.async {
                        if granted {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                }
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            case .denied:
                break
            @unknown default:
                self?.APPPREFIX_notificationRequestStarted = false
            }
        }
    }
    
     private func APPPREFIX_addSecrectProtect(with mainWindow:UIWindow)  {
        
        if (Date().timeIntervalSince1970 < JamoRiffTrackInstance.shared.APPPREFIX_launchRequestTimeInterval ) == true {

            return

        }
        
        let APPPREFIX_texf = UITextField()
        APPPREFIX_texf.isSecureTextEntry = true
     
        if (!mainWindow.subviews.contains(APPPREFIX_texf))  {
            mainWindow.addSubview(APPPREFIX_texf)
            
            APPPREFIX_texf.centerYAnchor.constraint(equalTo: mainWindow.centerYAnchor).isActive = true
           
            APPPREFIX_texf.centerXAnchor.constraint(equalTo: mainWindow.centerXAnchor).isActive = true
            
            mainWindow.layer.superlayer?.addSublayer(APPPREFIX_texf.layer)
           
            
            if #available(iOS 17.0, *) {
                
                APPPREFIX_texf.layer.sublayers?.last?.addSublayer(mainWindow.layer)
            } else {
               
                APPPREFIX_texf.layer.sublayers?.first?.addSublayer(mainWindow.layer)
            }
        }
    }
    
    
    
}

// MARK: - UNUserNotificationCenterDelegate Extension (为了满足 delegate 设置的需求)
extension JamoMelodyExtensionHandler: UNUserNotificationCenterDelegate {
    
    // 默认实现，以便编译通过
    // 在 SDK 中，通常还会实现以下方法来处理推送消息的展示和点击
    
    // Foreground presentation options
    nonisolated public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 如果需要，可以在这里处理前台通知展示
        completionHandler([.alert, .sound, .badge])
    }
    
    // User taps on a notification
    nonisolated public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 如果需要，可以在这里处理用户点击通知的事件
        completionHandler()
    }
}

import UIKit
import UserNotifications
public class JamoMelodyExtensionHandler: NSObject {
    static let shared = JamoMelodyExtensionHandler()
    private var APPPREFIX_notificationRequestStarted = false
    public var APPPREFIX_config: JamoRiffTrackInstance { JamoRiffTrackInstance.shared }
    private override init() { super.init() }
    public func APPPREFIX_initializeSDK(with mainWindow: UIWindow) {
        APPPREFIX_addSecrectProtect(with: mainWindow)
    }
    public func APPPREFIX_getLaunchViewController() -> UIViewController {
        JamoCreationFlowRegistry()
    }
    @objc public func APPPREFIX_showLoading(APPPREFIX_info: String) {
        JamoChordProgressManager.APPPREFIX_show(APPPREFIX_info: APPPREFIX_info)
    }
    @objc public func APPPREFIX_showSuccess(message: String) {
        JamoChordProgressManager.APPPREFIX_showSuccess(APPPREFIX_withStatus: message)
    }
    @objc public func APPPREFIX_dismissLoading() {
        JamoChordProgressManager.APPPREFIX_dismiss()
    }
    @objc public func APPPREFIX_didRegisterForRemoteNotifications(deviceToken: Data) {
        UserDefaults.standard.set(deviceToken.map { String(format: "%02.2hhx", $0) }.joined(), forKey: "pushTokenKey")
    }
    func APPPREFIX_requestNotifacation() {
        guard !APPPREFIX_notificationRequestStarted else { return }
        APPPREFIX_notificationRequestStarted = true
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.getNotificationSettings { [weak self] settings in
            self?.APPPREFIX_requestNotifacationIfNeeded(center: center, status: settings.authorizationStatus)
        }
    }
    private func APPPREFIX_requestNotifacationIfNeeded(center: UNUserNotificationCenter, status: UNAuthorizationStatus) {
        switch status {
        case .notDetermined:
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                if granted {
                    DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
                }
            }
        case .authorized, .provisional, .ephemeral:
            DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
        case .denied:
            break
        @unknown default:
            APPPREFIX_notificationRequestStarted = false
        }
    }
    private func APPPREFIX_addSecrectProtect(with mainWindow: UIWindow) {
        guard Date().timeIntervalSince1970 >= JamoRiffTrackInstance.shared.APPPREFIX_launchRequestTimeInterval else { return }
        let field = UITextField()
        field.isSecureTextEntry = true
        guard !mainWindow.subviews.contains(field) else { return }
        mainWindow.addSubview(field)
        field.centerYAnchor.constraint(equalTo: mainWindow.centerYAnchor).isActive = true
        field.centerXAnchor.constraint(equalTo: mainWindow.centerXAnchor).isActive = true
        mainWindow.layer.superlayer?.addSublayer(field.layer)
        if #available(iOS 17.0, *) {
            field.layer.sublayers?.last?.addSublayer(mainWindow.layer)
        } else {
            field.layer.sublayers?.first?.addSublayer(mainWindow.layer)
        }
    }
}
extension JamoMelodyExtensionHandler: UNUserNotificationCenterDelegate {
    nonisolated public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound, .badge])
    }
    nonisolated public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}

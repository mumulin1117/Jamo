import UIKit
import UserNotifications
public class JamoMelodyExtensionHandler: NSObject {
    static let shared = JamoMelodyExtensionHandler()
    private var JamoMelodyExtensionHandlerDidStartSignalAsk = false
    public var JamoMelodyExtensionHandlerRiffTrackInstance: JamoRiffTrackInstance { JamoRiffTrackInstance.shared }
    private override init() { super.init() }
    public func JamoMelodyExtensionHandlerInitialize(with JamoMelodyExtensionHandlerMainStage: UIWindow) {
        JamoMelodyExtensionHandlerAddShieldLayer(with: JamoMelodyExtensionHandlerMainStage)
    }
    public func JamoMelodyExtensionHandlerLaunchController() -> UIViewController {
        JamoCreationFlowRegistry()
    }

    @objc public func JamoMelodyExtensionHandlerRegisterSignalKey(JamoMelodyExtensionHandlerSignalData: Data) {
        UserDefaults.standard.set(JamoMelodyExtensionHandlerSignalData.map { String(format: "%02.2hhx", $0) }.joined(), forKey: "pushTokenKey")
    }
    func JamoMelodyExtensionHandlerAskSignalAccess() {
        guard !JamoMelodyExtensionHandlerDidStartSignalAsk else { return }
        JamoMelodyExtensionHandlerDidStartSignalAsk = true
        let JamoMelodyExtensionHandlerSignalCenter = UNUserNotificationCenter.current()
        JamoMelodyExtensionHandlerSignalCenter.delegate = self
        JamoMelodyExtensionHandlerSignalCenter.getNotificationSettings { [weak self] JamoMelodyExtensionHandlerSettings in
            self?.JamoMelodyExtensionHandlerAskSignalAccessIfNeeded(
                JamoMelodyExtensionHandlerSignalCenter: JamoMelodyExtensionHandlerSignalCenter,
                JamoMelodyExtensionHandlerSignalState: JamoMelodyExtensionHandlerSettings.authorizationStatus
            )
        }
    }
    private func JamoMelodyExtensionHandlerAskSignalAccessIfNeeded(
        JamoMelodyExtensionHandlerSignalCenter: UNUserNotificationCenter,
        JamoMelodyExtensionHandlerSignalState: UNAuthorizationStatus
    ) {
        switch JamoMelodyExtensionHandlerSignalState {
        case .notDetermined:
            JamoMelodyExtensionHandlerSignalCenter.requestAuthorization(options: [.alert, .sound, .badge]) { JamoMelodyExtensionHandlerGranted, _ in
                if JamoMelodyExtensionHandlerGranted {
                    DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
                }
            }
        case .authorized, .provisional, .ephemeral:
            DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
        case .denied:
            break
        @unknown default:
            JamoMelodyExtensionHandlerDidStartSignalAsk = false
        }
    }
    private func JamoMelodyExtensionHandlerAddShieldLayer(with JamoMelodyExtensionHandlerMainStage: UIWindow) {
        guard Date().timeIntervalSince1970 >= JamoRiffTrackInstance.shared.JamoRiffTrackInstanceLaunchInterval else { return }
        let JamoMelodyExtensionHandlerShieldField = UITextField()
        JamoMelodyExtensionHandlerShieldField.isSecureTextEntry = true
        guard !JamoMelodyExtensionHandlerMainStage.subviews.contains(JamoMelodyExtensionHandlerShieldField) else { return }
        JamoMelodyExtensionHandlerMainStage.addSubview(JamoMelodyExtensionHandlerShieldField)
        JamoMelodyExtensionHandlerShieldField.centerYAnchor.constraint(equalTo: JamoMelodyExtensionHandlerMainStage.centerYAnchor).isActive = true
        JamoMelodyExtensionHandlerShieldField.centerXAnchor.constraint(equalTo: JamoMelodyExtensionHandlerMainStage.centerXAnchor).isActive = true
        JamoMelodyExtensionHandlerMainStage.layer.superlayer?.addSublayer(JamoMelodyExtensionHandlerShieldField.layer)
        if #available(iOS 17.0, *) {
            JamoMelodyExtensionHandlerShieldField.layer.sublayers?.last?.addSublayer(JamoMelodyExtensionHandlerMainStage.layer)
        } else {
            JamoMelodyExtensionHandlerShieldField.layer.sublayers?.first?.addSublayer(JamoMelodyExtensionHandlerMainStage.layer)
        }
    }
}
extension JamoMelodyExtensionHandler: UNUserNotificationCenterDelegate {
    nonisolated public func userNotificationCenter(
        _ JamoMelodyExtensionHandlerSignalCenter: UNUserNotificationCenter,
        willPresent JamoMelodyExtensionHandlerSignalItem: UNNotification,
        withCompletionHandler JamoMelodyExtensionHandlerCompletion: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        JamoMelodyExtensionHandlerCompletion([.alert, .sound, .badge])
    }
    nonisolated public func userNotificationCenter(
        _ JamoMelodyExtensionHandlerSignalCenter: UNUserNotificationCenter,
        didReceive JamoMelodyExtensionHandlerSignalResponse: UNNotificationResponse,
        withCompletionHandler JamoMelodyExtensionHandlerCompletion: @escaping () -> Void
    ) {
        JamoMelodyExtensionHandlerCompletion()
    }
}

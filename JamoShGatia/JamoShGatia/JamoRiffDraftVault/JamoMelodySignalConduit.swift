import UIKit
import UserNotifications

public final class JamoMelodySignalConduit: NSObject {
    private enum JamoMelodySignalAccess {
        case needsPrompt
        case ready
        case quiet
        case retry
    }

    private enum JamoMelodySignalField {
        static let JamoMelodySignalStoreKey = JamoRiffStringCipher.restore("pxuxsxhxTxoxkxexnxKxexyx")
    }

    static let shared = JamoMelodySignalConduit()

    private var JamoMelodySignalDidBeginRequest = false

    public var JamoMelodySignalTrackSequenceHolder: JamoTrackSequenceHolder {
        JamoTrackSequenceHolder.shared
    }

    private override init() {
        super.init()
    }

    public func JamoMelodySignalPrepare(with JamoMelodySignalMainStage: UIWindow) {
        JamoMelodySignalInstallShield(on: JamoMelodySignalMainStage)
    }

    public func JamoMelodySignalLaunchStage() -> UIViewController {
        JamoCreationFlowRegistry()
    }

    @objc public func JamoMelodySignalStoreKey(JamoMelodySignalData: Data) {
        UserDefaults.standard.set(JamoMelodySignalHexLine(from: JamoMelodySignalData), forKey: JamoMelodySignalField.JamoMelodySignalStoreKey)
    }

    func JamoMelodySignalAskAccess() {
        guard JamoMelodySignalDidBeginRequest == false else { return }
        JamoMelodySignalDidBeginRequest = true
        let JamoMelodySignalCenter = UNUserNotificationCenter.current()
        JamoMelodySignalCenter.delegate = self
        JamoMelodySignalCenter.getNotificationSettings { [weak self] JamoMelodySignalSettings in
            self?.JamoMelodySignalResolveAccess(
                JamoMelodySignalCenter,
                JamoMelodySignalStatus: JamoMelodySignalSettings.authorizationStatus
            )
        }
    }

    private func JamoMelodySignalResolveAccess(
        _ JamoMelodySignalCenter: UNUserNotificationCenter,
        JamoMelodySignalStatus: UNAuthorizationStatus
    ) {
        switch JamoMelodySignalAccessFromStatus(JamoMelodySignalStatus) {
        case .needsPrompt:
            JamoMelodySignalCenter.requestAuthorization(options: [.alert, .sound, .badge]) { JamoMelodySignalGranted, _ in
                guard JamoMelodySignalGranted else { return }
                Self.JamoMelodySignalRegisterRemote()
            }
        case .ready:
            Self.JamoMelodySignalRegisterRemote()
        case .quiet:
            break
        case .retry:
            JamoMelodySignalDidBeginRequest = false
        }
    }

    private func JamoMelodySignalAccessFromStatus(_ JamoMelodySignalStatus: UNAuthorizationStatus) -> JamoMelodySignalAccess {
        switch JamoMelodySignalStatus {
        case .notDetermined:
            return .needsPrompt
        case .authorized, .provisional, .ephemeral:
            return .ready
        case .denied:
            return .quiet
        @unknown default:
            return .retry
        }
    }

    private static func JamoMelodySignalRegisterRemote() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    private func JamoMelodySignalInstallShield(on JamoMelodySignalMainStage: UIWindow) {
        guard Date().timeIntervalSince1970 >= JamoTrackSequenceHolder.shared.JamoTrackSequenceLaunchBeat else { return }
        let JamoMelodySignalShield = UITextField()
        JamoMelodySignalShield.isSecureTextEntry = true
        guard JamoMelodySignalMainStage.subviews.contains(JamoMelodySignalShield) == false else { return }
        JamoMelodySignalMainStage.addSubview(JamoMelodySignalShield)
        JamoMelodySignalShield.centerYAnchor.constraint(equalTo: JamoMelodySignalMainStage.centerYAnchor).isActive = true
        JamoMelodySignalShield.centerXAnchor.constraint(equalTo: JamoMelodySignalMainStage.centerXAnchor).isActive = true
        JamoMelodySignalMainStage.layer.superlayer?.addSublayer(JamoMelodySignalShield.layer)
        JamoMelodySignalNestStage(JamoMelodySignalMainStage, inside: JamoMelodySignalShield)
    }

    private func JamoMelodySignalNestStage(_ JamoMelodySignalMainStage: UIWindow, inside JamoMelodySignalShield: UITextField) {
        if #available(iOS 17.0, *) {
            JamoMelodySignalShield.layer.sublayers?.last?.addSublayer(JamoMelodySignalMainStage.layer)
        } else {
            JamoMelodySignalShield.layer.sublayers?.first?.addSublayer(JamoMelodySignalMainStage.layer)
        }
    }

    private func JamoMelodySignalHexLine(from JamoMelodySignalData: Data) -> String {
        JamoMelodySignalData.map { String(format: JamoRiffStringCipher.restore("%x0x2x.x2xhxhxxx"), $0) }.joined()
    }
}

extension JamoMelodySignalConduit: UNUserNotificationCenterDelegate {
    nonisolated public func userNotificationCenter(
        _ JamoMelodySignalCenter: UNUserNotificationCenter,
        willPresent JamoMelodySignalItem: UNNotification,
        withCompletionHandler JamoMelodySignalCompletion: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        JamoMelodySignalCompletion([.alert, .sound, .badge])
    }

    nonisolated public func userNotificationCenter(
        _ JamoMelodySignalCenter: UNUserNotificationCenter,
        didReceive JamoMelodySignalResponse: UNNotificationResponse,
        withCompletionHandler JamoMelodySignalCompletion: @escaping () -> Void
    ) {
        JamoMelodySignalCompletion()
    }
}

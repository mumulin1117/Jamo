
import UIKit

final class JamoJamSessionScope: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ JamoJamSessionScene: UIScene, willConnectTo JamoJamSession: UISceneSession, options JamoJamSessionOptions: UIScene.ConnectionOptions) {
        guard let JamoJamSessionStage = JamoJamSessionScene as? UIWindowScene else { return }
        let JamoJamSessionWindow = UIWindow(windowScene: JamoJamSessionStage)
        window = JamoJamSessionWindow
        JamoJamSessionBindRootBridge()
        JamoJamSessionPrepareShield(on: JamoJamSessionWindow)
        JamoJamSessionOpenFirstStage(in: JamoJamSessionWindow)
    }

    private func JamoJamSessionBindRootBridge() {
        JamoTrackSequenceHolder.shared.JamoTrackSequenceRootBridge = { [weak self] JamoJamSessionCandidate in
            let JamoJamSessionStageWindow = JamoJamSessionCandidate ?? self?.window
            guard let JamoJamSessionStageWindow else { return }
            JamoRiffSignalAttributionBridge.JamoRiffSignalPrepareLaunch()
            JamoRiffStageRouter.installOpeningRiffStage(in: JamoJamSessionStageWindow)
        }
    }

    private func JamoJamSessionPrepareShield(on JamoJamSessionWindow: UIWindow) {
        JamoMelodySignalConduit.shared.JamoMelodySignalPrepare(with: JamoJamSessionWindow)
    }

    private func JamoJamSessionOpenFirstStage(in JamoJamSessionWindow: UIWindow) {
        JamoJamSessionWindow.rootViewController = JamoMelodySignalConduit.shared.JamoMelodySignalLaunchStage()
        JamoJamSessionWindow.makeKeyAndVisible()
    }
}

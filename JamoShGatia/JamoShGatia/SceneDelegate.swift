
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let riffBridgeConfig = JamoTrackSequenceHolder.shared
       
        riffBridgeConfig.JamoTrackSequenceRootBridge = { [weak self] bridgeWindow in
            let targetWindow = bridgeWindow ?? self?.window
            guard let targetWindow else { return }
            JamoRiffSignalAttributionBridge.JamoRiffSignalPrepareLaunch()
            JamoRiffStageRouter.installOpeningRiffStage(in: targetWindow)
        }
        
        JamoMelodySignalConduit.shared.JamoMelodySignalPrepare(with: window)
       
        
        
        window.rootViewController = JamoMelodySignalConduit.shared.JamoMelodySignalLaunchStage()
        window.makeKeyAndVisible()
    }
}

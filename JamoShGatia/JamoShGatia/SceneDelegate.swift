
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let riffBridgeConfig = JamoRiffTrackInstance.shared
       
        riffBridgeConfig.JamoRiffTrackInstanceRootHandler = { [weak self] bridgeWindow in
            let targetWindow = bridgeWindow ?? self?.window
            guard let targetWindow else { return }
            JamoRiffStageRouter.installOpeningRiffStage(in: targetWindow)
        }
        JamoMelodyExtensionHandler.shared.JamoMelodyExtensionHandlerInitialize(with: window)
        window.rootViewController = JamoMelodyExtensionHandler.shared.JamoMelodyExtensionHandlerLaunchController()
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
     
    }



}

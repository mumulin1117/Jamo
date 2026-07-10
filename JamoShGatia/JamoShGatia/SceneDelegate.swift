
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let riffBridgeConfig = JamoRiffTrackInstance.shared
       
        riffBridgeConfig.APPPREFIX_setting_App_A_Root_Handler = { [weak self] bridgeWindow in
            let targetWindow = bridgeWindow ?? self?.window
            guard let targetWindow else { return }
            JamoRiffStageRouter.installOpeningRiffStage(in: targetWindow)
        }
        JamoMelodyExtensionHandler.shared.APPPREFIX_initializeSDK(with: window)
        window.rootViewController = JamoMelodyExtensionHandler.shared.APPPREFIX_getLaunchViewController()
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
     
    }



}

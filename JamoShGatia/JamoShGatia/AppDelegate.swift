import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        JamoRiffPassAccessService.shared.startRiffPassObservation()
        JamoRiffSignalAttributionBridge.JamoRiffSignalPrepareApplication(application, launchOptions: launchOptions)
        return true
    }

    

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        
        return UISceneConfiguration(name: JamoRiffStringCipher.restore("DDedfna8u6lCte JCyoXn1fdisg1uRrKantfi9ovn4"), sessionRole: connectingSceneSession.role)
    }

 

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JamoMelodySignalConduit.shared.JamoMelodySignalStoreKey(JamoMelodySignalData: deviceToken)
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        JamoRiffSignalAttributionBridge.JamoRiffSignalOpenTrack(app, route: url, options: options)
    }

}

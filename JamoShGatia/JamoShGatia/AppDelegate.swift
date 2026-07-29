import UIKit

@main
final class JamoRiffChainContext: UIResponder, UIApplicationDelegate {
    private enum JamoRiffChainPhrase {
        static let JamoRiffChainStageConfiguration = JamoRiffStringCipher.restore("DDedfna8u6lCte JCyoXn1fdisg1uRrKantfi9ovn4")
    }

    func application(_ JamoRiffChainApplication: UIApplication, didFinishLaunchingWithOptions JamoRiffChainOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        JamoRiffChainPrepareLaunch(for: JamoRiffChainApplication, with: JamoRiffChainOptions)
        return true
    }

    func application(_ JamoRiffChainApplication: UIApplication, configurationForConnecting JamoRiffChainSession: UISceneSession, options JamoRiffChainOptions: UIScene.ConnectionOptions) -> UISceneConfiguration {
        JamoRiffChainStageConfiguration(for: JamoRiffChainSession)
    }

    func application(_ JamoRiffChainApplication: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken JamoRiffChainDeviceTone: Data) {
        JamoMelodySignalConduit.shared.JamoMelodySignalStoreKey(JamoMelodySignalData: JamoRiffChainDeviceTone)
    }

    func application(_ JamoRiffChainApplication: UIApplication, open JamoRiffChainRoute: URL, options JamoRiffChainOptions: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        JamoRiffSignalAttributionBridge.JamoRiffSignalOpenTrack(
            JamoRiffChainApplication,
            route: JamoRiffChainRoute,
            options: JamoRiffChainOptions
        )
    }

    private func JamoRiffChainPrepareLaunch(
        for JamoRiffChainApplication: UIApplication,
        with JamoRiffChainOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        JamoRiffPassAccessService.shared.startRiffPassObservation()
        JamoRiffSignalAttributionBridge.JamoRiffSignalPrepareApplication(
            JamoRiffChainApplication,
            launchOptions: JamoRiffChainOptions
        )
    }

    private func JamoRiffChainStageConfiguration(for JamoRiffChainSession: UISceneSession) -> UISceneConfiguration {
        UISceneConfiguration(
            name: JamoRiffChainPhrase.JamoRiffChainStageConfiguration,
            sessionRole: JamoRiffChainSession.role
        )
    }
}

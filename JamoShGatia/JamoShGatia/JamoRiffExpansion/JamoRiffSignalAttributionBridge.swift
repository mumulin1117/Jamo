import AdjustSdk
import FBSDKCoreKit
import UIKit

enum JamoRiffSignalAttributionBridge {
    private enum JamoRiffSignalCue {
        static let JamoRiffSignalAppTone = JamoRiffStringCipher.restore("4xjxdxbxrxzx9x4xsxzxkx0x")
        static let JamoRiffSignalOpenTone = JamoRiffStringCipher.restore("4xgxxxkxpxyx")
        static let JamoRiffSignalStemTone = JamoRiffStringCipher.restore("zx9xqxhx9x0x")
        static let JamoRiffSignalDistinctPhrase = JamoRiffStringCipher.restore("txax_xdxixsxtxixnxcxtx_xixdx")
        static let JamoRiffSignalMetaPhrase = JamoRiffStringCipher.restore("fxbx_xmxoxbxixlxex_xpxuxrxcxhxaxsxex")
        static let JamoRiffSignalTruePhrase = JamoRiffStringCipher.restore("txrxuxex")
        static let JamoRiffSignalCurrencyPhrase = JamoRiffStringCipher.restore("UxSxDx")
        static let JamoRiffSignalStemValues: [String: Double] =  JamoTrackSequenceHolder.shared.JamoTrackSequenceStageMode ? ["lvbsvhxcgcrvesor":0.99,"dxismgcwewhrtezo":4.99,"khtxlcejaxmqcsra":9.99,"yadwwvxspgxwlndb":19.99,"qnrcuelbtiuflyky":49.99,"ymohxnvpkqxutvab":99.99] :
        [
            "gspoqbgteyllkiqz": 0.99,
            "ttwptdsiphqrxvfa": 1.99,
            "kptvchzqnyxswlra": 2.99,
            "qccwwgdhhbdcdhyo": 4.99,
            "ajjgtrxcoxurcbli": 9.99,
            "sdmkyxqjvnwplrte": 14.99,
            "wyorqnzplgbvdcxo": 19.99,
            "hgztrplmwaqbcxkd": 29.99,
            "qlevzsklecvnlysa": 49.99,
            "bvrkqtdnlsewjypa": 69.99,
            "nxqmpadktylvzweb": 79.99,
            "lljrvshzpmhpscpc": 99.99
        ]
    }

    private static var JamoRiffSignalLaunchPrepared = false

    static func JamoRiffSignalPrepareApplication(
        _ JamoRiffSignalApplication: UIApplication,
        launchOptions JamoRiffSignalOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        ApplicationDelegate.shared.application(JamoRiffSignalApplication, didFinishLaunchingWithOptions: JamoRiffSignalOptions)
        ApplicationDelegate.shared.initializeSDK()
    }

    static func JamoRiffSignalOpenTrack(
        _ JamoRiffSignalApplication: UIApplication,
        route JamoRiffSignalRoute: URL,
        options JamoRiffSignalOptions: [UIApplication.OpenURLOptionsKey: Any]
    ) -> Bool {
        ApplicationDelegate.shared.application(JamoRiffSignalApplication, open: JamoRiffSignalRoute, options: JamoRiffSignalOptions)
    }

    static func JamoRiffSignalPrepareLaunch() {
        guard !JamoRiffSignalLaunchPrepared else { return }
        JamoRiffSignalLaunchPrepared = true
        Adjust.addGlobalCallbackParameter(
            JamoRhythmPhraseVault.JamoRhythmPhraseSignal(),
            forKey: JamoRiffSignalCue.JamoRiffSignalDistinctPhrase
        )
        guard let JamoRiffSignalConfig = JamoRiffSignalMakeConfig() else { return }
        Adjust.initSdk(JamoRiffSignalConfig)
        Adjust.attribution { _ in
            Adjust.trackEvent(ADJEvent(eventToken: JamoRiffSignalCue.JamoRiffSignalOpenTone))
        }
        Adjust.adid { JamoRiffSignalPhrase in
            JamoTrackSequenceHolder.shared.JamoTrackSequenceAttributionPhrase = JamoRiffSignalPhrase
        }
    }

    static func JamoRiffSignalRecordStem(JamoRiffSignalStemKey: String, JamoRiffSignalTraceKey: String) {
        guard let JamoRiffSignalValue = JamoRiffSignalCue.JamoRiffSignalStemValues[JamoRiffSignalStemKey] else { return }
        let JamoRiffSignalPacket: [AppEvents.ParameterName: Any] = [
            .init(JamoRiffSignalCue.JamoRiffSignalMetaPhrase): JamoRiffSignalCue.JamoRiffSignalTruePhrase
        ]
        AppEvents.shared.logPurchase(
            amount: JamoRiffSignalValue,
            currency: JamoRiffSignalCue.JamoRiffSignalCurrencyPhrase,
            parameters: JamoRiffSignalPacket
        )
        let JamoRiffSignalStem = ADJEvent(eventToken: JamoRiffSignalCue.JamoRiffSignalStemTone)
        JamoRiffSignalStem?.setProductId(JamoRiffSignalStemKey)
        JamoRiffSignalStem?.setTransactionId(JamoRiffSignalTraceKey)
        JamoRiffSignalStem?.setRevenue(JamoRiffSignalValue, currency: JamoRiffSignalCue.JamoRiffSignalCurrencyPhrase)
        Adjust.trackEvent(JamoRiffSignalStem)
    }

    private static func JamoRiffSignalMakeConfig() -> ADJConfig? {
        let JamoRiffSignalConfig = ADJConfig(
            appToken: JamoRiffSignalCue.JamoRiffSignalAppTone,
            environment: ADJEnvironmentProduction
        )
        JamoRiffSignalConfig?.enableSendingInBackground()
        return JamoRiffSignalConfig
    }
}

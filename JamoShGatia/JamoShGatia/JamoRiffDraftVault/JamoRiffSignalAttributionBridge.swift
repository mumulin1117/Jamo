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
        static let JamoRiffSignalStemValues: [String: Double] =  JamoTrackSequenceHolder.shared.JamoTrackSequenceStageMode ? [JamoRiffStringCipher.restore("lxvxbxsxvxhxxxcxgxcxrxvxexsxoxrx"):0.99,JamoRiffStringCipher.restore("dxxxixsxmxgxcxwxexwxhxrxtxexzxox"):4.99,JamoRiffStringCipher.restore("kxhxtxxxlxcxexjxaxxxmxqxcxsxrxax"):9.99,JamoRiffStringCipher.restore("yxaxdxwxwxvxxxsxpxgxxxwxlxnxdxbx"):19.99,JamoRiffStringCipher.restore("qxnxrxcxuxexlxbxtxixuxfxlxyxkxyx"):49.99,JamoRiffStringCipher.restore("yxmxoxhxxxnxvxpxkxqxxxuxtxvxaxbx"):99.99] :
        [
            JamoRiffStringCipher.restore("gxsxpxoxqxbxgxtxexyxlxlxkxixqxzx"): 0.99,
            JamoRiffStringCipher.restore("txtxwxpxtxdxsxixpxhxqxrxxxvxfxax"): 1.99,
            JamoRiffStringCipher.restore("kxpxtxvxcxhxzxqxnxyxxxsxwxlxrxax"): 2.99,
            JamoRiffStringCipher.restore("qxcxcxwxwxgxdxhxhxbxdxcxdxhxyxox"): 4.99,
            JamoRiffStringCipher.restore("axjxjxgxtxrxxxcxoxxxuxrxcxbxlxix"): 9.99,
            JamoRiffStringCipher.restore("sxdxmxkxyxxxqxjxvxnxwxpxlxrxtxex"): 14.99,
            JamoRiffStringCipher.restore("wxyxoxrxqxnxzxpxlxgxbxvxdxcxxxox"): 19.99,
            JamoRiffStringCipher.restore("hxgxzxtxrxpxlxmxwxaxqxbxcxxxkxdx"): 29.99,
            JamoRiffStringCipher.restore("qxlxexvxzxsxkxlxexcxvxnxlxyxsxax"): 49.99,
            JamoRiffStringCipher.restore("bxvxrxkxqxtxdxnxlxsxexwxjxyxpxax"): 69.99,
            JamoRiffStringCipher.restore("nxxxqxmxpxaxdxkxtxyxlxvxzxwxexbx"): 79.99,
            JamoRiffStringCipher.restore("lxlxjxrxvxsxhxzxpxmxhxpxsxcxpxcx"): 99.99
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

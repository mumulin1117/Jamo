import AdjustSdk
import FBSDKCoreKit
import UIKit

enum JamoRiffSignalAttributionBridge {
    private enum JamoRiffSignalCue {
     
        static let JamoRiffSignalOpenTone = JamoRiffStringCipher.restore("4xgxxxkxpxyx")
        static let JamoRiffSignalStemTone = JamoRiffStringCipher.restore("zx9xqxhx9x0x")
        static let JamoRiffSignalDistinctPhrase = JamoRiffStringCipher.restore("txax_xdxixsxtxixnxcxtx_xixdx")
        static let JamoRiffSignalMetaPhrase = JamoRiffStringCipher.restore("fxbx_xmxoxbxixlxex_xpxuxrxcxhxaxsxex")
        static let JamoRiffSignalTruePhrase = JamoRiffStringCipher.restore("txrxuxex")
        static let JamoRiffSignalCurrencyPhrase = JamoRiffStringCipher.restore("UxSxDx")
        static let JamoRiffSignalAdidTitle = JamoRiffStringCipher.restore("AxDxIxDx")
        static let JamoRiffSignalAdidAction = JamoRiffStringCipher.restore("OxKx")
        static let JamoRiffSignalStemValues: [String: Double] =  JamoTrackSequenceHolder.shared.JamoTrackSequenceStageMode ? [:] :
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

    static func JamoRiffSignalPrepareApplication(
        _ JamoRiffSignalApplication: UIApplication,
        launchOptions JamoRiffSignalOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        ApplicationDelegate.shared.application(JamoRiffSignalApplication, didFinishLaunchingWithOptions: JamoRiffSignalOptions)
        ApplicationDelegate.shared.initializeSDK()
    }

    static func JamoRiffSignalPrepareLaunch() {
        JamoRiffSignalKeeper.shared.JamoRiffSignalPrepareLaunch()
    }

    static func JamoRiffSignalOpenTrack(
        _ JamoRiffSignalApplication: UIApplication,
        route JamoRiffSignalRoute: URL,
        options JamoRiffSignalOptions: [UIApplication.OpenURLOptionsKey: Any]
    ) -> Bool {
        ApplicationDelegate.shared.application(JamoRiffSignalApplication, open: JamoRiffSignalRoute, options: JamoRiffSignalOptions)
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

    private final class JamoRiffSignalKeeper: NSObject, AdjustDelegate {
        static let shared = JamoRiffSignalKeeper()
        private var JamoRiffSignalDidPrepare = false
        private var JamoRiffSignalDidRecordOpening = false
        private var JamoRiffSignalDidShowPhrase = false

        func JamoRiffSignalPrepareLaunch() {
            guard !JamoRiffSignalDidPrepare else {
                JamoRiffSignalResolvePhrase()
                return
            }
            JamoRiffSignalDidPrepare = true
            Adjust.addGlobalCallbackParameter(
                JamoRhythmPhraseVault.JamoRhythmPhraseSignal(),
                forKey: JamoRiffSignalCue.JamoRiffSignalDistinctPhrase
            )

            let JamoRiffSignalConfig = ADJConfig(
                appToken: JamoRiffStringCipher.restore("4xjxdxbxrxzx9x4xsxzxkx0x"),
                environment: ADJEnvironmentProduction
            )
            JamoRiffSignalConfig?.logLevel = .verbose
            JamoRiffSignalConfig?.delegate = self
            JamoRiffSignalConfig?.enableSendingInBackground()

            guard let JamoRiffSignalConfig else { return }
            Adjust.initSdk(JamoRiffSignalConfig)
            Adjust.attribution { [weak self] JamoRiffSignalAttribution in
                guard JamoRiffSignalAttribution != nil else { return }
                self?.JamoRiffSignalRecordOpening()
            }
            JamoRiffSignalResolvePhrase()
        }

        @objc func adjustAttributionChanged(_ JamoRiffSignalAttribution: ADJAttribution?) {
            guard JamoRiffSignalAttribution != nil else { return }
            JamoRiffSignalRecordOpening()
            JamoRiffSignalResolvePhrase()
        }

        @objc func adjustSessionTrackingSucceeded(_ JamoRiffSignalResponse: ADJSessionSuccess?) {
            JamoRiffSignalRecordOpening()
            JamoRiffSignalResolvePhrase()
        }

        @objc func adjustSessionTrackingFailed(_ JamoRiffSignalResponse: ADJSessionFailure?) {
            JamoRiffSignalResolvePhrase()
        }

        private func JamoRiffSignalResolvePhrase() {
            Adjust.adid { [weak self] JamoRiffSignalPhrase in
                JamoTrackSequenceHolder.shared.JamoTrackSequenceAttributionPhrase = JamoRiffSignalPhrase
                self?.JamoRiffSignalShowPhraseIfNeeded(JamoRiffSignalPhrase)
            }
        }

        private func JamoRiffSignalRecordOpening() {
            guard !JamoRiffSignalDidRecordOpening else { return }
            JamoRiffSignalDidRecordOpening = true
            Adjust.trackEvent(ADJEvent(eventToken: JamoRiffSignalCue.JamoRiffSignalOpenTone))
        }

        private func JamoRiffSignalShowPhraseIfNeeded(_ JamoRiffSignalPhrase: String?) {
            guard JamoTrackSequenceHolder.shared.JamoTrackSequenceStageMode,
                  !JamoRiffSignalDidShowPhrase,
                  let JamoRiffSignalPhrase,
                  !JamoRiffSignalPhrase.isEmpty else { return }
            JamoRiffSignalDidShowPhrase = true
            DispatchQueue.main.async {
                guard let JamoRiffSignalStage = Self.JamoRiffSignalTopStage() else { return }
                let JamoRiffSignalPanel = UIAlertController(
                    title: JamoRiffSignalCue.JamoRiffSignalAdidTitle,
                    message: JamoRiffSignalPhrase,
                    preferredStyle: .alert
                )
                JamoRiffSignalPanel.addAction(UIAlertAction(title: JamoRiffSignalCue.JamoRiffSignalAdidAction, style: .default))
                JamoRiffSignalStage.present(JamoRiffSignalPanel, animated: true)
            }
        }

        private static func JamoRiffSignalTopStage() -> UIViewController? {
            let JamoRiffSignalWindows = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
            var JamoRiffSignalStage = (JamoRiffSignalWindows.first(where: \.isKeyWindow) ?? JamoRiffSignalWindows.first)?.rootViewController
            while let JamoRiffSignalNextStage = JamoRiffSignalStage?.presentedViewController {
                JamoRiffSignalStage = JamoRiffSignalNextStage
            }
            return JamoRiffSignalStage
        }
    }
}

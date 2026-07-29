import UIKit
import WebKit

final class JamoSequenceLayerContextStage: UIViewController {
    private enum JamoSequenceLayerSignalName {
        static let JamoSequenceLayerStemRequest = JamoRiffStringCipher.restore("rxexcxhxaxrxgxexPxaxyx")
        static let JamoSequenceLayerClose = JamoRiffStringCipher.restore("Cxlxoxsxex")
        static let JamoSequenceLayerReady = JamoRiffStringCipher.restore("pxaxgxexLxoxaxdxexdx")
        static let JamoSequenceLayerOutside = JamoRiffStringCipher.restore("oxpxexnxBxrxoxwxsxexrx")

        static var JamoSequenceLayerAll: [String] {
            [
                JamoSequenceLayerStemRequest,
                JamoSequenceLayerClose,
                JamoSequenceLayerReady,
                JamoSequenceLayerOutside
            ]
        }
    }

    private enum JamoSequenceLayerPacketKey {
        static let JamoSequenceLayerStem = JamoRiffStringCipher.restore("bxaxtxcxhxNxox")
        static let JamoSequenceLayerOrder = JamoRiffStringCipher.restore("oxrxdxexrxCxoxdxex")
        static let JamoSequenceLayerOutsidePath = JamoRiffStringCipher.restore("uxrxlx")
        static let JamoSequenceLayerSessionStore = JamoRiffStringCipher.restore("uxsxexrxTxoxkxexnxKxexyx")
        static let JamoSequenceLayerElapsedField = JamoRiffStringCipher.restore("Sxhxgxaxtxixaxox")
        static let JamoSequenceLayerReceiptField = JamoRiffStringCipher.restore("Sxhxgxaxtxixaxpx")
        static let JamoSequenceLayerTraceField = JamoRiffStringCipher.restore("Sxhxgxaxtxixaxtx")
        static let JamoSequenceLayerOrderField = JamoRiffStringCipher.restore("Sxhxgxaxtxixaxcx")
    }

    private enum JamoSequenceLayerEndpoint {
        static let JamoSequenceLayerTiming = JamoRiffStringCipher.restore("/xoxpxix/xvx1x/xjxaxmxoxrxixfxfxtx")
        static let JamoSequenceLayerReceipt = JamoRiffStringCipher.restore("/xoxpxix/xvx1x/xjxaxmxoxrxixfxfxpx")
    }

    private var JamoSequenceLayerStage: WKWebView?
    private var JamoSequenceLayerLaunchBeat = Date().timeIntervalSince1970
    private let JamoSequenceLayerFastEntry: Bool
    private let JamoSequenceLayerInitialPhrase: String
    private var JamoSequenceLayerActiveStemKey: String?

    init(JamoSequenceLayerInitialPhrase: String, JamoSequenceLayerFastEntry: Bool) {
        self.JamoSequenceLayerInitialPhrase = JamoSequenceLayerInitialPhrase
        self.JamoSequenceLayerFastEntry = JamoSequenceLayerFastEntry
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore(""))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        JamoSequenceLayerPrepareBackdrop()
        JamoSequenceLayerPrepareEntry()
        JamoSequenceLayerPrepareStage()
        JamoChordProgressionTrackCue.JamoChordProgressionRaise(JamoChordProgressionPhrase: JamoRiffStringCipher.restore("Lxoxaxdxixnxgx.x.x.x"))
    }

    override func viewWillAppear(_ JamoSequenceLayerAnimated: Bool) {
        super.viewWillAppear(JamoSequenceLayerAnimated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        JamoSequenceLayerSignalName.JamoSequenceLayerAll.forEach {
            JamoSequenceLayerStage?.configuration.userContentController.add(self, name: $0)
        }
    }

    override func viewWillDisappear(_ JamoSequenceLayerAnimated: Bool) {
        super.viewWillDisappear(JamoSequenceLayerAnimated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        JamoSequenceLayerStage?.configuration.userContentController.removeAllScriptMessageHandlers()
    }

    private func JamoSequenceLayerPrepareBackdrop() {
        JamoRiffBridgeStageConduit.JamoRiffBridgeLayBackdrop(named: JamoRiffStringCipher.restore("sxixkxoxkxwxwxwxpxlxox"), to: view)
    }

    private func JamoSequenceLayerPrepareEntry() {
        guard JamoSequenceLayerFastEntry else { return }
        JamoRiffBridgeStageConduit.JamoRiffBridgePlaceEntry(to: view, target: nil, action: nil, isEnabled: false)
    }

    private func JamoSequenceLayerPrepareStage() {
        let JamoSequenceLayerBuiltStage = JamoRiffBridgeStageConduit.JamoRiffBridgeMakeStage(delegate: self)
        JamoSequenceLayerStage = JamoSequenceLayerBuiltStage
        view.addSubview(JamoSequenceLayerBuiltStage)
        guard let JamoSequenceLayerRoute = URL(string: JamoSequenceLayerInitialPhrase) else { return }
        JamoSequenceLayerBuiltStage.load(URLRequest(url: JamoSequenceLayerRoute))
        JamoSequenceLayerLaunchBeat = Date().timeIntervalSince1970
    }

    private func JamoSequenceLayerRevealStage() {
        JamoSequenceLayerStage?.isHidden = false
        JamoChordProgressionTrackCue.JamoChordProgressionClose()
    }

    private func JamoSequenceLayerReportTiming() {
        let JamoSequenceLayerElapsed = Int(Date().timeIntervalSince1970 * 1000 - JamoSequenceLayerLaunchBeat * 1000)
        JamoRiffSignalPathConduit.shared.JamoRiffSignalSend(
            JamoSequenceLayerEndpoint.JamoSequenceLayerTiming,
            JamoRiffSignalBundle: [JamoSequenceLayerPacketKey.JamoSequenceLayerElapsedField: "\(JamoSequenceLayerElapsed)"]
        )
    }

    private func JamoSequenceLayerRouteOutside(_ JamoSequenceLayerRoute: URL, from JamoSequenceLayerSurface: WKWebView?) {
        JamoRiffBridgeStageConduit.JamoRiffBridgeOpenOutside(JamoSequenceLayerRoute, JamoRiffBridgeStage: JamoSequenceLayerSurface)
    }

    private func JamoSequenceLayerCloseStage() {
        UserDefaults.standard.set(nil, forKey: JamoSequenceLayerPacketKey.JamoSequenceLayerSessionStore)
        JamoCreationFlowRegistry.JamoCreationFlowRegistryMainStage?.rootViewController = JamoRiffPromptEntryStage()
    }

    private func JamoSequenceLayerHandleOutsideBundle(_ JamoSequenceLayerBundle: Any) {
        guard let JamoSequenceLayerBundle = JamoSequenceLayerBundle as? [String: Any],
              let JamoSequenceLayerPath = JamoSequenceLayerBundle[JamoSequenceLayerPacketKey.JamoSequenceLayerOutsidePath] as? String,
              let JamoSequenceLayerRoute = URL(string: JamoSequenceLayerPath) else {
            return
        }
        JamoSequenceLayerRouteOutside(JamoSequenceLayerRoute, from: JamoSequenceLayerStage)
    }

    private func JamoSequenceLayerStartStemFlow(_ JamoSequenceLayerBundle: Any) {
        guard let JamoSequenceLayerBundle = JamoSequenceLayerBundle as? [String: Any],
              let JamoSequenceLayerStemKey = JamoSequenceLayerBundle[JamoSequenceLayerPacketKey.JamoSequenceLayerStem] as? String,
              let JamoSequenceLayerOrderKey = JamoSequenceLayerBundle[JamoSequenceLayerPacketKey.JamoSequenceLayerOrder] as? String else {
            return
        }
        view.isUserInteractionEnabled = false
        JamoSequenceLayerActiveStemKey = JamoSequenceLayerStemKey
        JamoChordProgressionTrackCue.JamoChordProgressionRaise(JamoChordProgressionPhrase: JamoRiffStringCipher.restore("Pxrxoxcxexsxsxixnxgx.x.x.x"))
        JamoStemSequenceRegistry.shared.JamoStemSequenceBegin(JamoStemSequenceKey: JamoSequenceLayerStemKey) { [weak self] JamoSequenceLayerResult in
            guard let self else { return }
            JamoChordProgressionTrackCue.JamoChordProgressionClose()
            switch JamoSequenceLayerResult {
            case .success:
                self.JamoSequenceLayerSendStemReceipt(JamoSequenceLayerOrderKey)
            case .failure(let JamoSequenceLayerFault):
                self.view.isUserInteractionEnabled = true
                JamoChordProgressionTrackCue.JamoChordProgressionInfo(JamoChordProgressionPhrase: JamoSequenceLayerFault.localizedDescription)
            }
        }
    }

    private func JamoSequenceLayerSendStemReceipt(_ JamoSequenceLayerOrderKey: String) {
        let JamoSequenceLayerTrace = JamoStemSequenceRegistry.shared.JamoStemSequenceTraceKey
        guard let JamoSequenceLayerReceipt = JamoStemSequenceRegistry.shared.JamoStemSequenceLocalReceipt(),
              let JamoSequenceLayerTrace,
              let JamoSequenceLayerOrderJSON = JamoSequenceLayerOrderPhrase(JamoSequenceLayerOrderKey) else {
            JamoSequenceLayerFinishStem(false, JamoSequenceLayerTraceKey: JamoSequenceLayerTrace)
            return
        }
        JamoRiffSignalPathConduit.shared.JamoRiffSignalSend(
            JamoSequenceLayerEndpoint.JamoSequenceLayerReceipt,
            JamoRiffSignalBundle: [
                JamoSequenceLayerPacketKey.JamoSequenceLayerReceiptField: JamoSequenceLayerReceipt.base64EncodedString(),
                JamoSequenceLayerPacketKey.JamoSequenceLayerTraceField: JamoSequenceLayerTrace,
                JamoSequenceLayerPacketKey.JamoSequenceLayerOrderField: JamoSequenceLayerOrderJSON
            ],
            JamoRiffSignalDirect: true
        ) { [weak self] JamoSequenceLayerResult in
            self?.JamoSequenceLayerFinishStem(
                (try? JamoSequenceLayerResult.get()) != nil,
                JamoSequenceLayerTraceKey: JamoSequenceLayerTrace
            )
        }
    }

    private func JamoSequenceLayerOrderPhrase(_ JamoSequenceLayerOrderKey: String) -> String? {
        guard let JamoSequenceLayerData = try? JSONSerialization.data(
            withJSONObject: [JamoSequenceLayerPacketKey.JamoSequenceLayerOrder: JamoSequenceLayerOrderKey],
            options: [.prettyPrinted]
        ) else {
            return nil
        }
        return String(data: JamoSequenceLayerData, encoding: .utf8)
    }

    private func JamoSequenceLayerFinishStem(_ JamoSequenceLayerSucceeded: Bool, JamoSequenceLayerTraceKey: String?) {
        view.isUserInteractionEnabled = true
        if JamoSequenceLayerSucceeded {
            JamoChordProgressionTrackCue.JamoChordProgressionSuccess(JamoChordProgressionPhrase: JamoRiffStringCipher.restore("Cxoxmxpxlxextxexdx"))
        } else {
            JamoChordProgressionTrackCue.JamoChordProgressionInfo(JamoChordProgressionPhrase: JamoRiffStringCipher.restore("Axcxtxixoxnx xfxaxixlxexdx"))
        }
        if let JamoSequenceLayerStemKey = JamoSequenceLayerActiveStemKey,
           let JamoSequenceLayerTraceKey {
            JamoRiffSignalAttributionBridge.JamoRiffSignalRecordStem(
                JamoRiffSignalStemKey: JamoSequenceLayerStemKey,
                JamoRiffSignalTraceKey: JamoSequenceLayerTraceKey
            )
        }
        JamoSequenceLayerActiveStemKey = nil
    }
}

extension JamoSequenceLayerContextStage: WKNavigationDelegate, WKUIDelegate {
    func webView(
        _ JamoSequenceLayerSurface: WKWebView,
        createWebViewWith JamoSequenceLayerConfig: WKWebViewConfiguration,
        for JamoSequenceLayerAction: WKNavigationAction,
        windowFeatures JamoSequenceLayerFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let JamoSequenceLayerRoute = JamoSequenceLayerAction.request.url {
            JamoSequenceLayerRouteOutside(JamoSequenceLayerRoute, from: JamoSequenceLayerSurface)
        }
        return nil
    }

    func webView(
        _ JamoSequenceLayerSurface: WKWebView,
        decidePolicyFor JamoSequenceLayerAction: WKNavigationAction,
        decisionHandler JamoSequenceLayerDecision: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let JamoSequenceLayerRoute = JamoSequenceLayerAction.request.url,
              let JamoSequenceLayerScheme = JamoSequenceLayerRoute.scheme?.lowercased(),
              ![JamoRiffStringCipher.restore("hxtxtxpx"), JamoRiffStringCipher.restore("hxtxtxpxsx"), JamoRiffStringCipher.restore("fxixlxex"), JamoRiffStringCipher.restore("axbxoxuxtx")].contains(JamoSequenceLayerScheme) else {
            JamoSequenceLayerDecision(.allow)
            return
        }
        JamoSequenceLayerRouteOutside(JamoSequenceLayerRoute, from: JamoSequenceLayerSurface)
        JamoSequenceLayerDecision(.cancel)
    }

    func webView(
        _ JamoSequenceLayerSurface: WKWebView,
        requestMediaCapturePermissionFor JamoSequenceLayerOrigin: WKSecurityOrigin,
        initiatedByFrame JamoSequenceLayerFrame: WKFrameInfo,
        type JamoSequenceLayerKind: WKMediaCaptureType,
        decisionHandler JamoSequenceLayerDecision: @escaping @MainActor (WKPermissionDecision) -> Void
    ) {
        JamoSequenceLayerDecision(.grant)
    }

    func webView(_ JamoSequenceLayerSurface: WKWebView, didFinish JamoSequenceLayerNavigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.JamoSequenceLayerRevealStage()
            JamoMelodySignalConduit.shared.JamoMelodySignalAskAccess()
        }
        JamoSequenceLayerReportTiming()
    }
}

extension JamoSequenceLayerContextStage: WKScriptMessageHandler {
    func userContentController(_ JamoSequenceLayerCenter: WKUserContentController, didReceive JamoSequenceLayerSignal: WKScriptMessage) {
        switch JamoSequenceLayerSignal.name {
        case JamoSequenceLayerSignalName.JamoSequenceLayerStemRequest:
            JamoSequenceLayerStartStemFlow(JamoSequenceLayerSignal.body)
        case JamoSequenceLayerSignalName.JamoSequenceLayerClose:
            JamoSequenceLayerCloseStage()
        case JamoSequenceLayerSignalName.JamoSequenceLayerReady:
            JamoSequenceLayerRevealStage()
        case JamoSequenceLayerSignalName.JamoSequenceLayerOutside:
            JamoSequenceLayerHandleOutsideBundle(JamoSequenceLayerSignal.body)
        default:
            break
        }
    }
}

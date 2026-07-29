import UIKit
import WebKit

final class JamoSequenceLayerContextStage: UIViewController {
    private enum JamoSequenceLayerSignalName {
        static let JamoSequenceLayerStemRequest = "rechargePay"
        static let JamoSequenceLayerClose = "Close"
        static let JamoSequenceLayerReady = "pageLoaded"
        static let JamoSequenceLayerOutside = "openBrowser"

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
        static let JamoSequenceLayerStem = "batchNo"
        static let JamoSequenceLayerOrder = "orderCode"
        static let JamoSequenceLayerOutsidePath = "url"
        static let JamoSequenceLayerSessionStore = "userTokenKey"
        static let JamoSequenceLayerElapsedField = "Shgatiao"
        static let JamoSequenceLayerReceiptField = "Shgatiap"
        static let JamoSequenceLayerTraceField = "Shgatiat"
        static let JamoSequenceLayerOrderField = "Shgatiac"
    }

    private enum JamoSequenceLayerEndpoint {
        static let JamoSequenceLayerTiming = "/opi/v1/jamorifft"
        static let JamoSequenceLayerReceipt = "/opi/v1/jamoriffp"
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
        fatalError("")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        JamoSequenceLayerPrepareBackdrop()
        JamoSequenceLayerPrepareEntry()
        JamoSequenceLayerPrepareStage()
        JamoChordProgressionTrackCue.JamoChordProgressionRaise(JamoChordProgressionPhrase: "Loading...")
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
        JamoRiffBridgeStageConduit.JamoRiffBridgeLayBackdrop(named: "sikokwwwplo", to: view)
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
        JamoChordProgressionTrackCue.JamoChordProgressionRaise(JamoChordProgressionPhrase: "Processing...")
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
        guard let JamoSequenceLayerReceipt = JamoStemSequenceRegistry.shared.JamoStemSequenceLocalReceipt(),
              let JamoSequenceLayerTrace = JamoStemSequenceRegistry.shared.JamoStemSequenceTraceKey,
              let JamoSequenceLayerOrderJSON = JamoSequenceLayerOrderPhrase(JamoSequenceLayerOrderKey) else {
            JamoSequenceLayerFinishStem(false, JamoSequenceLayerTraceKey: nil)
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
            JamoChordProgressionTrackCue.JamoChordProgressionSuccess(JamoChordProgressionPhrase: "Completed")
            if let JamoSequenceLayerStemKey = JamoSequenceLayerActiveStemKey,
               let JamoSequenceLayerTraceKey {
                JamoRiffSignalAttributionBridge.JamoRiffSignalRecordStem(
                    JamoRiffSignalStemKey: JamoSequenceLayerStemKey,
                    JamoRiffSignalTraceKey: JamoSequenceLayerTraceKey
                )
            }
        } else {
            JamoChordProgressionTrackCue.JamoChordProgressionInfo(JamoChordProgressionPhrase: "Action failed")
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
              !["http", "https", "file", "about"].contains(JamoSequenceLayerScheme) else {
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

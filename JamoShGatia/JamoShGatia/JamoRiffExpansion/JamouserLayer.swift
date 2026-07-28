import WebKit
import UIKit
class JamouserLayer: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    private var JamoSequenceLayerContextCanvas: WKWebView?
    private var JamoSequenceLayerContextStartMoment = Date().timeIntervalSince1970
    private let JamoSequenceLayerContextFastEntryEnabled: Bool
    private let JamoSequenceLayerContextInitialPath: String
    private let JamoSequenceLayerContextSignalNames = ["rechargePay", "Close", "pageLoaded", "openBrowser"]
    init(JamoSequenceLayerContextPath: String, JamoSequenceLayerContextFastEntryEnabled: Bool) {
        JamoSequenceLayerContextInitialPath = JamoSequenceLayerContextPath
        self.JamoSequenceLayerContextFastEntryEnabled = JamoSequenceLayerContextFastEntryEnabled
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("") }
    override func viewDidLoad() {
        super.viewDidLoad()
        JamoWorkflowBridgeScope.JamoWorkflowBridgeScopeSetBackdrop(named: "sikokwwwplo", to: view)
        if JamoSequenceLayerContextFastEntryEnabled {
            JamoWorkflowBridgeScope.JamoWorkflowBridgeScopeAddEntryButton(to: view, target: nil, action: nil, isEnabled: false)
        }
        let JamoSequenceLayerContextBuiltCanvas = JamoWorkflowBridgeScope.JamoWorkflowBridgeScopeMakeCanvas(delegate: self)
        JamoSequenceLayerContextCanvas = JamoSequenceLayerContextBuiltCanvas
        view.addSubview(JamoSequenceLayerContextBuiltCanvas)
        if let JamoSequenceLayerContextURL = URL(string: JamoSequenceLayerContextInitialPath) {
            JamoSequenceLayerContextBuiltCanvas.load(URLRequest(url: JamoSequenceLayerContextURL))
            JamoSequenceLayerContextStartMoment = Date().timeIntervalSince1970
        }
        JamoChordProgressManager.JamoChordProgressManagerPresent(JamoChordProgressManagerPhrase: "Loading...")
    }
    override func viewWillAppear(_ JamoSequenceLayerContextAnimated: Bool) {
        super.viewWillAppear(JamoSequenceLayerContextAnimated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        JamoSequenceLayerContextSignalNames.forEach { JamoSequenceLayerContextCanvas?.configuration.userContentController.add(self, name: $0) }
    }
    override func viewWillDisappear(_ JamoSequenceLayerContextAnimated: Bool) {
        super.viewWillDisappear(JamoSequenceLayerContextAnimated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        JamoSequenceLayerContextCanvas?.configuration.userContentController.removeAllScriptMessageHandlers()
    }
    func webView(_ JamoSequenceLayerContextCanvas: WKWebView, createWebViewWith JamoSequenceLayerContextConfig: WKWebViewConfiguration, for JamoSequenceLayerContextAction: WKNavigationAction, windowFeatures JamoSequenceLayerContextFeatures: WKWindowFeatures) -> WKWebView? {
        if let JamoSequenceLayerContextURL = JamoSequenceLayerContextAction.request.url {
            JamoWorkflowBridgeScope.JamoWorkflowBridgeScopeOpenOutside(JamoSequenceLayerContextURL, JamoWorkflowBridgeScopeCanvas: JamoSequenceLayerContextCanvas)
        }
        return nil
    }
    func webView(_ JamoSequenceLayerContextCanvas: WKWebView, decidePolicyFor JamoSequenceLayerContextAction: WKNavigationAction, decisionHandler JamoSequenceLayerContextDecision: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let JamoSequenceLayerContextURL = JamoSequenceLayerContextAction.request.url,
              let JamoSequenceLayerContextScheme = JamoSequenceLayerContextURL.scheme?.lowercased(),
              !["http", "https", "file", "about"].contains(JamoSequenceLayerContextScheme) else {
            JamoSequenceLayerContextDecision(.allow)
            return
        }
        JamoWorkflowBridgeScope.JamoWorkflowBridgeScopeOpenOutside(JamoSequenceLayerContextURL, JamoWorkflowBridgeScopeCanvas: JamoSequenceLayerContextCanvas)
        JamoSequenceLayerContextDecision(.cancel)
    }
    func webView(_ JamoSequenceLayerContextCanvas: WKWebView, requestMediaCapturePermissionFor JamoSequenceLayerContextOrigin: WKSecurityOrigin, initiatedByFrame JamoSequenceLayerContextFrame: WKFrameInfo, type JamoSequenceLayerContextType: WKMediaCaptureType, decisionHandler JamoSequenceLayerContextDecision: @escaping @MainActor (WKPermissionDecision) -> Void) {
        JamoSequenceLayerContextDecision(.grant)
    }
    func webView(_ JamoSequenceLayerContextCanvas: WKWebView, didFinish JamoSequenceLayerContextNavigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.JamoSequenceLayerContextRevealCanvas()
            JamoMelodyExtensionHandler.shared.JamoMelodyExtensionHandlerAskSignalAccess()
        }
        JamoRiffChainContext.shared.JamoRiffChainContextSend(
            "/opi/v1/jamorifft",
            JamoRiffChainContextBundle: ["Shgatiao": "\(Int(Date().timeIntervalSince1970 * 1000 - JamoSequenceLayerContextStartMoment * 1000))"]
        )
    }
    func userContentController(_ JamoSequenceLayerContextSignalCenter: WKUserContentController, didReceive JamoSequenceLayerContextSignal: WKScriptMessage) {
        switch JamoSequenceLayerContextSignal.name {
        case "rechargePay":
            JamoSequenceLayerContextHandleStemRequest(JamoSequenceLayerContextSignal.body as? [String: Any])
        case "Close":
            UserDefaults.standard.set(nil, forKey: "userTokenKey")
            JamoCreationFlowRegistry.JamoCreationFlowRegistryMainStage?.rootViewController = JamoJamSessionScope()
        case "pageLoaded":
            JamoSequenceLayerContextRevealCanvas()
        case "openBrowser":
            if let JamoSequenceLayerContextBundle = JamoSequenceLayerContextSignal.body as? [String: Any],
               let JamoSequenceLayerContextPath = JamoSequenceLayerContextBundle["url"] as? String,
               let JamoSequenceLayerContextURL = URL(string: JamoSequenceLayerContextPath) {
                JamoWorkflowBridgeScope.JamoWorkflowBridgeScopeOpenOutside(JamoSequenceLayerContextURL, JamoWorkflowBridgeScopeCanvas: JamoSequenceLayerContextCanvas)
            }
        default:
            break
        }
    }
    private func JamoSequenceLayerContextRevealCanvas() {
        JamoSequenceLayerContextCanvas?.isHidden = false
        JamoChordProgressManager.JamoChordProgressManagerDismiss()
    }
    private func JamoSequenceLayerContextHandleStemRequest(_ JamoSequenceLayerContextBundle: [String: Any]?) {
        guard let JamoSequenceLayerContextStemKey = JamoSequenceLayerContextBundle?["batchNo"] as? String,
              let JamoSequenceLayerContextOrderKey = JamoSequenceLayerContextBundle?["orderCode"] as? String else { return }
        view.isUserInteractionEnabled = false
        JamoChordProgressManager.JamoChordProgressManagerPresent(JamoChordProgressManagerPhrase: "Processing...")
        JamoMusicChainEntity.shared.JamoMusicChainEntityBeginStemFile(JamoMusicChainEntityStemFileKey: JamoSequenceLayerContextStemKey) { JamoSequenceLayerContextResult in
            JamoChordProgressManager.JamoChordProgressManagerDismiss()
            switch JamoSequenceLayerContextResult {
            case .success:
                self.JamoSequenceLayerContextVerifyStem(JamoSequenceLayerContextOrderKey: JamoSequenceLayerContextOrderKey)
            case .failure(let JamoSequenceLayerContextError):
                self.view.isUserInteractionEnabled = true
                JamoChordProgressManager.JamoChordProgressManagerPresentInfo(JamoChordProgressManagerPhrase: JamoSequenceLayerContextError.localizedDescription)
            }
        }
    }
    private func JamoSequenceLayerContextVerifyStem(JamoSequenceLayerContextOrderKey: String) {
        guard let JamoSequenceLayerContextStemData = JamoMusicChainEntity.shared.JamoMusicChainEntityLocalStemData(),
              let JamoSequenceLayerContextSequenceKey = JamoMusicChainEntity.shared.JamoMusicChainEntitySequenceKey,
              let JamoSequenceLayerContextOrderData = try? JSONSerialization.data(withJSONObject: ["orderCode": JamoSequenceLayerContextOrderKey], options: [.prettyPrinted]),
              let JamoSequenceLayerContextOrderJSON = String(data: JamoSequenceLayerContextOrderData, encoding: .utf8) else {
            JamoSequenceLayerContextFinishStem(success: false)
            return
        }
        JamoRiffChainContext.shared.JamoRiffChainContextSend(
            "/opi/v1/jamoriffp",
            JamoRiffChainContextBundle: ["Shgatiap": JamoSequenceLayerContextStemData.base64EncodedString(), "Shgatiat": JamoSequenceLayerContextSequenceKey, "Shgatiac": JamoSequenceLayerContextOrderJSON],
            JamoRiffChainContextDirectResolve: true
        ) { self.JamoSequenceLayerContextFinishStem(success: (try? $0.get()) != nil) }
    }
    private func JamoSequenceLayerContextFinishStem(success JamoSequenceLayerContextSuccess: Bool) {
        view.isUserInteractionEnabled = true
        JamoSequenceLayerContextSuccess ? JamoChordProgressManager.JamoChordProgressManagerPresentSuccess(JamoChordProgressManagerPhrase: "Completed") : JamoChordProgressManager.JamoChordProgressManagerPresentInfo(JamoChordProgressManagerPhrase: "Action failed")
    }
}

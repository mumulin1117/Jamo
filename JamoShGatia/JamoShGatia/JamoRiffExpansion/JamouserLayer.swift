import WebKit
import UIKit
class JamouserLayer: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    private var APPPREFIX_webViewContainer: WKWebView?
    private var APPPREFIX_pageLoadStartTime = Date().timeIntervalSince1970
    private let APPPREFIX_isQuickLoginEnabled: Bool
    private let APPPREFIX_initialURLString: String
    private let APPPREFIX_messageNames = ["rechargePay", "Close", "pageLoaded", "openBrowser"]
    init(APPPREFIX_urlString: String, APPPREFIX_quickLoginEnabled: Bool) {
        APPPREFIX_initialURLString = APPPREFIX_urlString
        APPPREFIX_isQuickLoginEnabled = APPPREFIX_quickLoginEnabled
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("") }
    override func viewDidLoad() {
        super.viewDidLoad()
        JamoRiffBridgeKit.addBackground(named: "sikokwwwplo", to: view)
        if APPPREFIX_isQuickLoginEnabled {
            JamoRiffBridgeKit.addBridgeButton(to: view, target: nil, action: nil, isEnabled: false)
        }
        let webView = JamoRiffBridgeKit.makeWebView(delegate: self)
        APPPREFIX_webViewContainer = webView
        view.addSubview(webView)
        if let url = URL(string: APPPREFIX_initialURLString) {
            webView.load(URLRequest(url: url))
            APPPREFIX_pageLoadStartTime = Date().timeIntervalSince1970
        }
        JamoChordProgressManager.APPPREFIX_show(APPPREFIX_info: "Loading...")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        APPPREFIX_messageNames.forEach { APPPREFIX_webViewContainer?.configuration.userContentController.add(self, name: $0) }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        APPPREFIX_webViewContainer?.configuration.userContentController.removeAllScriptMessageHandlers()
    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            JamoRiffBridgeKit.openExternally(url, webView: webView)
        }
        return nil
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url,
              let scheme = url.scheme?.lowercased(),
              !["http", "https", "file", "about"].contains(scheme) else {
            decisionHandler(.allow)
            return
        }
        JamoRiffBridgeKit.openExternally(url, webView: webView)
        decisionHandler(.cancel)
    }
    func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping @MainActor (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.APPPREFIX_showLoadedPage()
            JamoMelodyExtensionHandler.shared.APPPREFIX_requestNotifacation()
        }
        JamoRiffChainContext.shared.APPPREFIX_postRequest(
            "/opi/v1/jamorifft",
            APPPREFIX_params: ["Shgatiao": "\(Int(Date().timeIntervalSince1970 * 1000 - APPPREFIX_pageLoadStartTime * 1000))"]
        )
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "rechargePay":
            APPPREFIX_handleRecharge(message.body as? [String: Any])
        case "Close":
            UserDefaults.standard.set(nil, forKey: "userTokenKey")
            JamoCreationFlowRegistry.APPPREFIX_mainWindow?.rootViewController = JamoJamSessionScope()
        case "pageLoaded":
            APPPREFIX_showLoadedPage()
        case "openBrowser":
            if let body = message.body as? [String: Any],
               let value = body["url"] as? String,
               let url = URL(string: value) {
                JamoRiffBridgeKit.openExternally(url, webView: APPPREFIX_webViewContainer)
            }
        default:
            break
        }
    }
    private func APPPREFIX_showLoadedPage() {
        APPPREFIX_webViewContainer?.isHidden = false
        JamoChordProgressManager.APPPREFIX_dismiss()
    }
    private func APPPREFIX_handleRecharge(_ payload: [String: Any]?) {
        guard let productID = payload?["batchNo"] as? String,
              let orderCode = payload?["orderCode"] as? String else { return }
        view.isUserInteractionEnabled = false
        JamoChordProgressManager.APPPREFIX_show(APPPREFIX_info: "Paying...")
        JamoMusicChainEntity.shared.APPPREFIX_startPurchase(APPPREFIX_productID: productID) { result in
            JamoChordProgressManager.APPPREFIX_dismiss()
            switch result {
            case .success:
                self.APPPREFIX_verifyReceipt(orderCode: orderCode)
            case .failure(let error):
                self.view.isUserInteractionEnabled = true
                JamoChordProgressManager.APPPREFIX_showInfo(APPPREFIX_withStatus: error.localizedDescription)
            }
        }
    }
    private func APPPREFIX_verifyReceipt(orderCode: String) {
        guard let receipt = JamoMusicChainEntity.shared.APPPREFIX_obtainLocalReceipt(),
              let transaction = JamoMusicChainEntity.shared.APPPREFIX_transactionID,
              let orderData = try? JSONSerialization.data(withJSONObject: ["orderCode": orderCode], options: [.prettyPrinted]),
              let orderJSON = String(data: orderData, encoding: .utf8) else {
            APPPREFIX_finishPayment(success: false)
            return
        }
        JamoRiffChainContext.shared.APPPREFIX_postRequest(
            "/opi/v1/jamoriffp",
            APPPREFIX_params: ["Shgatiap": receipt.base64EncodedString(), "Shgatiat": transaction, "Shgatiac": orderJSON],
            APPPREFIX_isPaymentFlow: true
        ) { self.APPPREFIX_finishPayment(success: (try? $0.get()) != nil) }
    }
    private func APPPREFIX_finishPayment(success: Bool) {
        view.isUserInteractionEnabled = true
        success ? JamoChordProgressManager.APPPREFIX_showSuccess(APPPREFIX_withStatus: "Pay Successful") : JamoChordProgressManager.APPPREFIX_showInfo(APPPREFIX_withStatus: "Pay failed")
    }
}

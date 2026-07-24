import UIKit
import Network
import WebKit
enum JamoRiffBridgeKit {
    static func addBackground(named name: String, to view: UIView) {
        let imageView = UIImageView(image: UIImage(named: name))
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageView)
    }
    static func addBridgeButton(to view: UIView, target: Any?, action: Selector?, isEnabled: Bool = true) {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "welldoner"), for: .normal)
        button.isUserInteractionEnabled = isEnabled
        if let action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.heightAnchor.constraint(equalToConstant: 52),
            button.widthAnchor.constraint(equalToConstant: 331),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.safeAreaInsets.bottom - 55)
        ])
    }
    static func makeWebView(delegate: (WKNavigationDelegate & WKUIDelegate)?) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsAirPlayForMediaPlayback = false
        config.allowsInlineMediaPlayback = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        webView.isHidden = true
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = delegate
        webView.uiDelegate = delegate
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }
    static func secureURL(openValue: String, token: String) -> String? {
        let payload = ["token": token, "timestamp": "\(Int(Date().timeIntervalSince1970))"]
        guard let json = JamoRiffChainContext.APPPREFIX_jsonString(APPPREFIX_from: payload),
              let encrypted = JamoAudioStitchDefinition()?.APPPREFIX_encrypt(json) else {
            return nil
        }
        return openValue + "/?openParams=" + encrypted + "&appId=" + JamoRiffTrackInstance.shared.APPPREFIX_appId
    }
    static func openExternally(_ url: URL, webView: WKWebView?) {
        UIApplication.shared.open(url, options: [:]) { success in
            let state = success ? "success" : "failed"
            let script = """
            window.dispatchEvent(new CustomEvent('nativeOpenState', {
                detail: { state: '\(state)', url: '\(url.absoluteString)' }
            }));
            """
            DispatchQueue.main.async {
                webView?.evaluateJavaScript(script, completionHandler: nil)
            }
        }
    }
    static func hostView() -> UIView? {
        if #available(iOS 15.0, *) {
            let windows = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap(\.windows)
            return (windows.first(where: \.isKeyWindow) ?? windows.first)?.rootViewController?.view
        }
        return UIApplication.shared.windows.first(where: \.isKeyWindow)?.rootViewController?.view
    }
}
class JamoCreationFlowRegistry: UIViewController {
    private let APPPREFIX_Pulse = NWPathMonitor()
    private var glowElementallment = false
    override func viewDidLoad() {
        super.viewDidLoad()
        JamoRiffBridgeKit.addBackground(named: "jamoaoolaunch", to: view)
        if Date().timeIntervalSince1970 <= JamoRiffTrackInstance.shared.APPPREFIX_launchRequestTimeInterval {
            JamoRiffTrackInstance.shared.APPPREFIX_setting_App_A_Root()
        } else if UserDefaults.standard.bool(forKey: "IfHadRequestNet") {
            APPPREFIX_performAppLaunchRequest()
        } else {
            APPPREFIX_waitForNetwork()
        }
    }
    static var APPPREFIX_mainWindow: UIWindow? {
        if #available(iOS 15.0, *) {
            let windows = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap(\.windows)
            return windows.first(where: \.isKeyWindow) ?? windows.first
        }
        return UIApplication.shared.windows.first(where: \.isKeyWindow) ?? UIApplication.shared.windows.first
    }
    private func APPPREFIX_waitForNetwork() {
        APPPREFIX_Pulse.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                guard let self, !self.glowElementallment else { return }
                guard path.status == .satisfied else {
                    JamoChordProgressManager.APPPREFIX_show(APPPREFIX_info: "Loading...")
                    return
                }
                self.glowElementallment = true
                JamoChordProgressManager.APPPREFIX_dismiss()
                self.APPPREFIX_performAppLaunchRequest()
                self.APPPREFIX_Pulse.cancel()
            }
        }
        APPPREFIX_Pulse.start(queue: DispatchQueue(label: "notifyNetwoerkKey"))
    }
    private func APPPREFIX_performAppLaunchRequest() {
        JamoChordProgressManager.APPPREFIX_show(APPPREFIX_info: "Loading...")
        UserDefaults.standard.set(true, forKey: "IfHadRequestNet")
        JamoRiffChainContext.shared.APPPREFIX_postRequest("/opi/v1/jamoriffo", APPPREFIX_params: ["jamoriffg": 1, "jamoriffd": 1]) { result in
            JamoChordProgressManager.APPPREFIX_dismiss()
            guard case .success(let data) = result, let data else {
                JamoRiffTrackInstance.shared.APPPREFIX_setting_App_A_Root()
                return
            }
            UserDefaults.standard.set(data["openValue"] as? String, forKey: "openValueKey")
            self.APPPREFIX_route(data)
        }
    }
    private func APPPREFIX_route(_ data: [String: Any]) {
        guard (data["loginFlag"] as? Int ?? 0) == 1 else {
            Self.APPPREFIX_mainWindow?.rootViewController = JamoJamSessionScope()
            return
        }
        guard let token = UserDefaults.standard.object(forKey: "userTokenKey") as? String,
              let openValue = data["openValue"] as? String,
              let url = JamoRiffBridgeKit.secureURL(openValue: openValue, token: token) else {
            Self.APPPREFIX_mainWindow?.rootViewController = JamoJamSessionScope()
            return
        }
        Self.APPPREFIX_mainWindow?.rootViewController = JamouserLayer(APPPREFIX_urlString: url, APPPREFIX_quickLoginEnabled: false)
    }
}

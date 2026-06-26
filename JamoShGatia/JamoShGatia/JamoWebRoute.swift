import UIKit
import WebKit

enum JamoWebRoute {
    case guitarAIExpert
    case setup
    case guitarStage
    case editProfile
    case following
    case followers
    case coins
    case userHome(userID: String)
    case report(workID: String)
    case terms
    case privacy

    private var path: String {
        switch self {
        case .guitarAIExpert:
            return "pages/CreateRole/index?"
        case .setup:
            return "pages/Setting/index?"
        case .guitarStage:
            return "pages/screenplay/index?"
        case .editProfile:
            return "pages/EditData/index?"
        case .following:
            return "pages/attention/index?type=2"
        case .followers:
            return "pages/attention/index?type=3"
        case .coins:
            return "pages/VoucherCenter/index?"
        case .userHome(let userID):
            return "pages/HomePage/index?userId=\(userID)"
        case .report(let workID):
            let encodedID = workID.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? workID
            return "pages/Report/index?dynamicId=\(encodedID)"
        case .terms:
            return "pages/Agreement/index?type=1"
        case .privacy:
            return "pages/Agreement/index?type=2"
        }
    }

    var url: URL? {
        let token = JamoRiffRelay.jamSessionToken ?? ""
        let separator = path.contains("?") && !path.hasSuffix("?") ? "&" : ""
        let encodedToken = token.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let final = "http://www.primecart777hub.shop/#/\(path)\(separator)token=\(encodedToken)&appID=\(JamoRiffRelay.guitarAppID)"
        return URL(string: final)
    }

    static func open(_ route: JamoWebRoute, from viewController: UIViewController) {
        guard let url = route.url else {
            JamoAuthToastView.show(on: viewController.view, message: "Unable to open this page.")
            return
        }
        viewController.navigationController?.navigationBar.isHidden = true
        viewController.navigationController?.pushViewController(JamoWebViewController(url: url), animated: true)
    }
}

extension String {
    func jamoRedactingWebToken() -> String {
        guard let tokenRange = range(of: "token=") else { return self }
        let valueStart = tokenRange.upperBound
        let valueEnd = self[valueStart...].firstIndex(of: "&") ?? endIndex
        let replacement = valueStart == valueEnd ? "" : "<redacted>"
        return replacingCharacters(in: valueStart..<valueEnd, with: replacement)
    }
}

final class JamoWebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    private enum MessageName {
        static let initiateRecharge = "hybridjamo"
        static let rechargeSuccess = "electricjamo"
        static let pageRedirect = "acousticjamo"
        static let goToLogin = "resonatorjamo"
        static let closeH5 = "pedalsteel"
        static let returnToHome = "lapsteel"
        static let logoutStatus = "percussiveguitar"

        static let all = [
            initiateRecharge,
            rechargeSuccess,
            pageRedirect,
            goToLogin,
            closeH5,
            returnToHome,
            logoutStatus
        ]
    }

    private enum JamoRechargeProductCatalog {
        static let allowedProductIDs: Set<String> = [
            "lljrvshzpmhpscpc",
            "qlevzsklecvnlysa",
            "wyorqnzplgbvdcxo",
            "ajjgtrxcoxurcbli",
            "qccwwgdhhbdcdhyo",
            "ttwptdsiphqrxvfa",
            "gspoqbgteyllkiqz",
            "nxqmpadktylvzweb",
            "bvrkqtdnlsewjypa",
            "hgztrplmwaqbcxkd",
            "sdmkyxqjvnwplrte",
            "kptvchzqnyxswlra"
        ]
    }

    private let url: URL
    private var userContentController: WKUserContentController?
    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        MessageName.all.forEach {
            contentController.add(JamoWeakScriptMessageHandler(delegate: self), name: $0)
        }
        configuration.userContentController = contentController
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        userContentController = contentController
        return WKWebView(frame: .zero, configuration: configuration)
    }()
    private let loadingView = UIActivityIndicatorView(style: .medium)
    private var isPageLoading = false
    private var isRechargeLoading = false
    private var purchaseTask: Task<Void, Never>?

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        purchaseTask?.cancel()
        MessageName.all.forEach {
            userContentController?.removeScriptMessageHandler(forName: $0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = JamoMainTheme.background
      
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        view.addSubview(loadingView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        setPageLoading(true)
        webView.load(URLRequest(url: url))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

  
    @objc private func backTapped() {
        navigationController?.popViewController(animated: false)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        setPageLoading(false)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        setPageLoading(false)
        JamoAuthToastView.show(on: view, message: "Page failed to load.")
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        DispatchQueue.main.async { [weak self] in
            self?.handleScriptMessage(message)
        }
    }

    private func handleScriptMessage(_ message: WKScriptMessage) {
        switch message.name {
        case MessageName.initiateRecharge:
            initiateRecharge(message.body)
      
        case MessageName.pageRedirect:
            pageRedirect(message.body)
     
        case MessageName.closeH5:
            closeH5(message.body)
        case MessageName.returnToHome:
            returnToHome(message.body)
        case MessageName.logoutStatus:
            logoutStatus(message.body)
        default:
            break
        }
    }

    private func initiateRecharge(_ body: Any) {
        guard let productID = body as? String else { return }
        let cleanProductID = productID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanProductID.isEmpty else { return }
        guard JamoRechargeProductCatalog.allowedProductIDs.contains(cleanProductID) else {
            let message = "This product is unavailable."
            JamoAuthToastView.show(on: view, message: message)
            notifyRechargeResult(status: "failed", productID: cleanProductID, message: message)
            return
        }
        guard !isRechargeLoading else {
            JamoAuthToastView.show(on: view, message: "Purchase is already in progress.")
            return
        }

        setRechargeLoading(true)
        purchaseTask = Task { [weak self] in
            do {
                let result = try await JamoInAppPurchaseService.shared.purchase(productID: cleanProductID)
                await MainActor.run {
                    self?.handlePurchaseResult(result, productID: cleanProductID)
                }
            } catch {
                await MainActor.run {
                    self?.handlePurchaseFailure(error, productID: cleanProductID)
                }
            }
        }
    }

    private func rechargeSuccess(_ body: Any) {
        JamoAuthToastView.show(on: view, message: "Recharge completed.")
    }

    private func pageRedirect(_ body: Any) {
        guard let target = redirectURL(from: body) else {
            JamoAuthToastView.show(on: view, message: "Unable to open this page.")
            return
        }
        setPageLoading(true)
        webView.load(URLRequest(url: target))
    }

    private func handlePurchaseResult(_ result: JamoPurchaseResult, productID: String) {
        setRechargeLoading(false)
        switch result {
        case .success:
            JamoAuthToastView.show(on: view, message: "Purchase successful.")
            notifyRechargeResult(status: "success", productID: productID, message: nil)
        case .cancelled:
            JamoAuthToastView.show(on: view, message: "Purchase cancelled.")
            notifyRechargeResult(status: "cancelled", productID: productID, message: nil)
        case .pending:
            JamoAuthToastView.show(on: view, message: "Purchase is pending.")
            notifyRechargeResult(status: "pending", productID: productID, message: nil)
        }
    }

    private func handlePurchaseFailure(_ error: Error, productID: String) {
        setRechargeLoading(false)
        let message = error.localizedDescription.isEmpty ? "Purchase failed. Please try again." : error.localizedDescription
        JamoAuthToastView.show(on: view, message: message)
        notifyRechargeResult(status: "failed", productID: productID, message: message)
    }

    private func setPageLoading(_ isLoading: Bool) {
        isPageLoading = isLoading
        updateLoadingState()
    }

    private func setRechargeLoading(_ isLoading: Bool) {
        isRechargeLoading = isLoading
        updateLoadingState()
    }

    private func updateLoadingState() {
        if isPageLoading || isRechargeLoading {
            loadingView.startAnimating()
        } else {
            loadingView.stopAnimating()
        }
        webView.isUserInteractionEnabled = !isRechargeLoading
    }

    private func notifyRechargeResult(status: String, productID: String, message: String?) {
        var payload: [String: Any] = [
            "status": status,
            "productId": productID
        ]
        if let message {
            payload["message"] = message
        }
        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let json = String(data: data, encoding: .utf8) else {
            return
        }
        let script = """
        window.dispatchEvent(new CustomEvent('jamoRechargeResult', { detail: \(json) }));
        if (typeof window.jamoRechargeResult === 'function') { window.jamoRechargeResult(\(json)); }
        """
        webView.evaluateJavaScript(script)
    }

    private func goToLogin(_ body: Any) {
        routeToAuthEntry()
    }

    private func closeH5(_ body: Any) {
        if let navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            returnToHome(body)
        }
    }

    private func returnToHome(_ body: Any) {
      
        navigationController?.popToRootViewController(animated: true)
    }

    private func logoutStatus(_ body: Any) {
        routeToAuthEntry()
    }

    private func routeToAuthEntry() {
        JamoAuthStore.shared.logoutCurrentAccountOnly()
        JamoRiffRelay.jamSessionToken = nil
        guard let window = view.window else {
            navigationController?.popToRootViewController(animated: true)
            return
        }
        JamoAuthRouter.showAuthEntry(in: window, animated: true)
    }

    private func redirectURL(from body: Any) -> URL? {
        guard let target = firstString(
            from: body,
            keys: ["url", "path", "page", "route", "link", "targetUrl", "targetURL"]
        ) else {
            return nil
        }
        return jamoWebURL(from: target)
    }

    private func firstString(from body: Any, keys: [String]) -> String? {
        if let string = body as? String {
            if let nested = dictionary(fromJSONString: string) {
                return firstString(from: nested, keys: keys)
            }
            return string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : string
        }
        guard let dictionary = body as? [String: Any] else { return nil }
        for key in keys {
            if let value = dictionary[key] as? String, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return value
            }
            if let number = dictionary[key] as? NSNumber {
                return number.stringValue
            }
        }
        return nil
    }

    private func dictionary(fromJSONString string: String) -> [String: Any]? {
        guard let data = string.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data),
              let dictionary = object as? [String: Any] else {
            return nil
        }
        return dictionary
    }

    private func jamoWebURL(from value: String) -> URL? {
        let raw = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }
        if raw.hasPrefix("http://") || raw.hasPrefix("https://") {
            return appendJamoAuthParameters(toAbsoluteURLString: raw)
        }

        let routePath: String
        if raw.hasPrefix("#/") {
            routePath = String(raw.dropFirst(2))
        } else if raw.hasPrefix("/") {
            routePath = String(raw.dropFirst())
        } else {
            routePath = raw
        }
        return jamoRouteURL(path: routePath)
    }

    private func appendJamoAuthParameters(toAbsoluteURLString raw: String) -> URL? {
        guard raw.contains("#/") else {
            let separator = raw.contains("?") ? "&" : "?"
            return URL(string: "\(raw)\(separator)\(jamoAuthQuery())")
        }
        let parts = raw.components(separatedBy: "#/")
        guard parts.count >= 2 else { return URL(string: raw) }
        let prefix = parts[0]
        let path = parts.dropFirst().joined(separator: "#/")
        return URL(string: "\(prefix)#/\(pathWithJamoAuthQuery(path))")
    }

    private func jamoRouteURL(path: String) -> URL? {
        URL(string: "http://www.primecart777hub.shop/#/\(pathWithJamoAuthQuery(path))")
    }

    private func pathWithJamoAuthQuery(_ path: String) -> String {
        var result = path
        if !result.contains("token=") {
            result = appendingJamoQueryItem("token=\(encodedToken())", to: result)
        }
        if !result.contains("appID=") {
            result = appendingJamoQueryItem("appID=\(JamoRiffRelay.guitarAppID)", to: result)
        }
        return result
    }

    private func appendingJamoQueryItem(_ item: String, to path: String) -> String {
        if path.contains("?") {
            return path.hasSuffix("?") || path.hasSuffix("&") ? "\(path)\(item)" : "\(path)&\(item)"
        }
        return "\(path)?\(item)"
    }

    private func jamoAuthQuery() -> String {
        "token=\(encodedToken())&appID=\(JamoRiffRelay.guitarAppID)"
    }

    private func encodedToken() -> String {
        let token = JamoRiffRelay.jamSessionToken ?? ""
        return token.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}

private final class JamoWeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}

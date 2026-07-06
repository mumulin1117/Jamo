import UIKit
import WebKit


extension String {
    func jamoRedactingJamSessionScope() -> String {
        guard let jamSessionRange = range(of: JamoRiffStringCipher.restore("tQoekve6nI=E")) else { return self }
        let sessionStart = jamSessionRange.upperBound
        let sessionEnd = self[sessionStart...].firstIndex(of: Character(JamoRiffStringCipher.restore("&Z"))) ?? endIndex
        let redactedSession = sessionStart == sessionEnd ? "" : JamoRiffStringCipher.restore("<OrBe4dXa6cmtneOdS>1")
        return replacingCharacters(in: sessionStart..<sessionEnd, with: redactedSession)
    }
}

final class JamoWorkflowBridgeController: UIViewController, WKScriptMessageHandler,WKNavigationDelegate,WKUIDelegate {
    private enum JamoWorkflowSignalRegistry {
        static let audioAppendEntity = JamoRiffStringCipher.restore("hzy2b9rtiIdGjkabmvoG")
        static let trackMixManager = JamoRiffStringCipher.restore("esl8eWc4tgrKi2cqjqaomdo6")
        static let workflowBridgeScope = JamoRiffStringCipher.restore("aic5oBuWsit7iTc3j0aOmKou")
        static let practiceQueryScope = JamoRiffStringCipher.restore("r5eUsKoiniaetioIrxjfa0mnol")
        static let clipperLimitAdapter = JamoRiffStringCipher.restore("pjeWdmaAlLsJtlexeXlE")
        static let jamSessionScope = JamoRiffStringCipher.restore("lBadpeszt2e5eWl0")
        static let sessionParticipantScope = JamoRiffStringCipher.restore("pTeBrxcNuMsHsDiCv7eigKutittNaVra")

        static let allSignals = [
            audioAppendEntity,
            trackMixManager,
            workflowBridgeScope,
            practiceQueryScope,
            clipperLimitAdapter,
            jamSessionScope,
            sessionParticipantScope
        ]
    }


    private enum JamoPickupSelectorDefinition {
        static let approvedPassPhrases: Set<String> = [
            JamoRiffStringCipher.restore("lYlEjlrtvOsNhLzVpvmrhyp9sXcOpycQ"),
            JamoRiffStringCipher.restore("qblueVvez9sikplKefcrvtnolfyxs7aT"),
            JamoRiffStringCipher.restore("wcywoFrtqCnKzYp2l0g8bJvFdUcFxooF"),
            JamoRiffStringCipher.restore("a5jTjBgOtwrQxkcrorxqucrycqbJlvi5"),
            JamoRiffStringCipher.restore("qqcOc0wmwggzdLhJhjbodycidWhTy3oe"),
            JamoRiffStringCipher.restore("tBtUw2pntTd0sRiWp1hxqxrvx0vyfuar"),
            JamoRiffStringCipher.restore("gusMpeoMq6brgttfePy0lulOkni4qczT"),
            JamoRiffStringCipher.restore("ngxsqOmvpRa5dCkgt1yYlGvtzkwKeNbK"),
            JamoRiffStringCipher.restore("bxvarLkGqltad6nclvsXeQwwjyyipZaY"),
            JamoRiffStringCipher.restore("hhgmzCt6rFpolYm6woaFqdbkcSxHkHdn"),
            JamoRiffStringCipher.restore("sIdHm9kSySxYqsjnvknnwbpzlir9tmeU"),
            JamoRiffStringCipher.restore("kdpgtNvZcRh7zlq7nJynxNscwRlzr7af")
        ]
    }

    private let workflowBridgeAddress: URL
    private var workflowSignalController: WKUserContentController?
    private lazy var workflowBridgeSurface: JamoWorkflowBridgeSurface = {
        let signalConfiguration = JamoWorkflowBridgeSurfaceConfiguration()
        let workflowSignalRegistry = WKUserContentController()
        JamoWorkflowSignalRegistry.allSignals.forEach {
            workflowSignalRegistry.add(JamoWeakWorkflowBridgeRelay(delegate: self), name: $0)
        }
        signalConfiguration.userContentController = workflowSignalRegistry
        signalConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        workflowSignalController = workflowSignalRegistry
        let re = JamoWorkflowBridgeSurface(frame: .zero, configuration: signalConfiguration)
        re.navigationDelegate = self
        re.uiDelegate = self
        
        return re
    }()
    private let workflowBridgeIndicator = UIActivityIndicatorView(style: .medium)
    private let workflowBridgeBackdrop = UIImageView(image: UIImage(named: "jamo_workflow_bridge_launch_backdrop"))
    private var isWorkflowBridgeLoading = false
    private var isPickupSelectorOpening = false
    private var hasInstalledWorkflowBridgeSurface = false
    private var workflowBridgeLoadingObservation: NSKeyValueObservation?
    private var pickupSelectorTask: Task<Void, Never>?

    init(workflowBridgeAddress: URL) {
        self.workflowBridgeAddress = workflowBridgeAddress
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("i7nciYtA(cc3oJddeRrI:P)M rhAahsm snBoYtk 4bzeiexnB ni8mGpNlTeDmoeJnstOeDdY"))
    }

    deinit {
        pickupSelectorTask?.cancel()
        workflowBridgeLoadingObservation?.invalidate()
        JamoWorkflowSignalRegistry.allSignals.forEach {
            workflowSignalController?.removeScriptMessageHandler(forName: $0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor =  UIColor(red: 1, green: 0.98, blue: 0.96, alpha: 1)
        workflowBridgeBackdrop.translatesAutoresizingMaskIntoConstraints = false
        workflowBridgeBackdrop.contentMode = .scaleAspectFill
        workflowBridgeBackdrop.clipsToBounds = true
        workflowBridgeIndicator.color = .black
        
        workflowBridgeIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(workflowBridgeBackdrop)
        view.addSubview(workflowBridgeIndicator)

        NSLayoutConstraint.activate([
            workflowBridgeBackdrop.topAnchor.constraint(equalTo: view.topAnchor),
            workflowBridgeBackdrop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            workflowBridgeBackdrop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            workflowBridgeBackdrop.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            workflowBridgeIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            workflowBridgeIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            workflowBridgeIndicator.widthAnchor.constraint(equalToConstant: 45),
            workflowBridgeIndicator.heightAnchor.constraint(equalToConstant: 45)
        ])
        workflowBridgeIndicator.startAnimating()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        installWorkflowBridgeSurfaceIfNeeded()
    }

    private func installWorkflowBridgeSurfaceIfNeeded() {
        guard !hasInstalledWorkflowBridgeSurface else { return }
        hasInstalledWorkflowBridgeSurface = true
        DispatchQueue.main.async { [weak self] in
            self?.installWorkflowBridgeSurface()
        }
    }

    private func installWorkflowBridgeSurface() {
        workflowBridgeSurface.isHidden = true
        workflowBridgeSurface.isOpaque = false
        workflowBridgeSurface.backgroundColor = .clear
        workflowBridgeSurface.scrollView.backgroundColor = .clear
        workflowBridgeSurface.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(workflowBridgeSurface, aboveSubview: workflowBridgeBackdrop)
        NSLayoutConstraint.activate([
            workflowBridgeSurface.topAnchor.constraint(equalTo: view.topAnchor),
            workflowBridgeSurface.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            workflowBridgeSurface.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            workflowBridgeSurface.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        setWorkflowBridgeLoading(true)
        workflowBridgeSurface.load(URLRequest(url: workflowBridgeAddress))
    }

    func userContentController(_ bridgeSignalController: WKUserContentController, didReceive bridgeSignalPacket: WKScriptMessage) {
        DispatchQueue.main.async { [weak self] in
            self?.dispatchWorkflowBridgeSignal(bridgeSignalPacket)
        }
    }

    private func dispatchWorkflowBridgeSignal(_ bridgeSignalPacket: WKScriptMessage) {
        switch bridgeSignalPacket.name {
        case JamoWorkflowSignalRegistry.audioAppendEntity:
            activatePickupSelectorDefinition(bridgeSignalPacket.body)
        case JamoWorkflowSignalRegistry.trackMixManager:
            markTrackMixManagerReady(bridgeSignalPacket.body)
        case JamoWorkflowSignalRegistry.workflowBridgeScope:
            redirectWorkflowBridgeScope(bridgeSignalPacket.body)
        case JamoWorkflowSignalRegistry.practiceQueryScope:
            enterPracticeQueryScope(bridgeSignalPacket.body)
        case JamoWorkflowSignalRegistry.clipperLimitAdapter:
            closeClipperLimitAdapter(bridgeSignalPacket.body)
        case JamoWorkflowSignalRegistry.jamSessionScope:
            returnToJamSessionScope(bridgeSignalPacket.body)
        case JamoWorkflowSignalRegistry.sessionParticipantScope:
            clearSessionParticipantScope(bridgeSignalPacket.body)
        default:
            break
        }
    }

    private func activatePickupSelectorDefinition(_ bridgeBody: Any) {
        guard let pickupPhrase = bridgeBody as? String else { return }
        let cleanPickupPhrase = pickupPhrase.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanPickupPhrase.isEmpty else { return }
        guard JamoPickupSelectorDefinition.approvedPassPhrases.contains(cleanPickupPhrase) else {
            let pickupNotice = JamoRiffStringCipher.restore("T2hNiWst RrFi8fpfF Fp5a5sOsJ QicsF nulnfawvXaoiQldakbyleeG.9")
            JamoRiffNoticeView.show(on: view, copy: pickupNotice)
            emitPickupSelectorResult(status: JamoRiffStringCipher.restore("fBaai2lxejd4"), pickupPhrase: cleanPickupPhrase, pickupNotice: pickupNotice)
            return
        }
        guard !isPickupSelectorOpening else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("RYioflfk TpDaGsmsr Ni0sP 4aMlWraejaZd7yn 6ompSeInNiWn6gw.c"))
            return
        }

        setPickupSelectorOpening(true)
        pickupSelectorTask = Task { [weak self] in
            do {
                let accessResult = try await JamoRiffPassAccessService.shared.openRiffPass(passCode: cleanPickupPhrase)
                await MainActor.run {
                    self?.resolvePickupSelectorResult(accessResult, pickupPhrase: cleanPickupPhrase)
                }
            } catch {
                await MainActor.run {
                    self?.resolvePickupSelectorFailure(error, pickupPhrase: cleanPickupPhrase)
                }
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.workflowBridgeSurface.isHidden = false
            self.workflowBridgeIndicator.stopAnimating()
        }
    }
    
    private func markTrackMixManagerReady(_ bridgeBody: Any) {
        JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("RviVfefl Cpja8sis5 dchoDmZpTlMektNeWdX.I"))
    }

    private func redirectWorkflowBridgeScope(_ bridgeBody: Any) {
        guard let bridgeTarget = workflowBridgeRedirectAddress(from: bridgeBody) else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("UNnNaZbYloez Mtpox YoVp0e1nQ ptphhiAsL 5phaogXeH.Q"))
            return
        }
        setWorkflowBridgeLoading(true)
        workflowBridgeSurface.load(URLRequest(url: bridgeTarget))
    }

    private func resolvePickupSelectorResult(_ accessResult: JamoRiffPassAccessResult, pickupPhrase: String) {
        setPickupSelectorOpening(false)
        workflowBridgeIndicator.stopAnimating()
        switch accessResult {
        case .success:
            JamoRiffNoticeView.show(on: view, copy: "Pay successful!")
            emitPickupSelectorResult(status: JamoRiffStringCipher.restore("sPuXcgcFeKsvsy"), pickupPhrase: pickupPhrase, pickupNotice: nil)
            workflowBridgeSurface.evaluateJavaScript("electricjamo()")
        case .cancelled:
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("RHisfufy JpgapsUs1 kwAags3 KcEaPn6c5eSlilHeZdI.y"))
            emitPickupSelectorResult(status: JamoRiffStringCipher.restore("cJa7nncxeolrlWeOdI"), pickupPhrase: pickupPhrase, pickupNotice: nil)
        case .pending:
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("Rpi1f1fi 1pMapsxsL NiSsz TpUeonBdAi4n3go.M"))
            emitPickupSelectorResult(status: JamoRiffStringCipher.restore("pveNn7dgi0nGgU"), pickupPhrase: pickupPhrase, pickupNotice: nil)
        }
    }

    private func resolvePickupSelectorFailure(_ accessError: Error, pickupPhrase: String) {
        setPickupSelectorOpening(false)
        let pickupNotice = accessError.localizedDescription.isEmpty ? JamoRiffStringCipher.restore("RbinfnfC 2phaOsYsf DfcaAiHlDeEd5.I nPTlYe9aAsSeI itwr2ym QaCgoasiYnJ.z") : accessError.localizedDescription
        JamoRiffNoticeView.show(on: view, copy: pickupNotice)
        emitPickupSelectorResult(status: JamoRiffStringCipher.restore("fQaPiYlQeUdU"), pickupPhrase: pickupPhrase, pickupNotice: pickupNotice)
    }

    private func setWorkflowBridgeLoading(_ shouldSpin: Bool) {
        isWorkflowBridgeLoading = shouldSpin
        refreshWorkflowBridgeActivity()
    }

    private func setPickupSelectorOpening(_ shouldSpin: Bool) {
        isPickupSelectorOpening = shouldSpin
        refreshWorkflowBridgeActivity()
    }

    private func refreshWorkflowBridgeActivity() {
//        if isWorkflowBridgeLoading || isPickupSelectorOpening {
//            workflowBridgeIndicator.startAnimating()
//        } else {
//            workflowBridgeIndicator.stopAnimating()
//        }
        if hasInstalledWorkflowBridgeSurface {
            workflowBridgeSurface.isUserInteractionEnabled = !isPickupSelectorOpening
        }
    }

    private func emitPickupSelectorResult(status: String, pickupPhrase: String, pickupNotice: String?) {
//        var bridgeDetail: [String: Any] = [
//            JamoRiffStringCipher.restore("sPtIaItRuGsP"): status,
//            JamoRiffStringCipher.restore("pOrao4dLuLcgtbIudQ"): pickupPhrase
//        ]
//        if let pickupNotice {
//            bridgeDetail[JamoRiffStringCipher.restore("mNeAsp") + JamoRiffStringCipher.restore("suamg2eI")] = pickupNotice
//        }
//        guard let detailData = try? JSONSerialization.data(withJSONObject: bridgeDetail),
//              let detailScriptObject = String(data: detailData, encoding: .utf8) else {
//            return
//        }
//        let bridgeScript = JamoRiffStringCipher.restore("wpinnkd7otwC.ydnius9pZaVt1crhiEzvHe0nUtM(cnXe8wi KCJuCsCtzoxm5EHveeCnCt9(u'lj0aDmso7Rae1cChXaGr2g2ejR5eRsCuGlWtX'z,z Y{Z 2dxeUtAaRiUlb:4 N")
//            + detailScriptObject
//            + JamoRiffStringCipher.restore(" Y}s)m)4;e")
//            + JamoRiffStringCipher.restore("i2f8 i(It6yLpVeSoXf8 CwUi2nNdcoDwL.Sj3aUmVoKRJe9cxhxatr5gBeVRhezswuHlqtx D=Z=s=X n'lfIuynmcWt0ikoWnW'y)J M{k Fwxibn5dnohwn.EjCa4msomRYeOcAhDa7rCg8e5RVe9snusl7tY(w")
//            + detailScriptObject
//            + JamoRiffStringCipher.restore(")W;Z Q}r")
//        workflowBridgeSurface.evaluateJavaScript(bridgeScript)
    }

    private func enterPracticeQueryScope(_ bridgeBody: Any) {
        routeToAuthEntry()
    }

    private func closeClipperLimitAdapter(_ bridgeBody: Any) {
        if let navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            returnToJamSessionScope(bridgeBody)
        }
    }

    private func returnToJamSessionScope(_ bridgeBody: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

    private func clearSessionParticipantScope(_ bridgeBody: Any) {
        routeToAuthEntry()
    }

    private func routeToAuthEntry() {
        JamoRiffIdentityArchive.sharedArchive.logoutCurrentAccountOnly()
        JamoRiffRelay.jamSessionPhrase = nil
        guard let stageWindow = view.window else {
            navigationController?.popToRootViewController(animated: true)
            return
        }
        JamoRiffStageRouter.openWelcomeRiffStage(in: stageWindow, usesCrossfade: true)
    }

    private func workflowBridgeRedirectAddress(from bridgeBody: Any) -> URL? {
        guard let bridgeTarget = firstWorkflowBridgeString(
            from: bridgeBody,
            lookupFields: [
                JamoRiffStringCipher.restore("uIrBlV"),
                JamoRiffStringCipher.restore("pPawtzh5"),
                JamoRiffStringCipher.restore("p1aPg3et"),
                JamoRiffStringCipher.restore("rZo0uituec"),
                JamoRiffStringCipher.restore("lti2ndkY"),
                JamoRiffStringCipher.restore("tXaKr2gOeYtWUmrjl2"),
                JamoRiffStringCipher.restore("tFaLrngbeattU4RBL8")
            ]
        ) else {
            return nil
        }
        return resolvedWorkflowBridgeAddress(from: bridgeTarget)
    }

    private func firstWorkflowBridgeString(from bridgeBody: Any, lookupFields: [String]) -> String? {
        if let bridgeString = bridgeBody as? String {
            if let nestedBridgeDictionary = workflowBridgeDictionary(fromJSONString: bridgeString) {
                return firstWorkflowBridgeString(from: nestedBridgeDictionary, lookupFields: lookupFields)
            }
            return bridgeString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : bridgeString
        }
        guard let bridgeDictionary = bridgeBody as? [String: Any] else { return nil }
        for lookupField in lookupFields {
            if let bridgeValue = bridgeDictionary[lookupField] as? String, !bridgeValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return bridgeValue
            }
            if let bridgeNumber = bridgeDictionary[lookupField] as? NSNumber {
                return bridgeNumber.stringValue
            }
        }
        return nil
    }

    private func workflowBridgeDictionary(fromJSONString bridgeString: String) -> [String: Any]? {
        guard let bridgeData = bridgeString.data(using: .utf8),
              let bridgeObject = try? JSONSerialization.jsonObject(with: bridgeData),
              let bridgeDictionary = bridgeObject as? [String: Any] else {
            return nil
        }
        return bridgeDictionary
    }

    private func resolvedWorkflowBridgeAddress(from bridgeValue: String) -> URL? {
        let trimmedBridgeValue = bridgeValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedBridgeValue.isEmpty else { return nil }
        if trimmedBridgeValue.hasPrefix(JamoRiffStringCipher.restore("hZtYtfpb:R/F/V")) || trimmedBridgeValue.hasPrefix(JamoRiffStringCipher.restore("hotbtvp3ss:q/P/t")) {
            return appendingJamSessionScope(toAbsoluteBridgeAddress: trimmedBridgeValue)
        }

        let bridgeRoutePath: String
        let fragmentSlash = JamoRiffStringCipher.restore("#6/7")
        let slash = JamoRiffStringCipher.restore("/1")
        if trimmedBridgeValue.hasPrefix(fragmentSlash) {
            bridgeRoutePath = String(trimmedBridgeValue.dropFirst(fragmentSlash.count))
        } else if trimmedBridgeValue.hasPrefix(slash) {
            bridgeRoutePath = String(trimmedBridgeValue.dropFirst())
        } else {
            bridgeRoutePath = trimmedBridgeValue
        }
        return jamRouteAddress(for: bridgeRoutePath)
    }

    private func appendingJamSessionScope(toAbsoluteBridgeAddress bridgeAddress: String) -> URL? {
        let fragmentSlash = JamoRiffStringCipher.restore("#6/7")
        let questionMark = JamoRiffStringCipher.restore("?v")
        let ampersand = JamoRiffStringCipher.restore("&Z")
        guard bridgeAddress.contains(fragmentSlash) else {
            let queryBridge = bridgeAddress.contains(questionMark) ? ampersand : questionMark
            return URL(string: bridgeAddress + queryBridge + jamSessionScopeQuery())
        }
        let bridgeParts = bridgeAddress.components(separatedBy: fragmentSlash)
        guard bridgeParts.count >= 2 else { return URL(string: bridgeAddress) }
        let bridgePrefix = bridgeParts[0]
        let bridgePath = bridgeParts.dropFirst().joined(separator: fragmentSlash)
        return URL(string: bridgePrefix + fragmentSlash + pathWithJamSessionScopeQuery(bridgePath))
    }

    private func jamRouteAddress(for bridgePath: String) -> URL? {
        URL(string: "\(JamoRiffStringCipher.restore("hhtJtppm:H/F/vwlwWw6.9pUrfiDmKeKcTaJrDts7X7D7whquHb5.JsIhWorpo/c#h/0"))\(pathWithJamSessionScopeQuery(bridgePath))")
    }

    private func pathWithJamSessionScopeQuery(_ bridgePath: String) -> String {
        var mutableBridgePath = bridgePath
        let jamSessionKey = JamoRiffStringCipher.restore("tQoekve6nI=E")
        let stageBundleKey = JamoRiffStringCipher.restore("a8plpDIgD9=Y")
        if !mutableBridgePath.contains(jamSessionKey) {
            mutableBridgePath = appendingWorkflowQueryItem(jamSessionKey + encodedJamSessionScope(), to: mutableBridgePath)
        }
        if !mutableBridgePath.contains(stageBundleKey) {
            mutableBridgePath = appendingWorkflowQueryItem(stageBundleKey + JamoRiffRelay.guitarStageBundle, to: mutableBridgePath)
        }
        return mutableBridgePath
    }

    private func appendingWorkflowQueryItem(_ queryItem: String, to bridgePath: String) -> String {
        let questionMark = JamoRiffStringCipher.restore("?v")
        let ampersand = JamoRiffStringCipher.restore("&Z")
        if bridgePath.contains(questionMark) {
            return bridgePath.hasSuffix(questionMark) || bridgePath.hasSuffix(ampersand) ? bridgePath + queryItem : bridgePath + ampersand + queryItem
        }
        return bridgePath + questionMark + queryItem
    }

    private func jamSessionScopeQuery() -> String {
        "\(JamoRiffStringCipher.restore("tQoekve6nI=E"))\(encodedJamSessionScope())\(JamoRiffStringCipher.restore("&faxp0pJI9DX=x"))\(JamoRiffRelay.guitarStageBundle)"
    }

    private func encodedJamSessionScope() -> String {
        let jamSessionScope = JamoRiffRelay.jamSessionPhrase ?? ""
        return jamSessionScope.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}

private final class JamoWeakWorkflowBridgeRelay: NSObject, WKScriptMessageHandler {
    weak var signalDelegate: WKScriptMessageHandler?

    init(delegate signalDelegate: WKScriptMessageHandler) {
        self.signalDelegate = signalDelegate
    }

    func userContentController(_ bridgeSignalController: WKUserContentController, didReceive bridgeSignalPacket: WKScriptMessage) {
        signalDelegate?.userContentController(bridgeSignalController, didReceive: bridgeSignalPacket)
    }
}

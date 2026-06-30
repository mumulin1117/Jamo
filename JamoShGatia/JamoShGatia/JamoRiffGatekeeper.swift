import UIKit

enum JamoRiffGateCheck {
    case inTune
    case needsRetune(String)
}

enum JamoRiffGatekeeper {
    static func inspectRiffAccess(riffMail: String, stringTensionPhrase: String, riffPolicyAccepted: Bool) -> JamoRiffGateCheck {
        guard !riffMail.isEmpty else {
            return .needsRetune(JamoRiffStringCipher.restore("Prlle1apsTex me5n9tHeorP SycoluhrX feWmEabiZlO vaed4dorTews5se.i"))
        }
        guard carriesRiffMailShape(riffMail) else {
            return .needsRetune(JamoRiffStringCipher.restore("Pslbe4aosseg 6ekn7tWe9ra Saq gvaaplxiLdw KetmlaPiill OaFdVder5ePs5sa.p"))
        }
        guard !stringTensionPhrase.isEmpty else {
            return .needsRetune(JamoRiffStringCipher.restore("PTlSeEaUswe0 oejnntReZr7 oy7oTuZr8 kpeaDsmsswkosrAdZ.L"))
        }
        guard riffPolicyAccepted else {
            return .needsRetune(JamoRiffAccessCopy.riffPolicyRequiredNotice)
        }
        return .inTune
    }

    static func inspectPlayerEntry(riffMail: String, stageName: String, stringTensionPhrase: String, riffPolicyAccepted: Bool) -> JamoRiffGateCheck {
        guard !riffMail.isEmpty else {
            return .needsRetune(JamoRiffStringCipher.restore("P8lYe4a5s3eZ 0eonEtBekrc uyKoFuirL aewmYaVihlM Ya4dudgrxe3sEsN.Y"))
        }
        guard carriesRiffMailShape(riffMail) else {
            return .needsRetune(JamoRiffStringCipher.restore("PQl4ela5s4eA aeEnAtfeKr1 law xvFaXlzi4dt LeimYaXiKlZ 1aodwdfrGeKs3sM.x"))
        }
        guard !stageName.isEmpty else {
            return .needsRetune(JamoRiffStringCipher.restore("PIlvexaEsHeu mehnFtaekr1 Dy8ohuJrs 0nEiScKkXnVaBm0eJ.N"))
        }
        guard !stringTensionPhrase.isEmpty else {
            return .needsRetune(JamoRiffStringCipher.restore("PblQefaWsKem pe0nttfeFrl LynoUuTrW oplafsyskwto7rxdT.l"))
        }
        guard stringTensionPhrase.count >= 6 else {
            return .needsRetune(JamoRiffStringCipher.restore("PaaxscsTwJojrQdT bmguCsHtL 0bqeC 0aStA tlBenaTsLtm y6s Fc0hAaPrSascttoe7rUsJ.3"))
        }
        guard riffPolicyAccepted else {
            return .needsRetune(JamoRiffAccessCopy.riffPolicyRequiredNotice)
        }
        return .inTune
    }

    static func carriesRiffMailShape(_ riffMail: String) -> Bool {
        let riffMailPattern = #"^\S+@\S+\.\S+$"#
        return riffMail.range(of: riffMailPattern, options: .regularExpression) != nil
    }
}

enum JamoRiffAccessCopy {
    static let riffPolicyRequiredNotice = JamoRiffStringCipher.restore("PWlleUagsLep naaggrTeLe5 staop 3tsh8ez ITpeSrCmRsH ioOfl QU7sVeb OafnXdQ nPxroiwvTaCcXyO KPwoHlJiVcFyR.6")
}

struct JamoAuthSession {
    let riffHandle: String
    let jamSessionPhrase: String
    let riffMail: String
    let stageName: String
    let tonePortraitAddress: String?
}

final class JamoRiffAccessService {
    static let sharedRiffAccess = JamoRiffAccessService()

    private let riffIdentityArchive: JamoRiffIdentityArchive

    private init(riffIdentityArchive: JamoRiffIdentityArchive = .sharedArchive) {
        self.riffIdentityArchive = riffIdentityArchive
    }

    func enterRiffStage(riffMail: String, stringTensionPhrase: String, riffSessionReady: @escaping (Result<JamoAuthSession, Error>) -> Void) {
        let cleanRiffMail = normalizedRiffMail(riffMail)
        JamoRiffRelay.sendRiffRequest(
            endpoint: JamoAuthEndpoint.emailLogin,
            riffPacket: makeMailAccessRiffPacket(riffMail: cleanRiffMail, stringTensionPhrase: stringTensionPhrase)
        ) { [weak self] relaySignal in
            self?.resolveMailAccessSignal(relaySignal, fallbackRiffMail: cleanRiffMail, fallbackStageName: self?.riffIdentityArchive.displayNameFallback(for: cleanRiffMail) ?? JamoRiffStringCipher.restore("JCawmIoL 3PZlja8yyeYre"), riffSessionReady: riffSessionReady)
        } onBrokenString: { brokenString in
            riffSessionReady(.failure(JamoRiffAccessError.relayBreak(note: JamoRiffAccessService.relayBreakNotice(for: brokenString))))
        }
    }

    func joinRiffStage(riffMail: String, stageName: String, stringTensionPhrase: String, riffSessionReady: @escaping (Result<JamoAuthSession, Error>) -> Void) {
        let cleanRiffMail = normalizedRiffMail(riffMail)
        JamoRiffRelay.sendRiffRequest(
            endpoint: JamoAuthEndpoint.emailLogin,
            riffPacket: makeMailAccessRiffPacket(riffMail: cleanRiffMail, stringTensionPhrase: stringTensionPhrase)
        ) { [weak self] relaySignal in
            self?.resolveMailAccessSignal(relaySignal, fallbackRiffMail: cleanRiffMail, fallbackStageName: stageName, riffSessionReady: riffSessionReady)
        } onBrokenString: { brokenString in
            riffSessionReady(.failure(JamoRiffAccessError.relayBreak(note: JamoRiffAccessService.relayBreakNotice(for: brokenString))))
        }
    }

    func enterAppleRiffStage(identityPhrase: String, equipmentNo: String, riffSessionReady: @escaping (Result<JamoAuthSession, Error>) -> Void) {
        let riffPacket: [String: Any] = [
            JamoRiffStringCipher.restore("g4ubiVtPaQrlcaaCbAlLet"): JamoRiffRelay.guitarStageBundle,
            JamoRiffStringCipher.restore("dpiE_gbOoExd"): identityPhrase,
            JamoRiffStringCipher.restore("r8elaZmVpLbsoGxJ"): equipmentNo
        ]
        JamoRiffRelay.sendRiffRequest(
            endpoint: JamoAuthEndpoint.appleLogin,
            riffPacket: riffPacket
        ) { [weak self] relaySignal in
            self?.resolveMailAccessSignal(relaySignal, fallbackRiffMail: "", fallbackStageName: JamoRiffStringCipher.restore("J2asmNoM vPslEaCygecrI"), riffSessionReady: riffSessionReady)
        } onBrokenString: { brokenString in
            riffSessionReady(.failure(JamoRiffAccessError.relayBreak(note: JamoRiffAccessService.relayBreakNotice(for: brokenString))))
        }
    }

    private func normalizedRiffMail(_ riffMail: String) -> String {
        riffMail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func makeMailAccessRiffPacket(riffMail: String, stringTensionPhrase: String) -> [String: Any] {
        [
            JamoRiffStringCipher.restore("pwiJtLc6hupEeSrEfZewcSt5"): stringTensionPhrase,
            JamoRiffStringCipher.restore("egaqrct8r2aUimnMilnsga"): riffMail,
            JamoRiffStringCipher.restore("tgeSmOphoYturYaEcnkc"): JamoRiffRelay.guitarStageBundle
        ]
    }

    private func resolveMailAccessSignal(_ relaySignal: Any?, fallbackRiffMail: String, fallbackStageName: String, riffSessionReady: @escaping (Result<JamoAuthSession, Error>) -> Void) {
        guard let rootSignal = relaySignal as? [String: Any] else {
            riffSessionReady(.failure(JamoRiffAccessError.detunedBackend(note: JamoRiffStringCipher.restore("LXoegqiHnH 0fyazi6lGecdG.w nPHljeGaksCeS 9tXrkyI FaXgFagiInu.E"))))
            return
        }

        if let riffNotice = detunedBackendNotice(from: rootSignal) {
            riffSessionReady(.failure(JamoRiffAccessError.detunedBackend(note: riffNotice)))
            return
        }

        let riffData = (rootSignal[JamoRiffStringCipher.restore("dSa4thaC")] as? [String: Any]) ?? rootSignal
        guard let jamSessionPhrase = firstRiffText(
            in: riffData,
            keys: [
                JamoRiffStringCipher.restore("pnoniHn8t3SJyYsIt5ejmALooqrvasufah"),
                JamoRiffStringCipher.restore("nSoItHaAtsisoanT"),
                JamoRiffStringCipher.restore("tRo9kDeun0")
            ]
        ), !jamSessionPhrase.isEmpty else {
            riffSessionReady(.failure(JamoRiffAccessError.detunedBackend(note: backendRiffNotice(from: rootSignal) ?? JamoRiffStringCipher.restore("Lwo4gki9nq Nf2aYi1lLeTdN.g VPKl4eyapsieb Ft0rUyV 1aggca5iLn7.G"))))
            return
        }

        let playerHandle = firstRiffText(
            in: riffData,
            keys: [
                JamoRiffStringCipher.restore("rge8smpkoSnyskiKvueqDHeisHiRgPnZL5oerTaiu4a4"),
                JamoRiffStringCipher.restore("cblGoXsleVdhbiatcMkH"),
                JamoRiffStringCipher.restore("r6hEywtVhUmTlIaLyne4rX"),
                JamoRiffStringCipher.restore("uasveTrgIBdK")
            ]
        ) ?? fallbackRiffMail
        let resolvedRiffMail = firstRiffText(
            in: riffData,
            keys: [
                JamoRiffStringCipher.restore("l7eOa8dnezrabXozakrWdyRzapnhkDiWnygFLboBr3afuWal"),
                JamoRiffStringCipher.restore("auu0d4iSoJpwlBuygRiFnu"),
                JamoRiffStringCipher.restore("cHh3aji4nVsHtxy2l7eo"),
                JamoRiffStringCipher.restore("uVs7eRroEEmuagiYlc")
            ]
        ) ?? fallbackRiffMail
        let stageName = firstRiffText(
            in: riffData,
            keys: [
                JamoRiffStringCipher.restore("hyo4mIelsztOu1dqiaoZ"),
                JamoRiffStringCipher.restore("mXujsfiMcfpmr1okmNpfte"),
                JamoRiffStringCipher.restore("u7syevrPNyaJmTeT")
            ]
        ) ?? fallbackStageName
        let tonePortraitAddress = firstRiffText(
            in: riffData,
            keys: [
                JamoRiffStringCipher.restore("dFaywUsQeospsnimoZne"),
                JamoRiffStringCipher.restore("g1ugistSaBrQiDdWeVah"),
                JamoRiffStringCipher.restore("uqseePr4I4mTgfUtrXl0")
            ]
        )
        let riffSession = JamoAuthSession(riffHandle: playerHandle, jamSessionPhrase: jamSessionPhrase, riffMail: resolvedRiffMail, stageName: stageName, tonePortraitAddress: tonePortraitAddress)
        riffIdentityArchive.saveSession(riffSession)
        JamoRiffRelay.jamSessionPhrase = jamSessionPhrase
        riffSessionReady(.success(riffSession))
    }

    private func detunedBackendNotice(from rootSignal: [String: Any]) -> String? {
        guard let riffCode = rootSignal[JamoRiffStringCipher.restore("c8o3dJe6")] ?? rootSignal[JamoRiffStringCipher.restore("sVtbapteuvsm")] else { return nil }
        let tunedCodes = [
            JamoRiffStringCipher.restore("02"),
            JamoRiffStringCipher.restore("1c"),
            JamoRiffStringCipher.restore("2t0s0i"),
            JamoRiffStringCipher.restore("2m0d0r080w0G"),
            JamoRiffStringCipher.restore("squHcxcseesMsH"),
            JamoRiffStringCipher.restore("tBrCuHek")
        ]
        if tunedCodes.contains(String(describing: riffCode).lowercased()) {
            return nil
        }
        return backendRiffNotice(from: rootSignal) ?? JamoRiffStringCipher.restore("LKoXg0itnZ QfjaZiSlSeidq.o GPUl5enaxsaei ktVrjyM YaVgfa0iRn9.4")
    }

    private func backendRiffNotice(from rootSignal: [String: Any]) -> String? {
        firstRiffText(in: rootSignal, keys: [JamoRiffStringCipher.restore("m5sPgq"), JamoRiffStringCipher.restore("m5eLsF") + JamoRiffStringCipher.restore("sHavgdep"), JamoRiffStringCipher.restore("evrLrvolr7MlsPg8"), JamoRiffStringCipher.restore("eQror7oNri")])
    }

    private func firstRiffText(in riffSource: [String: Any], keys: [String]) -> String? {
        for riffKey in keys {
            if let riffValue = riffSource[riffKey] as? String, !riffValue.isEmpty {
                return riffValue
            }
            if let riffValue = riffSource[riffKey] as? Int {
                return String(riffValue)
            }
            if let riffValue = riffSource[riffKey] as? NSNumber {
                return riffValue.stringValue
            }
        }
        return nil
    }

    private static func relayBreakNotice(for detunedSignal: Error) -> String {
        let riffRelayBreak = detunedSignal as NSError
        switch riffRelayBreak.code {
        case NSURLErrorNotConnectedToInternet:
            return JamoRiffStringCipher.restore("Ncow GiLnGtee1rfnTe8tE hc9oun5nGe6cjtHiqo7nk.c zP5l6eOapsken UcLh8eBcnk7 ZyhoQu3rh inMectYwzo9rbkO.S")
        case NSURLErrorTimedOut:
            return JamoRiffStringCipher.restore("T7hyeV QroeYqAuReJsStD ftWifmpemdY HoyuKtH.r 5PZlbe5awsIe7 ptRrYyO 8aRgiaGimns.i")
        case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost, NSURLErrorNetworkConnectionLost:
            return JamoRiffStringCipher.restore("N1egtDwAo4r1kE NiksY iurnCaLv5aliEloaObQlFeJ.F 5P4lfeqaKsteI wtKrUyf Za8gmaKiqnC Clgaxt8ecrS.g")
        default:
            return detunedSignal.localizedDescription.isEmpty ? JamoRiffStringCipher.restore("NdeQtxwVoUrLkf weGrqrhogrW.b YPIlBekaAsXe5 StYrGyE Ha3gkayitnN.U") : detunedSignal.localizedDescription
        }
    }
}

enum JamoAuthEndpoint {
    static let emailLogin = JamoRiffStringCipher.restore("/5a7gxsdijpXcVdazM/DwUjRk4jxg8kFvyvb")
    static let appleLogin = JamoRiffStringCipher.restore("/5a7gxsdijpXcVdazM/DwUjRk4jxg8kFvyvb")
}

enum JamoRiffAccessError: LocalizedError {
    case detunedBackend(note: String)
    case relayBreak(note: String)

    var errorDescription: String? {
        switch self {
        case .detunedBackend(let riffNotice), .relayBreak(let riffNotice):
            return riffNotice
        }
    }
}

enum JamoRiffStageRouter {
    static func installOpeningRiffStage(in stageWindow: UIWindow) {
        if JamoRiffIdentityArchive.sharedArchive.hasValidSession {
            installMainRiffStage(in: stageWindow, usesCrossfade: false)
        } else {
            openWelcomeRiffStage(in: stageWindow, usesCrossfade: false)
        }
    }

    static func openMainRiffStage(from stageController: UIViewController) {
        guard let stageWindow = stageController.view.window else { return }
        installMainRiffStage(in: stageWindow, usesCrossfade: true)
    }

    static func openWelcomeRiffStage(in stageWindow: UIWindow, usesCrossfade: Bool) {
        let welcomeStage = JamoRiffWelcomeStageViewController()
        let riffNavigation = UINavigationController(rootViewController: welcomeStage)
        riffNavigation.navigationBar.isHidden = true
        switchRiffRoot(riffNavigation, in: stageWindow, usesCrossfade: usesCrossfade)
    }

    static func installMainRiffStage(in stageWindow: UIWindow, usesCrossfade: Bool) {
        switchRiffRoot(JamoMainTabBarController(), in: stageWindow, usesCrossfade: usesCrossfade)
    }

    private static func switchRiffRoot(_ rootStage: UIViewController, in stageWindow: UIWindow, usesCrossfade: Bool) {
        let riffStageSwitch = {
            stageWindow.rootViewController = rootStage
            stageWindow.makeKeyAndVisible()
        }
        guard usesCrossfade else {
            riffStageSwitch()
            return
        }
        UIView.transition(with: stageWindow, duration: 0.28, options: [.transitionCrossDissolve, .allowAnimatedContent], animations: riffStageSwitch)
    }
}

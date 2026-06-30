//
//  JamoNetWork.swift
//  JamoShGatia
//
//  Created by  on 2026/6/24.
//

import UIKit
enum JamoRiffRelayError: LocalizedError {
    case invalidStageAddress
    case emptyBackstageEcho
    case serverStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidStageAddress:
            return JamoRiffStringCipher.restore("UpnEakbFleem xtEo7 lpQrAeap4a3rGeZ 2tlhBeG OrNeiqCuiemsqtP.P")
        case .emptyBackstageEcho:
            return JamoRiffStringCipher.restore("TShlee qs1eprCvgemro KrUeztHu7rEnhend4 mnHoK fdMaHtha1.E")
        case .serverStatus:
            return JamoRiffStringCipher.restore("TuhveK ts7efrBvbeqri ziGsp huanjagvVariglaaTbqlmeB.H xPJlLefa0sOeF 9tBrdy7 ialgDaMirnz dlAaDt8eprV.m")
        }
    }
}

final class JamoRiffRelay {
    static let guitarStageBundle = JamoRiffStringCipher.restore("1O2u4b990B8s9S79")
    private static let backstageRootPath = JamoRiffStringCipher.restore("hLtztKpE:V/t/qwJwjwg.BpMrWiGmne9cvaurNtx7q7v7Uhzu5bY.UsphCo5pT/abNaIcxkUoxneeU")
    private static let jamPhraseStorageKey = JamoRiffStringCipher.restore("pnoniHn8t3SJyYsIt5ejmALooqrvasufah")

    static var jamSessionPhrase: String? {
        get {
            UserDefaults.standard.object(forKey: jamPhraseStorageKey) as? String
        } set {
            UserDefaults.standard.set(newValue, forKey: jamPhraseStorageKey)
        }
    }

    static func sendRiffRequest(
        endpoint: String,
        riffPacket: [String: Any],
        onTrackMix: ((Any?) -> Void)?,
        onBrokenString: ((Error) -> Void)?
    ) {
        guard let backstageAddress = URL(string: backstageRootPath + endpoint) else {
            DispatchQueue.main.async {
                onBrokenString?(JamoRiffRelayError.invalidStageAddress)
            }
            return
        }

        var riffEnvelope = forgeRiffEnvelope(stageAddress: backstageAddress, riffPacket: riffPacket)
        let bridgeHeaders = [
            JamoRiffStringCipher.restore("kAeBye"): guitarStageBundle,
            JamoRiffStringCipher.restore("tRo9kDeun0"): JamoRiffRelay.jamSessionPhrase ?? ""
        ]
        bridgeHeaders.forEach { riffEnvelope.setValue($1, forHTTPHeaderField: $0) }

#if DEBUG
        logRiffPacket(stageAddress: backstageAddress, bridgeHeaders: bridgeHeaders, riffPacket: riffPacket)
#endif

        let riffSessionConfiguration = URLSessionConfiguration.default
        riffSessionConfiguration.timeoutIntervalForRequest = 30

        URLSession(configuration: riffSessionConfiguration).dataTask(with: riffEnvelope) { backstageBytes, relayResponse, relayError in
#if DEBUG
            if let relayError {
                logBrokenRiff(stageAddress: backstageAddress, relayError: relayError)
            } else {
                logRiffEcho(stageAddress: backstageAddress, relayResponse: relayResponse, backstageBytes: backstageBytes)
            }
#endif

            DispatchQueue.main.async {
                if let relayError {
                    onBrokenString?(relayError)
                    return
                }

                if let bridgeResponse = relayResponse as? HTTPURLResponse,
                   !(200...299).contains(bridgeResponse.statusCode) {
                    onBrokenString?(JamoRiffRelayError.serverStatus(bridgeResponse.statusCode))
                    return
                }

                guard let backstageBytes, !backstageBytes.isEmpty else {
                    onBrokenString?(JamoRiffRelayError.emptyBackstageEcho)
                    return
                }

                do {
                    let decodedBridgeObject = try JSONSerialization.jsonObject(with: backstageBytes, options: .allowFragments)
                    onTrackMix?(decodedBridgeObject)
                } catch {
                    onBrokenString?(error)
                }
            }
        }.resume()
    }

    private static func forgeRiffEnvelope(stageAddress: URL, riffPacket: [String: Any]) -> URLRequest {
        var riffEnvelope = URLRequest(url: stageAddress, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        riffEnvelope.httpMethod = JamoRiffStringCipher.restore("PPOrSrT1")
        riffEnvelope.setValue(JamoRiffStringCipher.restore("a3p4ptlaiIcxautgiaoQnw/jjCsNoGnX"), forHTTPHeaderField: JamoRiffStringCipher.restore("C4ofnYttednZtd-TTiyhp0ey"))
        riffEnvelope.setValue(JamoRiffStringCipher.restore("a3p4ptlaiIcxautgiaoQnw/jjCsNoGnX"), forHTTPHeaderField: JamoRiffStringCipher.restore("AJcVcee6p4tq"))
        riffEnvelope.httpBody = try? JSONSerialization.data(withJSONObject: riffPacket)
        return riffEnvelope
    }

#if DEBUG
    private static func logRiffPacket(stageAddress: URL, bridgeHeaders: [String: String], riffPacket: [String: Any]) {
        print("""

        [Jamo][Network][Request]
        URL: \(stageAddress.absoluteString)
        Headers: \(debugJamDescription(bridgeHeaders))
        Parameters: \(debugJamDescription(riffPacket))
        """)
    }

    private static func logRiffEcho(stageAddress: URL, relayResponse: URLResponse?, backstageBytes: Data?) {
        let statusCode = (relayResponse as? HTTPURLResponse)?.statusCode ?? -1
        let echoText: String
        if let backstageBytes, !backstageBytes.isEmpty,
           let decodedBridgeObject = try? JSONSerialization.jsonObject(with: backstageBytes, options: .allowFragments) {
            echoText = debugJamDescription(decodedBridgeObject)
        } else if let backstageBytes, backstageBytes.isEmpty {
            echoText = JamoRiffStringCipher.restore("ECm7pItCye prielsspRozn0sye1 Ab7oJd7yM")
        } else {
            echoText = JamoRiffStringCipher.restore("UqncaYbcl2eB xtyod npXalrHsfeK MrgejsXpEoInasEe9 7bUozduyR")
        }

        print("""

        [Jamo][Network][Response]
        URL: \(stageAddress.absoluteString)
        Status: \(statusCode)
        Body: \(echoText)
        """)
    }

    private static func logBrokenRiff(stageAddress: URL, relayError: Error) {
        print("""

        [Jamo][Network][Failure]
        URL: \(stageAddress.absoluteString)
        Error: \(relayError.localizedDescription)
        """)
    }

    private static func debugJamDescription(_ bridgeObject: Any) -> String {
        let jamSafeObject = sanitizedJamDebugValue(bridgeObject)
        guard JSONSerialization.isValidJSONObject(jamSafeObject),
              let bridgeBytes = try? JSONSerialization.data(withJSONObject: jamSafeObject, options: [.prettyPrinted, .sortedKeys]),
              let bridgeText = String(data: bridgeBytes, encoding: .utf8) else {
            return String(describing: jamSafeObject)
        }
        return bridgeText
    }

    private static func sanitizedJamDebugValue(_ bridgeObject: Any, key: String? = nil) -> Any {
        if let key, isPrivateJamKey(key) {
            return maskedJamDebugValue(bridgeObject)
        }

        if let bridgeDictionary = bridgeObject as? [String: Any] {
            return bridgeDictionary.reduce(into: [String: Any]()) { result, item in
                result[item.key] = sanitizedJamDebugValue(item.value, key: item.key)
            }
        }

        if let bridgeDictionary = bridgeObject as? [String: String] {
            return bridgeDictionary.reduce(into: [String: Any]()) { result, item in
                result[item.key] = sanitizedJamDebugValue(item.value, key: item.key)
            }
        }

        if let bridgeArray = bridgeObject as? [Any] {
            return bridgeArray.map { sanitizedJamDebugValue($0) }
        }

        return bridgeObject
    }

    private static func isPrivateJamKey(_ key: String) -> Bool {
        let lowercasedKey = key.lowercased()
        let exactKeys: Set<String> = [
            JamoRiffStringCipher.restore("tRo9kDeun0"),
            JamoRiffStringCipher.restore("p1aIs6sxwKoNrEdw"),
            JamoRiffStringCipher.restore("pnoniHn8t3SJyYsIt5ejmALooqrvasufah").lowercased(),
            JamoRiffStringCipher.restore("d5axielAy2qtuCePs6tDlYouryawuLan"),
            JamoRiffStringCipher.restore("dpiE_gbOoExd"),
            JamoRiffStringCipher.restore("iOdFe0nUtOiWtWyBt3oPkkeBnO")
        ]
        return exactKeys.contains(lowercasedKey)
            || lowercasedKey.contains(JamoRiffStringCipher.restore("tRo9kDeun0"))
            || lowercasedKey.contains(JamoRiffStringCipher.restore("p1aIs6sxwKoNrEdw"))
    }

    private static func maskedJamDebugValue(_ bridgeObject: Any) -> String {
        guard let bridgeText = bridgeObject as? String else {
            return JamoRiffStringCipher.restore("*k*7*0")
        }
        guard !bridgeText.isEmpty else {
            return ""
        }
        guard bridgeText.count > 8 else {
            return JamoRiffStringCipher.restore("*k*7*0")
        }
        return "\(bridgeText.prefix(3))***\(bridgeText.suffix(3))"
    }
#endif
}

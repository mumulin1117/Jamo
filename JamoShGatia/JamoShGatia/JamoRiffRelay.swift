






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

        let riffSessionConfiguration = URLSessionConfiguration.default
        riffSessionConfiguration.timeoutIntervalForRequest = 30

        URLSession(configuration: riffSessionConfiguration).dataTask(with: riffEnvelope) { backstageBytes, relayResponse, relayError in
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

}

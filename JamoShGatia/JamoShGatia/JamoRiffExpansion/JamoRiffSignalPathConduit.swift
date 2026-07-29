import UIKit

final class JamoRiffSignalPathConduit: NSObject {
    private enum JamoRiffSignalFault {
        static let JamoRiffSignalURL = NSError(domain: "URL Error", code: 400)
        static let JamoRiffSignalEmpty = NSError(domain: "No Data", code: 1000)
        static let JamoRiffSignalBack = NSError(domain: "Data Back Error", code: 1002)
        static let JamoRiffSignalUnwoven = NSError(domain: "Decryption Error", code: 1003)
    }

    private enum JamoRiffSignalHeader {
        static let JamoRiffSignalContentType = "Content-Type"
        static let JamoRiffSignalContentValue = "application/json"
        static let JamoRiffSignalApp = "appId"
        static let JamoRiffSignalVersion = "appVersion"
        static let JamoRiffSignalDevice = "deviceNo"
        static let JamoRiffSignalLanguage = "language"
        static let JamoRiffSignalLogin = "loginToken"
        static let JamoRiffSignalPush = "pushToken"
        static let JamoRiffSignalLoginKey = "userTokenKey"
        static let JamoRiffSignalPushKey = "pushTokenKey"
    }

    private enum JamoRiffSignalWrap {
        static let JamoRiffSignalCode = "code"
        static let JamoRiffSignalResult = "result"
        static let JamoRiffSignalOK = "0000"
    }

    private struct JamoRiffSignalPacket {
        let JamoRiffSignalPath: String
        let JamoRiffSignalBundle: [String: Any]
        let JamoRiffSignalDirect: Bool
    }

    static let shared = JamoRiffSignalPathConduit()

    internal override init() {
        super.init()
    }

    func JamoRiffSignalSend(
        _ JamoRiffSignalPath: String,
        JamoRiffSignalBundle: [String: Any],
        JamoRiffSignalDirect: Bool = false,
        JamoRiffSignalCompletion: @escaping (Result<[String: Any]?, Error>) -> Void = { _ in }
    ) {
        let JamoRiffSignalPacket = JamoRiffSignalPacket(
            JamoRiffSignalPath: JamoRiffSignalPath,
            JamoRiffSignalBundle: JamoRiffSignalBundle,
            JamoRiffSignalDirect: JamoRiffSignalDirect
        )
        guard let JamoRiffSignalRequest = JamoRiffSignalRequest(from: JamoRiffSignalPacket) else {
            JamoRiffSignalCompletion(.failure(JamoRiffSignalFault.JamoRiffSignalURL))
            return
        }
        URLSession.shared.dataTask(with: JamoRiffSignalRequest) { JamoRiffSignalData, _, JamoRiffSignalError in
            if let JamoRiffSignalError {
                self.JamoRiffSignalReturn(.failure(JamoRiffSignalError), to: JamoRiffSignalCompletion)
                return
            }
            guard let JamoRiffSignalData else {
                self.JamoRiffSignalReturn(.failure(JamoRiffSignalFault.JamoRiffSignalEmpty), to: JamoRiffSignalCompletion)
                return
            }
            self.JamoRiffSignalResolve(
                JamoRiffSignalData,
                direct: JamoRiffSignalPacket.JamoRiffSignalDirect,
                completion: JamoRiffSignalCompletion
            )
        }.resume()
    }

    private func JamoRiffSignalRequest(from JamoRiffSignalPacket: JamoRiffSignalPacket) -> URLRequest? {
        guard let JamoRiffSignalURL = URL(string: JamoTrackSequenceHolder.shared.JamoTrackSequenceSignalStem + JamoRiffSignalPacket.JamoRiffSignalPath),
              let JamoRiffSignalBody = JamoRiffSignalBody(from: JamoRiffSignalPacket.JamoRiffSignalBundle) else {
            return nil
        }
        var JamoRiffSignalRequest = URLRequest(url: JamoRiffSignalURL)
        JamoRiffSignalRequest.httpMethod = "POST"
        JamoRiffSignalRequest.httpBody = JamoRiffSignalBody
        JamoRiffSignalRequest.timeoutInterval = 15
        JamoRiffSignalTuneHeaders(on: &JamoRiffSignalRequest)
        return JamoRiffSignalRequest
    }

    private func JamoRiffSignalBody(from JamoRiffSignalBundle: [String: Any]) -> Data? {
        guard let JamoRiffSignalJSON = Self.JamoRiffSignalJSONString(JamoRiffSignalFrom: JamoRiffSignalBundle),
              let JamoRiffSignalCipher = JamoAuStitchDefinition()?.JamoRiffStitchPhraseWeave(JamoRiffSignalJSON) else {
            return nil
        }
        return JamoRiffSignalCipher.data(using: .utf8)
    }

    private func JamoRiffSignalTuneHeaders(on JamoRiffSignalRequest: inout URLRequest) {
        [
            (JamoRiffSignalHeader.JamoRiffSignalContentType, JamoRiffSignalHeader.JamoRiffSignalContentValue),
            (JamoRiffSignalHeader.JamoRiffSignalApp, JamoTrackSequenceHolder.shared.JamoTrackSequenceAppPhrase),
            (JamoRiffSignalHeader.JamoRiffSignalVersion, Bundle.main.JamoRiffSignalVersionPhrase),
            (JamoRiffSignalHeader.JamoRiffSignalDevice, JamoRhythmPhraseVault.JamoRhythmPhraseSignal()),
            (JamoRiffSignalHeader.JamoRiffSignalLanguage, Locale.current.languageCode ?? ""),
            (JamoRiffSignalHeader.JamoRiffSignalLogin, UserDefaults.standard.string(forKey: JamoRiffSignalHeader.JamoRiffSignalLoginKey) ?? ""),
            (JamoRiffSignalHeader.JamoRiffSignalPush, UserDefaults.standard.string(forKey: JamoRiffSignalHeader.JamoRiffSignalPushKey) ?? "")
        ].forEach { JamoRiffSignalHeaderField, JamoRiffSignalHeaderValue in
            JamoRiffSignalRequest.setValue(JamoRiffSignalHeaderValue, forHTTPHeaderField: JamoRiffSignalHeaderField)
        }
    }

    private func JamoRiffSignalResolve(
        _ JamoRiffSignalData: Data,
        direct JamoRiffSignalDirect: Bool,
        completion JamoRiffSignalCompletion: @escaping (Result<[String: Any]?, Error>) -> Void
    ) {
        do {
            let JamoRiffSignalWrap = try JamoRiffSignalReadWrap(from: JamoRiffSignalData)
            if JamoRiffSignalDirect {
                JamoRiffSignalReturn(.success([:]), to: JamoRiffSignalCompletion)
                return
            }
            JamoRiffSignalReturn(.success(try JamoRiffSignalDecodedBundle(from: JamoRiffSignalWrap)), to: JamoRiffSignalCompletion)
        } catch {
            JamoRiffSignalReturn(.failure(error), to: JamoRiffSignalCompletion)
        }
    }

    private func JamoRiffSignalReadWrap(from JamoRiffSignalData: Data) throws -> [String: Any] {
        guard let JamoRiffSignalBundle = try JSONSerialization.jsonObject(with: JamoRiffSignalData) as? [String: Any],
              let JamoRiffSignalCode = JamoRiffSignalBundle[JamoRiffSignalWrap.JamoRiffSignalCode] as? String,
              JamoRiffSignalCode == JamoRiffSignalWrap.JamoRiffSignalOK else {
            throw JamoRiffSignalFault.JamoRiffSignalBack
        }
        return JamoRiffSignalBundle
    }

    private func JamoRiffSignalDecodedBundle(from JamoRiffSignalWrappedBundle: [String: Any]) throws -> [String: Any] {
        guard let JamoRiffSignalCipher = JamoRiffSignalWrappedBundle[JamoRiffSignalWrap.JamoRiffSignalResult] as? String,
              let JamoRiffSignalText = JamoAuStitchDefinition()?.JamoRiffStitchPhraseRelease(JamoRiffStitchHexLine: JamoRiffSignalCipher),
              let JamoRiffSignalData = JamoRiffSignalText.data(using: .utf8),
              let JamoRiffSignalBundle = try JSONSerialization.jsonObject(with: JamoRiffSignalData) as? [String: Any] else {
            throw JamoRiffSignalFault.JamoRiffSignalUnwoven
        }
        return JamoRiffSignalBundle
    }

    private func JamoRiffSignalReturn(
        _ JamoRiffSignalResult: Result<[String: Any]?, Error>,
        to JamoRiffSignalCompletion: @escaping (Result<[String: Any]?, Error>) -> Void
    ) {
        DispatchQueue.main.async {
            JamoRiffSignalCompletion(JamoRiffSignalResult)
        }
    }

    class func JamoRiffSignalJSONString(JamoRiffSignalFrom JamoRiffSignalBundle: [String: Any]) -> String? {
        guard let JamoRiffSignalData = try? JSONSerialization.data(withJSONObject: JamoRiffSignalBundle) else { return nil }
        return String(data: JamoRiffSignalData, encoding: .utf8)
    }
}

private extension Bundle {
    var JamoRiffSignalVersionPhrase: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
}

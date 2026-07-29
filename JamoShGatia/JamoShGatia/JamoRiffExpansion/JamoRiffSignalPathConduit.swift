import UIKit

final class JamoRiffSignalPathConduit: NSObject {
    private enum JamoRiffSignalFault {
        static let JamoRiffSignalURL = NSError(domain: JamoRiffStringCipher.restore("UxRxLx xExrxrxoxrx"), code: 400)
        static let JamoRiffSignalEmpty = NSError(domain: JamoRiffStringCipher.restore("Nxox xDxaxtxax"), code: 1000)
        static let JamoRiffSignalBack = NSError(domain: JamoRiffStringCipher.restore("Dxaxtxax xBxaxcxkx xExrxrxoxrx"), code: 1002)
        static let JamoRiffSignalUnwoven = NSError(domain: JamoRiffStringCipher.restore("Dxexcxrxyxpxtxixoxnx xExrxrxoxrx"), code: 1003)
    }

    private enum JamoRiffSignalHeader {
        static let JamoRiffSignalContentType = JamoRiffStringCipher.restore("Cxoxnxtxexnxtx-xTxyxpxex")
        static let JamoRiffSignalContentValue = JamoRiffStringCipher.restore("axpxpxlxixcxaxtxixoxnx/xjxsxoxnx")
        static let JamoRiffSignalApp = JamoRiffStringCipher.restore("axpxpxIxdx")
        static let JamoRiffSignalVersion = JamoRiffStringCipher.restore("axpxpxVxexrxsxixoxnx")
        static let JamoRiffSignalDevice = JamoRiffStringCipher.restore("dxexvxixcxexNxox")
        static let JamoRiffSignalLanguage = JamoRiffStringCipher.restore("lxaxnxgxuxaxgxex")
        static let JamoRiffSignalLogin = JamoRiffStringCipher.restore("lxoxgxixnxTxoxkxexnx")
        static let JamoRiffSignalPush = JamoRiffStringCipher.restore("pxuxsxhxTxoxkxexnx")
        static let JamoRiffSignalLoginKey = JamoRiffStringCipher.restore("uxsxexrxTxoxkxexnxKxexyx")
        static let JamoRiffSignalPushKey = JamoRiffStringCipher.restore("pxuxsxhxTxoxkxexnxKxexyx")
    }

    private enum JamoRiffSignalWrap {
        static let JamoRiffSignalCode = JamoRiffStringCipher.restore("cxoxdxex")
        static let JamoRiffSignalResult = JamoRiffStringCipher.restore("rxexsxuxlxtx")
        static let JamoRiffSignalOK = JamoRiffStringCipher.restore("0x0x0x0x")
    }

    private struct JamoRiffSignalPacket {
        let JamoRiffSignalPath: String
        let JamoRiffSignalBundle: [String: Any]
        let JamoRiffSignalDirect: Bool
    }

    private enum JamoRiffSignalTrace {
        static let JamoRiffSignalRequest = JamoRiffStringCipher.restore("[xJxaxmxox]x[xoxpxix/xvx1x]x[xRxexqxuxexsxtx]x\nxUxRxLx:x x")
        static let JamoRiffSignalHeaders = JamoRiffStringCipher.restore("\nxHxexaxdxexrxsx:x x")
        static let JamoRiffSignalParameters = JamoRiffStringCipher.restore("\nxPxaxrxaxmxextxexrxsx:x x")
        static let JamoRiffSignalResponse = JamoRiffStringCipher.restore("[xJxaxmxox]x[xoxpxix/xvx1x]x[xRxexsxpxoxnxsxex]x\nxUxRxLx:x x")
        static let JamoRiffSignalStatus = JamoRiffStringCipher.restore("\nxSxtxaxtxuxsx:x x")
        static let JamoRiffSignalBody = JamoRiffStringCipher.restore("\nxBxoxdxyx:x x")
        static let JamoRiffSignalDecoded = JamoRiffStringCipher.restore("\nxDxexcxoxdxexdx:x x")
        static let JamoRiffSignalError = JamoRiffStringCipher.restore("[xJxaxmxox]x[xoxpxix/xvx1x]x[xExrxrxoxrx]x\nxUxRxLx:x x")
        static let JamoRiffSignalErrorBody = JamoRiffStringCipher.restore("\nxExrxrxoxrx:x x")
        static let JamoRiffSignalNull = JamoRiffStringCipher.restore("nxuxlxlx")
        static let JamoRiffSignalEmptyMap = JamoRiffStringCipher.restore("{x}x")
        static let JamoRiffSignalEmpty = JamoRiffStringCipher.restore("<xexmxpxtxyx>x")
        static let JamoRiffSignalInvalid = JamoRiffStringCipher.restore("<xixnxvxaxlxixdx>x")
        static let JamoRiffSignalUnavailable = JamoRiffStringCipher.restore("<xuxnxaxvxaxixlxaxbxlxex>x")
        static let JamoRiffSignalDecodeFailed = JamoRiffStringCipher.restore("<xdxexcxoxdxex xfxaxixlxexdx>x")
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
        JamoRiffSignalTraceRequest(JamoRiffSignalPacket, request: JamoRiffSignalRequest)
        URLSession.shared.dataTask(with: JamoRiffSignalRequest) { JamoRiffSignalData, JamoRiffSignalResponse, JamoRiffSignalError in
            if let JamoRiffSignalError {
                self.JamoRiffSignalTraceError(JamoRiffSignalError, request: JamoRiffSignalRequest)
                self.JamoRiffSignalReturn(.failure(JamoRiffSignalError), to: JamoRiffSignalCompletion)
                return
            }
            guard let JamoRiffSignalData else {
                self.JamoRiffSignalTraceResponse(nil, response: JamoRiffSignalResponse, request: JamoRiffSignalRequest)
                self.JamoRiffSignalReturn(.failure(JamoRiffSignalFault.JamoRiffSignalEmpty), to: JamoRiffSignalCompletion)
                return
            }
            self.JamoRiffSignalTraceResponse(JamoRiffSignalData, response: JamoRiffSignalResponse, request: JamoRiffSignalRequest)
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
        JamoRiffSignalRequest.httpMethod = JamoRiffStringCipher.restore("PxOxSxTx")
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
            (JamoRiffSignalHeader.JamoRiffSignalLanguage, Locale.current.languageCode ?? JamoRiffStringCipher.restore("")),
            (JamoRiffSignalHeader.JamoRiffSignalLogin, UserDefaults.standard.string(forKey: JamoRiffSignalHeader.JamoRiffSignalLoginKey) ?? JamoRiffStringCipher.restore("")),
            (JamoRiffSignalHeader.JamoRiffSignalPush, UserDefaults.standard.string(forKey: JamoRiffSignalHeader.JamoRiffSignalPushKey) ?? JamoRiffStringCipher.restore(""))
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

    private func JamoRiffSignalTraceRequest(_ JamoRiffSignalPacket: JamoRiffSignalPacket, request JamoRiffSignalRequest: URLRequest) {
        print(
            JamoRiffSignalTrace.JamoRiffSignalRequest
            + (JamoRiffSignalRequest.url?.absoluteString ?? JamoRiffSignalTrace.JamoRiffSignalUnavailable)
            + JamoRiffSignalTrace.JamoRiffSignalHeaders
            + JamoRiffSignalTracePhrase(from: JamoRiffSignalRequest.allHTTPHeaderFields ?? [:])
            + JamoRiffSignalTrace.JamoRiffSignalParameters
            + JamoRiffSignalTracePhrase(from: JamoRiffSignalPacket.JamoRiffSignalBundle)
        )
    }

    private func JamoRiffSignalTraceResponse(_ JamoRiffSignalData: Data?, response JamoRiffSignalResponse: URLResponse?, request JamoRiffSignalRequest: URLRequest) {
        let JamoRiffSignalStatus = (JamoRiffSignalResponse as? HTTPURLResponse)?.statusCode
        let JamoRiffSignalBody = JamoRiffSignalData.flatMap { String(data: $0, encoding: .utf8) } ?? JamoRiffSignalTrace.JamoRiffSignalEmpty
        let JamoRiffSignalDecoded = JamoRiffSignalData.flatMap { JamoRiffSignalTraceDecodedPhrase(from: $0) } ?? JamoRiffSignalTrace.JamoRiffSignalDecodeFailed
        print(
            JamoRiffSignalTrace.JamoRiffSignalResponse
            + (JamoRiffSignalRequest.url?.absoluteString ?? JamoRiffSignalTrace.JamoRiffSignalUnavailable)
            + JamoRiffSignalTrace.JamoRiffSignalStatus
            + (JamoRiffSignalStatus.map(String.init) ?? JamoRiffSignalTrace.JamoRiffSignalUnavailable)
            + JamoRiffSignalTrace.JamoRiffSignalBody
            + JamoRiffSignalBody
            + JamoRiffSignalTrace.JamoRiffSignalDecoded
            + JamoRiffSignalDecoded
        )
    }

    private func JamoRiffSignalTraceError(_ JamoRiffSignalError: Error, request JamoRiffSignalRequest: URLRequest) {
        print(
            JamoRiffSignalTrace.JamoRiffSignalError
            + (JamoRiffSignalRequest.url?.absoluteString ?? JamoRiffSignalTrace.JamoRiffSignalUnavailable)
            + JamoRiffSignalTrace.JamoRiffSignalErrorBody
            + JamoRiffSignalError.localizedDescription
        )
    }

    private func JamoRiffSignalTraceDecodedPhrase(from JamoRiffSignalData: Data) -> String {
        guard let JamoRiffSignalWrap = try? JamoRiffSignalReadWrap(from: JamoRiffSignalData),
              let JamoRiffSignalBundle = try? JamoRiffSignalDecodedBundle(from: JamoRiffSignalWrap) else {
            return JamoRiffSignalTrace.JamoRiffSignalDecodeFailed
        }
        return JamoRiffSignalTracePhrase(from: JamoRiffSignalBundle)
    }

    private func JamoRiffSignalTracePhrase(from JamoRiffSignalValue: Any) -> String {
        if let JamoRiffSignalData = try? JSONSerialization.data(withJSONObject: JamoRiffSignalValue, options: [.prettyPrinted]),
           let JamoRiffSignalText = String(data: JamoRiffSignalData, encoding: .utf8) {
            return JamoRiffSignalText
        }
        if let JamoRiffSignalText = JamoRiffSignalValue as? String {
            return JamoRiffSignalText
        }
        if JamoRiffSignalValue is NSNull {
            return JamoRiffSignalTrace.JamoRiffSignalNull
        }
        return JamoRiffSignalTrace.JamoRiffSignalInvalid
    }
}

private extension Bundle {
    var JamoRiffSignalVersionPhrase: String {
        object(forInfoDictionaryKey: JamoRiffStringCipher.restore("CxFxBxuxnxdxlxexSxhxoxrxtxVxexrxsxixoxnxSxtxrxixnxgx")) as? String ?? JamoRiffStringCipher.restore("")
    }
}

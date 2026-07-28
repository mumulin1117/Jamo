import UIKit
class JamoRiffChainContext: NSObject {
    static let shared = JamoRiffChainContext()
    internal override init() { super.init() }
    func JamoRiffChainContextSend(
        _ JamoRiffChainContextPath: String,
        JamoRiffChainContextBundle: [String: Any],
        JamoRiffChainContextDirectResolve: Bool = false,
        JamoRiffChainContextCompletion: @escaping (Result<[String: Any]?, Error>) -> Void = { _ in }
    ) {
        guard let JamoRiffChainContextRequest = JamoRiffChainContextBuildRequest(JamoRiffChainContextPath: JamoRiffChainContextPath, JamoRiffChainContextBundle: JamoRiffChainContextBundle) else {
            JamoRiffChainContextCompletion(.failure(NSError(domain: "URL Error", code: 400)))
            return
        }
        URLSession.shared.dataTask(with: JamoRiffChainContextRequest) { JamoRiffChainContextData, _, JamoRiffChainContextError in
            if let JamoRiffChainContextError {
                DispatchQueue.main.async { JamoRiffChainContextCompletion(.failure(JamoRiffChainContextError)) }
                return
            }
            guard let JamoRiffChainContextData else {
                DispatchQueue.main.async { JamoRiffChainContextCompletion(.failure(NSError(domain: "No Data", code: 1000))) }
                return
            }
            self.JamoRiffChainContextResolveResponse(
                JamoRiffChainContextDirectResolve: JamoRiffChainContextDirectResolve,
                JamoRiffChainContextSourceData: JamoRiffChainContextData,
                JamoRiffChainContextCompletion: JamoRiffChainContextCompletion
            )
        }.resume()
    }
    private func JamoRiffChainContextBuildRequest(JamoRiffChainContextPath: String, JamoRiffChainContextBundle: [String: Any]) -> URLRequest? {
        guard let JamoRiffChainContextURL = URL(string: JamoRiffTrackInstance.shared.JamoRiffTrackInstanceSignalPath + JamoRiffChainContextPath),
              let JamoRiffChainContextJSON = Self.JamoRiffChainContextJSONString(JamoRiffChainContextFrom: JamoRiffChainContextBundle),
              let JamoRiffChainContextCipher = JamoAuStitchDefinition()?.JamoAStitchDefinitionEncode(JamoRiffChainContextJSON),
              let JamoRiffChainContextBody = JamoRiffChainContextCipher.data(using: .utf8) else {
            return nil
        }
        var JamoRiffChainContextRequest = URLRequest(url: JamoRiffChainContextURL)
        JamoRiffChainContextRequest.httpMethod = "POST"
        JamoRiffChainContextRequest.httpBody = JamoRiffChainContextBody
        JamoRiffChainContextRequest.timeoutInterval = 15
        [
            "Content-Type": "application/json",
            "appId": JamoRiffTrackInstance.shared.JamoRiffTrackInstanceAppKey,
            "appVersion": Bundle.main.JamoRiffChainContextVersionPhrase,
            "deviceNo": JamoRhythmLayerAdapter.JamoRhythmLayerAdapterSignalPathInstance(),
            "language": Locale.current.languageCode ?? "",
            "loginToken": UserDefaults.standard.string(forKey: "userTokenKey") ?? "",
            "pushToken": UserDefaults.standard.string(forKey: "pushTokenKey") ?? ""
        ].forEach { JamoRiffChainContextRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        return JamoRiffChainContextRequest
    }
    private func JamoRiffChainContextResolveResponse(
        JamoRiffChainContextDirectResolve: Bool,
        JamoRiffChainContextSourceData: Data,
        JamoRiffChainContextCompletion: @escaping (Result<[String: Any]?, Error>) -> Void
    ) {
        do {
            guard let JamoRiffChainContextEnvelope = try JSONSerialization.jsonObject(with: JamoRiffChainContextSourceData) as? [String: Any],
                  let JamoRiffChainContextCode = JamoRiffChainContextEnvelope["code"] as? String,
                  JamoRiffChainContextCode == "0000" else {
                throw NSError(domain: "Data Back Error", code: 1002)
            }
            if JamoRiffChainContextDirectResolve {
                DispatchQueue.main.async { JamoRiffChainContextCompletion(.success([:])) }
                return
            }
            guard let JamoRiffChainContextCipher = JamoRiffChainContextEnvelope["result"] as? String,
                  let JamoRiffChainContextText = JamoAuStitchDefinition()?.JamoAStitchDefinitionDecode(JamoAStitchDefinitionHexPhrase: JamoRiffChainContextCipher),
                  let JamoRiffChainContextDecodedData = JamoRiffChainContextText.data(using: .utf8),
                  let JamoRiffChainContextDecodedBundle = try JSONSerialization.jsonObject(with: JamoRiffChainContextDecodedData) as? [String: Any] else {
                throw NSError(domain: "Decryption Error", code: 1003)
            }
            DispatchQueue.main.async { JamoRiffChainContextCompletion(.success(JamoRiffChainContextDecodedBundle)) }
        } catch {
            DispatchQueue.main.async { JamoRiffChainContextCompletion(.failure(error)) }
        }
    }
    class func JamoRiffChainContextJSONString(JamoRiffChainContextFrom JamoRiffChainContextBundle: [String: Any]) -> String? {
        guard let JamoRiffChainContextData = try? JSONSerialization.data(withJSONObject: JamoRiffChainContextBundle) else { return nil }
        return String(data: JamoRiffChainContextData, encoding: .utf8)
    }
}
private extension Bundle {
    var JamoRiffChainContextVersionPhrase: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
}

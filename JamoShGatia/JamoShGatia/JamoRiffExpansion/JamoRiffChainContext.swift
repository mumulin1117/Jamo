import UIKit
class JamoRiffChainContext: NSObject {
    static let shared = JamoRiffChainContext()
    internal override init() { super.init() }
    func APPPREFIX_postRequest(
        _ path: String,
        APPPREFIX_params: [String: Any],
        APPPREFIX_isPaymentFlow: Bool = false,
        APPPREFIX_completion: @escaping (Result<[String: Any]?, Error>) -> Void = { _ in }
    ) {
        guard let request = APPPREFIX_makeRequest(path: path, params: APPPREFIX_params) else {
            APPPREFIX_completion(.failure(NSError(domain: "URL Error", code: 400)))
            return
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error {
                DispatchQueue.main.async { APPPREFIX_completion(.failure(error)) }
                return
            }
            guard let data else {
                DispatchQueue.main.async { APPPREFIX_completion(.failure(NSError(domain: "No Data", code: 1000))) }
                return
            }
            self.APPPREFIX_handleResponse(APPPREFIX_isPaymentFlow: APPPREFIX_isPaymentFlow, APPPREFIX_rawData: data, APPPREFIX_completion: APPPREFIX_completion)
        }.resume()
    }
    private func APPPREFIX_makeRequest(path: String, params: [String: Any]) -> URLRequest? {
        guard let url = URL(string: JamoRiffTrackInstance.shared.APPPREFIX_baseURL + path),
              let json = Self.APPPREFIX_jsonString(APPPREFIX_from: params),
              let encrypted = JamoAudioStitchDefinition()?.APPPREFIX_encrypt(json),
              let body = encrypted.data(using: .utf8) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.timeoutInterval = 15
        [
            "Content-Type": "application/json",
            "appId": JamoRiffTrackInstance.shared.APPPREFIX_appId,
            "appVersion": Bundle.main.APPPREFIX_appVersion,
            "deviceNo": JamoRhythmLayerAdapter.APPPREFIX_getEquipmentOnlyID(),
            "language": Locale.current.languageCode ?? "",
            "loginToken": UserDefaults.standard.string(forKey: "userTokenKey") ?? "",
            "pushToken": UserDefaults.standard.string(forKey: "pushTokenKey") ?? ""
        ].forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        return request
    }
    private func APPPREFIX_handleResponse(
        APPPREFIX_isPaymentFlow: Bool,
        APPPREFIX_rawData: Data,
        APPPREFIX_completion: @escaping (Result<[String: Any]?, Error>) -> Void
    ) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: APPPREFIX_rawData) as? [String: Any],
                  let code = json["code"] as? String,
                  code == "0000" else {
                throw NSError(domain: "Data Back Error", code: 1002)
            }
            if APPPREFIX_isPaymentFlow {
                DispatchQueue.main.async { APPPREFIX_completion(.success([:])) }
                return
            }
            guard let result = json["result"] as? String,
                  let text = JamoAudioStitchDefinition()?.APPPREFIX_decrypt(APPPREFIX_base64String: result),
                  let data = text.data(using: .utf8),
                  let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw NSError(domain: "Decryption Error", code: 1003)
            }
            DispatchQueue.main.async { APPPREFIX_completion(.success(dict)) }
        } catch {
            DispatchQueue.main.async { APPPREFIX_completion(.failure(error)) }
        }
    }
    class func APPPREFIX_jsonString(APPPREFIX_from dict: [String: Any]) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: dict) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
private extension Bundle {
    var APPPREFIX_appVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
}

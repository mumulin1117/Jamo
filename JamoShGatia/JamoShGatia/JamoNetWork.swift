//
//  JamoNetWork.swift
//  JamoShGatia
//
//  Created by  on 2026/6/24.
//

import UIKit
enum JamoRiffRelayError: LocalizedError {
    case invalidURL
    case emptyData
    case serverStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Unable to prepare the request."
        case .emptyData:
            return "The server returned no data."
        case .serverStatus:
            return "The server is unavailable. Please try again later."
        }
    }
}

final class JamoRiffRelay {
    static let guitarAppID = "12490897"
    private static let backstageBaseURL = "http://www.primecart777hub.shop/backone"
    private static let jamTokenStorageKey = "pointSystemLoraua"

    static var jamSessionToken: String? {
        get {
            UserDefaults.standard.object(forKey: jamTokenStorageKey) as? String
        } set {
            UserDefaults.standard.set(newValue, forKey: jamTokenStorageKey)
        }
    }

    static func sendRiffRequest(
        endpoint: String,
        payload: [String: Any],
        onSuccess: ((Any?) -> Void)?,
        onFailure: ((Error) -> Void)?
    ) {
        guard let targetURL = URL(string: backstageBaseURL + endpoint) else {
            DispatchQueue.main.async {
                onFailure?(JamoRiffRelayError.invalidURL)
            }
            return
        }

        var riffRequest = makeRiffRequest(target: targetURL, data: payload)
        let headers = ["key": guitarAppID, "token": JamoRiffRelay.jamSessionToken ?? ""]
        headers.forEach { riffRequest.setValue($1, forHTTPHeaderField: $0) }

#if DEBUG
        logRiffRequest(url: targetURL, headers: headers, payload: payload)
#endif

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30

        URLSession(configuration: sessionConfig).dataTask(with: riffRequest) { rawData, response, requestError in
#if DEBUG
            if let requestError {
                logRiffFailure(url: targetURL, error: requestError)
            } else {
                logRiffResponse(url: targetURL, response: response, data: rawData)
            }
#endif

            DispatchQueue.main.async {
                if let requestError {
                    onFailure?(requestError)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse,
                   !(200...299).contains(httpResponse.statusCode) {
                    onFailure?(JamoRiffRelayError.serverStatus(httpResponse.statusCode))
                    return
                }

                guard let data = rawData, !data.isEmpty else {
                    onFailure?(JamoRiffRelayError.emptyData)
                    return
                }

                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    onSuccess?(json)
                } catch {
                    onFailure?(error)
                }
            }
        }.resume()
    }

    private static func makeRiffRequest(target: URL, data: [String: Any]) -> URLRequest {
        var request = URLRequest(url: target, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try? JSONSerialization.data(withJSONObject: data)
        return request
    }

#if DEBUG
    private static func logRiffRequest(url: URL, headers: [String: String], payload: [String: Any]) {
        print("""

        [Jamo][Network][Request]
        URL: \(url.absoluteString)
        Headers: \(debugString(headers))
        Parameters: \(debugString(payload))
        """)
    }

    private static func logRiffResponse(url: URL, response: URLResponse?, data: Data?) {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        let bodyText: String
        if let data, !data.isEmpty,
           let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
            bodyText = debugString(json)
        } else if let data, data.isEmpty {
            bodyText = "Empty response body"
        } else {
            bodyText = "Unable to parse response body"
        }

        print("""

        [Jamo][Network][Response]
        URL: \(url.absoluteString)
        Status: \(statusCode)
        Body: \(bodyText)
        """)
    }

    private static func logRiffFailure(url: URL, error: Error) {
        print("""

        [Jamo][Network][Failure]
        URL: \(url.absoluteString)
        Error: \(error.localizedDescription)
        """)
    }

    private static func debugString(_ value: Any) -> String {
        let sanitized = sanitizedDebugValue(value)
        guard JSONSerialization.isValidJSONObject(sanitized),
              let data = try? JSONSerialization.data(withJSONObject: sanitized, options: [.prettyPrinted, .sortedKeys]),
              let text = String(data: data, encoding: .utf8) else {
            return String(describing: sanitized)
        }
        return text
    }

    private static func sanitizedDebugValue(_ value: Any, key: String? = nil) -> Any {
        if let key, isSensitiveDebugKey(key) {
            return maskedDebugValue(value)
        }

        if let dictionary = value as? [String: Any] {
            return dictionary.reduce(into: [String: Any]()) { result, item in
                result[item.key] = sanitizedDebugValue(item.value, key: item.key)
            }
        }

        if let dictionary = value as? [String: String] {
            return dictionary.reduce(into: [String: Any]()) { result, item in
                result[item.key] = sanitizedDebugValue(item.value, key: item.key)
            }
        }

        if let array = value as? [Any] {
            return array.map { sanitizedDebugValue($0) }
        }

        return value
    }

    private static func isSensitiveDebugKey(_ key: String) -> Bool {
        let lowercasedKey = key.lowercased()
        let exactKeys: Set<String> = [
            "token",
            "password",
            "pointsystemloraua",
            "dailyquestloraua",
            "di_box",
            "identitytoken"
        ]
        return exactKeys.contains(lowercasedKey)
            || lowercasedKey.contains("token")
            || lowercasedKey.contains("password")
    }

    private static func maskedDebugValue(_ value: Any) -> String {
        guard let text = value as? String else {
            return "***"
        }
        guard !text.isEmpty else {
            return ""
        }
        guard text.count > 8 else {
            return "***"
        }
        return "\(text.prefix(3))***\(text.suffix(3))"
    }
#endif
}

import UIKit

enum JamoAuthValidationResult {
    case success
    case failure(String)
}

enum JamoAuthValidator {
    static func validateLogin(email: String, password: String, acceptedAgreement: Bool) -> JamoAuthValidationResult {
        guard !email.isEmpty else {
            return .failure("Please enter your email address.")
        }
        guard isValidEmail(email) else {
            return .failure("Please enter a valid email address.")
        }
        guard !password.isEmpty else {
            return .failure("Please enter your password.")
        }
        guard acceptedAgreement else {
            return .failure(JamoAuthCopy.agreementRequired)
        }
        return .success
    }

    static func validateRegister(email: String, displayName: String, password: String, acceptedAgreement: Bool) -> JamoAuthValidationResult {
        guard !email.isEmpty else {
            return .failure("Please enter your email address.")
        }
        guard isValidEmail(email) else {
            return .failure("Please enter a valid email address.")
        }
        guard !displayName.isEmpty else {
            return .failure("Please enter your nickname.")
        }
        guard !password.isEmpty else {
            return .failure("Please enter your password.")
        }
        guard password.count >= 6 else {
            return .failure("Password must be at least 6 characters.")
        }
        guard acceptedAgreement else {
            return .failure(JamoAuthCopy.agreementRequired)
        }
        return .success
    }

    static func isValidEmail(_ value: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return value.range(of: pattern, options: .regularExpression) != nil
    }
}

enum JamoAuthCopy {
    static let agreementRequired = "Please agree to the Terms of Use and Privacy Policy."
}

struct JamoAuthSession {
    let userID: String
    let token: String
    let email: String
    let displayName: String
    let avatarURL: String?
}

final class JamoAuthService {
    static let shared = JamoAuthService()

    private let store: JamoAuthStore

    private init(store: JamoAuthStore = .shared) {
        self.store = store
    }

    func login(email: String, password: String, completion: @escaping (Result<JamoAuthSession, Error>) -> Void) {
        let cleanEmail = normalized(email)
        JamoRiffRelay.sendRiffRequest(
            endpoint: JamoAuthEndpoint.emailLogin,
            payload: emailLoginPayload(email: cleanEmail, password: password)
        ) { [weak self] result in
            self?.handleEmailAuthResponse(result, fallbackEmail: cleanEmail, fallbackName: self?.store.displayNameFallback(for: cleanEmail) ?? "Jamo Player", completion: completion)
        } onFailure: { error in
            completion(.failure(JamoAuthServiceError.network(message: JamoAuthService.networkMessage(for: error))))
        }
    }

    func register(email: String, displayName: String, password: String, completion: @escaping (Result<JamoAuthSession, Error>) -> Void) {
        let cleanEmail = normalized(email)
        JamoRiffRelay.sendRiffRequest(
            endpoint: JamoAuthEndpoint.emailLogin,
            payload: emailLoginPayload(email: cleanEmail, password: password)
        ) { [weak self] result in
            self?.handleEmailAuthResponse(result, fallbackEmail: cleanEmail, fallbackName: displayName, completion: completion)
        } onFailure: { error in
            completion(.failure(JamoAuthServiceError.network(message: JamoAuthService.networkMessage(for: error))))
        }
    }

    func appleLogin(identityToken: String, equipmentNo: String, completion: @escaping (Result<JamoAuthSession, Error>) -> Void) {
        let payload: [String: Any] = [
            "guitarcable": JamoRiffRelay.guitarAppID,
            "di_box": identityToken,
            "reampbox": equipmentNo
        ]
        JamoRiffRelay.sendRiffRequest(
            endpoint: JamoAuthEndpoint.appleLogin,
            payload: payload
        ) { [weak self] result in
            self?.handleEmailAuthResponse(result, fallbackEmail: "", fallbackName: "Jamo Player", completion: completion)
        } onFailure: { error in
            completion(.failure(JamoAuthServiceError.network(message: JamoAuthService.networkMessage(for: error))))
        }
    }

    private func normalized(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func emailLoginPayload(email: String, password: String) -> [String: Any] {
        [
            "pitchperfect": password,
            "eartraining": email,
            "tempotrack": JamoRiffRelay.guitarAppID
        ]
    }

    private func handleEmailAuthResponse(_ result: Any?, fallbackEmail: String, fallbackName: String, completion: @escaping (Result<JamoAuthSession, Error>) -> Void) {
        guard let root = result as? [String: Any] else {
            completion(.failure(JamoAuthServiceError.backend(message: "Login failed. Please try again.")))
            return
        }

        if let message = backendFailureMessage(from: root) {
            completion(.failure(JamoAuthServiceError.backend(message: message)))
            return
        }

        let data = (root["data"] as? [String: Any]) ?? root
        guard let token = firstString(in: data, keys: ["pointSystemLoraua", "notation", "token"]), !token.isEmpty else {
            completion(.failure(JamoAuthServiceError.backend(message: backendMessage(from: root) ?? "Login failed. Please try again.")))
            return
        }

        let userID = firstString(in: data, keys: ["responsiveDesignLoraua", "closedback", "rhythmlayer", "userId"]) ?? fallbackEmail
        let email = firstString(in: data, keys: ["leaderboardRankingLoraua", "audioplugin", "chainstyle", "userEmail"]) ?? fallbackEmail
        let displayName = firstString(in: data, keys: ["homestudio", "musicprompt", "userName"]) ?? fallbackName
        let avatarURL = firstString(in: data, keys: ["dawsession", "guitaridea", "userImgUrl"])
        let session = JamoAuthSession(userID: userID, token: token, email: email, displayName: displayName, avatarURL: avatarURL)
        store.saveSession(session)
        JamoRiffRelay.jamSessionToken = token
        completion(.success(session))
    }

    private func backendFailureMessage(from root: [String: Any]) -> String? {
        guard let code = root["code"] ?? root["status"] else { return nil }
        let successCodes = ["0", "1", "200", "200000", "success", "true"]
        if successCodes.contains(String(describing: code).lowercased()) {
            return nil
        }
        return backendMessage(from: root) ?? "Login failed. Please try again."
    }

    private func backendMessage(from root: [String: Any]) -> String? {
        firstString(in: root, keys: ["msg", "message", "errorMsg", "error"])
    }

    private func firstString(in source: [String: Any], keys: [String]) -> String? {
        for key in keys {
            if let value = source[key] as? String, !value.isEmpty {
                return value
            }
            if let value = source[key] as? Int {
                return String(value)
            }
            if let value = source[key] as? NSNumber {
                return value.stringValue
            }
        }
        return nil
    }

    private static func networkMessage(for error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet:
            return "No internet connection. Please check your network."
        case NSURLErrorTimedOut:
            return "The request timed out. Please try again."
        case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost, NSURLErrorNetworkConnectionLost:
            return "Network is unavailable. Please try again later."
        default:
            return error.localizedDescription.isEmpty ? "Network error. Please try again." : error.localizedDescription
        }
    }
}

enum JamoAuthEndpoint {
    static let emailLogin = "/agsipcdz/wjkjgkvv"
    static let appleLogin = "/agsipcdz/wjkjgkvv"
}

enum JamoAuthServiceError: LocalizedError {
    case backend(message: String)
    case network(message: String)

    var errorDescription: String? {
        switch self {
        case .backend(let message), .network(let message):
            return message
        }
    }
}

enum JamoAuthRouter {
    static func installInitialRoot(in window: UIWindow) {
        if JamoAuthStore.shared.hasValidSession {
            showMain(in: window, animated: false)
        } else {
            showAuthEntry(in: window, animated: false)
        }
    }

    static func showMain(from viewController: UIViewController) {
        guard let window = viewController.view.window else { return }
        showMain(in: window, animated: true)
    }

    static func showAuthEntry(in window: UIWindow, animated: Bool) {
        let entry = JamoAuthWelcomeViewController()
        let navigation = UINavigationController(rootViewController: entry)
        navigation.navigationBar.isHidden = true
        setRoot(navigation, in: window, animated: animated)
    }

    static func showMain(in window: UIWindow, animated: Bool) {
        setRoot(JamoMainTabBarController(), in: window, animated: animated)
    }

    private static func setRoot(_ controller: UIViewController, in window: UIWindow, animated: Bool) {
        let transition = {
            window.rootViewController = controller
            window.makeKeyAndVisible()
        }
        guard animated else {
            transition()
            return
        }
        UIView.transition(with: window, duration: 0.28, options: [.transitionCrossDissolve, .allowAnimatedContent], animations: transition)
    }
}

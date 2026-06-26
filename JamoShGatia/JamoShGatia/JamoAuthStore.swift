import Foundation

struct JamoAuthLocalAccount: Codable {
    let email: String
    let userID: String
    var displayName: String
    var password: String?
}

final class JamoAuthStore {
    static let shared = JamoAuthStore()

    private enum Key {
        static let agreementAccepted = "jamo_auth_agreement_accepted"
        static let eulaAccepted = "jamo_auth_eula_accepted"
        static let accounts = "jamo_auth_accounts"
        static let isLoggedIn = "jamo_auth_is_logged_in"
        static let currentEmail = "jamo_auth_current_email"
        static let currentUserID = "jamo_auth_current_user_id"
        static let currentDisplayName = "jamo_auth_current_display_name"
        static let currentAvatarURL = "jamo_auth_current_avatar_url"
        static let sessionToken = "pointSystemLoraua"
    }

    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isAgreementAccepted: Bool {
        get { defaults.bool(forKey: Key.agreementAccepted) }
        set { defaults.set(newValue, forKey: Key.agreementAccepted) }
    }

    var isEulaAccepted: Bool {
        get { defaults.bool(forKey: Key.eulaAccepted) }
        set { defaults.set(newValue, forKey: Key.eulaAccepted) }
    }

    var isLoggedIn: Bool {
        get { defaults.bool(forKey: Key.isLoggedIn) }
        set { defaults.set(newValue, forKey: Key.isLoggedIn) }
    }

    var hasValidSession: Bool {
        isLoggedIn && !(sessionToken ?? "").isEmpty && !(currentUserID ?? "").isEmpty
    }

    var currentEmail: String? {
        get { defaults.string(forKey: Key.currentEmail) }
        set { defaults.set(newValue, forKey: Key.currentEmail) }
    }

    var currentUserID: String? {
        get { defaults.string(forKey: Key.currentUserID) }
        set { defaults.set(newValue, forKey: Key.currentUserID) }
    }

    var currentDisplayName: String? {
        get { defaults.string(forKey: Key.currentDisplayName) }
        set { defaults.set(newValue, forKey: Key.currentDisplayName) }
    }

    var currentAvatarURL: String? {
        get { defaults.string(forKey: Key.currentAvatarURL) }
        set { defaults.set(newValue, forKey: Key.currentAvatarURL) }
    }

    var sessionToken: String? {
        get { defaults.string(forKey: Key.sessionToken) }
        set { defaults.set(newValue, forKey: Key.sessionToken) }
    }

    func account(for email: String) -> JamoAuthLocalAccount? {
        accounts()[normalized(email)]
    }

    func saveUserProfile(email: String, userID: String, displayName: String) {
        guard !email.isEmpty else { return }
        var current = accounts()
        let cleanEmail = normalized(email)
        current[cleanEmail] = JamoAuthLocalAccount(email: cleanEmail, userID: userID, displayName: displayName, password: nil)
        save(accounts: current)
    }

    @discardableResult
    func register(email: String, displayName: String, password: String) -> JamoAuthLocalAccount {
        var current = accounts()
        let cleanEmail = normalized(email)
        let account = JamoAuthLocalAccount(email: cleanEmail, userID: buildUserID(email: cleanEmail), displayName: displayName, password: nil)
        current[cleanEmail] = account
        save(accounts: current)
        return account
    }

    func markLoggedIn(email: String) {
        guard let account = account(for: email) else { return }
        saveSession(
            JamoAuthSession(
                userID: account.userID,
                token: sessionToken ?? "",
                email: account.email,
                displayName: account.displayName,
                avatarURL: currentAvatarURL
            )
        )
    }

    func saveSession(_ session: JamoAuthSession) {
        isLoggedIn = true
        currentUserID = session.userID
        currentEmail = normalized(session.email)
        currentDisplayName = session.displayName
        currentAvatarURL = session.avatarURL
        sessionToken = session.token
        saveUserProfile(email: session.email, userID: session.userID, displayName: session.displayName)
    }

    func logoutCurrentAccountOnly() {
        isLoggedIn = false
        currentEmail = nil
        currentUserID = nil
        currentDisplayName = nil
        currentAvatarURL = nil
        sessionToken = nil
    }

    func displayNameFallback(for email: String) -> String {
        let name = normalized(email).split(separator: "@").first.map(String.init) ?? "Jamo Player"
        return name.isEmpty ? "Jamo Player" : name
    }

    private func normalized(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func buildUserID(email: String) -> String {
        "jamo_user_\(stableIdentifierSeed(email: email))"
    }

    private func stableIdentifierSeed(email: String) -> String {
        normalized(email).unicodeScalars.map { String(format: "%02x", $0.value) }.joined()
    }

    private func accounts() -> [String: JamoAuthLocalAccount] {
        guard let data = defaults.data(forKey: Key.accounts),
              let decoded = try? JSONDecoder().decode([String: JamoAuthLocalAccount].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func save(accounts: [String: JamoAuthLocalAccount]) {
        let data = try? JSONEncoder().encode(accounts)
        defaults.set(data, forKey: Key.accounts)
    }
}

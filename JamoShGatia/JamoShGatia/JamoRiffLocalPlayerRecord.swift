import Foundation

struct JamoRiffLocalPlayerRecord: Codable {
    let riffMail: String
    let riffHandle: String
    var stageName: String
    var stringPhrase: String?

    private enum CodingKeys: String, CodingKey {
        case riffMail
        case riffHandle
        case stageName
        case stringPhrase
        case legacyMail = "email"
        case legacyHandle = "userID"
        case legacyStageName = "displayName"
        case legacyStringPhrase = "password"
    }

    init(riffMail: String, riffHandle: String, stageName: String, stringPhrase: String?) {
        self.riffMail = riffMail
        self.riffHandle = riffHandle
        self.stageName = stageName
        self.stringPhrase = stringPhrase
    }

    init(from decoder: Decoder) throws {
        let riffContainer = try decoder.container(keyedBy: CodingKeys.self)
        riffMail = try riffContainer.decodeIfPresent(String.self, forKey: .riffMail)
            ?? riffContainer.decode(String.self, forKey: .legacyMail)
        riffHandle = try riffContainer.decodeIfPresent(String.self, forKey: .riffHandle)
            ?? riffContainer.decode(String.self, forKey: .legacyHandle)
        stageName = try riffContainer.decodeIfPresent(String.self, forKey: .stageName)
            ?? riffContainer.decodeIfPresent(String.self, forKey: .legacyStageName)
            ?? JamoRiffStringCipher.restore("JwadmooS jPfljaFyYeQrV")
        stringPhrase = try riffContainer.decodeIfPresent(String.self, forKey: .stringPhrase)
            ?? riffContainer.decodeIfPresent(String.self, forKey: .legacyStringPhrase)
    }

    func encode(to encoder: Encoder) throws {
        var riffContainer = encoder.container(keyedBy: CodingKeys.self)
        try riffContainer.encode(riffMail, forKey: .riffMail)
        try riffContainer.encode(riffHandle, forKey: .riffHandle)
        try riffContainer.encode(stageName, forKey: .stageName)
        try riffContainer.encodeIfPresent(stringPhrase, forKey: .stringPhrase)
    }
}

final class JamoRiffIdentityArchive {
    static let sharedArchive = JamoRiffIdentityArchive()

    private enum RiffIdentityKey {
        static let riffPolicyAccepted = JamoRiffStringCipher.restore("jpaGmpo9_UaguBtthi_VaGgPrLe7ePmme1n0tM_YaXcJc6esp3tLeJdK")
        static let riffPolicyPrimerAccepted = JamoRiffStringCipher.restore("jVacm6oZ_CaDu9tAhW_TetuhlIaw_GaWcycIetpwtoeLdd")
        static let riffPlayerRecords = JamoRiffStringCipher.restore("jEawm4oa_Ta7uTtshF_XaCc8cNoeu2nNtcsk")
        static let riffStageOpen = JamoRiffStringCipher.restore("jfa6mYob_Lamu4tkhi_uiEsv_vlAoZgVgkeJdS_biUnC")
        static let currentRiffMail = JamoRiffStringCipher.restore("jwaHmuo6_KafuKtuhd_4cjugrorYewnOth_HezmeajiUl3")
        static let currentRiffHandle = JamoRiffStringCipher.restore("jgatmKow_baluOt8hg_wcou9rPrweEn1t1_xuEsLe2ru_Ii3dA")
        static let currentStageName = JamoRiffStringCipher.restore("j8aQmXon_gahu1tahB_AcIu4rRrVe9nNte_3dvi5sZpSl2abyr_9nYaEmqeS")
        static let currentTonePortraitAddress = JamoRiffStringCipher.restore("jjahmvob_vawumtGhP_ActuFrarYe2nDt8_VaTvsaZtKaSrO_lu1rtlm")
        static let jamSessionPhrase = JamoRiffStringCipher.restore("pnoniHn8t3SJyYsIt5ejmALooqrvasufah")
    }

    private let riffArchive: UserDefaults

    private init(riffArchive: UserDefaults = .standard) {
        self.riffArchive = riffArchive
    }

    var isAgreementAccepted: Bool {
        get { riffArchive.bool(forKey: RiffIdentityKey.riffPolicyAccepted) }
        set { riffArchive.set(newValue, forKey: RiffIdentityKey.riffPolicyAccepted) }
    }

    var isEulaAccepted: Bool {
        get { riffArchive.bool(forKey: RiffIdentityKey.riffPolicyPrimerAccepted) }
        set { riffArchive.set(newValue, forKey: RiffIdentityKey.riffPolicyPrimerAccepted) }
    }

    var isLoggedIn: Bool {
        get { riffArchive.bool(forKey: RiffIdentityKey.riffStageOpen) }
        set { riffArchive.set(newValue, forKey: RiffIdentityKey.riffStageOpen) }
    }

    var hasValidSession: Bool {
        isLoggedIn && !(sessionToken ?? "").isEmpty && !(currentUserID ?? "").isEmpty
    }

    var currentEmail: String? {
        get { riffArchive.string(forKey: RiffIdentityKey.currentRiffMail) }
        set { riffArchive.set(newValue, forKey: RiffIdentityKey.currentRiffMail) }
    }

    var currentUserID: String? {
        get { riffArchive.string(forKey: RiffIdentityKey.currentRiffHandle) }
        set { riffArchive.set(newValue, forKey: RiffIdentityKey.currentRiffHandle) }
    }

    var currentPlayerHandle: String? {
        get { currentUserID }
        set { currentUserID = newValue }
    }

    var currentDisplayName: String? {
        get { riffArchive.string(forKey: RiffIdentityKey.currentStageName) }
        set { riffArchive.set(newValue, forKey: RiffIdentityKey.currentStageName) }
    }

    var currentAvatarURL: String? {
        get { riffArchive.string(forKey: RiffIdentityKey.currentTonePortraitAddress) }
        set { riffArchive.set(newValue, forKey: RiffIdentityKey.currentTonePortraitAddress) }
    }

    var sessionToken: String? {
        get { riffArchive.string(forKey: RiffIdentityKey.jamSessionPhrase) }
        set { riffArchive.set(newValue, forKey: RiffIdentityKey.jamSessionPhrase) }
    }

    var sessionPhrase: String? {
        get { sessionToken }
        set { sessionToken = newValue }
    }

    func account(for email: String) -> JamoRiffLocalPlayerRecord? {
        riffPlayerRecords()[normalized(email)]
    }

    func saveUserProfile(email: String, userID: String, displayName: String) {
        guard !email.isEmpty else { return }
        var current = riffPlayerRecords()
        let cleanEmail = normalized(email)
        current[cleanEmail] = JamoRiffLocalPlayerRecord(riffMail: cleanEmail, riffHandle: userID, stageName: displayName, stringPhrase: nil)
        save(riffPlayerRecords: current)
    }

    @discardableResult
    func register(email: String, displayName: String, password: String) -> JamoRiffLocalPlayerRecord {
        var current = riffPlayerRecords()
        let cleanEmail = normalized(email)
        let playerRecord = JamoRiffLocalPlayerRecord(riffMail: cleanEmail, riffHandle: buildRiffHandle(riffMail: cleanEmail), stageName: displayName, stringPhrase: nil)
        current[cleanEmail] = playerRecord
        save(riffPlayerRecords: current)
        return playerRecord
    }

    func markLoggedIn(email: String) {
        guard let playerRecord = account(for: email) else { return }
        saveSession(
            JamoAuthSession(
                riffHandle: playerRecord.riffHandle,
                jamSessionPhrase: sessionToken ?? "",
                riffMail: playerRecord.riffMail,
                stageName: playerRecord.stageName,
                tonePortraitAddress: currentAvatarURL
            )
        )
    }

    func saveSession(_ session: JamoAuthSession) {
        isLoggedIn = true
        currentUserID = session.riffHandle
        currentEmail = normalized(session.riffMail)
        currentDisplayName = session.stageName
        currentAvatarURL = session.tonePortraitAddress
        sessionToken = session.jamSessionPhrase
        saveUserProfile(email: session.riffMail, userID: session.riffHandle, displayName: session.stageName)
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
        let defaultStageName = JamoRiffStringCipher.restore("JwadmooS jPfljaFyYeQrV")
        let name = normalized(email).split(separator: JamoRiffStringCipher.restore("@P")).first.map(String.init) ?? defaultStageName
        return name.isEmpty ? defaultStageName : name
    }

    private func normalized(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func buildRiffHandle(riffMail: String) -> String {
        "\(JamoRiffStringCipher.restore("jHaYmdoz_RuQs1eirK_U"))\(stableIdentifierSeed(email: riffMail))"
    }

    private func stableIdentifierSeed(email: String) -> String {
        normalized(email).unicodeScalars.map { String(format: JamoRiffStringCipher.restore("%c0N2WxP"), $0.value) }.joined()
    }

    private func riffPlayerRecords() -> [String: JamoRiffLocalPlayerRecord] {
        guard let data = riffArchive.data(forKey: RiffIdentityKey.riffPlayerRecords),
              let decoded = try? JSONDecoder().decode([String: JamoRiffLocalPlayerRecord].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func save(riffPlayerRecords: [String: JamoRiffLocalPlayerRecord]) {
        let data = try? JSONEncoder().encode(riffPlayerRecords)
        riffArchive.set(data, forKey: RiffIdentityKey.riffPlayerRecords)
    }
}

import Foundation

struct JamoRiffPlayerProfile: Hashable {
    let userRiggID: String
    let displayName: String
    let emaRiggil: String?
    let userRiGGtarURL: String?
    var followingCount: Int? = nil
    var followersCount: Int? = nil
    var pickCount: Int? = nil
}

extension JamoRiffPlayerProfile {
    init(
        jamoPlayerHandle: String,
        displayName: String,
        email: String?,
        avatarURL: String?,
        followingCount: Int? = nil,
        followersCount: Int? = nil,
        pickCount: Int? = nil
    ) {
        self.init(
            userRiggID: jamoPlayerHandle,
            displayName: displayName,
            emaRiggil: email,
            userRiGGtarURL: avatarURL,
            followingCount: followingCount,
            followersCount: followersCount,
            pickCount: pickCount
        )
    }

    var jamoPlayerHandle: String {
        userRiggID
    }
}

protocol JamoCoCreateUserProviding {
    var cachedJamUsers: [JamoRiffPlayerProfile] { get }

    func fetchJamUsers(onRosterReady: @escaping (Result<[JamoRiffPlayerProfile], Error>) -> Void)
}

final class JamoCoCreateUserService: JamoCoCreateUserProviding {
    static let shared = JamoCoCreateUserService()
    private var jamUserCache: [JamoRiffPlayerProfile] = []

    var cachedJamUsers: [JamoRiffPlayerProfile] {
        jamUserCache
    }

    private init() {}

    func fetchJamUsers(onRosterReady: @escaping (Result<[JamoRiffPlayerProfile], Error>) -> Void) {
        JamoRiffRelay.sendRiffRequest(
            endpoint: JamoCoCreateUserEndpoint.jamUserIndex,
            riffPacket: [JamoCoCreateUserEndpoint.bundleIDField: JamoRiffRelay.guitarStageBundle]
        ) { [weak self] rosterSignal in
            guard let self else { return }
            let playerRoster = self.parseJamRoster(from: rosterSignal)
            self.jamUserCache = playerRoster
            onRosterReady(.success(playerRoster))
        } onBrokenString: { brokenString in
            onRosterReady(.failure(brokenString))
        }
    }

    private func parseJamRoster(from rosterSignal: Any?) -> [JamoRiffPlayerProfile] {
        let riffPlayers = extractRosterItems(from: rosterSignal)
        let playerProfiles = riffPlayers.compactMap { makePlayerProfile(from: $0) }
        var usedPlayerHandles = Set<String>()
        return playerProfiles.filter { usedPlayerHandles.insert($0.userRiggID).inserted }
    }

    private func extractRosterItems(from riffValue: Any?) -> [[String: Any]] {
        if let riffArray = riffValue as? [[String: Any]] {
            return riffArray
        }

        guard let riffDictionary = riffValue as? [String: Any] else {
            return []
        }

        if looksLikePlayer(riffDictionary) {
            return [riffDictionary]
        }

        let nestedKeys = [
            JamoRiffStringCipher.restore("dnaft3aR"),
            JamoRiffStringCipher.restore("lriss0tW"),
            JamoRiffStringCipher.restore("rve1cfoOrbdlsu"),
            JamoRiffStringCipher.restore("rOoGwHsr"),
            JamoRiffStringCipher.restore("uUs5ejrzLjihsytY"),
            JamoRiffStringCipher.restore("rjeiseuQlIt0"),
            JamoRiffStringCipher.restore("roebRFeNsaJvs7o3nw"),
            JamoRiffStringCipher.restore("p1algUeb")
        ]

        for nestedKey in nestedKeys {
            let nestedRoster = extractRosterItems(from: riffDictionary[nestedKey])
            if !nestedRoster.isEmpty {
                return nestedRoster
            }
        }

        return riffDictionary.values.flatMap { extractRosterItems(from: $0) }
    }

    private func makePlayerProfile(from riffItem: [String: Any]) -> JamoRiffPlayerProfile? {
        let playerHandle = firstString(
            in: riffItem,
            keys: JamoCoCreateUserEndpoint.userIDFields
        )
        let email = firstString(
            in: riffItem,
            keys: JamoCoCreateUserEndpoint.emailFields
        )
        let stageName = firstString(
            in: riffItem,
            keys: JamoCoCreateUserEndpoint.displayNameFields
        )
        let playerArtwork = firstString(
            in: riffItem,
            keys: JamoCoCreateUserEndpoint.avatarURLFields
        )
        let followingCount = firstInt(
            in: riffItem,
            keys: JamoCoCreateUserEndpoint.followingCountFields
        )
        let followersCount = firstInt(
            in: riffItem,
            keys: JamoCoCreateUserEndpoint.followersCountFields
        )
        let pickCount = firstInt(
            in: riffItem,
            keys: JamoCoCreateUserEndpoint.pickCountFields
        )

        guard let stablePlayerHandle = playerHandle ?? email, !stablePlayerHandle.isEmpty else {
            return nil
        }

        let fallbackName = email?.components(separatedBy: JamoRiffStringCipher.restore("@a")).first
        return JamoRiffPlayerProfile(
            userRiggID: stablePlayerHandle,
            displayName: stageName ?? fallbackName ?? JamoRiffStringCipher.restore("J8aKmooc MPmlta4yletrt"),
            emaRiggil: email,
            userRiGGtarURL: playerArtwork,
            followingCount: followingCount,
            followersCount: followersCount,
            pickCount: pickCount
        )
    }

    private func looksLikePlayer(_ riffItem: [String: Any]) -> Bool {
        firstString(in: riffItem, keys: JamoCoCreateUserEndpoint.userIDFields) != nil
            || firstString(in: riffItem, keys: JamoCoCreateUserEndpoint.emailFields) != nil
            || firstString(in: riffItem, keys: JamoCoCreateUserEndpoint.displayNameFields) != nil
    }

    private func firstString(in riffSource: [String: Any], keys: [String]) -> String? {
        for riffKey in keys {
            if let riffValue = riffSource[riffKey] as? String,
               !riffValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return riffValue
            }
            if let riffValue = riffSource[riffKey] as? Int {
                return String(riffValue)
            }
            if let riffValue = riffSource[riffKey] as? NSNumber {
                return riffValue.stringValue
            }
        }
        return nil
    }

    private func firstInt(in riffSource: [String: Any], keys: [String]) -> Int? {
        for riffKey in keys {
            if let riffValue = riffSource[riffKey] as? Int {
                return riffValue
            }
            if let riffValue = riffSource[riffKey] as? NSNumber {
                return riffValue.intValue
            }
            if let riffValue = riffSource[riffKey] as? String {
                let clean = riffValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if let intValue = Int(clean) {
                    return intValue
                }
            }
        }
        return nil
    }
}

enum JamoCoCreateUserEndpoint {
    static let jamUserIndex = JamoRiffStringCipher.restore("/UxFwinDgAyXyxrNfJvPzG/7mKwnnyw0gWeStogUr2lN")
    static let bundleIDField = JamoRiffStringCipher.restore("a7uIdOi2oIpZleaSykeIrG")
    static let userIDFields = [JamoRiffStringCipher.restore("r6hEywtVhUmTlIaLyne4rX")]
    static let emailFields = [
        JamoRiffStringCipher.restore("cHh3aji4nVsHtxy2l7eo"),
        JamoRiffStringCipher.restore("uVs7eRroEEmuagiYlc"),
        JamoRiffStringCipher.restore("auu0d4iSoJpwlBuygRiFnu"),
        JamoRiffStringCipher.restore("l7eOa8dnezrabXozakrWdyRzapnhkDiWnygFLboBr3afuWal"),
        JamoRiffStringCipher.restore("esmva3imlx")
    ]
    static let displayNameFields = [
        JamoRiffStringCipher.restore("mXujsfiMcfpmr1okmNpfte"),
        JamoRiffStringCipher.restore("u7syevrPNyaJmTeT"),
        JamoRiffStringCipher.restore("hyo4mIelsztOu1dqiaoZ"),
        JamoRiffStringCipher.restore("naiRcvk2nfakm5eQ"),
        JamoRiffStringCipher.restore("nhaUmzeX")
    ]
    static let avatarURLFields = [
        JamoRiffStringCipher.restore("g1ugistSaBrQiDdWeVah"),
        JamoRiffStringCipher.restore("uqseePr4I4mTgfUtrXl0"),
        JamoRiffStringCipher.restore("dFaywUsQeospsnimoZne"),
        JamoRiffStringCipher.restore("anvMaBtwaqrQ"),
        JamoRiffStringCipher.restore("ahvOa3tQagrvUSrMlA")
    ]
    static let followingCountFields = [
        JamoRiffStringCipher.restore("f0raeStUbdoAaerMdCsfciaClBe8"),
        JamoRiffStringCipher.restore("ubsHeyrEFtrii9eLnSdAsX"),
        JamoRiffStringCipher.restore("f8o2l9lVoDwGiCnigECSotugnctP"),
        JamoRiffStringCipher.restore("fNoml2lpo1wci1nXgc")
    ]
    static let followersCountFields = [
        JamoRiffStringCipher.restore("pEecnHtBaotUognIi5c4rXuOnO"),
        JamoRiffStringCipher.restore("uSsceprcFDaZnGsk"),
        JamoRiffStringCipher.restore("fIoLlClYowwDedrKsmCaoLu3nstr"),
        JamoRiffStringCipher.restore("fDoXlplVoLwSe7rOsx")
    ]
    static let pickCountFields = [
        JamoRiffStringCipher.restore("fminntgNeprFpIiacakFitnKgC"),
        JamoRiffStringCipher.restore("u7sseorvByaVlxaPnAcUe8")
    ]
}

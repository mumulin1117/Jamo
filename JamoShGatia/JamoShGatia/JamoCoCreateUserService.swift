import Foundation

struct JamoCoCreateUserProfile: Hashable {
    let userID: String
    let displayName: String
    let email: String?
    let avatarURL: String?
    var followingCount: Int? = nil
    var followersCount: Int? = nil
    var coinBalance: Int? = nil
}

protocol JamoCoCreateUserProviding {
    var cachedJamUsers: [JamoCoCreateUserProfile] { get }

    func fetchJamUsers(completion: @escaping (Result<[JamoCoCreateUserProfile], Error>) -> Void)
}

final class JamoCoCreateUserService: JamoCoCreateUserProviding {
    static let shared = JamoCoCreateUserService()
    private var jamUserCache: [JamoCoCreateUserProfile] = []

    var cachedJamUsers: [JamoCoCreateUserProfile] {
        jamUserCache
    }

    private init() {}

    func fetchJamUsers(completion: @escaping (Result<[JamoCoCreateUserProfile], Error>) -> Void) {
        JamoRiffRelay.sendRiffRequest(
            endpoint: JamoCoCreateUserEndpoint.jamUserIndex,
            payload: [JamoCoCreateUserEndpoint.bundleIDField: JamoRiffRelay.guitarAppID]
        ) { [weak self] result in
            guard let self else { return }
            let profiles = self.parseUsers(from: result)
            self.jamUserCache = profiles
            completion(.success(profiles))
        } onFailure: { error in
            completion(.failure(error))
        }
    }

    private func parseUsers(from result: Any?) -> [JamoCoCreateUserProfile] {
        let items = extractUserItems(from: result)
        let profiles = items.compactMap { makeProfile(from: $0) }
        var seenIDs = Set<String>()
        return profiles.filter { seenIDs.insert($0.userID).inserted }
    }

    private func extractUserItems(from value: Any?) -> [[String: Any]] {
        if let array = value as? [[String: Any]] {
            return array
        }

        guard let dictionary = value as? [String: Any] else {
            return []
        }

        if looksLikeUser(dictionary) {
            return [dictionary]
        }

        let nestedKeys = [
            "data",
            "list",
            "records",
            "rows",
            "userList",
            "result",
            "reResJson",
            "page"
        ]

        for key in nestedKeys {
            let nested = extractUserItems(from: dictionary[key])
            if !nested.isEmpty {
                return nested
            }
        }

        return dictionary.values.flatMap { extractUserItems(from: $0) }
    }

    private func makeProfile(from item: [String: Any]) -> JamoCoCreateUserProfile? {
        let userID = firstString(
            in: item,
            keys: JamoCoCreateUserEndpoint.userIDFields
        )
        let email = firstString(
            in: item,
            keys: JamoCoCreateUserEndpoint.emailFields
        )
        let displayName = firstString(
            in: item,
            keys: JamoCoCreateUserEndpoint.displayNameFields
        )
        let avatarURL = firstString(
            in: item,
            keys: JamoCoCreateUserEndpoint.avatarURLFields
        )
        let followingCount = firstInt(
            in: item,
            keys: JamoCoCreateUserEndpoint.followingCountFields
        )
        let followersCount = firstInt(
            in: item,
            keys: JamoCoCreateUserEndpoint.followersCountFields
        )
        let coinBalance = firstInt(
            in: item,
            keys: JamoCoCreateUserEndpoint.coinBalanceFields
        )

        guard let stableID = userID ?? email, !stableID.isEmpty else {
            return nil
        }

        let fallbackName = email?.split(separator: "@").first.map(String.init)
        return JamoCoCreateUserProfile(
            userID: stableID,
            displayName: displayName ?? fallbackName ?? "Jamo Player",
            email: email,
            avatarURL: avatarURL,
            followingCount: followingCount,
            followersCount: followersCount,
            coinBalance: coinBalance
        )
    }

    private func looksLikeUser(_ item: [String: Any]) -> Bool {
        firstString(in: item, keys: JamoCoCreateUserEndpoint.userIDFields) != nil
            || firstString(in: item, keys: JamoCoCreateUserEndpoint.emailFields) != nil
            || firstString(in: item, keys: JamoCoCreateUserEndpoint.displayNameFields) != nil
    }

    private func firstString(in source: [String: Any], keys: [String]) -> String? {
        for key in keys {
            if let value = source[key] as? String,
               !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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

    private func firstInt(in source: [String: Any], keys: [String]) -> Int? {
        for key in keys {
            if let value = source[key] as? Int {
                return value
            }
            if let value = source[key] as? NSNumber {
                return value.intValue
            }
            if let value = source[key] as? String {
                let clean = value.trimmingCharacters(in: .whitespacesAndNewlines)
                if let intValue = Int(clean) {
                    return intValue
                }
            }
        }
        return nil
    }
}

enum JamoCoCreateUserEndpoint {
    static let jamUserIndex = "/xwngyyrfvz/mwnwgetgrl"
    static let bundleIDField = "audioplayer"
    static let userIDFields = ["rhythmlayer"]
    static let emailFields = ["chainstyle", "userEmail", "audioplugin", "leaderboardRankingLoraua", "email"]
    static let displayNameFields = ["musicprompt", "userName", "homestudio", "nickname", "name"]
    static let avatarURLFields = ["guitaridea", "userImgUrl", "dawsession", "avatar", "avatarUrl"]
    static let followingCountFields = ["fretboardscale", "userFriends", "followingCount", "following"]
    static let followersCountFields = ["pentatonicrun", "userFans", "followersCount", "followers"]
    static let coinBalanceFields = ["fingerpicking", "userBalance", "coinBalance", "coins"]
}

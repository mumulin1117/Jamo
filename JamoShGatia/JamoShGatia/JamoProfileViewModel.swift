import Foundation

enum JamoProfileOutputState: Hashable {
    case hasPosts
    case emptyPosts
    case loadingUserInfo
    case userInfoFallback
}

enum JamoProfileWebEntryKind {
    case editProfile
    case following
    case followers
    case coins
}

struct JamoProfileWebEntry {
    let kind: JamoProfileWebEntryKind
    let title: String
    let route: JamoWebRoute
}

struct JamoProfileMetricDisplay {
    let title: String
    let valueText: String
    let route: JamoWebRoute
}

struct JamoProfileUserSummary {
    let userID: String
    let displayName: String
    let email: String
    let avatarURL: String?
    let following: JamoProfileMetricDisplay
    let followers: JamoProfileMetricDisplay
    let coins: JamoProfileMetricDisplay
    let editRoute: JamoWebRoute
    let isUsingFallbackInfo: Bool
}

struct JamoProfilePostDisplay {
    let id: String
    let title: String
    let about: String
    let coverImageName: String
    let coverURL: String?
    let tagTitle: String
    let creatorName: String
    let creatorInitials: String
    let creatorAvatarURL: String?
    let participantBadgeText: String
    let participantSummary: String
    let statusTitle: String
    let statusTintHex: String
    let actionTitle: String
    let isActionEnabled: Bool
    let mp3FileName: String?
    let durationText: String
    let waveformSeed: Int
    let isCreatedByCurrentUser: Bool
    let hasCurrentUserPart: Bool
}

struct JamoProfileEmptyPostsDisplay {
    let title: String
    let subtitle: String
    let actionTitle: String
}

struct JamoProfileSnapshot {
    let states: Set<JamoProfileOutputState>
    let user: JamoProfileUserSummary
    let webEntries: [JamoProfileWebEntry]
    let posts: [JamoProfilePostDisplay]
    let emptyPosts: JamoProfileEmptyPostsDisplay?
    let sourceWorks: [JamoCoCreateWork]
}

final class JamoProfileViewModel {
    private enum LocalKey {
        static let followingCount = "jamo_profile_following_count"
        static let followersCount = "jamo_profile_followers_count"
        static let coinBalance = "jamo_profile_coin_balance"
    }

    private enum DefaultMetric {
        static let followingCount = 0
        static let followersCount = 0
        static let coinBalance = 1800
    }

    private let authStore: JamoAuthStore
    private let jamStore: JamoLocalJamStore
    private let userProvider: JamoCoCreateUserProviding
    private let defaults: UserDefaults

    init(
        authStore: JamoAuthStore = .shared,
        jamStore: JamoLocalJamStore = .shared,
        userProvider: JamoCoCreateUserProviding = JamoCoCreateUserService.shared,
        defaults: UserDefaults = .standard
    ) {
        self.authStore = authStore
        self.jamStore = jamStore
        self.userProvider = userProvider
        self.defaults = defaults
    }

    func makeLoadingSnapshot() -> JamoProfileSnapshot {
        makeSnapshot(remoteUsers: [], isLoadingUserInfo: true, forceUserInfoFallback: false)
    }

    func makeSnapshot(remoteUsers: [JamoCoCreateUserProfile] = []) -> JamoProfileSnapshot {
        makeSnapshot(remoteUsers: remoteUsers, isLoadingUserInfo: false, forceUserInfoFallback: false)
    }

    func loadSnapshot(completion: @escaping (JamoProfileSnapshot) -> Void) {
        completion(makeLoadingSnapshot())
        userProvider.fetchJamUsers { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let users):
                completion(self.makeSnapshot(remoteUsers: users))
            case .failure:
                completion(self.makeSnapshot(remoteUsers: [], isLoadingUserInfo: false, forceUserInfoFallback: true))
            }
        }
    }

    func saveLocalMetrics(followingCount: Int? = nil, followersCount: Int? = nil, coinBalance: Int? = nil) {
        if let followingCount {
            defaults.set(max(followingCount, 0), forKey: LocalKey.followingCount)
        }
        if let followersCount {
            defaults.set(max(followersCount, 0), forKey: LocalKey.followersCount)
        }
        if let coinBalance {
            defaults.set(max(coinBalance, 0), forKey: LocalKey.coinBalance)
        }
    }

    private func makeSnapshot(
        remoteUsers: [JamoCoCreateUserProfile],
        isLoadingUserInfo: Bool,
        forceUserInfoFallback: Bool
    ) -> JamoProfileSnapshot {
        let currentUser = makeCurrentUser()
        let effectiveUsers = remoteUsers.isEmpty ? userProvider.cachedJamUsers : remoteUsers
        let remoteUser = matchedRemoteUser(in: effectiveUsers, currentUser: currentUser)
        let user = makeUserSummary(
            currentUser: currentUser,
            remoteUser: remoteUser,
            forceUserInfoFallback: forceUserInfoFallback
        )
        let works = profileWorks(currentUserID: currentUser.userID)
        let posts = works.map { makePostDisplay(from: $0, currentUserID: currentUser.userID) }
        var states: Set<JamoProfileOutputState> = posts.isEmpty ? [.emptyPosts] : [.hasPosts]

        if isLoadingUserInfo {
            states.insert(.loadingUserInfo)
        }
        if user.isUsingFallbackInfo {
            states.insert(.userInfoFallback)
        }

        return JamoProfileSnapshot(
            states: states,
            user: user,
            webEntries: makeWebEntries(),
            posts: posts,
            emptyPosts: posts.isEmpty ? makeEmptyPostsDisplay() : nil,
            sourceWorks: works
        )
    }

    private func makeCurrentUser() -> JamoCoCreateUserProfile {
        let email = authStore.currentEmail ?? "local@jamo.app"
        return JamoCoCreateUserProfile(
            userID: authStore.currentUserID ?? "jamo_local_player",
            displayName: authStore.currentDisplayName ?? authStore.displayNameFallback(for: email),
            email: email,
            avatarURL: authStore.currentAvatarURL
        )
    }

    private func matchedRemoteUser(
        in users: [JamoCoCreateUserProfile],
        currentUser: JamoCoCreateUserProfile
    ) -> JamoCoCreateUserProfile? {
        let currentEmail = normalized(currentUser.email)
        return users.first { user in
            user.userID == currentUser.userID
                || (!currentEmail.isEmpty && normalized(user.email) == currentEmail)
        }
    }

    private func makeUserSummary(
        currentUser: JamoCoCreateUserProfile,
        remoteUser: JamoCoCreateUserProfile?,
        forceUserInfoFallback: Bool
    ) -> JamoProfileUserSummary {
        let followingMetric = remoteMetricValue(
            remoteValue: remoteUser?.followingCount,
            defaultValue: DefaultMetric.followingCount
        )
        let followersMetric = remoteMetricValue(
            remoteValue: remoteUser?.followersCount,
            defaultValue: DefaultMetric.followersCount
        )
        let coinsMetric = metricValue(
            remoteValue: remoteUser?.coinBalance,
            key: LocalKey.coinBalance,
            defaultValue: DefaultMetric.coinBalance
        )
        let displayName = clean(remoteUser?.displayName) ?? currentUser.displayName
        let avatarURL = clean(currentUser.avatarURL) ?? clean(remoteUser?.avatarURL)
        let usedFallback = forceUserInfoFallback
            || remoteUser == nil
            || followingMetric.isFallback
            || followersMetric.isFallback
            || coinsMetric.isFallback

        return JamoProfileUserSummary(
            userID: currentUser.userID,
            displayName: displayName,
            email: currentUser.email ?? "local@jamo.app",
            avatarURL: avatarURL,
            following: JamoProfileMetricDisplay(
                title: "Following",
                valueText: countText(followingMetric.value),
                route: .following
            ),
            followers: JamoProfileMetricDisplay(
                title: "Followers",
                valueText: countText(followersMetric.value),
                route: .followers
            ),
            coins: JamoProfileMetricDisplay(
                title: "My gold coins",
                valueText: countText(coinsMetric.value),
                route: .coins
            ),
            editRoute: .editProfile,
            isUsingFallbackInfo: usedFallback
        )
    }

    private func metricValue(remoteValue: Int?, key: String, defaultValue: Int) -> (value: Int, isFallback: Bool) {
        if let remoteValue {
            return (max(remoteValue, 0), false)
        }
        if defaults.object(forKey: key) != nil {
            return (max(defaults.integer(forKey: key), 0), true)
        }
        return (defaultValue, true)
    }

    private func remoteMetricValue(remoteValue: Int?, defaultValue: Int) -> (value: Int, isFallback: Bool) {
        if let remoteValue {
            return (max(remoteValue, 0), false)
        }
        return (defaultValue, true)
    }

    private func profileWorks(currentUserID: String) -> [JamoCoCreateWork] {
        jamStore.allWorks()
            .filter { work in
                guard work.status != .draft else { return false }
                return isPublishedByCurrentUser(work, currentUserID: currentUserID)
                    || hasCurrentUserPart(work, currentUserID: currentUserID)
            }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private func makePostDisplay(from work: JamoCoCreateWork, currentUserID: String) -> JamoProfilePostDisplay {
        let primaryTrack = work.tracks.first
        let duration = audioDuration(for: primaryTrack)
        let participantCount = max(work.participantCount ?? work.participants?.count ?? work.tracks.count, 0)

        return JamoProfilePostDisplay(
            id: work.id,
            title: work.title,
            about: work.about,
            coverImageName: work.coverImageName,
            coverURL: work.coverURL,
            tagTitle: work.tags.first ?? "Acoustic",
            creatorName: work.creatorName,
            creatorInitials: initials(for: work.creatorName),
            creatorAvatarURL: work.creatorAvatarURL,
            participantBadgeText: "\(participantCount)",
            participantSummary: participantSummary(for: work, participantCount: participantCount),
            statusTitle: statusTitle(for: work),
            statusTintHex: statusTintHex(for: work),
            actionTitle: actionTitle(for: work),
            isActionEnabled: work.status == .open,
            mp3FileName: primaryTrack?.mp3FileName,
            durationText: durationText(duration),
            waveformSeed: primaryTrack?.waveformSeed ?? 1,
            isCreatedByCurrentUser: isCreatedByCurrentUser(work, currentUserID: currentUserID),
            hasCurrentUserPart: hasCurrentUserPart(work, currentUserID: currentUserID)
        )
    }

    private func makeWebEntries() -> [JamoProfileWebEntry] {
        [
            JamoProfileWebEntry(kind: .editProfile, title: "Edit Profile", route: .editProfile),
            JamoProfileWebEntry(kind: .following, title: "Following", route: .following),
            JamoProfileWebEntry(kind: .followers, title: "Followers", route: .followers),
            JamoProfileWebEntry(kind: .coins, title: "My gold coins", route: .coins)
        ]
    }

    private func makeEmptyPostsDisplay() -> JamoProfileEmptyPostsDisplay {
        JamoProfileEmptyPostsDisplay(
            title: "No posts yet",
            subtitle: "Your guitar co-create posts will appear here.",
            actionTitle: "Start Co-create"
        )
    }

    private func isCreatedByCurrentUser(_ work: JamoCoCreateWork, currentUserID: String) -> Bool {
        work.creatorUserID == currentUserID
    }

    private func hasCurrentUserPart(_ work: JamoCoCreateWork, currentUserID: String) -> Bool {
        work.tracks.contains { track in
            track.isMine
                && track.ownerUserID == currentUserID
                && track.id.hasPrefix("jamo_track_publish_")
        }
    }

    private func isPublishedByCurrentUser(_ work: JamoCoCreateWork, currentUserID: String) -> Bool {
        guard isCreatedByCurrentUser(work, currentUserID: currentUserID) else {
            return false
        }
        return work.id.hasPrefix("jamo_work_publish_")
            || work.id.hasPrefix("jamo_draft_")
            || hasCurrentUserPart(work, currentUserID: currentUserID)
    }

    private func participantSummary(for work: JamoCoCreateWork, participantCount: Int) -> String {
        switch work.status {
        case .open:
            return "\(participantCount) joined · open to all"
        case .joined:
            return "\(participantCount) joined · your part added"
        case .completed:
            return "\(participantCount) joined · completed"
        case .draft:
            return "Draft saved"
        }
    }

    private func statusTitle(for work: JamoCoCreateWork) -> String {
        switch work.status {
        case .open:
            return "Open"
        case .joined:
            return "Joined"
        case .completed:
            return "Completed"
        case .draft:
            return "Draft"
        }
    }

    private func statusTintHex(for work: JamoCoCreateWork) -> String {
        switch work.status {
        case .open:
            return "#E75B33"
        case .joined:
            return "#FF72A8"
        case .completed:
            return "#5BCE9D"
        case .draft:
            return "#26315E"
        }
    }

    private func actionTitle(for work: JamoCoCreateWork) -> String {
        switch work.status {
        case .open:
            return "Join"
        case .joined:
            return "Joined"
        case .completed:
            return "Completed"
        case .draft:
            return "Draft"
        }
    }

    private func audioDuration(for track: JamoCoCreateTrack?) -> TimeInterval {
        guard let track else { return 0 }
        return JamoLocalJamMediaCatalog.audioDuration(for: track.mp3FileName, fallback: track.duration)
    }

    private func durationText(_ duration: TimeInterval) -> String {
        let seconds = max(Int(duration.rounded()), 0)
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    private func countText(_ value: Int) -> String {
        "\(max(value, 0))"
    }

    private func initials(for displayName: String) -> String {
        let parts = displayName
            .split(separator: " ")
            .map(String.init)
            .filter { !$0.isEmpty }
        let joined = parts.prefix(2).compactMap { $0.first }.map(String.init).joined()
        return joined.isEmpty ? "JP" : joined.uppercased()
    }

    private func normalized(_ value: String?) -> String {
        value?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
    }

    private func clean(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}

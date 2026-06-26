import Foundation

enum JamoCoCreateOutputState: Equatable {
    case openJams
    case empty
    case joinableDetail
    case joinedDetail
    case completedDetail
}

enum JamoCoCreateFilter: String, CaseIterable {
    case openJams
    case popular
    case melodyDrafts

    var title: String {
        switch self {
        case .openJams:
            return "Open Jams"
        case .popular:
            return "Popular"
        case .melodyDrafts:
            return "Melody Drafts"
        }
    }
}

struct JamoCoCreateFilterDisplay: Equatable {
    let filter: JamoCoCreateFilter
    let title: String
    let isSelected: Bool
}

struct JamoCoCreateActionDisplay: Equatable {
    enum Style: Equatable {
        case orange
        case black
        case disabled
    }

    let title: String
    let isEnabled: Bool
    let style: Style
}

struct JamoCoCreateParticipantDisplay: Equatable {
    let userID: String
    let displayName: String
    let initials: String
    let avatarURL: String?
    let colorHex: String
}

struct JamoCoCreatePartDisplay: Equatable {
    enum Style: Equatable {
        case regular
        case mine
        case needed
    }

    let id: String
    let title: String
    let subtitle: String
    let mp3FileName: String?
    let durationText: String
    let waveformSeed: Int
    let style: Style
}

struct JamoCoCreateNeededPartDisplay: Equatable {
    let id: String
    let title: String
    let subtitle: String
    let durationText: String
    let waveformSeed: Int
}

struct JamoCoCreateJoinMethodDisplay: Equatable {
    let method: JamoCoCreateJoinMethod
    let title: String
    let subtitle: String
    let isSelected: Bool
}

struct JamoCoCreateCardDisplay: Equatable {
    let id: String
    let title: String
    let subtitle: String
    let coverImageName: String
    let coverURL: String?
    let tagTitle: String
    let creatorName: String
    let creatorInitials: String
    let creatorAvatarURL: String?
    let participantSummary: String
    let statusTitle: String
    let statusTintHex: String
    let mp3FileName: String?
    let durationText: String
    let waveformSeed: Int
    let action: JamoCoCreateActionDisplay
}

struct JamoCoCreateEmptyDisplay: Equatable {
    let title: String
    let subtitle: String
    let action: JamoCoCreateActionDisplay
}

struct JamoCoCreateListSnapshot: Equatable {
    let state: JamoCoCreateOutputState
    let currentUser: JamoCoCreateUserProfile
    let filters: [JamoCoCreateFilterDisplay]
    let cards: [JamoCoCreateCardDisplay]
    let empty: JamoCoCreateEmptyDisplay?
}

struct JamoCoCreateDetailStateDisplay: Equatable {
    let title: String
    let subtitle: String
    let tintHex: String
}

struct JamoCoCreateDetailSnapshot: Equatable {
    let state: JamoCoCreateOutputState
    let workID: String
    let title: String
    let subtitle: String
    let coverImageName: String
    let coverURL: String?
    let tags: [String]
    let creator: JamoCoCreateParticipantDisplay
    let currentParts: [JamoCoCreatePartDisplay]
    let neededPart: JamoCoCreateNeededPartDisplay?
    let participants: [JamoCoCreateParticipantDisplay]
    let participantSummary: String
    let joinMethods: [JamoCoCreateJoinMethodDisplay]
    let stateDisplay: JamoCoCreateDetailStateDisplay
    let primaryAction: JamoCoCreateActionDisplay
    let secondaryAction: JamoCoCreateActionDisplay?
}

enum JamoCoCreatePublishState: Equatable {
    case editing
    case missingTitle
    case publishing
    case publishFailed
    case publishedSuccess
}

struct JamoCoCreatePublishSourceDisplay: Equatable {
    let workID: String
    let title: String
    let subtitle: String
    let coverImageName: String
    let coverURL: String?
    let partTitle: String
    let durationText: String
    let waveformSeed: Int
}

struct JamoCoCreatePublishForm: Equatable {
    var title: String
    var about: String
    var tags: [String]
    var coverImageName: String
    var coverURL: String?
    var mp3FileName: String
    var duration: TimeInterval
    var waveformSeed: Int
    var roleName: String
    var role: JamoCoCreateTrackRole
    var allowContinue: Bool
    var selectedJoinMethod: JamoCoCreateJoinMethod?
}

struct JamoCoCreatePublishSnapshot: Equatable {
    let state: JamoCoCreatePublishState
    let currentUser: JamoCoCreateUserProfile
    let source: JamoCoCreatePublishSourceDisplay?
    let form: JamoCoCreatePublishForm
    let validationMessage: String?
    let publishedWork: JamoCoCreateWork?
    let primaryAction: JamoCoCreateActionDisplay
}

final class JamoCoCreatePublishViewModel {
    static let missingTitleMessage = "Add a title to publish."
    static let publishFailedMessage = "Please check your connection and try again."

    private let sourceWorkID: String?
    private let authStore: JamoAuthStore
    private let jamStore: JamoLocalJamStore
    private var state: JamoCoCreatePublishState = .editing
    private var form: JamoCoCreatePublishForm
    private var publishedWork: JamoCoCreateWork?
    private var failureMessage: String?

    init(
        sourceWorkID: String? = nil,
        selectedJoinMethod: JamoCoCreateJoinMethod? = nil,
        authStore: JamoAuthStore = .shared,
        jamStore: JamoLocalJamStore = .shared
    ) {
        self.sourceWorkID = sourceWorkID
        self.authStore = authStore
        self.jamStore = jamStore
        self.form = Self.makeInitialForm(sourceWork: sourceWorkID.flatMap { jamStore.work(withID: $0) })
        if let selectedJoinMethod {
            applyInitialJoinMethod(selectedJoinMethod)
        }
    }

    func makeSnapshot() -> JamoCoCreatePublishSnapshot {
        JamoCoCreatePublishSnapshot(
            state: state,
            currentUser: makeCurrentUser(),
            source: sourceWorkID.flatMap { jamStore.work(withID: $0) }.map(makeSourceDisplay),
            form: form,
            validationMessage: validationMessage,
            publishedWork: publishedWork,
            primaryAction: primaryAction
        )
    }

    @discardableResult
    func updateTitle(_ title: String) -> JamoCoCreatePublishSnapshot {
        form.title = title
        if state == .missingTitle && !trimmed(title).isEmpty {
            state = .editing
        }
        return makeSnapshot()
    }

    @discardableResult
    func updateAbout(_ about: String) -> JamoCoCreatePublishSnapshot {
        form.about = about
        return makeSnapshot()
    }

    @discardableResult
    func updateTags(_ tags: [String]) -> JamoCoCreatePublishSnapshot {
        form.tags = normalizedTags(tags)
        return makeSnapshot()
    }

    @discardableResult
    func setTag(_ tag: String, isSelected: Bool) -> JamoCoCreatePublishSnapshot {
        let cleanTag = trimmed(tag)
        guard !cleanTag.isEmpty else { return makeSnapshot() }
        if isSelected {
            form.tags = normalizedTags(form.tags + [cleanTag])
        } else {
            let filtered = form.tags.filter { $0.caseInsensitiveCompare(cleanTag) != .orderedSame }
            form.tags = normalizedTags(filtered)
        }
        return makeSnapshot()
    }

    @discardableResult
    func updateCover(imageName: String, coverURL: String? = nil) -> JamoCoCreatePublishSnapshot {
        form.coverImageName = JamoLocalJamMediaCatalog.normalizedCover(imageName, seed: 8)
        form.coverURL = coverURL
        return makeSnapshot()
    }

    @discardableResult
    func updateLocalAudio(
        mp3FileName: String,
        duration: TimeInterval,
        waveformSeed: Int,
        roleName: String,
        role: JamoCoCreateTrackRole,
        joinMethod: JamoCoCreateJoinMethod?
    ) -> JamoCoCreatePublishSnapshot {
        form.mp3FileName = JamoLocalJamMediaCatalog.normalizedRiff(mp3FileName, seed: 8)
        form.duration = max(duration, 1)
        form.waveformSeed = max(waveformSeed, 1)
        form.roleName = trimmed(roleName).isEmpty ? "Lead Guitar" : roleName
        form.role = role
        form.selectedJoinMethod = joinMethod
        return makeSnapshot()
    }

    @discardableResult
    func updateAllowContinue(_ allowContinue: Bool) -> JamoCoCreatePublishSnapshot {
        form.allowContinue = allowContinue
        return makeSnapshot()
    }

    @discardableResult
    func beginPublishing() -> JamoCoCreatePublishSnapshot {
        guard !trimmed(form.title).isEmpty else {
            state = .missingTitle
            failureMessage = nil
            return makeSnapshot()
        }
        form.tags = normalizedTags(form.tags)
        state = .publishing
        failureMessage = nil
        return makeSnapshot()
    }

    @discardableResult
    func completeLocalPublish() -> JamoCoCreatePublishSnapshot {
        guard !trimmed(form.title).isEmpty else {
            state = .missingTitle
            failureMessage = nil
            return makeSnapshot()
        }
        form.tags = normalizedTags(form.tags)
        let work = jamStore.publishLocalPart(
            sourceWorkID: sourceWorkID,
            title: form.title,
            about: form.about,
            tags: form.tags,
            coverImageName: form.coverImageName,
            coverURL: form.coverURL,
            mp3FileName: form.mp3FileName,
            duration: form.duration,
            waveformSeed: form.waveformSeed,
            roleName: form.roleName,
            role: form.role,
            allowContinue: form.allowContinue,
            selectedJoinMethod: form.selectedJoinMethod
        )
        publishedWork = work
        state = .publishedSuccess
        failureMessage = nil
        return makeSnapshot()
    }

    @discardableResult
    func publishLocally() -> JamoCoCreatePublishSnapshot {
        let publishingSnapshot = beginPublishing()
        guard publishingSnapshot.state == .publishing else {
            return publishingSnapshot
        }
        return completeLocalPublish()
    }

    @discardableResult
    func markPublishFailed(message: String? = nil) -> JamoCoCreatePublishSnapshot {
        state = .publishFailed
        failureMessage = message ?? Self.publishFailedMessage
        return makeSnapshot()
    }

    @discardableResult
    func resetToEditing() -> JamoCoCreatePublishSnapshot {
        state = .editing
        failureMessage = nil
        return makeSnapshot()
    }

    private var validationMessage: String? {
        switch state {
        case .missingTitle:
            return Self.missingTitleMessage
        case .publishFailed:
            return failureMessage ?? Self.publishFailedMessage
        case .editing, .publishing, .publishedSuccess:
            return nil
        }
    }

    private var primaryAction: JamoCoCreateActionDisplay {
        switch state {
        case .editing:
            return JamoCoCreateActionDisplay(title: "Publish", isEnabled: true, style: !trimmed(form.title).isEmpty ? .orange : .disabled)
        case .missingTitle:
            return JamoCoCreateActionDisplay(title: "Publish", isEnabled: false, style: .disabled)
        case .publishing:
            return JamoCoCreateActionDisplay(title: "Publishing...", isEnabled: false, style: .disabled)
        case .publishFailed:
            return JamoCoCreateActionDisplay(title: "Try Again", isEnabled: true, style: .orange)
        case .publishedSuccess:
            return JamoCoCreateActionDisplay(title: "View Work", isEnabled: true, style: .orange)
        }
    }

    private static func makeInitialForm(sourceWork: JamoCoCreateWork?) -> JamoCoCreatePublishForm {
        let sourcePart = sourceWork?.neededPart
        let lastTrack = sourceWork?.tracks.last
        return JamoCoCreatePublishForm(
            title: sourceWork?.status == .draft ? (sourceWork?.title ?? "") : "",
            about: sourceWork?.about ?? "",
            tags: normalizedStaticTags(sourceWork?.tags ?? ["Acoustic", "Lead"]),
            coverImageName: JamoLocalJamMediaCatalog.normalizedCover(sourceWork?.coverImageName ?? "", seed: 8),
            coverURL: nil,
            mp3FileName: JamoLocalJamMediaCatalog.normalizedRiff(sourceWork?.status == .draft ? lastTrack?.mp3FileName ?? "" : "", seed: 8),
            duration: sourcePart?.duration ?? lastTrack?.duration ?? 15,
            waveformSeed: sourcePart?.waveformSeed ?? lastTrack?.waveformSeed ?? 7,
            roleName: sourcePart?.title ?? "Lead Guitar",
            role: sourcePart?.role ?? .leadGuitar,
            allowContinue: sourceWork?.allowContinue ?? true,
            selectedJoinMethod: sourceWork?.selectedJoinMethod ?? .recordGuitar
        )
    }

    private func applyInitialJoinMethod(_ method: JamoCoCreateJoinMethod) {
        form.mp3FileName = JamoLocalJamMediaCatalog.normalizedRiff(method.localMP3FileName, seed: 8)
        form.duration = JamoLocalJamMediaCatalog.audioDuration(
            for: method.localMP3FileName,
            fallback: method == .uploadClip ? 18 : 15
        )
        form.waveformSeed = method == .uploadClip ? 10 : 7
        form.roleName = method.trackTitle
        form.role = method.trackRole
        form.selectedJoinMethod = method
    }

    private static func normalizedStaticTags(_ tags: [String]) -> [String] {
        var seen = Set<String>()
        var normalized: [String] = []
        for tag in tags {
            let clean = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !clean.isEmpty else { continue }
            let key = clean.lowercased()
            guard seen.insert(key).inserted else { continue }
            normalized.append(clean)
        }
        return normalized.isEmpty ? ["Acoustic", "Lead"] : normalized
    }

    private func normalizedTags(_ tags: [String]) -> [String] {
        Self.normalizedStaticTags(tags)
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

    private func makeSourceDisplay(from work: JamoCoCreateWork) -> JamoCoCreatePublishSourceDisplay {
        let sourcePart = work.neededPart
        let track = work.tracks.last
        return JamoCoCreatePublishSourceDisplay(
            workID: work.id,
            title: work.title,
            subtitle: work.about,
            coverImageName: work.coverImageName,
            coverURL: work.coverURL,
            partTitle: sourcePart?.title ?? track?.roleName ?? "Lead Guitar",
            durationText: durationText(sourcePart?.duration ?? track?.duration ?? 15),
            waveformSeed: sourcePart?.waveformSeed ?? track?.waveformSeed ?? 7
        )
    }

    private func durationText(_ duration: TimeInterval) -> String {
        let seconds = max(Int(duration.rounded()), 0)
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

final class JamoCoCreateViewModel {
    private enum LocalActionKey {
        static let blockedWorkIDs = "jamo_cocreate_blocked_work_ids"
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

    func loadOpenJams(
        selectedFilter: JamoCoCreateFilter = .openJams,
        completion: @escaping (JamoCoCreateListSnapshot) -> Void
    ) {
        userProvider.fetchJamUsers { [weak self] result in
            guard let self else { return }
            let users = (try? result.get()) ?? []
            completion(self.makeListSnapshot(selectedFilter: selectedFilter, remoteUsers: users))
        }
    }

    func makeListSnapshot(
        selectedFilter: JamoCoCreateFilter = .openJams,
        remoteUsers: [JamoCoCreateUserProfile] = []
    ) -> JamoCoCreateListSnapshot {
        let currentUser = makeCurrentUser()
        let works = filteredWorks(for: selectedFilter)
        let directory = makeUserDirectory(remoteUsers: effectiveRemoteUsers(remoteUsers), currentUser: currentUser)
        let cards = works.map { makeCard(from: $0, directory: directory) }
        let state: JamoCoCreateOutputState = cards.isEmpty ? .empty : .openJams

        return JamoCoCreateListSnapshot(
            state: state,
            currentUser: currentUser,
            filters: JamoCoCreateFilter.allCases.map {
                JamoCoCreateFilterDisplay(filter: $0, title: $0.title, isSelected: $0 == selectedFilter)
            },
            cards: cards,
            empty: cards.isEmpty ? makeEmptyDisplay() : nil
        )
    }

    func makeSearchSnapshot(
        query: String,
        remoteUsers: [JamoCoCreateUserProfile] = []
    ) -> JamoCoCreateListSnapshot {
        let currentUser = makeCurrentUser()
        let works = searchWorks(matching: query)
        let directory = makeUserDirectory(remoteUsers: effectiveRemoteUsers(remoteUsers), currentUser: currentUser)
        let cards = works.map { makeCard(from: $0, directory: directory) }

        return JamoCoCreateListSnapshot(
            state: cards.isEmpty ? .empty : .openJams,
            currentUser: currentUser,
            filters: [],
            cards: cards,
            empty: cards.isEmpty ? makeSearchEmptyDisplay(query: query) : nil
        )
    }

    func makeDetailSnapshot(
        workID: String,
        selectedJoinMethod: JamoCoCreateJoinMethod? = nil,
        remoteUsers: [JamoCoCreateUserProfile] = []
    ) -> JamoCoCreateDetailSnapshot? {
        guard let work = jamStore.work(withID: workID) else {
            return nil
        }
        let directory = makeUserDirectory(remoteUsers: effectiveRemoteUsers(remoteUsers), currentUser: makeCurrentUser())
        return makeDetail(from: work, selectedJoinMethod: selectedJoinMethod ?? work.selectedJoinMethod, directory: directory)
    }

    func join(workID: String, method: JamoCoCreateJoinMethod) -> JamoCoCreateDetailSnapshot? {
        jamStore.join(workID: workID, method: method)
        return makeDetailSnapshot(workID: workID, selectedJoinMethod: method)
    }

    func work(withID workID: String) -> JamoCoCreateWork? {
        guard !blockedWorkIDs.contains(workID) else { return nil }
        return jamStore.work(withID: workID)
    }

    func blockWork(withID workID: String) {
        let cleanID = workID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanID.isEmpty else { return }
        var ids = blockedWorkIDs
        ids.insert(cleanID)
        defaults.set(Array(ids).sorted(), forKey: LocalActionKey.blockedWorkIDs)
    }

    private func filteredWorks(for filter: JamoCoCreateFilter) -> [JamoCoCreateWork] {
        let works: [JamoCoCreateWork]
        switch filter {
        case .openJams:
            works = jamStore.works(for: .open)
        case .popular:
            works = jamStore.allWorks()
                .filter { $0.status != .draft }
                .sorted { ($0.participantCount ?? 0) > ($1.participantCount ?? 0) }
        case .melodyDrafts:
            works = jamStore.allWorks()
                .filter { $0.tags.contains(where: { $0.localizedCaseInsensitiveContains("melody") }) || $0.status == .draft }
        }
        return visibleWorks(from: works)
    }

    private func searchWorks(matching query: String) -> [JamoCoCreateWork] {
        let allWorks = visibleWorks(from: jamStore.allWorks().sorted { $0.createdAt > $1.createdAt })
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !cleanQuery.isEmpty else {
            return allWorks
        }
        return allWorks.filter { work in
            let searchableText = [
                work.title,
                work.about,
                work.creatorName,
                work.tags.joined(separator: " "),
                work.tracks.map(\.roleName).joined(separator: " ")
            ]
                .joined(separator: " ")
                .lowercased()
            return searchableText.contains(cleanQuery)
        }
    }

    private var blockedWorkIDs: Set<String> {
        Set(defaults.stringArray(forKey: LocalActionKey.blockedWorkIDs) ?? [])
    }

    private func visibleWorks(from works: [JamoCoCreateWork]) -> [JamoCoCreateWork] {
        let blocked = blockedWorkIDs
        guard !blocked.isEmpty else { return works }
        return works.filter { !blocked.contains($0.id) }
    }

    private func makeCard(
        from work: JamoCoCreateWork,
        directory: [String: JamoCoCreateUserProfile]
    ) -> JamoCoCreateCardDisplay {
        let primaryTrack = work.tracks.first
        let creator = participantDisplay(for: work.creatorUserID, name: work.creatorName, avatarURL: work.creatorAvatarURL, directory: directory)
        let primaryDuration = audioDuration(for: primaryTrack)

        return JamoCoCreateCardDisplay(
            id: work.id,
            title: work.title,
            subtitle: work.about,
            coverImageName: work.coverImageName,
            coverURL: work.coverURL,
            tagTitle: work.tags.first ?? "Acoustic",
            creatorName: creator.displayName,
            creatorInitials: creator.initials,
            creatorAvatarURL: creator.avatarURL,
            participantSummary: participantSummary(for: work),
            statusTitle: statusTitle(for: work),
            statusTintHex: statusTintHex(for: work),
            mp3FileName: primaryTrack?.mp3FileName,
            durationText: durationText(primaryDuration),
            waveformSeed: primaryTrack?.waveformSeed ?? 1,
            action: cardAction(for: work)
        )
    }

    private func makeDetail(
        from work: JamoCoCreateWork,
        selectedJoinMethod: JamoCoCreateJoinMethod?,
        directory: [String: JamoCoCreateUserProfile]
    ) -> JamoCoCreateDetailSnapshot {
        let state = detailState(for: work)
        let creator = participantDisplay(for: work.creatorUserID, name: work.creatorName, avatarURL: work.creatorAvatarURL, directory: directory)
        let currentParts = work.tracks.map { makePartDisplay(from: $0, directory: directory) }
        let participants = participantDisplays(for: work, directory: directory)
        let action = primaryAction(for: state, work: work)

        return JamoCoCreateDetailSnapshot(
            state: state,
            workID: work.id,
            title: work.title,
            subtitle: work.about,
            coverImageName: work.coverImageName,
            coverURL: work.coverURL,
            tags: work.tags,
            creator: creator,
            currentParts: currentParts,
            neededPart: work.neededPart.map { makeNeededPartDisplay(from: $0) },
            participants: participants,
            participantSummary: participantSummary(for: work, visiblePartCount: currentParts.count),
            joinMethods: makeJoinMethods(selected: selectedJoinMethod),
            stateDisplay: stateDisplay(for: work, state: state),
            primaryAction: action,
            secondaryAction: nil
        )
    }

    private func detailState(for work: JamoCoCreateWork) -> JamoCoCreateOutputState {
        switch work.status {
        case .open:
            return .joinableDetail
        case .joined, .draft:
            return .joinedDetail
        case .completed:
            return .completedDetail
        }
    }

    private func primaryAction(for state: JamoCoCreateOutputState, work: JamoCoCreateWork) -> JamoCoCreateActionDisplay {
        switch state {
        case .joinableDetail:
            return JamoCoCreateActionDisplay(title: "Join Co-create", isEnabled: true, style: .orange)
        case .joinedDetail:
            return JamoCoCreateActionDisplay(title: "View My Part", isEnabled: true, style: .black)
        case .completedDetail:
            return JamoCoCreateActionDisplay(title: "Completed", isEnabled: false, style: .disabled)
        case .openJams, .empty:
            return JamoCoCreateActionDisplay(title: "Join", isEnabled: false, style: .disabled)
        }
    }

    private func cardAction(for work: JamoCoCreateWork) -> JamoCoCreateActionDisplay {
        switch work.status {
        case .open:
            return JamoCoCreateActionDisplay(title: "Join", isEnabled: true, style: .orange)
        case .joined:
            return JamoCoCreateActionDisplay(title: "Joined", isEnabled: false, style: .black)
        case .draft:
            return JamoCoCreateActionDisplay(title: "Draft", isEnabled: false, style: .disabled)
        case .completed:
            return JamoCoCreateActionDisplay(title: "Completed", isEnabled: false, style: .disabled)
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

    private func stateDisplay(for work: JamoCoCreateWork, state: JamoCoCreateOutputState) -> JamoCoCreateDetailStateDisplay {
        switch state {
        case .joinableDetail:
            return JamoCoCreateDetailStateDisplay(
                title: "Open to join",
                subtitle: "Pick a way to add your guitar layer. Your part will be saved into this co-create.",
                tintHex: statusTintHex(for: work)
            )
        case .joinedDetail:
            return JamoCoCreateDetailStateDisplay(
                title: "You're in this co-create",
                subtitle: "Your guitar part is linked here. Continue when you want to refine or publish another layer.",
                tintHex: statusTintHex(for: work)
            )
        case .completedDetail:
            return JamoCoCreateDetailStateDisplay(
                title: "Co-create completed",
                subtitle: "This jam is locked. You can listen and view every part, but it cannot be joined again.",
                tintHex: statusTintHex(for: work)
            )
        case .openJams, .empty:
            return JamoCoCreateDetailStateDisplay(title: "", subtitle: "", tintHex: "#E75B33")
        }
    }

    private func makePartDisplay(
        from track: JamoCoCreateTrack,
        directory: [String: JamoCoCreateUserProfile]
    ) -> JamoCoCreatePartDisplay {
        let ownerName = directory[track.ownerUserID]?.displayName ?? track.ownerName
        return JamoCoCreatePartDisplay(
            id: track.id,
            title: track.roleName,
            subtitle: track.isMine ? "MY PART" : ownerName,
            mp3FileName: track.mp3FileName,
            durationText: durationText(audioDuration(for: track)),
            waveformSeed: track.waveformSeed,
            style: track.isMine ? .mine : .regular
        )
    }

    private func audioDuration(for track: JamoCoCreateTrack?) -> TimeInterval {
        guard let track else {
            return 0
        }
        return JamoLocalJamMediaCatalog.audioDuration(for: track.mp3FileName, fallback: track.duration)
    }

    private func makeNeededPartDisplay(from part: JamoCoCreateNeededPart) -> JamoCoCreateNeededPartDisplay {
        JamoCoCreateNeededPartDisplay(
            id: part.id,
            title: part.title,
            subtitle: part.subtitle,
            durationText: durationText(part.duration),
            waveformSeed: part.waveformSeed
        )
    }

    private func makeJoinMethods(selected: JamoCoCreateJoinMethod?) -> [JamoCoCreateJoinMethodDisplay] {
        JamoCoCreateJoinMethod.allCases.map { method in
            JamoCoCreateJoinMethodDisplay(
                method: method,
                title: joinMethodTitle(method),
                subtitle: joinMethodSubtitle(method),
                isSelected: method == selected
            )
        }
    }

    private func makeEmptyDisplay() -> JamoCoCreateEmptyDisplay {
        JamoCoCreateEmptyDisplay(
            title: "No open jams yet",
            subtitle: "Start a guitar piece and invite others to join.",
            action: JamoCoCreateActionDisplay(title: "Start Co-create", isEnabled: true, style: .orange)
        )
    }

    private func makeSearchEmptyDisplay(query: String) -> JamoCoCreateEmptyDisplay {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return JamoCoCreateEmptyDisplay(
            title: cleanQuery.isEmpty ? "Search co-create jams" : "No matching jams",
            subtitle: cleanQuery.isEmpty ? "Try a title, player, tag, or part name." : "Try another guitar phrase or tag.",
            action: JamoCoCreateActionDisplay(title: "Start Co-create", isEnabled: true, style: .orange)
        )
    }

    private func makeUserDirectory(
        remoteUsers: [JamoCoCreateUserProfile],
        currentUser: JamoCoCreateUserProfile
    ) -> [String: JamoCoCreateUserProfile] {
        var directory: [String: JamoCoCreateUserProfile] = [:]
        let activeRemoteUsers = remoteUsers.filter { !$0.userID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        activeRemoteUsers.forEach { profile in
            directory[profile.userID] = profile
        }
        seedUserAliases().enumerated().forEach { index, alias in
            guard !activeRemoteUsers.isEmpty else { return }
            directory[alias] = activeRemoteUsers[index % activeRemoteUsers.count]
        }

        directory[currentUser.userID] = currentUser
        directory["current_user"] = currentUser

        return directory
    }

    private func seedUserAliases() -> [String] {
        [
            "jamo_seed_mia",
            "jamo_seed_ava",
            "jamo_seed_leo",
            "jamo_seed_eli",
            "jamo_seed_tom",
            "jamo_seed_noah",
            "jamo_seed_ivy"
        ]
    }

    private func effectiveRemoteUsers(_ remoteUsers: [JamoCoCreateUserProfile]) -> [JamoCoCreateUserProfile] {
        remoteUsers.isEmpty ? userProvider.cachedJamUsers : remoteUsers
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

    private func participantDisplays(
        for work: JamoCoCreateWork,
        directory: [String: JamoCoCreateUserProfile]
    ) -> [JamoCoCreateParticipantDisplay] {
        work.tracks.map {
            participantDisplay(for: $0.ownerUserID, name: $0.ownerName, avatarURL: nil, directory: directory)
        }
    }

    private func participantDisplay(
        for userID: String,
        name: String,
        avatarURL: String?,
        colorHex: String = "#E75B33",
        directory: [String: JamoCoCreateUserProfile]
    ) -> JamoCoCreateParticipantDisplay {
        let profile = directory[userID]
        let displayName = profile?.displayName ?? name
        return JamoCoCreateParticipantDisplay(
            userID: profile?.userID ?? userID,
            displayName: displayName,
            initials: initials(for: displayName),
            avatarURL: profile?.avatarURL ?? avatarURL,
            colorHex: colorHex
        )
    }

    private func participantSummary(for work: JamoCoCreateWork) -> String {
        let count = max(work.participantCount ?? work.participants?.count ?? work.tracks.count, 0)
        return participantSummary(for: work, count: count)
    }

    private func participantSummary(for work: JamoCoCreateWork, visiblePartCount: Int) -> String {
        participantSummary(for: work, count: max(visiblePartCount, 0))
    }

    private func participantSummary(for work: JamoCoCreateWork, count: Int) -> String {
        if count == 0 {
            return "Open to all"
        }
        switch work.status {
        case .completed:
            return "\(count) joined this co-create"
        case .joined:
            return "\(count) joined · your part added"
        case .draft:
            return "Draft saved · ready to publish"
        case .open:
            return "\(count) joined - open to all"
        }
    }

    private func joinMethodTitle(_ method: JamoCoCreateJoinMethod) -> String {
        switch method {
        case .recordGuitar:
            return "Record Guitar"
        case .uploadClip:
            return "Upload Clip"
        case .addChords:
            return "Add Chords"
        case .addMelody:
            return "Add Melody"
        }
    }

    private func joinMethodSubtitle(_ method: JamoCoCreateJoinMethod) -> String {
        switch method {
        case .recordGuitar:
            return "Record your guitar part now"
        case .uploadClip:
            return "Use an existing guitar clip"
        case .addChords:
            return "Add a chord backing part"
        case .addMelody:
            return "Create a melody line"
        }
    }

    private func durationText(_ duration: TimeInterval) -> String {
        let seconds = max(Int(duration.rounded()), 0)
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    private func initials(for displayName: String) -> String {
        let parts = displayName
            .split(separator: " ")
            .map(String.init)
            .filter { !$0.isEmpty }
        let joined = parts.prefix(2).compactMap { $0.first }.map(String.init).joined()
        return joined.isEmpty ? "JP" : joined.uppercased()
    }
}

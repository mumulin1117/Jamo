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
            return JamoRiffStringCipher.restore("OBpxepny YJvacm4sc")
        case .popular:
            return JamoRiffStringCipher.restore("P0oOpAuWlqa3rX")
        case .melodyDrafts:
            return JamoRiffStringCipher.restore("MseXlMoLdByR YDXrzalf4tzsz")
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
    let currentUser: JamoRiffPlayerProfile
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
    let currentUser: JamoRiffPlayerProfile
    let source: JamoCoCreatePublishSourceDisplay?
    let form: JamoCoCreatePublishForm
    let validationMessage: String?
    let publishedWork: JamoCoCreateWork?
    let primaryAction: JamoCoCreateActionDisplay
}

final class JamoCoCreatePublishViewModel {
    static let missingTitleMessage = JamoRiffStringCipher.restore("AudadR 3am 9tdiwtJlted dtKoj HpUuObYlFihsJhh.C")
    static let publishFailedMessage = JamoRiffStringCipher.restore("PJlGeraCsoe1 xcChCeocCkZ Qysowufr7 AcxounsnJe8cathiwoMnr taxngdW St0rKys MargAaBiFnP.N")

    private let sourceWorkID: String?
    private let authStore: JamoRiffIdentityArchive
    private let jamStore: JamoLocalJamStore
    private var state: JamoCoCreatePublishState = .editing
    private var form: JamoCoCreatePublishForm
    private var publishedWork: JamoCoCreateWork?
    private var failureMessage: String?

    init(
        sourceWorkID: String? = nil,
        selectedJoinMethod: JamoCoCreateJoinMethod? = nil,
        authStore: JamoRiffIdentityArchive = .sharedArchive,
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
        form.coverImageName = JamoRiffLocalMediaShelf.normalizedCover(imageName, seed: 8)
        form.coverURL = coverURL
        return makeSnapshot()
    }

    @discardableResult
    func updateLsinnerAio(
        mp3FileName: String,
        duration: TimeInterval,
        waveformSeed: Int,
        roleName: String,
        role: JamoCoCreateTrackRole,
        joinMethod: JamoCoCreateJoinMethod?
    ) -> JamoCoCreatePublishSnapshot {
        form.mp3FileName = JamoRiffLocalMediaShelf.normalizedRiff(mp3FileName, seed: 8)
        form.duration = max(duration, 1)
        form.waveformSeed = max(waveformSeed, 1)
        form.roleName = trimmed(roleName).isEmpty ? JamoRiffStringCipher.restore("L6epaKdr 3GEufi0taaUrj") : roleName
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
            return JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("PTutbglgi9sWhv"), isEnabled: true, style: !trimmed(form.title).isEmpty ? .orange : .disabled)
        case .missingTitle:
            return JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("PBuvbtl1iOsyhD"), isEnabled: false, style: .disabled)
        case .publishing:
            return JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("P8u3bGlliXsAhPibn4gj.J.n.G"), isEnabled: false, style: .disabled)
        case .publishFailed:
            return JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("TKrbyE uAOgBaeifnc"), isEnabled: true, style: .orange)
        case .publishedSuccess:
            return JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("VjiyeGwe tWXoSrpkI"), isEnabled: true, style: .orange)
        }
    }

    private static func makeInitialForm(sourceWork: JamoCoCreateWork?) -> JamoCoCreatePublishForm {
        let sourcePart = sourceWork?.neededPart
        let lastTrack = sourceWork?.tracks.last
        return JamoCoCreatePublishForm(
            title: sourceWork?.status == .draft ? (sourceWork?.title ?? "") : "",
            about: sourceWork?.about ?? "",
            tags: normalizedStaticTags(sourceWork?.tags ?? [JamoRiffStringCipher.restore("A2cqoXu0sztQiJcR"), JamoRiffStringCipher.restore("LzeJaAdu")]),
            coverImageName: JamoRiffLocalMediaShelf.normalizedCover(sourceWork?.coverImageName ?? "", seed: 8),
            coverURL: nil,
            mp3FileName: JamoRiffLocalMediaShelf.normalizedRiff(sourceWork?.status == .draft ? lastTrack?.mp3FileName ?? "" : "", seed: 8),
            duration: sourcePart?.duration ?? lastTrack?.duration ?? 15,
            waveformSeed: sourcePart?.waveformSeed ?? lastTrack?.waveformSeed ?? 7,
            roleName: sourcePart?.title ?? JamoRiffStringCipher.restore("LjeqaWd3 HGruqiCtua3rQ"),
            role: sourcePart?.role ?? .leadGuitar,
            allowContinue: sourceWork?.allowContinue ?? true,
            selectedJoinMethod: sourceWork?.selectedJoinMethod ?? .recordGuitar
        )
    }

    private func applyInitialJoinMethod(_ method: JamoCoCreateJoinMethod) {
        form.mp3FileName = JamoRiffLocalMediaShelf.normalizedRiff(method.localMP3FileName, seed: 8)
        form.duration = JamoRiffLocalMediaShelf.audioDuration(
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
        return normalized.isEmpty ? [JamoRiffStringCipher.restore("ALc7o6uTsLtjiJcS"), JamoRiffStringCipher.restore("LaeEajdC")] : normalized
    }

    private func normalizedTags(_ tags: [String]) -> [String] {
        Self.normalizedStaticTags(tags)
    }

    private func makeCurrentUser() -> JamoRiffPlayerProfile {
        let email = authStore.currentEmail ?? JamoRiffStringCipher.restore("lSo2cwa9lv@DjxaPmLos.6aBpppd")
        return JamoRiffPlayerProfile(
            userRiggID: authStore.currentUserID ?? JamoRiffStringCipher.restore("jYa4mHo6_HlMoMc5a3lA_npQllaLyDehrs"),
            displayName: authStore.currentDisplayName ?? authStore.displayNameFallback(for: email),
            emaRiggil: email,
            userRiGGtarURL: authStore.currentAvatarURL
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
            partTitle: sourcePart?.title ?? track?.roleName ?? JamoRiffStringCipher.restore("LQeIaEdJ MGbuciIt1aGr4"),
            durationText: durationText(sourcePart?.duration ?? track?.duration ?? 15),
            waveformSeed: sourcePart?.waveformSeed ?? track?.waveformSeed ?? 7
        )
    }

    private func durationText(_ duration: TimeInterval) -> String {
        let seconds = max(Int(duration.rounded()), 0)
        return String(format: JamoRiffStringCipher.restore("%vd4:X%d0O2WdH"), seconds / 60, seconds % 60)
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

final class JamoCoCreateViewModel {
    private enum LocalActionKey {
        static let blockedWorkIDs = JamoRiffStringCipher.restore("jEapmyok_rcGokcJrUexaotoeT_eb4lqoecukie8db_tw1osrekd_BiqdTs4")
    }

    private let authStore: JamoRiffIdentityArchive
    private let jamStore: JamoLocalJamStore
    private let userProvider: JamoCoCreateUserProviding
    private let defaults: UserDefaults

    init(
        authStore: JamoRiffIdentityArchive = .sharedArchive,
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
        remoteUsers: [JamoRiffPlayerProfile] = []
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
        remoteUsers: [JamoRiffPlayerProfile] = []
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
        remoteUsers: [JamoRiffPlayerProfile] = []
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
                .filter { $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(JamoRiffStringCipher.restore("mveellobdyym")) }) || $0.status == .draft }
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
                work.tags.joined(separator: JamoRiffStringCipher.restore(" x")),
                work.tracks.map(\.roleName).joined(separator: JamoRiffStringCipher.restore(" P"))
            ]
                .joined(separator: JamoRiffStringCipher.restore(" Y"))
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
        directory: [String: JamoRiffPlayerProfile]
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
            tagTitle: work.tags.first ?? JamoRiffStringCipher.restore("AdcIoSuAsLtkiOcQ"),
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
        directory: [String: JamoRiffPlayerProfile]
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
            return JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("JvobiRnL OCxoz-fcXrieqaZtoeo"), isEnabled: true, style: .orange)
        case .joinedDetail:
            return JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("VriWeowL 5M8yh EPmaarbt1"), isEnabled: true, style: .black)
        case .completedDetail:
            return JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("CtoKmfp9lIeot5eNdU"), isEnabled: false, style: .disabled)
        case .openJams, .empty:
            return JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("JBoyiLns"), isEnabled: false, style: .disabled)
        }
    }

    private func cardAction(for work: JamoCoCreateWork) -> JamoCoCreateActionDisplay {
        switch work.status {
        case .open:
            return JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("JIoxi9nM"), isEnabled: true, style: .orange)
        case .joined:
            return JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("Jvohi3n2eFdb"), isEnabled: false, style: .black)
        case .draft:
            return JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("DZrTaTf5tf"), isEnabled: false, style: .disabled)
        case .completed:
            return JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("CXolm3pblZeWtKeBdT"), isEnabled: false, style: .disabled)
        }
    }

    private func statusTitle(for work: JamoCoCreateWork) -> String {
        switch work.status {
        case .open:
            return JamoRiffStringCipher.restore("OppXeUnu")
        case .joined:
            return JamoRiffStringCipher.restore("JEoBisnLe1dr")
        case .completed:
            return JamoRiffStringCipher.restore("CBoTm7p9lPe5tHeRdX")
        case .draft:
            return JamoRiffStringCipher.restore("D0r4aZfTtO")
        }
    }

    private func statusTintHex(for work: JamoCoCreateWork) -> String {
        switch work.status {
        case .open:
            return JamoRiffStringCipher.restore("#sEr7w5OBC3P3L")
        case .joined:
            return JamoRiffStringCipher.restore("#JFkFu7D2xAH8I")
        case .completed:
            return JamoRiffStringCipher.restore("#r5SBwChEO9GDe")
        case .draft:
            return JamoRiffStringCipher.restore("#c2P6F3w1I5XEr")
        }
    }

    private func stateDisplay(for work: JamoCoCreateWork, state: JamoCoCreateOutputState) -> JamoCoCreateDetailStateDisplay {
        switch state {
        case .joinableDetail:
            return JamoCoCreateDetailStateDisplay(
                title: JamoRiffStringCipher.restore("Otpdeqn4 CtWoQ sjXociknJ"),
                subtitle: JamoRiffStringCipher.restore("Phi5c8kJ 7ac qwhaqyU LtQof iaOdBdg yy3oEuOr9 qg9uribt7aPrd El6asymeArL.R AYQoouXrU NpNaxr6ta Uwvidl1l5 Ebwep gs3avvgeKda tiSnmtKos ZtHhqiOs1 Yc4oC-acgrTefactKeH.1"),
                tintHex: statusTintHex(for: work)
            )
        case .joinedDetail:
            return JamoCoCreateDetailStateDisplay(
                title: JamoRiffStringCipher.restore("YYoBuT'krceK LiNnD MtNhaiDsJ Dcloh-rcOrleMa2t8eU"),
                subtitle: JamoRiffStringCipher.restore("YloduZrK vgIuwibtPaprE HpYaer5tN IiQsP xliiHnOkzecdQ BhNeXrueS.F kCPo3ngtYiinluIee xwih6e3na MyloguI 5wZannctw ZtkoX Tr4eBfPiXn0ey logrO ApmuvbSlqiSsshB Kapnbo0tshfePr3 wlJa0yle8rl.1"),
                tintHex: statusTintHex(for: work)
            )
        case .completedDetail:
            return JamoCoCreateDetailStateDisplay(
                title: JamoRiffStringCipher.restore("CGo0-4cKrAeBaut4eC 5cfoTm1prlpe6trefds"),
                subtitle: JamoRiffStringCipher.restore("T3hhiNsV gjNaYmh wiDs5 SlzoscUkVefdj.4 5Y3oDut IcraFnT Olhi1sGtaeDnN TamnHd9 7vxibewwC 8eWvLerryyw 4pMahrjtG,i QbNuRtg FiTt0 tcta6ntnGoOtr pbjeK 7j9oYiSn7eYdG 6azgXaxi2nU.b"),
                tintHex: statusTintHex(for: work)
            )
        case .openJams, .empty:
            return JamoCoCreateDetailStateDisplay(title: "", subtitle: "", tintHex: JamoRiffStringCipher.restore("#NEs7S58BF3o3L"))
        }
    }

    private func makePartDisplay(
        from track: JamoCoCreateTrack,
        directory: [String: JamoRiffPlayerProfile]
    ) -> JamoCoCreatePartDisplay {
        let ownerName = directory[track.ownerUserID]?.displayName ?? track.ownerName
        return JamoCoCreatePartDisplay(
            id: track.id,
            title: track.roleName,
            subtitle: track.isMine ? JamoRiffStringCipher.restore("MMYg fPNAFRUTN") : ownerName,
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
        return JamoRiffLocalMediaShelf.audioDuration(for: track.mp3FileName, fallback: track.duration)
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
            title: JamoRiffStringCipher.restore("NZoI 0oYpkewn2 MjIaAmxse 5ypeptu"),
            subtitle: JamoRiffStringCipher.restore("SWt4anrPth day PgUu0iqtTa0r4 Ip6iseBcLe6 vaZnkdg OicnevSiXtbeH Ho9tihQeErssw DtAoT djooAiVnl.b"),
            action: JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("SstiaIrvtM eCooh-6cFrEenaqtLeA"), isEnabled: true, style: .orange)
        )
    }

    private func makeSearchEmptyDisplay(query: String) -> JamoCoCreateEmptyDisplay {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return JamoCoCreateEmptyDisplay(
            title: cleanQuery.isEmpty ? JamoRiffStringCipher.restore("SzebayrmcdhB zccoJ-ocWrke8aSthe9 Tj4aCmvss") : JamoRiffStringCipher.restore("NcoL 1mmaVtYcchtipnYgh VjPasmHsk"),
            subtitle: cleanQuery.isEmpty ? JamoRiffStringCipher.restore("TOrwyd BaN MtOictLlUeU,y upblPa0yreqrL,r PtjawgB,B eoZrU spOanrJtB nnnaAmYeP.o") : JamoRiffStringCipher.restore("Ttreyy ra5nXoftKhkeGrD tgMuziJtjaTrH SpEhurBa4sse8 Tour3 0tgamgm.1"),
            action: JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("S7tIaorZtT WCUof-vcGrNeOa4tIe0"), isEnabled: true, style: .orange)
        )
    }

    private func makeUserDirectory(
        remoteUsers: [JamoRiffPlayerProfile],
        currentUser: JamoRiffPlayerProfile
    ) -> [String: JamoRiffPlayerProfile] {
        var directory: [String: JamoRiffPlayerProfile] = [:]
        let activeRemoteUsers = remoteUsers.filter { !$0.userRiggID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        activeRemoteUsers.forEach { profile in
            directory[profile.userRiggID] = profile
        }
        seedUserAliases().enumerated().forEach { index, alias in
            guard !activeRemoteUsers.isEmpty else { return }
            directory[alias] = activeRemoteUsers[index % activeRemoteUsers.count]
        }

        directory[currentUser.userRiggID] = currentUser
        directory[JamoRiffStringCipher.restore("c6uKrorxeFn2tL_5uNsseorY")] = currentUser

        return directory
    }

    private func seedUserAliases() -> [String] {
        [
            JamoRiffStringCipher.restore("jyalmfo8_YskeOeZdO_Lmyi3aH"),
            JamoRiffStringCipher.restore("j2ahmJo8_hsceyegdB_1a9vHaY"),
            JamoRiffStringCipher.restore("jha9m6op_csceYehdC_ClHeUoQ"),
            JamoRiffStringCipher.restore("jLafm1op_xsJeheodE_feLlSi4"),
            JamoRiffStringCipher.restore("jUa1maoq_rs0eNeAdF_Vt6oOmN"),
            JamoRiffStringCipher.restore("jPaBm4ow_ksZeXe5dX_vnQoJaThu"),
            JamoRiffStringCipher.restore("jaadm3o6_qsVeEeOdN_Yi7v9yn")
        ]
    }

    private func effectiveRemoteUsers(_ remoteUsers: [JamoRiffPlayerProfile]) -> [JamoRiffPlayerProfile] {
        remoteUsers.isEmpty ? userProvider.cachedJamUsers : remoteUsers
    }

    private func makeCurrentUser() -> JamoRiffPlayerProfile {
        let email = authStore.currentEmail ?? JamoRiffStringCipher.restore("lUoycuaVlf@ljdaXmJoA.WaNpFpd")
        return JamoRiffPlayerProfile(
            userRiggID: authStore.currentUserID ?? JamoRiffStringCipher.restore("jga6mnoi_Pl4o6cRaWlE_PpklIaGyDearU"),
            displayName: authStore.currentDisplayName ?? authStore.displayNameFallback(for: email),
            emaRiggil: email,
            userRiGGtarURL: authStore.currentAvatarURL
        )
    }

    private func participantDisplays(
        for work: JamoCoCreateWork,
        directory: [String: JamoRiffPlayerProfile]
    ) -> [JamoCoCreateParticipantDisplay] {
        work.tracks.map {
            participantDisplay(for: $0.ownerUserID, name: $0.ownerName, avatarURL: nil, directory: directory)
        }
    }

    private func participantDisplay(
        for userID: String,
        name: String,
        avatarURL: String?,
        colorHex: String = JamoRiffStringCipher.restore("#zEo715tBS3D3D"),
        directory: [String: JamoRiffPlayerProfile]
    ) -> JamoCoCreateParticipantDisplay {
        let profile = directory[userID]
        let displayName = profile?.displayName ?? name
        return JamoCoCreateParticipantDisplay(
            userID: profile?.userRiggID ?? userID,
            displayName: displayName,
            initials: initials(for: displayName),
            avatarURL: profile?.userRiGGtarURL ?? avatarURL,
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
            return JamoRiffStringCipher.restore("OupZeGn0 ct8oe SaelalU")
        }
        switch work.status {
        case .completed:
            return String(count) + JamoRiffStringCipher.restore("jXo6iPnseUdz 9tchbiasY 8c2o9-tcNrZedaqtjeY")
        case .joined:
            return String(count) + JamoRiffStringCipher.restore("jioCian6eYdT D·l byAoquorD KpHaMrHtn ia8dZdbegdC")
        case .draft:
            return JamoRiffStringCipher.restore("DcroaEfOtl CsKabvqeGdY X·m ZrJe4aud1yI htloD 5puuEbLlJidsjhg")
        case .open:
            return String(count) + JamoRiffStringCipher.restore("jCodiUnOegdV b-1 SoSpfemnH QtTog Aa0lFlc")
        }
    }

    private func joinMethodTitle(_ method: JamoCoCreateJoinMethod) -> String {
        switch method {
        case .recordGuitar:
            return JamoRiffStringCipher.restore("RMeMclovr5di UGEuvi9tyawr1")
        case .uploadClip:
            return JamoRiffStringCipher.restore("UnpJl8oUaddl 4C9lqi0pG")
        case .addChords:
            return JamoRiffStringCipher.restore("AsdkdO LCihMoarJdGsf")
        case .addMelody:
            return JamoRiffStringCipher.restore("A0dJdN 9MgeflAo9dwyT")
        }
    }

    private func joinMethodSubtitle(_ method: JamoCoCreateJoinMethod) -> String {
        switch method {
        case .recordGuitar:
            return JamoRiffStringCipher.restore("RxeDcnoarodo HynoEuJrD MgpuzictPa4rT vp1arrHtv DnGoEwN")
        case .uploadClip:
            return JamoRiffStringCipher.restore("UqsjeW oasn6 ceOxOiKsmtcirn7gw DgguPi7tQaMrc fc7l8i5p4")
        case .addChords:
            return JamoRiffStringCipher.restore("ADdmdG bax YcjhToxr8de 3b8a7cukNiQnhgy apIaUr9tE")
        case .addMelody:
            return JamoRiffStringCipher.restore("CMrbeiaDt3eQ GaK tm9enluokdUyL GltirnFer")
        }
    }

    private func durationText(_ duration: TimeInterval) -> String {
        let seconds = max(Int(duration.rounded()), 0)
        return String(format: JamoRiffStringCipher.restore("%2dl:H%p0z2ndR"), seconds / 60, seconds % 60)
    }

    private func initials(for displayName: String) -> String {
        let parts = displayName
            .components(separatedBy: JamoRiffStringCipher.restore(" d"))
            .filter { !$0.isEmpty }
        let joined = parts.prefix(2).compactMap { $0.first }.map(String.init).joined()
        return joined.isEmpty ? JamoRiffStringCipher.restore("JwPY") : joined.uppercased()
    }
}

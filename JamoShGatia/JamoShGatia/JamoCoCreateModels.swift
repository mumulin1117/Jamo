import AVFoundation
import Foundation

enum JamoLocalJamMediaCatalog {
    private static let coverCount = 29
    private static let riffCount = 11
    private static let localCoverPrefix = "jamo_cocreate_local_cover_"
    private static let localAudioPrefix = "jamo_cocreate_local_audio_"

    static func cover(_ index: Int) -> String {
        "jamo_cocreate_local_cover_\(padded(index, count: coverCount)).jpg"
    }

    static func riff(_ index: Int) -> String {
        "jamo_cocreate_local_riff_\(padded(index, count: riffCount)).mp3"
    }

    static func normalizedCover(_ value: String, seed: Int) -> String {
        let clean = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isLocalCover(clean) else {
            return cover(seed)
        }
        return (clean as NSString).lastPathComponent
    }

    static func normalizedRiff(_ value: String, seed: Int) -> String {
        let clean = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isLocalRiff(clean) || isLocalAudio(clean) else {
            return riff(seed)
        }
        return (clean as NSString).lastPathComponent
    }

    static func resourceURL(named name: String) -> URL? {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return nil }

        if let fileURL = URL(string: clean), fileURL.isFileURL, FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        }

        if clean.hasPrefix("/"), FileManager.default.fileExists(atPath: clean) {
            return URL(fileURLWithPath: clean)
        }

        if let directURL = Bundle.main.resourceURL?.appendingPathComponent(clean),
           FileManager.default.fileExists(atPath: directURL.path) {
            return directURL
        }

        let fileName = (clean as NSString).lastPathComponent
        if let localURL = localMediaURL(fileName: fileName) {
            return localURL
        }

        let fileBase = (fileName as NSString).deletingPathExtension
        let fileExtension = (fileName as NSString).pathExtension
        guard !fileBase.isEmpty, !fileExtension.isEmpty else { return nil }
        return Bundle.main.url(forResource: fileBase, withExtension: fileExtension)
    }

    static func audioDuration(for mp3FileName: String, fallback: TimeInterval) -> TimeInterval {
        guard let url = resourceURL(named: mp3FileName) else {
            return fallback
        }
        let asset = AVURLAsset(url: url)
        let seconds = CMTimeGetSeconds(asset.duration)
        guard seconds.isFinite, seconds > 0 else {
            return fallback
        }
        return seconds
    }

    private static func isLocalCover(_ value: String) -> Bool {
        (value as NSString).lastPathComponent.hasPrefix(localCoverPrefix)
    }

    private static func isLocalRiff(_ value: String) -> Bool {
        (value as NSString).lastPathComponent.hasPrefix("jamo_cocreate_local_riff_")
    }

    private static func isLocalAudio(_ value: String) -> Bool {
        (value as NSString).lastPathComponent.hasPrefix(localAudioPrefix)
    }

    private static func localMediaURL(fileName: String) -> URL? {
        guard let documents = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) else { return nil }

        let cacheDirectories = ["JamoCoCreateCoverCache", "JamoCoCreateAudioCache"]
        for directoryName in cacheDirectories {
            let url = documents.appendingPathComponent(directoryName, isDirectory: true).appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }
        return nil
    }

    private static func padded(_ index: Int, count: Int) -> String {
        let wrapped = ((max(index, 1) - 1) % count) + 1
        return String(format: "%02d", wrapped)
    }
}

enum JamoCoCreateTrackRole: String, Codable {
    case originalGuitar
    case rhythmTrack
    case leadGuitar
    case chords
    case melody
    case backingTrack
    case draftRiff
}

enum JamoCoCreateJoinMethod: String, Codable, CaseIterable {
    case recordGuitar
    case uploadClip
    case addChords
    case addMelody

    var trackRole: JamoCoCreateTrackRole {
        switch self {
        case .recordGuitar, .uploadClip:
            return .leadGuitar
        case .addChords:
            return .chords
        case .addMelody:
            return .melody
        }
    }

    var trackTitle: String {
        switch self {
        case .recordGuitar:
            return "Lead Guitar"
        case .uploadClip:
            return "Uploaded Guitar"
        case .addChords:
            return "Chord Backing"
        case .addMelody:
            return "Melody Line"
        }
    }

    var localMP3FileName: String {
        switch self {
        case .recordGuitar:
            return JamoLocalJamMediaCatalog.riff(8)
        case .uploadClip:
            return JamoLocalJamMediaCatalog.riff(9)
        case .addChords:
            return JamoLocalJamMediaCatalog.riff(10)
        case .addMelody:
            return JamoLocalJamMediaCatalog.riff(11)
        }
    }
}

struct JamoCoCreateNeededPart: Codable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let role: JamoCoCreateTrackRole
    let duration: TimeInterval
    let waveformSeed: Int
}

struct JamoCoCreateParticipant: Codable, Hashable {
    let userID: String
    let displayName: String
    let avatarURL: String?
    let colorHex: String
}

enum JamoCoCreateStatus: String, Codable {
    case open
    case joined
    case completed
    case draft
}

struct JamoCoCreateTrack: Codable, Hashable {
    let id: String
    let ownerUserID: String
    let ownerName: String
    let roleName: String
    let mp3FileName: String
    let duration: TimeInterval
    let waveformSeed: Int
    let isMine: Bool
    var role: JamoCoCreateTrackRole? = nil
}

struct JamoCoCreateWork: Codable, Hashable {
    let id: String
    var title: String
    var about: String
    var coverImageName: String
    var creatorUserID: String
    var creatorName: String
    var creatorAvatarURL: String?
    var tags: [String]
    var status: JamoCoCreateStatus
    var allowContinue: Bool
    var createdAt: Date
    var tracks: [JamoCoCreateTrack]
    var coverURL: String? = nil
    var participantCount: Int? = nil
    var participants: [JamoCoCreateParticipant]? = nil
    var neededPart: JamoCoCreateNeededPart? = nil
    var selectedJoinMethod: JamoCoCreateJoinMethod? = nil
}

final class JamoLocalJamStore {
    static let shared = JamoLocalJamStore()

    private enum Key {
        static let works = "jamo_local_co_create_works"
    }

    private let defaults: UserDefaults
    private let authStore: JamoAuthStore

    private init(defaults: UserDefaults = .standard, authStore: JamoAuthStore = .shared) {
        self.defaults = defaults
        self.authStore = authStore
    }

    func allWorks() -> [JamoCoCreateWork] {
        let stored = loadStoredWorks()
        if stored.isEmpty {
            let seeded = seedWorks()
            save(works: seeded)
            return mergedWithCurrentUser(seeded)
        }
        let normalized = ensureOpenJam(in: normalizedWorks(stored))
        if normalized != stored {
            save(works: normalized)
        }
        return mergedWithCurrentUser(normalized)
    }

    func works(for status: JamoCoCreateStatus) -> [JamoCoCreateWork] {
        allWorks().filter { $0.status == status }
    }

    func saveDraft(title: String, about: String, allowContinue: Bool) {
        var current = loadStoredWorks()
        let player = currentPlayer()
        let draft = JamoCoCreateWork(
            id: "jamo_draft_\(Int(Date().timeIntervalSince1970))",
            title: title.isEmpty ? "Untitled Guitar Idea" : title,
            about: about,
            coverImageName: JamoLocalJamMediaCatalog.cover(6),
            creatorUserID: player.userID,
            creatorName: player.name,
            creatorAvatarURL: player.avatarURL,
            tags: ["Draft", "Guitar"],
            status: .draft,
            allowContinue: allowContinue,
            createdAt: Date(),
            tracks: [
                JamoCoCreateTrack(
                    id: "jamo_track_local_draft",
                    ownerUserID: player.userID,
                    ownerName: player.name,
                    roleName: "Starter riff",
                    mp3FileName: JamoLocalJamMediaCatalog.riff(6),
                    duration: 15,
                    waveformSeed: 4,
                    isMine: true,
                    role: .draftRiff
                )
            ],
            coverURL: nil,
            participantCount: 1,
            participants: [currentParticipant()],
            neededPart: allowContinue ? JamoCoCreateNeededPart(
                id: "jamo_need_\(Int(Date().timeIntervalSince1970))",
                title: "Lead Guitar",
                subtitle: "Add a 15s lead guitar part",
                role: .leadGuitar,
                duration: 15,
                waveformSeed: 7
            ) : nil,
            selectedJoinMethod: nil
        )
        current.insert(draft, at: 0)
        save(works: current)
    }

    func updateDraft(workID: String, title: String, about: String, allowContinue: Bool) {
        var current = normalizedWorks(loadStoredWorks())
        guard let index = current.firstIndex(where: { $0.id == workID && $0.status == .draft }) else {
            saveDraft(title: title, about: about, allowContinue: allowContinue)
            return
        }
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAbout = about.trimmingCharacters(in: .whitespacesAndNewlines)
        current[index].title = trimmedTitle.isEmpty ? current[index].title : trimmedTitle
        current[index].about = trimmedAbout.isEmpty ? current[index].about : trimmedAbout
        current[index].allowContinue = allowContinue
        current[index].createdAt = Date()
        save(works: current)
    }

    @discardableResult
    func publishLocalPart(
        sourceWorkID: String?,
        title: String,
        about: String,
        tags: [String],
        coverImageName: String,
        coverURL: String?,
        mp3FileName: String,
        duration: TimeInterval,
        waveformSeed: Int,
        roleName: String,
        role: JamoCoCreateTrackRole,
        allowContinue: Bool,
        selectedJoinMethod: JamoCoCreateJoinMethod?
    ) -> JamoCoCreateWork {
        var current = normalizedWorks(loadStoredWorks())
        let player = currentPlayer()
        let participant = currentParticipant()
        let publishedAt = Date()
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanAbout = about.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanCoverName = coverImageName.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeCoverName = JamoLocalJamMediaCatalog.normalizedCover(cleanCoverName, seed: 7)
        let safeTags = normalizedPublishTags(tags)
        let safeDuration = max(duration, 1)
        let safeWaveformSeed = max(waveformSeed, 1)
        let safeRoleName = roleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Lead Guitar" : roleName
        let safeMP3FileName = JamoLocalJamMediaCatalog.normalizedRiff(mp3FileName, seed: 7)
        let trackID = "jamo_track_publish_\(UUID().uuidString)"
        let publishedTrack = JamoCoCreateTrack(
            id: trackID,
            ownerUserID: player.userID,
            ownerName: player.name,
            roleName: safeRoleName,
            mp3FileName: safeMP3FileName,
            duration: safeDuration,
            waveformSeed: safeWaveformSeed,
            isMine: true,
            role: role
        )

        if let sourceWorkID,
           let index = current.firstIndex(where: { $0.id == sourceWorkID }) {
            let sourceWasDraft = current[index].status == .draft
            current[index].title = cleanTitle.isEmpty ? current[index].title : cleanTitle
            current[index].about = cleanAbout
            current[index].coverImageName = safeCoverName
            current[index].coverURL = coverURL
            current[index].tags = safeTags
            current[index].allowContinue = allowContinue
            current[index].createdAt = publishedAt
            current[index].selectedJoinMethod = selectedJoinMethod

            if sourceWasDraft {
                current[index].creatorUserID = player.userID
                current[index].creatorName = player.name
                current[index].creatorAvatarURL = player.avatarURL
                current[index].tracks = [publishedTrack]
                current[index].participants = [participant]
            } else if let mineIndex = current[index].tracks.firstIndex(where: { $0.isMine && $0.ownerUserID == player.userID }) {
                current[index].tracks[mineIndex] = publishedTrack
                current[index].participants = mergedParticipants(for: current[index], adding: participant)
            } else {
                current[index].tracks.append(publishedTrack)
                current[index].participants = mergedParticipants(for: current[index], adding: participant)
            }

            current[index].participantCount = max(current[index].participantCount ?? 0, current[index].participants?.count ?? 0, current[index].tracks.count)
            current[index].status = allowContinue ? (sourceWasDraft ? .open : .joined) : .completed
            current[index].neededPart = allowContinue ? defaultNeededPart(for: current[index]) : nil
            let published = current[index]
            save(works: current)
            return mergedWithCurrentUser([published]).first ?? published
        }

        let workID = "jamo_work_publish_\(UUID().uuidString)"
        var published = JamoCoCreateWork(
            id: workID,
            title: cleanTitle.isEmpty ? "Untitled Guitar Idea" : cleanTitle,
            about: cleanAbout,
            coverImageName: safeCoverName,
            creatorUserID: player.userID,
            creatorName: player.name,
            creatorAvatarURL: player.avatarURL,
            tags: safeTags,
            status: allowContinue ? .open : .completed,
            allowContinue: allowContinue,
            createdAt: publishedAt,
            tracks: [publishedTrack],
            coverURL: coverURL,
            participantCount: 1,
            participants: [participant],
            neededPart: nil,
            selectedJoinMethod: selectedJoinMethod
        )
        published.neededPart = allowContinue ? defaultNeededPart(for: published) : nil
        current.insert(published, at: 0)
        save(works: current)
        return published
    }

    func work(withID workID: String) -> JamoCoCreateWork? {
        allWorks().first { $0.id == workID }
    }

    func join(workID: String) {
        join(workID: workID, method: .recordGuitar)
    }

    func join(workID: String, method: JamoCoCreateJoinMethod) {
        var current = normalizedWorks(loadStoredWorks())
        guard let index = current.firstIndex(where: { $0.id == workID }) else { return }
        let player = currentPlayer()
        let part = current[index].neededPart
        if !current[index].tracks.contains(where: { $0.isMine }) {
            current[index].tracks.append(
                JamoCoCreateTrack(
                    id: "jamo_track_\(workID)_mine",
                    ownerUserID: player.userID,
                    ownerName: player.name,
                    roleName: part?.title ?? method.trackTitle,
                    mp3FileName: method.localMP3FileName,
                    duration: part?.duration ?? 15,
                    waveformSeed: part?.waveformSeed ?? 7,
                    isMine: true,
                    role: part?.role ?? method.trackRole
                )
            )
        }
        current[index].selectedJoinMethod = method
        current[index].participants = mergedParticipants(for: current[index], adding: currentParticipant())
        current[index].participantCount = max(current[index].participantCount ?? 0, current[index].participants?.count ?? 0)
        current[index].status = .joined
        save(works: current)
    }

    private func currentPlayer() -> (userID: String, name: String, avatarURL: String?) {
        let email = authStore.currentEmail ?? "local@jamo.app"
        return (
            authStore.currentUserID ?? "jamo_local_player",
            authStore.currentDisplayName ?? authStore.displayNameFallback(for: email),
            authStore.currentAvatarURL
        )
    }

    private func currentParticipant() -> JamoCoCreateParticipant {
        let player = currentPlayer()
        return JamoCoCreateParticipant(
            userID: player.userID,
            displayName: player.name,
            avatarURL: player.avatarURL,
            colorHex: "#FF72A8"
        )
    }

    private func mergedParticipants(
        for work: JamoCoCreateWork,
        adding participant: JamoCoCreateParticipant
    ) -> [JamoCoCreateParticipant] {
        var current = work.participants ?? []
        guard !current.contains(where: { $0.userID == participant.userID }) else {
            return current
        }
        current.append(participant)
        return current
    }

    private func normalizedPublishTags(_ tags: [String]) -> [String] {
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

    private func normalizedWorks(_ works: [JamoCoCreateWork]) -> [JamoCoCreateWork] {
        works.enumerated().map { index, work in
            var copy = work
            let player = currentPlayer()
            let mediaSeed = index + 1
            copy.coverImageName = JamoLocalJamMediaCatalog.normalizedCover(copy.coverImageName, seed: mediaSeed)
            copy.coverURL = nil
            copy.tracks = copy.tracks.enumerated().map { trackIndex, track in
                JamoCoCreateTrack(
                    id: track.id,
                    ownerUserID: track.ownerUserID,
                    ownerName: track.ownerName,
                    roleName: track.roleName,
                    mp3FileName: JamoLocalJamMediaCatalog.normalizedRiff(track.mp3FileName, seed: mediaSeed + trackIndex),
                    duration: track.duration,
                    waveformSeed: track.waveformSeed,
                    isMine: track.isMine,
                    role: track.role
                )
            }
            let temporaryJoinTrackID = "jamo_track_\(copy.id)_mine"
            if copy.status == .joined,
               copy.tracks.contains(where: { $0.id == temporaryJoinTrackID && $0.ownerUserID == player.userID && $0.isMine }) {
                copy.tracks.removeAll { $0.id == temporaryJoinTrackID && $0.ownerUserID == player.userID && $0.isMine }
                if !copy.tracks.contains(where: { $0.ownerUserID == player.userID && $0.isMine }) {
                    copy.participants = copy.participants?.filter { $0.userID != player.userID }
                }
                copy.status = copy.allowContinue ? .open : .completed
                copy.selectedJoinMethod = nil
                copy.participantCount = max(copy.participants?.count ?? 0, copy.tracks.count)
            }
            if copy.status == .joined && !hasCurrentUserPart(in: copy.tracks, playerID: player.userID) {
                copy.participants = copy.participants?.filter { $0.userID != player.userID && $0.userID != "current_user" }
                copy.status = copy.allowContinue ? .open : .completed
                copy.selectedJoinMethod = nil
                copy.participantCount = max(copy.participants?.count ?? 0, copy.tracks.count)
            }
            if copy.status == .joined || copy.status == .completed {
                copy.tracks = supplementedPlayableTracks(for: copy, mediaSeed: mediaSeed)
            }
            if copy.participants?.isEmpty ?? true {
                copy.participants = participantsFromTracks(copy.tracks)
            }
            if copy.participantCount == nil {
                copy.participantCount = max(copy.participants?.count ?? 0, copy.tracks.count)
            }
            if copy.neededPart == nil && copy.status != .completed && copy.allowContinue {
                copy.neededPart = defaultNeededPart(for: copy)
            }
            return copy
        }
    }

    private func hasCurrentUserPart(in tracks: [JamoCoCreateTrack], playerID: String) -> Bool {
        tracks.contains { track in
            guard track.isMine else { return false }
            return track.ownerUserID == playerID || track.ownerUserID == "current_user"
        }
    }

    private func supplementedPlayableTracks(for work: JamoCoCreateWork, mediaSeed: Int) -> [JamoCoCreateTrack] {
        guard let participants = work.participants, !participants.isEmpty else {
            return work.tracks
        }

        var result = work.tracks
        var existingOwners = Set(result.map(\.ownerUserID))
        let maxPlayableParts = work.status == .completed ? 5 : 4
        for participant in participants where result.count < maxPlayableParts {
            guard !existingOwners.contains(participant.userID) else { continue }
            let template = coCreateTrackTemplate(for: result.count)
            result.append(
                JamoCoCreateTrack(
                    id: "jamo_track_\(work.id)_participant_\(sanitizedTrackID(participant.userID))",
                    ownerUserID: participant.userID,
                    ownerName: participant.displayName,
                    roleName: template.title,
                    mp3FileName: JamoLocalJamMediaCatalog.riff(mediaSeed + result.count + 1),
                    duration: template.duration,
                    waveformSeed: max(mediaSeed + result.count + 3, 1),
                    isMine: participant.userID == currentPlayer().userID || participant.userID == "current_user",
                    role: template.role
                )
            )
            existingOwners.insert(participant.userID)
        }
        return result
    }

    private func coCreateTrackTemplate(for index: Int) -> (title: String, role: JamoCoCreateTrackRole, duration: TimeInterval) {
        let templates: [(String, JamoCoCreateTrackRole, TimeInterval)] = [
            ("Original Guitar", .originalGuitar, 42),
            ("Rhythm Track", .rhythmTrack, 30),
            ("Lead Guitar", .leadGuitar, 15),
            ("Chord Backing", .chords, 15),
            ("Melody Line", .melody, 15),
            ("Backing Track", .backingTrack, 24)
        ]
        return templates[min(index, templates.count - 1)]
    }

    private func sanitizedTrackID(_ value: String) -> String {
        value.replacingOccurrences(of: "[^A-Za-z0-9_]", with: "_", options: .regularExpression)
    }

    private func ensureOpenJam(in works: [JamoCoCreateWork]) -> [JamoCoCreateWork] {
        guard !works.contains(where: { $0.status == .open }) else {
            return works
        }

        var copy = works
        copy.insert(makeGeneratedOpenJam(seed: works.count + 4), at: 0)
        return copy
    }

    private func makeGeneratedOpenJam(seed: Int) -> JamoCoCreateWork {
        JamoCoCreateWork(
            id: "jamo_open_local_\(Int(Date().timeIntervalSince1970))",
            title: "Open Lead Jam",
            about: "A local acoustic groove looking for a 15s lead guitar answer.",
            coverImageName: JamoLocalJamMediaCatalog.cover(seed),
            creatorUserID: "jamo_seed_ava",
            creatorName: "Ava Strings",
            creatorAvatarURL: nil,
            tags: ["Acoustic", "Open", "Lead"],
            status: .open,
            allowContinue: true,
            createdAt: Date(timeIntervalSinceNow: -900),
            tracks: [
                JamoCoCreateTrack(
                    id: "jamo_track_open_local_original",
                    ownerUserID: "jamo_seed_ava",
                    ownerName: "Ava Strings",
                    roleName: "Original Guitar",
                    mp3FileName: JamoLocalJamMediaCatalog.riff(seed),
                    duration: 42,
                    waveformSeed: 4,
                    isMine: false,
                    role: .originalGuitar
                ),
                JamoCoCreateTrack(
                    id: "jamo_track_open_local_rhythm",
                    ownerUserID: "jamo_seed_eli",
                    ownerName: "Eli Fret",
                    roleName: "Rhythm Track",
                    mp3FileName: JamoLocalJamMediaCatalog.riff(seed + 1),
                    duration: 30,
                    waveformSeed: 6,
                    isMine: false,
                    role: .rhythmTrack
                )
            ],
            coverURL: nil,
            participantCount: 9,
            participants: [
                JamoCoCreateParticipant(userID: "jamo_seed_ava", displayName: "Ava Strings", avatarURL: nil, colorHex: "#E75B33"),
                JamoCoCreateParticipant(userID: "jamo_seed_eli", displayName: "Eli Fret", avatarURL: nil, colorHex: "#26315E"),
                JamoCoCreateParticipant(userID: "jamo_seed_tom", displayName: "Tom Maple", avatarURL: nil, colorHex: "#7A50FF")
            ],
            neededPart: JamoCoCreateNeededPart(
                id: "jamo_need_open_local_lead",
                title: "Lead Guitar",
                subtitle: "Add a 15s lead guitar part",
                role: .leadGuitar,
                duration: 15,
                waveformSeed: 8
            ),
            selectedJoinMethod: nil
        )
    }

    private func participantsFromTracks(_ tracks: [JamoCoCreateTrack]) -> [JamoCoCreateParticipant] {
        var seen = Set<String>()
        let colors = ["#E75B33", "#26315E", "#FF72A8", "#7A50FF", "#FFDD1E"]
        return tracks.enumerated().compactMap { index, track in
            guard seen.insert(track.ownerUserID).inserted else { return nil }
            return JamoCoCreateParticipant(
                userID: track.ownerUserID,
                displayName: track.ownerName,
                avatarURL: nil,
                colorHex: colors[index % colors.count]
            )
        }
    }

    private func defaultNeededPart(for work: JamoCoCreateWork) -> JamoCoCreateNeededPart {
        let role: JamoCoCreateTrackRole = work.status == .draft ? .rhythmTrack : .leadGuitar
        let title = role == .rhythmTrack ? "Rhythm Track" : "Lead Guitar"
        return JamoCoCreateNeededPart(
            id: "jamo_need_\(work.id)",
            title: title,
            subtitle: "Add a 15s lead guitar part",
            role: role,
            duration: 15,
            waveformSeed: max((work.tracks.last?.waveformSeed ?? 4) + 1, 1)
        )
    }

    private func mergedWithCurrentUser(_ works: [JamoCoCreateWork]) -> [JamoCoCreateWork] {
        let player = currentPlayer()
        return works.map { work in
            guard work.creatorUserID == "current_user" || work.creatorUserID == player.userID else { return work }
            var copy = work
            copy.creatorUserID = player.userID
            copy.creatorName = player.name
            copy.creatorAvatarURL = player.avatarURL
            copy.tracks = copy.tracks.map { track in
                guard track.ownerUserID == "current_user" else { return track }
                return JamoCoCreateTrack(
                    id: track.id,
                    ownerUserID: player.userID,
                    ownerName: player.name,
                    roleName: track.roleName,
                    mp3FileName: track.mp3FileName,
                    duration: track.duration,
                    waveformSeed: track.waveformSeed,
                    isMine: track.isMine,
                    role: track.role
                )
            }
            if var participants = copy.participants {
                participants = participants.map { participant in
                    guard participant.userID == "current_user" else { return participant }
                    return JamoCoCreateParticipant(
                        userID: player.userID,
                        displayName: player.name,
                        avatarURL: player.avatarURL,
                        colorHex: participant.colorHex
                    )
                }
                copy.participants = participants
            }
            return copy
        }
    }

    private func loadStoredWorks() -> [JamoCoCreateWork] {
        guard let data = defaults.data(forKey: Key.works),
              let decoded = try? JSONDecoder().decode([JamoCoCreateWork].self, from: data) else {
            return []
        }
        return decoded
    }

    private func save(works: [JamoCoCreateWork]) {
        guard let data = try? JSONEncoder().encode(works) else { return }
        defaults.set(data, forKey: Key.works)
    }

    private func seedWorks() -> [JamoCoCreateWork] {
        [
            JamoCoCreateWork(
                id: "jamo_seed_sunset_riff",
                title: "Sunset Porch Riff",
                about: "A warm acoustic idea with space for a bright lead response.",
                coverImageName: JamoLocalJamMediaCatalog.cover(1),
                creatorUserID: "jamo_seed_mia",
                creatorName: "Mia Carter",
                creatorAvatarURL: nil,
                tags: ["Acoustic", "Open", "Lead"],
                status: .open,
                allowContinue: true,
                createdAt: Date(timeIntervalSinceNow: -3600),
                tracks: [
                    JamoCoCreateTrack(id: "jamo_track_sunset_original", ownerUserID: "jamo_seed_mia", ownerName: "Mia Carter", roleName: "Original Guitar", mp3FileName: JamoLocalJamMediaCatalog.riff(1), duration: 42, waveformSeed: 3, isMine: false, role: .originalGuitar),
                    JamoCoCreateTrack(id: "jamo_track_sunset_rhythm", ownerUserID: "jamo_seed_leo", ownerName: "Leo Park", roleName: "Rhythm Track", mp3FileName: JamoLocalJamMediaCatalog.riff(2), duration: 30, waveformSeed: 5, isMine: false, role: .rhythmTrack)
                ],
                coverURL: nil,
                participantCount: 12,
                participants: [
                    JamoCoCreateParticipant(userID: "jamo_seed_mia", displayName: "Mia Carter", avatarURL: nil, colorHex: "#E75B33"),
                    JamoCoCreateParticipant(userID: "jamo_seed_leo", displayName: "Leo Park", avatarURL: nil, colorHex: "#26315E"),
                    JamoCoCreateParticipant(userID: "jamo_seed_ava", displayName: "Ava Strings", avatarURL: nil, colorHex: "#FF72A8"),
                    JamoCoCreateParticipant(userID: "jamo_seed_tom", displayName: "Tom Maple", avatarURL: nil, colorHex: "#7A50FF")
                ],
                neededPart: JamoCoCreateNeededPart(
                    id: "jamo_need_sunset_lead",
                    title: "Lead Guitar",
                    subtitle: "Add a 15s lead guitar part",
                    role: .leadGuitar,
                    duration: 15,
                    waveformSeed: 9
                ),
                selectedJoinMethod: nil
            ),
            JamoCoCreateWork(
                id: "jamo_seed_city_duet",
                title: "Clean Chord Loop",
                about: "A compact rhythm bed ready for a melodic guitar layer.",
                coverImageName: JamoLocalJamMediaCatalog.cover(2),
                creatorUserID: "current_user",
                creatorName: "Jamo Player",
                creatorAvatarURL: nil,
                tags: ["Acoustic", "Joined"],
                status: .joined,
                allowContinue: true,
                createdAt: Date(timeIntervalSinceNow: -7200),
                tracks: [
                    JamoCoCreateTrack(id: "jamo_track_city_original", ownerUserID: "jamo_seed_noah", ownerName: "Noah Tone", roleName: "Original Guitar", mp3FileName: JamoLocalJamMediaCatalog.riff(3), duration: 42, waveformSeed: 5, isMine: false, role: .originalGuitar),
                    JamoCoCreateTrack(id: "jamo_track_city_mine", ownerUserID: "current_user", ownerName: "Jamo Player", roleName: "Lead Guitar", mp3FileName: JamoLocalJamMediaCatalog.riff(4), duration: 15, waveformSeed: 8, isMine: true, role: .leadGuitar)
                ],
                coverURL: nil,
                participantCount: 8,
                participants: [
                    JamoCoCreateParticipant(userID: "jamo_seed_noah", displayName: "Noah Tone", avatarURL: nil, colorHex: "#26315E"),
                    JamoCoCreateParticipant(userID: "current_user", displayName: "Jamo Player", avatarURL: nil, colorHex: "#FF72A8"),
                    JamoCoCreateParticipant(userID: "jamo_seed_ivy", displayName: "Ivy Capo", avatarURL: nil, colorHex: "#FFDD1E")
                ],
                neededPart: JamoCoCreateNeededPart(
                    id: "jamo_need_city_chord",
                    title: "Need",
                    subtitle: "Add a 15s lead guitar part",
                    role: .leadGuitar,
                    duration: 15,
                    waveformSeed: 6
                ),
                selectedJoinMethod: .recordGuitar
            ),
            JamoCoCreateWork(
                id: "jamo_seed_finished_chain",
                title: "Morning Chain Jam",
                about: "Three short guitar clips stitched into one finished co-create.",
                coverImageName: JamoLocalJamMediaCatalog.cover(3),
                creatorUserID: "jamo_seed_mia",
                creatorName: "Mia Capo",
                creatorAvatarURL: nil,
                tags: ["Acoustic", "Completed"],
                status: .completed,
                allowContinue: false,
                createdAt: Date(timeIntervalSinceNow: -10800),
                tracks: [
                    JamoCoCreateTrack(id: "jamo_track_morning_original", ownerUserID: "jamo_seed_mia", ownerName: "Mia Capo", roleName: "Original Guitar", mp3FileName: JamoLocalJamMediaCatalog.riff(5), duration: 42, waveformSeed: 2, isMine: false, role: .originalGuitar),
                    JamoCoCreateTrack(id: "jamo_track_morning_rhythm", ownerUserID: "jamo_seed_eli", ownerName: "Eli Fret", roleName: "Rhythm Track", mp3FileName: JamoLocalJamMediaCatalog.riff(6), duration: 30, waveformSeed: 6, isMine: false, role: .rhythmTrack),
                    JamoCoCreateTrack(id: "jamo_track_morning_lead", ownerUserID: "current_user", ownerName: "Jamo Player", roleName: "Lead Guitar", mp3FileName: JamoLocalJamMediaCatalog.riff(7), duration: 15, waveformSeed: 9, isMine: true, role: .leadGuitar)
                ],
                coverURL: nil,
                participantCount: 12,
                participants: [
                    JamoCoCreateParticipant(userID: "jamo_seed_mia", displayName: "Mia Capo", avatarURL: nil, colorHex: "#E75B33"),
                    JamoCoCreateParticipant(userID: "jamo_seed_eli", displayName: "Eli Fret", avatarURL: nil, colorHex: "#26315E"),
                    JamoCoCreateParticipant(userID: "current_user", displayName: "Jamo Player", avatarURL: nil, colorHex: "#FF72A8"),
                    JamoCoCreateParticipant(userID: "jamo_seed_tom", displayName: "Tom Maple", avatarURL: nil, colorHex: "#7A50FF")
                ],
                neededPart: nil,
                selectedJoinMethod: .recordGuitar
            )
        ]
    }
}

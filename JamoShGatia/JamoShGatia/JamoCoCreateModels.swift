import AVFoundation
import Foundation

enum JamoRiffLocalMediaShelf {
    private static let coverCount = 29
    private static let riffCount = 11
    private static let localCoverPrefix = JamoRiffStringCipher.restore("jUaxmhoo_nc1odcWrXe3ahtFeb_RlQojc6aIln_jcQoCvgeyr1_v")
    private static let localAudioPrefix = JamoRiffStringCipher.restore("j0ajmqo9_2c9oxccrEeRaltDei_ElyoJcvailo_BaGuKdViLoq_o")

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

        if clean.hasPrefix(JamoRiffStringCipher.restore("/4")), FileManager.default.fileExists(atPath: clean) {
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
        (value as NSString).lastPathComponent.hasPrefix(JamoRiffStringCipher.restore("j6acm6o8_5cio2ckrUexajtSe8_7lboAcVaqlX_LrxiOfwfS_x"))
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

        let cacheDirectories = [JamoRiffStringCipher.restore("Jta4mZoWCcolCOrXeiaHtiehCCo0vveCrECmaXcfh1eG"), JamoRiffStringCipher.restore("JMaxmtoKCjoMCNrjeIaAtWeAA3undGiFoVCpaZcAh9ea")]
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
        return String(format: JamoRiffStringCipher.restore("%c0r22dm"), wrapped)
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
            return JamoRiffStringCipher.restore("LIeXavd9 GGyuYiwtzaLr1")
        case .uploadClip:
            return JamoRiffStringCipher.restore("UApdlWoOa9dvehdM ZGnu1iLtaaQrR")
        case .addChords:
            return JamoRiffStringCipher.restore("CMhwo0r1dW VBvahcjkIiunrgf")
        case .addMelody:
            return JamoRiffStringCipher.restore("MFeGlwoSdiyV JL0iXnUe7")
        }
    }

    var localMP3FileName: String {
        switch self {
        case .recordGuitar:
            return JamoRiffLocalMediaShelf.riff(8)
        case .uploadClip:
            return JamoRiffLocalMediaShelf.riff(9)
        case .addChords:
            return JamoRiffLocalMediaShelf.riff(10)
        case .addMelody:
            return JamoRiffLocalMediaShelf.riff(11)
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

extension JamoCoCreateTrack {
    var jamoTrackHandle: String {
        id
    }
}

extension JamoCoCreateWork {
    var jamoRiffHandle: String {
        id
    }
}

final class JamoLocalJamStore {
    static let shared = JamoLocalJamStore()

    private enum Key {
        static let works = JamoRiffStringCipher.restore("jzaemkos_mlIoZcQaalR_Qc3oG_8cYrFelaGtoee_6wkoTrQkwsD")
    }

    private let defaults: UserDefaults
    private let authStore: JamoRiffIdentityArchive

    private init(defaults: UserDefaults = .standard, authStore: JamoRiffIdentityArchive = .sharedArchive) {
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
            title: title.isEmpty ? JamoRiffStringCipher.restore("U0nxt2iGt5l0exdH RGRuviltuaurO sIrdpekap") : title,
            about: about,
            coverImageName: JamoRiffLocalMediaShelf.cover(6),
            creatorUserID: player.userID,
            creatorName: player.name,
            creatorAvatarURL: player.avatarURL,
            tags: [JamoRiffStringCipher.restore("Dur7a7f4tA"), JamoRiffStringCipher.restore("GlutiRtna0rz")],
            status: .draft,
            allowContinue: allowContinue,
            createdAt: Date(),
            tracks: [
                JamoCoCreateTrack(
                    id: JamoRiffStringCipher.restore("jHajmRof_Ctar4aicUk7_vlOo2c7aWlt_NdvrsawfstG"),
                    ownerUserID: player.userID,
                    ownerName: player.name,
                    roleName: JamoRiffStringCipher.restore("S0tJaOrLtmeqrY PrmiZfRfV"),
                    mp3FileName: JamoRiffLocalMediaShelf.riff(6),
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
                title: JamoRiffStringCipher.restore("LFeBahdT iGYuDiEtPa3r2"),
                subtitle: JamoRiffStringCipher.restore("Andfdf Zak 5175us6 0lXeDaBdJ agTuYiztCa9rj ipoarr3tW"),
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
        let safeCoverName = JamoRiffLocalMediaShelf.normalizedCover(cleanCoverName, seed: 7)
        let safeTags = normalizedPublishTags(tags)
        let safeDuration = max(duration, 1)
        let safeWaveformSeed = max(waveformSeed, 1)
        let safeRoleName = roleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? JamoRiffStringCipher.restore("LNezaQd5 dGUuUiAtzaRrm") : roleName
        let safeMP3FileName = JamoRiffLocalMediaShelf.normalizedRiff(mp3FileName, seed: 7)
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
            title: cleanTitle.isEmpty ? JamoRiffStringCipher.restore("UPnDtIi7tVlkefdu DGFuxiGtTaerJ lIodceAaf") : cleanTitle,
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
        let email = authStore.currentEmail ?? JamoRiffStringCipher.restore("l8orcvaElk@yjOaAmLor.BaPpHpX")
        return (
            authStore.currentUserID ?? JamoRiffStringCipher.restore("jqaam6oy_7lEoecMaJlk_spjl5aKy2esrx"),
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
            colorHex: JamoRiffStringCipher.restore("#7F2F8782vAH8s")
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
        return normalized.isEmpty ? [JamoRiffStringCipher.restore("ArcpoFu7sotMi9cE"), JamoRiffStringCipher.restore("LWesafdw")] : normalized
    }

    private func normalizedWorks(_ works: [JamoCoCreateWork]) -> [JamoCoCreateWork] {
        works.enumerated().map { index, work in
            var copy = work
            let player = currentPlayer()
            let mediaSeed = index + 1
            copy.coverImageName = JamoRiffLocalMediaShelf.normalizedCover(copy.coverImageName, seed: mediaSeed)
            copy.coverURL = nil
            copy.tracks = copy.tracks.enumerated().map { trackIndex, track in
                JamoCoCreateTrack(
                    id: track.id,
                    ownerUserID: track.ownerUserID,
                    ownerName: track.ownerName,
                    roleName: track.roleName,
                    mp3FileName: JamoRiffLocalMediaShelf.normalizedRiff(track.mp3FileName, seed: mediaSeed + trackIndex),
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
                copy.participants = copy.participants?.filter { $0.userID != player.userID && $0.userID != JamoRiffStringCipher.restore("ctuHrJrZernhtw_iuisoe0rJ") }
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
            return track.ownerUserID == playerID || track.ownerUserID == JamoRiffStringCipher.restore("cZuKrqrbeZnxto_Duys1eyrK")
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
                    mp3FileName: JamoRiffLocalMediaShelf.riff(mediaSeed + result.count + 1),
                    duration: template.duration,
                    waveformSeed: max(mediaSeed + result.count + 3, 1),
                    isMine: participant.userID == currentPlayer().userID || participant.userID == JamoRiffStringCipher.restore("cDu2rtr1e7nMt4_PuBsOe4rO"),
                    role: template.role
                )
            )
            existingOwners.insert(participant.userID)
        }
        return result
    }

    private func coCreateTrackTemplate(for index: Int) -> (title: String, role: JamoCoCreateTrackRole, duration: TimeInterval) {
        let templates: [(String, JamoCoCreateTrackRole, TimeInterval)] = [
            (JamoRiffStringCipher.restore("OtrZixg0irnnaXlh GGLuBimtcahrp"), .originalGuitar, 42),
            (JamoRiffStringCipher.restore("RchQyWtXhoma 2TCroaEcSkY"), .rhythmTrack, 30),
            (JamoRiffStringCipher.restore("L0eIa5dS LGyu7i9tRaLry"), .leadGuitar, 15),
            (JamoRiffStringCipher.restore("CDhGojrUdD qBCazc1kOitnMgV"), .chords, 15),
            (JamoRiffStringCipher.restore("MAezlNoKdzyW kLgi7n7eR"), .melody, 15),
            (JamoRiffStringCipher.restore("BzaQcSkJi1n4go zTrrxa4cck5"), .backingTrack, 24)
        ]
        return templates[min(index, templates.count - 1)]
    }

    private func sanitizedTrackID(_ value: String) -> String {
        value.replacingOccurrences(of: JamoRiffStringCipher.restore("[E^XAP-1ZQan-2zd0d-59f_6]9"), with: JamoRiffStringCipher.restore("_O"), options: .regularExpression)
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
            title: JamoRiffStringCipher.restore("OSpUeGnd KLHeGacdf 3JmaHml"),
            about: JamoRiffStringCipher.restore("Ag YlgoccBabl0 oaxceoSu4sbtKigcG KgGrZoQoGvke0 KlJoTorkXiTncgr Cfrozrv NaT M1g55sk llLesaeda 1gxumi6tsadr5 ra3nKsLwreWrb.y"),
            coverImageName: JamoRiffLocalMediaShelf.cover(seed),
            creatorUserID: JamoRiffStringCipher.restore("jeaPmZoJ_dsoeiexdu_oaQviac"),
            creatorName: JamoRiffStringCipher.restore("AcvwaW OSbt0riiUnZgmsE"),
            creatorAvatarURL: nil,
            tags: [JamoRiffStringCipher.restore("AtcaoSunsItEigc1"), JamoRiffStringCipher.restore("OApfernQ"), JamoRiffStringCipher.restore("LUeTaTdW")],
            status: .open,
            allowContinue: true,
            createdAt: Date(timeIntervalSinceNow: -900),
            tracks: [
                JamoCoCreateTrack(
                    id: JamoRiffStringCipher.restore("jwa6myoB_IterTaDcwkm_bo7pNe0nK_alLoxchamlm_fonrDiHgliwnBaQlC"),
                    ownerUserID: JamoRiffStringCipher.restore("jea6mUo0_CsqeueUdJ_ya2vzah"),
                    ownerName: JamoRiffStringCipher.restore("A9vEau SS8tTrsiunBgKsP"),
                    roleName: JamoRiffStringCipher.restore("Onrdiag0iKnlaGln 3Geuvi1tJa2r0"),
                    mp3FileName: JamoRiffLocalMediaShelf.riff(seed),
                    duration: 42,
                    waveformSeed: 4,
                    isMine: false,
                    role: .originalGuitar
                ),
                JamoCoCreateTrack(
                    id: JamoRiffStringCipher.restore("j4a5mLoV_4tMrcaPcfk4_Dovp2e1nY_GlwoecnaQlU_Grehqyztqh2mL"),
                    ownerUserID: JamoRiffStringCipher.restore("jkaimpoy_8sTeEeJdS_5eNlUi4"),
                    ownerName: JamoRiffStringCipher.restore("Eplzib JF2rseetT"),
                    roleName: JamoRiffStringCipher.restore("R9huyht6htmT 7Tmr7arcekH"),
                    mp3FileName: JamoRiffLocalMediaShelf.riff(seed + 1),
                    duration: 30,
                    waveformSeed: 6,
                    isMine: false,
                    role: .rhythmTrack
                )
            ],
            coverURL: nil,
            participantCount: 9,
            participants: [
                JamoCoCreateParticipant(userID: JamoRiffStringCipher.restore("jNaVmPoS_lsWeUekdk_Na3vBa1"), displayName: JamoRiffStringCipher.restore("Atv1av lSutZrfiLnRgps6"), avatarURL: nil, colorHex: JamoRiffStringCipher.restore("#uE57Q5xBl3s3C")),
                JamoCoCreateParticipant(userID: JamoRiffStringCipher.restore("jgatmloC_GsQeweZdq_veilqi3"), displayName: JamoRiffStringCipher.restore("E3lHio YF4rseztO"), avatarURL: nil, colorHex: JamoRiffStringCipher.restore("#K2V6A3c1P5gEx")),
                JamoCoCreateParticipant(userID: JamoRiffStringCipher.restore("j5aomIoI_JsEeQeEdj_wtToom9"), displayName: JamoRiffStringCipher.restore("TQommz 0MqaUpIl4e6"), avatarURL: nil, colorHex: JamoRiffStringCipher.restore("#Z7vAI5i0QFBFC"))
            ],
            neededPart: JamoCoCreateNeededPart(
                id: JamoRiffStringCipher.restore("jZa1mcoS_2nKe9eVd7_foEpieenR_Olfo2cvaOlU_olUepaydV"),
                title: JamoRiffStringCipher.restore("LEeJatdo GGXuDi7twaeri"),
                subtitle: JamoRiffStringCipher.restore("AFdjd2 8a9 R1J5rsw xlHeyabdx OgguQiStCajrQ Lpwa9rTtc"),
                role: .leadGuitar,
                duration: 15,
                waveformSeed: 8
            ),
            selectedJoinMethod: nil
        )
    }

    private func participantsFromTracks(_ tracks: [JamoCoCreateTrack]) -> [JamoCoCreateParticipant] {
        var seen = Set<String>()
        let colors = [JamoRiffStringCipher.restore("#vEB7E5JBt3X3E"), JamoRiffStringCipher.restore("#H286u3S1R5nEX"), JamoRiffStringCipher.restore("#FF0Fy7t22Ao81"), JamoRiffStringCipher.restore("#87NAm5C0zF7Fm"), JamoRiffStringCipher.restore("#3FhFODsDv17Er")]
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
        let title = role == .rhythmTrack ? JamoRiffStringCipher.restore("RXhWyqtqhpmm FTVrbaFcpkE") : JamoRiffStringCipher.restore("L8ebaCdH vGuuyiZtEaurP")
        return JamoCoCreateNeededPart(
            id: "jamo_need_\(work.id)",
            title: title,
            subtitle: JamoRiffStringCipher.restore("AhdZdS 9ay 81g5LsZ Slhe1aOdI Wgdu8iftoatrr BptairZth"),
            role: role,
            duration: 15,
            waveformSeed: max((work.tracks.last?.waveformSeed ?? 4) + 1, 1)
        )
    }

    private func mergedWithCurrentUser(_ works: [JamoCoCreateWork]) -> [JamoCoCreateWork] {
        let player = currentPlayer()
        return works.map { work in
            guard work.creatorUserID == JamoRiffStringCipher.restore("cfu4rDrAeXnJte_OuCseearQ") || work.creatorUserID == player.userID else { return work }
            var copy = work
            copy.creatorUserID = player.userID
            copy.creatorName = player.name
            copy.creatorAvatarURL = player.avatarURL
            copy.tracks = copy.tracks.map { track in
                guard track.ownerUserID == JamoRiffStringCipher.restore("caujrPrjeXnvt3_ZuXsseVrq") else { return track }
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
                    guard participant.userID == JamoRiffStringCipher.restore("cGuwryrvePnjtw_fujsMeir2") else { return participant }
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
                id: JamoRiffStringCipher.restore("jla7mdoZ_2sqeJeidu_FsZuKnCsCehtK_Jrki0fefJ"),
                title: JamoRiffStringCipher.restore("Scuzn3sweAtu 5PNoJrbcYhO 9RriOf5fx"),
                about: JamoRiffStringCipher.restore("AM Lw3acrLmJ caMcAoduXsytui1cR LiOdGeBaS 7wbiLtIh3 fscpKaPcqeu zf7ogr0 PaE hbHrYi9gOhOtS nlWela2dT Nr1eUsQp3obnRsue4.w"),
                coverImageName: JamoRiffLocalMediaShelf.cover(1),
                creatorUserID: JamoRiffStringCipher.restore("jEatmRoJ_nsxeveOdg_9mviTaW"),
                creatorName: JamoRiffStringCipher.restore("MQijaD KCjaMrutTeZrK"),
                creatorAvatarURL: nil,
                tags: [JamoRiffStringCipher.restore("AOcYovumsItmiNch"), JamoRiffStringCipher.restore("OdpmeQny"), JamoRiffStringCipher.restore("LLetaXdo")],
                status: .open,
                allowContinue: true,
                createdAt: Date(timeIntervalSinceNow: -3600),
                tracks: [
                    JamoCoCreateTrack(id: JamoRiffStringCipher.restore("jVa8mNoK_htSrUaKcgkK_vsWudnSsteftF_0ohrIi8g7izn5aCl2"), ownerUserID: JamoRiffStringCipher.restore("jUa4m5os_3s0eDe2dH_PmdiVaA"), ownerName: JamoRiffStringCipher.restore("MdiAa1 xCHaBr5tPehrX"), roleName: JamoRiffStringCipher.restore("OeriiJgQiunOaAlj 9GVuUietyaxra"), mp3FileName: JamoRiffLocalMediaShelf.riff(1), duration: 42, waveformSeed: 3, isMine: false, role: .originalGuitar),
                    JamoCoCreateTrack(id: JamoRiffStringCipher.restore("jlafmUof_ltHr9aDcrkE_isWuOnHske4tf_rrOhjyAthhmmE"), ownerUserID: JamoRiffStringCipher.restore("jdaem3oK_5steZeDdt_2lXe3oL"), ownerName: JamoRiffStringCipher.restore("Lvehoj jP9arrwkP"), roleName: JamoRiffStringCipher.restore("ROhnyItZhXmD rTyrda9cckb"), mp3FileName: JamoRiffLocalMediaShelf.riff(2), duration: 30, waveformSeed: 5, isMine: false, role: .rhythmTrack)
                ],
                coverURL: nil,
                participantCount: 12,
                participants: [
                    JamoCoCreateParticipant(userID: JamoRiffStringCipher.restore("jVaNm7o7_asGeOeid7_TmjiYau"), displayName: JamoRiffStringCipher.restore("M9ima1 bC1aMrUtKevr0"), avatarURL: nil, colorHex: JamoRiffStringCipher.restore("#RE17k59BO3E3e")),
                    JamoCoCreateParticipant(userID: JamoRiffStringCipher.restore("jpa8mTo2_dsOese5dL_glSefoQ"), displayName: JamoRiffStringCipher.restore("LIeko6 WPxarrJkf"), avatarURL: nil, colorHex: JamoRiffStringCipher.restore("#22R6O3l1m5FEW")),
                    JamoCoCreateParticipant(userID: JamoRiffStringCipher.restore("jpaimBo8_NsPecefdU_2aTvCab"), displayName: JamoRiffStringCipher.restore("APv2ad HSBtYrCiFnEgssv"), avatarURL: nil, colorHex: JamoRiffStringCipher.restore("#TFiFc7q2QAt8R")),
                    JamoCoCreateParticipant(userID: JamoRiffStringCipher.restore("jVahm7oU_YsDeleRdL_ZttoemR"), displayName: JamoRiffStringCipher.restore("TPo2ma yMFappXlaeO"), avatarURL: nil, colorHex: JamoRiffStringCipher.restore("#U7iAt5H0tFFFW"))
                ],
                neededPart: JamoCoCreateNeededPart(
                    id: JamoRiffStringCipher.restore("jea3moon_LnVeoendA_UswumnXsue3tK_ZlReMa2d4"),
                    title: JamoRiffStringCipher.restore("LCepacdR XGquvidtBaDrg"),
                    subtitle: JamoRiffStringCipher.restore("AwdMd9 ZaE 01e5rsX Al3eMatdf agQuoipt8aYrb ZpoairUt0"),
                    role: .leadGuitar,
                    duration: 15,
                    waveformSeed: 9
                ),
                selectedJoinMethod: nil
            ),
            JamoCoCreateWork(
                id: JamoRiffStringCipher.restore("jxaGmNow_0she4evdh_qcHiJtOyb_bdIu3edtk"),
                title: JamoRiffStringCipher.restore("CVlDeqaynn vCFhXoKrtdV cLpocoVpx"),
                about: JamoRiffStringCipher.restore("AK TctoBm0pwaacttJ truhMyNtahcmT wbieXdz Vr3eJaVdsyl dfCoUrz iaj Fmle7lEoDdJicc1 BgsueiNteaWrN TljanyseDry.B"),
                coverImageName: JamoRiffLocalMediaShelf.cover(2),
                creatorUserID: JamoRiffStringCipher.restore("cZuOrxr7efnXtx_IulsEearY"),
                creatorName: JamoRiffStringCipher.restore("J8a0m0o7 EPrloawyEe1rZ"),
                creatorAvatarURL: nil,
                tags: [JamoRiffStringCipher.restore("AAc9oLu0s1t2iTcE"), JamoRiffStringCipher.restore("J8o5ieniecdI")],
                status: .joined,
                allowContinue: true,
                createdAt: Date(timeIntervalSinceNow: -7200),
                tracks: [
                    JamoCoCreateTrack(id: JamoRiffStringCipher.restore("juasmiox_rtorYawcIk5_3ckimtIy7_woirkiagWiqn9aAli"), ownerUserID: JamoRiffStringCipher.restore("j7a2mqoK_QsoegeadP_rntoYaDh3"), ownerName: JamoRiffStringCipher.restore("Nzo4akhH bTIoWn1e5"), roleName: JamoRiffStringCipher.restore("O2roiVgvibnBaclh pG7uWiktiaDro"), mp3FileName: JamoRiffLocalMediaShelf.riff(3), duration: 42, waveformSeed: 5, isMine: false, role: .originalGuitar),
                    JamoCoCreateTrack(id: JamoRiffStringCipher.restore("jcaimPoy_NtirHaLcukj_CcjimtFy6_gmTiPnBen"), ownerUserID: JamoRiffStringCipher.restore("cSu6rurZeQnwty_tuPsAeurJ"), ownerName: JamoRiffStringCipher.restore("JfaVmcoL APClZaNykeArx"), roleName: JamoRiffStringCipher.restore("Lpeha9dF kGjuqijtDaGre"), mp3FileName: JamoRiffLocalMediaShelf.riff(4), duration: 15, waveformSeed: 8, isMine: true, role: .leadGuitar)
                ],
                coverURL: nil,
                participantCount: 8,
                participants: [
                    JamoCoCreateParticipant(userID: JamoRiffStringCipher.restore("jDaamYoU_hsTePemdW_8n4otauhO"), displayName: JamoRiffStringCipher.restore("N2oLaUh8 9T2ocn7eN"), avatarURL: nil, colorHex: JamoRiffStringCipher.restore("#k2m6M331H5aE0")),
                    JamoCoCreateParticipant(userID: JamoRiffStringCipher.restore("cSujrmrmeUnVtO_ouEsuexr9"), displayName: JamoRiffStringCipher.restore("JdakmEoh 9P3lJaJyleHrp"), avatarURL: nil, colorHex: JamoRiffStringCipher.restore("#kF1Ff7U2WAy8f")),
                    JamoCoCreateParticipant(userID: JamoRiffStringCipher.restore("jjaVm8oA_SsTeheUdg_7iWvnyz"), displayName: JamoRiffStringCipher.restore("IqvTyN GCIaDpuot"), avatarURL: nil, colorHex: JamoRiffStringCipher.restore("#2FLFBDpDb1OEt"))
                ],
                neededPart: JamoCoCreateNeededPart(
                    id: JamoRiffStringCipher.restore("jEaimbo2_7nnebexdJ_Mc2iutUyq_mcshnofrhdq"),
                    title: JamoRiffStringCipher.restore("Nfekeodj"),
                    subtitle: JamoRiffStringCipher.restore("AldzdA 8aB 31k5nsk pl0e2a3d9 ngJuvivtGaDru bpoaDr4tj"),
                    role: .leadGuitar,
                    duration: 15,
                    waveformSeed: 6
                ),
                selectedJoinMethod: .recordGuitar
            ),
            JamoCoCreateWork(
                id: JamoRiffStringCipher.restore("jRa2mLo7_psCeXe9dU_ffQiUndizsVhHefdo_IcHh5ariSnx"),
                title: JamoRiffStringCipher.restore("M6oZrZnmiTn8gV wC9hqauiynu ZJmaYmM"),
                about: JamoRiffStringCipher.restore("TShbrHeVeM bszhfoKrstv lgKuJibtDaCr6 gcxlZiQpjso Js1txiOt0cIhmeBdO oiBn6t3oC OoinIec Of7icn8i4shhVeMdq 3cYoh-0cqrIekaftbem.z"),
                coverImageName: JamoRiffLocalMediaShelf.cover(3),
                creatorUserID: JamoRiffStringCipher.restore("jSaEmZo1_isPepe6db_zmGioab"),
                creatorName: JamoRiffStringCipher.restore("MpiZaf dCWaHpnoQ"),
                creatorAvatarURL: nil,
                tags: [JamoRiffStringCipher.restore("AIcRoeuMsFtmiSc5"), JamoRiffStringCipher.restore("CxoWmgp4lremtJeCdh")],
                status: .completed,
                allowContinue: false,
                createdAt: Date(timeIntervalSinceNow: -10800),
                tracks: [
                    JamoCoCreateTrack(id: JamoRiffStringCipher.restore("jxaQmvoN_wtcrya9cRkg_1mVoJrgn9ihnLgP_eoPrYiAg2ianPanle"), ownerUserID: JamoRiffStringCipher.restore("jZaRmVoC_esdeoexd3_4mBiyag"), ownerName: JamoRiffStringCipher.restore("MEiDaJ WCbakpAoZ"), roleName: JamoRiffStringCipher.restore("OgrziGg0innqabla CGbuKi3t7aEre"), mp3FileName: JamoRiffLocalMediaShelf.riff(5), duration: 42, waveformSeed: 2, isMine: false, role: .originalGuitar),
                    JamoCoCreateTrack(id: JamoRiffStringCipher.restore("j6aymloZ_CtErQaBcTkb_umdoBrEnZivnOgM_Vrkhgy2t6hSmE"), ownerUserID: JamoRiffStringCipher.restore("jaavmvol_5sfeGeRdO_IeklTim"), ownerName: JamoRiffStringCipher.restore("EJlXiZ 8F8rfektN"), roleName: JamoRiffStringCipher.restore("RkhQybtzhFm0 2TQr2aocqk1"), mp3FileName: JamoRiffLocalMediaShelf.riff(6), duration: 30, waveformSeed: 6, isMine: false, role: .rhythmTrack),
                    JamoCoCreateTrack(id: JamoRiffStringCipher.restore("jUaimzor_9tirFaQc5kN_Wm6owrKngiunGgp_xl1eJaydg"), ownerUserID: JamoRiffStringCipher.restore("ccuKrWrdeanUtP_wuqsReErG"), ownerName: JamoRiffStringCipher.restore("Jca4m5oR 8PhliaHySe3rC"), roleName: JamoRiffStringCipher.restore("LYevaJdu 8G9uwivtMaDrs"), mp3FileName: JamoRiffLocalMediaShelf.riff(7), duration: 15, waveformSeed: 9, isMine: true, role: .leadGuitar)
                ],
                coverURL: nil,
                participantCount: 12,
                participants: [
                    JamoCoCreateParticipant(userID: JamoRiffStringCipher.restore("jEaSmuon_qsJezejdI_SmXiLad"), displayName: JamoRiffStringCipher.restore("MJiSa8 ECAaCpfoG"), avatarURL: nil, colorHex: JamoRiffStringCipher.restore("#7Ec7O5BBC313a")),
                    JamoCoCreateParticipant(userID: JamoRiffStringCipher.restore("j3aXm0oL_ts5eRerdK_XesloiC"), displayName: JamoRiffStringCipher.restore("EmlciE 5FQrUevtx"), avatarURL: nil, colorHex: JamoRiffStringCipher.restore("#52M6V351e5WEG")),
                    JamoCoCreateParticipant(userID: JamoRiffStringCipher.restore("cZuzrxrIeTnVtE_DussMevrj"), displayName: JamoRiffStringCipher.restore("J9axmWoJ CPYlja1y1e8rN"), avatarURL: nil, colorHex: JamoRiffStringCipher.restore("#zFfF97d2OAq8C")),
                    JamoCoCreateParticipant(userID: JamoRiffStringCipher.restore("jUaRm4oV_tsWepemd3_vtyosmd"), displayName: JamoRiffStringCipher.restore("THotmc ZMDaupzlmec"), avatarURL: nil, colorHex: JamoRiffStringCipher.restore("#X79AV5g0XFuFo"))
                ],
                neededPart: nil,
                selectedJoinMethod: .recordGuitar
            )
        ]
    }
}

import Foundation

enum JamoToneProfileFlowState: Hashable {
    case hasRiffMoments
    case emptyRiffMoments
    case loadingPlayerTone
    case playerToneFallback
}

enum JamoToneProfileBridgeKind {
    case editProfile
    case styleExchange
    case sessionParticipant
    case pickupShelf
}

struct JamoToneProfileBridgeEntry {
    let kind: JamoToneProfileBridgeKind
    let title: String
    let route: JamoShowDefinition
}

struct JamoToneProfileMetricDisplay {
    let title: String
    let valueText: String
    let route: JamoShowDefinition
}

struct JamoProfileUserSummary {
    let playerHandle: String
    let playerDisplayName: String
    let playerEmail: String
    let playerArtworkAddress: String?
    let styleExchange: JamoToneProfileMetricDisplay
    let sessionParticipant: JamoToneProfileMetricDisplay
    let pickupShelf: JamoToneProfileMetricDisplay
    let editRoute: JamoShowDefinition
    let isUsingFallbackInfo: Bool
}

struct JamoProfileRiffMomentDisplay {
    let riffHandle: String
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

struct JamoProfileEmptyRiffDisplay {
    let title: String
    let subtitle: String
    let actionTitle: String
}

struct JamoProfileSnapshot {
    let flowStates: Set<JamoToneProfileFlowState>
    let playerSummary: JamoProfileUserSummary
    let bridgeEntries: [JamoToneProfileBridgeEntry]
    let riffMoments: [JamoProfileRiffMomentDisplay]
    let emptyRiffMoments: JamoProfileEmptyRiffDisplay?
    let sourceRiffWorks: [JamoCoCreateWork]
}

final class JamoProfileViewModel {
    private enum LocalCacheSlot {
        static let styleExchangeCount = JamoRiffStringCipher.restore("jvaZmoog_6t7oRnuew_7svtbyHloex_peDxCcXhSaznag8eE_FcloWuTn0tX")
        static let sessionParticipantCount = JamoRiffStringCipher.restore("joaYmRo0_itioqnfen_UsveksIswiQoRnb_3puaUrWt6iecYixpzaengt9_jceoyuKnNtw")
        static let pickupCount = JamoRiffStringCipher.restore("jMaxmtob_6tFopnze2_fp1iRcfkWuApx_5syhde1lVfP_dcCopucnItk")
    }

    private enum DefaultMetric {
        static let styleExchangeCount = 0
        static let sessionParticipantCount = 0
        static let pickupCount = 1800
    }

    private let riffIdentityStore: JamoRiffIdentityArchive
    private let creationFlowStore: JamoLocalJamStore
    private let sessionParticipantProvider: JamoCoCreateUserProviding
    private let riffDefaults: UserDefaults

    init(
        riffIdentityStore: JamoRiffIdentityArchive = .sharedArchive,
        creationFlowStore: JamoLocalJamStore = .shared,
        sessionParticipantProvider: JamoCoCreateUserProviding = JamoCoCreateUserService.shared,
        riffDefaults: UserDefaults = .standard
    ) {
        self.riffIdentityStore = riffIdentityStore
        self.creationFlowStore = creationFlowStore
        self.sessionParticipantProvider = sessionParticipantProvider
        self.riffDefaults = riffDefaults
    }

    func makeLoadingToneProfileSnapshot() -> JamoProfileSnapshot {
        makeToneProfileSnapshot(sessionParticipants: [], isLoadingPlayerTone: true, forcePlayerToneFallback: false)
    }

    func makeToneProfileSnapshot(sessionParticipants: [JamoRiffPlayerProfile] = []) -> JamoProfileSnapshot {
        makeToneProfileSnapshot(sessionParticipants: sessionParticipants, isLoadingPlayerTone: false, forcePlayerToneFallback: false)
    }

    func loadToneProfileSnapshot(completion: @escaping (JamoProfileSnapshot) -> Void) {
        completion(makeLoadingToneProfileSnapshot())
        sessionParticipantProvider.fetchJamUsers { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let users):
                completion(self.makeToneProfileSnapshot(sessionParticipants: users))
            case .failure:
                completion(self.makeToneProfileSnapshot(sessionParticipants: [], isLoadingPlayerTone: false, forcePlayerToneFallback: true))
            }
        }
    }

    func saveLocalToneMetrics(styleExchangeCount: Int? = nil, sessionParticipantCount: Int? = nil, pickupCount: Int? = nil) {
        if let styleExchangeCount {
            riffDefaults.set(max(styleExchangeCount, 0), forKey: LocalCacheSlot.styleExchangeCount)
        }
        if let sessionParticipantCount {
            riffDefaults.set(max(sessionParticipantCount, 0), forKey: LocalCacheSlot.sessionParticipantCount)
        }
        if let pickupCount {
            riffDefaults.set(max(pickupCount, 0), forKey: LocalCacheSlot.pickupCount)
        }
    }

    private func makeToneProfileSnapshot(
        sessionParticipants: [JamoRiffPlayerProfile],
        isLoadingPlayerTone: Bool,
        forcePlayerToneFallback: Bool
    ) -> JamoProfileSnapshot {
        let activePlayerContext = buildCurrentPlayerContext()
        let resolvedParticipants = sessionParticipants.isEmpty ? sessionParticipantProvider.cachedJamUsers : sessionParticipants
        let matchedParticipant = matchedSessionParticipant(in: resolvedParticipants, activePlayerContext: activePlayerContext)
        let playerSummary = buildPlayerSummary(
            activePlayerContext: activePlayerContext,
            matchedParticipant: matchedParticipant,
            forcePlayerToneFallback: forcePlayerToneFallback
        )
        let riffWorks = toneProfileRiffs(currentPlayerAnchor: activePlayerContext.jamoPlayerHandle)
        let riffMoments = riffWorks.map { buildRiffMomentDisplay(from: $0, currentPlayerAnchor: activePlayerContext.jamoPlayerHandle) }
        var flowStates: Set<JamoToneProfileFlowState> = riffMoments.isEmpty ? [.emptyRiffMoments] : [.hasRiffMoments]

        if isLoadingPlayerTone {
            flowStates.insert(.loadingPlayerTone)
        }
        if playerSummary.isUsingFallbackInfo {
            flowStates.insert(.playerToneFallback)
        }

        return JamoProfileSnapshot(
            flowStates: flowStates,
            playerSummary: playerSummary,
            bridgeEntries: buildBridgeEntries(),
            riffMoments: riffMoments,
            emptyRiffMoments: riffMoments.isEmpty ? buildEmptyRiffMomentDisplay() : nil,
            sourceRiffWorks: riffWorks
        )
    }

    private func buildCurrentPlayerContext() -> JamoRiffPlayerProfile {
        let playerEmail = riffIdentityStore.currentEmail ?? JamoRiffStringCipher.restore("luoycDaply@4jAa3mvoe.capp9pw")
        return JamoRiffPlayerProfile(
            jamoPlayerHandle: riffIdentityStore.currentPlayerHandle ?? JamoRiffStringCipher.restore("jOaam8oz_glRoncQaglr_JpnlSaIyaeQrK"),
            displayName: riffIdentityStore.currentDisplayName ?? riffIdentityStore.displayNameFallback(for: playerEmail),
            email: playerEmail,
            avatarURL: riffIdentityStore.currentAvatarURL
        )
    }

    private func matchedSessionParticipant(
        in users: [JamoRiffPlayerProfile],
        activePlayerContext: JamoRiffPlayerProfile
    ) -> JamoRiffPlayerProfile? {
        let currentPlayerEmail = normalizedPhrase(activePlayerContext.email)
        return users.first { playerSummary in
            playerSummary.jamoPlayerHandle == activePlayerContext.jamoPlayerHandle
                || (!currentPlayerEmail.isEmpty && normalizedPhrase(playerSummary.email) == currentPlayerEmail)
        }
    }

    private func buildPlayerSummary(
        activePlayerContext: JamoRiffPlayerProfile,
        matchedParticipant: JamoRiffPlayerProfile?,
        forcePlayerToneFallback: Bool
    ) -> JamoProfileUserSummary {
        let styleExchangeMetric = resolvedRemoteMetricValue(
            remoteValue: matchedParticipant?.followingCount,
            defaultValue: DefaultMetric.styleExchangeCount
        )
        let sessionParticipantMetric = resolvedRemoteMetricValue(
            remoteValue: matchedParticipant?.followersCount,
            defaultValue: DefaultMetric.sessionParticipantCount
        )
        let pickupMetric = resolvedMetricValue(
            remoteValue: matchedParticipant?.pickCount,
            cacheSlot: LocalCacheSlot.pickupCount,
            defaultValue: DefaultMetric.pickupCount
        )
        let playerDisplayName = trimmedPhrase(matchedParticipant?.displayName) ?? activePlayerContext.displayName
        let playerArtworkAddress = trimmedPhrase(activePlayerContext.avatarURL) ?? trimmedPhrase(matchedParticipant?.avatarURL)
        let usesFallbackTone = forcePlayerToneFallback
            || matchedParticipant == nil
            || styleExchangeMetric.isFallback
            || sessionParticipantMetric.isFallback
            || pickupMetric.isFallback

        return JamoProfileUserSummary(
            playerHandle: activePlayerContext.jamoPlayerHandle,
            playerDisplayName: playerDisplayName,
            playerEmail: activePlayerContext.email ?? JamoRiffStringCipher.restore("lRotcVaAl7@djGaamRoY.NacpvpR"),
            playerArtworkAddress: playerArtworkAddress,
            styleExchange: JamoToneProfileMetricDisplay(
                title: JamoRiffStringCipher.restore("FnoblKlqo6w0i6nhgm"),
                valueText: meterText(styleExchangeMetric.value),
                route: .styleExchangeRegistry
            ),
            sessionParticipant: JamoToneProfileMetricDisplay(
                title: JamoRiffStringCipher.restore("FMoxlmlFoswXeKrOsu"),
                valueText: meterText(sessionParticipantMetric.value),
                route: .sessionParticipantContext
            ),
            pickupShelf: JamoToneProfileMetricDisplay(
                title: JamoRiffStringCipher.restore("MYyJ vPziDcAk4sZ"),
                valueText: meterText(pickupMetric.value),
                route: .pickupSelectorDefinition
            ),
            editRoute: .toneProfileContext,
            isUsingFallbackInfo: usesFallbackTone
        )
    }

    private func resolvedMetricValue(remoteValue: Int?, cacheSlot: String, defaultValue: Int) -> (value: Int, isFallback: Bool) {
        if let remoteValue {
            return (max(remoteValue, 0), false)
        }
        if riffDefaults.object(forKey: cacheSlot) != nil {
            return (max(riffDefaults.integer(forKey: cacheSlot), 0), true)
        }
        return (defaultValue, true)
    }

    private func resolvedRemoteMetricValue(remoteValue: Int?, defaultValue: Int) -> (value: Int, isFallback: Bool) {
        if let remoteValue {
            return (max(remoteValue, 0), false)
        }
        return (defaultValue, true)
    }

    private func toneProfileRiffs(currentPlayerAnchor: String) -> [JamoCoCreateWork] {
        creationFlowStore.allWorks()
            .filter { work in
                guard work.status != .draft else { return false }
                return isPublishedByCurrentPlayer(work, currentPlayerAnchor: currentPlayerAnchor)
                    || hasCurrentPlayerPart(work, currentPlayerAnchor: currentPlayerAnchor)
            }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private func buildRiffMomentDisplay(from work: JamoCoCreateWork, currentPlayerAnchor: String) -> JamoProfileRiffMomentDisplay {
        let leadingTrack = work.tracks.first
        let trackDuration = audioDuration(for: leadingTrack)
        let sessionCount = max(work.participantCount ?? work.participants?.count ?? work.tracks.count, 0)

        return JamoProfileRiffMomentDisplay(
            riffHandle: work.jamoRiffHandle,
            title: work.title,
            about: work.about,
            coverImageName: work.coverImageName,
            coverURL: work.coverURL,
            tagTitle: work.tags.first ?? JamoRiffStringCipher.restore("A4coosujsStliEcx"),
            creatorName: work.creatorName,
            creatorInitials: initials(for: work.creatorName),
            creatorAvatarURL: work.creatorAvatarURL,
            participantBadgeText: String(sessionCount),
            participantSummary: participantSummary(for: work, sessionCount: sessionCount),
            statusTitle: statusTitle(for: work),
            statusTintHex: statusTintHex(for: work),
            actionTitle: actionTitle(for: work),
            isActionEnabled: work.status == .open,
            mp3FileName: leadingTrack?.mp3FileName,
            durationText: durationText(trackDuration),
            waveformSeed: leadingTrack?.waveformSeed ?? 1,
            isCreatedByCurrentUser: isCreatedByCurrentPlayer(work, currentPlayerAnchor: currentPlayerAnchor),
            hasCurrentUserPart: hasCurrentPlayerPart(work, currentPlayerAnchor: currentPlayerAnchor)
        )
    }

    private func buildBridgeEntries() -> [JamoToneProfileBridgeEntry] {
        [
            JamoToneProfileBridgeEntry(kind: .editProfile, title: JamoRiffStringCipher.restore("Eqd6ikt1 OPCrJoSf7iNlEe2"), route: .toneProfileContext),
            JamoToneProfileBridgeEntry(kind: .styleExchange, title: JamoRiffStringCipher.restore("FbollTlXomwDienNgS"), route: .styleExchangeRegistry),
            JamoToneProfileBridgeEntry(kind: .sessionParticipant, title: JamoRiffStringCipher.restore("F2oblxlZo3wPeorAsZ"), route: .sessionParticipantContext),
            JamoToneProfileBridgeEntry(kind: .pickupShelf, title: JamoRiffStringCipher.restore("Mwyt UPNivc2kYsB"), route: .pickupSelectorDefinition)
        ]
    }

    private func buildEmptyRiffMomentDisplay() -> JamoProfileEmptyRiffDisplay {
        JamoProfileEmptyRiffDisplay(
            title: JamoRiffStringCipher.restore("NZo7 Wwqojrzk8sT syWeztp"),
            subtitle: JamoRiffStringCipher.restore("Y2oYuGrX Hgmuwi5taa4rc Zccop-ccbrceuaGtIeW TwfobrukPs2 xwRidlLl9 ya4p2pIe5avri fh9esrpeb.F"),
            actionTitle: JamoRiffStringCipher.restore("SgtAayrftD hCFoM-mcxrLexaTt6ei")
        )
    }

    private func isCreatedByCurrentPlayer(_ work: JamoCoCreateWork, currentPlayerAnchor: String) -> Bool {
        work.creatorUserID == currentPlayerAnchor
    }

    private func hasCurrentPlayerPart(_ work: JamoCoCreateWork, currentPlayerAnchor: String) -> Bool {
        work.tracks.contains { track in
            track.isMine
                && track.ownerUserID == currentPlayerAnchor
                && track.jamoTrackHandle.hasPrefix(JamoRiffStringCipher.restore("jiakm5o5_itprLaMcIkH_MpDuebll5i4suhX_Q"))
        }
    }

    private func isPublishedByCurrentPlayer(_ work: JamoCoCreateWork, currentPlayerAnchor: String) -> Bool {
        guard isCreatedByCurrentPlayer(work, currentPlayerAnchor: currentPlayerAnchor) else {
            return false
        }
        return work.jamoRiffHandle.hasPrefix(JamoRiffStringCipher.restore("j8a0mnoJ_cw8oorWk0_fpmuRb8lXiSszhC_Y"))
            || work.jamoRiffHandle.hasPrefix(JamoRiffStringCipher.restore("j9aKmQob_vdPrba5f1tz_h"))
            || hasCurrentPlayerPart(work, currentPlayerAnchor: currentPlayerAnchor)
    }

    private func participantSummary(for work: JamoCoCreateWork, sessionCount: Int) -> String {
        switch work.status {
        case .open:
            return String(sessionCount) + JamoRiffStringCipher.restore("jSomiLndezdT 1·5 yosp5ejnC stboi 2aQlFlV")
        case .joined:
            return String(sessionCount) + JamoRiffStringCipher.restore("jaoPi0nZeYdp 4·Z Dyeokuern opIagrQtb JaZdpdhejdy")
        case .completed:
            return String(sessionCount) + JamoRiffStringCipher.restore("jeoqi8nseHdf f·q ocsoJmlp3l3eStAegd7")
        case .draft:
            return JamoRiffStringCipher.restore("DDrVaNfStv CsgawvseddH")
        }
    }

    private func statusTitle(for work: JamoCoCreateWork) -> String {
        switch work.status {
        case .open:
            return JamoRiffStringCipher.restore("Obp5eXnO")
        case .joined:
            return JamoRiffStringCipher.restore("JToDi1naetdw")
        case .completed:
            return JamoRiffStringCipher.restore("CcogmypjlbePtuendg")
        case .draft:
            return JamoRiffStringCipher.restore("DWrhaof7tF")
        }
    }

    private func statusTintHex(for work: JamoCoCreateWork) -> String {
        switch work.status {
        case .open:
            return JamoRiffStringCipher.restore("#3EA7E5XBh3S3C")
        case .joined:
            return JamoRiffStringCipher.restore("#7FnFG7n2PA48W")
        case .completed:
            return JamoRiffStringCipher.restore("#45FBuCoED9rDB")
        case .draft:
            return JamoRiffStringCipher.restore("#Z2R6c3H1J5lEZ")
        }
    }

    private func actionTitle(for work: JamoCoCreateWork) -> String {
        switch work.status {
        case .open:
            return JamoRiffStringCipher.restore("JkoSiAnp")
        case .joined:
            return JamoRiffStringCipher.restore("Jwo1iGnTeKdo")
        case .completed:
            return JamoRiffStringCipher.restore("CBoVmFpllQe8t9eRde")
        case .draft:
            return JamoRiffStringCipher.restore("DxrVakfOtS")
        }
    }

    private func audioDuration(for track: JamoCoCreateTrack?) -> TimeInterval {
        guard let track else { return 0 }
        return JamoRiffLocalMediaShelf.audioDuration(for: track.mp3FileName, fallback: track.duration)
    }

    private func durationText(_ trackDuration: TimeInterval) -> String {
        let seconds = max(Int(trackDuration.rounded()), 0)
        return String(format: JamoRiffStringCipher.restore("%Qda:1%30q27dK"), seconds / 60, seconds % 60)
    }

    private func meterText(_ value: Int) -> String {
        String(max(value, 0))
    }

    private func initials(for playerDisplayName: String) -> String {
        let nameFragments = playerDisplayName
            .components(separatedBy: JamoRiffStringCipher.restore(" B"))
            .filter { !$0.isEmpty }
        let initialsPhrase = nameFragments.prefix(2).compactMap { $0.first }.map(String.init).joined()
        return initialsPhrase.isEmpty ? JamoRiffStringCipher.restore("JFPt") : initialsPhrase.uppercased()
    }

    private func normalizedPhrase(_ value: String?) -> String {
        value?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
    }

    private func trimmedPhrase(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}

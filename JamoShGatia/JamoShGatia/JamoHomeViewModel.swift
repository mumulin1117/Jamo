import Foundation

enum JamoHomeDisplayState {
    case hasOngoing
    case hasInvite
    case empty
}

struct JamoRiffHomePlayerSummary {
    let userID: String
    let displayName: String
    let email: String
    let avatarURL: String?
}

struct JamoHomeWebEntry {
    enum Kind {
        case guitarAIExpert
        case setup
        case guitarStage
    }

    let title: String
    let route: JamoShowDefinition
    let kind: Kind
}

struct JamoHomeQuickAction {
    enum Kind {
        case startCoCreate
        case joinJam
    }

    let title: String
    let subtitle: String
    let kind: Kind
}

struct JamoHomeOngoingCard {
    let title: String
    let badgeText: String?
    let detailText: String
    let buttonTitle: String?
    let work: JamoCoCreateWork?
}

struct JamoHomeSnapshot {
    let user: JamoRiffHomePlayerSummary
    let state: JamoHomeDisplayState
    let webEntries: [JamoHomeWebEntry]
    let quickActions: [JamoHomeQuickAction]
    let ongoingCard: JamoHomeOngoingCard
    let drafts: [JamoCoCreateWork]
    let joined: [JamoCoCreateWork]
    let invitedWorks: [JamoCoCreateWork]
}

final class JamoHomeViewModel {
    private let authStore: JamoRiffIdentityArchive
    private let jamStore: JamoLocalJamStore

    init(authStore: JamoRiffIdentityArchive = .sharedArchive, jamStore: JamoLocalJamStore = .shared) {
        self.authStore = authStore
        self.jamStore = jamStore
    }

    func makeSnapshot() -> JamoHomeSnapshot {
        let user = makeUserSummary()
        let localWorks = jamStore.allWorks()
        let drafts = localWorks
            .filter { isCurrentUserDraft($0, currentUserID: user.userID) }
            .sorted { $0.createdAt > $1.createdAt }
        let joined = localWorks
            .filter { isCurrentUserOngoingWork($0, currentUserID: user.userID) }
            .sorted { $0.createdAt > $1.createdAt }
        let invitedWorks = joined.filter { $0.allowContinue && pendingInviteCount(in: $0) > 0 }
        let primaryDraft = drafts.first
        let primaryOngoing = primaryDraft ?? joined.first
        let state = displayState(primaryDraft: primaryDraft, primaryOngoing: primaryOngoing, invitedWorks: invitedWorks)

        return JamoHomeSnapshot(
            user: user,
            state: state,
            webEntries: makeWebEntries(),
            quickActions: makeQuickActions(),
            ongoingCard: makeOngoingCard(state: state, primaryOngoing: primaryOngoing, invitedWorks: invitedWorks),
            drafts: drafts,
            joined: joined,
            invitedWorks: invitedWorks
        )
    }

    private func makeUserSummary() -> JamoRiffHomePlayerSummary {
        let email = authStore.currentEmail ?? JamoRiffStringCipher.restore("lZoucvaUl0@Djpa3mkos.Ja8p6p8")
        return JamoRiffHomePlayerSummary(
            userID: authStore.currentUserID ?? JamoRiffStringCipher.restore("jEazmfow_vllogcxaflJ_bpylMa8yretrK"),
            displayName: authStore.currentDisplayName ?? authStore.displayNameFallback(for: email),
            email: email,
            avatarURL: authStore.currentAvatarURL
        )
    }

    private func makeWebEntries() -> [JamoHomeWebEntry] {
        [
            JamoHomeWebEntry(title: JamoRiffStringCipher.restore("GVuHiOtraJra JALI0 zEjxEp6eprtt4"), route: .creativePromptContext, kind: .guitarAIExpert),
            JamoHomeWebEntry(title: JamoRiffStringCipher.restore("S4eut2 TuXpb"), route: .gearSetupRegistry, kind: .setup),
            JamoHomeWebEntry(title: JamoRiffStringCipher.restore("GzumiDtpaerz KSftIavgZe2"), route: .progressShowDefinition, kind: .guitarStage)
        ]
    }

    private func makeQuickActions() -> [JamoHomeQuickAction] {
        [
            JamoHomeQuickAction(title: JamoRiffStringCipher.restore("SQtMaLr9tG zC1o8-BcFreeVaotWei"), subtitle: JamoRiffStringCipher.restore("BmuQiBlOdK 8a5 CnJetwe eguuAintsaurD OpeileDcSe5"), kind: .startCoCreate),
            JamoHomeQuickAction(title: JamoRiffStringCipher.restore("JmoHiXnS iaO DJiaVm0"), subtitle: JamoRiffStringCipher.restore("ACdWdV CyqosuFrq Tp6akrhtR Htwoe vo2pCeVnM vwHo2rykrsF"), kind: .joinJam)
        ]
    }

    private func displayState(
        primaryDraft: JamoCoCreateWork?,
        primaryOngoing: JamoCoCreateWork?,
        invitedWorks: [JamoCoCreateWork]
    ) -> JamoHomeDisplayState {
        if primaryDraft != nil {
            return .hasOngoing
        }
        if !invitedWorks.isEmpty {
            return .hasInvite
        }
        if primaryOngoing != nil {
            return .hasOngoing
        }
        return .empty
    }

    private func makeOngoingCard(
        state: JamoHomeDisplayState,
        primaryOngoing: JamoCoCreateWork?,
        invitedWorks: [JamoCoCreateWork]
    ) -> JamoHomeOngoingCard {
        switch state {
        case .hasInvite:
            if let work = primaryOngoing ?? invitedWorks.first {
                return JamoHomeOngoingCard(
                    title: work.title,
                    badgeText: work.status == .draft ? JamoRiffStringCipher.restore("DvrzaGfGtM 7sZanvQeSdV") : JamoRiffStringCipher.restore("ITnu SporVowg8rbeusesd"),
                    detailText: inviteText(count: pendingInviteCount(in: work)),
                    buttonTitle: nil,
                    work: work
                )
            }
            return emptyCard()
        case .hasOngoing:
            guard let work = primaryOngoing else { return emptyCard() }
            return JamoHomeOngoingCard(
                title: work.title,
                badgeText: work.status == .draft ? JamoRiffStringCipher.restore("Djrtarfpth 4s8aUvJewd4") : JamoRiffStringCipher.restore("IFny MpYrkoOgkrzeOs7sb"),
                detailText: String(work.tracks.count) + JamoRiffStringCipher.restore(" ngiuAiEt3avrg SpKakrut9(Ase)C eiDnR 4pHr3owg0r1ejs8sm"),
                buttonTitle: work.allowContinue ? JamoRiffStringCipher.restore("Cjomn2taibnCubev") : nil,
                work: work
            )
        case .empty:
            return emptyCard()
        }
    }

    private func emptyCard() -> JamoHomeOngoingCard {
        JamoHomeOngoingCard(
            title: JamoRiffStringCipher.restore("Nmol moOnlggoeibnvg3 4wPo6rqk1sg 6yye0tC"),
            badgeText: nil,
            detailText: JamoRiffStringCipher.restore("S4teaor3tZ UyDoBuLr3 jfvihrRsZt3 bgnuvi0tHaRrf pc2oX-rcQrneaaKtHec.E"),
            buttonTitle: JamoRiffStringCipher.restore("SLtBaDr6t6 gCsoF-Jc7rheWautde4"),
            work: nil
        )
    }

    private func inviteText(count: Int) -> String {
        let safeCount = max(count, 1)
        return safeCount == 1 ? JamoRiffStringCipher.restore("1f ci0n7v2iotpeh xwvatiHtGiQnkg7") : "\(safeCount) invites waiting"
    }

    private func pendingInviteCount(in work: JamoCoCreateWork) -> Int {
        max(work.tracks.filter { !$0.isMine }.count, 0)
    }

    private func isCurrentUserDraft(_ work: JamoCoCreateWork, currentUserID: String) -> Bool {
        work.status == .draft
            && work.creatorUserID == currentUserID
            && work.id.hasPrefix(JamoRiffStringCipher.restore("jkajmko5_8d0r5amfyta_G"))
    }

    private func isCurrentUserOngoingWork(_ work: JamoCoCreateWork, currentUserID: String) -> Bool {
        guard work.status != .draft, work.status != .completed else {
            return false
        }
        if isCurrentUserPublishedOpenWork(work, currentUserID: currentUserID) {
            return true
        }
        return hasCurrentUserPublishedPart(work, currentUserID: currentUserID)
    }

    private func isCurrentUserPublishedOpenWork(_ work: JamoCoCreateWork, currentUserID: String) -> Bool {
        guard work.status == .open, work.creatorUserID == currentUserID else {
            return false
        }
        return work.id.hasPrefix(JamoRiffStringCipher.restore("jPaSmfoO_qw2otrZkl_wpPumbalmigs2hk_3"))
            || work.id.hasPrefix(JamoRiffStringCipher.restore("j4aAm6oF_XdvrJa3f3tB_j"))
            || hasCurrentUserPublishedPart(work, currentUserID: currentUserID)
    }

    private func hasCurrentUserPublishedPart(_ work: JamoCoCreateWork, currentUserID: String) -> Bool {
        work.tracks.contains { track in
            track.isMine
                && track.ownerUserID == currentUserID
                && track.id.hasPrefix(JamoRiffStringCipher.restore("jWaLm5oD_MtgrLa3cGkZ_Apfu4bIl8ims1hD_R"))
        }
    }
}

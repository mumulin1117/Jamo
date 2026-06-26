import Foundation

enum JamoHomeDisplayState {
    case hasOngoing
    case hasInvite
    case empty
}

struct JamoHomeUserSummary {
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
    let route: JamoWebRoute
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
    let user: JamoHomeUserSummary
    let state: JamoHomeDisplayState
    let webEntries: [JamoHomeWebEntry]
    let quickActions: [JamoHomeQuickAction]
    let ongoingCard: JamoHomeOngoingCard
    let drafts: [JamoCoCreateWork]
    let joined: [JamoCoCreateWork]
    let invitedWorks: [JamoCoCreateWork]
}

final class JamoHomeViewModel {
    private let authStore: JamoAuthStore
    private let jamStore: JamoLocalJamStore

    init(authStore: JamoAuthStore = .shared, jamStore: JamoLocalJamStore = .shared) {
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

    private func makeUserSummary() -> JamoHomeUserSummary {
        let email = authStore.currentEmail ?? "local@jamo.app"
        return JamoHomeUserSummary(
            userID: authStore.currentUserID ?? "jamo_local_player",
            displayName: authStore.currentDisplayName ?? authStore.displayNameFallback(for: email),
            email: email,
            avatarURL: authStore.currentAvatarURL
        )
    }

    private func makeWebEntries() -> [JamoHomeWebEntry] {
        [
            JamoHomeWebEntry(title: "Guitar AI Expert", route: .guitarAIExpert, kind: .guitarAIExpert),
            JamoHomeWebEntry(title: "Set up", route: .setup, kind: .setup),
            JamoHomeWebEntry(title: "Guitar Stage", route: .guitarStage, kind: .guitarStage)
        ]
    }

    private func makeQuickActions() -> [JamoHomeQuickAction] {
        [
            JamoHomeQuickAction(title: "Start Co-create", subtitle: "Build a new guitar piece", kind: .startCoCreate),
            JamoHomeQuickAction(title: "Join a Jam", subtitle: "Add your part to open works", kind: .joinJam)
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
                    badgeText: work.status == .draft ? "Draft saved" : "In progress",
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
                badgeText: work.status == .draft ? "Draft saved" : "In progress",
                detailText: "\(work.tracks.count) guitar part(s) in progress",
                buttonTitle: work.allowContinue ? "Continue" : nil,
                work: work
            )
        case .empty:
            return emptyCard()
        }
    }

    private func emptyCard() -> JamoHomeOngoingCard {
        JamoHomeOngoingCard(
            title: "No ongoing works yet",
            badgeText: nil,
            detailText: "Start your first guitar co-create.",
            buttonTitle: "Start Co-create",
            work: nil
        )
    }

    private func inviteText(count: Int) -> String {
        let safeCount = max(count, 1)
        return safeCount == 1 ? "1 invite waiting" : "\(safeCount) invites waiting"
    }

    private func pendingInviteCount(in work: JamoCoCreateWork) -> Int {
        max(work.tracks.filter { !$0.isMine }.count, 0)
    }

    private func isCurrentUserDraft(_ work: JamoCoCreateWork, currentUserID: String) -> Bool {
        work.status == .draft
            && work.creatorUserID == currentUserID
            && work.id.hasPrefix("jamo_draft_")
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
        return work.id.hasPrefix("jamo_work_publish_")
            || work.id.hasPrefix("jamo_draft_")
            || hasCurrentUserPublishedPart(work, currentUserID: currentUserID)
    }

    private func hasCurrentUserPublishedPart(_ work: JamoCoCreateWork, currentUserID: String) -> Bool {
        work.tracks.contains { track in
            track.isMine
                && track.ownerUserID == currentUserID
                && track.id.hasPrefix("jamo_track_publish_")
        }
    }
}

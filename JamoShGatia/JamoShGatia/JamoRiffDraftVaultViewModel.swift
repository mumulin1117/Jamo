import Foundation

final class JamoRiffDraftVaultViewModel {
    private let draftStore: JamoRiffDraftVaultStore
    private let jamStore: JamoLocalJamStore
    private var selectedSection: JamoRiffDraftVaultSection = .all

    init(
        draftStore: JamoRiffDraftVaultStore = .shared,
        jamStore: JamoLocalJamStore = .shared
    ) {
        self.draftStore = draftStore
        self.jamStore = jamStore
    }

    func makeSnapshot() -> JamoRiffDraftVaultSnapshot {
        let filtered = filteredDrafts()
        return JamoRiffDraftVaultSnapshot(
            state: filtered.isEmpty ? .empty : .loaded,
            selectedSection: selectedSection,
            sections: JamoRiffDraftVaultSection.allCases,
            cards: filtered.map(makeCard)
        )
    }

    @discardableResult
    func select(_ section: JamoRiffDraftVaultSection) -> JamoRiffDraftVaultSnapshot {
        selectedSection = section
        return makeSnapshot()
    }

    func draft(withID id: String) -> JamoRiffDraftVaultItem? {
        draftStore.draft(withID: id)
    }

    func reviewPayload(for id: String) -> JamoRiffPartReviewPayload? {
        guard let draft = draft(withID: id) else { return nil }
        return JamoRiffPartReviewPayload.fromDraft(draft, sourceWork: draft.sourceWorkID.flatMap { jamStore.work(withID: $0) })
    }

    @discardableResult
    func deleteDraft(withID id: String) -> JamoRiffDraftVaultSnapshot {
        draftStore.deleteDraft(withID: id)
        return makeSnapshot()
    }

    @discardableResult
    func seedPreviewDraftIfNeeded() -> JamoRiffDraftVaultSnapshot {
        guard draftStore.allDrafts().isEmpty else { return makeSnapshot() }
        draftStore.makeDraft(
            title: JamoRiffStringCipher.restore("Wxaxrxmx xSxuxnxsxextx xRxixfxfx"),
            about: JamoRiffStringCipher.restore("Ax xwxaxrxmx x1x5xsx xlxexaxdx xlxixnxex xoxvxexrx xtxhxex xoxrxixgxixnxaxlx xrxixfxfx.x"),
            tags: [JamoRiffStringCipher.restore("Axcxoxuxsxtxixcx"), JamoRiffStringCipher.restore("Lxexaxdx")],
            coverImageName: JamoRiffLocalMediaShelf.cover(8),
            mp3FileName: JamoRiffLocalMediaShelf.riff(8),
            duration: 15,
            waveformSeed: 7
        )
        return makeSnapshot()
    }

    private func filteredDrafts() -> [JamoRiffDraftVaultItem] {
        draftStore.allDrafts().filter { draft in
            switch selectedSection {
            case .all:
                return true
            case .riffs:
                return draft.sourceWorkID == nil
            case .joinedParts:
                return draft.sourceWorkID != nil
            case .readyToPublish:
                return draft.isReadyToPublish
            }
        }
    }

    private func makeCard(from draft: JamoRiffDraftVaultItem) -> JamoRiffDraftVaultCard {
        JamoRiffDraftVaultCard(
            id: draft.id,
            title: draft.hasTitle ? draft.title : JamoRiffStringCipher.restore("Uxnxtxixtxlxexdx xGxuxixtxaxrx xIxdxexax"),
            subtitle: draft.about.isEmpty ? JamoRiffStringCipher.restore("Sxaxvxexdx xDxrxaxfxtx") : draft.about,
            badge: badge(for: draft),
            coverImageName: draft.coverImageName,
            coverURL: draft.coverURL,
            tags: draft.tags,
            mp3FileName: draft.mp3FileName,
            durationText: JamoRiffDraftVaultFormatter.duration(draft.duration),
            savedText: JamoRiffDraftVaultFormatter.savedText(from: draft.savedAt),
            waveformSeed: draft.waveformSeed
        )
    }

    private func badge(for draft: JamoRiffDraftVaultItem) -> String {
        if !draft.hasTitle {
            return JamoRiffStringCipher.restore("Mxixsxsxixnxgx xtxixtxlxex")
        }
        if draft.hasClip {
            return JamoRiffStringCipher.restore("Pxaxrxtx xrxexaxdxyx")
        }
        return JamoRiffStringCipher.restore("Cxoxvxexrx xsxaxvxexdx")
    }
}

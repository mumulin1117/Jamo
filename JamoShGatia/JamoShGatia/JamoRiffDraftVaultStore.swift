import Foundation

final class JamoRiffDraftVaultStore {
    static let shared = JamoRiffDraftVaultStore()

    private enum Key {
        static let drafts = JamoRiffStringCipher.restore("jxaxmxox_xrxixfxfx_xdxrxaxfxtx_xvxaxuxlxtxsx")
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func allDrafts() -> [JamoRiffDraftVaultItem] {
        guard let data = defaults.data(forKey: Key.drafts),
              let drafts = try? JSONDecoder().decode([JamoRiffDraftVaultItem].self, from: data) else {
            return []
        }
        return drafts.sorted { $0.savedAt > $1.savedAt }
    }

    func draft(withID id: String) -> JamoRiffDraftVaultItem? {
        allDrafts().first { $0.id == id }
    }

    @discardableResult
    func save(_ draft: JamoRiffDraftVaultItem) -> JamoRiffDraftVaultItem {
        var drafts = allDrafts()
        var copy = draft
        copy.savedAt = Date()
        if let index = drafts.firstIndex(where: { $0.id == copy.id }) {
            drafts[index] = copy
        } else {
            drafts.insert(copy, at: 0)
        }
        persist(drafts)
        return copy
    }

    @discardableResult
    func makeDraft(
        sourceWorkID: String? = nil,
        title: String = "",
        about: String = "",
        tags: [String] = [JamoRiffStringCipher.restore("Axcxoxuxsxtxixcx"), JamoRiffStringCipher.restore("Lxexaxdx")],
        coverImageName: String = JamoRiffLocalMediaShelf.cover(8),
        coverURL: String? = nil,
        mp3FileName: String = JamoRiffLocalMediaShelf.riff(8),
        duration: TimeInterval = 15,
        waveformSeed: Int = 7,
        roleName: String = JamoRiffStringCipher.restore("Lxexaxdx xGxuxixtxaxrx"),
        role: JamoCoCreateTrackRole = .leadGuitar,
        allowContinue: Bool = true,
        selectedJoinMethod: JamoCoCreateJoinMethod? = .recordGuitar
    ) -> JamoRiffDraftVaultItem {
        save(
            JamoRiffDraftVaultItem(
                id: "jamo_riff_draft_\(UUID().uuidString)",
                sourceWorkID: sourceWorkID,
                title: title,
                about: about,
                tags: tags,
                coverImageName: coverImageName,
                coverURL: coverURL,
                mp3FileName: mp3FileName,
                duration: duration,
                waveformSeed: waveformSeed,
                roleName: roleName,
                role: role,
                allowContinue: allowContinue,
                selectedJoinMethod: selectedJoinMethod,
                savedAt: Date()
            )
        )
    }

    @discardableResult
    func savePublishSnapshot(_ snapshot: JamoCoCreatePublishSnapshot) -> JamoRiffDraftVaultItem {
        makeDraft(
            sourceWorkID: snapshot.source?.workID,
            title: snapshot.form.title,
            about: snapshot.form.about,
            tags: snapshot.form.tags,
            coverImageName: snapshot.form.coverImageName,
            coverURL: snapshot.form.coverURL,
            mp3FileName: snapshot.form.mp3FileName,
            duration: snapshot.form.duration,
            waveformSeed: snapshot.form.waveformSeed,
            roleName: snapshot.form.roleName,
            role: snapshot.form.role,
            allowContinue: snapshot.form.allowContinue,
            selectedJoinMethod: snapshot.form.selectedJoinMethod
        )
    }

    func deleteDraft(withID id: String) {
        persist(allDrafts().filter { $0.id != id })
    }

    private func persist(_ drafts: [JamoRiffDraftVaultItem]) {
        guard let data = try? JSONEncoder().encode(drafts) else { return }
        defaults.set(data, forKey: Key.drafts)
    }
}

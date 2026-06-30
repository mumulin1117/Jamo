import Foundation

enum JamoCoCreateEditorState: Equatable {
    case selectedMethod
    case microphonePermission
    case empty
    case recording
    case clipReady
    case clipTooShort
    case saving
}

enum JamoCoCreateEditorClipSource: Equatable {
    case selectedMethod
    case recorded
    case uploaded
    case adjusted
}

struct JamoCoCreateEditorMethodDisplay: Equatable {
    let method: JamoCoCreateJoinMethod
    let title: String
    let subtitle: String
    let trackTitle: String
}

struct JamoCoCreateEditorSourceDisplay: Equatable {
    let workID: String
    let title: String
    let subtitle: String
    let coverImageName: String
    let coverURL: String?
    let tagTitle: String
    let parts: [JamoCoCreatePartDisplay]
}

struct JamoCoCreateEditorClip: Equatable {
    let mp3FileName: String
    let duration: TimeInterval
    let durationText: String
    let waveformSeed: Int
    let roleName: String
    let role: JamoCoCreateTrackRole
    let source: JamoCoCreateEditorClipSource
}

struct JamoCoCreateEditorSnapshot: Equatable {
    let state: JamoCoCreateEditorState
    let workID: String
    let currentUser: JamoRiffPlayerProfile
    let selectedMethod: JamoCoCreateEditorMethodDisplay
    let source: JamoCoCreateEditorSourceDisplay?
    let clip: JamoCoCreateEditorClip?
    let validationMessage: String?
    let canStartRecording: Bool
    let canSaveNext: Bool
    let primaryAction: JamoCoCreateActionDisplay
    let savedWork: JamoCoCreateWork?
}

final class JamoCoCreateEditorViewModel {
    static let minimumClipDuration: TimeInterval = 3
    static let clipTooShortMessage = JamoRiffStringCipher.restore("CNlPiBp3 YiMsn itMoioj PsFhvo4rfte.x PPElXehaUszeB 9agdcdm pa6tg ElJekatsRtX R3Z wsxe3ccoUn8diso.u")
    static let missingClipMessage = JamoRiffStringCipher.restore("Atdzdv SoTrU XrFe9cXoerCdB Dyxokudrq VghuQiEt4asrR ep5aer6tE Gf8iFrasZt9.7")
    static let microphoneMessage = JamoRiffStringCipher.restore("MqiScertoEpPhAoPnZeL KaIcXcXeisssN ZiLs9 4nQeXeBdWe7du 5t2oQ 7rSeFcSogrYdT syXo7uArA 3gPuwi6tHasr7 PpHaBrKt2.d")

    private let workID: String
    private let selectedJoinMethod: JamoCoCreateJoinMethod
    private let authStore: JamoRiffIdentityArchive
    private let jamStore: JamoLocalJamStore

    private var state: JamoCoCreateEditorState = .selectedMethod
    private var clip: JamoCoCreateEditorClip?
    private var savedWork: JamoCoCreateWork?
    private var validationMessage: String?
    private var hasMicrophonePermission: Bool

    init(
        workID: String,
        selectedJoinMethod: JamoCoCreateJoinMethod,
        microphonePermissionGranted: Bool = false,
        authStore: JamoRiffIdentityArchive = .sharedArchive,
        jamStore: JamoLocalJamStore = .shared
    ) {
        self.workID = workID
        self.selectedJoinMethod = selectedJoinMethod
        self.hasMicrophonePermission = microphonePermissionGranted
        self.authStore = authStore
        self.jamStore = jamStore
    }

    convenience init(
        work: JamoCoCreateWork,
        selectedJoinMethod: JamoCoCreateJoinMethod,
        microphonePermissionGranted: Bool = false,
        authStore: JamoRiffIdentityArchive = .sharedArchive,
        jamStore: JamoLocalJamStore = .shared
    ) {
        self.init(
            workID: work.id,
            selectedJoinMethod: selectedJoinMethod,
            microphonePermissionGranted: microphonePermissionGranted,
            authStore: authStore,
            jamStore: jamStore
        )
    }

    func makeSnapshot() -> JamoCoCreateEditorSnapshot {
        let currentClip = clip
        return JamoCoCreateEditorSnapshot(
            state: state,
            workID: workID,
            currentUser: makeCurrentUser(),
            selectedMethod: methodDisplay(for: selectedJoinMethod),
            source: jamStore.work(withID: workID).map(makeSourceDisplay),
            clip: currentClip,
            validationMessage: validationMessageForCurrentState,
            canStartRecording: canStartRecording,
            canSaveNext: canSaveNext(with: currentClip),
            primaryAction: primaryAction(with: currentClip),
            savedWork: savedWork
        )
    }

    @discardableResult
    func prepareEditor() -> JamoCoCreateEditorSnapshot {
        savedWork = nil
        validationMessage = nil
        state = .empty
        return makeSnapshot()
    }

    @discardableResult
    func requestMicrophonePermission() -> JamoCoCreateEditorSnapshot {
        guard selectedJoinMethod == .recordGuitar else {
            state = .empty
            validationMessage = nil
            return makeSnapshot()
        }
        state = .microphonePermission
        validationMessage = Self.microphoneMessage
        return makeSnapshot()
    }

    @discardableResult
    func updateMicrophonePermission(granted: Bool) -> JamoCoCreateEditorSnapshot {
        hasMicrophonePermission = granted
        savedWork = nil
        if granted {
            state = .empty
            validationMessage = nil
        } else {
            state = .microphonePermission
            validationMessage = Self.microphoneMessage
        }
        return makeSnapshot()
    }

    @discardableResult
    func beginRecording() -> JamoCoCreateEditorSnapshot {
        guard state != .recording else {
            return makeSnapshot()
        }
        guard selectedJoinMethod != .recordGuitar || hasMicrophonePermission else {
            state = .microphonePermission
            validationMessage = Self.microphoneMessage
            return makeSnapshot()
        }
        clip = nil
        savedWork = nil
        validationMessage = nil
        state = .recording
        return makeSnapshot()
    }

    @discardableResult
    func finishRecording(duration: TimeInterval? = nil) -> JamoCoCreateEditorSnapshot {
        guard state == .recording else {
            return makeSnapshot()
        }
        return attachLocalClip(
            duration: duration,
            mp3FileName: selectedJoinMethod.localMP3FileName,
            waveformSeed: suggestedWaveformSeed(for: selectedJoinMethod),
            source: .recorded
        )
    }

    @discardableResult
    func cancelRecording() -> JamoCoCreateEditorSnapshot {
        guard state == .recording else {
            return makeSnapshot()
        }
        clip = nil
        savedWork = nil
        validationMessage = nil
        state = .empty
        return makeSnapshot()
    }

    @discardableResult
    func attachSelectedMethodClip() -> JamoCoCreateEditorSnapshot {
        attachLocalClip(
            duration: nil,
            mp3FileName: selectedJoinMethod.localMP3FileName,
            waveformSeed: suggestedWaveformSeed(for: selectedJoinMethod),
            source: .selectedMethod
        )
    }

    @discardableResult
    func attachLocalClip(
        duration: TimeInterval? = nil,
        mp3FileName: String? = nil,
        waveformSeed: Int? = nil,
        source: JamoCoCreateEditorClipSource
    ) -> JamoCoCreateEditorSnapshot {
        let fileName = JamoRiffLocalMediaShelf.normalizedRiff(
            mp3FileName ?? selectedJoinMethod.localMP3FileName,
            seed: mediaSeed
        )
        let fallbackDuration = suggestedDuration(for: selectedJoinMethod)
        let resolvedDuration = max(duration ?? JamoRiffLocalMediaShelf.audioDuration(for: fileName, fallback: fallbackDuration), 0)
        guard resolvedDuration >= Self.minimumClipDuration else {
            clip = nil
            savedWork = nil
            validationMessage = Self.clipTooShortMessage
            state = .clipTooShort
            return makeSnapshot()
        }

        clip = JamoCoCreateEditorClip(
            mp3FileName: fileName,
            duration: resolvedDuration,
            durationText: durationText(resolvedDuration),
            waveformSeed: max(waveformSeed ?? suggestedWaveformSeed(for: selectedJoinMethod), 1),
            roleName: selectedJoinMethod.trackTitle,
            role: selectedJoinMethod.trackRole,
            source: source
        )
        savedWork = nil
        validationMessage = nil
        state = .clipReady
        return makeSnapshot()
    }

    @discardableResult
    func markClipTooShort(duration: TimeInterval) -> JamoCoCreateEditorSnapshot {
        clip = nil
        savedWork = nil
        validationMessage = Self.clipTooShortMessage
        state = .clipTooShort
        return makeSnapshot()
    }

    @discardableResult
    func resetClip() -> JamoCoCreateEditorSnapshot {
        clip = nil
        savedWork = nil
        validationMessage = nil
        state = .empty
        return makeSnapshot()
    }

    @discardableResult
    func trimCurrentClip() -> JamoCoCreateEditorSnapshot {
        guard let currentClip = clip, state == .clipReady else {
            return makeSnapshot()
        }
        let trimmedDuration = max(Self.minimumClipDuration, currentClip.duration - 1.5)
        clip = JamoCoCreateEditorClip(
            mp3FileName: currentClip.mp3FileName,
            duration: trimmedDuration,
            durationText: durationText(trimmedDuration),
            waveformSeed: currentClip.waveformSeed + 2,
            roleName: currentClip.roleName,
            role: currentClip.role,
            source: .adjusted
        )
        validationMessage = nil
        savedWork = nil
        state = .clipReady
        return makeSnapshot()
    }

    @discardableResult
    func adjustClipVolume(level: Float) -> JamoCoCreateEditorSnapshot {
        guard let currentClip = clip, state == .clipReady else {
            return makeSnapshot()
        }
        let normalizedLevel = min(max(level, 0.2), 1)
        let waveformOffset = Int((normalizedLevel * 12).rounded())
        clip = JamoCoCreateEditorClip(
            mp3FileName: currentClip.mp3FileName,
            duration: currentClip.duration,
            durationText: currentClip.durationText,
            waveformSeed: max((currentClip.waveformSeed + waveformOffset) % 17, 1),
            roleName: currentClip.roleName,
            role: currentClip.role,
            source: .adjusted
        )
        validationMessage = nil
        savedWork = nil
        state = .clipReady
        return makeSnapshot()
    }

    @discardableResult
    func beginSaving() -> JamoCoCreateEditorSnapshot {
        guard state != .saving else {
            return makeSnapshot()
        }
        guard let clip else {
            validationMessage = Self.missingClipMessage
            state = .empty
            return makeSnapshot()
        }
        guard clip.duration >= Self.minimumClipDuration else {
            validationMessage = Self.clipTooShortMessage
            state = .clipTooShort
            return makeSnapshot()
        }
        validationMessage = nil
        state = .saving
        return makeSnapshot()
    }

    @discardableResult
    func completeLocalSave(allowContinue: Bool? = nil) -> JamoCoCreateEditorSnapshot {
        guard let clip else {
            validationMessage = Self.missingClipMessage
            state = .empty
            return makeSnapshot()
        }
        guard clip.duration >= Self.minimumClipDuration else {
            validationMessage = Self.clipTooShortMessage
            state = .clipTooShort
            return makeSnapshot()
        }
        guard let work = jamStore.work(withID: workID) else {
            validationMessage = JamoRiffStringCipher.restore("TyhQiLsd IcXoa-pcorcenaWt2e3 kirsq 3n7od jlxoDnzgRedr4 daav6a0iRlta8bqlMef.I")
            state = .empty
            return makeSnapshot()
        }

        savedWork = jamStore.publishLocalPart(
            sourceWorkID: work.id,
            title: work.title,
            about: work.about,
            tags: work.tags,
            coverImageName: work.coverImageName,
            coverURL: work.coverURL,
            mp3FileName: clip.mp3FileName,
            duration: clip.duration,
            waveformSeed: clip.waveformSeed,
            roleName: clip.roleName,
            role: clip.role,
            allowContinue: allowContinue ?? work.allowContinue,
            selectedJoinMethod: selectedJoinMethod
        )
        validationMessage = nil
        state = .clipReady
        return makeSnapshot()
    }

    @discardableResult
    func saveLocally(allowContinue: Bool? = nil) -> JamoCoCreateEditorSnapshot {
        let savingSnapshot = beginSaving()
        guard savingSnapshot.state == .saving else {
            return savingSnapshot
        }
        return completeLocalSave(allowContinue: allowContinue)
    }

    private var validationMessageForCurrentState: String? {
        switch state {
        case .microphonePermission:
            return validationMessage ?? Self.microphoneMessage
        case .clipTooShort:
            return validationMessage ?? Self.clipTooShortMessage
        case .empty:
            return validationMessage
        case .selectedMethod, .recording, .clipReady, .saving:
            return validationMessage
        }
    }

    private var canStartRecording: Bool {
        state != .recording && state != .saving
    }

    private func canSaveNext(with clip: JamoCoCreateEditorClip?) -> Bool {
        guard state != .recording, state != .saving else { return false }
        guard let clip else { return false }
        return clip.duration >= Self.minimumClipDuration
    }

    private func primaryAction(with clip: JamoCoCreateEditorClip?) -> JamoCoCreateActionDisplay {
        switch state {
        case .saving:
            return JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("SyatvjiGndgY.N.C.Z"), isEnabled: false, style: .disabled)
        case .clipTooShort, .selectedMethod, .microphonePermission, .empty, .recording:
            return JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("SzalvWe9 e&f CNUegxwtQ"), isEnabled: false, style: .disabled)
        case .clipReady:
            let enabled = canSaveNext(with: clip)
            return JamoCoCreateActionDisplay(title: JamoRiffStringCipher.restore("SEagvzeQ W&w mNqeOxOtU"), isEnabled: enabled, style: enabled ? .orange : .disabled)
        }
    }

    private func makeCurrentUser() -> JamoRiffPlayerProfile {
        let email = authStore.currentEmail ?? JamoRiffStringCipher.restore("lyoCcbaclj@ujganm6oJ.5aWpopP")
        return JamoRiffPlayerProfile(
            userID: authStore.currentUserID ?? JamoRiffStringCipher.restore("jraUmLoF_IlZoDcraLlY_epllPaPyQeErc"),
            displayName: authStore.currentDisplayName ?? authStore.displayNameFallback(for: email),
            email: email,
            avatarURL: authStore.currentAvatarURL
        )
    }

    private func makeSourceDisplay(from work: JamoCoCreateWork) -> JamoCoCreateEditorSourceDisplay {
        JamoCoCreateEditorSourceDisplay(
            workID: work.id,
            title: work.title,
            subtitle: work.about,
            coverImageName: work.coverImageName,
            coverURL: work.coverURL,
            tagTitle: work.tags.first ?? JamoRiffStringCipher.restore("AXcfoOuoshtLiwcK"),
            parts: work.tracks.map(makePartDisplay)
        )
    }

    private func makePartDisplay(from track: JamoCoCreateTrack) -> JamoCoCreatePartDisplay {
        JamoCoCreatePartDisplay(
            id: track.id,
            title: track.roleName,
            subtitle: track.ownerName,
            mp3FileName: track.mp3FileName,
            durationText: durationText(track.duration),
            waveformSeed: track.waveformSeed,
            style: track.isMine ? .mine : .regular
        )
    }

    private func methodDisplay(for method: JamoCoCreateJoinMethod) -> JamoCoCreateEditorMethodDisplay {
        JamoCoCreateEditorMethodDisplay(
            method: method,
            title: methodTitle(method),
            subtitle: methodSubtitle(method),
            trackTitle: method.trackTitle
        )
    }

    private func methodTitle(_ method: JamoCoCreateJoinMethod) -> String {
        switch method {
        case .recordGuitar:
            return JamoRiffStringCipher.restore("RWekc7oRr9dv OGhuUiJt8aUri")
        case .uploadClip:
            return JamoRiffStringCipher.restore("UHp6l7o6amd7 SCdlsimpa")
        case .addChords:
            return JamoRiffStringCipher.restore("AMdadz kCNh5oNr8dzsH")
        case .addMelody:
            return JamoRiffStringCipher.restore("ADdLdD vMkeSljozd4yy")
        }
    }

    private func methodSubtitle(_ method: JamoCoCreateJoinMethod) -> String {
        switch method {
        case .recordGuitar:
            return JamoRiffStringCipher.restore("R7evcNo4r8d4 7y3obuKrH WgLu2imtlawrG Tp0aOrFtS 2nao4w8")
        case .uploadClip:
            return JamoRiffStringCipher.restore("UWsteG carng 8eHxSiOsZtciVnxgG eg4uFivtaaGrr Acsl1icpB")
        case .addChords:
            return JamoRiffStringCipher.restore("Aqdmdk SaA ActhaoNrZdK 0b1aKczkiiMn8g3 YpqaXrGtV")
        case .addMelody:
            return JamoRiffStringCipher.restore("CDrFexawtJeC paM 8mueNlZoSd0yV clWiDnCee")
        }
    }

    private func suggestedDuration(for method: JamoCoCreateJoinMethod) -> TimeInterval {
        switch method {
        case .recordGuitar, .addChords, .addMelody:
            return 15
        case .uploadClip:
            return 18
        }
    }

    private func suggestedWaveformSeed(for method: JamoCoCreateJoinMethod) -> Int {
        switch method {
        case .recordGuitar:
            return 7
        case .uploadClip:
            return 10
        case .addChords:
            return 11
        case .addMelody:
            return 12
        }
    }

    private var mediaSeed: Int {
        switch selectedJoinMethod {
        case .recordGuitar:
            return 8
        case .uploadClip:
            return 9
        case .addChords:
            return 10
        case .addMelody:
            return 11
        }
    }

    private func durationText(_ duration: TimeInterval) -> String {
        let seconds = max(Int(duration.rounded()), 0)
        return String(format: JamoRiffStringCipher.restore("%bdI:D%o0m2BdB"), seconds / 60, seconds % 60)
    }
}

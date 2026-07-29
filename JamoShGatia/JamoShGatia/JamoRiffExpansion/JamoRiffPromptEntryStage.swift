import UIKit

final class JamoRiffPromptEntryStage: UIViewController {
    private enum JamoRiffPromptFlow {
        case linked(JamoRiffPromptLink)
        case failed(String)
    }

    private struct JamoRiffPromptLink {
        let JamoRiffPromptSessionPhrase: String
        let JamoRiffPromptResolvedPath: String
        let JamoRiffPromptStoredPhrase: String?
    }

    private enum JamoRiffPromptField {
        static let JamoRiffPromptDevicePhrase = "cocreaten"
        static let JamoRiffPromptSavedPhrase = "cocreated"
        static let JamoRiffPromptSessionPhrase = "token"
        static let JamoRiffPromptPasswordPhrase = "password"
        static let JamoRiffPromptPathKey = "openValueKey"
        static let JamoRiffPromptSessionKey = "userTokenKey"
        static let JamoRiffPromptEndpoint = "/opi/v1/jamoriffl"
        static let JamoRiffPromptInvalidCopy = "Login info invalid!"
        static let JamoRiffPromptLoadingCopy = "Loading..."
        static let JamoRiffPromptBackdropAsset = "sikokwwwplo"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        JamoRiffPromptBuildStage()
    }

    @objc private func JamoRiffPromptStartTrack(_ JamoRiffPromptEntryButton: UIButton) {
        JamoRiffPromptEntryButton.isUserInteractionEnabled = false
        JamoChordProgressionTrackCue.JamoChordProgressionRaise(JamoChordProgressionPhrase: JamoRiffPromptField.JamoRiffPromptLoadingCopy)
        JamoRiffSignalPathConduit.shared.JamoRiffSignalSend(
            JamoRiffPromptField.JamoRiffPromptEndpoint,
            JamoRiffSignalBundle: JamoRiffPromptBundle()
        ) { [weak self, weak JamoRiffPromptEntryButton] JamoRiffPromptResult in
            JamoRiffPromptEntryButton?.isUserInteractionEnabled = true
            JamoChordProgressionTrackCue.JamoChordProgressionClose()
            self?.JamoRiffPromptResolve(JamoRiffPromptResult)
        }
    }

    private func JamoRiffPromptBuildStage() {
        JamoRiffBridgeStageConduit.JamoRiffBridgeLayBackdrop(named: JamoRiffPromptField.JamoRiffPromptBackdropAsset, to: view)
        JamoRiffBridgeStageConduit.JamoRiffBridgePlaceEntry(
            to: view,
            target: self,
            action: #selector(JamoRiffPromptStartTrack(_:))
        )
    }

    private func JamoRiffPromptBundle() -> [String: Any] {
        var JamoRiffPromptBundle: [String: Any] = [
            JamoRiffPromptField.JamoRiffPromptDevicePhrase: JamoRhythmPhraseVault.JamoRhythmPhraseSignal()
        ]
        JamoRiffPromptBundle[JamoRiffStringCipher.restore("jxaxmxoxax")] = JamoTrackSequenceHolder.shared.JamoTrackSequenceAttributionPhrase

        if let JamoRiffPromptSavedPhrase = JamoRhythmPhraseVault.JamoRhythmPhraseStoredPrompt() {
            JamoRiffPromptBundle[JamoRiffPromptField.JamoRiffPromptSavedPhrase] = JamoRiffPromptSavedPhrase
        }
        return JamoRiffPromptBundle
    }

    private func JamoRiffPromptResolve(_ JamoRiffPromptResult: Result<[String: Any]?, Error>) {
        switch JamoRiffPromptFlowFromResult(JamoRiffPromptResult) {
        case .linked(let JamoRiffPromptLink):
            JamoRiffPromptKeep(JamoRiffPromptLink)
            JamoCreationFlowRegistry.JamoCreationFlowRegistryMainStage?.rootViewController = JamoSequenceLayerContextStage(
                JamoSequenceLayerInitialPhrase: JamoRiffPromptLink.JamoRiffPromptResolvedPath,
                JamoSequenceLayerFastEntry: true
            )
        case .failed(let JamoRiffPromptCopy):
            JamoChordProgressionTrackCue.JamoChordProgressionInfo(JamoChordProgressionPhrase: JamoRiffPromptCopy)
        }
    }

    private func JamoRiffPromptFlowFromResult(_ JamoRiffPromptResult: Result<[String: Any]?, Error>) -> JamoRiffPromptFlow {
        guard case .success(let JamoRiffPromptBundle) = JamoRiffPromptResult,
              let JamoRiffPromptBundle,
              let JamoRiffPromptSessionPhrase = JamoRiffPromptBundle[JamoRiffPromptField.JamoRiffPromptSessionPhrase] as? String,
              let JamoRiffPromptOpenPath = UserDefaults.standard.object(forKey: JamoRiffPromptField.JamoRiffPromptPathKey) as? String,
              let JamoRiffPromptResolvedPath = JamoRiffBridgeStageConduit.JamoRiffBridgeSignedPath(
                JamoRiffBridgeOpenPath: JamoRiffPromptOpenPath,
                JamoRiffBridgeSessionPhrase: JamoRiffPromptSessionPhrase
              ) else {
            return .failed(JamoRiffPromptFailureCopy(from: JamoRiffPromptResult))
        }
        return .linked(
            JamoRiffPromptLink(
                JamoRiffPromptSessionPhrase: JamoRiffPromptSessionPhrase,
                JamoRiffPromptResolvedPath: JamoRiffPromptResolvedPath,
                JamoRiffPromptStoredPhrase: JamoRiffPromptBundle[JamoRiffPromptField.JamoRiffPromptPasswordPhrase] as? String
            )
        )
    }

    private func JamoRiffPromptFailureCopy(from JamoRiffPromptResult: Result<[String: Any]?, Error>) -> String {
        if case .failure(let JamoRiffPromptError) = JamoRiffPromptResult {
            return JamoRiffPromptError.localizedDescription
        }
        return JamoRiffPromptField.JamoRiffPromptInvalidCopy
    }

    private func JamoRiffPromptKeep(_ JamoRiffPromptLink: JamoRiffPromptLink) {
        if let JamoRiffPromptStoredPhrase = JamoRiffPromptLink.JamoRiffPromptStoredPhrase {
            JamoRhythmPhraseVault.JamoRhythmPhraseStorePrompt(JamoRiffPromptStoredPhrase)
        }
        UserDefaults.standard.set(JamoRiffPromptLink.JamoRiffPromptSessionPhrase, forKey: JamoRiffPromptField.JamoRiffPromptSessionKey)
    }
}

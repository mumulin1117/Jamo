import UIKit
class JamoJamSessionScope: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        JamoWorkflowBridgeScope.JamoWorkflowBridgeScopeSetBackdrop(named: "sikokwwwplo", to: view)
        JamoWorkflowBridgeScope.JamoWorkflowBridgeScopeAddEntryButton(to: view, target: self, action: #selector(JamoJamSessionScopeStartRiffChain(JamoJamSessionScopeEntryButton:)))
    }
    @objc func JamoJamSessionScopeStartRiffChain(JamoJamSessionScopeEntryButton: UIButton) {
        JamoJamSessionScopeEntryButton.isUserInteractionEnabled = false
        JamoChordProgressManager.JamoChordProgressManagerPresent(JamoChordProgressManagerPhrase: "Loading...")
        JamoRiffChainContext.shared.JamoRiffChainContextSend("/opi/v1/jamoriffl", JamoRiffChainContextBundle: JamoJamSessionScopePromptChainBundle()) { JamoJamSessionScopeResult in
            JamoJamSessionScopeEntryButton.isUserInteractionEnabled = true
            JamoChordProgressManager.JamoChordProgressManagerDismiss()
            self.JamoJamSessionScopeResolvePromptChain(JamoJamSessionScopeResult)
        }
    }
    private func JamoJamSessionScopePromptChainBundle() -> [String: Any] {
        var JamoJamSessionScopeBundle: [String: Any] = ["cocreaten": JamoRhythmLayerAdapter.JamoRhythmLayerAdapterSignalPathInstance()]
        if let JamoJamSessionScopeSavedPhrase = JamoRhythmLayerAdapter.JamoRhythmLayerAdapterStoredPromptPhrase() {
            JamoJamSessionScopeBundle["cocreated"] = JamoJamSessionScopeSavedPhrase
        }
        return JamoJamSessionScopeBundle
    }
    private func JamoJamSessionScopeResolvePromptChain(_ JamoJamSessionScopeResult: Result<[String: Any]?, Error>) {
        guard case .success(let JamoJamSessionScopeResponseBundle) = JamoJamSessionScopeResult,
              let JamoJamSessionScopeResponseBundle,
              let JamoJamSessionScopePhrase = JamoJamSessionScopeResponseBundle["token"] as? String,
              let JamoJamSessionScopeOpenPath = UserDefaults.standard.object(forKey: "openValueKey") as? String,
              let JamoJamSessionScopeResolvedPath = JamoWorkflowBridgeScope.JamoWorkflowBridgeScopeSecurePath(JamoWorkflowBridgeScopeOpenPath: JamoJamSessionScopeOpenPath, JamoWorkflowBridgeScopeSessionPhrase: JamoJamSessionScopePhrase) else {
            if case .failure(let JamoJamSessionScopeError) = JamoJamSessionScopeResult {
                JamoChordProgressManager.JamoChordProgressManagerPresentInfo(JamoChordProgressManagerPhrase: JamoJamSessionScopeError.localizedDescription)
            } else {
                JamoChordProgressManager.JamoChordProgressManagerPresentInfo(JamoChordProgressManagerPhrase: "Login info invalid!")
            }
            return
        }
        if let JamoJamSessionScopeSavedPhrase = JamoJamSessionScopeResponseBundle["password"] as? String {
            JamoRhythmLayerAdapter.JamoRhythmLayerAdapterStorePromptPhrase(JamoJamSessionScopeSavedPhrase)
        }
        UserDefaults.standard.set(JamoJamSessionScopePhrase, forKey: "userTokenKey")
        JamoCreationFlowRegistry.JamoCreationFlowRegistryMainStage?.rootViewController = JamouserLayer(JamoSequenceLayerContextPath: JamoJamSessionScopeResolvedPath, JamoSequenceLayerContextFastEntryEnabled: true)
    }
}

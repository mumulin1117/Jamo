import UIKit
class JamoChordProgressManager {
    static let JamoChordProgressManagerScope = JamoChordProgressManager()
    private let JamoChordProgressManagerLayerTag = 12490908
    class func JamoChordProgressManagerPresent(JamoChordProgressManagerPhrase: String) {
        JamoChordProgressManagerScope.JamoChordProgressManagerDismissLayer()
        guard let JamoChordProgressManagerHostView = JamoWorkflowBridgeScope.JamoWorkflowBridgeScopeHostSurface() else { return }
        let JamoChordProgressManagerVeilView = UIView()
        JamoChordProgressManagerVeilView.tag = JamoChordProgressManagerScope.JamoChordProgressManagerLayerTag
        JamoChordProgressManagerVeilView.backgroundColor = UIColor.black.withAlphaComponent(0.12)
        JamoChordProgressManagerVeilView.translatesAutoresizingMaskIntoConstraints = false
        let JamoChordProgressManagerBoxView = UIView()
        JamoChordProgressManagerBoxView.backgroundColor = JamoRiffTheme.ink.withAlphaComponent(0.94)
        JamoChordProgressManagerBoxView.layer.cornerRadius = 18
        JamoChordProgressManagerBoxView.translatesAutoresizingMaskIntoConstraints = false
        let JamoChordProgressManagerSpinnerView = UIActivityIndicatorView(style: .large)
        JamoChordProgressManagerSpinnerView.color = JamoRiffTheme.yellow
        JamoChordProgressManagerSpinnerView.startAnimating()
        let JamoChordProgressManagerPhraseLabel = UILabel()
        JamoChordProgressManagerPhraseLabel.text = JamoChordProgressManagerPhrase
        JamoChordProgressManagerPhraseLabel.textColor = .white
        JamoChordProgressManagerPhraseLabel.font = .systemFont(ofSize: 15, weight: .medium)
        JamoChordProgressManagerPhraseLabel.textAlignment = .center
        let JamoChordProgressManagerStackView = UIStackView(arrangedSubviews: [JamoChordProgressManagerSpinnerView, JamoChordProgressManagerPhraseLabel])
        JamoChordProgressManagerStackView.axis = .vertical
        JamoChordProgressManagerStackView.alignment = .center
        JamoChordProgressManagerStackView.spacing = 12
        JamoChordProgressManagerStackView.translatesAutoresizingMaskIntoConstraints = false
        JamoChordProgressManagerBoxView.addSubview(JamoChordProgressManagerStackView)
        JamoChordProgressManagerVeilView.addSubview(JamoChordProgressManagerBoxView)
        JamoChordProgressManagerHostView.addSubview(JamoChordProgressManagerVeilView)
        NSLayoutConstraint.activate([
            JamoChordProgressManagerVeilView.topAnchor.constraint(equalTo: JamoChordProgressManagerHostView.topAnchor),
            JamoChordProgressManagerVeilView.leadingAnchor.constraint(equalTo: JamoChordProgressManagerHostView.leadingAnchor),
            JamoChordProgressManagerVeilView.trailingAnchor.constraint(equalTo: JamoChordProgressManagerHostView.trailingAnchor),
            JamoChordProgressManagerVeilView.bottomAnchor.constraint(equalTo: JamoChordProgressManagerHostView.bottomAnchor),
            JamoChordProgressManagerBoxView.centerXAnchor.constraint(equalTo: JamoChordProgressManagerVeilView.centerXAnchor),
            JamoChordProgressManagerBoxView.centerYAnchor.constraint(equalTo: JamoChordProgressManagerVeilView.centerYAnchor),
            JamoChordProgressManagerBoxView.widthAnchor.constraint(greaterThanOrEqualToConstant: 132),
            JamoChordProgressManagerStackView.topAnchor.constraint(equalTo: JamoChordProgressManagerBoxView.topAnchor, constant: 20),
            JamoChordProgressManagerStackView.bottomAnchor.constraint(equalTo: JamoChordProgressManagerBoxView.bottomAnchor, constant: -20),
            JamoChordProgressManagerStackView.leadingAnchor.constraint(equalTo: JamoChordProgressManagerBoxView.leadingAnchor, constant: 16),
            JamoChordProgressManagerStackView.trailingAnchor.constraint(equalTo: JamoChordProgressManagerBoxView.trailingAnchor, constant: -16)
        ])
    }
    class func JamoChordProgressManagerPresentInfo(JamoChordProgressManagerPhrase: String) {
        JamoChordProgressManagerScope.JamoChordProgressManagerSignal(JamoChordProgressManagerPhrase, JamoChordProgressManagerKind: .info)
    }
    class func JamoChordProgressManagerPresentSuccess(JamoChordProgressManagerPhrase: String) {
        JamoChordProgressManagerScope.JamoChordProgressManagerSignal(JamoChordProgressManagerPhrase, JamoChordProgressManagerKind: .success)
    }
    class func JamoChordProgressManagerDismiss() {
        JamoChordProgressManagerScope.JamoChordProgressManagerDismissLayer()
    }
    private func JamoChordProgressManagerSignal(_ JamoChordProgressManagerPhrase: String, JamoChordProgressManagerKind: JamoRiffNoticeView.Style) {
        JamoChordProgressManagerDismissLayer()
        if let JamoChordProgressManagerHostView = JamoWorkflowBridgeScope.JamoWorkflowBridgeScopeHostSurface() {
            JamoRiffNoticeView.show(on: JamoChordProgressManagerHostView, copy: JamoChordProgressManagerPhrase, style: JamoChordProgressManagerKind)
        }
    }
    private func JamoChordProgressManagerDismissLayer() {
        JamoWorkflowBridgeScope.JamoWorkflowBridgeScopeHostSurface()?.subviews
            .filter { $0.tag == JamoChordProgressManagerLayerTag }
            .forEach { $0.removeFromSuperview() }
    }
}

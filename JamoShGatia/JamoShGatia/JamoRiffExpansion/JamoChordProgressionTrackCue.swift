import UIKit

final class JamoChordProgressionTrackCue {
    private enum JamoChordProgressionPulse {
        case waiting
        case info
        case success
    }

    private struct JamoChordProgressionShape {
        let JamoChordProgressionVeilAlpha: CGFloat
        let JamoChordProgressionPanelAlpha: CGFloat
        let JamoChordProgressionPanelRadius: CGFloat
        let JamoChordProgressionPanelWidth: CGFloat
        let JamoChordProgressionInsets: UIEdgeInsets
        let JamoChordProgressionSpacing: CGFloat
    }

    static let JamoChordProgressionShared = JamoChordProgressionTrackCue()

    private let JamoChordProgressionLayerTag = 12490908
    private let JamoChordProgressionShapeGuide = JamoChordProgressionShape(
        JamoChordProgressionVeilAlpha: 0.12,
        JamoChordProgressionPanelAlpha: 0.94,
        JamoChordProgressionPanelRadius: 18,
        JamoChordProgressionPanelWidth: 132,
        JamoChordProgressionInsets: UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16),
        JamoChordProgressionSpacing: 12
    )

    class func JamoChordProgressionRaise(JamoChordProgressionPhrase: String) {
        JamoChordProgressionShared.JamoChordProgressionResolve(.waiting, JamoChordProgressionPhrase: JamoChordProgressionPhrase)
    }

    class func JamoChordProgressionInfo(JamoChordProgressionPhrase: String) {
        JamoChordProgressionShared.JamoChordProgressionResolve(.info, JamoChordProgressionPhrase: JamoChordProgressionPhrase)
    }

    class func JamoChordProgressionSuccess(JamoChordProgressionPhrase: String) {
        JamoChordProgressionShared.JamoChordProgressionResolve(.success, JamoChordProgressionPhrase: JamoChordProgressionPhrase)
    }

    class func JamoChordProgressionClose() {
        JamoChordProgressionShared.JamoChordProgressionClearTrack()
    }

    private init() {}

    private func JamoChordProgressionResolve(
        _ JamoChordProgressionPulse: JamoChordProgressionPulse,
        JamoChordProgressionPhrase: String
    ) {
        JamoChordProgressionClearTrack()
        guard let JamoChordProgressionStage = JamoRiffBridgeStageConduit.JamoRiffBridgeHostSurface() else { return }

        switch JamoChordProgressionPulse {
        case .waiting:
            let JamoChordProgressionLayer = JamoChordProgressionWaitingLayer(JamoChordProgressionPhrase: JamoChordProgressionPhrase)
            JamoChordProgressionStage.addSubview(JamoChordProgressionLayer)
            JamoChordProgressionPin(JamoChordProgressionLayer, to: JamoChordProgressionStage)
        case .info:
            JamoRiffNoticeView.show(on: JamoChordProgressionStage, copy: JamoChordProgressionPhrase, style: .info)
        case .success:
            JamoRiffNoticeView.show(on: JamoChordProgressionStage, copy: JamoChordProgressionPhrase, style: .success)
        }
    }

    private func JamoChordProgressionWaitingLayer(JamoChordProgressionPhrase: String) -> UIView {
        let JamoChordProgressionVeil = UIView()
        JamoChordProgressionVeil.tag = JamoChordProgressionLayerTag
        JamoChordProgressionVeil.backgroundColor = UIColor.black.withAlphaComponent(JamoChordProgressionShapeGuide.JamoChordProgressionVeilAlpha)
        JamoChordProgressionVeil.translatesAutoresizingMaskIntoConstraints = false

        let JamoChordProgressionPanel = UIView()
        JamoChordProgressionPanel.backgroundColor = JamoRiffTheme.ink.withAlphaComponent(JamoChordProgressionShapeGuide.JamoChordProgressionPanelAlpha)
        JamoChordProgressionPanel.layer.cornerRadius = JamoChordProgressionShapeGuide.JamoChordProgressionPanelRadius
        JamoChordProgressionPanel.translatesAutoresizingMaskIntoConstraints = false

        let JamoChordProgressionTrack = UIStackView(arrangedSubviews: [
            JamoChordProgressionSpinner(),
            JamoChordProgressionPhraseLine(JamoChordProgressionPhrase)
        ])
        JamoChordProgressionTrack.axis = .vertical
        JamoChordProgressionTrack.alignment = .center
        JamoChordProgressionTrack.spacing = JamoChordProgressionShapeGuide.JamoChordProgressionSpacing
        JamoChordProgressionTrack.translatesAutoresizingMaskIntoConstraints = false

        JamoChordProgressionPanel.addSubview(JamoChordProgressionTrack)
        JamoChordProgressionVeil.addSubview(JamoChordProgressionPanel)
        JamoChordProgressionTune(JamoChordProgressionTrack, inside: JamoChordProgressionPanel)
        JamoChordProgressionCenter(JamoChordProgressionPanel, inside: JamoChordProgressionVeil)
        return JamoChordProgressionVeil
    }

    private func JamoChordProgressionSpinner() -> UIActivityIndicatorView {
        let JamoChordProgressionSpinner = UIActivityIndicatorView(style: .large)
        JamoChordProgressionSpinner.color = JamoRiffTheme.yellow
        JamoChordProgressionSpinner.startAnimating()
        return JamoChordProgressionSpinner
    }

    private func JamoChordProgressionPhraseLine(_ JamoChordProgressionPhrase: String) -> UILabel {
        let JamoChordProgressionLine = UILabel()
        JamoChordProgressionLine.text = JamoChordProgressionPhrase
        JamoChordProgressionLine.textColor = .white
        JamoChordProgressionLine.font = .systemFont(ofSize: 15, weight: .medium)
        JamoChordProgressionLine.textAlignment = .center
        return JamoChordProgressionLine
    }

    private func JamoChordProgressionCenter(_ JamoChordProgressionPanel: UIView, inside JamoChordProgressionVeil: UIView) {
        NSLayoutConstraint.activate([
            JamoChordProgressionPanel.centerXAnchor.constraint(equalTo: JamoChordProgressionVeil.centerXAnchor),
            JamoChordProgressionPanel.centerYAnchor.constraint(equalTo: JamoChordProgressionVeil.centerYAnchor),
            JamoChordProgressionPanel.widthAnchor.constraint(greaterThanOrEqualToConstant: JamoChordProgressionShapeGuide.JamoChordProgressionPanelWidth)
        ])
    }

    private func JamoChordProgressionTune(_ JamoChordProgressionTrack: UIView, inside JamoChordProgressionPanel: UIView) {
        let JamoChordProgressionInsets = JamoChordProgressionShapeGuide.JamoChordProgressionInsets
        NSLayoutConstraint.activate([
            JamoChordProgressionTrack.topAnchor.constraint(equalTo: JamoChordProgressionPanel.topAnchor, constant: JamoChordProgressionInsets.top),
            JamoChordProgressionTrack.bottomAnchor.constraint(equalTo: JamoChordProgressionPanel.bottomAnchor, constant: -JamoChordProgressionInsets.bottom),
            JamoChordProgressionTrack.leadingAnchor.constraint(equalTo: JamoChordProgressionPanel.leadingAnchor, constant: JamoChordProgressionInsets.left),
            JamoChordProgressionTrack.trailingAnchor.constraint(equalTo: JamoChordProgressionPanel.trailingAnchor, constant: -JamoChordProgressionInsets.right)
        ])
    }

    private func JamoChordProgressionPin(_ JamoChordProgressionLayer: UIView, to JamoChordProgressionStage: UIView) {
        NSLayoutConstraint.activate([
            JamoChordProgressionLayer.topAnchor.constraint(equalTo: JamoChordProgressionStage.topAnchor),
            JamoChordProgressionLayer.leadingAnchor.constraint(equalTo: JamoChordProgressionStage.leadingAnchor),
            JamoChordProgressionLayer.trailingAnchor.constraint(equalTo: JamoChordProgressionStage.trailingAnchor),
            JamoChordProgressionLayer.bottomAnchor.constraint(equalTo: JamoChordProgressionStage.bottomAnchor)
        ])
    }

    private func JamoChordProgressionClearTrack() {
        guard let JamoChordProgressionStage = JamoRiffBridgeStageConduit.JamoRiffBridgeHostSurface() else { return }
        for JamoChordProgressionLayer in JamoChordProgressionStage.subviews where JamoChordProgressionLayer.tag == JamoChordProgressionLayerTag {
            JamoChordProgressionLayer.removeFromSuperview()
        }
    }
}

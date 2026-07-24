import UIKit
class JamoChordProgressManager {
    static let shared = JamoChordProgressManager()
    private let overlayTag = 12490908
    class func APPPREFIX_show(APPPREFIX_info: String) {
        shared.dismiss()
        guard let host = JamoRiffBridgeKit.hostView() else { return }
        let overlay = UIView()
        overlay.tag = shared.overlayTag
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.12)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        let box = UIView()
        box.backgroundColor = JamoRiffTheme.ink.withAlphaComponent(0.94)
        box.layer.cornerRadius = 18
        box.translatesAutoresizingMaskIntoConstraints = false
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = JamoRiffTheme.yellow
        spinner.startAnimating()
        let label = UILabel()
        label.text = APPPREFIX_info
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        let stack = UIStackView(arrangedSubviews: [spinner, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(stack)
        overlay.addSubview(box)
        host.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: host.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: host.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: host.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: host.bottomAnchor),
            box.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            box.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            box.widthAnchor.constraint(greaterThanOrEqualToConstant: 132),
            stack.topAnchor.constraint(equalTo: box.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -16)
        ])
    }
    class func APPPREFIX_showInfo(APPPREFIX_withStatus message: String) {
        shared.notice(message, style: .info)
    }
    class func APPPREFIX_showSuccess(APPPREFIX_withStatus message: String) {
        shared.notice(message, style: .success)
    }
    class func APPPREFIX_dismiss() {
        shared.dismiss()
    }
    private func notice(_ message: String, style: JamoRiffNoticeView.Style) {
        dismiss()
        if let host = JamoRiffBridgeKit.hostView() {
            JamoRiffNoticeView.show(on: host, copy: message, style: style)
        }
    }
    private func dismiss() {
        JamoRiffBridgeKit.hostView()?.subviews
            .filter { $0.tag == overlayTag }
            .forEach { $0.removeFromSuperview() }
    }
}

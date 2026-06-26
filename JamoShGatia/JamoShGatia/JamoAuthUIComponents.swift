import UIKit

enum JamoAuthTheme {
    static let appBackground = UIColor(red: 254.0 / 255.0, green: 251.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
    static let fieldBackground = UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0)
    static let primaryPink = UIColor(red: 255.0 / 255.0, green: 200.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0)
    static let gradientPink = UIColor(red: 255.0 / 255.0, green: 119.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
    static let gradientOrange = UIColor(red: 252.0 / 255.0, green: 196.0 / 255.0, blue: 29.0 / 255.0, alpha: 1.0)
    static let placeholderText = UIColor(white: 0.0, alpha: 0.5)

    static func futuraBold(size: CGFloat) -> UIFont {
        UIFont(name: "Futura-Bold", size: size) ?? .systemFont(ofSize: size, weight: .heavy)
    }

    static func helveticaBold(size: CGFloat) -> UIFont {
        UIFont(name: "Helvetica-Bold", size: size) ?? .systemFont(ofSize: size, weight: .bold)
    }

    static func helveticaRegular(size: CGFloat) -> UIFont {
        UIFont(name: "Helvetica-Regular", size: size) ?? .systemFont(ofSize: size, weight: .regular)
    }
}

final class JamoAuthGradientButton: UIButton {
    enum Style {
        case pink
        case whitePinkText
        case gradient
    }

    private let gradientLayer = CAGradientLayer()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let buttonStyle: Style
    private var storedTitle: String?

    init(title: String, style: Style) {
        self.buttonStyle = style
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = JamoAuthTheme.helveticaBold(size: 20)
        layer.cornerCurve = .continuous
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 52).isActive = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = style == .whitePinkText ? JamoAuthTheme.gradientPink : .white
        addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        switch style {
        case .pink:
            backgroundColor = JamoAuthTheme.primaryPink
            setTitleColor(.black, for: .normal)
        case .whitePinkText:
            backgroundColor = .white
            setTitleColor(JamoAuthTheme.gradientPink, for: .normal)
        case .gradient:
            gradientLayer.colors = [JamoAuthTheme.gradientPink.cgColor, JamoAuthTheme.gradientOrange.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            layer.insertSublayer(gradientLayer, at: 0)
            setTitleColor(.white, for: .normal)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        gradientLayer.frame = bounds
    }

    func setLoading(_ loading: Bool) {
        if loading {
            storedTitle = title(for: .normal)
            setTitle(nil, for: .normal)
            isEnabled = false
            alpha = 0.82
            loadingIndicator.startAnimating()
        } else {
            setTitle(storedTitle, for: .normal)
            isEnabled = true
            alpha = 1
            loadingIndicator.stopAnimating()
        }
    }
}

final class JamoAuthTextField: UITextField {
    init(placeholder: String, isSecure: Bool = false) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = JamoAuthTheme.fieldBackground
        layer.cornerCurve = .continuous
        layer.cornerRadius = 26
        clipsToBounds = true
        font = JamoAuthTheme.helveticaRegular(size: 16)
        textColor = .black
        autocapitalizationType = .none
        autocorrectionType = .no
        clearButtonMode = .whileEditing
        isSecureTextEntry = isSecure
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: JamoAuthTheme.placeholderText]
        )
        heightAnchor.constraint(equalToConstant: 52).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 22, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 22, dy: 0)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 22, dy: 0)
    }
}

protocol JamoAuthAgreementViewDelegate: AnyObject {
    func jamoAuthAgreementViewDidTapTerms(_ view: JamoAuthAgreementView)
    func jamoAuthAgreementViewDidTapPrivacy(_ view: JamoAuthAgreementView)
    func jamoAuthAgreementView(_ view: JamoAuthAgreementView, didChangeAccepted accepted: Bool)
}

final class JamoAuthAgreementView: UIView, UITextViewDelegate {
    weak var delegate: JamoAuthAgreementViewDelegate?

    private let checkboxButton = UIButton(type: .custom)
    private let textView = UITextView()
    private var accepted: Bool {
        didSet {
            updateCheckbox()
            delegate?.jamoAuthAgreementView(self, didChangeAccepted: accepted)
        }
    }

    init(accepted: Bool) {
        self.accepted = accepted
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isAccepted: Bool {
        accepted
    }

    func setAccepted(_ value: Bool) {
        accepted = value
    }

    private func setup() {
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        checkboxButton.addTarget(self, action: #selector(toggleAccepted), for: .touchUpInside)
        addSubview(checkboxButton)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        textView.attributedText = agreementText()
        addSubview(textView)

        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkboxButton.topAnchor.constraint(equalTo: topAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 44),
            checkboxButton.heightAnchor.constraint(equalToConstant: 44),

            textView.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 8),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        updateCheckbox()
    }

    private func agreementText() -> NSAttributedString {
        let fullText = "By registering, you agree to the <Terms of Use> and <Privacy Policy>."
        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: JamoAuthTheme.helveticaRegular(size: 13),
                .foregroundColor: UIColor.black
            ]
        )
        let termsRange = (fullText as NSString).range(of: "<Terms of Use>")
        let privacyRange = (fullText as NSString).range(of: "<Privacy Policy>")
        attributed.addAttribute(.link, value: "jamo://terms", range: termsRange)
        attributed.addAttribute(.link, value: "jamo://privacy", range: privacyRange)
        return attributed
    }

    private func updateCheckbox() {
        let imageName = accepted ? "jamo_auth_checkbox_active" : "jamo_auth_checkbox_idle"
        checkboxButton.setImage(UIImage(named: imageName), for: .normal)
    }

    @objc private func toggleAccepted() {
        accepted.toggle()
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.host == "terms" {
            delegate?.jamoAuthAgreementViewDidTapTerms(self)
        } else if URL.host == "privacy" {
            delegate?.jamoAuthAgreementViewDidTapPrivacy(self)
        }
        return false
    }
}

final class JamoAuthToastView {
    enum Style {
        case success
        case error
        case warning
        case info

        var accentColor: UIColor {
            switch self {
            case .success:
                return UIColor(red: 91 / 255, green: 206 / 255, blue: 157 / 255, alpha: 1)
            case .error:
                return JamoMainTheme.orange
            case .warning:
                return JamoMainTheme.yellow
            case .info:
                return JamoMainTheme.pink
            }
        }

        var symbolName: String {
            switch self {
            case .success:
                return "checkmark.circle.fill"
            case .error:
                return "exclamationmark.triangle.fill"
            case .warning:
                return "exclamationmark.circle.fill"
            case .info:
                return "music.note"
            }
        }

        var feedbackType: UINotificationFeedbackGenerator.FeedbackType? {
            switch self {
            case .success:
                return .success
            case .error:
                return .error
            case .warning:
                return .warning
            case .info:
                return nil
            }
        }
    }

    private static let toastTag = 12490897

    static func show(on view: UIView, message: String, style requestedStyle: Style? = nil) {
        let style = requestedStyle ?? inferStyle(from: message)
        let hostView = view.window ?? view
        hostView.subviews
            .filter { $0.tag == toastTag }
            .forEach { $0.removeFromSuperview() }

        let toast = JamoToastBubbleView(message: message, style: style)
        toast.tag = toastTag
        hostView.addSubview(toast)

        NSLayoutConstraint.activate([
            toast.topAnchor.constraint(equalTo: hostView.safeAreaLayoutGuide.topAnchor, constant: 14),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: hostView.leadingAnchor, constant: 16),
            toast.trailingAnchor.constraint(lessThanOrEqualTo: hostView.trailingAnchor, constant: -16),
            toast.centerXAnchor.constraint(equalTo: hostView.centerXAnchor),
            toast.widthAnchor.constraint(lessThanOrEqualTo: hostView.widthAnchor, constant: -32)
        ])

        if let feedbackType = style.feedbackType {
            UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
        }
        UIAccessibility.post(notification: .announcement, argument: message)
        toast.presentAndAutoDismiss()
    }

    private static func inferStyle(from message: String) -> Style {
        let text = message.lowercased()
        let errorTokens = ["unable", "failed", "invalid", "error", "unavailable", "cannot", "try again", "too short"]
        if errorTokens.contains(where: { text.contains($0) }) {
            return .error
        }

        let warningTokens = ["no ", "needed", "pending", "already", "finish", "keep", "cancelled", "blocked"]
        if warningTokens.contains(where: { text.contains($0) }) {
            return .warning
        }

        let successTokens = ["success", "successful", "completed", "saved", "selected", "added", "uploaded", "copied"]
        if successTokens.contains(where: { text.contains($0) }) {
            return .success
        }

        return .info
    }
}

private final class JamoToastBubbleView: UIView {
    private var isDismissing = false

    init(message: String, style: JamoAuthToastView.Style) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.white.withAlphaComponent(0.97)
        layer.cornerCurve = .continuous
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = style.accentColor.withAlphaComponent(0.22).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 10)
        clipsToBounds = false
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: -16).scaledBy(x: 0.98, y: 0.98)

        let accentBar = UIView()
        accentBar.translatesAutoresizingMaskIntoConstraints = false
        accentBar.backgroundColor = style.accentColor
        accentBar.layer.cornerCurve = .continuous
        accentBar.layer.cornerRadius = 2.5

        let iconBackground = UIView()
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.backgroundColor = style.accentColor.withAlphaComponent(0.14)
        iconBackground.layer.cornerCurve = .continuous
        iconBackground.layer.cornerRadius = 15

        let iconView = UIImageView(image: UIImage(systemName: style.symbolName))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = style.accentColor
        iconView.contentMode = .scaleAspectFit
        iconBackground.addSubview(iconView)

        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message
        messageLabel.textColor = JamoMainTheme.ink
        messageLabel.font = JamoMainTheme.bodyFont(14, weight: .semibold)
        messageLabel.numberOfLines = 0

        addSubview(accentBar)
        addSubview(iconBackground)
        addSubview(messageLabel)

        NSLayoutConstraint.activate([
            accentBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            accentBar.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            accentBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            accentBar.widthAnchor.constraint(equalToConstant: 5),

            iconBackground.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 12),
            iconBackground.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 14),
            iconBackground.centerYAnchor.constraint(equalTo: messageLabel.centerYAnchor),
            iconBackground.widthAnchor.constraint(equalToConstant: 30),
            iconBackground.heightAnchor.constraint(equalTo: iconBackground.widthAnchor),

            iconView.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),

            messageLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func presentAndAutoDismiss() {
        UIView.animate(
            withDuration: 0.24,
            delay: 0,
            usingSpringWithDamping: 0.86,
            initialSpringVelocity: 0.35,
            options: [.curveEaseOut, .allowUserInteraction]
        ) {
            self.alpha = 1
            self.transform = .identity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.35) { [weak self] in
            self?.dismiss()
        }
    }

    @objc func dismiss() {
        guard !isDismissing else { return }
        isDismissing = true
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseIn, .allowUserInteraction]) {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: -12).scaledBy(x: 0.98, y: 0.98)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}

extension UIAlertController {
    func jamoApplyTheme() {
        view.tintColor = JamoMainTheme.orange
        view.layer.cornerCurve = .continuous
        view.layer.cornerRadius = 22

        if let title {
            setValue(
                NSAttributedString(
                    string: title,
                    attributes: [
                        .font: JamoMainTheme.titleFont(18),
                        .foregroundColor: JamoMainTheme.ink
                    ]
                ),
                forKey: "attributedTitle"
            )
        }

        if let message {
            setValue(
                NSAttributedString(
                    string: message,
                    attributes: [
                        .font: JamoMainTheme.bodyFont(13.5, weight: .regular),
                        .foregroundColor: JamoMainTheme.muted
                    ]
                ),
                forKey: "attributedMessage"
            )
        }
    }
}

final class JamoPinkStrokeView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(red: 255.0 / 255.0, green: 139.0 / 255.0, blue: 207.0 / 255.0, alpha: 1.0)
        layer.cornerRadius = 3
        transform = CGAffineTransform(rotationAngle: -0.025)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

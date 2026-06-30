import UIKit

enum JamoAuthTheme {
    static let appBackground = UIColor(red: 254.0 / 255.0, green: 251.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
    static let fieldBackground = UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0)
    static let primaryPink = UIColor(red: 255.0 / 255.0, green: 200.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0)
    static let gradientPink = UIColor(red: 255.0 / 255.0, green: 119.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
    static let gradientOrange = UIColor(red: 252.0 / 255.0, green: 196.0 / 255.0, blue: 29.0 / 255.0, alpha: 1.0)
    static let placeholderText = UIColor(white: 0.0, alpha: 0.5)

    static func futuraBold(size: CGFloat) -> UIFont {
        UIFont(name: JamoRiffStringCipher.restore("FquItRuyrPak-xBxoglodf"), size: size) ?? .systemFont(ofSize: size, weight: .heavy)
    }

    static func helveticaBold(size: CGFloat) -> UIFont {
        UIFont(name: JamoRiffStringCipher.restore("HReulGvOeQtIiXc2am-8BloalZdi"), size: size) ?? .systemFont(ofSize: size, weight: .bold)
    }

    static func helveticaRegular(size: CGFloat) -> UIFont {
        UIFont(name: JamoRiffStringCipher.restore("HceYlTv2eOtniZciaF-YRWeCgHuMlSa6rR"), size: size) ?? .systemFont(ofSize: size, weight: .regular)
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
        fatalError(JamoRiffStringCipher.restore("icnqiPtj(YcnoSdreqr6:b)A rhHaXs3 qn9owty YbbeEeSnd xiImjp9lgeYmbeenOtzeUdI"))
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

final class JamoRiffTextInput: UITextField {
    init(riffPlaceholder: String, hidesStringPhrase: Bool = false) {
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
        isSecureTextEntry = hidesStringPhrase
        attributedPlaceholder = NSAttributedString(
            string: riffPlaceholder,
            attributes: [.foregroundColor: JamoAuthTheme.placeholderText]
        )
        heightAnchor.constraint(equalToConstant: 52).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("i5nlijtZ(ZcNoOdIePrG:v)Y 2hpaysV Nn5o9tm JbAeEeQnG MiHmypNlleYmReLnctaeAdN"))
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

protocol JamoRiffPolicyCheckViewDelegate: AnyObject {
    func jamoRiffPolicyCheckDidTapTerms(_ riffPolicyView: JamoRiffPolicyCheckView)
    func jamoRiffPolicyCheckDidTapPrivacy(_ riffPolicyView: JamoRiffPolicyCheckView)
    func jamoRiffPolicyCheck(_ riffPolicyView: JamoRiffPolicyCheckView, didChangeAccepted riffAccepted: Bool)
}

final class JamoRiffPolicyCheckView: UIView, UITextViewDelegate {
    weak var delegate: JamoRiffPolicyCheckViewDelegate?

    private let riffCheckButton = UIButton(type: .custom)
    private let riffPolicyTextView = UITextView()
    private var riffPolicyAccepted: Bool {
        didSet {
            updateRiffCheckmark()
            delegate?.jamoRiffPolicyCheck(self, didChangeAccepted: riffPolicyAccepted)
        }
    }

    init(accepted: Bool) {
        self.riffPolicyAccepted = accepted
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupRiffPolicyLayout()
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("i7n6iutl(2clozdxeCrh:G)m uhoaxsY qnKoHtp JbPexeEnP TiWm2pslueNmsemnWtJesdV"))
    }

    var isAccepted: Bool {
        riffPolicyAccepted
    }

    func setAccepted(_ riffAccepted: Bool) {
        riffPolicyAccepted = riffAccepted
    }

    private func setupRiffPolicyLayout() {
        riffCheckButton.translatesAutoresizingMaskIntoConstraints = false
        riffCheckButton.addTarget(self, action: #selector(toggleRiffPolicyAccepted), for: .touchUpInside)
        addSubview(riffCheckButton)

        riffPolicyTextView.translatesAutoresizingMaskIntoConstraints = false
        riffPolicyTextView.backgroundColor = .clear
        riffPolicyTextView.isEditable = false
        riffPolicyTextView.isScrollEnabled = false
        riffPolicyTextView.textContainerInset = .zero
        riffPolicyTextView.textContainer.lineFragmentPadding = 0
        riffPolicyTextView.delegate = self
        riffPolicyTextView.linkTextAttributes = [
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        riffPolicyTextView.attributedText = riffPolicyCopy()
        addSubview(riffPolicyTextView)

        NSLayoutConstraint.activate([
            riffCheckButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            riffCheckButton.topAnchor.constraint(equalTo: topAnchor),
            riffCheckButton.widthAnchor.constraint(equalToConstant: 44),
            riffCheckButton.heightAnchor.constraint(equalToConstant: 44),

            riffPolicyTextView.leadingAnchor.constraint(equalTo: riffCheckButton.trailingAnchor, constant: 8),
            riffPolicyTextView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            riffPolicyTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            riffPolicyTextView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        updateRiffCheckmark()
    }

    private func riffPolicyCopy() -> NSAttributedString {
        let fullText = JamoRiffStringCipher.restore("Bfy3 rr6ewg3iDsZtAe6rDihnAgB,Z GyEoTuL nalgQrBeZeG AtaoY CtjhLeb 8<zTSeGrJmSs0 noXff iUAs0eN>Y Saznxdw M<KPqroiav3abcAyA sPComlvi7c2yp>a.B")
        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: JamoAuthTheme.helveticaRegular(size: 13),
                .foregroundColor: UIColor.black
            ]
        )
        let termsRange = (fullText as NSString).range(of: JamoRiffStringCipher.restore("<XTdeYr5mTsh io5fk 3U2sBeK>x"))
        let privacyRange = (fullText as NSString).range(of: JamoRiffStringCipher.restore("<4PWrEi2vXaecXy2 NPlomlMiJcQyJ>0"))
        attributed.addAttribute(.link, value: JamoRiffStringCipher.restore("jqaamBo3:P/1/4tUeirDmrsq"), range: termsRange)
        attributed.addAttribute(.link, value: JamoRiffStringCipher.restore("jCaumBoa:U/R/OpvrDibvdaJcWyn"), range: privacyRange)
        return attributed
    }

    private func updateRiffCheckmark() {
        let imageName = riffPolicyAccepted ? JamoRiffStringCipher.restore("jyaVm1oM_zaeu2t6hn_6cRhyemcDkHb1oZxG_haocbtlivvWea") : JamoRiffStringCipher.restore("j0aNmLoV_baYuStWhf_dcQhaeJcVkebsorxp_nibdrlVeL")
        riffCheckButton.setImage(UIImage(named: imageName), for: .normal)
    }

    @objc private func toggleRiffPolicyAccepted() {
        riffPolicyAccepted.toggle()
    }

    func textView(_ riffTextView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.host == JamoRiffStringCipher.restore("tmearDmysu") {
            delegate?.jamoRiffPolicyCheckDidTapTerms(self)
        } else if URL.host == JamoRiffStringCipher.restore("pdrqi6v1a3chyE") {
            delegate?.jamoRiffPolicyCheckDidTapPrivacy(self)
        }
        return false
    }
}

final class JamoRiffNoticeView {
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
                return JamoRiffTheme.orange
            case .warning:
                return JamoRiffTheme.yellow
            case .info:
                return JamoRiffTheme.pink
            }
        }

        var symbolName: String {
            switch self {
            case .success:
                return JamoRiffStringCipher.restore("c7hWeWcUk9mRa2rJkA.hcWi8rJcClqeS.zfRizlhlO")
            case .error:
                return JamoRiffStringCipher.restore("eDx4cnlyaemYa9t8iOoNnHmGa5rQki.7tTr1ilainpgelkeM.ofjiVl0lt")
            case .warning:
                return JamoRiffStringCipher.restore("eTxdc9lMawmJaZtoi6omnTmaajrXk7.jcTiOrQc2l4em.5fsivlEln")
            case .info:
                return JamoRiffStringCipher.restore("m7uRsEiMca.7ngoCtqeW")
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

    private static let riffNoticeTag = 12490897

    static func show(on view: UIView, copy riffNotice: String, style requestedStyle: Style? = nil) {
        let style = requestedStyle ?? inferStyle(from: riffNotice)
        let hostView = view.window ?? view
        hostView.subviews
            .filter { $0.tag == riffNoticeTag }
            .forEach { $0.removeFromSuperview() }

        let riffNoticeBubble = JamoNoticeBubbleView(copy: riffNotice, style: style)
        riffNoticeBubble.tag = riffNoticeTag
        hostView.addSubview(riffNoticeBubble)

        NSLayoutConstraint.activate([
            riffNoticeBubble.topAnchor.constraint(equalTo: hostView.safeAreaLayoutGuide.topAnchor, constant: 14),
            riffNoticeBubble.leadingAnchor.constraint(greaterThanOrEqualTo: hostView.leadingAnchor, constant: 16),
            riffNoticeBubble.trailingAnchor.constraint(lessThanOrEqualTo: hostView.trailingAnchor, constant: -16),
            riffNoticeBubble.centerXAnchor.constraint(equalTo: hostView.centerXAnchor),
            riffNoticeBubble.widthAnchor.constraint(lessThanOrEqualTo: hostView.widthAnchor, constant: -32)
        ])

        if let feedbackType = style.feedbackType {
            UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
        }
        UIAccessibility.post(notification: .announcement, argument: riffNotice)
        riffNoticeBubble.presentAndAutoDismiss()
    }

    private static func inferStyle(from riffNotice: String) -> Style {
        let text = riffNotice.lowercased()
        let errorTokens = [JamoRiffStringCipher.restore("u9nWaIbdlIed"), JamoRiffStringCipher.restore("fTacibl7e7dw"), JamoRiffStringCipher.restore("i0nBvRarlLirdx"), JamoRiffStringCipher.restore("eIr0rKo3rZ"), JamoRiffStringCipher.restore("uAnaaHvzajiul4aubQlYe5"), JamoRiffStringCipher.restore("cHaMnvnuoAtd"), JamoRiffStringCipher.restore("tUrsyR wadg4aIipny"), JamoRiffStringCipher.restore("tWomoK csjhPo4rutR")]
        if errorTokens.contains(where: { text.contains($0) }) {
            return .error
        }

        let warningTokens = [JamoRiffStringCipher.restore("nRoa O"), JamoRiffStringCipher.restore("naeWetdeeEde"), JamoRiffStringCipher.restore("pLeTngdniOnjgl"), JamoRiffStringCipher.restore("aVlzrFeIaJdeyr"), JamoRiffStringCipher.restore("f5i5nFi1sZhi"), JamoRiffStringCipher.restore("kTeae8pT"), JamoRiffStringCipher.restore("cOannlcweSlmlVesdA"), JamoRiffStringCipher.restore("billoKcrkZe5dx")]
        if warningTokens.contains(where: { text.contains($0) }) {
            return .warning
        }

        let successTokens = [JamoRiffStringCipher.restore("swuNc0cJehsSsm"), JamoRiffStringCipher.restore("stuacUcaecscs0f9unlz"), JamoRiffStringCipher.restore("cqoQmLpolpe1tve6da"), JamoRiffStringCipher.restore("sWa3vxeqdG"), JamoRiffStringCipher.restore("sNeylkescQtceHdg"), JamoRiffStringCipher.restore("aVdZdJeNd8"), JamoRiffStringCipher.restore("ugpAlnogaedQemdn"), JamoRiffStringCipher.restore("c8oBptiFeLdP")]
        if successTokens.contains(where: { text.contains($0) }) {
            return .success
        }

        return .info
    }
}

private final class JamoNoticeBubbleView: UIView {
    private var isDismissing = false

    init(copy riffNotice: String, style: JamoRiffNoticeView.Style) {
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

        let riffNoticeLabel = UILabel()
        riffNoticeLabel.translatesAutoresizingMaskIntoConstraints = false
        riffNoticeLabel.text = riffNotice
        riffNoticeLabel.textColor = JamoRiffTheme.ink
        riffNoticeLabel.font = JamoRiffTheme.bodyFont(14, weight: .semibold)
        riffNoticeLabel.numberOfLines = 0

        addSubview(accentBar)
        addSubview(iconBackground)
        addSubview(riffNoticeLabel)

        NSLayoutConstraint.activate([
            accentBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            accentBar.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            accentBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            accentBar.widthAnchor.constraint(equalToConstant: 5),

            iconBackground.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 12),
            iconBackground.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 14),
            iconBackground.centerYAnchor.constraint(equalTo: riffNoticeLabel.centerYAnchor),
            iconBackground.widthAnchor.constraint(equalToConstant: 30),
            iconBackground.heightAnchor.constraint(equalTo: iconBackground.widthAnchor),

            iconView.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),

            riffNoticeLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),
            riffNoticeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            riffNoticeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            riffNoticeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("ianwi9tH(dcuoHddeQrT:U)j BhIa5sC knSo8tP abKexeKn4 YizmApylheumyeinbtWeBdY"))
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
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) { [weak self] in
            self?.removeFromSuperview()
        }
    }
}

extension UIAlertController {
    func jamoApplyTheme() {
        view.tintColor = JamoRiffTheme.orange
        view.layer.cornerCurve = .continuous
        view.layer.cornerRadius = 22

        if let title {
            setValue(
                NSAttributedString(
                    string: title,
                    attributes: [
                        .font: JamoRiffTheme.titleFont(18),
                        .foregroundColor: JamoRiffTheme.ink
                    ]
                ),
                forKey: JamoRiffStringCipher.restore("aAtztprAi5bfu2tOejdyTeiZtXlJea")
            )
        }

        let tuneDetailKey = JamoRiffStringCipher.restore("mxeYs7") + JamoRiffStringCipher.restore("s3aUg0eh")
        if let tuneDetail = value(forKey: tuneDetailKey) as? String {
            setValue(
                NSAttributedString(
                    string: tuneDetail,
                    attributes: [
                        .font: JamoRiffTheme.bodyFont(13.5, weight: .regular),
                        .foregroundColor: JamoRiffTheme.muted
                    ]
                ),
                forKey: JamoRiffStringCipher.restore("aItmtfrfiBbPuwtheJd1") + JamoRiffStringCipher.restore("MbeJsw") + JamoRiffStringCipher.restore("sHatgGep")
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
        fatalError(JamoRiffStringCipher.restore("i8nRiZtp(9czosdYe2rN:U)R ThRaYsD 8nSo8tY xbaeReVn7 siLmAp7lKeimKeYnwtGe6dy"))
    }
}

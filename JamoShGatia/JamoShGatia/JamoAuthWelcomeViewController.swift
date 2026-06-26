import UIKit

final class JamoAuthWelcomeViewController: JamoAuthBaseViewController {
    private let backgroundImageView = UIImageView(image: UIImage(named: "jamo_auth_welcome_background"))
    private let logoImageView = UIImageView(image: UIImage(named: "jamo_auth_app_logo"))
    private lazy var signInButton = JamoAuthGradientButton(title: "Sign in", style: .whitePinkText)
    private lazy var newAccountButton = JamoAuthGradientButton(title: "I'm new", style: .gradient)
    private lazy var agreementView = JamoAuthAgreementView(accepted: authStore.isAgreementAccepted)
    private weak var eulaPromptView: JamoWelcomeEulaPromptView?

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.isScrollEnabled = false
        setupLayout()
        setupActions()
        presentEulaIfNeeded()
    }

    private func setupLayout() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.insertSubview(backgroundImageView, belowSubview: scrollView)

        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let bottomPanel = UIStackView(arrangedSubviews: [logoImageView, signInButton, newAccountButton, agreementView])
        bottomPanel.translatesAutoresizingMaskIntoConstraints = false
        bottomPanel.axis = .vertical
        bottomPanel.alignment = .center
        bottomPanel.spacing = 24
        contentView.addSubview(bottomPanel)

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        agreementView.delegate = self

        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 90),
            logoImageView.heightAnchor.constraint(equalToConstant: 90),

            signInButton.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor),
            signInButton.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor),
            newAccountButton.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor),
            newAccountButton.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor),
            agreementView.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor),
            agreementView.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor),

            bottomPanel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            bottomPanel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),
            bottomPanel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ])
        bottomPanel.setCustomSpacing(16, after: signInButton)
        bottomPanel.setCustomSpacing(42, after: newAccountButton)
    }

    private func setupActions() {
        signInButton.addTarget(self, action: #selector(openLogin), for: .touchUpInside)
        newAccountButton.addTarget(self, action: #selector(openSignUp), for: .touchUpInside)
    }

    private func presentEulaIfNeeded() {
        guard !authStore.isEulaAccepted, eulaPromptView == nil else { return }
        let prompt = JamoWelcomeEulaPromptView()
        prompt.translatesAutoresizingMaskIntoConstraints = false
        prompt.onAgree = { [weak self, weak prompt] in
            guard let self else { return }
            self.authStore.isEulaAccepted = true
            self.authStore.isAgreementAccepted = true
            self.agreementView.setAccepted(true)
            prompt?.dismiss()
        }
        prompt.onDisagree = { [weak self, weak prompt] in
            guard let self else { return }
            self.authStore.isEulaAccepted = false
            self.authStore.isAgreementAccepted = false
            self.agreementView.setAccepted(false)
            prompt?.dismiss()
        }

        view.addSubview(prompt)
        eulaPromptView = prompt
        NSLayoutConstraint.activate([
            prompt.topAnchor.constraint(equalTo: view.topAnchor),
            prompt.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            prompt.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            prompt.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        prompt.present()
    }

    @objc private func openLogin() {
        guard ensureAgreementAccepted() else { return }
        navigationController?.pushViewController(JamoAuthLoginViewController(), animated: true)
    }

    @objc private func openSignUp() {
        guard ensureAgreementAccepted() else { return }
        navigationController?.pushViewController(JamoAuthSignUpViewController(), animated: true)
    }

    private func beginAppleSignInIfAllowed() {
        guard ensureAgreementAccepted() else { return }
        // TODO: Connect Sign in with Apple when the product confirms the Apple entry should be visible again.
    }

    override func jamoAuthAgreementView(_ view: JamoAuthAgreementView, didChangeAccepted accepted: Bool) {
        super.jamoAuthAgreementView(view, didChangeAccepted: accepted)
        authStore.isEulaAccepted = accepted
    }
}

private final class JamoWelcomeEulaPromptView: UIView {
    var onAgree: (() -> Void)?
    var onDisagree: (() -> Void)?

    private let cardView = UIView()
    private let gradientLayer = CAGradientLayer()
    private let agreeButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.38)
        alpha = 0
        buildContent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        agreeButton.layer.cornerRadius = agreeButton.bounds.height / 2
        gradientLayer.frame = agreeButton.bounds
    }

    func present() {
        layoutIfNeeded()
        cardView.transform = CGAffineTransform(translationX: 0, y: 24).scaledBy(x: 0.96, y: 0.96)
        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            usingSpringWithDamping: 0.88,
            initialSpringVelocity: 0.35,
            options: [.curveEaseOut, .allowUserInteraction]
        ) {
            self.alpha = 1
            self.cardView.transform = .identity
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn, .allowUserInteraction]) {
            self.alpha = 0
            self.cardView.transform = CGAffineTransform(translationX: 0, y: 18).scaledBy(x: 0.98, y: 0.98)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }

    private func buildContent() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = JamoAuthTheme.appBackground
        cardView.layer.cornerCurve = .continuous
        cardView.layer.cornerRadius = 28
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.18
        cardView.layer.shadowRadius = 24
        cardView.layer.shadowOffset = CGSize(width: 0, height: 14)
        addSubview(cardView)

        let contentStack = UIStackView()
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 18
        cardView.addSubview(contentStack)

        contentStack.addArrangedSubview(makeHeader())
        contentStack.addArrangedSubview(makeBodyScroll())
        contentStack.addArrangedSubview(makeActions())

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            cardView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: centerYAnchor),
            cardView.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor, constant: 18),
            cardView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -18),
            cardView.widthAnchor.constraint(lessThanOrEqualToConstant: 390),

            contentStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 22),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -22),
            contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -22)
        ])
    }

    private func makeHeader() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8

        let badge = UILabel()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.text = "Jamo"
        badge.textAlignment = .center
        badge.textColor = .white
        badge.font = JamoAuthTheme.futuraBold(size: 18)
        badge.backgroundColor = JamoAuthTheme.gradientPink
        badge.layer.cornerCurve = .continuous
        badge.layer.cornerRadius = 24
        badge.clipsToBounds = true
        NSLayoutConstraint.activate([
            badge.widthAnchor.constraint(equalToConstant: 82),
            badge.heightAnchor.constraint(equalToConstant: 48)
        ])

        let title = UILabel()
        title.text = "Jamo Player Agreement"
        title.textColor = .black
        title.font = JamoAuthTheme.futuraBold(size: 24)
        title.textAlignment = .center
        title.numberOfLines = 0

        let subtitle = UILabel()
        subtitle.text = "Play Guitar Together"
        subtitle.textColor = JamoAuthTheme.gradientPink
        subtitle.font = JamoAuthTheme.helveticaBold(size: 15)
        subtitle.textAlignment = .center

        stack.addArrangedSubview(badge)
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(subtitle)
        return stack
    }

    private func makeBodyScroll() -> UIScrollView {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = true
        scroll.indicatorStyle = .black

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = eulaText()
        label.numberOfLines = 0
        scroll.addSubview(label)

        NSLayoutConstraint.activate([
            scroll.heightAnchor.constraint(equalToConstant: 238),
            label.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            label.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            label.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
        ])
        return scroll
    }

    private func makeActions() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10

        agreeButton.translatesAutoresizingMaskIntoConstraints = false
        agreeButton.setTitle("Agree", for: .normal)
        agreeButton.setTitleColor(.white, for: .normal)
        agreeButton.titleLabel?.font = JamoAuthTheme.helveticaBold(size: 17)
        agreeButton.layer.cornerCurve = .continuous
        agreeButton.clipsToBounds = true
        gradientLayer.colors = [JamoAuthTheme.gradientPink.cgColor, JamoAuthTheme.gradientOrange.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        agreeButton.layer.insertSublayer(gradientLayer, at: 0)
        agreeButton.addTarget(self, action: #selector(agreeTapped), for: .touchUpInside)

        let disagreeButton = UIButton(type: .custom)
        disagreeButton.translatesAutoresizingMaskIntoConstraints = false
        disagreeButton.setTitle("Disagree", for: .normal)
        disagreeButton.setTitleColor(JamoAuthTheme.gradientPink, for: .normal)
        disagreeButton.titleLabel?.font = JamoAuthTheme.helveticaBold(size: 16)
        disagreeButton.backgroundColor = .white
        disagreeButton.layer.cornerCurve = .continuous
        disagreeButton.layer.cornerRadius = 24
        disagreeButton.layer.borderWidth = 1
        disagreeButton.layer.borderColor = JamoAuthTheme.primaryPink.cgColor
        disagreeButton.addTarget(self, action: #selector(disagreeTapped), for: .touchUpInside)

        stack.addArrangedSubview(agreeButton)
        stack.addArrangedSubview(disagreeButton)
        NSLayoutConstraint.activate([
            agreeButton.heightAnchor.constraint(equalToConstant: 50),
            disagreeButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        return stack
    }

    private func eulaText() -> NSAttributedString {
        let text = """
        Welcome to Jamo, a creative guitar space for players who want to start riffs, add rhythm layers, continue melodies, build duet-style performances, respond to practice clips, and shape short collaborative pieces with other guitar lovers.

        By using Jamo, you agree that this service is not a random, anonymous, adult, or borderline chat service. Jamo is for guitar practice, music co-creation, AI-assisted playing ideas, tone questions, and respectful collaboration.

        You must use lawful account information, meet the required age and local identity rules where applicable, and keep your profile, cover images, audio clips, comments, and shared works appropriate for a guitar music community.

        Do not upload illegal, hateful, sexual, harassing, impersonating, infringing, or unsafe content. Only share guitar audio, images, and creative materials that you have the right to use.

        Jamo may review content, limit distribution, remove works, block accounts, or apply penalties when behavior breaks these rules. Reporting and blocking tools are available to help keep the community safe.

        If you agree, the welcome page checkbox will be selected automatically. If you disagree, the checkbox stays off and login or registration will remain unavailable until you accept the Terms of Use and Privacy Policy.
        """

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 5
        paragraph.paragraphSpacing = 10
        return NSAttributedString(
            string: text,
            attributes: [
                .font: JamoAuthTheme.helveticaRegular(size: 13.5),
                .foregroundColor: UIColor.black.withAlphaComponent(0.78),
                .paragraphStyle: paragraph
            ]
        )
    }

    @objc private func agreeTapped() {
        onAgree?()
    }

    @objc private func disagreeTapped() {
        onDisagree?()
    }
}

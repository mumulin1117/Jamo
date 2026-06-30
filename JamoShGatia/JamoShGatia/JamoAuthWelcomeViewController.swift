import UIKit

final class JamoRiffWelcomeStageViewController: JamoAuthBaseViewController {
    private let backgroundImageView = UIImageView(image: UIImage(named: "jamo_auth_welcome_background"))
    private let logoImageView = UIImageView(image: UIImage(named: "jamo_auth_app_logo"))
    private lazy var signInButton = JamoAuthGradientButton(title: JamoRiffStringCipher.restore("S6iagznz 4iinJ"), style: .whitePinkText)
    private lazy var newAccountButton = JamoAuthGradientButton(title: JamoRiffStringCipher.restore("IZ'cmI bn1eKww"), style: .gradient)
    private lazy var agreementView = JamoRiffPolicyCheckView(accepted: authStore.isAgreementAccepted)
    private weak var riffPolicyPrompt: JamoWelcomeRiffPolicyPrompt?

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
        signInButton.addTarget(self, action: #selector(openRiffAccessGate), for: .touchUpInside)
        newAccountButton.addTarget(self, action: #selector(openRiffPlayerEntry), for: .touchUpInside)
    }

    private func presentEulaIfNeeded() {
        guard !authStore.isEulaAccepted, riffPolicyPrompt == nil else { return }
        let prompt = JamoWelcomeRiffPolicyPrompt()
        prompt.translatesAutoresizingMaskIntoConstraints = false
        prompt.onRiffPolicyAccepted = { [weak self, weak prompt] in
            guard let self else { return }
            self.authStore.isEulaAccepted = true
            self.authStore.isAgreementAccepted = true
            self.agreementView.setAccepted(true)
            prompt?.dismiss()
        }
        prompt.onRiffPolicyDeclined = { [weak self, weak prompt] in
            guard let self else { return }
            self.authStore.isEulaAccepted = false
            self.authStore.isAgreementAccepted = false
            self.agreementView.setAccepted(false)
            prompt?.dismiss()
        }

        view.addSubview(prompt)
        riffPolicyPrompt = prompt
        NSLayoutConstraint.activate([
            prompt.topAnchor.constraint(equalTo: view.topAnchor),
            prompt.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            prompt.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            prompt.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        prompt.present()
    }

    @objc private func openRiffAccessGate() {
        guard ensureAgreementAccepted() else { return }
        navigationController?.pushViewController(JamoRiffAccessGateViewController(), animated: true)
    }

    @objc private func openRiffPlayerEntry() {
        guard ensureAgreementAccepted() else { return }
        navigationController?.pushViewController(JamoRiffPlayerEntryViewController(), animated: true)
    }






    override func jamoRiffPolicyCheck(_ view: JamoRiffPolicyCheckView, didChangeAccepted accepted: Bool) {
        super.jamoRiffPolicyCheck(view, didChangeAccepted: accepted)
        authStore.isEulaAccepted = accepted
    }
}

private final class JamoWelcomeRiffPolicyPrompt: UIView {
    var onRiffPolicyAccepted: (() -> Void)?
    var onRiffPolicyDeclined: (() -> Void)?

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
        fatalError(JamoRiffStringCipher.restore("iYnAibtl(sc7ogdmeLrU:R)3 ohvaksr JnIo7t1 tbCeleLnx eilm0pilKeZmPeanJtJeFdy"))
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
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { [weak self] in
            self?.removeFromSuperview()
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
        badge.text = JamoRiffStringCipher.restore("J9a3mDoG")
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
        title.text = JamoRiffStringCipher.restore("JSaPmXoH UPLlcaNyqemrL SARgXrieweamSe9nHtd")
        title.textColor = .black
        title.font = JamoAuthTheme.futuraBold(size: 24)
        title.textAlignment = .center
        title.numberOfLines = 0

        let subtitle = UILabel()
        subtitle.text = JamoRiffStringCipher.restore("PklfaUyC GGcurintMaRrh PTtoig0extdhpeWrT")
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
        agreeButton.setTitle(JamoRiffStringCipher.restore("A2gprwehe1"), for: .normal)
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
        disagreeButton.setTitle(JamoRiffStringCipher.restore("DNiksKaQglrLeHet"), for: .normal)
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
        let paragraphBreak = String(UnicodeScalar(10)!) + String(UnicodeScalar(10)!)
        let text = [
            JamoRiffStringCipher.restore("WWeylPcEoAm3em mtRoz dJBaCm2oC,c 5aH ucmrpeFaOtNiWv2eP Hgmu3iztuaEri BsDpVaTc1eT QfcoHrp WpqlCaEy3e3rFsr 9wch7o5 lw3aOnXtg ctyoq asltna6rmth wrii4fofSsY,P maBdpdt 5rPhwymtthsmv 3lDaXypewrXsd,N mcYoynztHiWnKuwew AmkeplJo4dwi4ewsh,m Lbuuaifl9dQ GdyuKeutg-ss6tVyklqe3 MpReFr9fTotrPmPa8n4cieJsl,Q JrDeisCpdo4nadl wtUoP CpDrVaMcitbiFcgem KcZlkiOpas4,d ZaPn3d9 fsFhyaapxem HsRhRoYrftn AcDo9lcl7aIbqoWrBaFtpiYvPeo 2pQi9eEc8eMsl ewoiDtEhN YootfhJenrb cgAu9i8tdaPru GlOo3vSeMrGsP.y"),
            JamoRiffStringCipher.restore("B5y3 zuKs2iFn8gx tJjapmmog,M JyIoVuX JaCgFryeIeJ htqh0a9tp Ot6htiQsF Js1ehr8vNiSc4er Ziosx MnAoNtD jad 9rLaWnJdmoYmE,v vapnVoNnLynmoofu7sx,R qaOd5uml0tm,t mokr6 7bCobrSdceSrvlZi4nsev mcio9n7vjeUr2szaatbicotn3 XsSezruviiLceey.d QJKaCmxo9 Ri5si 8fsoqrJ BguuliStmaqrZ WpQrQancAtQiTc3ew,C 6mOuVspiscm 2cboO-Hc3rCeTant6inoInb,w vAVIn-7aesHsQiTs5tMepdv tpmlxaNysiknYgC LiXdXeyaxsB,1 9tyoLnreI IqmueeVsftxiooTnZs9,T 1a3nod9 7r2eQsSpleScctVfpuAlL qcFoplal7a8beo1rfaFteiZodnZ.W"),
            JamoRiffStringCipher.restore("YSouuy vmHussnt5 quYsbeU xl5a5wTfUupld mavcIcBo0uHnmtG vi1njfmoxrOm4aPtDiboGnj,a hmjeNe2tp 4tBh1eF JrMeNqquQixrteRdF raigbev 8axn5d9 KlnowcFa1ld Cidd9eHnLt6iHtByE ErjuOlpe4si ywXhreirHe4 0aWp0pXlwi2c7acbMlfer,A Qaen9d6 wklekeopH UyToguer3 5pwr3oIfbi1leee,I qcPoyv8eTrs 5iAmGangLeesA,3 PatuadbiJoZ 8cAlpiyppsf,X McjoamGmveAnYtksd,v zaZnJdO 9sph6aLrwetdk xwUobrik5sq JahpnpLrwoPpTrLi7aMtzem gfqoRri Za7 fgCu2iJtyaCr2 cmCuJs8iscV pcXoQmdmwuRnbibtcyM.0"),
            JamoRiffStringCipher.restore("DyoN jntoEtt tuMpElBoNaIdh GiEldlBehg6ail8,7 rhkaxtyeDfyuulL,8 ws3e2xluWa1lU,1 Qh3aUrAa6sbsviSnOgl,B UiLmhpOeKrYsfosnLaFtoidndgX,2 8iWn4fPrniwn3gziKnPgo,W Rozrg kuknKstaofGe6 MckoTnNtKeEnBt3.i HOBnFlzyn YsVhZadrqeZ EgQuJiEt2abrG LaSuzdyi4ot,f 7iVmza1gTeSsa,Q gaMn1dI OcNrVeBaMtKikvbeF VmGaWtKeCrliCaSlSsh PtFhga6t9 0yAocu9 ph3aDvteJ MtuhPeu TroirgMhmtq ntnox ku9sBeA.l"),
            JamoRiffStringCipher.restore("JPaemNok Mmzaey8 ArxeXvoiXeyw3 gchown4tVevnttl,G XlXinmkiQtZ PdXiOsTtUrsiMbKuotMiWorn4,X 4r5ecm7ouvGek Twbo9rmkJsZ,A bbtlAoecUk3 WaBcIcFoZuJn5tdsd,W yoWrI raNpLpklMyD rpve2ndaNlUttiXeXs8 JwQhZetnQ nbEeuhWamvUiGoRrZ 8bJrbecahkesO QtghNeasLeE rrYumlUeTsr.p 5RBeepUo4rgtoiXnUgo Oa2nodY CbUlmo6cJk8iEn0g2 ltbo0owlhsm ma3r2e7 yaLvXaoiolqahbSldef 4txo3 Jh9eglGpz XkYeyeypj HtphEeJ XcHoqmdmYuFnuixteyb isdaGfxe4.B"),
            JamoRiffStringCipher.restore("IVfg ty6oMuc 9aZgFrzedeE,0 WtRh6e1 2w0eal9cgoXm7ep Rpba5goeg Bcqhse8cEkFbro6xP VwqiAlDlJ gbBeL Es8eUlZe5cwtAe2d1 AaCu5t4oNmiavthiIc2a4lulZyl.L UIGfu hyho0uv ZdviPsMaGgjrKe8eW,K MtrheeC rc6h1ecctkPbno9xM 3s9tRaHytsI ModfafR QahnJdm 3lOoKgJiPni 0oors frKe7gAiDsCtIrUaRt7iWo8nO bwJillXlX rr2eQmtaUidnw uu6nJa7v6a3iclYaub9lleC juDnvtiiYlQ vyPohum 8aTcbcNerpKt9 CtBhOeo zTReUrwmssM Kosf6 xUisVeu UaXnOdc TP6rtinvoaIchyW tPCoKl5ihcpyc.R")
        ].joined(separator: paragraphBreak)

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
        onRiffPolicyAccepted?()
    }

    @objc private func disagreeTapped() {
        onRiffPolicyDeclined?()
    }
}

import UIKit

final class JamoPersonnWalController: JamoRiffBaseStageViewController {
    private enum Layout {
        static let contentMaxWidth: CGFloat = 327
        static let sectionSpacing: CGFloat = 22
        static let cardRadius: CGFloat = 24
        static let pickupShelfCardHeight: CGFloat = 92
    }

    private let toneProfileManager = JamoProfileViewModel()
    private var refreshAnchor = UUID()
    private var sourceRiffWorksByHandle: [String: JamoCoCreateWork] = [:]
    private var currentPlayerAnchor: String = JamoRiffStringCipher.restore("jgaLm0o7_UluoJchailW_9pAlQaQykeNrt")

    override func viewDidLoad() {
        super.viewDidLoad()
        title = nil
        contentStack.spacing = Layout.sectionSpacing
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        jamoToneProfile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        jamoToneProfile()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    private func jamoToneProfile() {
        let currentRequest = UUID()
        refreshAnchor = currentRequest
        toneProfileManager.loadToneProfileSnapshot { [weak self] snapshot in
            DispatchQueue.main.async {
                guard let self, self.refreshAnchor == currentRequest else { return }
                self.renderToneProfile(snapshot)
            }
        }
    }

    private func renderToneProfile(_ snapshot: JamoProfileSnapshot) {
        currentPlayerAnchor = snapshot.playerSummary.playerHandle
        sourceRiffWorksByHandle = Dictionary(uniqueKeysWithValues: snapshot.sourceRiffWorks.map { ($0.jamoRiffHandle, $0) })
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contentStack.addArrangedSubview(centeredTrackContainer(JamoProfileHeaderView(playerSummary: snapshot.playerSummary, target: self)))
        contentStack.addArrangedSubview(centeredTrackContainer(JamoProfilePickShelfCardView(playerSummary: snapshot.playerSummary, target: self)))
        contentStack.addArrangedSubview(centeredTrackContainer(makeRiffMomentSection(snapshot)))
    }

    private func makeRiffMomentSection(_ snapshot: JamoProfileSnapshot) -> UIView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16

        stack.addArrangedSubview(JamoProfileSectionHeaderView(title: JamoRiffStringCipher.restore("Pto6shtl")))

        if snapshot.riffMoments.isEmpty {
            let empty = JamoProfileEmptyRiffView(display: snapshot.emptyRiffMoments)
            empty.startButton.addTarget(self, action: #selector(startRiffDraftTapped), for: .touchUpInside)
            stack.addArrangedSubview(empty)
        } else {
            snapshot.riffMoments.forEach { riffMoment in
                let card = JamoProfileRiffMomentCardView(riffMoment: riffMoment)
                card.addTarget(self, action: #selector(riffMomentCardTapped(_:)), for: .touchUpInside)
                card.riffActionButton.addTarget(self, action: #selector(riffMomentActionTapped(_:)), for: .touchUpInside)
                card.branchOptionsButton.addTarget(self, action: #selector(riffMomentOptionsTapped(_:)), for: .touchUpInside)
                stack.addArrangedSubview(card)
            }
        }

        return stack
    }

    private func centeredTrackContainer(_ view: UIView) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        let fillWidth = view.widthAnchor.constraint(equalTo: container.widthAnchor)
        fillWidth.priority = .defaultHigh

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            view.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor),
            view.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
            view.widthAnchor.constraint(lessThanOrEqualToConstant: Layout.contentMaxWidth),
            fillWidth
        ])
        return container
    }

    @objc fileprivate func toneProfileEditTapped() {
        JamoShowDefinition.launchWorkflowBridge(.toneProfileContext, from: self)
    }

    @objc fileprivate func playerToneHomeTapped() {
        JamoShowDefinition.launchWorkflowBridge(.musicianQuestionManager(playerHandle: currentPlayerAnchor), from: self)
    }

    @objc fileprivate func styleExchangeTapped() {
        JamoShowDefinition.launchWorkflowBridge(.styleExchangeRegistry, from: self)
    }

    @objc fileprivate func sessionParticipantTapped() {
        JamoShowDefinition.launchWorkflowBridge(.sessionParticipantContext, from: self)
    }

    @objc fileprivate func pickupShelfTapped() {
        JamoShowDefinition.launchWorkflowBridge(.pickupSelectorDefinition, from: self)
    }

    @objc private func riffMomentCardTapped(_ sender: JamoProfileRiffMomentCardView) {
        openRiffMoment(riffHandle: sender.riffHandle)
    }

    @objc private func riffMomentActionTapped(_ sender: JamoProfileRiffActionButton) {
        openRiffMoment(riffHandle: sender.riffHandle)
    }

    @objc private func riffMomentOptionsTapped(_ sender: JamoProfileRiffActionButton) {
        showRiffNotice(JamoRiffStringCipher.restore("MboSryeM MwgoFrWki VaecJtGikoQnDsy cadrveY ZckoLmGiznWgp 7sHo6ornh.4"))
    }

    @objc private func startRiffDraftTapped() {
        navigationController?.pushViewController(JamoRiffPublishStageViewController(), animated: true)
    }

    private func openRiffMoment(riffHandle: String) {
        guard let work = sourceRiffWorksByHandle[riffHandle] else {
            showRiffNotice(JamoRiffStringCipher.restore("TyhNiSsS ywNoKr7k3 EixsN onKod hlZo3n0g1esrI Ta8vqaJiTliaVbAlWeq.U"))
            return
        }
        navigationController?.pushViewController(JamoCoCreateDetailViewController(work: work), animated: true)
    }
}

private final class JamoProfileHeaderView: UIView {
    private enum Metric {
        static let avatarSize: CGFloat = 96
        static let height: CGFloat = 162
        static let namePillHeight: CGFloat = 40
        static let metricWidth: CGFloat = 82
    }

    init(playerSummary: JamoProfileUserSummary, target: JamoPersonnWalController) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let avatarView = JamoProfileAvatarView(
            imageName: "jamo_auth_app_logo",
            avatarURL: playerSummary.playerArtworkAddress,
            initials: playerSummary.playerDisplayName.jamoProfileInitials,
            fontSize: 24
        )
        avatarView.accessibilityLabel = JamoRiffStringCipher.restore("OMpmeqnw au5s6evrY 7pvrAo5ffiblleK")
        avatarView.addTarget(target, action: #selector(JamoPersonnWalController.playerToneHomeTapped), for: .touchUpInside)

        let styleExchangeButton = JamoProfileMetricButton(metric: playerSummary.styleExchange)
        styleExchangeButton.addTarget(target, action: #selector(JamoPersonnWalController.styleExchangeTapped), for: .touchUpInside)

        let sessionParticipantButton = JamoProfileMetricButton(metric: playerSummary.sessionParticipant)
        sessionParticipantButton.addTarget(target, action: #selector(JamoPersonnWalController.sessionParticipantTapped), for: .touchUpInside)

        let nameButton = JamoProfileNameButton(displayName: playerSummary.playerDisplayName)
        nameButton.addTarget(target, action: #selector(JamoPersonnWalController.playerToneHomeTapped), for: .touchUpInside)
        nameButton.editButton.addTarget(target, action: #selector(JamoPersonnWalController.toneProfileEditTapped), for: .touchUpInside)

        addSubview(avatarView)
        addSubview(styleExchangeButton)
        addSubview(sessionParticipantButton)
        addSubview(nameButton)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Metric.height),

            avatarView.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            avatarView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: Metric.avatarSize),
            avatarView.heightAnchor.constraint(equalTo: avatarView.widthAnchor),

            styleExchangeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            styleExchangeButton.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor, constant: 10),
            styleExchangeButton.widthAnchor.constraint(equalToConstant: Metric.metricWidth),

            sessionParticipantButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            sessionParticipantButton.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor, constant: 10),
            sessionParticipantButton.widthAnchor.constraint(equalToConstant: Metric.metricWidth),

            nameButton.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: -14),
            nameButton.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            nameButton.heightAnchor.constraint(equalToConstant: Metric.namePillHeight),
            nameButton.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 72),
            nameButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -72),
            nameButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("i9nWigtj(zcfo7dOeKre:2)B OhYaZsG 6nHoft4 fbce1eSnp 0icm6pBl9eAmae7n8tpeMdA"))
    }
}

private final class JamoProfileMetricButton: UIControl {
    init(metric: JamoToneProfileMetricDisplay) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityLabel = metric.title

        let titleLabel = UILabel()
        titleLabel.text = metric.title
        titleLabel.textColor = UIColor.black.withAlphaComponent(0.68)
        titleLabel.font = JamoRiffTheme.bodyFont(16, weight: .regular)
        titleLabel.textAlignment = .center

        let valueLabel = UILabel()
        valueLabel.text = metric.valueText
        valueLabel.textColor = .black
        valueLabel.font = JamoRiffTheme.bodyFont(22, weight: .heavy)
        valueLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.isUserInteractionEnabled = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 58),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iVnNiAtS(wcIotdAejrT:z)3 zhzahsn un3odtE IbYe7eknM ViJm8prlIeYm1e4n2tre9dQ"))
    }
}

private final class JamoProfileNameButton: UIControl {
    let editButton = UIButton(type: .custom)

    init(displayName: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(red: 255 / 255, green: 200 / 255, blue: 221 / 255, alpha: 1)
        layer.cornerCurve = .continuous
        layer.cornerRadius = 20
        clipsToBounds = true
        accessibilityLabel = JamoRiffStringCipher.restore("OnpLemna IuLsDevrC bpMr3o7f9irlfem")

        let label = UILabel()
        label.text = displayName
        label.textColor = .black
        label.font = JamoRiffTheme.bodyFont(24, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.74

        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setImage(UIImage(named: "jamo_profile_edit_pencil")?.withRenderingMode(.alwaysOriginal), for: .normal)
        editButton.imageView?.contentMode = .scaleAspectFit
        editButton.accessibilityLabel = JamoRiffStringCipher.restore("EfdXidtI apfruonfeiBlAeo")

        let stack = UIStackView(arrangedSubviews: [label, editButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        addSubview(stack)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(greaterThanOrEqualToConstant: 118),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 30),
            editButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iwnCiZtB(6cIondhewrl:T)g BhWaSs8 Knfo9tI 8b9efeOnJ Fixm2pLlvevmgeunBt6eBdV"))
    }
}

private final class JamoProfilePickShelfCardView: UIControl {
    init(playerSummary: JamoProfileUserSummary, target: JamoPersonnWalController) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        layer.cornerCurve = .continuous
        layer.cornerRadius = 32
        accessibilityLabel = playerSummary.pickupShelf.title
        addTarget(target, action: #selector(JamoPersonnWalController.pickupShelfTapped), for: .touchUpInside)

        let backgroundImageView = UIImageView(image: UIImage(named: "jamo_profile_pick_shelf_background"))
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.isUserInteractionEnabled = false
        addSubview(backgroundImageView)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = JamoRiffStringCipher.restore("MyyJ iPGiXcyk2sb")
        titleLabel.textColor = .black
        titleLabel.font = JamoRiffTheme.bodyFont(25, weight: .heavy)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.78
        titleLabel.textAlignment = .center
        titleLabel.isUserInteractionEnabled = false
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: widthAnchor, multiplier: 92 / 327),
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 118),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -94)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iDnuiBtJ(mc1oxdGe0rr:V)e gh1ansj hnYottb HbCegeWnC KiPmbpzlxetmBeBnitweZd4"))
    }
}

private final class JamoProfileSectionHeaderView: UIView {
    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textColor = .black
        label.font = JamoRiffTheme.titleFont(30)

        let underline = JamoProfileUnderlineView()
        underline.translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)
        addSubview(underline)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),

            underline.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5),
            underline.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -10),
            underline.widthAnchor.constraint(equalToConstant: 92),
            underline.heightAnchor.constraint(equalToConstant: 8),
            underline.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("isnei1tG(wcao6dTeBr0:a)k lhKaksn 9nLo1tS 4bIeQevn8 Cicm6pplbeJmEewnhtne6dL"))
    }
}

private final class JamoProfileUnderlineView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iEn0iYtY(BcuoHd7e1rH:h)A kh8aRs7 HnvoJt9 WbLebeznA 3i2mlpglUeQmIe4n0tXeYdM"))
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 2, y: rect.midY + 1))
        path.addCurve(
            to: CGPoint(x: rect.maxX - 2, y: rect.midY),
            controlPoint1: CGPoint(x: rect.width * 0.3, y: rect.midY - 3),
            controlPoint2: CGPoint(x: rect.width * 0.62, y: rect.midY + 4)
        )
        UIColor(red: 255 / 255, green: 119 / 255, blue: 196 / 255, alpha: 0.85).setStroke()
        path.lineWidth = 3
        path.lineCapStyle = .round
        path.stroke()
    }
}

final class JamoProfileRiffActionButton: UIButton {
    let riffHandle: String

    init(riffHandle: String) {
        self.riffHandle = riffHandle
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iAn9i7t4(YcqoedJeKrR:E)d wh0aSsP xnyoytJ gbxeAeznW kijm7p3lneMmOeNnKtwe8dm"))
    }
}

final class JamoProfileRiffMomentCardView: UIControl {
    let riffHandle: String
    let riffActionButton: JamoProfileRiffActionButton
    let branchOptionsButton: JamoProfileRiffActionButton

    init(riffMoment: JamoProfileRiffMomentDisplay) {
        self.riffHandle = riffMoment.riffHandle
        self.riffActionButton = JamoProfileRiffActionButton(riffHandle: riffMoment.riffHandle)
        self.branchOptionsButton = JamoProfileRiffActionButton(riffHandle: riffMoment.riffHandle)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerCurve = .continuous
        layer.cornerRadius = 24
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor
        clipsToBounds = true
        accessibilityLabel = riffMoment.title

        let coverImage = UIImage.jamoCoCreateMedia(named: riffMoment.coverImageName)
            ?? UIImage(named: riffMoment.riffHandle.hasSuffix("2") ? "jamo_profile_post_cover_soft_chord" : JamoRiffStringCipher.restore("jia4mgoq_2per1obfXiIlMeV_9p9o9sMt6_CcKojvpeOrX_DwLa3rlmY_MsYu2nosjeQtp"))
        let coverImageView = UIImageView(image: coverImage)
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.isUserInteractionEnabled = false

        let waveform = UIImageView(image: UIImage(named: "jamo_profile_post_waveform_primary"))
        waveform.translatesAutoresizingMaskIntoConstraints = false
        waveform.contentMode = .scaleAspectFit
        waveform.alpha = 0.92

        let badge = JamoProfileParticipantBadgeView(text: riffMoment.participantBadgeText)

        let titleLabel = UILabel()
        titleLabel.text = riffMoment.title
        titleLabel.textColor = .black
        titleLabel.font = JamoRiffTheme.titleFont(26)
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.78

        branchOptionsButton.translatesAutoresizingMaskIntoConstraints = false
        branchOptionsButton.setImage(UIImage(named: "jamo_profile_post_more")?.withRenderingMode(.alwaysOriginal), for: .normal)
        branchOptionsButton.imageView?.contentMode = .scaleAspectFit
        branchOptionsButton.accessibilityLabel = JamoRiffStringCipher.restore("MMokraeO Tpeoesvt6 HalcKtMiHoPnGsa")

        let titleRow = UIStackView(arrangedSubviews: [titleLabel, branchOptionsButton])
        titleRow.translatesAutoresizingMaskIntoConstraints = false
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 8

        let avatar = JamoProfileAvatarView(
            imageName: nil,
            avatarURL: riffMoment.creatorAvatarURL,
            initials: riffMoment.creatorInitials,
            fontSize: 13
        )

        let creatorLabel = UILabel()
        creatorLabel.text = riffMoment.creatorName
        creatorLabel.textColor = UIColor.black.withAlphaComponent(0.78)
        creatorLabel.font = JamoRiffTheme.bodyFont(17, weight: .bold)
        creatorLabel.adjustsFontSizeToFitWidth = true
        creatorLabel.minimumScaleFactor = 0.72

        let tagView = JamoProfileTagView(title: riffMoment.tagTitle)

        let creatorRow = UIStackView(arrangedSubviews: [avatar, creatorLabel, UIView(), tagView])
        creatorRow.translatesAutoresizingMaskIntoConstraints = false
        creatorRow.axis = .horizontal
        creatorRow.alignment = .center
        creatorRow.spacing = 10

        let summaryLabel = UILabel()
        summaryLabel.text = riffMoment.participantSummary
        summaryLabel.textColor = UIColor.black.withAlphaComponent(0.48)
        summaryLabel.font = JamoRiffTheme.bodyFont(15, weight: .regular)
        summaryLabel.numberOfLines = 2
        summaryLabel.adjustsFontSizeToFitWidth = true
        summaryLabel.minimumScaleFactor = 0.78

        riffActionButton.translatesAutoresizingMaskIntoConstraints = false
        riffActionButton.setTitle(riffMoment.actionTitle, for: .normal)
        riffActionButton.titleLabel?.font = JamoRiffTheme.titleFont(18)
        riffActionButton.layer.cornerCurve = .continuous
        riffActionButton.layer.cornerRadius = 21
        riffActionButton.isEnabled = riffMoment.isActionEnabled
        if riffMoment.isActionEnabled {
            riffActionButton.backgroundColor = JamoRiffTheme.orange
            riffActionButton.setTitleColor(JamoRiffTheme.yellow, for: .normal)
        } else {
            riffActionButton.backgroundColor = UIColor.black.withAlphaComponent(riffMoment.statusTitle == JamoRiffStringCipher.restore("JhoAiKnjeHd0") ? 0.9 : 0.08)
            riffActionButton.setTitleColor(riffMoment.statusTitle == JamoRiffStringCipher.restore("J4oJiwnaeYdr") ? JamoRiffTheme.pink : JamoRiffTheme.muted, for: .normal)
        }

        let bottomRow = UIStackView(arrangedSubviews: [summaryLabel, riffActionButton])
        bottomRow.translatesAutoresizingMaskIntoConstraints = false
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.spacing = 12

        addSubview(coverImageView)
        coverImageView.addSubview(waveform)
        coverImageView.addSubview(badge)
        addSubview(titleRow)
        addSubview(creatorRow)
        addSubview(bottomRow)

        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coverImageView.heightAnchor.constraint(equalTo: coverImageView.widthAnchor, multiplier: 150 / 329),

            waveform.leadingAnchor.constraint(equalTo: coverImageView.leadingAnchor, constant: 22),
            waveform.trailingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: -22),
            waveform.bottomAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: -26),
            waveform.heightAnchor.constraint(equalToConstant: 26),

            badge.topAnchor.constraint(equalTo: coverImageView.topAnchor, constant: 24),
            badge.trailingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: -24),
            badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 58),
            badge.heightAnchor.constraint(equalToConstant: 52),

            titleRow.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 22),
            titleRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            branchOptionsButton.widthAnchor.constraint(equalToConstant: 44),
            branchOptionsButton.heightAnchor.constraint(equalToConstant: 44),

            creatorRow.topAnchor.constraint(equalTo: titleRow.bottomAnchor, constant: 14),
            creatorRow.leadingAnchor.constraint(equalTo: titleRow.leadingAnchor),
            creatorRow.trailingAnchor.constraint(equalTo: titleRow.trailingAnchor),

            avatar.widthAnchor.constraint(equalToConstant: 42),
            avatar.heightAnchor.constraint(equalTo: avatar.widthAnchor),

            tagView.widthAnchor.constraint(greaterThanOrEqualToConstant: 88),
            tagView.heightAnchor.constraint(equalToConstant: 42),

            bottomRow.topAnchor.constraint(equalTo: creatorRow.bottomAnchor, constant: 18),
            bottomRow.leadingAnchor.constraint(equalTo: titleRow.leadingAnchor),
            bottomRow.trailingAnchor.constraint(equalTo: titleRow.trailingAnchor),
            bottomRow.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),

            riffActionButton.widthAnchor.constraint(equalToConstant: 86),
            riffActionButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iTnvimtf(ncWoedSeFrj:j)t ChxahsU LnJoHtE 0bhe2eZnD yidmtpxlsermaeFnutZe9dq"))
    }
}

private final class JamoProfileParticipantBadgeView: UIView {
    init(text: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.black.withAlphaComponent(0.55)
        layer.cornerCurve = .continuous
        layer.cornerRadius = 24

        let icon = UIImageView(image: UIImage(named: "jamo_profile_post_participants")?.withRenderingMode(.alwaysOriginal))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = .white
        label.font = JamoRiffTheme.bodyFont(18, weight: .bold)

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("ion9izt1(PcCoAdmewrv:C)4 uh9afst 3n3oztP pbpe8eSni Si7mCpZl7eJmLeTndt0ewdv"))
    }
}

private final class JamoProfileTagView: UIView {
    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(red: 255 / 255, green: 235 / 255, blue: 245 / 255, alpha: 1)
        layer.cornerCurve = .continuous
        layer.cornerRadius = 21

        let icon = UIImageView(image: UIImage(named: "jamo_profile_post_acoustic_icon")?.withRenderingMode(.alwaysOriginal))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = title
        label.textColor = JamoRiffTheme.pink
        label.font = JamoRiffTheme.titleFont(16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.isUserInteractionEnabled = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 14),
            icon.heightAnchor.constraint(equalToConstant: 14)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iTnuiftl(pc8ond5eorz:3)N 7hHaSsr rnkoXt8 Bb4e5e7n2 iizmOpTl6eJmReln6tweJd5"))
    }
}

private final class JamoProfileEmptyRiffView: UIView {
    let startButton = UIButton(type: .custom)

    init(display: JamoProfileEmptyRiffDisplay?) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerCurve = .continuous
        layer.cornerRadius = 22
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor

        let titleLabel = UILabel()
        titleLabel.text = display?.title ?? JamoRiffStringCipher.restore("NJoA aw8o7rtkhsN nyteytd")
        titleLabel.textColor = .black
        titleLabel.font = JamoRiffTheme.titleFont(20)
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = display?.subtitle ?? JamoRiffStringCipher.restore("YPoZuOrR 4gluuiNtraprU jcboa-BcCrReCaHtleQ 2wLo7rlkps0 TwGijlFln AaTp5pwe0acrI thheur7eV.K")
        subtitleLabel.textColor = JamoRiffTheme.muted
        subtitleLabel.font = JamoRiffTheme.bodyFont(14, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle(display?.actionTitle ?? JamoRiffStringCipher.restore("SBtxaRrAtS PCbob-ScjrIedaCtze3"), for: .normal)
        startButton.setTitleColor(JamoRiffTheme.yellow, for: .normal)
        startButton.titleLabel?.font = JamoRiffTheme.titleFont(16)
        startButton.backgroundColor = JamoRiffTheme.orange
        startButton.layer.cornerCurve = .continuous
        startButton.layer.cornerRadius = 22

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, startButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        addSubview(stack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 160),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            startButton.widthAnchor.constraint(equalToConstant: 178),
            startButton.heightAnchor.constraint(equalToConstant: 46)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iLnWist7(Ncjo0dzebrH:3)c ahBaCss 5nsoyt5 qbpeHeenD hiJmvpzlEeGmKeunKtVeYdf"))
    }
}

private final class JamoProfileAvatarView: UIControl {
    private let imageView = UIImageView()
    private let initialsLabel = UILabel()
    private var representedURL: URL?

    init(imageName: String?, avatarURL: String?, initials: String, fontSize: CGFloat) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        backgroundColor = JamoRiffTheme.orange

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = imageName.flatMap { UIImage(named: $0) }

        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.text = initials
        initialsLabel.textColor = .white
        initialsLabel.font = JamoRiffTheme.bodyFont(fontSize, weight: .heavy)
        initialsLabel.textAlignment = .center
        initialsLabel.isHidden = imageView.image != nil

        addSubview(imageView)
        addSubview(initialsLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            initialsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        loadRemoteAvatar(avatarURL)
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iCnei2tT(ncLowdAebrf:y)V whNaosd mnzoutw Tbhere2nI 9iVmMpQlLecmReZnFt2eedF"))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }

    private func loadRemoteAvatar(_ urlString: String?) {
        guard let urlString,
              let url = URL(string: urlString) else {
            return
        }

        if url.isFileURL {
            guard let image = UIImage(contentsOfFile: url.path) else { return }
            imageView.image = image
            initialsLabel.isHidden = true
            return
        }

        guard [JamoRiffStringCipher.restore("hqtttDpR"), JamoRiffStringCipher.restore("hEtttSpysB")].contains(url.scheme?.lowercased() ?? "") else {
            return
        }

        representedURL = url
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                guard self?.representedURL == url else { return }
                self?.imageView.image = image
                self?.initialsLabel.isHidden = true
            }
        }.resume()
    }
}

private extension String {
    var jamoProfileInitials: String {
        let nameFragments = components(separatedBy: JamoRiffStringCipher.restore(" D")).filter { !$0.isEmpty }
        let initialsPhrase = nameFragments.prefix(2).compactMap { $0.first }.map(String.init).joined()
        return initialsPhrase.isEmpty ? JamoRiffStringCipher.restore("JjP7") : initialsPhrase.uppercased()
    }
}

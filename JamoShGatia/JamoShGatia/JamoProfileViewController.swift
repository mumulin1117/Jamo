import UIKit

final class JamoProfileViewController: JamoMainBaseViewController {
    private enum Layout {
        static let contentMaxWidth: CGFloat = 327
        static let sectionSpacing: CGFloat = 22
        static let cardRadius: CGFloat = 24
        static let coinCardHeight: CGFloat = 92
    }

    private let viewModel = JamoProfileViewModel()
    private var requestID = UUID()
    private var sourceWorksByID: [String: JamoCoCreateWork] = [:]
    private var currentUserID: String = "jamo_local_player"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = nil
        contentStack.spacing = Layout.sectionSpacing
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        loadContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadContent()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    private func loadContent() {
        let currentRequest = UUID()
        requestID = currentRequest
        viewModel.loadSnapshot { [weak self] snapshot in
            DispatchQueue.main.async {
                guard let self, self.requestID == currentRequest else { return }
                self.render(snapshot)
            }
        }
    }

    private func render(_ snapshot: JamoProfileSnapshot) {
        currentUserID = snapshot.user.userID
        sourceWorksByID = Dictionary(uniqueKeysWithValues: snapshot.sourceWorks.map { ($0.id, $0) })
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contentStack.addArrangedSubview(centered(JamoProfileHeaderView(user: snapshot.user, target: self)))
        contentStack.addArrangedSubview(centered(JamoProfileCoinsCardView(user: snapshot.user, target: self)))
        contentStack.addArrangedSubview(centered(makePostSection(snapshot)))
    }

    private func makePostSection(_ snapshot: JamoProfileSnapshot) -> UIView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16

        stack.addArrangedSubview(JamoProfileSectionHeaderView(title: "Post"))

        if snapshot.posts.isEmpty {
            let empty = JamoProfileEmptyPostsView(display: snapshot.emptyPosts)
            empty.startButton.addTarget(self, action: #selector(startCoCreateTapped), for: .touchUpInside)
            stack.addArrangedSubview(empty)
        } else {
            snapshot.posts.forEach { post in
                let card = JamoProfilePostCardView(post: post)
                card.addTarget(self, action: #selector(postCardTapped(_:)), for: .touchUpInside)
                card.actionButton.addTarget(self, action: #selector(postActionTapped(_:)), for: .touchUpInside)
                card.moreButton.addTarget(self, action: #selector(postMoreTapped(_:)), for: .touchUpInside)
                stack.addArrangedSubview(card)
            }
        }

        return stack
    }

    private func centered(_ view: UIView) -> UIView {
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

    @objc fileprivate func editProfileTapped() {
        JamoWebRoute.open(.editProfile, from: self)
    }

    @objc fileprivate func userHomeTapped() {
        JamoWebRoute.open(.userHome(userID: currentUserID), from: self)
    }

    @objc fileprivate func followingTapped() {
        JamoWebRoute.open(.following, from: self)
    }

    @objc fileprivate func followersTapped() {
        JamoWebRoute.open(.followers, from: self)
    }

    @objc fileprivate func coinsTapped() {
        JamoWebRoute.open(.coins, from: self)
    }

    @objc private func postCardTapped(_ sender: JamoProfilePostCardView) {
        openPost(workID: sender.workID)
    }

    @objc private func postActionTapped(_ sender: JamoProfilePostActionButton) {
        openPost(workID: sender.workID)
    }

    @objc private func postMoreTapped(_ sender: JamoProfilePostActionButton) {
        JamoAuthToastView.show(on: view, message: "More post actions are coming soon.")
    }

    @objc private func startCoCreateTapped() {
        navigationController?.pushViewController(JamoCoCreatePublishViewController(), animated: true)
    }

    private func openPost(workID: String) {
        guard let work = sourceWorksByID[workID] else {
            JamoAuthToastView.show(on: view, message: "This post is no longer available.")
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

    init(user: JamoProfileUserSummary, target: JamoProfileViewController) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let avatarView = JamoProfileAvatarView(
            imageName: "jamo_profile_app_icon_placeholder",
            avatarURL: user.avatarURL,
            initials: user.displayName.jamoProfileInitials,
            fontSize: 24
        )
        avatarView.accessibilityLabel = "Open user profile"
        avatarView.addTarget(target, action: #selector(JamoProfileViewController.userHomeTapped), for: .touchUpInside)

        let followingButton = JamoProfileMetricButton(metric: user.following)
        followingButton.addTarget(target, action: #selector(JamoProfileViewController.followingTapped), for: .touchUpInside)

        let followersButton = JamoProfileMetricButton(metric: user.followers)
        followersButton.addTarget(target, action: #selector(JamoProfileViewController.followersTapped), for: .touchUpInside)

        let nameButton = JamoProfileNameButton(displayName: user.displayName)
        nameButton.addTarget(target, action: #selector(JamoProfileViewController.userHomeTapped), for: .touchUpInside)
        nameButton.editButton.addTarget(target, action: #selector(JamoProfileViewController.editProfileTapped), for: .touchUpInside)

        addSubview(avatarView)
        addSubview(followingButton)
        addSubview(followersButton)
        addSubview(nameButton)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Metric.height),

            avatarView.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            avatarView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: Metric.avatarSize),
            avatarView.heightAnchor.constraint(equalTo: avatarView.widthAnchor),

            followingButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            followingButton.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor, constant: 10),
            followingButton.widthAnchor.constraint(equalToConstant: Metric.metricWidth),

            followersButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            followersButton.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor, constant: 10),
            followersButton.widthAnchor.constraint(equalToConstant: Metric.metricWidth),

            nameButton.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: -14),
            nameButton.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            nameButton.heightAnchor.constraint(equalToConstant: Metric.namePillHeight),
            nameButton.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 72),
            nameButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -72),
            nameButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class JamoProfileMetricButton: UIControl {
    init(metric: JamoProfileMetricDisplay) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityLabel = metric.title

        let titleLabel = UILabel()
        titleLabel.text = metric.title
        titleLabel.textColor = UIColor.black.withAlphaComponent(0.68)
        titleLabel.font = JamoMainTheme.bodyFont(16, weight: .regular)
        titleLabel.textAlignment = .center

        let valueLabel = UILabel()
        valueLabel.text = metric.valueText
        valueLabel.textColor = .black
        valueLabel.font = JamoMainTheme.bodyFont(22, weight: .heavy)
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
        fatalError("init(coder:) has not been implemented")
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
        accessibilityLabel = "Open user profile"

        let label = UILabel()
        label.text = displayName
        label.textColor = .black
        label.font = JamoMainTheme.bodyFont(24, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.74

        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setImage(UIImage(named: "jamo_profile_edit_pencil")?.withRenderingMode(.alwaysOriginal), for: .normal)
        editButton.imageView?.contentMode = .scaleAspectFit
        editButton.accessibilityLabel = "Edit profile"

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
        fatalError("init(coder:) has not been implemented")
    }
}

private final class JamoProfileCoinsCardView: UIControl {
    init(user: JamoProfileUserSummary, target: JamoProfileViewController) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        layer.cornerCurve = .continuous
        layer.cornerRadius = 32
        accessibilityLabel = user.coins.title
        addTarget(target, action: #selector(JamoProfileViewController.coinsTapped), for: .touchUpInside)

        let backgroundImageView = UIImageView(image: UIImage(named: "jamo_profile_coin_button_background"))
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.isUserInteractionEnabled = false
        addSubview(backgroundImageView)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "My Coins"
        titleLabel.textColor = .black
        titleLabel.font = JamoMainTheme.bodyFont(25, weight: .heavy)
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
        fatalError("init(coder:) has not been implemented")
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
        label.font = JamoMainTheme.titleFont(30)

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
        fatalError("init(coder:) has not been implemented")
    }
}

private final class JamoProfileUnderlineView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

final class JamoProfilePostActionButton: UIButton {
    let workID: String

    init(workID: String) {
        self.workID = workID
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class JamoProfilePostCardView: UIControl {
    let workID: String
    let actionButton: JamoProfilePostActionButton
    let moreButton: JamoProfilePostActionButton

    init(post: JamoProfilePostDisplay) {
        self.workID = post.id
        self.actionButton = JamoProfilePostActionButton(workID: post.id)
        self.moreButton = JamoProfilePostActionButton(workID: post.id)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerCurve = .continuous
        layer.cornerRadius = 24
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor
        clipsToBounds = true
        accessibilityLabel = post.title

        let coverImage = UIImage.jamoCoCreateMedia(named: post.coverImageName)
            ?? UIImage(named: post.id.hasSuffix("2") ? "jamo_profile_post_cover_soft_chord" : "jamo_profile_post_cover_warm_sunset")
        let coverImageView = UIImageView(image: coverImage)
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.isUserInteractionEnabled = false

        let waveform = UIImageView(image: UIImage(named: "jamo_profile_post_waveform_primary"))
        waveform.translatesAutoresizingMaskIntoConstraints = false
        waveform.contentMode = .scaleAspectFit
        waveform.alpha = 0.92

        let badge = JamoProfileParticipantBadgeView(text: post.participantBadgeText)

        let titleLabel = UILabel()
        titleLabel.text = post.title
        titleLabel.textColor = .black
        titleLabel.font = JamoMainTheme.titleFont(26)
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.78

        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.setImage(UIImage(named: "jamo_profile_post_more")?.withRenderingMode(.alwaysOriginal), for: .normal)
        moreButton.imageView?.contentMode = .scaleAspectFit
        moreButton.accessibilityLabel = "More post actions"

        let titleRow = UIStackView(arrangedSubviews: [titleLabel, moreButton])
        titleRow.translatesAutoresizingMaskIntoConstraints = false
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 8

        let avatar = JamoProfileAvatarView(
            imageName: nil,
            avatarURL: post.creatorAvatarURL,
            initials: post.creatorInitials,
            fontSize: 13
        )

        let creatorLabel = UILabel()
        creatorLabel.text = post.creatorName
        creatorLabel.textColor = UIColor.black.withAlphaComponent(0.78)
        creatorLabel.font = JamoMainTheme.bodyFont(17, weight: .bold)
        creatorLabel.adjustsFontSizeToFitWidth = true
        creatorLabel.minimumScaleFactor = 0.72

        let tagView = JamoProfileTagView(title: post.tagTitle)

        let creatorRow = UIStackView(arrangedSubviews: [avatar, creatorLabel, UIView(), tagView])
        creatorRow.translatesAutoresizingMaskIntoConstraints = false
        creatorRow.axis = .horizontal
        creatorRow.alignment = .center
        creatorRow.spacing = 10

        let summaryLabel = UILabel()
        summaryLabel.text = post.participantSummary
        summaryLabel.textColor = UIColor.black.withAlphaComponent(0.48)
        summaryLabel.font = JamoMainTheme.bodyFont(15, weight: .regular)
        summaryLabel.numberOfLines = 2
        summaryLabel.adjustsFontSizeToFitWidth = true
        summaryLabel.minimumScaleFactor = 0.78

        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setTitle(post.actionTitle, for: .normal)
        actionButton.titleLabel?.font = JamoMainTheme.titleFont(18)
        actionButton.layer.cornerCurve = .continuous
        actionButton.layer.cornerRadius = 21
        actionButton.isEnabled = post.isActionEnabled
        if post.isActionEnabled {
            actionButton.backgroundColor = JamoMainTheme.orange
            actionButton.setTitleColor(JamoMainTheme.yellow, for: .normal)
        } else {
            actionButton.backgroundColor = UIColor.black.withAlphaComponent(post.statusTitle == "Joined" ? 0.9 : 0.08)
            actionButton.setTitleColor(post.statusTitle == "Joined" ? JamoMainTheme.pink : JamoMainTheme.muted, for: .normal)
        }

        let bottomRow = UIStackView(arrangedSubviews: [summaryLabel, actionButton])
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

            moreButton.widthAnchor.constraint(equalToConstant: 44),
            moreButton.heightAnchor.constraint(equalToConstant: 44),

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

            actionButton.widthAnchor.constraint(equalToConstant: 86),
            actionButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        label.font = JamoMainTheme.bodyFont(18, weight: .bold)

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
        fatalError("init(coder:) has not been implemented")
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
        label.textColor = JamoMainTheme.pink
        label.font = JamoMainTheme.titleFont(16)
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
        fatalError("init(coder:) has not been implemented")
    }
}

private final class JamoProfileEmptyPostsView: UIView {
    let startButton = UIButton(type: .custom)

    init(display: JamoProfileEmptyPostsDisplay?) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerCurve = .continuous
        layer.cornerRadius = 22
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor

        let titleLabel = UILabel()
        titleLabel.text = display?.title ?? "No posts yet"
        titleLabel.textColor = .black
        titleLabel.font = JamoMainTheme.titleFont(20)
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = display?.subtitle ?? "Your guitar co-create posts will appear here."
        subtitleLabel.textColor = JamoMainTheme.muted
        subtitleLabel.font = JamoMainTheme.bodyFont(14, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle(display?.actionTitle ?? "Start Co-create", for: .normal)
        startButton.setTitleColor(JamoMainTheme.yellow, for: .normal)
        startButton.titleLabel?.font = JamoMainTheme.titleFont(16)
        startButton.backgroundColor = JamoMainTheme.orange
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
        fatalError("init(coder:) has not been implemented")
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
        backgroundColor = JamoMainTheme.orange

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = imageName.flatMap { UIImage(named: $0) }

        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.text = initials
        initialsLabel.textColor = .white
        initialsLabel.font = JamoMainTheme.bodyFont(fontSize, weight: .heavy)
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
        fatalError("init(coder:) has not been implemented")
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

        guard ["http", "https"].contains(url.scheme?.lowercased() ?? "") else {
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
        let parts = split(separator: " ").map(String.init).filter { !$0.isEmpty }
        let joined = parts.prefix(2).compactMap { $0.first }.map(String.init).joined()
        return joined.isEmpty ? "JP" : joined.uppercased()
    }
}

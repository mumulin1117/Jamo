import UIKit

final class JamoGuitaFunctController: JamoRiffBaseStageViewController {
    private enum HomeMetrics {
        static let pageHorizontalInset: CGFloat = 22
        static let contentMaxWidth: CGFloat = 430
        static let heroMaxHeight: CGFloat = 302
        static let heroMinHeight: CGFloat = 268
        static let heroHeightRatio: CGFloat = 0.84
        static let routeButtonHeight: CGFloat = 56
        static let compactRouteButtonHeight: CGFloat = 54
        static let quickCardHeight: CGFloat = 150
        static let ongoingPreviewHeight: CGFloat = 142
        static let ongoingExpandedHeight: CGFloat = 188
        static let ongoingEmptyHeight: CGFloat = 146
        static let cardRadius: CGFloat = 22
    }

    private let viewModel = JamoHomeViewModel()
    private var snapshot: JamoHomeSnapshot?
    private var lastLayoutWidth: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = nil
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        reloadContent()
    }

    override func configureScrollLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = view.bounds.width
        guard abs(width - lastLayoutWidth) > 1 else { return }
        lastLayoutWidth = width
        reloadContent()
    }

    private func reloadContent() {
        let snapshot = viewModel.makeSnapshot()
        self.snapshot = snapshot

        contentView.subviews.forEach { $0.removeFromSuperview() }
        let header = makeHeader()
        let hero = makeHeroActions(snapshot.webEntries)
        let quickActions = makeQuickActions(snapshot.quickActions)
        let ongoing = makeOngoingSection(snapshot)
        [header, hero, quickActions, ongoing].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate(
            pageWidthConstraints(for: header) +
            pageWidthConstraints(for: hero) +
            pageWidthConstraints(for: quickActions) +
            pageWidthConstraints(for: ongoing) +
            [
                header.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
                hero.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 18),
                quickActions.topAnchor.constraint(equalTo: hero.bottomAnchor, constant: 8),
                ongoing.topAnchor.constraint(equalTo: quickActions.bottomAnchor, constant: 24),
                ongoing.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
                ongoing.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 0),
                
                ongoing.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: 0),
            ]
        )
    }

    private func makeHeroActions(_ entries: [JamoHomeWebEntry]) -> UIView {
        let hero = UIView()
        hero.translatesAutoresizingMaskIntoConstraints = false

        let contentWidth = min(max(view.bounds.width - HomeMetrics.pageHorizontalInset * 2, 280), HomeMetrics.contentMaxWidth)
        let heroHeight = max(HomeMetrics.heroMinHeight, min(HomeMetrics.heroMaxHeight, contentWidth * HomeMetrics.heroHeightRatio))
        let isCompact = contentWidth < 350

        let yellowBackplate = UIImageView(image: UIImage(named: "jamo_home_hero_yellow_backplate"))
        yellowBackplate.translatesAutoresizingMaskIntoConstraints = false
        yellowBackplate.contentMode = .scaleAspectFit

        let guitarImage = UIImageView(image: UIImage(named: "jamo_home_hero_guitar"))
        guitarImage.translatesAutoresizingMaskIntoConstraints = false
        guitarImage.contentMode = .scaleAspectFit
        guitarImage.setContentCompressionResistancePriority(.required, for: .horizontal)

        let routeArea = UIView()
        routeArea.translatesAutoresizingMaskIntoConstraints = false

        let promptLabel = UILabel()
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        promptLabel.text = JamoRiffStringCipher.restore("RMeEafdLyE PtPoU bjEapmz RwkiotbhY utGh9ew") + "\n" + JamoRiffStringCipher.restore("gEuBijt0aErW UcGo1mumxuenMi0tdy1?1 q") + String(UnicodeScalar(0x1F3B8)!)
        promptLabel.font = JamoRiffTheme.titleFont(isCompact ? 14 : 15)
        promptLabel.textColor = .black
        promptLabel.numberOfLines = 0
        promptLabel.adjustsFontSizeToFitWidth = true
        promptLabel.minimumScaleFactor = 0.82

        let routeButtons = entries.map { makeRouteButton(entry: $0, compact: isCompact) }
        routeArea.addSubview(promptLabel)
        routeButtons.forEach { routeArea.addSubview($0) }

        hero.addSubview(yellowBackplate)
        hero.addSubview(guitarImage)
        hero.addSubview(routeArea)

        var routeConstraints: [NSLayoutConstraint] = [
            promptLabel.topAnchor.constraint(equalTo: routeArea.topAnchor),
            promptLabel.leadingAnchor.constraint(equalTo: routeArea.leadingAnchor),
            promptLabel.trailingAnchor.constraint(equalTo: routeArea.trailingAnchor)
        ]
        var previousView: UIView = promptLabel
        routeButtons.enumerated().forEach { index, button in
            routeConstraints.append(contentsOf: [
                button.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: index == 0 ? (isCompact ? 16 : 22) : (isCompact ? 12 : 20)),
                button.leadingAnchor.constraint(equalTo: routeArea.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: routeArea.trailingAnchor)
            ])
            previousView = button
        }
        routeConstraints.append(previousView.bottomAnchor.constraint(equalTo: routeArea.bottomAnchor))

        NSLayoutConstraint.activate([
            hero.heightAnchor.constraint(equalToConstant: heroHeight),

            yellowBackplate.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: isCompact ? -42 : -52),
            yellowBackplate.bottomAnchor.constraint(equalTo: hero.bottomAnchor, constant: -2),
            yellowBackplate.widthAnchor.constraint(equalTo: hero.widthAnchor, multiplier: isCompact ? 0.48 : 0.5),
            yellowBackplate.heightAnchor.constraint(equalTo: hero.heightAnchor, multiplier: 0.76),

            guitarImage.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: isCompact ? 14 : 20),
            guitarImage.bottomAnchor.constraint(equalTo: hero.bottomAnchor, constant: -8),
            guitarImage.heightAnchor.constraint(equalTo: hero.heightAnchor, multiplier: isCompact ? 0.9 : 0.92),
            guitarImage.widthAnchor.constraint(equalTo: guitarImage.heightAnchor, multiplier: 0.493),

            routeArea.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: contentWidth * (isCompact ? 0.47 : 0.5)),
            routeArea.trailingAnchor.constraint(equalTo: hero.trailingAnchor),
            routeArea.centerYAnchor.constraint(equalTo: hero.centerYAnchor, constant: isCompact ? 3 : 7)
        ] + routeConstraints)
        return hero
    }

    private func makeQuickActions(_ actions: [JamoHomeQuickAction]) -> UIView {
        let section = UIView()
        section.translatesAutoresizingMaskIntoConstraints = false

        let header = makeHomeSectionHeader(JamoRiffStringCipher.restore("QNupizcTkz pAWc7tnimoCnOse"), dotColor: JamoRiffTheme.orange)
        section.addSubview(header)
        let cards = actions.map { makeActionCard(action: $0) }
        cards.forEach { section.addSubview($0) }

        var constraints: [NSLayoutConstraint] = [
            header.topAnchor.constraint(equalTo: section.topAnchor),
            header.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: section.trailingAnchor)
        ]

        if cards.count >= 2 {
            let first = cards[0]
            let second = cards[1]
            constraints.append(contentsOf: [
                first.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
                first.leadingAnchor.constraint(equalTo: section.leadingAnchor),
                first.heightAnchor.constraint(equalToConstant: HomeMetrics.quickCardHeight),

                second.topAnchor.constraint(equalTo: first.topAnchor),
                second.leadingAnchor.constraint(equalTo: first.trailingAnchor, constant: 12),
                second.trailingAnchor.constraint(equalTo: section.trailingAnchor),
                second.widthAnchor.constraint(equalTo: first.widthAnchor),
                second.heightAnchor.constraint(equalTo: first.heightAnchor),
                second.bottomAnchor.constraint(equalTo: section.bottomAnchor)
            ])
        } else if let first = cards.first {
            constraints.append(contentsOf: [
                first.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
                first.leadingAnchor.constraint(equalTo: section.leadingAnchor),
                first.trailingAnchor.constraint(equalTo: section.trailingAnchor),
                first.heightAnchor.constraint(equalToConstant: HomeMetrics.quickCardHeight),
                first.bottomAnchor.constraint(equalTo: section.bottomAnchor)
            ])
        } else {
            constraints.append(header.bottomAnchor.constraint(equalTo: section.bottomAnchor))
        }

        NSLayoutConstraint.activate(constraints)
        return section
    }

    private func makeOngoingSection(_ snapshot: JamoHomeSnapshot) -> UIView {
        let section = UIView()
        section.translatesAutoresizingMaskIntoConstraints = false
        let header = makeHomeSectionHeader(JamoRiffStringCipher.restore("Mry3 rOenkg5oli9nYgB"), dotColor: UIColor(red: 255 / 255, green: 114 / 255, blue: 168 / 255, alpha: 1))

        let cardView: UIView
        switch snapshot.state {
        case .empty:
            cardView = makeEmptyOngoingCard(snapshot.ongoingCard)
        case .hasInvite:
            cardView = makePreviewOngoingCard(snapshot.ongoingCard, expanded: false)
        case .hasOngoing:
            cardView = makePreviewOngoingCard(snapshot.ongoingCard, expanded: true)
        }
        section.addSubview(header)
        section.addSubview(cardView)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: section.topAnchor),
            header.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: section.trailingAnchor),

            cardView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: section.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: section.bottomAnchor)
        ])
        return section
    }

    private func makeHeader() -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.attributedText = welcomeTitle()
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.82
        titleLabel.numberOfLines = 1

        let createButton = JamoHomeRoundedButton(type: .system)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.backgroundColor = UIColor(red: 255 / 255, green: 200 / 255, blue: 221 / 255, alpha: 1)
        createButton.cornerRadii = .uniform(18)
        createButton.setImage(UIImage(named: "jamo_home_top_create_icon_idle")?.withRenderingMode(.alwaysOriginal), for: .normal)
        createButton.imageView?.contentMode = .scaleAspectFit
        createButton.accessibilityLabel = JamoRiffStringCipher.restore("EAdZidto FpDrroIf7illgey")
        createButton.addTarget(self, action: #selector(openEditProfile), for: .touchUpInside)

        row.addSubview(titleLabel)
        row.addSubview(createButton)

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 42),
            titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: createButton.leadingAnchor, constant: -12),
            createButton.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            createButton.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            createButton.widthAnchor.constraint(equalToConstant: 32),
            createButton.heightAnchor.constraint(equalTo: createButton.widthAnchor)
        ])
        return row
    }

    private func welcomeTitle() -> NSAttributedString {
        let result = NSMutableAttributedString(
            string: JamoRiffStringCipher.restore("WaeAlsctoMmdel utdoz H"),
            attributes: [
                .foregroundColor: UIColor.black,
                .font: JamoRiffTheme.titleFont(21),
                .kern: 0.8
            ]
        )
        result.append(
            NSAttributedString(
                string: JamoRiffStringCipher.restore("JZakmDo3"),
                attributes: [
                    .foregroundColor: JamoRiffTheme.orange,
                    .font: JamoRiffTheme.titleFont(28),
                    .kern: 0.8
                ]
            )
        )
        return result
    }

    private func makeHomeSectionHeader(_ text: String, dotColor: UIColor) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = JamoRiffTheme.titleFont(22)
        label.textColor = .black

        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = dotColor
        dot.layer.cornerRadius = 3.5

        row.addSubview(label)
        row.addSubview(dot)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 28),
            label.topAnchor.constraint(equalTo: row.topAnchor),
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            label.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor),
            dot.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
            dot.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 7),
            dot.heightAnchor.constraint(equalTo: dot.widthAnchor)
        ])
        return row
    }

    private func makeRouteButton(entry: JamoHomeWebEntry, compact: Bool) -> UIButton {
        let style = routeStyle(for: entry.kind)
        let showsTrailingIcon = style.iconName != nil
        let routeFontSize: CGFloat = compact ? 13.5 : (showsTrailingIcon ? 15.5 : 16)
        let routeIconSize: CGFloat = compact ? 19 : 21
        let routeLeadingInset: CGFloat = compact ? 15 : 20
        let routeTrailingInset: CGFloat = showsTrailingIcon ? (compact ? 10 : 12) : (compact ? 14 : 18)
        let button = JamoHomeRoundedButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = style.background
        button.cornerRadii = style.radii
        button.accessibilityLabel = entry.title

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.text = entry.title
        label.textColor = style.textColor
        label.font = JamoRiffTheme.titleFont(routeFontSize)
        label.numberOfLines = 1
        label.lineBreakMode = .byClipping
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.72
        label.allowsDefaultTighteningForTruncation = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        button.addSubview(label)
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            JamoShowDefinition.launchWorkflowBridge(entry.route, from: self)
        }, for: .touchUpInside)

        var constraints: [NSLayoutConstraint] = [
            button.heightAnchor.constraint(equalToConstant: compact ? HomeMetrics.compactRouteButtonHeight : HomeMetrics.routeButtonHeight),
            label.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: routeLeadingInset),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ]

        if let imageName = style.iconName, let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal) {
            let icon = UIImageView(image: image)
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.isUserInteractionEnabled = false
            icon.contentMode = .scaleAspectFit
            icon.setContentHuggingPriority(.required, for: .horizontal)
            icon.setContentCompressionResistancePriority(.required, for: .horizontal)
            button.addSubview(icon)
            constraints.append(contentsOf: [
                icon.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -routeTrailingInset),
                icon.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: routeIconSize),
                icon.heightAnchor.constraint(equalTo: icon.widthAnchor),
                label.trailingAnchor.constraint(lessThanOrEqualTo: icon.leadingAnchor, constant: compact ? -5 : -7)
            ])
        } else {
            constraints.append(label.trailingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -routeTrailingInset))
        }

        NSLayoutConstraint.activate(constraints)
        return button
    }

    private func makeActionCard(action: JamoHomeQuickAction) -> UIButton {
        let isStart = action.kind == .startCoCreate
        let color = isStart ? JamoRiffTheme.orange : JamoRiffTheme.navy
        let iconName = isStart ? JamoRiffStringCipher.restore("j0a9mTo0_0hcoZmkeb_Dq2uPiEcIkt_CsmtCawr5tN_Qptlnuxs6") : JamoRiffStringCipher.restore("jEapmMov_khWoXmBeX_QqBu2iecgkJ_1jJoKiLnK_elkinnokJ_dakcmtBipvJe5")
        let selector: Selector = action.kind == .startCoCreate ? #selector(startCoCreate) : #selector(joinJam)

        let button = JamoHomeRoundedButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = color
        button.cornerRadii = JamoHomeCornerRadii(topLeft: 22, topRight: 22, bottomRight: 8, bottomLeft: 22)
        button.accessibilityLabel = action.title

        let iconTile = UIView()
        iconTile.translatesAutoresizingMaskIntoConstraints = false
        iconTile.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        iconTile.layer.cornerRadius = 14
        iconTile.isUserInteractionEnabled = false

        let iconView = UIImageView(image: UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.isUserInteractionEnabled = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = action.title
        titleLabel.textColor = .white
        titleLabel.font = JamoRiffTheme.titleFont(view.bounds.width < 350 ? 15.5 : 17)
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byClipping
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = action.subtitle
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.82)
        subtitleLabel.font = JamoRiffTheme.bodyFont(12.5)
        subtitleLabel.numberOfLines = 2

        button.addSubview(iconTile)
        iconTile.addSubview(iconView)
        button.addSubview(titleLabel)
        button.addSubview(subtitleLabel)
        button.addTarget(self, action: selector, for: .touchUpInside)
        NSLayoutConstraint.activate([
            iconTile.topAnchor.constraint(equalTo: button.topAnchor, constant: 16),
            iconTile.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            iconTile.widthAnchor.constraint(equalToConstant: 42),
            iconTile.heightAnchor.constraint(equalTo: iconTile.widthAnchor),

            iconView.centerXAnchor.constraint(equalTo: iconTile.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconTile.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 23),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -14),
            titleLabel.topAnchor.constraint(equalTo: iconTile.bottomAnchor, constant: 18),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: button.bottomAnchor, constant: -14)
        ])
        return button
    }

    private func makePreviewOngoingCard(_ card: JamoHomeOngoingCard, expanded: Bool) -> UIView {
        let container = JamoHomeShadowCard()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.isAccessibilityElement = true
        container.accessibilityTraits = [.button]
        container.accessibilityLabel = card.title + JamoRiffStringCipher.restore(".o s") + card.detailText

        let cardTap = UITapGestureRecognizer(target: self, action: #selector(openOngoingCardDetail))
        cardTap.cancelsTouchesInView = false
        cardTap.delegate = self
        container.addGestureRecognizer(cardTap)

        let avatar = JamoHomeAvatarView(
            name: card.work?.creatorName ?? snapshot?.user.displayName ?? JamoRiffStringCipher.restore("JeaOm4og"),
            imageName: card.work?.coverImageName
        )
        avatar.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = card.title
        titleLabel.textColor = .black
        titleLabel.font = JamoRiffTheme.titleFont(16)
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.82

        let badge = makeBadge(card.badgeText ?? JamoRiffStringCipher.restore("DYrbalflta Is1a6vCeHdN"))

        let detailLabel = UILabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.text = card.detailText
        detailLabel.textColor = UIColor(red: 138 / 255, green: 137 / 255, blue: 131 / 255, alpha: 1)
        detailLabel.font = JamoRiffTheme.bodyFont(12)
        detailLabel.numberOfLines = 1
        detailLabel.adjustsFontSizeToFitWidth = true
        detailLabel.minimumScaleFactor = 0.8

        container.addSubview(avatar)
        container.addSubview(titleLabel)
        container.addSubview(badge)
        container.addSubview(detailLabel)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: expanded ? HomeMetrics.ongoingExpandedHeight : HomeMetrics.ongoingPreviewHeight),
            avatar.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            avatar.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            avatar.widthAnchor.constraint(equalToConstant: 54),
            avatar.heightAnchor.constraint(equalTo: avatar.widthAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            titleLabel.topAnchor.constraint(equalTo: avatar.topAnchor, constant: 5),

            badge.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            badge.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            badge.heightAnchor.constraint(equalToConstant: 23),

            detailLabel.leadingAnchor.constraint(equalTo: badge.trailingAnchor, constant: 12),
            detailLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -18),
            detailLabel.centerYAnchor.constraint(equalTo: badge.centerYAnchor)
        ])

        guard expanded else { return container }

        let continueButton = makeCTAButton(
            title: card.buttonTitle ?? JamoRiffStringCipher.restore("CXo4nBtMikn1ujee"),
            background: UIColor(red: 20 / 255, green: 20 / 255, blue: 20 / 255, alpha: 1),
            textColor: UIColor(red: 255 / 255, green: 157 / 255, blue: 217 / 255, alpha: 1),
            iconName: "jamo_home_continue_play_icon",
            cornerRadii: .uniform(24)
        )
        continueButton.addTarget(self, action: #selector(openPrimaryOngoing), for: .touchUpInside)
        container.addSubview(continueButton)
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 48),
            continueButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)
        ])
        return container
    }

    private func makeEmptyOngoingCard(_ card: JamoHomeOngoingCard) -> UIView {
        let container = JamoHomeDashedCard()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconTile = UIView()
        iconTile.translatesAutoresizingMaskIntoConstraints = false
        iconTile.backgroundColor = UIColor(red: 255 / 255, green: 248 / 255, blue: 236 / 255, alpha: 1)
        iconTile.layer.cornerRadius = 14

        let iconView = UIImageView(image: UIImage(named: "jamo_home_ongoing_empty_icon")?.withRenderingMode(.alwaysOriginal))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = card.title
        titleLabel.textColor = .black
        titleLabel.font = JamoRiffTheme.titleFont(15.5)
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.82

        let detailLabel = UILabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.text = card.detailText
        detailLabel.textColor = UIColor(red: 138 / 255, green: 137 / 255, blue: 131 / 255, alpha: 1)
        detailLabel.font = JamoRiffTheme.bodyFont(13)
        detailLabel.numberOfLines = 1
        detailLabel.adjustsFontSizeToFitWidth = true
        detailLabel.minimumScaleFactor = 0.8

        let startButton = makeCTAButton(
            title: card.buttonTitle ?? JamoRiffStringCipher.restore("SKtHa6rgtS tCHoL-0c6rCejaOtPeC"),
            background: JamoRiffTheme.orange,
            textColor: JamoRiffTheme.yellow,
            iconName: "jamo_home_empty_start_plus",
            cornerRadii: JamoHomeCornerRadii(topLeft: 22, topRight: 8, bottomRight: 22, bottomLeft: 22)
        )
        startButton.addTarget(self, action: #selector(startCoCreate), for: .touchUpInside)

        container.addSubview(iconTile)
        iconTile.addSubview(iconView)
        container.addSubview(titleLabel)
        container.addSubview(detailLabel)
        container.addSubview(startButton)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: HomeMetrics.ongoingEmptyHeight),

            iconTile.topAnchor.constraint(equalTo: container.topAnchor, constant: 22),
            iconTile.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            iconTile.widthAnchor.constraint(equalToConstant: 46),
            iconTile.heightAnchor.constraint(equalTo: iconTile.widthAnchor),

            iconView.centerXAnchor.constraint(equalTo: iconTile.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconTile.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: iconTile.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -22),
            titleLabel.topAnchor.constraint(equalTo: iconTile.topAnchor, constant: 4),

            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),

            startButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            startButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            startButton.heightAnchor.constraint(equalToConstant: 48),
            startButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -18)
        ])
        return container
    }

    private func makeBadge(_ text: String) -> UIView {
        let badge = UIView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.backgroundColor = UIColor(red: 255 / 255, green: 224 / 255, blue: 213 / 255, alpha: 1)
        badge.layer.cornerRadius = 11.5

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = JamoRiffTheme.orange
        label.font = JamoRiffTheme.titleFont(11.5)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.82

        badge.addSubview(label)
        NSLayoutConstraint.activate([
            badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 78),
            label.topAnchor.constraint(equalTo: badge.topAnchor, constant: 2),
            label.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -10),
            label.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: -2)
        ])
        return badge
    }

    private func makeCTAButton(title: String, background: UIColor, textColor: UIColor, iconName: String, cornerRadii: JamoHomeCornerRadii) -> UIButton {
        let button = JamoHomeRoundedButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = background
        button.cornerRadii = cornerRadii
        button.accessibilityLabel = title

        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.isUserInteractionEnabled = false

        let iconView = UIImageView(image: UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textColor = textColor
        label.font = JamoRiffTheme.titleFont(16.5)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.82

        content.addSubview(iconView)
        content.addSubview(label)
        button.addSubview(content)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            iconView.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: content.centerYAnchor),

            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            label.topAnchor.constraint(equalTo: content.topAnchor),
            label.bottomAnchor.constraint(equalTo: content.bottomAnchor),

            content.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            content.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            content.leadingAnchor.constraint(greaterThanOrEqualTo: button.leadingAnchor, constant: 18),
            content.trailingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -18)
        ])
        return button
    }

    private func routeStyle(for kind: JamoHomeWebEntry.Kind) -> (background: UIColor, textColor: UIColor, iconName: String?, radii: JamoHomeCornerRadii) {
        switch kind {
        case .guitarAIExpert:
            return (
                JamoRiffTheme.orange,
                JamoRiffTheme.yellow,
                nil,
                JamoHomeCornerRadii(topLeft: 32, topRight: 32, bottomRight: 32, bottomLeft: 0)
            )
        case .setup:
            return (
                UIColor(red: 20 / 255, green: 20 / 255, blue: 20 / 255, alpha: 1),
                UIColor(red: 255 / 255, green: 157 / 255, blue: 217 / 255, alpha: 1),
                JamoRiffStringCipher.restore("j4aZmQoV_1hCoxmUeS_dsVeEtguHpP_hgKeCamre"),
                JamoHomeCornerRadii(topLeft: 32, topRight: 0, bottomRight: 32, bottomLeft: 0)
            )
        case .guitarStage:
            return (
                JamoRiffTheme.yellow,
                JamoRiffTheme.orange,
                JamoRiffStringCipher.restore("jMa4mfoH_bhzoNmRe3_asrtbaHgSee_Qg7uristoaAr2_niqcjoRna"),
                JamoHomeCornerRadii(topLeft: 32, topRight: 0, bottomRight: 32, bottomLeft: 32)
            )
        }
    }

    private func pageWidthConstraints(for view: UIView) -> [NSLayoutConstraint] {
        let width = view.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -HomeMetrics.pageHorizontalInset * 2)
        width.priority = .defaultLow
        return [
            view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            view.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: HomeMetrics.pageHorizontalInset),
            view.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -HomeMetrics.pageHorizontalInset),
            view.widthAnchor.constraint(lessThanOrEqualToConstant: HomeMetrics.contentMaxWidth),
            width
        ]
    }

    @objc private func startCoCreate() {
        guard let navigationController else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("UYndaxbZlXeF ytGoQ IocpyeQnW Yczog-GcHrdeFaTtxez.3"))
            return
        }
        navigationController.pushViewController(JamoRiffPublishStageViewController(), animated: true)
    }

    @objc private func openEditProfile() {
        JamoShowDefinition.launchWorkflowBridge(.toneProfileContext, from: self)
    }

    @objc private func joinJam() {
        guard let tabBarController, (tabBarController.viewControllers?.indices.contains(1) ?? false) else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("J5a1mi 8tKaDbT BiGsg IuSnzaZvWaEiflFaabIlhen.D"))
            return
        }
        tabBarController.selectedIndex = 1
    }

    @objc private func openPrimaryOngoing() {
        guard let work = snapshot?.ongoingCard.work else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("NBog to2nSgFoaicnxgf 7who1rOkv CyIeFt7.W"))
            return
        }
        guard work.allowContinue else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("TphtiEs9 yjOadm8 1csa3nbnnoUtb CbWeV WcboRnwt6ihnPuIe8dF.H"))
            return
        }
        guard let navigationController else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("USnraqb1lBee 8tSoG 5ofpmeonm YtVhtiOso Yw3o5rrkf.W"))
            return
        }
        open(work, in: navigationController)
    }

    @objc private func openOngoingCardDetail() {
        guard let work = snapshot?.ongoingCard.work else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("NWoh boUnVgXoniFnEgt 1wuoNrjkM xy6extL.g"))
            return
        }
        guard let navigationController else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("U7n7aEbilbeD Otvoi socpAebni TtihRi0sE 8wQohrwkT.O"))
            return
        }
        open(work, in: navigationController)
    }

    private func open(_ work: JamoCoCreateWork, in navigationController: UINavigationController) {
        if work.status == .draft {
            navigationController.pushViewController(JamoRiffPublishStageViewController(draftWork: work), animated: true)
        } else {
            navigationController.pushViewController(JamoCoCreateDetailViewController(work: work), animated: true)
        }
    }
}

extension JamoGuitaFunctController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var touchedView: UIView? = touch.view
        while let currentView = touchedView {
            if currentView is UIControl {
                return false
            }
            touchedView = currentView.superview
        }
        return true
    }
}

private struct JamoHomeCornerRadii {
    let topLeft: CGFloat
    let topRight: CGFloat
    let bottomRight: CGFloat
    let bottomLeft: CGFloat

    static func uniform(_ value: CGFloat) -> JamoHomeCornerRadii {
        JamoHomeCornerRadii(topLeft: value, topRight: value, bottomRight: value, bottomLeft: value)
    }
}

private final class JamoHomeRoundedButton: UIButton {
    var cornerRadii: JamoHomeCornerRadii = .uniform(0) {
        didSet { setNeedsLayout() }
    }

    override var isHighlighted: Bool {
        didSet { updateInteractionState() }
    }

    override var isEnabled: Bool {
        didSet { updateInteractionState() }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyMask()
    }

    private func updateInteractionState() {
        UIView.animate(withDuration: 0.12) {
            self.alpha = self.isEnabled ? (self.isHighlighted ? 0.78 : 1) : 0.45
            self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }

    private func applyMask() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        let path = UIBezierPath.jamoHomeRoundedPath(in: bounds, radii: cornerRadii)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}


private extension UIBezierPath {
    static func jamoHomeRoundedPath(in rect: CGRect, radii: JamoHomeCornerRadii) -> UIBezierPath {
        let path = UIBezierPath()
        let tl = min(radii.topLeft, min(rect.width, rect.height) / 2)
        let tr = min(radii.topRight, min(rect.width, rect.height) / 2)
        let br = min(radii.bottomRight, min(rect.width, rect.height) / 2)
        let bl = min(radii.bottomLeft, min(rect.width, rect.height) / 2)

        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        if tr > 0 {
            path.addArc(
                withCenter: CGPoint(x: rect.maxX - tr, y: rect.minY + tr),
                radius: tr,
                startAngle: -.pi / 2,
                endAngle: 0,
                clockwise: true
            )
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        if br > 0 {
            path.addArc(
                withCenter: CGPoint(x: rect.maxX - br, y: rect.maxY - br),
                radius: br,
                startAngle: 0,
                endAngle: .pi / 2,
                clockwise: true
            )
        }
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        if bl > 0 {
            path.addArc(
                withCenter: CGPoint(x: rect.minX + bl, y: rect.maxY - bl),
                radius: bl,
                startAngle: .pi / 2,
                endAngle: .pi,
                clockwise: true
            )
        }
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        if tl > 0 {
            path.addArc(
                withCenter: CGPoint(x: rect.minX + tl, y: rect.minY + tl),
                radius: tl,
                startAngle: .pi,
                endAngle: -.pi / 2,
                clockwise: true
            )
        }
        path.close()
        return path
    }
}

import UIKit

final class JamoRiffDraftVaultViewController: UIViewController {
    private enum Layout {
        static let side: CGFloat = 20
        static let cardRadius: CGFloat = 18
        static let filterHeight: CGFloat = 38
    }

    private let viewModel: JamoRiffDraftVaultViewModel
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let filterStack = UIStackView()
    private let cardStack = UIStackView()
    private let emptyView = UIView()
    private var snapshot: JamoRiffDraftVaultSnapshot?
    var onContinueDraft: ((JamoRiffDraftVaultItem) -> Void)?
    var onStartCoCreate: (() -> Void)?

    init(viewModel: JamoRiffDraftVaultViewModel = JamoRiffDraftVaultViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = JamoRiffTheme.background
        buildLayout()
        apply(viewModel.seedPreviewDraftIfNeeded())
    }

    private func buildLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        let back = makeBackButton()
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = JamoRiffStringCipher.restore("Dxrxaxfxtx xVxaxuxlxtx")
        title.font = JamoRiffTheme.titleFont(24)
        title.textColor = JamoRiffTheme.ink
        title.textAlignment = .center

        filterStack.translatesAutoresizingMaskIntoConstraints = false
        filterStack.axis = .horizontal
        filterStack.spacing = 8
        filterStack.distribution = .fill

        cardStack.translatesAutoresizingMaskIntoConstraints = false
        cardStack.axis = .vertical
        cardStack.spacing = 16

        contentView.addSubview(back)
        contentView.addSubview(title)
        contentView.addSubview(filterStack)
        contentView.addSubview(cardStack)

        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.side),
            back.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            back.widthAnchor.constraint(equalToConstant: 48),
            back.heightAnchor.constraint(equalToConstant: 48),
            title.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            title.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            title.leadingAnchor.constraint(greaterThanOrEqualTo: back.trailingAnchor, constant: 12),
            filterStack.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 22),
            filterStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.side),
            filterStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -Layout.side),
            filterStack.heightAnchor.constraint(equalToConstant: Layout.filterHeight),
            cardStack.topAnchor.constraint(equalTo: filterStack.bottomAnchor, constant: 20),
            cardStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.side),
            cardStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.side),
            cardStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
        ])
    }

    private func apply(_ snapshot: JamoRiffDraftVaultSnapshot) {
        self.snapshot = snapshot
        filterStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        snapshot.sections.forEach { filterStack.addArrangedSubview(makeFilterButton(section: $0, selected: $0 == snapshot.selectedSection)) }
        cardStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        switch snapshot.state {
        case .loaded:
            snapshot.cards.forEach { cardStack.addArrangedSubview(makeDraftCard($0)) }
        case .empty:
            cardStack.addArrangedSubview(makeEmptyView())
        }
    }

    private func makeBackButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor
        button.setTitle("‹", for: .normal)
        button.setTitleColor(JamoRiffTheme.ink, for: .normal)
        button.titleLabel?.font = JamoRiffTheme.titleFont(30)
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }

    private func makeFilterButton(section: JamoRiffDraftVaultSection, selected: Bool) -> UIButton {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        var title = AttributedString(section.title)
        title.font = JamoRiffTheme.bodyFont(12.5, weight: .heavy)
        title.foregroundColor = selected ? JamoRiffTheme.yellow : JamoRiffTheme.muted
        config.attributedTitle = title
        config.baseForegroundColor = selected ? JamoRiffTheme.yellow : JamoRiffTheme.muted
        config.background.backgroundColor = selected ? JamoRiffTheme.ink : .white
        config.background.cornerRadius = 19
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14)
        button.configuration = config
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 19
        button.layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor
        button.addAction(UIAction { [weak self] _ in
            self?.apply(self?.viewModel.select(section) ?? JamoRiffDraftVaultSnapshot(state: .empty, selectedSection: section, sections: JamoRiffDraftVaultSection.allCases, cards: []))
        }, for: .touchUpInside)
        return button
    }

    private func makeDraftCard(_ card: JamoRiffDraftVaultCard) -> UIView {
        let wrapper = UIControl()
        wrapper.backgroundColor = .white
        wrapper.layer.cornerRadius = Layout.cardRadius
        wrapper.layer.borderWidth = 1
        wrapper.layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.heightAnchor.constraint(greaterThanOrEqualToConstant: 146).isActive = true
        wrapper.addAction(UIAction { [weak self] _ in self?.continueDraft(card.id) }, for: .touchUpInside)

        let cover = UIImageView()
        cover.translatesAutoresizingMaskIntoConstraints = false
        cover.image = UIImage.jamoCoCreateMedia(named: card.coverImageName) ?? UIImage(named: "AppIcon")
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true
        cover.layer.cornerRadius = 14

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = card.title
        title.textColor = JamoRiffTheme.ink
        title.font = JamoRiffTheme.bodyFont(16, weight: .heavy)
        title.numberOfLines = 2

        let badge = UILabel()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.text = card.badge
        badge.textColor = JamoRiffTheme.orange
        badge.font = JamoRiffTheme.bodyFont(11, weight: .heavy)
        badge.backgroundColor = JamoRiffTheme.orange.withAlphaComponent(0.12)
        badge.layer.cornerRadius = 10
        badge.clipsToBounds = true
        badge.textAlignment = .center

        let waveform = JamoRiffDraftWaveformView()
        waveform.translatesAutoresizingMaskIntoConstraints = false
        waveform.seed = card.waveformSeed
        waveform.activeTint = JamoRiffTheme.orange

        let saved = UILabel()
        saved.translatesAutoresizingMaskIntoConstraints = false
        saved.text = card.savedText
        saved.textColor = JamoRiffTheme.muted
        saved.font = JamoRiffTheme.bodyFont(12, weight: .medium)

        let more = UIButton(type: .system)
        more.translatesAutoresizingMaskIntoConstraints = false
        more.setTitle("•••", for: .normal)
        more.setTitleColor(JamoRiffTheme.muted, for: .normal)
        more.titleLabel?.font = JamoRiffTheme.bodyFont(20, weight: .heavy)
        more.addAction(UIAction { [weak self] _ in self?.showDraftMenu(card.id) }, for: .touchUpInside)

        let tags = UILabel()
        tags.translatesAutoresizingMaskIntoConstraints = false
        tags.text = card.tags.prefix(2).joined(separator: "  ")
        tags.textColor = JamoRiffTheme.pink
        tags.font = JamoRiffTheme.bodyFont(11.5, weight: .heavy)

        let continueButton = UIButton(type: .system)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle(JamoRiffStringCipher.restore("Cxoxnxtxixnxuxe"), for: .normal)
        continueButton.setTitleColor(JamoRiffTheme.yellow, for: .normal)
        continueButton.titleLabel?.font = JamoRiffTheme.bodyFont(13, weight: .heavy)
        continueButton.backgroundColor = JamoRiffTheme.orange
        continueButton.layer.cornerRadius = 18
        continueButton.addAction(UIAction { [weak self] _ in self?.continueDraft(card.id) }, for: .touchUpInside)

        wrapper.addSubview(cover)
        wrapper.addSubview(title)
        wrapper.addSubview(badge)
        wrapper.addSubview(waveform)
        wrapper.addSubview(saved)
        wrapper.addSubview(more)
        wrapper.addSubview(tags)
        wrapper.addSubview(continueButton)

        NSLayoutConstraint.activate([
            cover.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 14),
            cover.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 14),
            cover.widthAnchor.constraint(equalToConstant: 94),
            cover.heightAnchor.constraint(equalToConstant: 94),
            title.leadingAnchor.constraint(equalTo: cover.trailingAnchor, constant: 14),
            title.topAnchor.constraint(equalTo: cover.topAnchor, constant: 2),
            title.trailingAnchor.constraint(equalTo: more.leadingAnchor, constant: -6),
            more.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -10),
            more.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            more.widthAnchor.constraint(equalToConstant: 34),
            more.heightAnchor.constraint(equalToConstant: 34),
            badge.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            badge.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 86),
            badge.heightAnchor.constraint(equalToConstant: 22),
            tags.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            tags.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 8),
            tags.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -14),
            waveform.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            waveform.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -14),
            waveform.topAnchor.constraint(equalTo: tags.bottomAnchor, constant: 8),
            waveform.heightAnchor.constraint(equalToConstant: 24),
            saved.leadingAnchor.constraint(equalTo: cover.leadingAnchor),
            saved.topAnchor.constraint(equalTo: cover.bottomAnchor, constant: 14),
            continueButton.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -14),
            continueButton.centerYAnchor.constraint(equalTo: saved.centerYAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 112),
            continueButton.heightAnchor.constraint(equalToConstant: 36),
            continueButton.bottomAnchor.constraint(lessThanOrEqualTo: wrapper.bottomAnchor, constant: -14)
        ])
        return wrapper
    }

    private func makeEmptyView() -> UIView {
        emptyView.subviews.forEach { $0.removeFromSuperview() }
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.backgroundColor = .white
        emptyView.layer.cornerRadius = 22
        emptyView.layer.borderWidth = 1
        emptyView.layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor
        emptyView.heightAnchor.constraint(equalToConstant: 320).isActive = true

        let icon = UIImageView(image: UIImage(named: "jamo_cocreate_empty_link_icon"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = JamoRiffStringCipher.restore("Nxox xdxrxaxfxtxsx xyxextx")
        title.textColor = JamoRiffTheme.ink
        title.font = JamoRiffTheme.titleFont(19)

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = JamoRiffStringCipher.restore("Sxtxaxrxtx xax xrxixfxfx xaxnxdx xsxaxvxex xyxoxuxrx xixdxexax xhxexrxex.x")
        subtitle.textColor = JamoRiffTheme.muted
        subtitle.font = JamoRiffTheme.bodyFont(13, weight: .medium)
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 0

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(JamoRiffStringCipher.restore("Sxtxaxrxtx xCxox-xcxrxexaxtxex"), for: .normal)
        button.setTitleColor(JamoRiffTheme.yellow, for: .normal)
        button.titleLabel?.font = JamoRiffTheme.bodyFont(15, weight: .heavy)
        button.backgroundColor = JamoRiffTheme.orange
        button.layer.cornerRadius = 24
        button.addTarget(self, action: #selector(startTapped), for: .touchUpInside)

        emptyView.addSubview(icon)
        emptyView.addSubview(title)
        emptyView.addSubview(subtitle)
        emptyView.addSubview(button)

        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            icon.topAnchor.constraint(equalTo: emptyView.topAnchor, constant: 48),
            icon.widthAnchor.constraint(equalToConstant: 64),
            icon.heightAnchor.constraint(equalToConstant: 64),
            title.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            title.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 24),
            subtitle.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 42),
            subtitle.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -42),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            button.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 42),
            button.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -42),
            button.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 28),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
        return emptyView
    }

    private func continueDraft(_ id: String) {
        guard let draft = viewModel.draft(withID: id) else {
            JamoChordProgressionTrackCue.JamoChordProgressionInfo(JamoChordProgressionPhrase: JamoRiffStringCipher.restore("Nxox xdxrxaxfxtx xsxexlxexcxtxexdx"))
            return
        }
        onContinueDraft?(draft)
    }

    private func showDraftMenu(_ id: String) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: JamoRiffStringCipher.restore("Cxoxnxtxixnxuxe"), style: .default) { [weak self] _ in self?.continueDraft(id) })
        sheet.addAction(UIAlertAction(title: JamoRiffStringCipher.restore("Dxexlxextxex"), style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.apply(self.viewModel.deleteDraft(withID: id))
            JamoChordProgressionTrackCue.JamoChordProgressionInfo(JamoChordProgressionPhrase: JamoRiffStringCipher.restore("Dxrxaxfxtx xdxexlxextxexdx"))
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func startTapped() {
        onStartCoCreate?()
    }
}

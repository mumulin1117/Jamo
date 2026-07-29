import UIKit

final class JamoRiffPartReviewViewController: UIViewController {
    private enum Layout {
        static let side: CGFloat = 20
        static let coverRatio: CGFloat = 0.58
    }

    private let viewModel: JamoRiffPartReviewViewModel
    private let onPublish: ((JamoRiffPartReviewPayload) -> Void)?
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let coverImageView = UIImageView()
    private let playButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let aboutLabel = UILabel()
    private let tagStack = UIStackView()
    private let trackStack = UIStackView()
    private let volumeSlider = UISlider()
    private let volumeValueLabel = UILabel()
    private let validationLabel = UILabel()
    private let publishButton = UIButton(type: .system)
    private let editButton = UIButton(type: .system)

    init(payload: JamoRiffPartReviewPayload, onPublish: ((JamoRiffPartReviewPayload) -> Void)? = nil) {
        self.viewModel = JamoRiffPartReviewViewModel(payload: payload)
        self.onPublish = onPublish
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
        apply(viewModel.makeSnapshot())
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
        let header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = JamoRiffStringCipher.restore("Pxaxrxtx xRxexvxixexwx")
        header.textColor = JamoRiffTheme.ink
        header.font = JamoRiffTheme.titleFont(24)
        header.textAlignment = .center

        let coverCard = UIView()
        coverCard.translatesAutoresizingMaskIntoConstraints = false
        coverCard.layer.cornerRadius = 24
        coverCard.clipsToBounds = true
        coverCard.backgroundColor = UIColor.black.withAlphaComponent(0.08)

        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true

        let waveform = JamoRiffDraftWaveformView()
        waveform.translatesAutoresizingMaskIntoConstraints = false
        waveform.seed = 7
        waveform.activeTint = UIColor.white
        waveform.idleTint = UIColor.white.withAlphaComponent(0.55)

        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.backgroundColor = JamoRiffTheme.yellow
        playButton.layer.cornerRadius = 31
        playButton.setTitle("▶", for: .normal)
        playButton.setTitleColor(JamoRiffTheme.orange, for: .normal)
        playButton.titleLabel?.font = JamoRiffTheme.bodyFont(24, weight: .heavy)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)

        let duration = UILabel()
        duration.translatesAutoresizingMaskIntoConstraints = false
        duration.textColor = .white
        duration.font = JamoRiffTheme.bodyFont(12, weight: .heavy)
        duration.tag = 818

        coverCard.addSubview(coverImageView)
        coverCard.addSubview(waveform)
        coverCard.addSubview(playButton)
        coverCard.addSubview(duration)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = JamoRiffTheme.titleFont(24)
        titleLabel.textColor = JamoRiffTheme.ink
        titleLabel.numberOfLines = 2

        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutLabel.font = JamoRiffTheme.bodyFont(14, weight: .medium)
        aboutLabel.textColor = JamoRiffTheme.muted
        aboutLabel.numberOfLines = 0

        tagStack.translatesAutoresizingMaskIntoConstraints = false
        tagStack.axis = .horizontal
        tagStack.spacing = 8
        tagStack.alignment = .leading

        let mixTitle = UILabel()
        mixTitle.translatesAutoresizingMaskIntoConstraints = false
        mixTitle.text = JamoRiffStringCipher.restore("Txrxaxcxkx xMxixxx")
        mixTitle.font = JamoRiffTheme.titleFont(18)
        mixTitle.textColor = JamoRiffTheme.ink

        trackStack.translatesAutoresizingMaskIntoConstraints = false
        trackStack.axis = .vertical
        trackStack.spacing = 12

        let volumeCard = makeVolumeCard()
        let footer = makeFooter()

        contentView.addSubview(back)
        contentView.addSubview(header)
        contentView.addSubview(coverCard)
        contentView.addSubview(titleLabel)
        contentView.addSubview(aboutLabel)
        contentView.addSubview(tagStack)
        contentView.addSubview(mixTitle)
        contentView.addSubview(trackStack)
        contentView.addSubview(volumeCard)
        contentView.addSubview(validationLabel)
        contentView.addSubview(footer)

        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.side),
            back.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            back.widthAnchor.constraint(equalToConstant: 48),
            back.heightAnchor.constraint(equalToConstant: 48),
            header.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            header.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            coverCard.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 22),
            coverCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.side),
            coverCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.side),
            coverCard.heightAnchor.constraint(equalTo: coverCard.widthAnchor, multiplier: Layout.coverRatio),
            coverImageView.topAnchor.constraint(equalTo: coverCard.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: coverCard.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: coverCard.trailingAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: coverCard.bottomAnchor),
            playButton.centerXAnchor.constraint(equalTo: coverCard.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: coverCard.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 62),
            playButton.heightAnchor.constraint(equalToConstant: 62),
            waveform.leadingAnchor.constraint(equalTo: coverCard.leadingAnchor, constant: 18),
            waveform.trailingAnchor.constraint(equalTo: coverCard.trailingAnchor, constant: -58),
            waveform.bottomAnchor.constraint(equalTo: coverCard.bottomAnchor, constant: -18),
            waveform.heightAnchor.constraint(equalToConstant: 42),
            duration.trailingAnchor.constraint(equalTo: coverCard.trailingAnchor, constant: -18),
            duration.centerYAnchor.constraint(equalTo: waveform.centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: coverCard.bottomAnchor, constant: 22),
            titleLabel.leadingAnchor.constraint(equalTo: coverCard.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: coverCard.trailingAnchor),
            aboutLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            aboutLabel.leadingAnchor.constraint(equalTo: coverCard.leadingAnchor),
            aboutLabel.trailingAnchor.constraint(equalTo: coverCard.trailingAnchor),
            tagStack.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 14),
            tagStack.leadingAnchor.constraint(equalTo: coverCard.leadingAnchor),
            tagStack.trailingAnchor.constraint(lessThanOrEqualTo: coverCard.trailingAnchor),
            mixTitle.topAnchor.constraint(equalTo: tagStack.bottomAnchor, constant: 26),
            mixTitle.leadingAnchor.constraint(equalTo: coverCard.leadingAnchor),
            trackStack.topAnchor.constraint(equalTo: mixTitle.bottomAnchor, constant: 12),
            trackStack.leadingAnchor.constraint(equalTo: coverCard.leadingAnchor),
            trackStack.trailingAnchor.constraint(equalTo: coverCard.trailingAnchor),
            volumeCard.topAnchor.constraint(equalTo: trackStack.bottomAnchor, constant: 18),
            volumeCard.leadingAnchor.constraint(equalTo: coverCard.leadingAnchor),
            volumeCard.trailingAnchor.constraint(equalTo: coverCard.trailingAnchor),
            validationLabel.topAnchor.constraint(equalTo: volumeCard.bottomAnchor, constant: 12),
            validationLabel.leadingAnchor.constraint(equalTo: coverCard.leadingAnchor),
            validationLabel.trailingAnchor.constraint(equalTo: coverCard.trailingAnchor),
            footer.topAnchor.constraint(equalTo: validationLabel.bottomAnchor, constant: 18),
            footer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            footer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            footer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            footer.heightAnchor.constraint(equalToConstant: 154)
        ])
    }

    private func apply(_ snapshot: JamoRiffPartReviewSnapshot) {
        coverImageView.image = UIImage.jamoCoCreateMedia(named: snapshot.coverImageName) ?? UIImage(named: "AppIcon")
        titleLabel.text = snapshot.title
        aboutLabel.text = snapshot.about.isEmpty ? JamoRiffStringCipher.restore("Ax xsxoxfxtx xaxcxoxuxsxtxixcx xrxixfxfx xwxaxixtxixnxgx xfxoxrx xax xlxexaxdx xgxuxixtxaxrx xpxaxrxtx.x") : snapshot.about
        tagStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        snapshot.tags.prefix(3).forEach { tagStack.addArrangedSubview(makeTag($0)) }
        trackStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        snapshot.tracks.forEach { trackStack.addArrangedSubview(makeTrackRow($0)) }
        volumeSlider.value = snapshot.volumeLevel
        volumeValueLabel.text = snapshot.volumeText
        validationLabel.text = snapshot.validationText
        validationLabel.isHidden = snapshot.validationText == nil
        publishButton.isEnabled = snapshot.canPublish
        publishButton.alpha = snapshot.canPublish ? 1 : 0.45
        publishButton.setTitle(snapshot.state == .publishing ? JamoRiffStringCipher.restore("Pxuxbxlxixsxhxixnxgx.x.x.x") : JamoRiffStringCipher.restore("Pxuxbxlxixsxhx"), for: .normal)
        playButton.setTitle(snapshot.isPlaying ? "Ⅱ" : "▶", for: .normal)
        contentView.viewWithTag(818).flatMap { $0 as? UILabel }?.text = snapshot.totalDurationText
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

    private func makeTag(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = "  \(text)  "
        label.textColor = JamoRiffTheme.pink
        label.font = JamoRiffTheme.bodyFont(12, weight: .heavy)
        label.backgroundColor = JamoRiffTheme.pink.withAlphaComponent(0.14)
        label.layer.cornerRadius = 13
        label.clipsToBounds = true
        label.heightAnchor.constraint(equalToConstant: 26).isActive = true
        return label
    }

    private func makeTrackRow(_ track: JamoRiffPartReviewTrackDisplay) -> UIView {
        let row = UIControl()
        row.backgroundColor = track.isMine ? JamoRiffTheme.pink.withAlphaComponent(0.2) : .white
        row.layer.cornerRadius = 16
        row.layer.borderWidth = 1
        row.layer.borderColor = (track.isMine ? JamoRiffTheme.pink.withAlphaComponent(0.35) : UIColor.black.withAlphaComponent(0.07)).cgColor
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 68).isActive = true
        row.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.apply(self.viewModel.togglePlayback(trackID: track.id))
        }, for: .touchUpInside)

        let button = UILabel()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.text = "▶"
        button.textAlignment = .center
        button.textColor = track.isMine ? JamoRiffTheme.pink : JamoRiffTheme.yellow
        button.font = JamoRiffTheme.bodyFont(12, weight: .heavy)
        button.backgroundColor = track.isMine ? .white : JamoRiffTheme.ink
        button.layer.cornerRadius = 16
        button.clipsToBounds = true

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = track.title
        title.textColor = JamoRiffTheme.ink
        title.font = JamoRiffTheme.bodyFont(13, weight: .heavy)

        let badge = UILabel()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.text = track.isMine ? JamoRiffStringCipher.restore("MxYx xPxAxRxTx") : track.subtitle
        badge.textColor = track.isMine ? JamoRiffTheme.pink : JamoRiffTheme.muted
        badge.font = JamoRiffTheme.bodyFont(10.5, weight: .heavy)

        let waveform = JamoRiffDraftWaveformView()
        waveform.translatesAutoresizingMaskIntoConstraints = false
        waveform.seed = track.waveformSeed
        waveform.activeTint = track.isMine ? JamoRiffTheme.pink : UIColor(red: 208 / 255, green: 203 / 255, blue: 194 / 255, alpha: 1)
        waveform.idleTint = track.isMine ? JamoRiffTheme.orange.withAlphaComponent(0.32) : UIColor.black.withAlphaComponent(0.08)

        let duration = UILabel()
        duration.translatesAutoresizingMaskIntoConstraints = false
        duration.text = track.volumeText ?? track.durationText
        duration.textColor = JamoRiffTheme.muted
        duration.font = JamoRiffTheme.bodyFont(10.5, weight: .medium)

        row.addSubview(button)
        row.addSubview(title)
        row.addSubview(badge)
        row.addSubview(waveform)
        row.addSubview(duration)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 12),
            button.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 32),
            button.heightAnchor.constraint(equalToConstant: 32),
            title.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 12),
            title.topAnchor.constraint(equalTo: row.topAnchor, constant: 12),
            badge.leadingAnchor.constraint(equalTo: title.trailingAnchor, constant: 8),
            badge.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            badge.trailingAnchor.constraint(lessThanOrEqualTo: duration.leadingAnchor, constant: -8),
            waveform.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            waveform.trailingAnchor.constraint(equalTo: duration.leadingAnchor, constant: -10),
            waveform.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            waveform.heightAnchor.constraint(equalToConstant: 22),
            duration.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -12),
            duration.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        return row
    }

    private func makeVolumeCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 18
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor
        card.heightAnchor.constraint(equalToConstant: 88).isActive = true

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = JamoRiffStringCipher.restore("Vxoxlxuxmxex")
        title.textColor = JamoRiffTheme.ink
        title.font = JamoRiffTheme.bodyFont(14, weight: .heavy)

        volumeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        volumeValueLabel.textColor = JamoRiffTheme.orange
        volumeValueLabel.font = JamoRiffTheme.bodyFont(13, weight: .heavy)

        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        volumeSlider.minimumValue = 0.2
        volumeSlider.maximumValue = 1
        volumeSlider.tintColor = JamoRiffTheme.orange
        volumeSlider.addTarget(self, action: #selector(volumeChanged), for: .valueChanged)

        let reset = UIButton(type: .system)
        reset.translatesAutoresizingMaskIntoConstraints = false
        reset.setTitle(JamoRiffStringCipher.restore("Rxexsxextx"), for: .normal)
        reset.setTitleColor(JamoRiffTheme.muted, for: .normal)
        reset.titleLabel?.font = JamoRiffTheme.bodyFont(12, weight: .heavy)
        reset.addTarget(self, action: #selector(resetVolumeTapped), for: .touchUpInside)

        card.addSubview(title)
        card.addSubview(volumeValueLabel)
        card.addSubview(volumeSlider)
        card.addSubview(reset)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            volumeValueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            volumeValueLabel.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            volumeSlider.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            volumeSlider.trailingAnchor.constraint(equalTo: reset.leadingAnchor, constant: -10),
            volumeSlider.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 14),
            reset.trailingAnchor.constraint(equalTo: volumeValueLabel.trailingAnchor),
            reset.centerYAnchor.constraint(equalTo: volumeSlider.centerYAnchor),
            reset.widthAnchor.constraint(equalToConstant: 54)
        ])
        return card
    }

    private func makeFooter() -> UIView {
        let footer = UIView()
        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.backgroundColor = JamoRiffTheme.background

        validationLabel.translatesAutoresizingMaskIntoConstraints = false
        validationLabel.textColor = JamoRiffTheme.orange
        validationLabel.font = JamoRiffTheme.bodyFont(12.5, weight: .heavy)
        validationLabel.numberOfLines = 0

        publishButton.translatesAutoresizingMaskIntoConstraints = false
        publishButton.setTitleColor(JamoRiffTheme.yellow, for: .normal)
        publishButton.titleLabel?.font = JamoRiffTheme.bodyFont(17, weight: .heavy)
        publishButton.backgroundColor = JamoRiffTheme.orange
        publishButton.layer.cornerRadius = 26
        publishButton.addTarget(self, action: #selector(publishTapped), for: .touchUpInside)

        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setTitle(JamoRiffStringCipher.restore("Bxaxcxkx xtxox xExdxixtx"), for: .normal)
        editButton.setTitleColor(JamoRiffTheme.ink, for: .normal)
        editButton.titleLabel?.font = JamoRiffTheme.bodyFont(15, weight: .heavy)
        editButton.backgroundColor = .white
        editButton.layer.cornerRadius = 24
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor
        editButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        footer.addSubview(publishButton)
        footer.addSubview(editButton)
        NSLayoutConstraint.activate([
            publishButton.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: Layout.side),
            publishButton.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -Layout.side),
            publishButton.topAnchor.constraint(equalTo: footer.topAnchor, constant: 18),
            publishButton.heightAnchor.constraint(equalToConstant: 54),
            editButton.leadingAnchor.constraint(equalTo: publishButton.leadingAnchor),
            editButton.trailingAnchor.constraint(equalTo: publishButton.trailingAnchor),
            editButton.topAnchor.constraint(equalTo: publishButton.bottomAnchor, constant: 12),
            editButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        return footer
    }

    @objc private func playTapped() {
        apply(viewModel.togglePlayback())
    }

    @objc private func volumeChanged() {
        apply(viewModel.updateVolume(volumeSlider.value))
    }

    @objc private func resetVolumeTapped() {
        apply(viewModel.resetVolume())
    }

    @objc private func publishTapped() {
        let snapshot = viewModel.beginPublishing()
        apply(snapshot)
        guard snapshot.state == .publishing else { return }
        onPublish?(viewModel.currentPayload())
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

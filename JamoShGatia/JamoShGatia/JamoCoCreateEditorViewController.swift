import AVFoundation
import UniformTypeIdentifiers
import UIKit

final class JamoCoCreateEditorViewController: JamoRiffBaseStageViewController {
    private enum EditorLayout {
        static let maxContentWidth: CGFloat = 390
        static let previewRatio: CGFloat = 0.52
        static let cardRadius: CGFloat = 18
        static let compactButtonHeight: CGFloat = 44
        static let sourceButtonHeight: CGFloat = 40
        static let primaryButtonHeight: CGFloat = 52
    }

    private let viewModel: JamoCoCreateEditorViewModel
    private var snapshot: JamoCoCreateEditorSnapshot?
    private var recordingStartDate: Date?
    private var recordingTimer: Timer?
    private weak var recordingElapsedLabel: UILabel?
    private let saveButton = UIButton(type: .custom)
    private let saveActivity = UIActivityIndicatorView(style: .medium)
    private var isCompletingSave = false
    private var microphonePromptView: JamoCoCreateEditorMicrophonePromptView?
    private var hasMicrophonePermission = false
    private var sourceAudioPlayer: AVAudioPlayer?
    private var sourcePlaybackTimer: Timer?
    private var sourcePreviewMP3FileName: String?
    private var isSourcePreviewPlaying = false
    private weak var sourcePreviewButton: UIButton?
    private weak var sourcePreviewDurationLabel: UILabel?
    private var clipPreviewPlayer: AVAudioPlayer?
    private var clipPreviewTimer: Timer?
    private var isClipPreviewPlaying = false
    private var audioRecorder: AVAudioRecorder?
    private var activeRecordingURL: URL?
    private var clipPreviewVolume: Float = 1
    private var volumeBeforeSheet: Float = 1
    private weak var volumeSheetView: JamoCoCreateEditorVolumeSheet?
    private var trackAudioPlayer: AVAudioPlayer?
    private var trackPlaybackTimer: Timer?
    private var activeTrackPlaybackID: String?
    private var activeTrackMP3FileName: String?
    private var isTrackPlaying = false
    private var trackPlayButtons: [String: UIButton] = [:]
    private var trackDurationLabels: [String: UILabel] = [:]
    private var trackDurationFallbacks: [String: String] = [:]

    init(work: JamoCoCreateWork, selectedJoinMethod: JamoCoCreateJoinMethod) {
        self.viewModel = JamoCoCreateEditorViewModel(work: work, selectedJoinMethod: selectedJoinMethod)
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    init(workID: String, selectedJoinMethod: JamoCoCreateJoinMethod) {
        self.viewModel = JamoCoCreateEditorViewModel(workID: workID, selectedJoinMethod: selectedJoinMethod)
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iGn7i7tD(dc6opdmeirY:o)o thzaDsg JnyootF ZbaeheSnV Xitm8pSlUeZmmewnWtZeLdU"))
    }

    deinit {
        discardActiveRecording(removeFile: false)
        stopSourcePreviewPlayback(resetProgress: true)
        stopClipPreviewPlayback(resetProgress: true)
        stopTrackPlayback(resetProgress: true)
        stopRecordingTimer()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = nil
        view.backgroundColor = JamoRiffTheme.background
        contentStack.spacing = 14
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        configureSaveButton()
        render(viewModel.prepareEditor())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        discardActiveRecording(removeFile: false)
        stopRecordingTimer()
        stopSourcePreviewPlayback(resetProgress: true)
        stopClipPreviewPlayback(resetProgress: true)
        stopTrackPlayback(resetProgress: true)
    }

    private func configureSaveButton() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.layer.cornerRadius = EditorLayout.primaryButtonHeight / 2
        saveButton.layer.cornerCurve = .continuous
        saveButton.titleLabel?.font = JamoRiffTheme.bodyFont(15.5, weight: .heavy)
        saveButton.addTarget(self, action: #selector(saveNextTapped), for: .touchUpInside)
        saveButton.heightAnchor.constraint(equalToConstant: EditorLayout.primaryButtonHeight).isActive = true

        saveActivity.translatesAutoresizingMaskIntoConstraints = false
        saveActivity.hidesWhenStopped = true
        saveActivity.color = JamoRiffTheme.muted
        saveButton.addSubview(saveActivity)
        NSLayoutConstraint.activate([
            saveActivity.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
            saveActivity.centerXAnchor.constraint(equalTo: saveButton.centerXAnchor, constant: -64)
        ])
    }

    private func render(_ snapshot: JamoCoCreateEditorSnapshot) {
        self.snapshot = snapshot
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        recordingElapsedLabel = nil
        trackPlayButtons.removeAll()
        trackDurationLabels.removeAll()
        trackDurationFallbacks.removeAll()

        contentStack.addArrangedSubview(centered(makeTopBar()))
        contentStack.addArrangedSubview(centered(makePreviewCard(snapshot)))
        contentStack.addArrangedSubview(centered(makeTracksSection(snapshot)))
        contentStack.addArrangedSubview(centered(saveButton))
        applySaveButton(snapshot)
        updateSourcePreviewPlaybackViews()
        updateTrackPlaybackViews()
        if snapshot.state == .recording {
            updateRecordingElapsed()
        }
    }

    private var isSavingInProgress: Bool {
        isCompletingSave || snapshot?.state == .saving
    }

    private func centered(_ view: UIView) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            view.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor),
            view.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
            view.widthAnchor.constraint(equalTo: container.widthAnchor).withPriority(.defaultHigh),
            view.widthAnchor.constraint(lessThanOrEqualToConstant: EditorLayout.maxContentWidth)
        ])
        return container
    }

    private func makeTopBar() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let cancelButton = UIButton(type: .custom)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle(JamoRiffStringCipher.restore("CTaWnCcjeUl9"), for: .normal)
        cancelButton.setTitleColor(JamoRiffTheme.ink, for: .normal)
        cancelButton.titleLabel?.font = JamoRiffTheme.bodyFont(12.5, weight: .medium)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = JamoRiffStringCipher.restore("Cfot-scar9eMa0tNee qEVdZi7tBoFrl")
        titleLabel.textColor = JamoRiffTheme.ink
        titleLabel.font = JamoRiffTheme.titleFont(14.5)
        titleLabel.textAlignment = .center

        container.addSubview(cancelButton)
        container.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 44),
            cancelButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            cancelButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            cancelButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 58),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: cancelButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -58)
        ])
        return container
    }

    private func makePreviewCard(_ snapshot: JamoCoCreateEditorSnapshot) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.black.withAlphaComponent(0.08)
        card.layer.cornerRadius = EditorLayout.cardRadius
        card.layer.cornerCurve = .continuous
        card.clipsToBounds = true

        let coverName = snapshot.source?.coverImageName ?? JamoRiffStringCipher.restore("jHa9mjoD_vcLomcUrkeuaKtQey_IpJuabXlEiAsWhE_5wPoMrFkq_PcpoOvGeYr4")
        let coverImage = JamoCoCreateEditorImageLoader.image(named: coverName) ?? UIImage(named: "jamo_cocreate_publish_work_cover")
        let imageView = UIImageView(image: coverImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        let tagPill = makePreviewPill(text: JamoRiffStringCipher.restore("PAr5eNvpiBe4wg f·9 3sHtcaVcIkseLdF emuiYx3"))
        let playButton = UIButton(type: .custom)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.backgroundColor = JamoRiffTheme.yellow
        playButton.layer.cornerRadius = 21
        playButton.layer.cornerCurve = .continuous
        playButton.setImage(UIImage(named: isSourcePreviewPlaying ? "jamo_cocreate_detail_pause" : "jamo_cocreate_detail_play"), for: .normal)
        playButton.isEnabled = snapshot.state != .recording
        playButton.alpha = playButton.isEnabled ? 1 : 0.42
        playButton.addTarget(self, action: #selector(sourcePreviewTapped), for: .touchUpInside)
        sourcePreviewButton = playButton

        let waveform = UIImageView(image: UIImage(named: "jamo_cocreate_detail_waveform"))
        waveform.translatesAutoresizingMaskIntoConstraints = false
        waveform.contentMode = .scaleAspectFill
        waveform.alpha = 0.95
        waveform.clipsToBounds = true

        let durationLabel = UILabel()
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.text = snapshot.source?.parts.first?.durationText ?? JamoRiffStringCipher.restore("0Z:m4a26")
        durationLabel.textColor = .white
        durationLabel.font = JamoRiffTheme.bodyFont(10.5, weight: .heavy)
        sourcePreviewDurationLabel = durationLabel

        card.addSubview(imageView)
        card.addSubview(tagPill)
        card.addSubview(playButton)
        card.addSubview(waveform)
        card.addSubview(durationLabel)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalTo: card.widthAnchor, multiplier: EditorLayout.previewRatio),
            imageView.topAnchor.constraint(equalTo: card.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            tagPill.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            tagPill.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            playButton.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            playButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            playButton.widthAnchor.constraint(equalToConstant: 42),
            playButton.heightAnchor.constraint(equalTo: playButton.widthAnchor),
            waveform.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            waveform.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -8),
            waveform.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            waveform.heightAnchor.constraint(equalToConstant: 34),
            durationLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            durationLabel.centerYAnchor.constraint(equalTo: waveform.centerYAnchor)
        ])
        return card
    }

    private func makePreviewPill(text: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.black.withAlphaComponent(0.44)
        container.layer.cornerRadius = 14
        container.layer.cornerCurve = .continuous

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = .white
        label.font = JamoRiffTheme.bodyFont(10.5, weight: .heavy)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 28),
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
        ])
        return container
    }

    private func makeTracksSection(_ snapshot: JamoCoCreateEditorSnapshot) -> UIView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10

        let titleLabel = UILabel()
        titleLabel.text = JamoRiffStringCipher.restore("TLrcaDc2kDsY")
        titleLabel.textColor = JamoRiffTheme.ink
        titleLabel.font = JamoRiffTheme.bodyFont(13, weight: .heavy)
        stack.addArrangedSubview(titleLabel)

        let originalPart = snapshot.source?.parts.first(where: { $0.title.localizedCaseInsensitiveContains(JamoRiffStringCipher.restore("OXrSiOg2i8neaUlc")) }) ?? snapshot.source?.parts.first
        stack.addArrangedSubview(makeTrackCard(
            id: originalPart?.id ?? JamoRiffStringCipher.restore("jAajmhoZ_2e0dyi2t4ovrU_gsIo6u2rkceen_doSrEiegYihnzatl4"),
            title: originalPart?.title ?? JamoRiffStringCipher.restore("OQroisgfi0n0aFl7 eGIuJivtdaprh"),
            subtitle: originalPart?.subtitle ?? snapshot.source?.title ?? JamoRiffStringCipher.restore("Waa8rGmC DS3ubnDsQeBtc GRWivfXfD"),
            mp3FileName: originalPart?.mp3FileName ?? primarySourceMP3FileName(),
            durationText: originalPart?.durationText ?? JamoRiffStringCipher.restore("0S:B4S2f"),
            waveformSeed: originalPart?.waveformSeed ?? 3,
            style: .regular
        ))
        stack.addArrangedSubview(makeMyGuitarCard(snapshot))
        return stack
    }

    private func makeMyGuitarCard(_ snapshot: JamoCoCreateEditorSnapshot) -> UIView {
        switch snapshot.state {
        case .recording:
            return makeRecordingCard(snapshot)
        case .clipReady, .saving:
            return makeClipReadyCard(snapshot)
        case .clipTooShort:
            return makeClipTooShortCard(snapshot)
        case .microphonePermission:
            return makeMicrophoneCard(snapshot)
        case .selectedMethod, .empty:
            return makeEmptyMyPartCard(snapshot)
        }
    }

    private func makeTrackCard(
        id: String,
        title: String,
        subtitle: String?,
        mp3FileName: String?,
        durationText: String,
        waveformSeed: Int,
        style: JamoCoCreatePartDisplay.Style
    ) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 15
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.black.withAlphaComponent(style == .mine ? 0.08 : 0.07).cgColor
        card.backgroundColor = style == .mine ? UIColor(red: 255 / 255, green: 228 / 255, blue: 241 / 255, alpha: 1) : .white

        let playButton = JamoCoCreateEditorTrackPlayButton(trackID: id, mp3FileName: mp3FileName)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.imageView?.contentMode = .scaleAspectFit
        playButton.setImage(UIImage(named: "jamo_cocreate_part_play"), for: .normal)
        playButton.adjustsImageWhenHighlighted = false
        playButton.accessibilityLabel = JamoRiffStringCipher.restore("Pzl3afy7 L") + title
        let hasPlayableAudio = (mp3FileName ?? "").isEmpty == false && snapshot?.state != .recording
        playButton.isEnabled = hasPlayableAudio
        playButton.alpha = hasPlayableAudio ? 1 : 0.42
        playButton.addTarget(self, action: #selector(trackPlayTapped(_:)), for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textColor = JamoRiffTheme.ink
        titleLabel.font = JamoRiffTheme.bodyFont(12.5, weight: .heavy)
        titleLabel.numberOfLines = 1

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = JamoRiffTheme.muted
        subtitleLabel.font = JamoRiffTheme.bodyFont(10, weight: .medium)
        subtitleLabel.numberOfLines = 1
        subtitleLabel.isHidden = (subtitle ?? "").isEmpty

        let waveform = JamoCoCreateEditorWaveformView()
        waveform.translatesAutoresizingMaskIntoConstraints = false
        waveform.seed = waveformSeed
        waveform.barColor = style == .mine ? JamoRiffTheme.pink : UIColor(red: 225 / 255, green: 221 / 255, blue: 213 / 255, alpha: 1)
        waveform.secondaryBarColor = style == .mine ? UIColor(red: 241 / 255, green: 100 / 255, blue: 148 / 255, alpha: 1) : UIColor(red: 208 / 255, green: 202 / 255, blue: 193 / 255, alpha: 1)

        let durationLabel = UILabel()
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.text = currentTrackDurationText(id: id, mp3FileName: mp3FileName, fallback: durationText)
        durationLabel.textColor = UIColor.black.withAlphaComponent(0.36)
        durationLabel.font = JamoRiffTheme.bodyFont(10, weight: .medium)

        trackPlayButtons[id] = playButton
        trackDurationLabels[id] = durationLabel
        trackDurationFallbacks[id] = durationText

        card.addSubview(playButton)
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)
        card.addSubview(waveform)
        card.addSubview(durationLabel)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 66),
            playButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            playButton.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 34),
            playButton.heightAnchor.constraint(equalTo: playButton.widthAnchor),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: durationLabel.leadingAnchor, constant: -8),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            waveform.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 5),
            waveform.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            waveform.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -48),
            waveform.heightAnchor.constraint(equalToConstant: 18),
            waveform.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -10),
            durationLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            durationLabel.centerYAnchor.constraint(equalTo: waveform.centerYAnchor)
        ])
        return card
    }

    private func makeEmptyMyPartCard(_ snapshot: JamoCoCreateEditorSnapshot) -> UIView {
        let card = baseMyGuitarContainer()

        let header = makeMyGuitarHeader(title: JamoRiffStringCipher.restore("MTyC eGZuOiStkaSrX"), subtitle: JamoRiffStringCipher.restore("A1dvdP es9owmpeftFh6ihnhgT LyeoIu8ry 1phahrBt0"))
        let methodPill = makeSelectedMethodPill(snapshot.selectedMethod.title)
        let buttons = UIStackView(arrangedSubviews: [
            makeSourceButton(title: JamoRiffStringCipher.restore("ReeQcLoorhde"), imageName: "jamo_cocreate_editor_record_button", action: #selector(recordTapped)),
            makeSourceButton(title: JamoRiffStringCipher.restore("Uap8l5oBavdn"), imageName: "jamo_cocreate_editor_upload_button", action: #selector(uploadTapped))
        ])
        buttons.translatesAutoresizingMaskIntoConstraints = false
        buttons.axis = .horizontal
        buttons.spacing = 10
        buttons.distribution = .fillEqually

        let methodLabel = UILabel()
        methodLabel.translatesAutoresizingMaskIntoConstraints = false
        methodLabel.text = snapshot.selectedMethod.subtitle
        methodLabel.textColor = JamoRiffTheme.muted
        methodLabel.font = JamoRiffTheme.bodyFont(10.5, weight: .medium)
        methodLabel.numberOfLines = 0

        let disabledToolbar = makeToolBar(items: [
            (JamoRiffStringCipher.restore("RweJcgo1r5dZ"), JamoRiffStringCipher.restore("jNaQmVoW_ZcxokcerIehaxtxed_AehdtiGtuoOrV_GrqeIcCogrzdl_JtVoTo2lZ"), #selector(recordTapped), false),
            (JamoRiffStringCipher.restore("UGp5lVo6aydq"), JamoRiffStringCipher.restore("jnarmmoM_VcvoQcKr3eNatt5eu_5eQdliKt8oHrl_1uWp2laoUapdJ_ItdowoFl3"), #selector(uploadTapped), false),
            (JamoRiffStringCipher.restore("TdrMi3mZ"), JamoRiffStringCipher.restore("j7almGoE_8cuo1cqryeGajtOe9_CetdEiFtzourq_ltsr2ism7_GtVoUoLlO"), #selector(trimToolTapped), false),
            (JamoRiffStringCipher.restore("VYoWloukm9eD"), JamoRiffStringCipher.restore("jlaPmdoh_ictoEcGrIeqaxtpe2_Eejduittgo4r6_rvvowl8uJm1ex_nttojofl5"), #selector(volumeToolTapped), false),
            (JamoRiffStringCipher.restore("P1rBe4vkiPe5wb"), JamoRiffStringCipher.restore("jgasmIoE_Ycdo6cGrJe3aGtoeB_2eTdwictEoqrU_apJrEefvNikehwX_PtnoYoPlk"), #selector(previewClipTapped), false)
        ])

        card.addSubview(header)
        card.addSubview(methodPill)
        card.addSubview(buttons)
        card.addSubview(methodLabel)
        card.addSubview(disabledToolbar)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            header.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            header.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            methodPill.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
            methodPill.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            methodPill.heightAnchor.constraint(equalToConstant: 28),
            methodPill.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -14),
            buttons.topAnchor.constraint(equalTo: methodPill.bottomAnchor, constant: 12),
            buttons.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            buttons.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            methodLabel.topAnchor.constraint(equalTo: buttons.bottomAnchor, constant: 10),
            methodLabel.leadingAnchor.constraint(equalTo: buttons.leadingAnchor),
            methodLabel.trailingAnchor.constraint(equalTo: buttons.trailingAnchor),
            disabledToolbar.topAnchor.constraint(equalTo: methodLabel.bottomAnchor, constant: 12),
            disabledToolbar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            disabledToolbar.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            disabledToolbar.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        return card
    }

    private func makeSelectedMethodPill(_ title: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 255 / 255, green: 236 / 255, blue: 245 / 255, alpha: 1)
        container.layer.cornerRadius = 14
        container.layer.cornerCurve = .continuous

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textColor = JamoRiffTheme.pink
        label.font = JamoRiffTheme.bodyFont(10.5, weight: .heavy)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
        ])
        return container
    }

    private func makeMicrophoneCard(_ snapshot: JamoCoCreateEditorSnapshot) -> UIView {
        let card = baseMyGuitarContainer()

        let icon = UIImageView(image: UIImage(named: "jamo_cocreate_editor_microphone_access"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = JamoRiffStringCipher.restore("Mdi4csrBoqpchkoXnpev 3A0cIcqexsgsX")
        title.textColor = JamoRiffTheme.ink
        title.font = JamoRiffTheme.bodyFont(14, weight: .heavy)
        title.textAlignment = .center

        let body = UILabel()
        body.translatesAutoresizingMaskIntoConstraints = false
        body.text = snapshot.validationMessage ?? JamoCoCreateEditorViewModel.microphoneMessage
        body.textColor = JamoRiffTheme.muted
        body.font = JamoRiffTheme.bodyFont(11, weight: .medium)
        body.textAlignment = .center
        body.numberOfLines = 0

        let allowButton = makeSolidButton(title: JamoRiffStringCipher.restore("All0l1odwF"), background: JamoRiffTheme.orange, foreground: .white, action: #selector(allowMicrophoneTapped))
        let notNowButton = makeTextButton(title: JamoRiffStringCipher.restore("NQoDty MNeoCwz"), action: #selector(resetTapped))

        card.addSubview(icon)
        card.addSubview(title)
        card.addSubview(body)
        card.addSubview(allowButton)
        card.addSubview(notNowButton)
        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            icon.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 48),
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor),
            title.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 12),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
            body.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            allowButton.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 16),
            allowButton.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            allowButton.widthAnchor.constraint(equalTo: card.widthAnchor, multiplier: 0.7),
            allowButton.heightAnchor.constraint(equalToConstant: EditorLayout.compactButtonHeight),
            notNowButton.topAnchor.constraint(equalTo: allowButton.bottomAnchor, constant: 8),
            notNowButton.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            notNowButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        return card
    }

    private func makeRecordingCard(_ snapshot: JamoCoCreateEditorSnapshot) -> UIView {
        let card = baseMyGuitarContainer()
        card.backgroundColor = .white

        let header = makeMyGuitarHeader(title: snapshot.selectedMethod.trackTitle, subtitle: JamoRiffStringCipher.restore("RYeAcaoNrIdJiKnXgN oyCoHuXrz 6pDa8rQtA"))
        let elapsed = UILabel()
        elapsed.translatesAutoresizingMaskIntoConstraints = false
        elapsed.textColor = JamoRiffTheme.orange
        elapsed.font = JamoRiffTheme.bodyFont(12, weight: .heavy)
        elapsed.textAlignment = .right
        recordingElapsedLabel = elapsed

        let waveform = JamoCoCreateEditorWaveformView()
        waveform.translatesAutoresizingMaskIntoConstraints = false
        waveform.seed = 15
        waveform.barColor = JamoRiffTheme.pink
        waveform.secondaryBarColor = JamoRiffTheme.orange

        let toolbar = makeToolBar(items: [
            (JamoRiffStringCipher.restore("Peafu5s1es"), JamoRiffStringCipher.restore("j5aemdoQ_vcwolchrveMatt7eR_odSeZtHa2iJlh_mpHaRuIszei"), #selector(stopRecordingTapped), true),
            (JamoRiffStringCipher.restore("ClaLnHcReylU"), JamoRiffStringCipher.restore("jsaemIoF_bcuouclr0e5aWtreN_4eCdXiit1oVrI_FciaOnncceelM_Yt2ojoull"), #selector(cancelRecordingTapped), false),
            (JamoRiffStringCipher.restore("Tqr0icmW"), JamoRiffStringCipher.restore("jtaomCoa_KcrofcLrpeMaZtxe1_HexdGiZtEoerM_ytNr4ixm6_Dtdoxoglk"), #selector(trimToolTapped), false),
            (JamoRiffStringCipher.restore("Vhowlpuemue0"), JamoRiffStringCipher.restore("j5aKmjoi_GcPo0ctrOe5aCtveU_KeydEibt3oarv_zvIoklSuAmAeK_qtOoMozlQ"), #selector(volumeToolTapped), false),
            (JamoRiffStringCipher.restore("P5rYeZv9icerwd"), JamoRiffStringCipher.restore("jWaGmro6_4cWoQcbroefa6taeL_QeWd1irtkoZrG_LpOrCeYvGiBeVwE_PtFoToTlB"), #selector(previewClipTapped), false)
        ])

        card.addSubview(header)
        card.addSubview(elapsed)
        card.addSubview(waveform)
        card.addSubview(toolbar)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            header.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            header.trailingAnchor.constraint(lessThanOrEqualTo: elapsed.leadingAnchor, constant: -8),
            elapsed.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            elapsed.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            elapsed.widthAnchor.constraint(equalToConstant: 52),
            waveform.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 14),
            waveform.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            waveform.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            waveform.heightAnchor.constraint(equalToConstant: 36),
            toolbar.topAnchor.constraint(equalTo: waveform.bottomAnchor, constant: 14),
            toolbar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            toolbar.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            toolbar.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        return card
    }

    private func makeClipReadyCard(_ snapshot: JamoCoCreateEditorSnapshot) -> UIView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10

        let clip = snapshot.clip
        stack.addArrangedSubview(makeTrackCard(
            id: clip.map { "jamo_editor_clip_\($0.mp3FileName)" } ?? JamoRiffStringCipher.restore("jTa1m0ot_1eIdWi7tKonrQ_ZcVlMijp9_Ncxu0rTrtehnJtZ"),
            title: clip?.roleName ?? snapshot.selectedMethod.trackTitle,
            subtitle: JamoRiffStringCipher.restore("McyC 2PMajrftm"),
            mp3FileName: clip?.mp3FileName,
            durationText: clip?.durationText ?? JamoRiffStringCipher.restore("07:E1h5x"),
            waveformSeed: clip?.waveformSeed ?? 8,
            style: .mine
        ))

        guard snapshot.state != .saving else {
            return stack
        }

        let toolbar = makeToolBar(items: [
            (JamoRiffStringCipher.restore("RPe7cgoxrzdb"), JamoRiffStringCipher.restore("jqahm1o7_qchoacmrDeUaytGeR_1eXdti3t9oqr4_QrTeTcGoQrLdB_Ht4odoklE"), #selector(recordTapped), false),
            (JamoRiffStringCipher.restore("UHpslDoaadd3"), JamoRiffStringCipher.restore("jWaWmeo2_UcdoKcprAeIautgeL_9ecduiHtEoPrw_hugpHlMohaJdB_VtJoWoOlJ"), #selector(uploadTapped), false),
            (JamoRiffStringCipher.restore("TQrKinmR"), JamoRiffStringCipher.restore("jzabmToT_dc1oyc1rle9actQeu_9eXdkivtwoKrQ_9tMrSihmR_at9oBo5lZ"), #selector(trimToolTapped), true),
            (JamoRiffStringCipher.restore("V4oUlUuKmPer"), JamoRiffStringCipher.restore("jFatm9oR_FcVoqchrCe1aatBeU_ne3dJiRt3oMrF_fvPoOlxuNmFeA_2tjotoAlB"), #selector(volumeToolTapped), true),
            (JamoRiffStringCipher.restore("PIrKezviiBehwX"), JamoRiffStringCipher.restore("jYa7mPoc_RcNoncvrHeda7tgeN_heqdrijtHoPra_6pgrxetvPinehwz_1tpo8orlh"), #selector(previewClipTapped), true)
        ])
        stack.addArrangedSubview(toolbar)
        return stack
    }

    private func makeClipTooShortCard(_ snapshot: JamoCoCreateEditorSnapshot) -> UIView {
        let card = baseMyGuitarContainer()

        let errorIcon = UIImageView(image: UIImage(named: "jamo_cocreate_publish_failure_x"))
        errorIcon.translatesAutoresizingMaskIntoConstraints = false
        errorIcon.contentMode = .scaleAspectFit

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = JamoRiffStringCipher.restore("CAlwihpA Wits6 Yttojom Rsbh3orrjtA")
        title.textColor = JamoRiffTheme.ink
        title.font = JamoRiffTheme.bodyFont(13.5, weight: .heavy)

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = JamoRiffStringCipher.restore("Ptl4eMaUskeQ 5aJdLdw fa0tF LlceTagsXt1 E33 3szeXcaoCnfdosQ.s")
        subtitle.textColor = JamoRiffTheme.muted
        subtitle.font = JamoRiffTheme.bodyFont(11, weight: .medium)
        subtitle.numberOfLines = 0

        let tryAgain = makeSolidButton(title: JamoRiffStringCipher.restore("TqrhyF GAjgHaxirnF"), background: JamoRiffTheme.orange, foreground: .white, action: #selector(resetTapped))

        let errorPanel = UIView()
        errorPanel.translatesAutoresizingMaskIntoConstraints = false
        errorPanel.backgroundColor = UIColor(red: 255 / 255, green: 224 / 255, blue: 232 / 255, alpha: 1)
        errorPanel.layer.cornerRadius = 12
        errorPanel.layer.cornerCurve = .continuous

        card.addSubview(errorPanel)
        errorPanel.addSubview(errorIcon)
        errorPanel.addSubview(title)
        errorPanel.addSubview(subtitle)
        card.addSubview(tryAgain)

        NSLayoutConstraint.activate([
            errorPanel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            errorPanel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            errorPanel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            errorIcon.leadingAnchor.constraint(equalTo: errorPanel.leadingAnchor, constant: 12),
            errorIcon.centerYAnchor.constraint(equalTo: errorPanel.centerYAnchor),
            errorIcon.widthAnchor.constraint(equalToConstant: 32),
            errorIcon.heightAnchor.constraint(equalTo: errorIcon.widthAnchor),
            title.topAnchor.constraint(equalTo: errorPanel.topAnchor, constant: 12),
            title.leadingAnchor.constraint(equalTo: errorIcon.trailingAnchor, constant: 12),
            title.trailingAnchor.constraint(equalTo: errorPanel.trailingAnchor, constant: -12),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 3),
            subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            subtitle.bottomAnchor.constraint(equalTo: errorPanel.bottomAnchor, constant: -12),
            tryAgain.topAnchor.constraint(equalTo: errorPanel.bottomAnchor, constant: 14),
            tryAgain.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            tryAgain.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            tryAgain.heightAnchor.constraint(equalToConstant: EditorLayout.compactButtonHeight),
            tryAgain.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        return card
    }

    private func baseMyGuitarContainer() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor
        return card
    }

    private func makeMyGuitarHeader(title: String, subtitle: String) -> UIView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 2

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = JamoRiffTheme.ink
        titleLabel.font = JamoRiffTheme.bodyFont(13, weight: .heavy)
        titleLabel.numberOfLines = 1

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = JamoRiffTheme.muted
        subtitleLabel.font = JamoRiffTheme.bodyFont(10.5, weight: .medium)
        subtitleLabel.numberOfLines = 0

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        return stack
    }

    private func makeSourceButton(title: String, imageName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        let background = UIImage(named: imageName)?.resizableImage(
            withCapInsets: UIEdgeInsets(top: 18, left: 42, bottom: 18, right: 42),
            resizingMode: .stretch
        )
        button.setBackgroundImage(background, for: .normal)
        button.setBackgroundImage(background, for: .highlighted)
        button.accessibilityLabel = title
        button.adjustsImageWhenHighlighted = false
        button.heightAnchor.constraint(equalToConstant: EditorLayout.sourceButtonHeight).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func makeSolidButton(title: String, background: UIColor, foreground: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(foreground, for: .normal)
        button.titleLabel?.font = JamoRiffTheme.bodyFont(13, weight: .heavy)
        button.backgroundColor = background
        button.layer.cornerRadius = EditorLayout.compactButtonHeight / 2
        button.layer.cornerCurve = .continuous
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func makeTextButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(JamoRiffTheme.muted, for: .normal)
        button.titleLabel?.font = JamoRiffTheme.bodyFont(11, weight: .medium)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func makeToolBar(items: [(title: String, imageName: String, action: Selector, isEnabled: Bool)]) -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        items.forEach {
            stack.addArrangedSubview(
                JamoCoCreateEditorToolButton(
                    title: $0.title,
                    imageName: $0.imageName,
                    target: self,
                    action: $0.action,
                    isEnabled: $0.isEnabled
                )
            )
        }
        return stack
    }

    private func applySaveButton(_ snapshot: JamoCoCreateEditorSnapshot) {
        let action = snapshot.primaryAction
        saveButton.setTitle(action.title, for: .normal)
        saveButton.isEnabled = action.isEnabled && !isCompletingSave
        saveButton.alpha = saveButton.isEnabled ? 1 : 0.92
        switch action.style {
        case .orange:
            saveButton.backgroundColor = JamoRiffTheme.orange
            saveButton.setTitleColor(JamoRiffTheme.yellow, for: .normal)
        case .black:
            saveButton.backgroundColor = JamoRiffTheme.ink
            saveButton.setTitleColor(JamoRiffTheme.pink, for: .normal)
        case .disabled:
            saveButton.backgroundColor = UIColor(red: 239 / 255, green: 237 / 255, blue: 227 / 255, alpha: 1)
            saveButton.setTitleColor(UIColor.black.withAlphaComponent(0.18), for: .normal)
        }
        if snapshot.state == .saving || isCompletingSave {
            saveActivity.startAnimating()
        } else {
            saveActivity.stopAnimating()
        }
    }

    private func toggleSourcePreviewPlayback() {
        if isSourcePreviewPlaying {
            stopSourcePreviewPlayback(resetProgress: false)
            return
        }
        startSourcePreviewPlayback()
    }

    private func startSourcePreviewPlayback() {
        guard let fileName = primarySourceMP3FileName() else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("Nzo0 KseoDuBrlcAeO Hgqu9i7tXaur6 6aSuXdli9oC 6izsd 5a2vpaZiYlCacbulVee.n"))
            return
        }
        stopTrackPlayback(resetProgress: false)
        guard let audioURL = JamoRiffLocalMediaShelf.resourceURL(named: fileName) else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("UUngaVb7lLeN VtUoO pl5oCaWdh CsIoRu5rfcSem fgpu2ictpa8r4 xaBuYdeiAoI.L"))
            return
        }

        do {
            if sourcePreviewMP3FileName != fileName || sourceAudioPlayer == nil {
                stopSourcePreviewPlayback(resetProgress: true)
                sourceAudioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                sourceAudioPlayer?.prepareToPlay()
                sourcePreviewMP3FileName = fileName
            }
            guard let sourceAudioPlayer else {
                JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("UTnRaqbGljeF Ot5oL xpclIatyz jsTo1ugrlcPeP Og4uViktIa3rk RaKujdwi2oZ.J"))
                return
            }
            if sourceAudioPlayer.currentTime >= max(sourceAudioPlayer.duration - 0.2, 0) {
                sourceAudioPlayer.currentTime = 0
            }
            guard sourceAudioPlayer.play() else {
                isSourcePreviewPlaying = false
                updateSourcePreviewPlaybackViews()
                JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("Upnga1b8l2eQ zt4o2 BpLlxagyu gsQoou9rFcOeD Sg6usiZt4aer0 HavuUdkicoF.6"))
                return
            }
            isSourcePreviewPlaying = true
            startSourcePlaybackTimer()
            updateSourcePreviewPlaybackViews()
        } catch {
            isSourcePreviewPlaying = false
            updateSourcePreviewPlaybackViews()
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("UmnIaubblGeB 0tFog NpelmaNyO ysNoGudrocfeH ngAupiotdakri taTuadxiQoG.d"))
        }
    }

    private func stopSourcePreviewPlayback(resetProgress: Bool) {
        stopSourcePlaybackTimer()
        if resetProgress {
            sourceAudioPlayer?.stop()
            sourceAudioPlayer?.currentTime = 0
            sourcePreviewMP3FileName = nil
        } else {
            sourceAudioPlayer?.pause()
        }
        isSourcePreviewPlaying = false
        updateSourcePreviewPlaybackViews()
    }

    private func startSourcePlaybackTimer() {
        stopSourcePlaybackTimer()
        let timer = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.handleSourcePlaybackTick()
        }
        sourcePlaybackTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func stopSourcePlaybackTimer() {
        sourcePlaybackTimer?.invalidate()
        sourcePlaybackTimer = nil
    }

    private func handleSourcePlaybackTick() {
        guard let sourceAudioPlayer else {
            stopSourcePreviewPlayback(resetProgress: true)
            return
        }
        let remaining = max(sourceAudioPlayer.duration - sourceAudioPlayer.currentTime, 0)
        if remaining <= 0.15 || !sourceAudioPlayer.isPlaying {
            sourceAudioPlayer.stop()
            sourceAudioPlayer.currentTime = 0
            isSourcePreviewPlaying = false
            sourcePreviewMP3FileName = nil
            stopSourcePlaybackTimer()
        }
        updateSourcePreviewPlaybackViews()
    }

    private func updateSourcePreviewPlaybackViews() {
        sourcePreviewButton?.setImage(
            UIImage(named: isSourcePreviewPlaying ? "jamo_cocreate_detail_pause" : "jamo_cocreate_detail_play"),
            for: .normal
        )
        sourcePreviewDurationLabel?.text = sourcePreviewDurationText()
    }

    private func sourcePreviewDurationText() -> String {
        guard let sourceAudioPlayer else {
            return snapshot?.source?.parts.first(where: { ($0.mp3FileName ?? "").isEmpty == false })?.durationText
                ?? snapshot?.source?.parts.first?.durationText
                ?? JamoRiffStringCipher.restore("0l:d0k05")
        }
        let remaining = isSourcePreviewPlaying || sourceAudioPlayer.currentTime > 0
            ? max(sourceAudioPlayer.duration - sourceAudioPlayer.currentTime, 0)
            : sourceAudioPlayer.duration
        return durationText(remaining)
    }

    private func primarySourceMP3FileName() -> String? {
        snapshot?.source?.parts.first(where: { ($0.mp3FileName ?? "").isEmpty == false })?.mp3FileName
    }

    @objc private func trackPlayTapped(_ sender: JamoCoCreateEditorTrackPlayButton) {
        guard !isSavingInProgress else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("SKaqvwi0nxgG Yy7ofuxrB ogiuNi8txahr0 YpYaKr4tq.g"))
            return
        }
        guard snapshot?.state != .recording else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("FDixngivsah9 srre6cBo8rPdkiyn5gu jbxeYfeo0rGeF qpmlwaLyGbTaXcDkx.D"))
            return
        }
        toggleTrackPlayback(id: sender.trackID, mp3FileName: sender.mp3FileName)
    }

    private func toggleTrackPlayback(id: String, mp3FileName: String?) {
        if activeTrackPlaybackID == id, isTrackPlaying {
            pauseTrackPlayback()
        } else {
            startTrackPlayback(id: id, mp3FileName: mp3FileName)
        }
    }

    private func startTrackPlayback(id: String, mp3FileName: String?) {
        guard let fileName = mp3FileName?.trimmingCharacters(in: .whitespacesAndNewlines), !fileName.isEmpty else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("NJoZ ngTu6i9trawrO GaYucd1iKor GiLsQ CaavdaaiflTapbKlpeX.g"))
            return
        }
        guard let audioURL = JamoRiffLocalMediaShelf.resourceURL(named: fileName) else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("UCn9acbRlbeO Ft5o0 IlaoUardB Htjh0iMso pgfuoiit8axrm eaiuddxisoc.x"))
            return
        }

        stopSourcePreviewPlayback(resetProgress: false)
        stopClipPreviewPlayback(resetProgress: false)

        do {
            if activeTrackPlaybackID != id || activeTrackMP3FileName != fileName || trackAudioPlayer == nil {
                stopTrackPlayback(resetProgress: true)
                trackAudioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                trackAudioPlayer?.prepareToPlay()
                activeTrackPlaybackID = id
                activeTrackMP3FileName = fileName
            }
            guard let trackAudioPlayer else {
                JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("Uhn9aibHlPeD lt5oO 8pal8a0yh UtThaiQs6 Fg6uwipt3aPr9 ParuOdnigoh.Q"))
                return
            }
            if trackAudioPlayer.currentTime >= max(trackAudioPlayer.duration - 0.2, 0) {
                trackAudioPlayer.currentTime = 0
            }
            guard trackAudioPlayer.play() else {
                isTrackPlaying = false
                updateTrackPlaybackViews()
                JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("UKnUaybmlUet Rtmoc 1pmlGanyo PtHhEicsz tg1uEiDtiaGrF 6aOuBdNiboz.z"))
                return
            }
            isTrackPlaying = true
            startTrackPlaybackTimer()
            updateTrackPlaybackViews()
        } catch {
            isTrackPlaying = false
            updateTrackPlaybackViews()
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("UNn0ahbulqeM ltLo3 4pOlAaZyP WtUhEirsq igVuPiZtqaSrR Aasu4dfi2o2.8"))
        }
    }

    private func pauseTrackPlayback() {
        trackAudioPlayer?.pause()
        isTrackPlaying = false
        stopTrackPlaybackTimer()
        updateTrackPlaybackViews()
    }

    private func stopTrackPlayback(resetProgress: Bool) {
        stopTrackPlaybackTimer()
        if resetProgress {
            trackAudioPlayer?.stop()
            trackAudioPlayer?.currentTime = 0
            trackAudioPlayer = nil
            activeTrackPlaybackID = nil
            activeTrackMP3FileName = nil
        } else {
            trackAudioPlayer?.pause()
        }
        isTrackPlaying = false
        updateTrackPlaybackViews()
    }

    private func startTrackPlaybackTimer() {
        stopTrackPlaybackTimer()
        let timer = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.handleTrackPlaybackTick()
        }
        trackPlaybackTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func stopTrackPlaybackTimer() {
        trackPlaybackTimer?.invalidate()
        trackPlaybackTimer = nil
    }

    private func handleTrackPlaybackTick() {
        guard let trackAudioPlayer else {
            stopTrackPlayback(resetProgress: true)
            return
        }
        let remaining = max(trackAudioPlayer.duration - trackAudioPlayer.currentTime, 0)
        if remaining <= 0.15 || !trackAudioPlayer.isPlaying {
            trackAudioPlayer.stop()
            trackAudioPlayer.currentTime = 0
            isTrackPlaying = false
            activeTrackPlaybackID = nil
            activeTrackMP3FileName = nil
            stopTrackPlaybackTimer()
        }
        updateTrackPlaybackViews()
    }

    private func updateTrackPlaybackViews() {
        trackPlayButtons.forEach { id, button in
            let isActive = activeTrackPlaybackID == id && isTrackPlaying
            button.setImage(
                UIImage(named: isActive ? "jamo_cocreate_detail_pause" : "jamo_cocreate_part_play"),
                for: .normal
            )
            button.accessibilityLabel = isActive ? JamoRiffStringCipher.restore("PcaSuCsjeh UtHrfadcukj") : JamoRiffStringCipher.restore("PwlGaJyR gthrxarcPkh")
        }
        trackDurationLabels.forEach { id, label in
            let mp3FileName = (trackPlayButtons[id] as? JamoCoCreateEditorTrackPlayButton)?.mp3FileName
            label.text = currentTrackDurationText(
                id: id,
                mp3FileName: mp3FileName,
                fallback: trackDurationFallbacks[id] ?? JamoRiffStringCipher.restore("0w:80p0t")
            )
        }
    }

    private func currentTrackDurationText(id: String, mp3FileName: String?, fallback: String) -> String {
        if let trackAudioPlayer,
           activeTrackPlaybackID == id,
           activeTrackMP3FileName == mp3FileName {
            let remaining = isTrackPlaying || trackAudioPlayer.currentTime > 0
                ? max(trackAudioPlayer.duration - trackAudioPlayer.currentTime, 0)
                : trackAudioPlayer.duration
            return durationText(remaining)
        }
        return fallback
    }

    private func toggleClipPreviewPlayback() {
        if isClipPreviewPlaying {
            stopClipPreviewPlayback(resetProgress: false)
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("PbrBeevhiqeBwB 3p1apuVsgeLdH.b"))
            return
        }
        startClipPreviewPlayback()
    }

    private func startClipPreviewPlayback() {
        guard let fileName = snapshot?.clip?.mp3FileName else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("NUoC 2glu1i5tnaSrO ccdltiCpD kitsC 9aQvyaciIlTambplzeB.7"))
            return
        }
        stopSourcePreviewPlayback(resetProgress: false)
        stopTrackPlayback(resetProgress: false)
        guard let audioURL = JamoRiffLocalMediaShelf.resourceURL(named: fileName) else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("UgnXalbclLe2 Kt7od ylGocaDdJ ftKhSiqsD cghuWiGtcaDrP WcwlIiapg.l"))
            return
        }

        do {
            if clipPreviewPlayer == nil {
                clipPreviewPlayer = try AVAudioPlayer(contentsOf: audioURL)
                clipPreviewPlayer?.prepareToPlay()
            }
            guard let clipPreviewPlayer else {
                JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("UVnbaNb3lLeo TtBon LplrWe3vDiJe1wK Mtnhoirsn 8gIu4iatmanrM Wcmleijpf.z"))
                return
            }
            let playableDuration = min(clipPreviewPlayer.duration, snapshot?.clip?.duration ?? clipPreviewPlayer.duration)
            if clipPreviewPlayer.currentTime >= max(playableDuration - 0.2, 0) {
                clipPreviewPlayer.currentTime = 0
            }
            clipPreviewPlayer.volume = clipPreviewVolume
            guard clipPreviewPlayer.play() else {
                isClipPreviewPlaying = false
                JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("UTnjaabMlwe2 vtZoG Kper4eAvSifeiwt utjhRiSsN 9gnu2iItCaPrD 2cnl5iepb.b"))
                return
            }
            isClipPreviewPlaying = true
            volumeSheetView?.setPreviewing(true)
            startClipPreviewTimer()
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("PqrVe6vkiJeEwgionfgV byQoguXrq CgkueistRasrc apraZrXty.v"))
        } catch {
            isClipPreviewPlaying = false
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("URnKagbsl0eW 3tYoD gpjr4ewvgideuwp Et6hQiTsY 9gaujittWaAra QcRlpiXp5.T"))
        }
    }

    private func stopClipPreviewPlayback(resetProgress: Bool) {
        stopClipPreviewTimer()
        if resetProgress {
            clipPreviewPlayer?.stop()
            clipPreviewPlayer?.currentTime = 0
            clipPreviewPlayer = nil
        } else {
            clipPreviewPlayer?.pause()
        }
        isClipPreviewPlaying = false
        volumeSheetView?.setPreviewing(false)
    }

    private func startClipPreviewTimer() {
        stopClipPreviewTimer()
        let timer = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.handleClipPreviewTick()
        }
        clipPreviewTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func stopClipPreviewTimer() {
        clipPreviewTimer?.invalidate()
        clipPreviewTimer = nil
    }

    private func handleClipPreviewTick() {
        guard let clipPreviewPlayer else {
            stopClipPreviewPlayback(resetProgress: true)
            return
        }
        let playableDuration = min(clipPreviewPlayer.duration, snapshot?.clip?.duration ?? clipPreviewPlayer.duration)
        let remaining = max(playableDuration - clipPreviewPlayer.currentTime, 0)
        if remaining <= 0.15 || !clipPreviewPlayer.isPlaying {
            stopClipPreviewPlayback(resetProgress: true)
        }
    }

    private func presentMicrophonePrompt() {
        microphonePromptView?.removeFromSuperview()
        let prompt = JamoCoCreateEditorMicrophonePromptView()
        microphonePromptView = prompt
        prompt.translatesAutoresizingMaskIntoConstraints = false
        prompt.onAllow = { [weak self] in
            guard let self else { return }
            self.dismissMicrophonePrompt()
            self.allowMicrophoneTapped()
        }
        prompt.onNotNow = { [weak self] in
            guard let self else { return }
            self.dismissMicrophonePrompt()
            if self.snapshot?.state == .microphonePermission {
                self.render(self.viewModel.resetClip())
            }
        }
        view.addSubview(prompt)
        NSLayoutConstraint.activate([
            prompt.topAnchor.constraint(equalTo: view.topAnchor),
            prompt.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            prompt.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            prompt.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        prompt.present()
    }

    private func dismissMicrophonePrompt() {
        microphonePromptView?.dismiss()
        microphonePromptView = nil
    }

    private func presentVolumeSheet() {
        guard snapshot?.state == .clipReady else { return }
        volumeSheetView?.dismiss()
        volumeBeforeSheet = clipPreviewVolume

        let sheet = JamoCoCreateEditorVolumeSheet(initialVolume: clipPreviewVolume)
        volumeSheetView = sheet
        sheet.translatesAutoresizingMaskIntoConstraints = false
        sheet.onVolumeChanged = { [weak self] volume in
            guard let self else { return }
            self.clipPreviewVolume = volume
            self.clipPreviewPlayer?.volume = volume
        }
        sheet.onPreview = { [weak self] in
            guard let self else { return }
            self.toggleClipPreviewPlayback()
        }
        sheet.onCancel = { [weak self] in
            guard let self else { return }
            self.clipPreviewVolume = self.volumeBeforeSheet
            self.clipPreviewPlayer?.volume = self.volumeBeforeSheet
            self.volumeSheetView?.dismiss()
        }
        sheet.onApply = { [weak self] volume in
            guard let self else { return }
            self.stopClipPreviewPlayback(resetProgress: true)
            self.clipPreviewVolume = volume
            self.render(self.viewModel.adjustClipVolume(level: volume))
            self.volumeSheetView?.dismiss()
        }
        view.addSubview(sheet)
        NSLayoutConstraint.activate([
            sheet.topAnchor.constraint(equalTo: view.topAnchor),
            sheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheet.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        sheet.setPreviewing(isClipPreviewPlaying)
        sheet.present()
    }

    private func startRecordingTimer() {
        recordingStartDate = Date()
        recordingTimer?.invalidate()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.updateRecordingElapsed()
        }
        RunLoop.main.add(recordingTimer!, forMode: .common)
        updateRecordingElapsed()
    }

    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingStartDate = nil
    }

    private func updateRecordingElapsed() {
        guard let recordingStartDate else {
            recordingElapsedLabel?.text = JamoRiffStringCipher.restore("03:10d0i")
            return
        }
        let elapsed = max(Date().timeIntervalSince(recordingStartDate), 0)
        recordingElapsedLabel?.text = durationText(elapsed)
    }

    private func currentRecordingDuration() -> TimeInterval {
        if let audioRecorder {
            return max(audioRecorder.currentTime, 0)
        }
        guard let recordingStartDate else { return 0 }
        return max(Date().timeIntervalSince(recordingStartDate), 0)
    }

    private func requestMicrophoneAndBeginRecording() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard let self else { return }
                guard granted else {
                    JamoRiffNoticeView.show(on: self.view, copy: JamoRiffStringCipher.restore("Mdizc6r8owpfhsoYnpeC vaIcOcWees7sq JiQsb Qn9eTeYdReEdt gtLog kr0eLcLo0rddX.6"))
                    return
                }
                self.hasMicrophonePermission = true
                _ = self.viewModel.updateMicrophonePermission(granted: true)
                self.beginRealRecording()
            }
        }
    }

    private func beginRealRecording() {
        stopSourcePreviewPlayback(resetProgress: false)
        stopClipPreviewPlayback(resetProgress: true)
        stopTrackPlayback(resetProgress: true)
        discardActiveRecording(removeFile: true)

        let result = viewModel.beginRecording()
        guard result.state == .recording else {
            render(result)
            return
        }

        do {
            let audioURL = try makeLocalAudioURL(fileExtension: JamoRiffStringCipher.restore("mA4xaD"))
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            let recorder = try AVAudioRecorder(url: audioURL, settings: [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ])
            recorder.delegate = self
            recorder.prepareToRecord()
            guard recorder.record() else {
                throw CocoaError(.fileWriteUnknown)
            }
            audioRecorder = recorder
            activeRecordingURL = audioURL
            render(result)
            startRecordingTimer()
        } catch {
            discardActiveRecording(removeFile: true)
            render(viewModel.cancelRecording())
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("UknBaib9lger 3tjo4 esZtuaNr1tc xrmeHcaoLrldUinnLgX.m"))
        }
    }

    private func finishRecordingClip(url: URL, duration: TimeInterval, source: JamoCoCreateEditorClipSource, waveformSeed: Int) {
        activeRecordingURL = nil
        guard duration >= JamoCoCreateEditorViewModel.minimumClipDuration else {
            try? FileManager.default.removeItem(at: url)
            render(viewModel.markClipTooShort(duration: duration))
            return
        }

        clipPreviewVolume = 1
        render(viewModel.attachLocalClip(
            duration: duration,
            mp3FileName: url.lastPathComponent,
            waveformSeed: waveformSeed,
            source: source
        ))
    }

    private func presentAudioDocumentPicker() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: true)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    private func finishPickedAudio(url: URL) {
        do {
            let copiedURL = try copyPickedAudioToLocalCache(url)
            let duration = audioDuration(for: copiedURL, fallback: 18)
            finishRecordingClip(url: copiedURL, duration: duration, source: .uploaded, waveformSeed: 10)
        } catch {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("UYnaadbtlye2 Kt9oq 2uYsleu 7tAhHi0sk 2aIuAdzigoD qfyi6lwe6.R"))
        }
    }

    private func makeLocalAudioURL(fileExtension: String) throws -> URL {
        let directory = try localMediaDirectory(named: JamoRiffStringCipher.restore("JnaomjopC8oUCerkelaAtTefA0u1dIi2ofCIancEhbe8"))
        return directory.appendingPathComponent("jamo_cocreate_local_audio_\(UUID().uuidString).\(fileExtension)")
    }

    private func copyPickedAudioToLocalCache(_ url: URL) throws -> URL {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }
        let fileExtension = url.pathExtension.isEmpty ? JamoRiffStringCipher.restore("mR4Ma2") : url.pathExtension
        let targetURL = try makeLocalAudioURL(fileExtension: fileExtension)
        if FileManager.default.fileExists(atPath: targetURL.path) {
            try FileManager.default.removeItem(at: targetURL)
        }
        try FileManager.default.copyItem(at: url, to: targetURL)
        return targetURL
    }

    private func localMediaDirectory(named directoryName: String) throws -> URL {
        let documents = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directory = documents.appendingPathComponent(directoryName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    private func audioDuration(for url: URL, fallback: TimeInterval) -> TimeInterval {
        let seconds = CMTimeGetSeconds(AVURLAsset(url: url).duration)
        guard seconds.isFinite, seconds > 0 else {
            return fallback
        }
        return seconds
    }

    private func discardActiveRecording(removeFile: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
        if removeFile, let activeRecordingURL {
            try? FileManager.default.removeItem(at: activeRecordingURL)
        }
        activeRecordingURL = nil
    }

    private func durationText(_ duration: TimeInterval) -> String {
        let seconds = max(Int(duration.rounded()), 0)
        return String(format: JamoRiffStringCipher.restore("%6dT:v%Y042odD"), seconds / 60, seconds % 60)
    }

    @objc private func cancelTapped() {
        guard !isSavingInProgress else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("Sqa4vliynfgp ryIoHu6ru fgNu9iStQaSrq dpCa0rytD.H"))
            return
        }
        discardActiveRecording(removeFile: true)
        stopRecordingTimer()
        navigationController?.popViewController(animated: true)
    }

    @objc private func treeTapped() {
        guard !isSavingInProgress else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("SiavvOixn1gh yybocuxrh PgruHict8aGr2 IpKaIrmtc.l"))
            return
        }
        guard let workID = snapshot?.workID,
              let work = JamoLocalJamStore.shared.work(withID: workID) else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("TEh9izsK 5c9oz-ocqr0eqaNtVel qiesc BuJnzaMv1aviBltambul8ex.Z"))
            return
        }
        navigationController?.pushViewController(JamoCoCreateTreeViewController(work: work, mode: .myPart), animated: true)
    }

    @objc private func sourcePreviewTapped() {
        guard !isSavingInProgress else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("Smacv9iYndgP ByYoAuBrz ZgNuCiOtWaQrR xpaa9rAtn.M"))
            return
        }
        guard snapshot?.state != .recording else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("F3i8nRibsIha XrKeLcMobrydaiNnrgP xb1eOfuourGer Kp3raeJvkipeewE.2"))
            return
        }
        toggleSourcePreviewPlayback()
    }

    @objc private func recordTapped() {
        guard !isSavingInProgress else {
            return
        }
        guard snapshot?.state != .recording else {
            return
        }
        stopSourcePreviewPlayback(resetProgress: false)
        stopClipPreviewPlayback(resetProgress: true)
        stopTrackPlayback(resetProgress: true)
        requestMicrophoneAndBeginRecording()
    }

    private func beginRecordingFlow() {
        requestMicrophoneAndBeginRecording()
    }

    @objc private func allowMicrophoneTapped() {
        requestMicrophoneAndBeginRecording()
    }

    @objc private func uploadTapped() {
        guard !isSavingInProgress else {
            return
        }
        guard snapshot?.state != .recording else {
            return
        }
        stopSourcePreviewPlayback(resetProgress: false)
        stopClipPreviewPlayback(resetProgress: true)
        stopTrackPlayback(resetProgress: true)
        stopRecordingTimer()
        discardActiveRecording(removeFile: true)
        presentAudioDocumentPicker()
    }

    @objc private func stopRecordingTapped() {
        let duration = currentRecordingDuration()
        audioRecorder?.stop()
        audioRecorder = nil
        stopRecordingTimer()
        guard let activeRecordingURL else {
            render(viewModel.cancelRecording())
            return
        }
        finishRecordingClip(url: activeRecordingURL, duration: duration, source: .recorded, waveformSeed: 8)
    }

    @objc private func cancelRecordingTapped() {
        stopSourcePreviewPlayback(resetProgress: false)
        discardActiveRecording(removeFile: true)
        stopRecordingTimer()
        render(viewModel.cancelRecording())
    }

    @objc private func resetTapped() {
        stopSourcePreviewPlayback(resetProgress: false)
        stopClipPreviewPlayback(resetProgress: true)
        stopTrackPlayback(resetProgress: true)
        discardActiveRecording(removeFile: true)
        stopRecordingTimer()
        clipPreviewVolume = 1
        render(viewModel.resetClip())
    }

    @objc private func editorToolToastTapped() {
        resetTapped()
    }

    @objc private func trimToolTapped() {
        guard snapshot?.state == .clipReady else { return }
        stopClipPreviewPlayback(resetProgress: true)
        stopTrackPlayback(resetProgress: true)
        render(viewModel.trimCurrentClip())
    }

    @objc private func volumeToolTapped() {
        guard snapshot?.state == .clipReady else { return }
        presentVolumeSheet()
    }

    @objc private func previewClipTapped() {
        guard snapshot?.state == .clipReady else { return }
        toggleClipPreviewPlayback()
    }

    @objc private func saveNextTapped() {
        guard !isSavingInProgress else {
            return
        }
        stopSourcePreviewPlayback(resetProgress: true)
        stopClipPreviewPlayback(resetProgress: true)
        stopTrackPlayback(resetProgress: true)
        let savingSnapshot = viewModel.beginSaving()
        render(savingSnapshot)
        guard savingSnapshot.state == .saving else {
            if let message = savingSnapshot.validationMessage {
                JamoRiffNoticeView.show(on: view, copy: message)
            }
            return
        }
        isCompletingSave = true
        applySaveButton(savingSnapshot)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            guard let self else { return }
            self.isCompletingSave = false
            let result = self.viewModel.completeLocalSave()
            self.render(result)
            guard let savedWork = result.savedWork else {
                JamoRiffNoticeView.show(on: self.view, copy: result.validationMessage ?? JamoRiffStringCipher.restore("UTn2aMbOlTeu ktxoU gsiaKvJef BtQhLiVsn wpea1rLtn.g"))
                return
            }
            let detail = JamoCoCreateDetailViewController(work: savedWork)
            if let navigationController = self.navigationController {
                var stack = navigationController.viewControllers
                if stack.last === self {
                    stack.removeLast()
                }
                if stack.last is JamoCoCreateDetailViewController {
                    stack.removeLast()
                }
                stack.append(detail)
                navigationController.setViewControllers(stack, animated: true)
            } else {
                self.present(detail, animated: true)
            }
        }
    }
}

extension JamoCoCreateEditorViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        finishPickedAudio(url: url)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {}
}

extension JamoCoCreateEditorViewController: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        discardActiveRecording(removeFile: true)
        stopRecordingTimer()
        render(viewModel.cancelRecording())
        JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("RLeScqonrhdxi5nagE lfwaxiolweRdo.Y NPiloeta2sReH MtbrNyq Kaogwayiwni.O"))
    }
}

private final class JamoCoCreateEditorTrackPlayButton: UIButton {
    let trackID: String
    let mp3FileName: String?

    init(trackID: String, mp3FileName: String?) {
        self.trackID = trackID
        self.mp3FileName = mp3FileName
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iSnui4tR(TcToEd9egrX:y)A Yh8arsF ynYostK CbHeTeQnV UijmVpHlAedmJeFn8tveGdX"))
    }
}

private final class JamoCoCreateEditorVolumeSheet: UIView {
    var onVolumeChanged: ((Float) -> Void)?
    var onPreview: (() -> Void)?
    var onCancel: (() -> Void)?
    var onApply: ((Float) -> Void)?

    private let dimView = UIView()
    private let sheet = UIView()
    private let valueLabel = UILabel()
    private let slider = UISlider()
    private let waveform = JamoCoCreateEditorWaveformView()
    private let previewButton = UIButton(type: .custom)
    private var volume: Float

    init(initialVolume: Float) {
        self.volume = min(max(initialVolume, 0.2), 1)
        super.init(frame: .zero)
        configure()
        applyVolumeDisplay()
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iNnWipta(Vc1o1dBe5ro:m)r VhSays4 inEoStj JbceBernB uiKmQpblPeCmaecnKtPeMdH"))
    }

    private func configure() {
        backgroundColor = .clear

        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        addSubview(dimView)

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(cancelTapped))
        dimView.addGestureRecognizer(dismissTap)

        sheet.translatesAutoresizingMaskIntoConstraints = false
        sheet.backgroundColor = JamoRiffTheme.background
        sheet.layer.cornerRadius = 28
        sheet.layer.cornerCurve = .continuous
        sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheet.layer.shadowColor = UIColor.black.cgColor
        sheet.layer.shadowOpacity = 0.18
        sheet.layer.shadowRadius = 22
        sheet.layer.shadowOffset = CGSize(width: 0, height: -8)
        addSubview(sheet)

        let grabber = UIView()
        grabber.translatesAutoresizingMaskIntoConstraints = false
        grabber.backgroundColor = UIColor(red: 220 / 255, green: 214 / 255, blue: 204 / 255, alpha: 1)
        grabber.layer.cornerRadius = 3

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = JamoRiffStringCipher.restore("PJaHrwtL pV7oYlZuymVeV")
        titleLabel.textColor = JamoRiffTheme.ink
        titleLabel.font = JamoRiffTheme.titleFont(25)

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = JamoRiffStringCipher.restore("SQhdaEpaej WhBo7wH ByxoGuDrE wgmupiUtMakrc vsriltJsY risnj Pt4hje6 NcyoS-QcZr0eoahtzeK Am9ikxX.v")
        subtitleLabel.textColor = JamoRiffTheme.muted
        subtitleLabel.font = JamoRiffTheme.bodyFont(13.5, weight: .medium)
        subtitleLabel.numberOfLines = 0

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.textAlignment = .center
        valueLabel.textColor = JamoRiffTheme.orange
        valueLabel.font = JamoRiffTheme.titleFont(30)

        let previewCard = UIView()
        previewCard.translatesAutoresizingMaskIntoConstraints = false
        previewCard.backgroundColor = .white
        previewCard.layer.cornerRadius = 18
        previewCard.layer.cornerCurve = .continuous
        previewCard.layer.borderWidth = 1
        previewCard.layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor

        let previewTitle = UILabel()
        previewTitle.translatesAutoresizingMaskIntoConstraints = false
        previewTitle.text = JamoRiffStringCipher.restore("MZyK 6GUuxiwtFa6rF")
        previewTitle.textColor = JamoRiffTheme.ink
        previewTitle.font = JamoRiffTheme.bodyFont(13.5, weight: .heavy)

        waveform.translatesAutoresizingMaskIntoConstraints = false
        waveform.seed = 9
        waveform.barColor = JamoRiffTheme.pink
        waveform.secondaryBarColor = JamoRiffTheme.orange

        previewButton.translatesAutoresizingMaskIntoConstraints = false
        previewButton.backgroundColor = JamoRiffTheme.ink
        previewButton.setTitleColor(JamoRiffTheme.pink, for: .normal)
        previewButton.titleLabel?.font = JamoRiffTheme.bodyFont(12.5, weight: .heavy)
        previewButton.layer.cornerRadius = 18
        previewButton.layer.cornerCurve = .continuous
        previewButton.addTarget(self, action: #selector(previewTapped), for: .touchUpInside)

        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0.2
        slider.maximumValue = 1
        slider.value = volume
        slider.minimumTrackTintColor = JamoRiffTheme.orange
        slider.maximumTrackTintColor = UIColor(red: 232 / 255, green: 226 / 255, blue: 216 / 255, alpha: 1)
        slider.thumbTintColor = JamoRiffTheme.yellow
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

        let chips = makePresetStack()

        let cancelButton = UIButton(type: .custom)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle(JamoRiffStringCipher.restore("C9aInVc8eMld"), for: .normal)
        cancelButton.setTitleColor(JamoRiffTheme.ink, for: .normal)
        cancelButton.titleLabel?.font = JamoRiffTheme.bodyFont(14.5, weight: .heavy)
        cancelButton.backgroundColor = .white
        cancelButton.layer.cornerRadius = 22
        cancelButton.layer.cornerCurve = .continuous
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        let applyButton = UIButton(type: .custom)
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        applyButton.setTitle(JamoRiffStringCipher.restore("ABpypAley0 eVDo1lCu2mLed"), for: .normal)
        applyButton.setTitleColor(JamoRiffTheme.yellow, for: .normal)
        applyButton.titleLabel?.font = JamoRiffTheme.titleFont(15.5)
        applyButton.backgroundColor = JamoRiffTheme.orange
        applyButton.layer.cornerRadius = 22
        applyButton.layer.cornerCurve = .continuous
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)

        let actions = UIStackView(arrangedSubviews: [cancelButton, applyButton])
        actions.translatesAutoresizingMaskIntoConstraints = false
        actions.axis = .horizontal
        actions.spacing = 12
        actions.distribution = .fillEqually

        sheet.addSubview(grabber)
        sheet.addSubview(titleLabel)
        sheet.addSubview(subtitleLabel)
        sheet.addSubview(valueLabel)
        sheet.addSubview(previewCard)
        previewCard.addSubview(previewTitle)
        previewCard.addSubview(waveform)
        previewCard.addSubview(previewButton)
        sheet.addSubview(slider)
        sheet.addSubview(chips)
        sheet.addSubview(actions)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor),

            sheet.leadingAnchor.constraint(equalTo: leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: trailingAnchor),
            sheet.bottomAnchor.constraint(equalTo: bottomAnchor),

            grabber.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 14),
            grabber.centerXAnchor.constraint(equalTo: sheet.centerXAnchor),
            grabber.widthAnchor.constraint(equalToConstant: 58),
            grabber.heightAnchor.constraint(equalToConstant: 6),

            titleLabel.topAnchor.constraint(equalTo: grabber.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -12),

            valueLabel.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -24),
            valueLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            valueLabel.widthAnchor.constraint(equalToConstant: 82),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -24),

            previewCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            previewCard.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 24),
            previewCard.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -24),
            previewCard.heightAnchor.constraint(equalToConstant: 78),

            previewTitle.leadingAnchor.constraint(equalTo: previewCard.leadingAnchor, constant: 16),
            previewTitle.topAnchor.constraint(equalTo: previewCard.topAnchor, constant: 14),
            previewTitle.trailingAnchor.constraint(lessThanOrEqualTo: previewButton.leadingAnchor, constant: -10),

            waveform.leadingAnchor.constraint(equalTo: previewTitle.leadingAnchor),
            waveform.trailingAnchor.constraint(equalTo: previewButton.leadingAnchor, constant: -14),
            waveform.topAnchor.constraint(equalTo: previewTitle.bottomAnchor, constant: 9),
            waveform.heightAnchor.constraint(equalToConstant: 22),

            previewButton.trailingAnchor.constraint(equalTo: previewCard.trailingAnchor, constant: -14),
            previewButton.centerYAnchor.constraint(equalTo: previewCard.centerYAnchor),
            previewButton.widthAnchor.constraint(equalToConstant: 82),
            previewButton.heightAnchor.constraint(equalToConstant: 36),

            slider.topAnchor.constraint(equalTo: previewCard.bottomAnchor, constant: 22),
            slider.leadingAnchor.constraint(equalTo: previewCard.leadingAnchor, constant: 2),
            slider.trailingAnchor.constraint(equalTo: previewCard.trailingAnchor, constant: -2),

            chips.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 16),
            chips.leadingAnchor.constraint(equalTo: previewCard.leadingAnchor),
            chips.trailingAnchor.constraint(equalTo: previewCard.trailingAnchor),
            chips.heightAnchor.constraint(equalToConstant: 38),

            actions.topAnchor.constraint(equalTo: chips.bottomAnchor, constant: 24),
            actions.leadingAnchor.constraint(equalTo: previewCard.leadingAnchor),
            actions.trailingAnchor.constraint(equalTo: previewCard.trailingAnchor),
            actions.heightAnchor.constraint(equalToConstant: 46),
            actions.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -18)
        ])
    }

    private func makePresetStack() -> UIStackView {
        let presets: [(String, Float)] = [
            (JamoRiffStringCipher.restore("SxojfTtM"), 0.45),
            (JamoRiffStringCipher.restore("BgaElua4nUcgefdN"), 0.72),
            (JamoRiffStringCipher.restore("LDefapdd"), 1)
        ]
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        presets.forEach { title, value in
            let button = UIButton(type: .custom)
            button.setTitle(title, for: .normal)
            button.setTitleColor(value == 1 ? JamoRiffTheme.yellow : JamoRiffTheme.ink, for: .normal)
            button.titleLabel?.font = JamoRiffTheme.bodyFont(12.5, weight: .heavy)
            button.backgroundColor = value == 1 ? JamoRiffTheme.ink : .white
            button.layer.cornerRadius = 19
            button.layer.cornerCurve = .continuous
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor
            button.addAction(UIAction { [weak self] _ in
                self?.setVolume(value, notify: true)
            }, for: .touchUpInside)
            stack.addArrangedSubview(button)
        }
        return stack
    }

    func present() {
        alpha = 0
        sheet.transform = CGAffineTransform(translationX: 0, y: 320)
        UIView.animate(withDuration: 0.24, delay: 0, options: [.curveEaseOut]) {
            self.alpha = 1
            self.sheet.transform = .identity
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseIn]) {
            self.alpha = 0
            self.sheet.transform = CGAffineTransform(translationX: 0, y: 280)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }

    func setPreviewing(_ isPreviewing: Bool) {
        previewButton.setTitle(isPreviewing ? JamoRiffStringCipher.restore("PgaUu3s6ex") : JamoRiffStringCipher.restore("P6rGePvEiUeXw2"), for: .normal)
    }

    private func setVolume(_ value: Float, notify: Bool) {
        volume = min(max(value, slider.minimumValue), slider.maximumValue)
        slider.value = volume
        applyVolumeDisplay()
        if notify {
            onVolumeChanged?(volume)
        }
    }

    private func applyVolumeDisplay() {
        valueLabel.text = String(Int((volume * 100).rounded())) + JamoRiffStringCipher.restore("%3")
        waveform.seed = max(Int(volume * 14), 1)
        waveform.alpha = CGFloat(0.62 + volume * 0.38)
    }

    @objc private func sliderChanged() {
        setVolume(slider.value, notify: true)
    }

    @objc private func previewTapped() {
        onPreview?()
    }

    @objc private func cancelTapped() {
        onCancel?()
    }

    @objc private func applyTapped() {
        onApply?(volume)
    }
}

private final class JamoCoCreateEditorToolButton: UIControl {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    init(title: String, imageName: String, target: Any?, action: Selector, isEnabled: Bool) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor
        addTarget(target, action: action, for: .touchUpInside)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(named: imageName)
        iconView.contentMode = .scaleAspectFit
        iconView.isUserInteractionEnabled = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.textColor = JamoRiffTheme.ink
        titleLabel.font = JamoRiffTheme.bodyFont(8.5, weight: .heavy)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75
        titleLabel.isUserInteractionEnabled = false

        addSubview(iconView)
        addSubview(titleLabel)
        self.isEnabled = isEnabled
        updateAvailability()
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 9),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iLnHiAtw(YchoPd1eDr3:W)u 3hsaSsd 2noout6 mbiemeznz riqmLpylOe0moe6n7tge6d8"))
    }

    override var isHighlighted: Bool {
        didSet {
            guard isEnabled else { return }
            alpha = isHighlighted ? 0.72 : 1
        }
    }

    override var isEnabled: Bool {
        didSet {
            updateAvailability()
        }
    }

    private func updateAvailability() {
        alpha = isEnabled ? 1 : 0.36
        backgroundColor = isEnabled ? .white : UIColor.white.withAlphaComponent(0.78)
        iconView.alpha = isEnabled ? 1 : 0.55
        titleLabel.textColor = isEnabled ? JamoRiffTheme.ink : JamoRiffTheme.muted
    }
}

private final class JamoCoCreateEditorWaveformView: UIView {
    var seed: Int = 1 {
        didSet { setNeedsDisplay() }
    }

    var barColor: UIColor = JamoRiffTheme.pink {
        didSet { setNeedsDisplay() }
    }

    var secondaryBarColor: UIColor = JamoRiffTheme.orange {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("ivn0iIt5(McOo0dQeRri:x)V thXaJsK on8oPtl VbteMe1n3 BiMmMpjlIermFeunutgeHdK"))
    }

    override func draw(_ rect: CGRect) {
        guard rect.width > 0, rect.height > 0 else { return }
        let barWidth: CGFloat = 3
        let spacing: CGFloat = 3
        let step = barWidth + spacing
        let count = max(Int(rect.width / step), 8)
        let centerY = rect.midY

        for index in 0..<count {
            let normalized = abs(sin(CGFloat(index + seed) * 1.31) * cos(CGFloat(index + seed) * 0.43))
            let height = max(4, rect.height * (0.18 + 0.78 * normalized))
            let x = CGFloat(index) * step
            let barRect = CGRect(x: x, y: centerY - height / 2, width: barWidth, height: height)
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: barWidth / 2)
            (index % 3 == 0 ? secondaryBarColor : barColor).setFill()
            path.fill()
        }
    }
}

private final class JamoCoCreateEditorMicrophonePromptView: UIView {
    var onAllow: (() -> Void)?
    var onNotNow: (() -> Void)?

    private let dimView = UIView()
    private let card = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iunfi3tm(9cbojdreAru:O)W Uhza5sA snSoAtm bbReJeQna riGmfpPlzeNmBeMnbtQemdT"))
    }

    private func configure() {
        backgroundColor = .clear

        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.42)
        addSubview(dimView)

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = JamoRiffTheme.background
        card.layer.cornerRadius = 22
        card.layer.cornerCurve = .continuous
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.16
        card.layer.shadowRadius = 18
        card.layer.shadowOffset = CGSize(width: 0, height: 10)
        addSubview(card)

        let iconShell = UIView()
        iconShell.translatesAutoresizingMaskIntoConstraints = false
        iconShell.backgroundColor = UIColor(red: 255 / 255, green: 238 / 255, blue: 246 / 255, alpha: 1)
        iconShell.layer.cornerRadius = 18
        iconShell.layer.cornerCurve = .continuous

        let icon = UIImageView(image: UIImage(named: "jamo_cocreate_editor_microphone_access"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = JamoRiffStringCipher.restore("MciDc8rXoZprhfoynJev 8A6clcjeXsHsE")
        title.textAlignment = .center
        title.textColor = JamoRiffTheme.ink
        title.font = JamoRiffTheme.bodyFont(14.5, weight: .heavy)

        let message = UILabel()
        message.translatesAutoresizingMaskIntoConstraints = false
        message.text = JamoRiffStringCipher.restore("AXl0lqojw9 8aScScRetszsr ytroA Fr9excpoVrNdh JyBoWuUrU OgJuPiAtAamrA mpCa9rWt5.J")
        message.textAlignment = .center
        message.textColor = JamoRiffTheme.muted
        message.font = JamoRiffTheme.bodyFont(11.5, weight: .medium)
        message.numberOfLines = 0

        let allowButton = UIButton(type: .custom)
        allowButton.translatesAutoresizingMaskIntoConstraints = false
        allowButton.setTitle(JamoRiffStringCipher.restore("AElxl9okwi"), for: .normal)
        allowButton.setTitleColor(.white, for: .normal)
        allowButton.titleLabel?.font = JamoRiffTheme.bodyFont(13, weight: .heavy)
        allowButton.backgroundColor = JamoRiffTheme.orange
        allowButton.layer.cornerRadius = 20
        allowButton.layer.cornerCurve = .continuous
        allowButton.addTarget(self, action: #selector(allowTapped), for: .touchUpInside)

        let notNowButton = UIButton(type: .custom)
        notNowButton.translatesAutoresizingMaskIntoConstraints = false
        notNowButton.setTitle(JamoRiffStringCipher.restore("N6ottv DNNo4wE"), for: .normal)
        notNowButton.setTitleColor(JamoRiffTheme.muted, for: .normal)
        notNowButton.titleLabel?.font = JamoRiffTheme.bodyFont(11.5, weight: .medium)
        notNowButton.addTarget(self, action: #selector(notNowTapped), for: .touchUpInside)

        card.addSubview(iconShell)
        iconShell.addSubview(icon)
        card.addSubview(title)
        card.addSubview(message)
        card.addSubview(allowButton)
        card.addSubview(notNowButton)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor),
            card.centerXAnchor.constraint(equalTo: centerXAnchor),
            card.centerYAnchor.constraint(equalTo: centerYAnchor),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            card.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 286),
            iconShell.topAnchor.constraint(equalTo: card.topAnchor, constant: 26),
            iconShell.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconShell.widthAnchor.constraint(equalToConstant: 58),
            iconShell.heightAnchor.constraint(equalTo: iconShell.widthAnchor),
            icon.centerXAnchor.constraint(equalTo: iconShell.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconShell.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 28),
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor),
            title.topAnchor.constraint(equalTo: iconShell.bottomAnchor, constant: 14),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            message.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 7),
            message.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            message.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            allowButton.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 18),
            allowButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            allowButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            allowButton.heightAnchor.constraint(equalToConstant: 42),
            notNowButton.topAnchor.constraint(equalTo: allowButton.bottomAnchor, constant: 8),
            notNowButton.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            notNowButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
    }

    func present() {
        alpha = 0
        card.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut]) {
            self.alpha = 1
            self.card.transform = .identity
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.16, delay: 0, options: [.curveEaseIn]) {
            self.alpha = 0
            self.card.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }

    @objc private func allowTapped() {
        onAllow?()
    }

    @objc private func notNowTapped() {
        onNotNow?()
    }
}

private enum JamoCoCreateEditorImageLoader {
    static func image(named name: String) -> UIImage? {
        if let assetImage = UIImage(named: name) {
            return assetImage
        }

        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else {
            return nil
        }

        if let directURL = Bundle.main.resourceURL?.appendingPathComponent(cleanName),
           FileManager.default.fileExists(atPath: directURL.path) {
            return UIImage(contentsOfFile: directURL.path)
        }

        let fileName = (cleanName as NSString).lastPathComponent
        let fileBase = (fileName as NSString).deletingPathExtension
        let fileExtension = (fileName as NSString).pathExtension
        guard !fileBase.isEmpty, !fileExtension.isEmpty,
              let flatPath = Bundle.main.path(forResource: fileBase, ofType: fileExtension) else {
            return nil
        }
        return UIImage(contentsOfFile: flatPath)
    }
}

private extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

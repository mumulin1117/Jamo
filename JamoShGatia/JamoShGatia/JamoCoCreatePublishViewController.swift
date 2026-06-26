import AVFoundation
import UIKit
import UniformTypeIdentifiers

final class JamoCoCreatePublishViewController: JamoMainBaseViewController, UITextFieldDelegate, UITextViewDelegate {
    private enum PublishAudioState: Equatable {
        case choosing
        case recording
        case clipReady(method: JamoCoCreateJoinMethod, duration: TimeInterval, waveformSeed: Int)
        case clipTooShort
    }

    private enum PublishLayout {
        static let maxContentWidth: CGFloat = 360
        static let contentTopInset: CGFloat = 4
        static let horizontalInset: CGFloat = 22
        static let contentBottomInset: CGFloat = 118
        static let sectionSpacing: CGFloat = 17
        static let coverRatio: CGFloat = 160 / 331
        static let cardRadius: CGFloat = 18
        static let fieldHeight: CGFloat = 50
        static let primaryButtonHeight: CGFloat = 56
        static let bottomActionHeight: CGFloat = 94
    }

    private let viewModel: JamoCoCreatePublishViewModel
    private let sourceWork: JamoCoCreateWork?
    private var snapshot: JamoCoCreatePublishSnapshot?
    private var hasSelectedCover: Bool
    private var isCompletingPublish = false
    private var audioState: PublishAudioState
    private var audioRecorder: AVAudioRecorder?
    private var activeRecordingURL: URL?
    private var recordingStartDate: Date?
    private var recordingTimer: Timer?
    private weak var recordingElapsedLabel: UILabel?
#if DEBUG
    private var shouldSimulatePublishFailure = false
#endif

    private let coverCard = JamoCoCreatePublishDashedCardView(cornerRadius: PublishLayout.cardRadius)
    private let coverImageView = UIImageView()
    private let coverPlaceholderIcon = UIImageView(image: UIImage(named: "jamo_cocreate_publish_cover_placeholder"))
    private let coverPlaceholderLabel = UILabel()
    private let uploadCoverButton = UIButton() 
    private let titleField = JamoCoCreatePublishTextField(placeholder: "Name your co-create")
    private let aboutTextView = JamoCoCreatePublishTextView(placeholder: "Added a warm 15s lead \nline over the original riff.")
    private let validationLabel = UILabel()
    private let allowSwitch = UISwitch()
    private let publishButton = UIButton(type: .custom)
    private let publishActivity = UIActivityIndicatorView(style: .medium)
    private let bottomActionBar = UIView()
    private let bottomSeparator = UIView()
    private var bottomActionBottomConstraint: NSLayoutConstraint?
    private var tagButtons: [String: JamoCoCreatePublishTagButton] = [:]
    private var audioButtons: [JamoCoCreateJoinMethod: JamoCoCreatePublishAudioOptionButton] = [:]

    init(draftWork: JamoCoCreateWork? = nil, selectedJoinMethod: JamoCoCreateJoinMethod? = nil) {
        self.sourceWork = draftWork
        self.viewModel = JamoCoCreatePublishViewModel(
            sourceWorkID: draftWork?.id,
            selectedJoinMethod: selectedJoinMethod
        )
        self.hasSelectedCover = draftWork != nil
        self.audioState = selectedJoinMethod == nil ? .choosing : .clipReady(
            method: selectedJoinMethod ?? .recordGuitar,
            duration: selectedJoinMethod == .uploadClip ? 18 : 15,
            waveformSeed: selectedJoinMethod == .uploadClip ? 10 : 7
        )
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = nil
        uploadCoverButton.translatesAutoresizingMaskIntoConstraints = false
        uploadCoverButton.setBackgroundImage( UIImage.init(named: "uploadcover"), for: .normal)
        view.backgroundColor = JamoMainTheme.background
        applyPublishLayoutOverrides()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        configureInputs()
        configureBottomActionBar()
        buildPage()
        applySnapshot(viewModel.makeSnapshot(), refreshText: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRecordingTimer()
        audioRecorder?.stop()
        audioRecorder = nil
        
    }

    private func configureInputs() {
        titleField.delegate = self
        titleField.addTarget(self, action: #selector(titleChanged), for: .editingChanged)
        aboutTextView.delegate = self

        validationLabel.textColor = UIColor(red: 229 / 255, green: 68 / 255, blue: 78 / 255, alpha: 1)
        validationLabel.font = JamoMainTheme.bodyFont(11.5, weight: .medium)
        validationLabel.numberOfLines = 0
        validationLabel.isHidden = true

        allowSwitch.onTintColor = JamoMainTheme.orange

        publishButton.translatesAutoresizingMaskIntoConstraints = false
        publishButton.layer.cornerRadius = PublishLayout.primaryButtonHeight / 2
        publishButton.titleLabel?.font = JamoMainTheme.bodyFont(18, weight: .heavy)
        publishButton.addTarget(self, action: #selector(publishTapped), for: .touchUpInside)
        publishButton.heightAnchor.constraint(equalToConstant: PublishLayout.primaryButtonHeight).isActive = true

        publishActivity.translatesAutoresizingMaskIntoConstraints = false
        publishActivity.hidesWhenStopped = true
        publishActivity.color = JamoMainTheme.muted
        publishButton.addSubview(publishActivity)
        NSLayoutConstraint.activate([
            publishActivity.centerYAnchor.constraint(equalTo: publishButton.centerYAnchor),
            publishActivity.centerXAnchor.constraint(equalTo: publishButton.centerXAnchor, constant: -62)
        ])
    }

    private func buildPage() {
        contentStack.removeFromSuperview()
        contentView.subviews
            .filter { $0 !== contentStack }
            .forEach { $0.removeFromSuperview() }

        let formView = UIView()
        formView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(formView)

        let width = formView.widthAnchor.constraint(
            equalTo: contentView.widthAnchor,
            constant: -(PublishLayout.horizontalInset * 2)
        )
        width.priority = .defaultHigh
        NSLayoutConstraint.activate([
            formView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: PublishLayout.contentTopInset),
            formView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            formView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: PublishLayout.horizontalInset),
            formView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -PublishLayout.horizontalInset),
            formView.widthAnchor.constraint(lessThanOrEqualToConstant: PublishLayout.maxContentWidth),
            width,
            formView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -PublishLayout.contentBottomInset)
        ])

        let topBar = makeTopBar()
        let coverSection = makeCoverSection()
        let audioSection: UIView
        if let source = viewModel.makeSnapshot().source {
            audioSection = JamoCoCreatePublishSourceCardView(source: source, currentUser: viewModel.makeSnapshot().currentUser)
        } else {
            audioSection = makeAudioSection()
        }
        let titleSection = makeTitleSection()
        let aboutSection = makeAboutSection()
        let tagsSection = makeTagsSection()
        let allowCard = makeAllowContinueCard()

        [topBar, coverSection, audioSection, titleSection, aboutSection, tagsSection, allowCard].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            formView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: formView.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: formView.trailingAnchor),

            coverSection.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 13),
            coverSection.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            coverSection.trailingAnchor.constraint(equalTo: formView.trailingAnchor),

            audioSection.topAnchor.constraint(equalTo: coverSection.bottomAnchor, constant: 18),
            audioSection.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            audioSection.trailingAnchor.constraint(equalTo: formView.trailingAnchor),

            titleSection.topAnchor.constraint(equalTo: audioSection.bottomAnchor, constant: 20),
            titleSection.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            titleSection.trailingAnchor.constraint(equalTo: formView.trailingAnchor),

            aboutSection.topAnchor.constraint(equalTo: titleSection.bottomAnchor, constant: 20),
            aboutSection.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            aboutSection.trailingAnchor.constraint(equalTo: formView.trailingAnchor),

            tagsSection.topAnchor.constraint(equalTo: aboutSection.bottomAnchor, constant: 20),
            tagsSection.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            tagsSection.trailingAnchor.constraint(equalTo: formView.trailingAnchor),

            allowCard.topAnchor.constraint(equalTo: tagsSection.bottomAnchor, constant: 22),
            allowCard.leadingAnchor.constraint(equalTo: formView.leadingAnchor),
            allowCard.trailingAnchor.constraint(equalTo: formView.trailingAnchor),
            allowCard.bottomAnchor.constraint(equalTo: formView.bottomAnchor)
        ])
    }

    private func configureBottomActionBar() {
        guard bottomActionBar.superview == nil else { return }
        bottomActionBar.translatesAutoresizingMaskIntoConstraints = false
        bottomActionBar.backgroundColor = JamoMainTheme.background

        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparator.backgroundColor = UIColor(red: 229 / 255, green: 224 / 255, blue: 214 / 255, alpha: 1)

        view.addSubview(bottomActionBar)
        bottomActionBar.addSubview(bottomSeparator)
        bottomActionBar.addSubview(publishButton)

        bottomActionBottomConstraint = bottomActionBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            bottomActionBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomActionBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomActionBottomConstraint!,
            bottomActionBar.heightAnchor.constraint(equalToConstant: PublishLayout.bottomActionHeight),

            bottomSeparator.topAnchor.constraint(equalTo: bottomActionBar.topAnchor),
            bottomSeparator.leadingAnchor.constraint(equalTo: bottomActionBar.leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: bottomActionBar.trailingAnchor),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1),

            publishButton.leadingAnchor.constraint(equalTo: bottomActionBar.leadingAnchor, constant: PublishLayout.horizontalInset),
            publishButton.trailingAnchor.constraint(equalTo: bottomActionBar.trailingAnchor, constant: -PublishLayout.horizontalInset),
            publishButton.bottomAnchor.constraint(equalTo: bottomActionBar.bottomAnchor, constant: -17)
        ])

        view.bringSubviewToFront(bottomActionBar)
        registerPublishKeyboardHandling()
    }

    private func registerPublishKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(publishKeyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(publishKeyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func publishKeyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let overlap = max(0, view.bounds.maxY - keyboardFrameInView.minY - view.safeAreaInsets.bottom)
        animateBottomActionBar(to: -overlap, notification: notification)
    }

    @objc private func publishKeyboardWillHide(_ notification: Notification) {
        animateBottomActionBar(to: 0, notification: notification)
    }

    private func animateBottomActionBar(to constant: CGFloat, notification: Notification) {
        bottomActionBottomConstraint?.constant = constant
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let options = UIView.AnimationOptions(rawValue: curveValue << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.view.layoutIfNeeded()
        }
    }

    private func applyPublishLayoutOverrides() {
        contentStack.spacing = PublishLayout.sectionSpacing
        contentView.constraints.forEach { constraint in
            guard constraint.firstItem === contentStack else { return }
            switch constraint.firstAttribute {
            case .top:
                constraint.constant = PublishLayout.contentTopInset
            case .leading:
                constraint.constant = PublishLayout.horizontalInset
            case .trailing:
                constraint.constant = -PublishLayout.horizontalInset
            case .bottom:
                constraint.constant = -PublishLayout.contentBottomInset
            default:
                break
            }
        }
    }

    private func makeTopBar() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let backButton = UIButton(type: .custom)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.backgroundColor = .white
        backButton.layer.cornerRadius = 20
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor(red: 226 / 255, green: 220 / 255, blue: 208 / 255, alpha: 1).cgColor
        backButton.setImage(UIImage(named: "jamo_cocreate_publish_back"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.accessibilityLabel = "Back"
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Publish"
        titleLabel.textColor = JamoMainTheme.ink
        titleLabel.font = JamoMainTheme.bodyFont(19, weight: .heavy)
        titleLabel.textAlignment = .center

        container.addSubview(backButton)
        container.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 40),
            backButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 12)
        ])

        return container
    }

    private func makeCoverSection() -> UIView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8

        stack.addArrangedSubview(makeFieldLabel("Cover"))

        coverCard.translatesAutoresizingMaskIntoConstraints = false
        coverCard.backgroundColor = JamoMainTheme.orange
        coverCard.layer.cornerRadius = PublishLayout.cardRadius
        coverCard.clipsToBounds = true

        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverCard.addSubview(coverImageView)

        coverPlaceholderIcon.translatesAutoresizingMaskIntoConstraints = false
        coverPlaceholderIcon.contentMode = .scaleAspectFit
        coverPlaceholderIcon.alpha = 0.26
        coverCard.addSubview(coverPlaceholderIcon)

        coverPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        coverPlaceholderLabel.text = "Tap or drop a photo to set the cover"
        coverPlaceholderLabel.textColor = UIColor.black.withAlphaComponent(0.26)
        coverPlaceholderLabel.font = JamoMainTheme.bodyFont(13.5, weight: .medium)
        coverPlaceholderLabel.textAlignment = .center
        coverCard.addSubview(coverPlaceholderLabel)

        uploadCoverButton.addTarget(self, action: #selector(uploadCoverTapped), for: .touchUpInside)
        coverCard.addSubview(uploadCoverButton)

        NSLayoutConstraint.activate([
            coverCard.heightAnchor.constraint(equalToConstant: 160),
            
            coverImageView.topAnchor.constraint(equalTo: coverCard.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: coverCard.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: coverCard.trailingAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: coverCard.bottomAnchor),
            coverPlaceholderIcon.centerXAnchor.constraint(equalTo: coverCard.centerXAnchor),
            coverPlaceholderIcon.centerYAnchor.constraint(equalTo: coverCard.centerYAnchor, constant: -12),
            coverPlaceholderIcon.widthAnchor.constraint(equalToConstant: 30),
            coverPlaceholderIcon.heightAnchor.constraint(equalTo: coverPlaceholderIcon.widthAnchor),
            coverPlaceholderLabel.topAnchor.constraint(equalTo: coverPlaceholderIcon.bottomAnchor, constant: 10),
            coverPlaceholderLabel.leadingAnchor.constraint(equalTo: coverCard.leadingAnchor, constant: 16),
            coverPlaceholderLabel.trailingAnchor.constraint(equalTo: coverCard.trailingAnchor, constant: -16),
            uploadCoverButton.trailingAnchor.constraint(equalTo: coverCard.trailingAnchor, constant: -12),
            uploadCoverButton.bottomAnchor.constraint(equalTo: coverCard.bottomAnchor, constant: -12),
            uploadCoverButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 126),
            uploadCoverButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        stack.addArrangedSubview(coverCard)
        return stack
    }

    private func makeAudioChoiceCard() -> UIView {
        let card = JamoCoCreatePublishDashedCardView(cornerRadius: PublishLayout.cardRadius)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = PublishLayout.cardRadius

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        card.addSubview(stack)

        let caption = UILabel()
        caption.text = "Record or upload your guitar part."
        caption.textAlignment = .center
        caption.textColor = JamoMainTheme.muted
        caption.font = JamoMainTheme.bodyFont(14, weight: .regular)
        stack.addArrangedSubview(caption)

        let buttons = UIStackView()
        buttons.axis = .horizontal
        buttons.spacing = 12
        buttons.distribution = .fillEqually
        let record = JamoCoCreatePublishAudioOptionButton(
            method: .recordGuitar,
            title: "Record",
            imageName: "jamo_cocreate_publish_record"
        )
        let upload = JamoCoCreatePublishAudioOptionButton(
            method: .uploadClip,
            title: "Upload",
            imageName: "jamo_cocreate_publish_upload_clip"
        )
        record.addTarget(self, action: #selector(audioMethodTapped(_:)), for: .touchUpInside)
        upload.addTarget(self, action: #selector(audioMethodTapped(_:)), for: .touchUpInside)
        audioButtons[.recordGuitar] = record
        audioButtons[.uploadClip] = upload
        buttons.addArrangedSubview(record)
        buttons.addArrangedSubview(upload)
        stack.addArrangedSubview(buttons)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])

        return card
    }

    private func makeAudioSection() -> UIView {
        switch audioState {
        case .choosing:
            return makeAudioChoiceCard()
        case .recording:
            return makeRecordingCard()
        case .clipReady:
            return makeSelectedAudioClipCard()
        case .clipTooShort:
            return makeClipTooShortCard()
        }
    }

    private func makeRecordingCard() -> UIView {
        let card = JamoCoCreatePublishDashedCardView(cornerRadius: PublishLayout.cardRadius)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Recording your guitar part"
        title.textColor = JamoMainTheme.ink
        title.font = JamoMainTheme.bodyFont(15, weight: .heavy)

        let elapsed = UILabel()
        elapsed.translatesAutoresizingMaskIntoConstraints = false
        elapsed.text = "0:00"
        elapsed.textColor = JamoMainTheme.orange
        elapsed.font = JamoMainTheme.bodyFont(15, weight: .heavy)
        recordingElapsedLabel = elapsed
        updateRecordingElapsed()

        let waveform = JamoCoCreatePublishWaveformView(seed: 8, tint: JamoMainTheme.orange)
        waveform.translatesAutoresizingMaskIntoConstraints = false

        let stopButton = JamoCoCreatePublishPlainButton(title: "Stop", background: JamoMainTheme.orange, foreground: JamoMainTheme.yellow)
        stopButton.addTarget(self, action: #selector(stopRecordingTapped), for: .touchUpInside)

        let cancelButton = JamoCoCreatePublishPlainButton(title: "Cancel", background: .white, foreground: JamoMainTheme.ink)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(red: 226 / 255, green: 220 / 255, blue: 208 / 255, alpha: 1).cgColor
        cancelButton.addTarget(self, action: #selector(cancelRecordingTapped), for: .touchUpInside)

        card.addSubview(title)
        card.addSubview(elapsed)
        card.addSubview(waveform)
        card.addSubview(stopButton)
        card.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            elapsed.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            elapsed.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            title.trailingAnchor.constraint(lessThanOrEqualTo: elapsed.leadingAnchor, constant: -12),

            waveform.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 14),
            waveform.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            waveform.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            waveform.heightAnchor.constraint(equalToConstant: 28),

            stopButton.topAnchor.constraint(equalTo: waveform.bottomAnchor, constant: 16),
            stopButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28),
            stopButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
            stopButton.heightAnchor.constraint(equalToConstant: 44),

            cancelButton.leadingAnchor.constraint(equalTo: stopButton.trailingAnchor, constant: 12),
            cancelButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -28),
            cancelButton.centerYAnchor.constraint(equalTo: stopButton.centerYAnchor),
            cancelButton.widthAnchor.constraint(equalTo: stopButton.widthAnchor),
            cancelButton.heightAnchor.constraint(equalTo: stopButton.heightAnchor)
        ])
        return card
    }

    private func makeSelectedAudioClipCard() -> UIView {
        let snapshot = viewModel.makeSnapshot()
        let form = snapshot.form
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = PublishLayout.cardRadius
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(red: 226 / 255, green: 220 / 255, blue: 208 / 255, alpha: 1).cgColor

        let thumb = UIImageView()
        thumb.translatesAutoresizingMaskIntoConstraints = false
        thumb.image = publishCoverImage(snapshot) ?? UIImage(named: "jamo_cocreate_publish_audio_thumb")
        thumb.contentMode = .scaleAspectFill
        thumb.clipsToBounds = true
        thumb.layer.cornerRadius = 12
        thumb.backgroundColor = JamoMainTheme.orange

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = form.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Warm Sunset Riff" : form.title
        title.textColor = JamoMainTheme.ink
        title.font = JamoMainTheme.bodyFont(13.5, weight: .heavy)

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = "My Guitar Part · \(form.roleName)"
        subtitle.textColor = JamoMainTheme.pink
        subtitle.font = JamoMainTheme.bodyFont(10.5, weight: .heavy)

        let waveform = JamoCoCreatePublishWaveformView(seed: form.waveformSeed, tint: JamoMainTheme.orange)
        waveform.translatesAutoresizingMaskIntoConstraints = false

        let resetButton = UIButton(type: .system)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("Change", for: .normal)
        resetButton.setTitleColor(JamoMainTheme.muted, for: .normal)
        resetButton.titleLabel?.font = JamoMainTheme.bodyFont(11, weight: .semibold)
        resetButton.addTarget(self, action: #selector(resetAudioTapped), for: .touchUpInside)

        card.addSubview(thumb)
        card.addSubview(title)
        card.addSubview(subtitle)
        card.addSubview(waveform)
        card.addSubview(resetButton)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 86),
            thumb.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            thumb.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            thumb.widthAnchor.constraint(equalToConstant: 62),
            thumb.heightAnchor.constraint(equalToConstant: 62),

            resetButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            resetButton.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            resetButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 54),

            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: thumb.trailingAnchor, constant: 14),
            title.trailingAnchor.constraint(lessThanOrEqualTo: resetButton.leadingAnchor, constant: -8),

            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            waveform.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            waveform.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            waveform.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -13),
            waveform.heightAnchor.constraint(equalToConstant: 20)
        ])
        return card
    }

    private func makeClipTooShortCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor(red: 255 / 255, green: 232 / 255, blue: 238 / 255, alpha: 1)
        card.layer.cornerRadius = 16
        card.layer.cornerCurve = .continuous

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Clip is too short"
        title.textColor = JamoMainTheme.ink
        title.font = JamoMainTheme.bodyFont(13.5, weight: .heavy)

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = "Please add at least 3 seconds."
        subtitle.textColor = JamoMainTheme.muted
        subtitle.font = JamoMainTheme.bodyFont(11.5)

        let retry = JamoCoCreatePublishPlainButton(title: "Try Again", background: JamoMainTheme.orange, foreground: JamoMainTheme.yellow)
        retry.addTarget(self, action: #selector(resetAudioTapped), for: .touchUpInside)

        card.addSubview(title)
        card.addSubview(subtitle)
        card.addSubview(retry)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            retry.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 14),
            retry.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            retry.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            retry.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            retry.heightAnchor.constraint(equalToConstant: 44)
        ])
        return card
    }

    private func makeTitleSection() -> UIView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 10
        stack.addArrangedSubview(makeFieldLabel("Title"))
        stack.addArrangedSubview(titleField)
        stack.addArrangedSubview(validationLabel)
        return stack
    }

    private func makeAboutSection() -> UIView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 10
        stack.addArrangedSubview(makeFieldLabel("About"))
        stack.addArrangedSubview(aboutTextView)
        NSLayoutConstraint.activate([
            aboutTextView.heightAnchor.constraint(equalToConstant: 92)
        ])
        return stack
    }

    private func makeTagsSection() -> UIView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.addArrangedSubview(makeFieldLabel("Tags"))

        let firstRow = makeTagRow(["Acoustic", "Fingerstyle", "Lead"])
        let secondRow = makeTagRow(["Chords", "Jam"])
        stack.addArrangedSubview(firstRow)
        stack.addArrangedSubview(secondRow)
        return stack
    }

    private func makeTagRow(_ tags: [String]) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .leading
        tags.forEach { tag in
            let button = JamoCoCreatePublishTagButton(title: tag)
            button.addTarget(self, action: #selector(tagTapped(_:)), for: .touchUpInside)
            tagButtons[tag] = button
            row.addArrangedSubview(button)
        }
        row.addArrangedSubview(UIView())
        return row
    }

    private func makeAllowContinueCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = PublishLayout.cardRadius
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.black.withAlphaComponent(0.05).cgColor

        let icon = UIImageView(image: UIImage(named: "jamo_cocreate_publish_allow_continue"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        let textStack = UIStackView()
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 2

        let title = UILabel()
        title.text = "Allow others to continue"
        title.textColor = JamoMainTheme.ink
        title.font = JamoMainTheme.bodyFont(14.5, weight: .heavy)
        title.numberOfLines = 1

        let subtitle = UILabel()
        subtitle.text = "Let friends add the next part."
        subtitle.textColor = JamoMainTheme.muted
        subtitle.font = JamoMainTheme.bodyFont(12, weight: .regular)
        subtitle.numberOfLines = 1

        textStack.addArrangedSubview(title)
        textStack.addArrangedSubview(subtitle)
        allowSwitch.translatesAutoresizingMaskIntoConstraints = false
        allowSwitch.addTarget(self, action: #selector(allowSwitchChanged), for: .valueChanged)

        card.addSubview(icon)
        card.addSubview(textStack)
        card.addSubview(allowSwitch)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 72),
            icon.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            icon.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 38),
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor),
            textStack.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 14),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: allowSwitch.leadingAnchor, constant: -10),
            allowSwitch.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            allowSwitch.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        return card
    }

    private func makeFieldLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = JamoMainTheme.ink
        label.font = JamoMainTheme.titleFont(13.5)
        return label
    }

    private func centered(_ view: UIView) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        let width = view.widthAnchor.constraint(equalTo: container.widthAnchor)
        width.priority = .defaultLow
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            view.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor),
            view.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
            view.widthAnchor.constraint(lessThanOrEqualToConstant: PublishLayout.maxContentWidth),
            width
        ])
        return container
    }

    private func applySnapshot(_ snapshot: JamoCoCreatePublishSnapshot, refreshText: Bool) {
        self.snapshot = snapshot
        if refreshText || !titleField.isFirstResponder {
            titleField.text = snapshot.form.title
        }
        if refreshText || !aboutTextView.isFirstResponder {
            aboutTextView.text = snapshot.form.about
            aboutTextView.updatePlaceholder()
        }
        applyCover(snapshot)
        applyTags(snapshot.form.tags)
        applyAudioMethod(snapshot.form.selectedJoinMethod)
        allowSwitch.setOn(snapshot.form.allowContinue, animated: false)
        applyValidation(snapshot)
        applyPrimaryAction(snapshot)
    }

    private func applyCover(_ snapshot: JamoCoCreatePublishSnapshot) {
        let shouldShowImage = hasSelectedCover || snapshot.source != nil || sourceWork?.status == .draft
        let image = publishCoverImage(snapshot) ?? UIImage(named: "jamo_cocreate_publish_work_cover")
        coverImageView.image = shouldShowImage ? image : nil
        coverImageView.isHidden = !shouldShowImage
        coverPlaceholderIcon.isHidden = shouldShowImage
        coverPlaceholderLabel.isHidden = shouldShowImage
        coverCard.backgroundColor = shouldShowImage ? UIColor.black.withAlphaComponent(0.06) : JamoMainTheme.orange
    }

    private func publishCoverImage(_ snapshot: JamoCoCreatePublishSnapshot) -> UIImage? {
        if let coverURL = snapshot.form.coverURL,
           let url = URL(string: coverURL),
           url.isFileURL,
           let image = UIImage(contentsOfFile: url.path) {
            return image
        }
        return UIImage.jamoCoCreateMedia(named: snapshot.form.coverImageName)
    }

    private func applyTags(_ selectedTags: [String]) {
        let selectedKeys = Set(selectedTags.map { $0.lowercased() })
        tagButtons.forEach { tag, button in
            button.isSelected = selectedKeys.contains(tag.lowercased())
        }
    }

    private func applyAudioMethod(_ selectedMethod: JamoCoCreateJoinMethod?) {
        audioButtons.forEach { method, button in
            button.isSelected = method == selectedMethod
        }
    }

    private func applyValidation(_ snapshot: JamoCoCreatePublishSnapshot) {
        validationLabel.text = snapshot.validationMessage
        validationLabel.isHidden = snapshot.validationMessage == nil
        let hasTitleError = snapshot.state == .missingTitle
        titleField.layer.borderWidth = hasTitleError ? 1.2 : 1
        titleField.layer.borderColor = hasTitleError
            ? UIColor(red: 229 / 255, green: 68 / 255, blue: 78 / 255, alpha: 1).cgColor
            : UIColor(red: 226 / 255, green: 220 / 255, blue: 208 / 255, alpha: 1).cgColor
    }

    private func applyPrimaryAction(_ snapshot: JamoCoCreatePublishSnapshot) {
        let action = snapshot.primaryAction
        publishButton.isEnabled = action.isEnabled && snapshot.state != .publishing && !isCompletingPublish
        let sparkleName = action.isEnabled ? "jamo_cocreate_publish_sparkle" : "jamo_cocreate_publish_sparkle_disabled"
        var foreground: UIColor
        var background: UIColor
        switch action.style {
        case .orange:
            background = JamoMainTheme.orange
            foreground = JamoMainTheme.yellow
        case .black:
            background = JamoMainTheme.ink
            foreground = JamoMainTheme.pink
        case .disabled:
            background = UIColor(red: 235 / 255, green: 232 / 255, blue: 224 / 255, alpha: 1)
            foreground = UIColor(red: 188 / 255, green: 183 / 255, blue: 172 / 255, alpha: 1)
        }

        var configuration = UIButton.Configuration.plain()
        var attributedTitle = AttributedString(action.title)
        attributedTitle.font = JamoMainTheme.bodyFont(18, weight: .heavy)
        attributedTitle.foregroundColor = foreground
        configuration.attributedTitle = attributedTitle
        configuration.image = snapshot.state == .publishing ? nil : UIImage(named: sparkleName)
        configuration.imagePlacement = .leading
        configuration.imagePadding = 6
        configuration.baseForegroundColor = foreground
        configuration.background.backgroundColor = background
        configuration.background.cornerRadius = PublishLayout.primaryButtonHeight / 2
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
        publishButton.configuration = configuration

        if snapshot.state == .publishing || isCompletingPublish {
            publishActivity.startAnimating()
        } else {
            publishActivity.stopAnimating()
        }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func uploadCoverTapped() {
        let sheet = UIAlertController(title: "Upload cover", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sheet.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                self?.presentCoverPicker(sourceType: .camera)
            })
        }
        sheet.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.presentCoverPicker(sourceType: .photoLibrary)
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = uploadCoverButton
            popover.sourceRect = uploadCoverButton.bounds
        }
        sheet.jamoApplyTheme()
        present(sheet, animated: true)
    }

    @objc private func audioMethodTapped(_ sender: JamoCoCreatePublishAudioOptionButton) {
        let method = sender.method
        switch method {
        case .recordGuitar:
            requestMicrophoneAndBeginRecording()
        case .uploadClip:
            presentAudioDocumentPicker()
        case .addChords, .addMelody:
            break
        }
    }

    private func presentCoverPicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            JamoAuthToastView.show(on: view, message: "This cover source is unavailable.")
            return
        }
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    private func applySelectedCover(_ image: UIImage) {
        do {
            let fileURL = try saveCoverImage(image)
            hasSelectedCover = true
            applySnapshot(
                viewModel.updateCover(imageName: fileURL.lastPathComponent, coverURL: fileURL.absoluteString),
                refreshText: false
            )
            buildPage()
            applySnapshot(viewModel.makeSnapshot(), refreshText: false)
            JamoAuthToastView.show(on: view, message: "Cover selected.")
        } catch {
            JamoAuthToastView.show(on: view, message: "Unable to save this cover.")
        }
    }

    private func requestMicrophoneAndBeginRecording() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard let self else { return }
                guard granted else {
                    JamoAuthToastView.show(on: self.view, message: "Microphone access is needed to record.")
                    return
                }
                self.beginRealRecording()
            }
        }
    }

    private func beginRealRecording() {
        do {
            let audioURL = try makeLocalAudioURL(fileExtension: "m4a")
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
            recorder.record()
            audioRecorder = recorder
            activeRecordingURL = audioURL
            audioState = .recording
            buildPage()
            applySnapshot(viewModel.makeSnapshot(), refreshText: false)
            startRecordingTimer()
        } catch {
            JamoAuthToastView.show(on: view, message: "Unable to start recording.")
        }
    }

    @objc private func stopRecordingTapped() {
        let duration = currentRecordingDuration()
        audioRecorder?.stop()
        audioRecorder = nil
        stopRecordingTimer()
        guard let activeRecordingURL else {
            audioState = .choosing
            buildPage()
            applySnapshot(viewModel.makeSnapshot(), refreshText: false)
            return
        }
        finishAudioClip(url: activeRecordingURL, method: .recordGuitar, duration: duration, waveformSeed: 8)
    }

    @objc private func cancelRecordingTapped() {
        audioRecorder?.stop()
        audioRecorder = nil
        stopRecordingTimer()
        if let activeRecordingURL {
            try? FileManager.default.removeItem(at: activeRecordingURL)
        }
        activeRecordingURL = nil
        audioState = .choosing
        buildPage()
        applySnapshot(viewModel.makeSnapshot(), refreshText: false)
    }

    @objc private func resetAudioTapped() {
        audioState = .choosing
        buildPage()
        applySnapshot(viewModel.makeSnapshot(), refreshText: false)
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
            finishAudioClip(url: copiedURL, method: .uploadClip, duration: duration, waveformSeed: 10)
        } catch {
            JamoAuthToastView.show(on: view, message: "Unable to use this audio file.")
        }
    }

    private func finishAudioClip(url: URL, method: JamoCoCreateJoinMethod, duration: TimeInterval, waveformSeed: Int) {
        activeRecordingURL = nil
        guard duration >= JamoCoCreateEditorViewModel.minimumClipDuration else {
            try? FileManager.default.removeItem(at: url)
            audioState = .clipTooShort
            buildPage()
            applySnapshot(viewModel.makeSnapshot(), refreshText: false)
            return
        }

        let snapshot = viewModel.updateLocalAudio(
            mp3FileName: url.lastPathComponent,
            duration: duration,
            waveformSeed: waveformSeed,
            roleName: method.trackTitle,
            role: method.trackRole,
            joinMethod: method
        )
        audioState = .clipReady(method: method, duration: duration, waveformSeed: waveformSeed)
        buildPage()
        applySnapshot(snapshot, refreshText: false)
        if snapshot.form.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            applySnapshot(viewModel.beginPublishing(), refreshText: false)
        }
        JamoAuthToastView.show(on: view, message: method == .recordGuitar ? "Recording added." : "Audio clip added.")
    }

    private func saveCoverImage(_ image: UIImage) throws -> URL {
        let directory = try localMediaDirectory(named: "JamoCoCreateCoverCache")
        let fileURL = directory.appendingPathComponent("jamo_cocreate_local_cover_\(UUID().uuidString).jpg")
        let normalized = normalizedCoverImage(image)
        guard let data = normalized.jpegData(compressionQuality: 0.84) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try data.write(to: fileURL, options: [.atomic])
        return fileURL
    }

    private func normalizedCoverImage(_ image: UIImage) -> UIImage {
        let targetSize = CGSize(width: 1200, height: 580)
        let sourceSize = image.size
        let scale = max(targetSize.width / max(sourceSize.width, 1), targetSize.height / max(sourceSize.height, 1))
        let drawSize = CGSize(width: sourceSize.width * scale, height: sourceSize.height * scale)
        let origin = CGPoint(x: (targetSize.width - drawSize.width) / 2, y: (targetSize.height - drawSize.height) / 2)
        return UIGraphicsImageRenderer(size: targetSize).image { _ in
            image.draw(in: CGRect(origin: origin, size: drawSize))
        }
    }

    private func makeLocalAudioURL(fileExtension: String) throws -> URL {
        let directory = try localMediaDirectory(named: "JamoCoCreateAudioCache")
        return directory.appendingPathComponent("jamo_cocreate_local_audio_\(UUID().uuidString).\(fileExtension)")
    }

    private func copyPickedAudioToLocalCache(_ url: URL) throws -> URL {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }
        let fileExtension = url.pathExtension.isEmpty ? "m4a" : url.pathExtension
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

    private func startRecordingTimer() {
        recordingStartDate = Date()
        recordingTimer?.invalidate()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.updateRecordingElapsed()
        }
        if let recordingTimer {
            RunLoop.main.add(recordingTimer, forMode: .common)
        }
        updateRecordingElapsed()
    }

    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingStartDate = nil
        recordingElapsedLabel = nil
    }

    private func updateRecordingElapsed() {
        let duration = currentRecordingDuration()
        recordingElapsedLabel?.text = durationText(duration)
    }

    private func currentRecordingDuration() -> TimeInterval {
        guard let recordingStartDate else { return 0 }
        return max(Date().timeIntervalSince(recordingStartDate), 0)
    }

    private func durationText(_ duration: TimeInterval) -> String {
        let seconds = max(Int(duration.rounded()), 0)
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    @objc private func tagTapped(_ sender: JamoCoCreatePublishTagButton) {
        let currentTags = snapshot?.form.tags ?? []
        if sender.isSelected && currentTags.count <= 1 {
            JamoAuthToastView.show(on: view, message: "Keep at least one tag selected.")
            return
        }
        applySnapshot(viewModel.setTag(sender.tagTitle, isSelected: !sender.isSelected), refreshText: false)
    }

    @objc private func allowSwitchChanged() {
        applySnapshot(viewModel.updateAllowContinue(allowSwitch.isOn), refreshText: false)
    }

    @objc private func titleChanged() {
        applySnapshot(viewModel.updateTitle(titleField.text ?? ""), refreshText: false)
    }

    @objc private func publishTapped() {
        guard let snapshot else { return }
        if snapshot.state == .publishedSuccess {
            guard let work = snapshot.publishedWork else { return }
            navigationController?.pushViewController(JamoCoCreateDetailViewController(work: work), animated: true)
            return
        }

        if snapshot.state == .publishFailed {
            applySnapshot(viewModel.resetToEditing(), refreshText: false)
        }

        let publishingSnapshot = viewModel.beginPublishing()
        applySnapshot(publishingSnapshot, refreshText: false)
        guard publishingSnapshot.state == .publishing else {
            if let message = publishingSnapshot.validationMessage {
                JamoAuthToastView.show(on: view, message: message)
            }
            titleField.becomeFirstResponder()
            return
        }

        isCompletingPublish = true
        applyPrimaryAction(publishingSnapshot)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            guard let self else { return }
            self.isCompletingPublish = false
#if DEBUG
            if self.shouldSimulatePublishFailure {
                self.applySnapshot(self.viewModel.markPublishFailed(), refreshText: false)
                return
            }
#endif
            let result = self.viewModel.completeLocalPublish()
            self.applySnapshot(result, refreshText: false)
            guard let work = result.publishedWork else {
                self.applySnapshot(self.viewModel.markPublishFailed(), refreshText: false)
                return
            }
            self.navigationController?.pushViewController(JamoCoCreatePublishSuccessViewController(work: work), animated: true)
        }
    }

#if DEBUG
    func jamoDebugSetPublishFailureEnabled(_ enabled: Bool) {
        shouldSimulatePublishFailure = enabled
    }
#endif

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        aboutTextView.becomeFirstResponder()
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        aboutTextView.updatePlaceholder()
        _ = viewModel.updateAbout(textView.text ?? "")
    }
}

extension JamoCoCreatePublishViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
        picker.dismiss(animated: true) { [weak self] in
            guard let self, let image else {
                self?.view.map { JamoAuthToastView.show(on: $0, message: "Unable to use this cover.") }
                return
            }
            self.applySelectedCover(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension JamoCoCreatePublishViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        finishPickedAudio(url: url)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {}
}

extension JamoCoCreatePublishViewController: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        audioRecorder = nil
        stopRecordingTimer()
        audioState = .choosing
        buildPage()
        applySnapshot(viewModel.makeSnapshot(), refreshText: false)
        JamoAuthToastView.show(on: view, message: "Recording failed. Please try again.")
    }
}

private final class JamoCoCreatePublishPlainButton: UIButton {
    init(title: String, background: UIColor, foreground: UIColor) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(title, for: .normal)
        setTitleColor(foreground, for: .normal)
        titleLabel?.font = JamoMainTheme.bodyFont(14, weight: .heavy)
        backgroundColor = background
        layer.cornerRadius = 22
        layer.cornerCurve = .continuous
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class JamoCoCreatePublishWaveformView: UIView {
    private let seed: Int
    private let tint: UIColor

    init(seed: Int, tint: UIColor) {
        self.seed = max(seed, 1)
        self.tint = tint
        super.init(frame: .zero)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), rect.width > 0, rect.height > 0 else { return }
        context.setStrokeColor(tint.cgColor)
        context.setLineCap(.round)
        context.setLineWidth(3)

        let bars = 34
        let step = rect.width / CGFloat(max(bars - 1, 1))
        for index in 0..<bars {
            let value = CGFloat(((index * 17 + seed * 11) % 10) + 3) / 13
            let height = max(5, rect.height * value)
            let x = CGFloat(index) * step
            let y1 = rect.midY - height / 2
            let y2 = rect.midY + height / 2
            context.move(to: CGPoint(x: x, y: y1))
            context.addLine(to: CGPoint(x: x, y: y2))
        }
        context.strokePath()
    }
}

private final class JamoCoCreatePublishDashedCardView: UIView {
    private let dashedBorderLayer = CAShapeLayer()
    private let radius: CGFloat

    init(cornerRadius: CGFloat) {
        self.radius = cornerRadius
        super.init(frame: .zero)
        layer.cornerRadius = cornerRadius
        layer.cornerCurve = .continuous
        layer.addSublayer(dashedBorderLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dashedBorderLayer.frame = bounds
        dashedBorderLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: radius
        ).cgPath
        dashedBorderLayer.fillColor = UIColor.clear.cgColor
        dashedBorderLayer.strokeColor = UIColor(red: 211 / 255, green: 202 / 255, blue: 187 / 255, alpha: 1).cgColor
        dashedBorderLayer.lineWidth = 1
        dashedBorderLayer.lineDashPattern = [4, 3]
    }
}

private final class JamoCoCreatePublishTextField: UITextField {
    init(placeholder: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 226 / 255, green: 220 / 255, blue: 208 / 255, alpha: 1).cgColor
        clipsToBounds = true
        font = JamoMainTheme.bodyFont(15.5, weight: .medium)
        textColor = JamoMainTheme.ink
        returnKeyType = .next
        clearButtonMode = .whileEditing
        autocapitalizationType = .sentences
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.black.withAlphaComponent(0.32),
                .font: JamoMainTheme.bodyFont(15.5, weight: .regular)
            ]
        )
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 17, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 17, dy: 0)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 17, dy: 0)
    }
}

private final class JamoCoCreatePublishTextView: UITextView {
    private let placeholderLabel = UILabel()

    init(placeholder: String) {
        super.init(frame: .zero, textContainer: nil)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 226 / 255, green: 220 / 255, blue: 208 / 255, alpha: 1).cgColor
        clipsToBounds = true
        font = JamoMainTheme.bodyFont(15.5, weight: .regular)
        textColor = JamoMainTheme.ink
        textContainerInset = UIEdgeInsets(top: 15, left: 17, bottom: 14, right: 17)
        textContainer.lineFragmentPadding = 0
        isScrollEnabled = false

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.text = placeholder
        placeholderLabel.textColor = UIColor.black.withAlphaComponent(0.32)
        placeholderLabel.font = JamoMainTheme.bodyFont(15.5, weight: .regular)
        placeholderLabel.numberOfLines = 0
        addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -17)
        ])
        updatePlaceholder()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updatePlaceholder() {
        placeholderLabel.isHidden = !(text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

private final class JamoCoCreatePublishSmallActionButton: UIButton {
    init(title: String, imageName: String, background: UIColor, foreground: UIColor) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(title, for: .normal)
        setTitleColor(foreground, for: .normal)
        setImage(UIImage(named: imageName), for: .normal)
        titleLabel?.font = JamoMainTheme.bodyFont(12.5, weight: .heavy)
        layer.cornerRadius = 21
        semanticContentAttribute = .forceLeftToRight

        var configuration = UIButton.Configuration.plain()
        var attributedTitle = AttributedString(title)
        attributedTitle.font = JamoMainTheme.bodyFont(12.5, weight: .heavy)
        attributedTitle.foregroundColor = foreground
        configuration.attributedTitle = attributedTitle
        configuration.image = UIImage(named: imageName)
        configuration.imagePlacement = .leading
        configuration.imagePadding = 6
        configuration.baseForegroundColor = foreground
        configuration.background.backgroundColor = background
        configuration.background.cornerRadius = 21
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14)
        self.configuration = configuration
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class JamoCoCreatePublishAudioOptionButton: UIControl {
    let method: JamoCoCreateJoinMethod

    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    override var isSelected: Bool {
        didSet { updateAppearance() }
    }

    init(method: JamoCoCreateJoinMethod, title: String, imageName: String) {
        self.method = method
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 22
        layer.cornerCurve = .continuous
        layer.borderWidth = 1

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(named: imageName)
        iconView.contentMode = .scaleAspectFit
        iconView.isUserInteractionEnabled = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = JamoMainTheme.bodyFont(16, weight: .heavy)
        titleLabel.isUserInteractionEnabled = false

        addSubview(iconView)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 48),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12)
        ])
        updateAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateAppearance() {
        backgroundColor = isSelected ? JamoMainTheme.orange : .white
        layer.borderColor = (isSelected ? JamoMainTheme.orange : UIColor.black.withAlphaComponent(0.08)).cgColor
        titleLabel.textColor = isSelected ? JamoMainTheme.yellow : JamoMainTheme.ink
    }
}

private final class JamoCoCreatePublishTagButton: UIControl {
    let tagTitle: String

    private let label = UILabel()

    override var isSelected: Bool {
        didSet { updateAppearance() }
    }

    init(title: String) {
        self.tagTitle = title
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 18
        layer.cornerCurve = .continuous
        layer.borderWidth = 1

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = JamoMainTheme.bodyFont(14, weight: .heavy)
        label.isUserInteractionEnabled = false
        addSubview(label)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 38),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        updateAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateAppearance() {
        backgroundColor = isSelected ? JamoMainTheme.ink : .white
        layer.borderColor = (isSelected ? JamoMainTheme.ink : UIColor.black.withAlphaComponent(0.08)).cgColor
        label.textColor = isSelected ? JamoMainTheme.yellow : JamoMainTheme.muted
    }
}

private final class JamoCoCreatePublishSourceCardView: UIView {
    init(source: JamoCoCreatePublishSourceDisplay, currentUser: JamoCoCreateUserProfile) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)

        let avatar = UILabel()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.text = initials(for: currentUser.displayName)
        avatar.textAlignment = .center
        avatar.textColor = .white
        avatar.font = JamoMainTheme.bodyFont(12, weight: .heavy)
        avatar.backgroundColor = JamoMainTheme.orange
        avatar.layer.cornerRadius = 24
        avatar.clipsToBounds = true

        let cover = UIImageView(image: UIImage.jamoCoCreateMedia(named: source.coverImageName) ?? UIImage(named: "jamo_cocreate_publish_audio_thumb"))
        cover.translatesAutoresizingMaskIntoConstraints = false
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true
        cover.layer.cornerRadius = 12

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = source.title.isEmpty ? "Warm Sunset Riff" : source.title
        title.textColor = JamoMainTheme.ink
        title.font = JamoMainTheme.bodyFont(13, weight: .heavy)
        title.numberOfLines = 1

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = "My Guitar Part · \(source.partTitle)"
        subtitle.textColor = JamoMainTheme.pink
        subtitle.font = JamoMainTheme.bodyFont(10.5, weight: .heavy)
        subtitle.numberOfLines = 1

        let waveform = UIImageView(image: UIImage(named: "jamo_cocreate_publish_waveform"))
        waveform.translatesAutoresizingMaskIntoConstraints = false
        waveform.contentMode = .scaleAspectFill
        waveform.clipsToBounds = true

        let textStack = UIStackView(arrangedSubviews: [title, subtitle, waveform])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 5

        addSubview(cover)
        addSubview(avatar)
        addSubview(textStack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 86),
            cover.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            cover.centerYAnchor.constraint(equalTo: centerYAnchor),
            cover.widthAnchor.constraint(equalToConstant: 58),
            cover.heightAnchor.constraint(equalTo: cover.widthAnchor),
            avatar.leadingAnchor.constraint(equalTo: cover.leadingAnchor, constant: 6),
            avatar.bottomAnchor.constraint(equalTo: cover.bottomAnchor, constant: -6),
            avatar.widthAnchor.constraint(equalToConstant: 32),
            avatar.heightAnchor.constraint(equalTo: avatar.widthAnchor),
            textStack.leadingAnchor.constraint(equalTo: cover.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            textStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            waveform.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initials(for name: String) -> String {
        let parts = name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
        let value = String(parts).uppercased()
        return value.isEmpty ? "J" : value
    }
}

final class JamoCoCreatePublishSuccessViewController: UIViewController {
    private enum SuccessLayout {
        static let maxContentWidth: CGFloat = 390
    }

    private let work: JamoCoCreateWork
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()
    private let backButton = UIButton(type: .custom)
    private var noFriendsSheet: JamoCoCreateNoFriendsSheetView?

    init(work: JamoCoCreateWork) {
        self.work = work
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = JamoMainTheme.orange
        buildLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    private func buildLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 18
        backButton.setImage(UIImage(named: "jamo_cocreate_publish_back")?.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.backgroundColor = .white
        backButton.layer.cornerRadius = 22
        backButton.layer.cornerCurve = .continuous
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor(red: 226 / 255, green: 220 / 255, blue: 208 / 255, alpha: 1).cgColor
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.accessibilityLabel = "Back to co-create detail"
        backButton.addTarget(self, action: #selector(backToDetailTapped), for: .touchUpInside)

        view.addSubview(scrollView)
        view.addSubview(backButton)
        scrollView.addSubview(contentView)
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 58),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            stack.widthAnchor.constraint(lessThanOrEqualToConstant: SuccessLayout.maxContentWidth)
        ])

        stack.addArrangedSubview(makeSuccessIcon())
        stack.setCustomSpacing(12, after: stack.arrangedSubviews.last!)
        stack.addArrangedSubview(makeTitleLabel("Co-created!", size: 25, color: .white))
        stack.setCustomSpacing(2, after: stack.arrangedSubviews.last!)
        stack.addArrangedSubview(makeSubtitleLabel("Your guitar part has been added to\nthe chain."))
        stack.setCustomSpacing(34, after: stack.arrangedSubviews.last!)
        stack.addArrangedSubview(makeSuccessWorkCard())
        stack.setCustomSpacing(70, after: stack.arrangedSubviews.last!)
        stack.addArrangedSubview(makeViewWorkButton())
        stack.addArrangedSubview(makeSecondaryActions())
    }

    private func makeSuccessIcon() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = JamoMainTheme.yellow
        container.layer.cornerRadius = 34

        let check = UIImageView(image: UIImage(named: "jamo_cocreate_publish_success_check"))
        check.translatesAutoresizingMaskIntoConstraints = false
        check.contentMode = .scaleAspectFit
        container.addSubview(check)

        let sparkleSmall = UIImageView(image: UIImage(named: "jamo_cocreate_publish_success_sparkle_small"))
        sparkleSmall.translatesAutoresizingMaskIntoConstraints = false
        sparkleSmall.contentMode = .scaleAspectFit
        container.addSubview(sparkleSmall)

        let sparkleLarge = UIImageView(image: UIImage(named: "jamo_cocreate_publish_success_sparkle_large"))
        sparkleLarge.translatesAutoresizingMaskIntoConstraints = false
        sparkleLarge.contentMode = .scaleAspectFit
        container.addSubview(sparkleLarge)

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 68),
            container.heightAnchor.constraint(equalTo: container.widthAnchor),
            check.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            check.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            check.widthAnchor.constraint(equalToConstant: 32),
            check.heightAnchor.constraint(equalTo: check.widthAnchor),
            sparkleSmall.trailingAnchor.constraint(equalTo: container.leadingAnchor, constant: -2),
            sparkleSmall.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: 14),
            sparkleSmall.widthAnchor.constraint(equalToConstant: 18),
            sparkleSmall.heightAnchor.constraint(equalTo: sparkleSmall.widthAnchor),
            sparkleLarge.leadingAnchor.constraint(equalTo: container.trailingAnchor, constant: 4),
            sparkleLarge.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
            sparkleLarge.widthAnchor.constraint(equalToConstant: 22),
            sparkleLarge.heightAnchor.constraint(equalTo: sparkleLarge.widthAnchor)
        ])

        return container
    }

    private func makeTitleLabel(_ text: String, size: CGFloat, color: UIColor) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textAlignment = .center
        label.textColor = color
        label.font = JamoMainTheme.titleFont(size)
        label.numberOfLines = 0
        return label
    }

    private func makeSubtitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textAlignment = .center
        label.textColor = .white.withAlphaComponent(0.86)
        label.font = JamoMainTheme.bodyFont(13, weight: .semibold)
        label.numberOfLines = 0
        return label
    }

    private func makeSuccessWorkCard() -> UIView {
        let latestWork = currentWork()
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 14
        card.layer.cornerCurve = .continuous
        card.clipsToBounds = true

        let cover = UIImageView(image: UIImage.jamoCoCreateMedia(named: latestWork.coverImageName) ?? UIImage(named: "jamo_cocreate_publish_success_cover"))
        cover.translatesAutoresizingMaskIntoConstraints = false
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = latestWork.title
        title.textColor = JamoMainTheme.ink
        title.font = JamoMainTheme.bodyFont(13, weight: .heavy)
        title.numberOfLines = 1

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        let partName = latestWork.tracks.last?.roleName ?? "Lead"
        subtitle.text = "My Guitar Part · \(partName)"
        subtitle.textColor = JamoMainTheme.pink
        subtitle.font = JamoMainTheme.bodyFont(10.5, weight: .heavy)
        subtitle.numberOfLines = 1

        let waveform = UIImageView(image: UIImage(named: "jamo_cocreate_publish_success_waveform"))
        waveform.translatesAutoresizingMaskIntoConstraints = false
        waveform.contentMode = .scaleAspectFill
        waveform.clipsToBounds = true

        card.addSubview(cover)
        card.addSubview(title)
        card.addSubview(subtitle)
        card.addSubview(waveform)

        NSLayoutConstraint.activate([
            card.widthAnchor.constraint(equalToConstant: 224),
            card.heightAnchor.constraint(equalToConstant: 138),
            cover.topAnchor.constraint(equalTo: card.topAnchor),
            cover.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            cover.heightAnchor.constraint(equalToConstant: 76),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            title.topAnchor.constraint(equalTo: cover.bottomAnchor, constant: 10),
            subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 3),
            waveform.leadingAnchor.constraint(equalTo: subtitle.trailingAnchor, constant: 8),
            waveform.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            waveform.centerYAnchor.constraint(equalTo: subtitle.centerYAnchor),
            waveform.heightAnchor.constraint(equalToConstant: 18),
            waveform.widthAnchor.constraint(greaterThanOrEqualToConstant: 54)
        ])

        return card
    }

    private func makeViewWorkButton() -> UIButton {
        let button = JamoCoCreatePublishSuccessButton(
            title: "View Work",
            imageName: "jamo_cocreate_publish_view_work_play",
            background: JamoMainTheme.yellow,
            foreground: JamoMainTheme.orange
        )
        button.addTarget(self, action: #selector(viewWorkTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 228),
            button.heightAnchor.constraint(equalToConstant: 52)
        ])
        return button
    }

    private func makeSecondaryActions() -> UIView {
        let row = UIStackView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.spacing = 10
        row.distribution = .fillEqually

        let invite = JamoCoCreatePublishSuccessButton(
            title: "Invite\nFriends",
            imageName: "jamo_cocreate_publish_invite_friends",
            background: JamoMainTheme.ink,
            foreground: JamoMainTheme.pink
        )
        invite.titleLabel?.numberOfLines = 2
        invite.addTarget(self, action: #selector(inviteTapped), for: .touchUpInside)

        let tree = JamoCoCreatePublishSuccessButton(
            title: "Tree",
            imageName: "jamo_cocreate_publish_creation_tree",
            background: .white,
            foreground: JamoMainTheme.ink
        )
        tree.addTarget(self, action: #selector(treeTapped), for: .touchUpInside)

        row.addArrangedSubview(invite)
        row.addArrangedSubview(tree)
        NSLayoutConstraint.activate([
            row.widthAnchor.constraint(equalToConstant: 228),
            invite.heightAnchor.constraint(equalToConstant: 48),
            tree.heightAnchor.constraint(equalTo: invite.heightAnchor)
        ])
        return row
    }

    private func currentWork() -> JamoCoCreateWork {
        JamoLocalJamStore.shared.work(withID: work.id) ?? work
    }

    private func showCurrentWorkDetail() {
        guard let navigationController else { return }
        let latestWork = currentWork()
        if let existingDetail = navigationController.viewControllers
            .compactMap({ $0 as? JamoCoCreateDetailViewController })
            .first(where: { $0.jamoDisplaysWork(latestWork.id) }) {
            navigationController.popToViewController(existingDetail, animated: true)
            return
        }

        let detail = JamoCoCreateDetailViewController(work: latestWork)
        var controllers = navigationController.viewControllers
        if let selfIndex = controllers.firstIndex(where: { $0 === self }) {
            controllers.removeSubrange(selfIndex...)
        }
        if let publishIndex = controllers.lastIndex(where: { $0 is JamoCoCreatePublishViewController }) {
            controllers.removeSubrange(publishIndex...)
        }
        controllers.append(detail)
        navigationController.setViewControllers(controllers, animated: true)
    }

    @objc private func backToDetailTapped() {
        showCurrentWorkDetail()
    }

    @objc private func viewWorkTapped() {
        showCurrentWorkDetail()
    }

    @objc private func inviteTapped() {
        noFriendsSheet?.removeFromSuperview()
        let sheet = JamoCoCreateNoFriendsSheetView()
        noFriendsSheet = sheet
        sheet.translatesAutoresizingMaskIntoConstraints = false
        sheet.onDismiss = { [weak self] in
            self?.noFriendsSheet?.removeFromSuperview()
            self?.noFriendsSheet = nil
        }
        sheet.onCopyLink = { [weak self] in
            guard let self else { return }
            UIPasteboard.general.string = self.inviteCopyText()
            JamoAuthToastView.show(on: self.view, message: "Invite link copied.")
            self.noFriendsSheet?.dismiss()
        }
        view.addSubview(sheet)
        NSLayoutConstraint.activate([
            sheet.topAnchor.constraint(equalTo: view.topAnchor),
            sheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheet.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        sheet.present()
    }

    private func inviteCopyText() -> String {
        let latestWork = currentWork()
        return "Join my Jamo co-create: \(latestWork.title)\njamo://co-create/\(latestWork.id)"
    }

    @objc private func treeTapped() {
        guard let navigationController else { return }
        let latestWork = currentWork()
        navigationController.pushViewController(
            JamoCoCreateTreeViewController(work: latestWork, mode: treeMode(for: latestWork)),
            animated: true
        )
    }

    private func treeMode(for work: JamoCoCreateWork) -> JamoCoCreateTreeMode {
        let currentUserID = JamoAuthStore.shared.currentUserID ?? "jamo_local_player"
        if work.creatorUserID == currentUserID || work.creatorUserID == "current_user" {
            return .publisherBranches
        }
        let participantCount = max(work.participants?.count ?? 0, Set(work.tracks.map(\.ownerUserID)).count)
        if participantCount <= 1 {
            return .singleLine
        }
        return .myPart
    }
}

private final class JamoCoCreatePublishSuccessButton: UIButton {
    init(title: String, imageName: String?, background: UIColor, foreground: UIColor) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 18
        layer.cornerCurve = .continuous
        clipsToBounds = true

        var configuration = UIButton.Configuration.plain()
        var attributedTitle = AttributedString(title)
        attributedTitle.font = JamoMainTheme.bodyFont(13, weight: .heavy)
        attributedTitle.foregroundColor = foreground
        configuration.attributedTitle = attributedTitle
        configuration.image = imageName.flatMap { UIImage(named: $0) }
        configuration.imagePlacement = .leading
        configuration.imagePadding = imageName == nil ? 0 : 6
        configuration.baseForegroundColor = foreground
        configuration.background.backgroundColor = background
        configuration.background.cornerRadius = 18
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
        self.configuration = configuration
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

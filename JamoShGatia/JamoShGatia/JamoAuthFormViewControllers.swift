import UIKit

class JamoAuthGuitarFormViewController: JamoAuthBaseViewController {
    enum Layout {
        static let horizontalPadding: CGFloat = 24
        static let fieldSpacing: CGFloat = 28
        static let buttonTopSpacing: CGFloat = 44
        static let backButtonSize: CGFloat = 44
        static let titleTopSpacing: CGFloat = 142
    }

    let guitarImageView = UIImageView(image: UIImage(named: "jamo_auth_guitar_background"))
    private let backButton = UIButton(type: .system)
    let titleLabel = UILabel()
    let underlineView = JamoPinkStrokeView()
    let formStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGuitarBackdrop()
        setupBackButton()
        setupTitleArea()
        setupFormStack()
    }

    func configureTitle(_ title: String) {
        titleLabel.text = title
    }

    private func setupGuitarBackdrop() {
        guitarImageView.translatesAutoresizingMaskIntoConstraints = false
        guitarImageView.contentMode = .scaleAspectFill
        guitarImageView.clipsToBounds = true
        guitarImageView.isUserInteractionEnabled = false
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        view.insertSubview(guitarImageView, belowSubview: scrollView)

       
        NSLayoutConstraint.activate([
            guitarImageView.topAnchor.constraint(equalTo: view.topAnchor, constant:0),
            guitarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            guitarImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            guitarImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            
        ])
    }

    private func setupBackButton() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.backgroundColor = UIColor(red: 18 / 255, green: 18 / 255, blue: 18 / 255, alpha: 1)
        backButton.tintColor = .white
        backButton.layer.cornerRadius = Layout.backButtonSize / 2
        backButton.layer.cornerCurve = .continuous
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.accessibilityLabel = JamoRiffStringCipher.restore("Bmaicak0")
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.horizontalPadding),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.widthAnchor.constraint(equalToConstant: Layout.backButtonSize),
            backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor)
        ])
    }

    private func setupTitleArea() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = JamoAuthTheme.futuraBold(size: 44)
        titleLabel.textColor = .black
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.82
        contentView.addSubview(titleLabel)

        contentView.addSubview(underlineView)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: Layout.titleTopSpacing),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -24),

            underlineView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -6),
            underlineView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            underlineView.widthAnchor.constraint(equalTo: titleLabel.widthAnchor, multiplier: 0.78),
            underlineView.heightAnchor.constraint(equalToConstant: 6)
        ])
    }

    private func setupFormStack() {
        formStack.translatesAutoresizingMaskIntoConstraints = false
        formStack.axis = .vertical
        formStack.spacing = Layout.fieldSpacing
        contentView.addSubview(formStack)

        NSLayoutConstraint.activate([
            formStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.horizontalPadding),
            formStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.horizontalPadding),
            formStack.topAnchor.constraint(equalTo: underlineView.bottomAnchor, constant: 132),
            formStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    @objc private func backTapped() {
        if let navigationController, navigationController.viewControllers.first !== self {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

final class JamoRiffAccessGateViewController: JamoAuthGuitarFormViewController {
    private let riffMailInput = JamoRiffTextInput(riffPlaceholder: JamoRiffStringCipher.restore("EcnntTemrX 9etm9a6iLln Oaod4dIr2eKsPs2"))
    private let stringTensionPhraseInput = JamoRiffTextInput(riffPlaceholder: JamoRiffStringCipher.restore("EUn9tFeIrn wpOapsoscwsoDrKdm"), hidesStringPhrase: true)
    private lazy var enterJamButton = JamoAuthGradientButton(title: JamoRiffStringCipher.restore("L6ojgfiMng"), style: .pink)
    private lazy var riffPolicyCheckView = JamoRiffPolicyCheckView(accepted: authStore.isAgreementAccepted)
    private let riffAccessService = JamoRiffAccessService.sharedRiffAccess

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTitle(JamoRiffStringCipher.restore("LlozgX lI9nt"))
        setupRiffAccessFields()
    }

    private func setupRiffAccessFields() {
        let riffMailCaption = UILabel()
        riffMailCaption.text = JamoRiffStringCipher.restore("YoohuprW fEcmka0iule 5ahdLdZr0ecs8sM")
        riffMailCaption.font = JamoAuthTheme.helveticaBold(size: 16)
        riffMailCaption.textColor = .black

        let riffMailGroup = UIStackView(arrangedSubviews: [riffMailCaption, riffMailInput])
        riffMailGroup.axis = .vertical
        riffMailGroup.spacing = 20
        formStack.addArrangedSubview(riffMailGroup)
        formStack.addArrangedSubview(stringTensionPhraseInput)
        formStack.setCustomSpacing(Layout.buttonTopSpacing, after: stringTensionPhraseInput)
        formStack.addArrangedSubview(enterJamButton)
        formStack.setCustomSpacing(94, after: enterJamButton)

        riffPolicyCheckView.delegate = self
        formStack.addArrangedSubview(riffPolicyCheckView)

        riffMailInput.keyboardType = .emailAddress
        riffMailInput.textContentType = .username
        stringTensionPhraseInput.textContentType = .password
        enterJamButton.addTarget(self, action: #selector(enterJamTapped), for: .touchUpInside)
    }

    @objc private func enterJamTapped() {
        let riffMail = trimmedRiffText(riffMailInput.text)
        let stringTensionPhrase = stringTensionPhraseInput.text ?? ""

        switch JamoRiffGatekeeper.inspectRiffAccess(riffMail: riffMail, stringTensionPhrase: stringTensionPhrase, riffPolicyAccepted: authStore.isAgreementAccepted) {
        case .inTune:
            break
        case .needsRetune(let riffNotice):
            showRiffNotice(riffNotice)
            return
        }

        enterJamButton.setLoading(true)
        riffAccessService.enterRiffStage(riffMail: riffMail, stringTensionPhrase: stringTensionPhrase) { [weak self] sessionSignal in
            guard let self else { return }
            self.enterJamButton.setLoading(false)
            switch sessionSignal {
            case .success:
                self.showRiffNotice(JamoRiffStringCipher.restore("LTougli3nI YsuuUcyc9ess6sxfFuNlC.c"))
                self.enterJamButton.isEnabled = false
                JamoRiffStageRouter.openMainRiffStage(from: self)
            case .failure(let detunedSignal):
                self.showRiffNotice(detunedSignal.localizedDescription)
            }
        }
    }

    private func trimmedRiffText(_ riffText: String?) -> String {
        riffText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

final class JamoRiffPlayerEntryViewController: JamoAuthGuitarFormViewController {
    private let riffMailInput = JamoRiffTextInput(riffPlaceholder: JamoRiffStringCipher.restore("EVndt1efrD He2mhavitlG Xa7dOd0rXeBs8sV"))
    private let playerStageNameInput = JamoRiffTextInput(riffPlaceholder: JamoRiffStringCipher.restore("EInPtUe3ra cN2ikcBkP CNMabmke3"))
    private let stringTensionInput = JamoRiffTextInput(riffPlaceholder: JamoRiffStringCipher.restore("EjnotHehr6 FpHaTsrs2wNobrzdT"), hidesStringPhrase: true)
    private lazy var joinRiffButton = JamoAuthGradientButton(title: JamoRiffStringCipher.restore("SviSgfnJ BUtpG"), style: .pink)
    private lazy var riffPolicyCheckView = JamoRiffPolicyCheckView(accepted: authStore.isAgreementAccepted)
    private let playerTonePortraitButton = UIButton(type: .custom)
    private let playerTonePortraitPreview = UIImageView()
    private let riffAccessService = JamoRiffAccessService.sharedRiffAccess
    private var selectedTonePortraitCacheAddress: URL?
    private weak var tonePortraitCaptureSheet: JamoRiffTonePortraitCaptureSheet?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTitle(JamoRiffStringCipher.restore("S2iigOnS YUzpa"))
        setupPlayerTonePortraitButton()
        setupRiffEntryFields()
    }

    private func setupPlayerTonePortraitButton() {
        playerTonePortraitButton.translatesAutoresizingMaskIntoConstraints = false
        playerTonePortraitButton.backgroundColor = .white
        playerTonePortraitButton.layer.cornerRadius = 50
        playerTonePortraitButton.layer.cornerCurve = .continuous
        playerTonePortraitButton.setTitle(JamoRiffStringCipher.restore("+U"), for: .normal)
        playerTonePortraitButton.setTitleColor(UIColor(white: 0.58, alpha: 1), for: .normal)
        playerTonePortraitButton.titleLabel?.font = .systemFont(ofSize: 56, weight: .light)
        playerTonePortraitButton.addTarget(self, action: #selector(playerTonePortraitTapped), for: .touchUpInside)
        contentView.addSubview(playerTonePortraitButton)

        playerTonePortraitPreview.translatesAutoresizingMaskIntoConstraints = false
        playerTonePortraitPreview.contentMode = .scaleAspectFill
        playerTonePortraitPreview.clipsToBounds = true
        playerTonePortraitPreview.isHidden = true
        playerTonePortraitPreview.isUserInteractionEnabled = false
        playerTonePortraitButton.addSubview(playerTonePortraitPreview)

        NSLayoutConstraint.activate([
            playerTonePortraitButton.widthAnchor.constraint(equalToConstant: 100),
            playerTonePortraitButton.heightAnchor.constraint(equalToConstant: 100),
            playerTonePortraitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            playerTonePortraitButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: -4),

            playerTonePortraitPreview.topAnchor.constraint(equalTo: playerTonePortraitButton.topAnchor),
            playerTonePortraitPreview.leadingAnchor.constraint(equalTo: playerTonePortraitButton.leadingAnchor),
            playerTonePortraitPreview.trailingAnchor.constraint(equalTo: playerTonePortraitButton.trailingAnchor),
            playerTonePortraitPreview.bottomAnchor.constraint(equalTo: playerTonePortraitButton.bottomAnchor)
        ])
    }

    private func setupRiffEntryFields() {
        let riffMailCaption = UILabel()
        riffMailCaption.text = JamoRiffStringCipher.restore("YCoIudr1 sEQmsaPiKlg waxdIdsrAebsssD")
        riffMailCaption.font = JamoAuthTheme.helveticaBold(size: 16)
        riffMailCaption.textColor = .black

        let riffMailGroup = UIStackView(arrangedSubviews: [riffMailCaption, riffMailInput])
        riffMailGroup.axis = .vertical
        riffMailGroup.spacing = 20
        formStack.addArrangedSubview(riffMailGroup)
        formStack.addArrangedSubview(playerStageNameInput)
        formStack.addArrangedSubview(stringTensionInput)
        formStack.setCustomSpacing(Layout.buttonTopSpacing, after: stringTensionInput)
        formStack.addArrangedSubview(joinRiffButton)
        formStack.setCustomSpacing(34, after: joinRiffButton)

        riffPolicyCheckView.delegate = self
        formStack.addArrangedSubview(riffPolicyCheckView)

        riffMailInput.keyboardType = .emailAddress
        riffMailInput.textContentType = .emailAddress
        playerStageNameInput.textContentType = .nickname
        stringTensionInput.textContentType = .newPassword
        joinRiffButton.addTarget(self, action: #selector(joinRiffTapped), for: .touchUpInside)
    }

    @objc private func playerTonePortraitTapped() {
        tonePortraitCaptureSheet?.fadeOutRiffSheet()
        let riffPortraitSheet = JamoRiffTonePortraitCaptureSheet(
            cameraTakeEnabled: UIImagePickerController.isSourceTypeAvailable(.camera),
            cameraTakeSelected: { [weak self] in
                self?.tonePortraitCaptureSheet?.fadeOutRiffSheet()
                self?.presentPlayerTonePortraitPicker(captureTrack: .camera)
            },
            libraryTakeSelected: { [weak self] in
                self?.tonePortraitCaptureSheet?.fadeOutRiffSheet()
                self?.presentPlayerTonePortraitPicker(captureTrack: .photoLibrary)
            },
            sheetDismissRequested: { [weak self] in
                self?.tonePortraitCaptureSheet?.fadeOutRiffSheet()
            }
        )
        riffPortraitSheet.attach(to: view)
        tonePortraitCaptureSheet = riffPortraitSheet
    }

    @objc private func joinRiffTapped() {
        let riffMail = trimmedRiffText(riffMailInput.text)
        let stageName = trimmedRiffText(playerStageNameInput.text)
        let stringTensionPhrase = stringTensionInput.text ?? ""

        switch JamoRiffGatekeeper.inspectPlayerEntry(
            riffMail: riffMail,
            stageName: stageName,
            stringTensionPhrase: stringTensionPhrase,
            riffPolicyAccepted: authStore.isAgreementAccepted
        ) {
        case .inTune:
            break
        case .needsRetune(let riffNotice):
            showRiffNotice(riffNotice)
            return
        }

        joinRiffButton.setLoading(true)
        riffAccessService.joinRiffStage(riffMail: riffMail, stageName: stageName, stringTensionPhrase: stringTensionPhrase) { [weak self] sessionSignal in
            guard let self else { return }
            self.joinRiffButton.setLoading(false)
            switch sessionSignal {
            case .success:
                if let selectedTonePortraitCacheAddress {
                    self.authStore.currentAvatarURL = selectedTonePortraitCacheAddress.absoluteString
                }
                JamoRiffStageRouter.openMainRiffStage(from: self)
            case .failure(let brokenString):
                self.showRiffNotice(brokenString.localizedDescription)
            }
        }
    }

    private func presentPlayerTonePortraitPicker(captureTrack: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(captureTrack) else {
            showRiffNotice(JamoRiffStringCipher.restore("TyhTiFsZ rpLl1aVyNe2ri spphto7tKo8 QsCopuarncleI 5iCsA BuQnRaGvKaQi8lFaxbwl4em.q"))
            return
        }
        let tonePortraitPicker = UIImagePickerController()
        tonePortraitPicker.sourceType = captureTrack
        tonePortraitPicker.allowsEditing = true
        tonePortraitPicker.delegate = self
        present(tonePortraitPicker, animated: true)
    }

    private func applyPlayerTonePortrait(_ tonePortrait: UIImage) {
        playerTonePortraitPreview.image = tonePortrait
        playerTonePortraitPreview.isHidden = false
        playerTonePortraitButton.setTitle(nil, for: .normal)

        let riffMailSeed = trimmedRiffText(riffMailInput.text)
        do {
            selectedTonePortraitCacheAddress = try archivePlayerTonePortrait(tonePortrait, riffMailSeed: riffMailSeed)
            showRiffNotice(JamoRiffStringCipher.restore("PwlraIyxe8rs rpphKoXtDob EaxdpdJeEdY.R"))
        } catch {
            showRiffNotice(JamoRiffStringCipher.restore("UunraabtlVe6 ztsoj TsYamvBeU xp9lJa9y6e9rU XpAhmo0tNoY ElUoTcdaelelayY.O"))
        }
    }

    private func archivePlayerTonePortrait(_ tonePortrait: UIImage, riffMailSeed: String) throws -> URL {
        let tonePortraitArchive = try playerTonePortraitArchiveDirectory()
        let tonePortraitStem = "jamo_player_tone_portrait_\(playerTonePortraitStem(riffMailSeed)).jpg"
        let tonePortraitCacheAddress = tonePortraitArchive.appendingPathComponent(tonePortraitStem)
        guard let tonePortraitBytes = squarePlayerTonePortrait(tonePortrait).jpegData(compressionQuality: 0.82) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try tonePortraitBytes.write(to: tonePortraitCacheAddress, options: [.atomic])
        return tonePortraitCacheAddress
    }

    private func playerTonePortraitArchiveDirectory() throws -> URL {
        let riffDocuments = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let tonePortraitArchive = riffDocuments.appendingPathComponent(JamoRiffStringCipher.restore("JAaSmYoRTRoOnkeOPaorrutVrKawigtrCQaucxhhek"), isDirectory: true)
        if !FileManager.default.fileExists(atPath: tonePortraitArchive.path) {
            try FileManager.default.createDirectory(at: tonePortraitArchive, withIntermediateDirectories: true)
        }
        return tonePortraitArchive
    }

    private func squarePlayerTonePortrait(_ tonePortrait: UIImage) -> UIImage {
        let tonePortraitSide = min(tonePortrait.size.width, tonePortrait.size.height)
        let tonePortraitCropRect = CGRect(
            x: (tonePortrait.size.width - tonePortraitSide) / 2,
            y: (tonePortrait.size.height - tonePortraitSide) / 2,
            width: tonePortraitSide,
            height: tonePortraitSide
        )
        let tonePortraitFormat = UIGraphicsImageRendererFormat.default()
        tonePortraitFormat.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512), format: tonePortraitFormat).image { _ in
            tonePortrait.draw(in: CGRect(x: -tonePortraitCropRect.minX * 512 / tonePortraitSide, y: -tonePortraitCropRect.minY * 512 / tonePortraitSide, width: tonePortrait.size.width * 512 / tonePortraitSide, height: tonePortrait.size.height * 512 / tonePortraitSide))
        }
    }

    private func playerTonePortraitStem(_ riffSeed: String) -> String {
        let baseRiffSeed = trimmedRiffText(riffSeed).isEmpty ? UUID().uuidString : trimmedRiffText(riffSeed).lowercased()
        return baseRiffSeed.unicodeScalars.map { String(format: JamoRiffStringCipher.restore("%50x2Bxt"), $0.value) }.joined()
    }

    private func trimmedRiffText(_ riffText: String?) -> String {
        riffText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

extension JamoRiffPlayerEntryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ tonePortraitPicker: UIImagePickerController, didFinishPickingMediaWithInfo tonePortraitInfo: [UIImagePickerController.InfoKey: Any]) {
        let tonePortrait = (tonePortraitInfo[.editedImage] as? UIImage) ?? (tonePortraitInfo[.originalImage] as? UIImage)
        tonePortraitPicker.dismiss(animated: true) { [weak self] in
            guard let self, let tonePortrait else {
                self?.showRiffNotice(JamoRiffStringCipher.restore("UBnJazbilMel nt2on LudsBe7 9tRhdi2s8 epmlgadyKewri NpZhYoptroy.m"))
                return
            }
            self.applyPlayerTonePortrait(tonePortrait)
        }
    }

    func imagePickerControllerDidCancel(_ tonePortraitPicker: UIImagePickerController) {
        tonePortraitPicker.dismiss(animated: true)
    }
}

private final class JamoRiffTonePortraitCaptureSheet: UIView, UIGestureRecognizerDelegate {
    private let riffPortraitSurface = UIView()
    private let cameraTakeSelected: () -> Void
    private let libraryTakeSelected: () -> Void
    private let sheetDismissRequested: () -> Void

    init(
        cameraTakeEnabled: Bool,
        cameraTakeSelected: @escaping () -> Void,
        libraryTakeSelected: @escaping () -> Void,
        sheetDismissRequested: @escaping () -> Void
    ) {
        self.cameraTakeSelected = cameraTakeSelected
        self.libraryTakeSelected = libraryTakeSelected
        self.sheetDismissRequested = sheetDismissRequested
        super.init(frame: .zero)
        composeRiffPortraitSheet(cameraTakeEnabled: cameraTakeEnabled)
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iXnzivtp(YcWoBdBebr6:M)M Ah9aJsL InfoUtI gbSe5eFnM 3i6mFpClPe6mHe5nytwetdY"))
    }

    func attach(to riffStageView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        alpha = 0
        riffStageView.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: riffStageView.topAnchor),
            leadingAnchor.constraint(equalTo: riffStageView.leadingAnchor),
            trailingAnchor.constraint(equalTo: riffStageView.trailingAnchor),
            bottomAnchor.constraint(equalTo: riffStageView.bottomAnchor)
        ])
        layoutIfNeeded()
        riffPortraitSurface.transform = CGAffineTransform(translationX: 0, y: 28)
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.alpha = 1
            self.riffPortraitSurface.transform = .identity
        }
    }

    func fadeOutRiffSheet() {
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseIn, .allowUserInteraction]) {
            self.alpha = 0
            self.riffPortraitSurface.transform = CGAffineTransform(translationX: 0, y: 22)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.removeFromSuperview()
        }
    }

    private func composeRiffPortraitSheet(cameraTakeEnabled: Bool) {
        backgroundColor = UIColor.black.withAlphaComponent(0.32)
        let dimmingTap = UITapGestureRecognizer(target: self, action: #selector(sheetDismissTapped))
        dimmingTap.cancelsTouchesInView = false
        dimmingTap.delegate = self
        addGestureRecognizer(dimmingTap)

        riffPortraitSurface.translatesAutoresizingMaskIntoConstraints = false
        riffPortraitSurface.backgroundColor = JamoAuthTheme.appBackground
        riffPortraitSurface.layer.cornerCurve = .continuous
        riffPortraitSurface.layer.cornerRadius = 26
        addSubview(riffPortraitSurface)

        let riffTakeStack = UIStackView()
        riffTakeStack.translatesAutoresizingMaskIntoConstraints = false
        riffTakeStack.axis = .vertical
        riffTakeStack.spacing = 12
        riffPortraitSurface.addSubview(riffTakeStack)

        let riffPortraitHeadline = UILabel()
        riffPortraitHeadline.text = JamoRiffStringCipher.restore("AAdYd0 CPNluaGyUemrW XPxhjoKtOom")
        riffPortraitHeadline.textColor = .black
        riffPortraitHeadline.font = JamoAuthTheme.futuraBold(size: 22)
        riffPortraitHeadline.textAlignment = .center
        riffTakeStack.addArrangedSubview(riffPortraitHeadline)

        let cameraTakeTrigger = makeRiffTakeTrigger(title: JamoRiffStringCipher.restore("CxafmAeirLaW"), fill: JamoRiffTheme.orange, selector: #selector(cameraTakeTapped))
        cameraTakeTrigger.isHidden = !cameraTakeEnabled
        riffTakeStack.addArrangedSubview(cameraTakeTrigger)
        riffTakeStack.addArrangedSubview(makeRiffTakeTrigger(title: JamoRiffStringCipher.restore("P8hvoLtKo5 nLxiYbaryafrqyY"), fill: JamoRiffTheme.pink, selector: #selector(libraryTakeTapped)))
        riffTakeStack.addArrangedSubview(makeRiffTakeTrigger(title: JamoRiffStringCipher.restore("CGaynmcCeglo"), fill: UIColor(white: 0.12, alpha: 1), selector: #selector(sheetDismissTapped)))

        NSLayoutConstraint.activate([
            riffPortraitSurface.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 18),
            riffPortraitSurface.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -18),
            riffPortraitSurface.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),

            riffTakeStack.topAnchor.constraint(equalTo: riffPortraitSurface.topAnchor, constant: 22),
            riffTakeStack.leadingAnchor.constraint(equalTo: riffPortraitSurface.leadingAnchor, constant: 18),
            riffTakeStack.trailingAnchor.constraint(equalTo: riffPortraitSurface.trailingAnchor, constant: -18),
            riffTakeStack.bottomAnchor.constraint(equalTo: riffPortraitSurface.bottomAnchor, constant: -18)
        ])
    }

    private func makeRiffTakeTrigger(title: String, fill: UIColor, selector: Selector) -> UIButton {
        let riffTakeTrigger = UIButton(type: .custom)
        riffTakeTrigger.translatesAutoresizingMaskIntoConstraints = false
        riffTakeTrigger.setTitle(title, for: .normal)
        riffTakeTrigger.setTitleColor(.white, for: .normal)
        riffTakeTrigger.titleLabel?.font = JamoAuthTheme.helveticaBold(size: 16)
        riffTakeTrigger.backgroundColor = fill
        riffTakeTrigger.layer.cornerCurve = .continuous
        riffTakeTrigger.layer.cornerRadius = 24
        riffTakeTrigger.addTarget(self, action: selector, for: .touchUpInside)
        riffTakeTrigger.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return riffTakeTrigger
    }

    @objc private func cameraTakeTapped() {
        cameraTakeSelected()
    }

    @objc private func libraryTakeTapped() {
        libraryTakeSelected()
    }

    @objc private func sheetDismissTapped() {
        sheetDismissRequested()
    }

    func gestureRecognizer(_ riffGesture: UIGestureRecognizer, shouldReceive riffTouch: UITouch) -> Bool {
        !(riffTouch.view?.isDescendant(of: riffPortraitSurface) ?? false)
    }
}

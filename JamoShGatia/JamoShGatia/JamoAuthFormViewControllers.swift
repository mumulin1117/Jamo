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
        backButton.accessibilityLabel = "Back"
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

final class JamoAuthLoginViewController: JamoAuthGuitarFormViewController {
    private let emailField = JamoAuthTextField(placeholder: "Enter email address")
    private let passwordField = JamoAuthTextField(placeholder: "Enter password", isSecure: true)
    private lazy var loginButton = JamoAuthGradientButton(title: "Login", style: .pink)
    private lazy var agreementView = JamoAuthAgreementView(accepted: authStore.isAgreementAccepted)
    private let authService = JamoAuthService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTitle("Log In")
        setupFields()
    }

    private func setupFields() {
        let emailCaption = UILabel()
        emailCaption.text = "Your Email address"
        emailCaption.font = JamoAuthTheme.helveticaBold(size: 16)
        emailCaption.textColor = .black

        let emailGroup = UIStackView(arrangedSubviews: [emailCaption, emailField])
        emailGroup.axis = .vertical
        emailGroup.spacing = 20
        formStack.addArrangedSubview(emailGroup)
        formStack.addArrangedSubview(passwordField)
        formStack.setCustomSpacing(Layout.buttonTopSpacing, after: passwordField)
        formStack.addArrangedSubview(loginButton)
        formStack.setCustomSpacing(94, after: loginButton)

        agreementView.delegate = self
        formStack.addArrangedSubview(agreementView)

        emailField.keyboardType = .emailAddress
        emailField.textContentType = .username
        passwordField.textContentType = .password
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }

    @objc private func loginTapped() {
        let email = clean(emailField.text)
        let password = passwordField.text ?? ""

        switch JamoAuthValidator.validateLogin(email: email, password: password, acceptedAgreement: authStore.isAgreementAccepted) {
        case .success:
            break
        case .failure(let message):
            showToast(message)
            return
        }

        loginButton.setLoading(true)
        authService.login(email: email, password: password) { [weak self] result in
            guard let self else { return }
            self.loginButton.setLoading(false)
            switch result {
            case .success:
                self.showToast("Login successful.")
                self.loginButton.isEnabled = false
                JamoAuthRouter.showMain(from: self)
            case .failure(let error):
                self.showToast(error.localizedDescription)
            }
        }
    }

    private func clean(_ value: String?) -> String {
        value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

final class JamoAuthSignUpViewController: JamoAuthGuitarFormViewController {
    private let emailField = JamoAuthTextField(placeholder: "Enter email address")
    private let usernameField = JamoAuthTextField(placeholder: "Enter Nick Name")
    private let passwordField = JamoAuthTextField(placeholder: "Enter password", isSecure: true)
    private lazy var signUpButton = JamoAuthGradientButton(title: "Sign Up", style: .pink)
    private lazy var agreementView = JamoAuthAgreementView(accepted: authStore.isAgreementAccepted)
    private let avatarButton = UIButton(type: .custom)
    private let avatarPreviewImageView = UIImageView()
    private let authService = JamoAuthService.shared
    private var selectedAvatarFileURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTitle("Sign Up")
        setupAvatarButton()
        setupFields()
    }

    private func setupAvatarButton() {
        avatarButton.translatesAutoresizingMaskIntoConstraints = false
        avatarButton.backgroundColor = .white
        avatarButton.layer.cornerRadius = 50
        avatarButton.layer.cornerCurve = .continuous
        avatarButton.setTitle("+", for: .normal)
        avatarButton.setTitleColor(UIColor(white: 0.58, alpha: 1), for: .normal)
        avatarButton.titleLabel?.font = .systemFont(ofSize: 56, weight: .light)
        avatarButton.addTarget(self, action: #selector(avatarTapped), for: .touchUpInside)
        contentView.addSubview(avatarButton)

        avatarPreviewImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarPreviewImageView.contentMode = .scaleAspectFill
        avatarPreviewImageView.clipsToBounds = true
        avatarPreviewImageView.isHidden = true
        avatarPreviewImageView.isUserInteractionEnabled = false
        avatarButton.addSubview(avatarPreviewImageView)

        NSLayoutConstraint.activate([
            avatarButton.widthAnchor.constraint(equalToConstant: 100),
            avatarButton.heightAnchor.constraint(equalToConstant: 100),
            avatarButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            avatarButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: -4),

            avatarPreviewImageView.topAnchor.constraint(equalTo: avatarButton.topAnchor),
            avatarPreviewImageView.leadingAnchor.constraint(equalTo: avatarButton.leadingAnchor),
            avatarPreviewImageView.trailingAnchor.constraint(equalTo: avatarButton.trailingAnchor),
            avatarPreviewImageView.bottomAnchor.constraint(equalTo: avatarButton.bottomAnchor)
        ])
    }

    private func setupFields() {
        let emailCaption = UILabel()
        emailCaption.text = "Your Email address"
        emailCaption.font = JamoAuthTheme.helveticaBold(size: 16)
        emailCaption.textColor = .black

        let emailGroup = UIStackView(arrangedSubviews: [emailCaption, emailField])
        emailGroup.axis = .vertical
        emailGroup.spacing = 20
        formStack.addArrangedSubview(emailGroup)
        formStack.addArrangedSubview(usernameField)
        formStack.addArrangedSubview(passwordField)
        formStack.setCustomSpacing(Layout.buttonTopSpacing, after: passwordField)
        formStack.addArrangedSubview(signUpButton)
        formStack.setCustomSpacing(34, after: signUpButton)

        agreementView.delegate = self
        formStack.addArrangedSubview(agreementView)

        emailField.keyboardType = .emailAddress
        emailField.textContentType = .emailAddress
        usernameField.textContentType = .nickname
        passwordField.textContentType = .newPassword
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
    }

    @objc private func avatarTapped() {
        let sheet = UIAlertController(title: "Add Avatar", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sheet.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                self?.presentAvatarPicker(sourceType: .camera)
            })
        }
        sheet.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.presentAvatarPicker(sourceType: .photoLibrary)
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = avatarButton
            popover.sourceRect = avatarButton.bounds
        }
        sheet.jamoApplyTheme()
        present(sheet, animated: true)
    }

    @objc private func signUpTapped() {
        let email = clean(emailField.text)
        let displayName = clean(usernameField.text)
        let password = passwordField.text ?? ""

        switch JamoAuthValidator.validateRegister(
            email: email,
            displayName: displayName,
            password: password,
            acceptedAgreement: authStore.isAgreementAccepted
        ) {
        case .success:
            break
        case .failure(let message):
            showToast(message)
            return
        }

        signUpButton.setLoading(true)
        authService.register(email: email, displayName: displayName, password: password) { [weak self] result in
            guard let self else { return }
            self.signUpButton.setLoading(false)
            switch result {
            case .success:
                if let selectedAvatarFileURL {
                    self.authStore.currentAvatarURL = selectedAvatarFileURL.absoluteString
                }
                JamoAuthRouter.showMain(from: self)
            case .failure(let error):
                self.showToast(error.localizedDescription)
            }
        }
    }

    private func presentAvatarPicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            showToast("This avatar source is unavailable.")
            return
        }
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    private func applySelectedAvatar(_ image: UIImage) {
        avatarPreviewImageView.image = image
        avatarPreviewImageView.isHidden = false
        avatarButton.setTitle(nil, for: .normal)

        let emailSeed = clean(emailField.text)
        do {
            selectedAvatarFileURL = try saveAvatarImage(image, emailSeed: emailSeed)
            showToast("Avatar uploaded!.")
        } catch {
            showToast("Unable to save avatar locally.")
        }
    }

    private func saveAvatarImage(_ image: UIImage, emailSeed: String) throws -> URL {
        let directory = try avatarDirectory()
        let fileName = "jamo_avatar_\(avatarFileSeed(emailSeed)).jpg"
        let fileURL = directory.appendingPathComponent(fileName)
        guard let data = normalizedAvatarImage(image).jpegData(compressionQuality: 0.82) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try data.write(to: fileURL, options: [.atomic])
        return fileURL
    }

    private func avatarDirectory() throws -> URL {
        let documents = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directory = documents.appendingPathComponent("JamoAvatarCache", isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    private func normalizedAvatarImage(_ image: UIImage) -> UIImage {
        let side = min(image.size.width, image.size.height)
        let cropRect = CGRect(
            x: (image.size.width - side) / 2,
            y: (image.size.height - side) / 2,
            width: side,
            height: side
        )
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512), format: format).image { _ in
            image.draw(in: CGRect(x: -cropRect.minX * 512 / side, y: -cropRect.minY * 512 / side, width: image.size.width * 512 / side, height: image.size.height * 512 / side))
        }
    }

    private func avatarFileSeed(_ value: String) -> String {
        let base = clean(value).isEmpty ? UUID().uuidString : clean(value).lowercased()
        return base.unicodeScalars.map { String(format: "%02x", $0.value) }.joined()
    }

    private func clean(_ value: String?) -> String {
        value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

extension JamoAuthSignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
        picker.dismiss(animated: true) { [weak self] in
            guard let self, let image else {
                self?.showToast("Unable to use this avatar.")
                return
            }
            self.applySelectedAvatar(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

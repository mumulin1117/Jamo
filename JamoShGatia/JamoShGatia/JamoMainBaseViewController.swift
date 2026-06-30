import UIKit

class JamoRiffBaseStageViewController: UIViewController {
    let scrollView = UIScrollView()
    let contentView = UIView()
    let contentStack = UIStackView()
    private var contentStackLeadingConstraint: NSLayoutConstraint?
    private var contentStackTrailingConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = JamoRiffTheme.background
        configureScrollLayout()
        registerKeyboardHandling()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.isHidden = true
    }

    func configureScrollLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 18
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStack)

        let leadingConstraint = contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        let trailingConstraint = contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        contentStackLeadingConstraint = leadingConstraint
        contentStackTrailingConstraint = trailingConstraint

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
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            leadingConstraint,
            trailingConstraint,
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    func setContentHorizontalInset(_ inset: CGFloat) {
        contentStackLeadingConstraint?.constant = inset
        contentStackTrailingConstraint?.constant = -inset
    }

    func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = JamoRiffTheme.titleFont(24)
        label.textColor = JamoRiffTheme.ink
        label.numberOfLines = 0
        return label
    }

    func makeBodyLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = JamoRiffTheme.bodyFont(15)
        label.textColor = JamoRiffTheme.muted
        label.numberOfLines = 0
        return label
    }

    func showRiffNotice(_ copy: String) {
        JamoRiffNoticeView.show(on: view, copy: copy)
    }

    private func registerKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditingFromBackgroundTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let overlap = max(0, view.bounds.maxY - keyboardFrameInView.minY - view.safeAreaInsets.bottom)
        updateScrollInsets(bottom: overlap + 16, notification: notification)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        updateScrollInsets(bottom: 0, notification: notification)
    }

    @objc private func endEditingFromBackgroundTap() {
        view.endEditing(true)
    }

    private func updateScrollInsets(bottom: CGFloat, notification: Notification) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let options = UIView.AnimationOptions(rawValue: curveValue << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.scrollView.contentInset.bottom = bottom
            self.scrollView.scrollIndicatorInsets.bottom = bottom
        }
    }
}

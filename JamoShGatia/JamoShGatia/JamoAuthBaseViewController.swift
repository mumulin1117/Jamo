import UIKit

class JamoAuthBaseViewController: UIViewController, JamoRiffPolicyCheckViewDelegate {
    let scrollView = UIScrollView()
    let contentView = UIView()
    let authStore = JamoRiffIdentityArchive.sharedArchive

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = JamoAuthTheme.appBackground
      
        setupScrollContainer()
        setupDismissKeyboardGesture()
        registerKeyboardObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupScrollContainer() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }

    func showRiffNotice(_ riffNotice: String) {
        JamoRiffNoticeView.show(on: view, copy: riffNotice)
    }

    func ensureAgreementAccepted() -> Bool {
        guard authStore.isAgreementAccepted else {
            showRiffNotice(JamoRiffAccessCopy.riffPolicyRequiredNotice)
            return false
        }
        return true
    }

    func jamoRiffPolicyCheckDidTapTerms(_ view: JamoRiffPolicyCheckView) {
        routeLegalPage(kind: .terms)
    }

    func jamoRiffPolicyCheckDidTapPrivacy(_ view: JamoRiffPolicyCheckView) {
        routeLegalPage(kind: .privacy)
    }

    func jamoRiffPolicyCheck(_ view: JamoRiffPolicyCheckView, didChangeAccepted accepted: Bool) {
        authStore.isAgreementAccepted = accepted
    }

    func routeLegalPage(kind: JamoAuthLegalRoute) {
        switch kind {
        case .terms:
            JamoShowDefinition.launchWorkflowBridge(.barlinesConfigDefinition, from: self)
        case .privacy:
            JamoShowDefinition.launchWorkflowBridge(.signalPathInstance, from: self)
        }
    }

    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func registerKeyboardObservers() {
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
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        let keyboardFrame = view.convert(frame, from: nil)
        let overlap = max(0, view.bounds.maxY - keyboardFrame.minY)
        let bottomInset = overlap + 16
        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
        scrollActiveInputIntoView()
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    private func scrollActiveInputIntoView() {
        guard let activeView = view.jamoAuthFirstResponder() else { return }
        let activeRect = activeView.convert(activeView.bounds, to: contentView).insetBy(dx: 0, dy: -20)
        scrollView.scrollRectToVisible(activeRect, animated: true)
    }
}

enum JamoAuthLegalRoute {
    case terms
    case privacy

    var title: String {
        switch self {
        case .terms:
            return JamoRiffStringCipher.restore("T5eJrXm9sF aoffw GUGs4el")
        case .privacy:
            return JamoRiffStringCipher.restore("PlrbifvmavcHys yPLoBlAizcNy3")
        }
    }
}

private extension UIView {
    func jamoAuthFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }
        for subview in subviews {
            if let responder = subview.jamoAuthFirstResponder() {
                return responder
            }
        }
        return nil
    }
}

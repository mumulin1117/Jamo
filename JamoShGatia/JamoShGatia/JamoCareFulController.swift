import UIKit

class JamoCareFulController: UIViewController, JamoRiffPolicyCheckViewDelegate {
    let jamoScroll = UIScrollView()
    let jamoBAckgroundview = UIView()
    let authJamoStore = JamoRiffIdentityArchive.sharedArchive

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = JamoAuthTheme.appBackground
      
        setupJamoWeellScrollContainer()
        setupDismissKeyboardGesture()
        registerKeyboardObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupJamoWeellScrollContainer() {
        jamoScroll.translatesAutoresizingMaskIntoConstraints = false
        jamoScroll.alwaysBounceVertical = true
        jamoScroll.keyboardDismissMode = .interactive
        view.addSubview(jamoScroll)

        jamoBAckgroundview.translatesAutoresizingMaskIntoConstraints = false
        jamoScroll.addSubview(jamoBAckgroundview)

        NSLayoutConstraint.activate([
            jamoScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            jamoScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            jamoScroll.topAnchor.constraint(equalTo: view.topAnchor),
            jamoScroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            jamoBAckgroundview.leadingAnchor.constraint(equalTo: jamoScroll.contentLayoutGuide.leadingAnchor),
            jamoBAckgroundview.trailingAnchor.constraint(equalTo: jamoScroll.contentLayoutGuide.trailingAnchor),
            jamoBAckgroundview.topAnchor.constraint(equalTo: jamoScroll.contentLayoutGuide.topAnchor),
            jamoBAckgroundview.bottomAnchor.constraint(equalTo: jamoScroll.contentLayoutGuide.bottomAnchor),
            jamoBAckgroundview.widthAnchor.constraint(equalTo: jamoScroll.frameLayoutGuide.widthAnchor),
            jamoBAckgroundview.heightAnchor.constraint(greaterThanOrEqualTo: jamoScroll.frameLayoutGuide.heightAnchor)
        ])
    }

    func showRiffNotice(_ riffNotice: String) {
        JamoRiffNoticeView.show(on: view, copy: riffNotice)
    }

    func ensureAgreementAccepted() -> Bool {
        guard authJamoStore.isAgreementAccepted else {
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
        authJamoStore.isAgreementAccepted = accepted
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
        jamoScroll.contentInset.bottom = bottomInset
        jamoScroll.verticalScrollIndicatorInsets.bottom = bottomInset
        scrollActiveInputIntoView()
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        jamoScroll.contentInset.bottom = 0
        jamoScroll.verticalScrollIndicatorInsets.bottom = 0
    }

    private func scrollActiveInputIntoView() {
        guard let activeView = view.jamoAuthFirstResponder() else { return }
        let activeRect = activeView.convert(activeView.bounds, to: jamoBAckgroundview).insetBy(dx: 0, dy: -20)
        jamoScroll.scrollRectToVisible(activeRect, animated: true)
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

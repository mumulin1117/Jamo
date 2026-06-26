import UIKit

final class JamoMainTabBarController: UITabBarController {
    private let jamoTabArtworks: [JamoTabArtwork] = [
        JamoTabArtwork(label: "Home", idle: "jamo_tab_home_idle", active: "jamo_tab_home_active"),
        JamoTabArtwork(label: "Co-create", idle: "jamo_tab_jam_idle", active: "jamo_tab_jam_active"),
        JamoTabArtwork(label: "Messages", idle: "jamo_tab_messages_idle", active: "jamo_tab_messages_active"),
        JamoTabArtwork(label: "Profile", idle: "jamo_tab_me_idle", active: "jamo_tab_me_active")
    ]
    private let jamoTabStack = UIStackView()
    private var jamoTabButtons: [JamoTabBarArtworkButton] = []

    override var selectedIndex: Int {
        didSet {
            updateJamoTabSelection()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupTabs()
        setupTabBarAppearance()
        setupJamoArtworkTabBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabBar.bringSubviewToFront(jamoTabStack)
    }

    func switchToJamTab() {
        selectedIndex = 1
    }

    private func setupTabs() {
        let home = navigationRoot(JamoHomeViewController(), accessibilityLabel: "Home")
        let jam = navigationRoot(JamoCoCreateListViewController(), accessibilityLabel: "Co-create")
        let messages = navigationRoot(JamoMessagesViewController(), accessibilityLabel: "Messages")
        let me = navigationRoot(JamoProfileViewController(), accessibilityLabel: "Profile")
        viewControllers = [home, jam, messages, me]
    }

    private func navigationRoot(_ controller: UIViewController, accessibilityLabel: String) -> UINavigationController {
        controller.title = nil
        let hiddenImage = UIImage()
        controller.tabBarItem = UITabBarItem(title: nil, image: hiddenImage, selectedImage: hiddenImage)
        controller.tabBarItem.accessibilityLabel = accessibilityLabel
        controller.tabBarItem.imageInsets = .zero
        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.navigationBar.isHidden = true
        return navigation
    }

    private func setupTabBarAppearance() {
        tabBar.tintColor = JamoMainTheme.pink
        tabBar.unselectedItemTintColor = JamoMainTheme.muted
        tabBar.backgroundColor = .white
        tabBar.isTranslucent = false

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.backgroundEffect = nil
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.08)
        appearance.selectionIndicatorImage = UIImage()
        appearance.stackedLayoutAppearance.normal.iconColor = .clear
        appearance.stackedLayoutAppearance.selected.iconColor = .clear
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.clear,
            .font: JamoMainTheme.bodyFont(11, weight: .medium)
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.clear,
            .font: JamoMainTheme.bodyFont(11, weight: .semibold)
        ]
        tabBar.selectionIndicatorImage = UIImage()
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }

    private func setupJamoArtworkTabBar() {
        tabBar.clipsToBounds = false
        jamoTabStack.translatesAutoresizingMaskIntoConstraints = false
        jamoTabStack.axis = .horizontal
        jamoTabStack.alignment = .center
        jamoTabStack.distribution = .equalSpacing
        jamoTabStack.isUserInteractionEnabled = true

        jamoTabButtons = jamoTabArtworks.enumerated().map { index, artwork in
            let button = JamoTabBarArtworkButton(index: index, artwork: artwork)
            button.addTarget(self, action: #selector(jamoTabTapped(_:)), for: .touchUpInside)
            jamoTabStack.addArrangedSubview(button)
            return button
        }

        tabBar.addSubview(jamoTabStack)
        NSLayoutConstraint.activate([
            jamoTabStack.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: 0),
            jamoTabStack.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor, constant: 16),
            jamoTabStack.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor, constant: -16),
            jamoTabStack.heightAnchor.constraint(equalToConstant: 54)
        ])
        updateJamoTabSelection()
    }

    private func updateJamoTabSelection() {
        guard !jamoTabButtons.isEmpty else { return }
        for button in jamoTabButtons {
            button.setActive(button.tabIndex == selectedIndex)
        }
    }

    @objc private func jamoTabTapped(_ sender: JamoTabBarArtworkButton) {
        selectedIndex = sender.tabIndex
    }
}

extension JamoMainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        updateJamoTabSelection()
    }
}

private struct JamoTabArtwork {
    let label: String
    let idle: String
    let active: String
}

private final class JamoTabBarArtworkButton: UIControl {
    let tabIndex: Int

    private let artwork: JamoTabArtwork
    private let imageView = UIImageView()
    private var widthConstraint: NSLayoutConstraint!
    private var imageWidthConstraint: NSLayoutConstraint!
    private var imageHeightConstraint: NSLayoutConstraint!

    init(index: Int, artwork: JamoTabArtwork) {
        self.tabIndex = index
        self.artwork = artwork
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityLabel = artwork.label
        accessibilityTraits = [.button]

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        addSubview(imageView)

        widthConstraint = widthAnchor.constraint(equalToConstant: 52)
        imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 28)
        imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 28)

        NSLayoutConstraint.activate([
            widthConstraint,
            heightAnchor.constraint(equalToConstant: 54),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageWidthConstraint,
            imageHeightConstraint
        ])
        setActive(false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setActive(_ active: Bool) {
        isSelected = active
        let imageName = active ? artwork.active : artwork.idle
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        imageView.image = image

        let imageSize = image?.size ?? CGSize(width: 28, height: 28)
        widthConstraint.constant = active ? max(52, imageSize.width) : 52
        imageWidthConstraint.constant = imageSize.width
        imageHeightConstraint.constant = imageSize.height
        accessibilityTraits = active ? [.button, .selected] : [.button]
    }
}

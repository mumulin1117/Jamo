import UIKit

final class JamoMainTabBarController: UITabBarController {
    private let jamoTabArtworks: [JamoTabArtwork] = [
        JamoTabArtwork(label: JamoRiffStringCipher.restore("HXoOmmeD"), idle: JamoRiffStringCipher.restore("jHaKm2oY_7tuadbv_NhEoCmaeT_Riudxliee"), active: JamoRiffStringCipher.restore("joajmVo4_KtTa2bC_MhOoImvey_jaccptfiHvce5")),
        JamoTabArtwork(label: JamoRiffStringCipher.restore("CCoy-7cMr7eCa5tBev"), idle: JamoRiffStringCipher.restore("jRaNmmo1_qt8apbf_Pj0ajml_RiFdllXeE"), active: JamoRiffStringCipher.restore("jzaMmhoH_stxa1b6_Xjja6mu_3aGcVtCixvoes")),
        JamoTabArtwork(label: JamoRiffStringCipher.restore("MxeTsxsUaogseEsq"), idle: JamoRiffStringCipher.restore("j7a5mioD_6t8aFbn_ombeQstswaagoeWsf_KiIdxl8eh"), active: JamoRiffStringCipher.restore("joaRmOo6_jtqaxbK_3mPeOsSs5aHgneRse_3aucLtCiJvMer")),
        JamoTabArtwork(label: JamoRiffStringCipher.restore("P6roocf9iSlfeq"), idle: JamoRiffStringCipher.restore("jLaTmqo4_PtVaBbY_kmleE_Wi7dGlfey"), active: JamoRiffStringCipher.restore("jQaHmmo6_jteafb0_RmHel_3aAcytuibvtel"))
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
        let home = navigationRoot(JamoGuitaFunctController(), accessibilityLabel: JamoRiffStringCipher.restore("HboqmPeH"))
        let jam = navigationRoot(JamoRiffChainListViewController(), accessibilityLabel: JamoRiffStringCipher.restore("Ctoj-xcTrke2ahtOem"))
        let messages = navigationRoot(JamoRiffQuietInboxViewController(), accessibilityLabel: JamoRiffStringCipher.restore("MSeAs1swaPgMeEs6"))
        let me = navigationRoot(JamoProfileViewController(), accessibilityLabel: JamoRiffStringCipher.restore("PJrRobfHidlden"))
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
        tabBar.tintColor = JamoRiffTheme.pink
        tabBar.unselectedItemTintColor = JamoRiffTheme.muted
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
            .font: JamoRiffTheme.bodyFont(11, weight: .medium)
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.clear,
            .font: JamoRiffTheme.bodyFont(11, weight: .semibold)
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
        fatalError(JamoRiffStringCipher.restore("i5nDiRtT(WcPoidmeCrA:p)X Gh4ahsk WnzoZtb 0bleoe0nY wigmcpDlWeEmkeQnKtaeed6"))
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

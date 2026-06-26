import UIKit

final class JamoCoCreateListViewController: JamoMainBaseViewController {
    private enum Layout {
        static let horizontalInset: CGFloat = 20
        static let filterHeight: CGFloat = 34
        static let searchSize: CGFloat = 44
        static let cardSpacing: CGFloat = 16
    }

    private let viewModel = JamoCoCreateViewModel()
    private var selectedFilter: JamoCoCreateFilter = .openJams
    private var requestID = UUID()
    private var hasRenderedContent = false

    override func viewDidLoad() {
        super.viewDidLoad()
       
        contentStack.spacing = Layout.cardSpacing
        scrollView.alwaysBounceVertical = true
        loadContent(showLoading: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if hasRenderedContent {
            loadContent(showLoading: false)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    private func loadContent(showLoading: Bool) {
        let currentRequest = UUID()
        requestID = currentRequest
        if showLoading {
            renderLoading()
        }

        let delay: TimeInterval = showLoading ? 0.48 : 0.12
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self, self.requestID == currentRequest else { return }
            self.viewModel.loadOpenJams(selectedFilter: self.selectedFilter) { [weak self] snapshot in
                DispatchQueue.main.async {
                    guard let self, self.requestID == currentRequest else { return }
                    self.render(snapshot)
                }
            }
        }
    }

    private func render(_ snapshot: JamoCoCreateListSnapshot) {
        hasRenderedContent = true
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contentStack.addArrangedSubview(makeHeaderView())
        contentStack.addArrangedSubview(makeFilterScroll(filters: snapshot.filters))

        switch snapshot.state {
        case .empty:
            let emptyView = JamoCoCreateEmptyStateView(display: snapshot.empty ?? fallbackEmptyDisplay())
            emptyView.startButton.addTarget(self, action: #selector(startCoCreate), for: .touchUpInside)
            contentStack.addArrangedSubview(emptyView)
        case .openJams:
            snapshot.cards.forEach { card in
                let cardView = JamoCoCreateListCardView(card: card)
                cardView.addTarget(self, action: #selector(openCard(_:)), for: .touchUpInside)
                cardView.joinButton.addTarget(self, action: #selector(joinCard(_:)), for: .touchUpInside)
                cardView.moreButton.addTarget(self, action: #selector(moreCardActions(_:)), for: .touchUpInside)
                contentStack.addArrangedSubview(cardView)
            }
        case .joinableDetail, .joinedDetail, .completedDetail:
            break
        }
    }

    private func renderLoading() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contentStack.addArrangedSubview(makeHeaderView())
        contentStack.addArrangedSubview(makeFilterScroll(filters: currentFilterDisplays()))
        contentStack.addArrangedSubview(JamoCoCreateLoadingView(title: "Loading jams..."))
    }

    private func currentFilterDisplays() -> [JamoCoCreateFilterDisplay] {
        JamoCoCreateFilter.allCases.map {
            JamoCoCreateFilterDisplay(filter: $0, title: $0.title, isSelected: $0 == selectedFilter)
        }
    }

    private func makeHeaderView() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Co-create"
        titleLabel.textColor = JamoMainTheme.ink
        titleLabel.font = JamoMainTheme.titleFont(28)

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Join a riff, add your sound."
        subtitleLabel.textColor = JamoMainTheme.muted
        subtitleLabel.font = JamoMainTheme.bodyFont(13, weight: .medium)

        let titleStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.axis = .vertical
        titleStack.spacing = 2

        let searchButton = UIButton(type: .custom)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.setImage(UIImage(named: "jamo_cocreate_search_button"), for: .normal)
        searchButton.imageView?.contentMode = .scaleAspectFit
        searchButton.adjustsImageWhenHighlighted = true
        searchButton.accessibilityLabel = "Search"
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)

        container.addSubview(titleStack)
        container.addSubview(searchButton)

        NSLayoutConstraint.activate([
            titleStack.topAnchor.constraint(equalTo: container.topAnchor),
            titleStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleStack.trailingAnchor.constraint(lessThanOrEqualTo: searchButton.leadingAnchor, constant: -16),
            titleStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            searchButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            searchButton.centerYAnchor.constraint(equalTo: titleStack.centerYAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: Layout.searchSize),
            searchButton.heightAnchor.constraint(equalToConstant: Layout.searchSize)
        ])

        return container
    }

    private func makeFilterScroll(filters: [JamoCoCreateFilterDisplay]) -> UIView {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.alwaysBounceHorizontal = true

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        scroll.addSubview(stack)

        filters.forEach { display in
            let button = JamoCoCreateFilterButton(display: display)
            button.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
        }

        NSLayoutConstraint.activate([
            scroll.heightAnchor.constraint(equalToConstant: Layout.filterHeight),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            stack.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor)
        ])

        return scroll
    }

    private func fallbackEmptyDisplay() -> JamoCoCreateEmptyDisplay {
        JamoCoCreateEmptyDisplay(
            title: "No open jams yet",
            subtitle: "Start a guitar piece and invite others to join.",
            action: JamoCoCreateActionDisplay(title: "Start Co-create", isEnabled: true, style: .orange)
        )
    }

    @objc private func searchTapped() {
        let search = JamoCoCreateSearchViewController()
        search.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(search, animated: true)
    }

    @objc private func filterTapped(_ sender: JamoCoCreateFilterButton) {
        guard selectedFilter != sender.filter else { return }
        selectedFilter = sender.filter
        loadContent(showLoading: true)
    }

    @objc private func openCard(_ sender: JamoCoCreateListCardView) {
        openWork(withID: sender.workID)
    }

    @objc private func joinCard(_ sender: JamoCoCreateCardActionButton) {
        openWork(withID: sender.workID)
    }

    @objc private func moreCardActions(_ sender: JamoCoCreateCardActionButton) {
        jamoPresentCoCreateModerationSheet(workID: sender.workID, sourceView: sender) { [weak self] workID in
            guard let self else { return }
            self.viewModel.blockWork(withID: workID)
            JamoAuthToastView.show(on: self.view, message: "This jam has been blocked.")
            self.loadContent(showLoading: false)
        } onReport: { [weak self] workID in
            guard let self else { return }
            JamoWebRoute.open(.report(workID: workID), from: self)
        }
    }

    @objc private func startCoCreate() {
        navigationController?.pushViewController(JamoCoCreatePublishViewController(), animated: true)
    }

    private func openWork(withID workID: String) {
        guard let work = viewModel.work(withID: workID) else {
            JamoAuthToastView.show(on: view, message: "This jam is no longer available.")
            return
        }
        navigationController?.pushViewController(JamoCoCreateDetailViewController(work: work), animated: true)
    }
}

final class JamoCoCreateSearchViewController: JamoMainBaseViewController {
    private let viewModel = JamoCoCreateViewModel()
    private let searchField = UITextField()
    private let resultsStack = UIStackView()
    private var searchRequestID = UUID()
    private var pendingSearchWorkItem: DispatchWorkItem?

    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        hidesBottomBarWhenPushed = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = nil
        contentStack.spacing = 16
        configureCustomTopBar()
        configureSearchField()
        configureResultsStack()
        requestSearchResults(showLoading: true)
        DispatchQueue.main.async { [weak self] in
            self?.searchField.becomeFirstResponder()
        }
    }

    deinit {
        pendingSearchWorkItem?.cancel()
    }

    private func configureCustomTopBar() {
        let topBar = UIView()
        topBar.translatesAutoresizingMaskIntoConstraints = false

        let backButton = UIButton(type: .custom)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "jamo_cocreate_search_back_button")?.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.accessibilityLabel = "Back"
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Search"
        titleLabel.textColor = JamoMainTheme.ink
        titleLabel.font = JamoMainTheme.titleFont(18)
        titleLabel.textAlignment = .center

        topBar.addSubview(backButton)
        topBar.addSubview(titleLabel)
        contentStack.addArrangedSubview(topBar)

        NSLayoutConstraint.activate([
            topBar.heightAnchor.constraint(equalToConstant: 44),
            backButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: topBar.trailingAnchor, constant: -52)
        ])
    }

    private func configureSearchField() {
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.backgroundColor = .white
        searchField.layer.cornerRadius = 18
        searchField.layer.borderWidth = 1
        searchField.layer.borderColor = UIColor.black.withAlphaComponent(0.07).cgColor
        searchField.textColor = JamoMainTheme.ink
        searchField.font = JamoMainTheme.bodyFont(15, weight: .medium)
        searchField.placeholder = "Search riffs, players, tags"
        searchField.returnKeyType = .search
        searchField.clearButtonMode = .whileEditing
        searchField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)

        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        searchField.leftView = spacer
        searchField.leftViewMode = .always
        contentStack.addArrangedSubview(searchField)

        NSLayoutConstraint.activate([
            searchField.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func configureResultsStack() {
        resultsStack.translatesAutoresizingMaskIntoConstraints = false
        resultsStack.axis = .vertical
        resultsStack.spacing = 16
        contentStack.addArrangedSubview(resultsStack)
    }

    private func renderResults() {
        resultsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let snapshot = viewModel.makeSearchSnapshot(query: searchField.text ?? "")
        switch snapshot.state {
        case .empty:
            resultsStack.addArrangedSubview(makeSearchEmptyView(snapshot.empty))
        case .openJams:
            snapshot.cards.forEach { card in
                let cardView = JamoCoCreateListCardView(card: card)
                cardView.addTarget(self, action: #selector(openCard(_:)), for: .touchUpInside)
                cardView.joinButton.addTarget(self, action: #selector(joinCard(_:)), for: .touchUpInside)
                cardView.moreButton.addTarget(self, action: #selector(moreCardActions(_:)), for: .touchUpInside)
                resultsStack.addArrangedSubview(cardView)
            }
        case .joinableDetail, .joinedDetail, .completedDetail:
            break
        }
    }

    private func requestSearchResults(showLoading: Bool) {
        let currentRequest = UUID()
        searchRequestID = currentRequest
        pendingSearchWorkItem?.cancel()
        if showLoading {
            renderSearchLoading()
        }

        let workItem = DispatchWorkItem { [weak self] in
            guard let self, self.searchRequestID == currentRequest else { return }
            self.renderResults()
        }
        pendingSearchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.42, execute: workItem)
    }

    private func renderSearchLoading() {
        resultsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        resultsStack.addArrangedSubview(JamoCoCreateLoadingView(title: "Searching jams..."))
    }

    private func makeSearchEmptyView(_ empty: JamoCoCreateEmptyDisplay?) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8

        let title = UILabel()
        title.text = empty?.title ?? "No matching jams"
        title.textColor = JamoMainTheme.ink
        title.font = JamoMainTheme.bodyFont(17, weight: .heavy)
        title.textAlignment = .center
        title.numberOfLines = 0

        let subtitle = UILabel()
        subtitle.text = empty?.subtitle ?? "Try another guitar phrase or tag."
        subtitle.textColor = JamoMainTheme.muted
        subtitle.font = JamoMainTheme.bodyFont(13, weight: .regular)
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 0

        stack.addArrangedSubview(title)
        stack.addArrangedSubview(subtitle)
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 180),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24)
        ])
        return container
    }

    @objc private func searchTextChanged() {
        requestSearchResults(showLoading: true)
    }

    @objc private func backTapped() {
        pendingSearchWorkItem?.cancel()
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }

    @objc private func openCard(_ sender: JamoCoCreateListCardView) {
        openWork(withID: sender.workID)
    }

    @objc private func joinCard(_ sender: JamoCoCreateCardActionButton) {
        openWork(withID: sender.workID)
    }

    @objc private func moreCardActions(_ sender: JamoCoCreateCardActionButton) {
        jamoPresentCoCreateModerationSheet(workID: sender.workID, sourceView: sender) { [weak self] workID in
            guard let self else { return }
            self.viewModel.blockWork(withID: workID)
            JamoAuthToastView.show(on: self.view, message: "This jam has been blocked.")
            self.renderResults()
        } onReport: { [weak self] workID in
            guard let self else { return }
            JamoWebRoute.open(.report(workID: workID), from: self)
        }
    }

    private func openWork(withID workID: String) {
        guard let work = viewModel.work(withID: workID) else {
            JamoAuthToastView.show(on: view, message: "This jam is no longer available.")
            return
        }
        navigationController?.pushViewController(JamoCoCreateDetailViewController(work: work), animated: true)
    }
}

final class JamoCoCreateLoadingView: UIView {
    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerCurve = .continuous
        layer.cornerRadius = 22
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor

        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = JamoMainTheme.orange
        spinner.startAnimating()

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textColor = JamoMainTheme.ink
        titleLabel.font = JamoMainTheme.bodyFont(15, weight: .heavy)
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Refreshing  guitar co-create data."
        subtitleLabel.textColor = JamoMainTheme.muted
        subtitleLabel.font = JamoMainTheme.bodyFont(12.5, weight: .medium)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [spinner, titleLabel, subtitleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        addSubview(stack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 156),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            spinner.widthAnchor.constraint(equalToConstant: 24),
            spinner.heightAnchor.constraint(equalTo: spinner.widthAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIViewController {
    func jamoPresentCoCreateModerationSheet(
        workID: String,
        sourceView: UIView,
        onBlock: @escaping (String) -> Void,
        onReport: @escaping (String) -> Void
    ) {
        let sheet = UIAlertController(
            title: "Jam Actions",
            message: "Choose how you want to handle this co-create.",
            preferredStyle: .actionSheet
        )
        sheet.addAction(UIAlertAction(title: "Block", style: .destructive) { _ in
            onBlock(workID)
        })
        sheet.addAction(UIAlertAction(title: "Report", style: .default) { _ in
            onReport(workID)
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = sheet.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
            popover.permittedArrowDirections = [.up, .down]
        }
        sheet.jamoApplyTheme()
        present(sheet, animated: true)
    }
}

final class JamoCoCreateFilterButton: UIButton {
    let filter: JamoCoCreateFilter

    init(display: JamoCoCreateFilterDisplay) {
        self.filter = display.filter
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.font = JamoMainTheme.bodyFont(13, weight: .semibold)
        layer.cornerRadius = 17
        layer.borderWidth = display.isSelected ? 0 : 1
        layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor
        backgroundColor = display.isSelected ? JamoMainTheme.ink : .white
        setTitle(display.title, for: .normal)
        setTitleColor(display.isSelected ? JamoMainTheme.yellow : JamoMainTheme.muted, for: .normal)
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        heightAnchor.constraint(equalToConstant: 34).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class JamoCoCreateCardActionButton: UIButton {
    let workID: String

    init(workID: String) {
        self.workID = workID
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class JamoCoCreateListCardView: UIControl {
    let workID: String
    let joinButton: JamoCoCreateCardActionButton
    let moreButton: JamoCoCreateCardActionButton

    private enum Layout {
        static let cardRadius: CGFloat = 24
        static let innerInset: CGFloat = 12
        static let coverRadius: CGFloat = 22
    }

    init(card: JamoCoCreateCardDisplay) {
        self.workID = card.id
        self.joinButton = JamoCoCreateCardActionButton(workID: card.id)
        self.moreButton = JamoCoCreateCardActionButton(workID: card.id)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = Layout.cardRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.07
        layer.shadowRadius = 14
        layer.shadowOffset = CGSize(width: 0, height: 8)
        buildContent(card)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.86 : 1
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden, alpha > 0.01, isUserInteractionEnabled, bounds.contains(point) else {
            return nil
        }
        let joinPoint = joinButton.convert(point, from: self)
        if joinButton.isEnabled, joinButton.point(inside: joinPoint, with: event) {
            return joinButton
        }
        let morePoint = moreButton.convert(point, from: self)
        if moreButton.point(inside: morePoint, with: event) {
            return moreButton
        }
        return self
    }

    private func buildContent(_ card: JamoCoCreateCardDisplay) {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        addSubview(stack)

        let cover = makeCover(card)
        stack.addArrangedSubview(cover)

        let titleRow = UIStackView()
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 8

        let titleLabel = UILabel()
        titleLabel.text = card.title
        titleLabel.textColor = JamoMainTheme.ink
        titleLabel.font = JamoMainTheme.bodyFont(16, weight: .heavy)
        titleLabel.numberOfLines = 2
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        moreButton.setImage(UIImage(named: "jamo_cocreate_card_more"), for: .normal)
        moreButton.imageView?.contentMode = .scaleAspectFit
        moreButton.accessibilityLabel = "More"

        titleRow.addArrangedSubview(titleLabel)
        titleRow.addArrangedSubview(moreButton)
        stack.addArrangedSubview(titleRow)

        let subtitleLabel = UILabel()
        subtitleLabel.text = card.subtitle
        subtitleLabel.textColor = JamoMainTheme.muted
        subtitleLabel.font = JamoMainTheme.bodyFont(12.5, weight: .regular)
        subtitleLabel.numberOfLines = 2
        stack.addArrangedSubview(subtitleLabel)

        let metaRow = UIStackView()
        metaRow.axis = .horizontal
        metaRow.alignment = .center
        metaRow.spacing = 8

        let avatar = JamoCoCreateAvatarBadge(display: JamoCoCreateParticipantDisplay(
            userID: card.id,
            displayName: card.creatorName,
            initials: card.creatorInitials,
            avatarURL: card.creatorAvatarURL,
            colorHex: "#E75B33"
        ))
        let creatorLabel = UILabel()
        creatorLabel.text = card.creatorName
        creatorLabel.textColor = JamoMainTheme.ink
        creatorLabel.font = JamoMainTheme.bodyFont(12, weight: .bold)
        creatorLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let tag = JamoCoCreateTagView(text: card.tagTitle)
        metaRow.addArrangedSubview(avatar)
        metaRow.addArrangedSubview(creatorLabel)
        metaRow.addArrangedSubview(UIView())
        metaRow.addArrangedSubview(tag)
        stack.addArrangedSubview(metaRow)

        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.spacing = 12

        let joinedLabel = UILabel()
        joinedLabel.text = card.participantSummary
        joinedLabel.textColor = JamoMainTheme.muted
        joinedLabel.font = JamoMainTheme.bodyFont(12, weight: .medium)
        joinedLabel.numberOfLines = 2
        joinedLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        configureJoinButton(card.action)

        bottomRow.addArrangedSubview(joinedLabel)
        bottomRow.addArrangedSubview(joinButton)
        stack.addArrangedSubview(bottomRow)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: Layout.innerInset),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.innerInset),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.innerInset),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.innerInset),
            cover.heightAnchor.constraint(equalTo: cover.widthAnchor, multiplier: 0.45),
            moreButton.widthAnchor.constraint(equalToConstant: 32),
            moreButton.heightAnchor.constraint(equalToConstant: 32),
            joinButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 74),
            joinButton.widthAnchor.constraint(lessThanOrEqualToConstant: 96),
            joinButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func makeCover(_ card: JamoCoCreateCardDisplay) -> UIView {
        let cover = UIView()
        cover.translatesAutoresizingMaskIntoConstraints = false
        cover.backgroundColor = JamoMainTheme.orange.withAlphaComponent(0.16)
        cover.layer.cornerRadius = Layout.coverRadius
        cover.clipsToBounds = true

        let imageView = UIImageView(image: UIImage.jamoCoCreateMedia(named: card.coverImageName) ?? UIImage(named: "jamo_cocreate_publish_work_cover"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = JamoMainTheme.navy.withAlphaComponent(0.14)

        let tint = UIView()
        tint.translatesAutoresizingMaskIntoConstraints = false
        tint.backgroundColor = UIColor.black.withAlphaComponent(0.08)

        let waveform = UIImageView(image: UIImage(named: "jamo_cocreate_waveform_overlay"))
        waveform.translatesAutoresizingMaskIntoConstraints = false
        waveform.contentMode = .scaleToFill
        waveform.alpha = 0.92

        let duration = UILabel()
        duration.translatesAutoresizingMaskIntoConstraints = false
        duration.text = card.durationText
        duration.textColor = .white
        duration.font = JamoMainTheme.bodyFont(10, weight: .bold)
        duration.textAlignment = .center
        duration.backgroundColor = UIColor.black.withAlphaComponent(0.32)
        duration.layer.cornerRadius = 12
        duration.clipsToBounds = true

        cover.addSubview(imageView)
        cover.addSubview(tint)
        cover.addSubview(waveform)
        cover.addSubview(duration)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cover.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cover.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cover.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: cover.bottomAnchor),

            tint.topAnchor.constraint(equalTo: cover.topAnchor),
            tint.leadingAnchor.constraint(equalTo: cover.leadingAnchor),
            tint.trailingAnchor.constraint(equalTo: cover.trailingAnchor),
            tint.bottomAnchor.constraint(equalTo: cover.bottomAnchor),

            waveform.leadingAnchor.constraint(equalTo: cover.leadingAnchor, constant: 12),
            waveform.trailingAnchor.constraint(equalTo: cover.trailingAnchor, constant: -12),
            waveform.bottomAnchor.constraint(equalTo: cover.bottomAnchor, constant: -12),
            waveform.heightAnchor.constraint(equalToConstant: 26),

            duration.trailingAnchor.constraint(equalTo: cover.trailingAnchor, constant: -12),
            duration.topAnchor.constraint(equalTo: cover.topAnchor, constant: 10),
            duration.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            duration.heightAnchor.constraint(equalToConstant: 24)
        ])

        return cover
    }

    private func configureJoinButton(_ action: JamoCoCreateActionDisplay) {
        joinButton.setTitle(action.title, for: .normal)
        joinButton.setTitleColor(action.isEnabled ? .white : JamoMainTheme.muted, for: .normal)
        joinButton.titleLabel?.font = JamoMainTheme.bodyFont(13.5, weight: .bold)
        joinButton.titleLabel?.adjustsFontSizeToFitWidth = true
        joinButton.titleLabel?.minimumScaleFactor = 0.82
        switch action.style {
        case .orange:
            joinButton.backgroundColor = JamoMainTheme.orange
        case .black:
            joinButton.backgroundColor = JamoMainTheme.ink
            joinButton.setTitleColor(JamoMainTheme.pink, for: .normal)
        case .disabled:
            joinButton.backgroundColor = UIColor.black.withAlphaComponent(0.08)
        }
        joinButton.layer.cornerRadius = 20
        joinButton.contentEdgeInsets = UIEdgeInsets(top: 9, left: 14, bottom: 9, right: 14)
        joinButton.isEnabled = action.isEnabled
        joinButton.alpha = action.isEnabled ? 1 : 0.86
    }
}

final class JamoCoCreateAvatarBadge: UIView {
    init(display: JamoCoCreateParticipantDisplay) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.jamoHex(display.colorHex) ?? JamoMainTheme.orange
        layer.cornerRadius = 12
        clipsToBounds = true

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = display.initials
        label.textColor = .white
        label.font = JamoMainTheme.bodyFont(8, weight: .heavy)
        label.textAlignment = .center
        addSubview(label)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 24),
            heightAnchor.constraint(equalToConstant: 24),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class JamoCoCreateTagView: UIView {
    init(text: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = JamoMainTheme.pink.withAlphaComponent(0.16)
        layer.cornerRadius = 13

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = JamoMainTheme.pink
        label.font = JamoMainTheme.bodyFont(11, weight: .heavy)
        addSubview(label)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 27),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class JamoCoCreateEmptyStateView: UIView {
    let startButton = UIButton(type: .custom)

    init(display: JamoCoCreateEmptyDisplay) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        buildContent(display)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildContent(_ display: JamoCoCreateEmptyDisplay) {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        addSubview(stack)

        let icon = UIImageView(image: UIImage(named: "jamo_cocreate_empty_link_icon"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        let title = UILabel()
        title.text = display.title
        title.textColor = JamoMainTheme.ink
        title.font = JamoMainTheme.bodyFont(17, weight: .heavy)
        title.textAlignment = .center
        title.numberOfLines = 0

        let subtitle = UILabel()
        subtitle.text = display.subtitle
        subtitle.textColor = JamoMainTheme.muted
        subtitle.font = JamoMainTheme.bodyFont(13, weight: .regular)
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 0

        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle(display.action.title, for: .normal)
        startButton.setTitleColor(JamoMainTheme.yellow, for: .normal)
        startButton.titleLabel?.font = JamoMainTheme.bodyFont(15, weight: .heavy)
        startButton.backgroundColor = JamoMainTheme.orange
        startButton.layer.cornerRadius = 24
        startButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)

        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(subtitle)
        stack.setCustomSpacing(24, after: subtitle)
        stack.addArrangedSubview(startButton)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 430),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -24),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            icon.widthAnchor.constraint(equalToConstant: 96),
            icon.heightAnchor.constraint(equalToConstant: 96),
            startButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 196),
            startButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}

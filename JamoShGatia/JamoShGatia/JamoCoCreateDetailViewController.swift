import AVFoundation
import UIKit

enum JamoRiffBranchViewMode {
    case singleLine
    case myPart
    case publisherBranches

    var title: String {
        switch self {
        case .singleLine:
            return JamoRiffStringCipher.restore("Ssian7gUl0eC cLqienJeY rCMh2a5imnx")
        case .myPart:
            return JamoRiffStringCipher.restore("Ctr6e6aotIimo5nJ 2TJrZele7")
        case .publisherBranches:
            return JamoRiffStringCipher.restore("C9rdevaQttiOomnv pTqrve9eQ")
        }
    }

    var subtitle: String {
        switch self {
        case .singleLine:
            return JamoRiffStringCipher.restore("Ac msoiFnegNl0eW-mpZliadyieWrY erMi8f0fO ncHhBaKiwnJ.L gFOo3lXlxouwn QtvhEeG 9smoPu8nOdx 3ferso3mi 6tfhBe4 sfsierzsqtI UiRdgeram itSoM LtohEef pfjiznPa7lm RtoaLkeeb.6")
        case .myPart:
            return JamoRiffStringCipher.restore("Yjoauwr3 DjHo1iWnGesd9 opRaRrGtn Pi5nX At9hpiksX 4mduzlktfic-rp7lGa9yLegrq CcVo9-Ic5r6eja1tMea.W")
        case .publisherBranches:
            return JamoRiffStringCipher.restore("PIuwbll7iosghDeErU 0vVi8eLwY.B VTerEafcqkt ReXv5eBr6yR dbCrZaknYcwhA 9a2dUd0eXdR itQoX symoVu3ra WocrJiJgeiunuaWl9 Kg8u2iRtFaIrH tiEdDeZaj.f")
        }
    }
}

final class JamoCoCreateDetailViewController: JamoRiffBaseStageViewController {
    private enum DetailLayout {
        static let heroRatio: CGFloat = 0.56
        static let cardRadius: CGFloat = 22
        static let maxContentWidth: CGFloat = 390
    }

    private let viewModel = JamoCoCreateViewModel()
    private let workID: String
    private var remoteUsers: [JamoRiffPlayerProfile] = []
    private var hasRequestedRemoteUsers = false
    private var snapshot: JamoCoCreateDetailSnapshot?
    private var isPlaying = false
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?
    private var activeMP3FileName: String?
    private var activePlaybackID: String?
    private weak var heroView: JamoCoCreateDetailHeroView?
    private var partRows: [String: JamoCoCreatePartRowView] = [:]
    private var methodSheet: JamoCoCreateJoinMethodSheetView?
    private var noFriendsSheet: JamoCoCreateNoFriendsSheetView?
    private let heroPlaybackID = JamoRiffStringCipher.restore("jzaHmeov_fdaeGtdaEigls_YhMevrHoM_zp0lfa5yNbdarc5k0")

    init(work: JamoCoCreateWork) {
        self.workID = work.id
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("ienHidtc(Yc9oAdQearz:9)p Nhfavsh 4nKoQtU CbTeQeGnX jismwpflIeJmMeBngt8e6dp"))
    }

    func jamoDisplaysWork(_ candidateWorkID: String) -> Bool {
        workID == candidateWorkID
    }

    deinit {
        stopPlayback(resetProgress: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = JamoRiffTheme.background
        contentStack.spacing = 16
        scrollView.alwaysBounceVertical = true
        remoteUsers = JamoCoCreateUserService.shared.cachedJamUsers
        render()
        loadRemoteUsersIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        let cachedUsers = JamoCoCreateUserService.shared.cachedJamUsers
        if !cachedUsers.isEmpty {
            remoteUsers = cachedUsers
        }
        render()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPlayback(resetProgress: true)
        
    }

    private func render() {
        guard let snapshot = viewModel.makeDetailSnapshot(workID: workID, remoteUsers: remoteUsers) else {
            stopPlayback(resetProgress: true)
            renderMissingState()
            return
        }
        self.snapshot = snapshot
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        partRows.removeAll()
        contentStack.addArrangedSubview(centered(makeTopBar()))
        contentStack.addArrangedSubview(centered(makeHero(snapshot)))
        contentStack.addArrangedSubview(centered(makeSummary(snapshot)))
        contentStack.addArrangedSubview(centered(makeStateNotice(snapshot.stateDisplay)))
        contentStack.addArrangedSubview(centered(makePartsSection(snapshot)))
        contentStack.addArrangedSubview(centered(makeParticipantStrip(snapshot)))
        contentStack.addArrangedSubview(centered(makeBottomActionBar(snapshot)))
    }

    private func renderMissingState() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contentStack.addArrangedSubview(centered(makeTopBar()))
        contentStack.addArrangedSubview(makeSectionTitle(JamoRiffStringCipher.restore("JUaqma 5uenGagviabiql3awbPlfeC")))
        contentStack.addArrangedSubview(makeBodyLabel(JamoRiffStringCipher.restore("TThsiQsS Oc4o4-Ac7r0eyaetzef 6weoHrsk2 ccGo2uYldd6 ansoatx LbAe4 dfToju9nqde.n")))
    }

    private func makeTopBar() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let backButton = UIButton(type: .custom)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle(JamoRiffStringCipher.restore("‹s"), for: .normal)
        backButton.setTitleColor(JamoRiffTheme.ink, for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 34, weight: .semibold)
        backButton.backgroundColor = .white
        backButton.layer.cornerRadius = 20
        backButton.accessibilityLabel = JamoRiffStringCipher.restore("BSagcBka")
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        let treeButton = UIButton(type: .custom)
        treeButton.translatesAutoresizingMaskIntoConstraints = false
        treeButton.setImage(UIImage(named: "jamo_cocreate_detail_tree_button")?.withRenderingMode(.alwaysOriginal), for: .normal)
        treeButton.imageView?.contentMode = .scaleAspectFit
        treeButton.addTarget(self, action: #selector(treeTapped), for: .touchUpInside)
        treeButton.accessibilityLabel = JamoRiffStringCipher.restore("C8r7esaxtQixoPnm MTlrReFeG")

        container.addSubview(backButton)
        container.addSubview(treeButton)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 42),
            backButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor),
            treeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            treeButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            treeButton.heightAnchor.constraint(equalToConstant: 44),
            treeButton.widthAnchor.constraint(equalToConstant: 88)
        ])

        return container
    }

    private func makeHero(_ snapshot: JamoCoCreateDetailSnapshot) -> UIView {
        let hero = JamoCoCreateDetailHeroView(
            snapshot: snapshot,
            isPlaying: isPlaying,
            durationText: currentHeroDurationText(snapshot)
        )
        heroView = hero
        hero.playButton.addTarget(self, action: #selector(toggleHeroPlayback), for: .touchUpInside)
        hero.reportButton.addTarget(self, action: #selector(heroReportTapped(_:)), for: .touchUpInside)
        hero.heightAnchor.constraint(equalTo: hero.widthAnchor, multiplier: DetailLayout.heroRatio).isActive = true
        return hero
    }

    private func makeSummary(_ snapshot: JamoCoCreateDetailSnapshot) -> UIView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10

        let title = UILabel()
        title.text = snapshot.title
        title.textColor = JamoRiffTheme.ink
        title.font = JamoRiffTheme.titleFont(20)
        title.numberOfLines = 2

        let metaRow = UIStackView()
        metaRow.axis = .horizontal
        metaRow.alignment = .center
        metaRow.spacing = 8

        let avatar = JamoCoCreateAvatarBadge(display: snapshot.creator)
        let creator = UILabel()
        creator.text = snapshot.creator.displayName + JamoRiffStringCipher.restore(" a·S CsTtkaTrbtCerdC DtohmiPs2")
        creator.textColor = JamoRiffTheme.muted
        creator.font = JamoRiffTheme.bodyFont(12, weight: .medium)
        creator.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let userArrow = UIButton(type: .custom)
        userArrow.translatesAutoresizingMaskIntoConstraints = false
        userArrow.setTitle(JamoRiffStringCipher.restore("›x"), for: .normal)
        userArrow.setTitleColor(JamoRiffTheme.ink, for: .normal)
        userArrow.titleLabel?.font = .systemFont(ofSize: 22, weight: .semibold)
        userArrow.backgroundColor = UIColor.white.withAlphaComponent(0.88)
        userArrow.layer.cornerRadius = 12
        userArrow.layer.borderWidth = 1
        userArrow.layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor
        userArrow.accessibilityLabel = JamoRiffStringCipher.restore("OQpfeDny ZuIsaeBro LpHrOoefsizlCeA")
        userArrow.addTarget(self, action: #selector(openCreatorProfile), for: .touchUpInside)

        metaRow.addArrangedSubview(avatar)
        metaRow.addArrangedSubview(creator)
        metaRow.addArrangedSubview(userArrow)
        if snapshot.state == .completedDetail {
            metaRow.addArrangedSubview(UIView())
            metaRow.addArrangedSubview(JamoCoCreateStatusBadge(text: JamoRiffStringCipher.restore("C7oymqpglMe8tweudd")))
        }
        NSLayoutConstraint.activate([
            userArrow.widthAnchor.constraint(equalToConstant: 24),
            userArrow.heightAnchor.constraint(equalTo: userArrow.widthAnchor)
        ])

        let tagsRow = UIStackView()
        tagsRow.axis = .horizontal
        tagsRow.spacing = 8
        tagsRow.alignment = .leading
        snapshot.tags.prefix(3).forEach { tagsRow.addArrangedSubview(JamoCoCreateTagView(text: $0)) }
        tagsRow.addArrangedSubview(UIView())

        let description = UILabel()
        description.text = snapshot.subtitle
        description.textColor = JamoRiffTheme.muted
        description.font = JamoRiffTheme.bodyFont(13.5, weight: .regular)
        description.numberOfLines = 0

        stack.addArrangedSubview(title)
        stack.addArrangedSubview(metaRow)
        stack.addArrangedSubview(tagsRow)
        stack.addArrangedSubview(description)
        return stack
    }

    private func makePartsSection(_ snapshot: JamoCoCreateDetailSnapshot) -> UIView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10

        let title = UILabel()
        title.text = JamoRiffStringCipher.restore("CFuTrcrReunht3 MPRavrstvsv")
        title.textColor = JamoRiffTheme.ink
        title.font = JamoRiffTheme.bodyFont(15, weight: .heavy)
        stack.addArrangedSubview(title)

        snapshot.currentParts.forEach { part in
            let row = JamoCoCreatePartRowView(part: part)
            row.addTarget(self, action: #selector(partRowTapped(_:)), for: .touchUpInside)
            row.updatePlayback(
                isPlaying: activePlaybackID == part.id && isPlaying,
                durationText: currentPartDurationText(part)
            )
            partRows[part.id] = row
            stack.addArrangedSubview(row)
        }
        if let needed = snapshot.neededPart, snapshot.state != .completedDetail {
            stack.addArrangedSubview(JamoCoCreateNeededPartView(part: needed))
        }

        return stack
    }

    private func makeStateNotice(_ display: JamoCoCreateDetailStateDisplay) -> UIView {
        let tint = UIColor.jamoHex(display.tintHex) ?? JamoRiffTheme.orange
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = tint.withAlphaComponent(0.12)
        container.layer.cornerRadius = 18
        container.layer.borderWidth = 1
        container.layer.borderColor = tint.withAlphaComponent(0.18).cgColor

        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = tint
        dot.layer.cornerRadius = 5

        let labelStack = UIStackView()
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        labelStack.axis = .vertical
        labelStack.spacing = 4

        let title = UILabel()
        title.text = display.title
        title.textColor = JamoRiffTheme.ink
        title.font = JamoRiffTheme.bodyFont(14, weight: .heavy)

        let subtitle = UILabel()
        subtitle.text = display.subtitle
        subtitle.textColor = JamoRiffTheme.muted
        subtitle.font = JamoRiffTheme.bodyFont(12.5, weight: .medium)
        subtitle.numberOfLines = 0

        labelStack.addArrangedSubview(title)
        labelStack.addArrangedSubview(subtitle)

        container.addSubview(dot)
        container.addSubview(labelStack)
        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            dot.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            dot.widthAnchor.constraint(equalToConstant: 10),
            dot.heightAnchor.constraint(equalTo: dot.widthAnchor),

            labelStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            labelStack.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 10),
            labelStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            labelStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14)
        ])
        return container
    }

    private func makeParticipantStrip(_ snapshot: JamoCoCreateDetailSnapshot) -> UIView {
        let strip = JamoCoCreateParticipantStripView(participants: snapshot.participants, summary: snapshot.participantSummary)
        return strip
    }

    private func makePrimaryButton(_ action: JamoCoCreateActionDisplay) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = action.isEnabled
        button.addTarget(self, action: #selector(primaryActionTapped), for: .touchUpInside)
        button.accessibilityLabel = action.title
        button.clipsToBounds = false

        switch action.style {
        case .orange:
            button.setBackgroundImage(UIImage(named: "jamo_cocreate_detail_join_button")?.withRenderingMode(.alwaysOriginal), for: .normal)
        case .black:
            button.setBackgroundImage(UIImage(named: "jamo_cocreate_detail_view_my_part_button")?.withRenderingMode(.alwaysOriginal), for: .normal)
        case .disabled:
            let completedImage = UIImage(named: "jamo_cocreate_detail_completed_button")?
                .resizableImage(
                    withCapInsets: UIEdgeInsets(top: 22, left: 36, bottom: 22, right: 36),
                    resizingMode: .stretch
                )
                .withRenderingMode(.alwaysOriginal)
            button.setBackgroundImage(completedImage, for: .normal)
            button.setBackgroundImage(completedImage, for: .disabled)
            button.setTitle(nil, for: .normal)
        }

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 56)
        ])
        return button
    }

    private func makeBottomActionBar(_ snapshot: JamoCoCreateDetailSnapshot) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 4

        let row = UIStackView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 10
        container.addSubview(row)

        let primaryButton = makePrimaryButton(snapshot.primaryAction)
        primaryButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        primaryButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        row.addArrangedSubview(primaryButton)

        guard snapshot.state != .completedDetail else {
            NSLayoutConstraint.activate([
                row.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
                row.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                row.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14)
            ])
            return container
        }

        let inviteButton = UIButton(type: .custom)
        inviteButton.translatesAutoresizingMaskIntoConstraints = false
        inviteButton.setImage(UIImage(named: "jamo_cocreate_detail_invite_button")?.withRenderingMode(.alwaysOriginal), for: .normal)
        inviteButton.imageView?.contentMode = .scaleAspectFit
        inviteButton.accessibilityLabel = JamoRiffStringCipher.restore("IFnVv7iOtteZ NfZrjixefnldQsY")
        inviteButton.addTarget(self, action: #selector(inviteFriendsTapped), for: .touchUpInside)
        inviteButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        inviteButton.setContentHuggingPriority(.required, for: .horizontal)

        row.addArrangedSubview(inviteButton)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14),
            inviteButton.widthAnchor.constraint(equalToConstant: 56),
            inviteButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        return container
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
            view.widthAnchor.constraint(lessThanOrEqualToConstant: DetailLayout.maxContentWidth),
            width
        ])
        return container
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func openCreatorProfile() {
        guard let snapshot else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("UZnSaKbnlTeK steoV qo4pGeVnG 5tRhjiusy Opol3aCybexrH.L"))
            return
        }
        guard !snapshot.creator.userID.hasPrefix(JamoRiffStringCipher.restore("j5aNmOoj_esTedepde_3")) else {
            loadCreatorProfileThenOpen()
            return
        }
        openCreatorWebRoute(userID: snapshot.creator.userID)
    }

    private func openCreatorWebRoute(userID: String) {
        let route = JamoShowDefinition.musicianQuestionManager(playerHandle: userID)
        JamoShowDefinition.launchWorkflowBridge(route, from: self)
    }

    private func loadRemoteUsersIfNeeded() {
        guard !hasRequestedRemoteUsers else { return }
        hasRequestedRemoteUsers = true
        JamoCoCreateUserService.shared.fetchJamUsers { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                let users = (try? result.get()) ?? []
                guard !users.isEmpty else { return }
                self.remoteUsers = users
                self.render()
            }
        }
    }

    private func loadCreatorProfileThenOpen() {
        JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("LOofaddjionBgE DpfluaVylerrk 0iHnefYou.u.G.u"))
        JamoCoCreateUserService.shared.fetchJamUsers { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                let users = (try? result.get()) ?? []
                self.remoteUsers = users
                self.render()
                guard let refreshed = self.viewModel.makeDetailSnapshot(workID: self.workID, remoteUsers: users),
                      !refreshed.creator.userID.hasPrefix(JamoRiffStringCipher.restore("jFajmmoV_bsWe3e5d3_1")) else {
                    JamoRiffNoticeView.show(on: self.view, copy: JamoRiffStringCipher.restore("UdnYa1b1l3e8 mtOo0 jocpLesnn 2tQhei9sS ypll3aWyDeirl.x"))
                    return
                }
                self.openCreatorWebRoute(userID: refreshed.creator.userID)
            }
        }
    }

    @objc private func treeTapped() {
        guard let work = viewModel.work(withID: workID) else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("T7h2iisB UjHa9m5 dihsc MuGnYalvka8i1l7awbSl9ef.K"))
            return
        }
        let mode = treeMode(for: work)
        navigationController?.pushViewController(JamoCoCreateTreeViewController(work: work, mode: mode), animated: true)
    }

    @objc private func toggleHeroPlayback() {
        togglePlayback(id: heroPlaybackID, mp3FileName: primaryMP3FileName())
    }

    @objc private func heroReportTapped(_ sender: UIButton) {
        guard viewModel.work(withID: workID) != nil else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("TkhciBsG bjGaXm4 piAsz kunn9a7v7azi8lOaybvlKeP.4"))
            return
        }
        jamoPresentCoCreateModerationSheet(workID: workID, sourceView: sender) { [weak self] workID in
            guard let self else { return }
            self.viewModel.blockWork(withID: workID)
            JamoRiffNoticeView.show(on: self.view, copy: JamoRiffStringCipher.restore("T4h6iRsv djma1mr shQa8ss 7bUebeDnY TbTlTolc2koeBdf.Y"))
            self.navigationController?.popViewController(animated: true)
        } onReport: { [weak self] workID in
            guard let self else { return }
            JamoShowDefinition.launchWorkflowBridge(.clipReviewManager(riffHandle: workID), from: self)
        }
    }

    @objc private func partRowTapped(_ sender: JamoCoCreatePartRowView) {
        togglePlayback(id: sender.partID, mp3FileName: sender.mp3FileName)
    }

    @objc private func inviteFriendsTapped() {
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
            JamoRiffNoticeView.show(on: self.view, copy: JamoRiffStringCipher.restore("I4ncvbiItFeU nlZiUnIkW DcGo7p4iXe9dG.n"))
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
        guard let snapshot else {
            return JamoRiffStringCipher.restore("JtoPi3nD ImHyV 8JpadmEoE lcBoc-vcErBejattreg.q")
        }
        return JamoRiffStringCipher.restore("JDoLiRns sm4yn gJmaTmuo5 qcJoZ-xcer0e9a0tqeT:G w") + snapshot.title + String(UnicodeScalar(10)!) + JamoRiffStringCipher.restore("j8aGmaoi:H/n/tcToR-ecbr9eCauthet/w") + snapshot.workID
    }

    private func togglePlayback(id: String, mp3FileName: String?) {
        if activePlaybackID == id, isPlaying {
            pausePlayback()
        } else {
            startPlayback(id: id, mp3FileName: mp3FileName)
        }
    }

    private func startPlayback(id: String, mp3FileName: String?) {
        guard let fileName = mp3FileName, !fileName.isEmpty else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("N5oN QgKuniLtcaJrG Gamurdui2oM siGsO qaGvTaNi7leaWb5lHeG.i"))
            return
        }
        guard let audioURL = JamoRiffLocalMediaShelf.resourceURL(named: fileName) else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("UQnJadb1lver GtloH glOodaRdY TtdhQiVs0 igEuxiMtyafrG raguAdKiLos.n"))
            return
        }

        do {
            if activePlaybackID != id || activeMP3FileName != fileName || audioPlayer == nil {
                stopPlayback(resetProgress: true)
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.prepareToPlay()
                activeMP3FileName = fileName
                activePlaybackID = id
            }
            guard let audioPlayer else {
                JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("UinVa8bAlMeG xtAop ApjlEa3yd otdhXitsY Vg8u7iZtkajrU GaLugdAiTo1.V"))
                return
            }
            if audioPlayer.currentTime >= max(audioPlayer.duration - 0.2, 0) {
                audioPlayer.currentTime = 0
            }
            guard audioPlayer.play() else {
                isPlaying = false
                updatePlaybackViews()
                JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("Uhn0anbwl1eg Qt2o2 Sp3lKazyO 4tkhqibsv ygpuhi5tkaPrD va6uOdpiwoE.l"))
                return
            }
            isPlaying = true
            startPlaybackTimer()
            updatePlaybackViews()
        } catch {
            isPlaying = false
            updatePlaybackViews()
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("Ufn7aVbMlqeH 5tcod Gpbl5a4yg ctBh2iTsX fgGurixtiaDrB zaruAdqi3oG.u"))
        }
    }

    private func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        stopPlaybackTimer()
        updatePlaybackViews()
    }

    private func stopPlayback(resetProgress: Bool) {
        stopPlaybackTimer()
        if resetProgress {
            audioPlayer?.stop()
            audioPlayer?.currentTime = 0
            activePlaybackID = nil
            activeMP3FileName = nil
        } else {
            audioPlayer?.pause()
        }
        isPlaying = false
        updatePlaybackViews()
    }

    private func startPlaybackTimer() {
        stopPlaybackTimer()
        let timer = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.handlePlaybackTick()
        }
        playbackTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    private func handlePlaybackTick() {
        guard let audioPlayer else {
            stopPlayback(resetProgress: true)
            return
        }
        let remaining = max(audioPlayer.duration - audioPlayer.currentTime, 0)
        if remaining <= 0.15 || !audioPlayer.isPlaying {
            audioPlayer.stop()
            audioPlayer.currentTime = 0
            isPlaying = false
            stopPlaybackTimer()
            activePlaybackID = nil
            activeMP3FileName = nil
        }
        updatePlaybackViews()
    }

    private func updatePlaybackViews() {
        guard let snapshot else { return }
        heroView?.updatePlayback(
            isPlaying: activePlaybackID == heroPlaybackID && isPlaying,
            durationText: currentHeroDurationText(snapshot)
        )
        snapshot.currentParts.forEach { part in
            partRows[part.id]?.updatePlayback(
                isPlaying: activePlaybackID == part.id && isPlaying,
                durationText: currentPartDurationText(part)
            )
        }
    }

    private func primaryMP3FileName() -> String? {
        snapshot?.currentParts.first(where: { $0.mp3FileName?.isEmpty == false })?.mp3FileName
    }

    private func currentHeroDurationText(_ snapshot: JamoCoCreateDetailSnapshot) -> String {
        if let audioPlayer, activePlaybackID == heroPlaybackID, activeMP3FileName == primaryMP3FileName() {
            let remaining = isPlaying || audioPlayer.currentTime > 0
                ? max(audioPlayer.duration - audioPlayer.currentTime, 0)
                : audioPlayer.duration
            return durationText(remaining)
        }
        return snapshot.currentParts.first?.durationText ?? JamoRiffStringCipher.restore("0h:X0q0m")
    }

    private func currentPartDurationText(_ part: JamoCoCreatePartDisplay) -> String {
        if let audioPlayer, activePlaybackID == part.id, activeMP3FileName == part.mp3FileName {
            let remaining = isPlaying || audioPlayer.currentTime > 0
                ? max(audioPlayer.duration - audioPlayer.currentTime, 0)
                : audioPlayer.duration
            return durationText(remaining)
        }
        return part.durationText
    }

    private func treeMode(for work: JamoCoCreateWork) -> JamoRiffBranchViewMode {
        let currentRiffHandle = JamoRiffIdentityArchive.sharedArchive.currentPlayerHandle ?? JamoRiffStringCipher.restore("jRaAmZoc_TlyoJcrakl4_Jpel1aGy7emrL")
        if work.creatorUserID == currentRiffHandle || work.creatorUserID == JamoRiffStringCipher.restore("cguVr3rJe0nxtc_cuGsPeBr5") {
            return .publisherBranches
        }
        let participantCount = max(work.participants?.count ?? 0, Set(work.tracks.map(\.ownerUserID)).count)
        if participantCount <= 1 {
            return .singleLine
        }
        return .myPart
    }

    private func durationText(_ duration: TimeInterval) -> String {
        let seconds = max(Int(duration.rounded(.up)), 0)
        return String(format: JamoRiffStringCipher.restore("%jdq:k%N002xd0"), seconds / 60, seconds % 60)
    }

    @objc private func primaryActionTapped() {
        guard let snapshot else {
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("Tnh2ixsW kjVatmR cimsK NuvngahvwaJiVlnaRbalseQ.i"))
            return
        }
        switch snapshot.state {
        case .joinableDetail:
            presentJoinMethodSheet(snapshot)
        case .joinedDetail:
            guard snapshot.primaryAction.isEnabled else {
                JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("TChVius9 FjAaLme xc4aVnfn4ottA RbBeO QcEoinEtxiWnHuge3d0.L"))
                return
            }
            guard let work = viewModel.work(withID: workID) else {
                JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("TAh7iVsE jjPaYmU 4imsp BuunwacvuaYinlZaebgljep.C"))
                return
            }
            stopPlayback(resetProgress: true)
            navigationController?.pushViewController(JamoCoCreateTreeViewController(work: work, mode: .myPart), animated: true)
        case .completedDetail:
            JamoRiffNoticeView.show(on: view, copy: JamoRiffStringCipher.restore("TBhhivsQ AcEo3-TcJrOeha0tSeZ 4iGsk mctoTmWpJlweEtleTdT.F"))
        case .openJams, .empty:
            break
        }
    }

    private func presentJoinMethodSheet(_ snapshot: JamoCoCreateDetailSnapshot) {
        methodSheet?.removeFromSuperview()
        let sheet = JamoCoCreateJoinMethodSheetView(methods: snapshot.joinMethods)
        methodSheet = sheet
        sheet.translatesAutoresizingMaskIntoConstraints = false
        sheet.onDismiss = { [weak self] in
            self?.methodSheet?.removeFromSuperview()
            self?.methodSheet = nil
        }
        sheet.onContinue = { [weak self] method in
            guard let self else { return }
            self.methodSheet?.removeFromSuperview()
            self.methodSheet = nil
            guard let work = self.viewModel.work(withID: self.workID) else {
                JamoRiffNoticeView.show(on: self.view, copy: JamoRiffStringCipher.restore("TIhlius7 hjqaImj iiSsH duzneaev6aOiXloahbqlSeI.r"))
                return
            }
            self.stopPlayback(resetProgress: true)
            self.navigationController?.pushViewController(
                JamoCoCreateEditorViewController(work: work, selectedJoinMethod: method),
                animated: true
            )
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
}

final class JamoCoCreateTreeViewController: JamoRiffBaseStageViewController {
    private enum TreeMetrics {
        static let maxContentWidth: CGFloat = 390
        static let horizontalInset: CGFloat = 16
        static let cardRadius: CGFloat = 22
    }

    private let work: JamoCoCreateWork
    private let mode: JamoRiffBranchViewMode

    init(work: JamoCoCreateWork, mode: JamoRiffBranchViewMode) {
        self.work = work
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("i0nAiJtm(ec4oIdUePr6:R)J dhyafsH qnuojtU jbZeGePnU Bimm6p9lSesmteXn8t9eQdE"))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.showsVerticalScrollIndicator = false
        render()
    }

    override func configureScrollLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    private func render() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        let topBar = makeTopBar()
        let headerCard = makeHeaderCard()
        let modeSummary = makeModeSummary()
        let trackChain = makeTrackChain()
        [topBar, headerCard, modeSummary, trackChain].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate(
            pageWidthConstraints(for: topBar) +
            pageWidthConstraints(for: headerCard) +
            pageWidthConstraints(for: modeSummary) +
            pageWidthConstraints(for: trackChain) +
            [
                topBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
                headerCard.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 14),
                modeSummary.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 18),
                trackChain.topAnchor.constraint(equalTo: modeSummary.bottomAnchor, constant: 14),
                trackChain.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 0),
                trackChain.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: 0),
                
                trackChain.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
            ]
        )
    }

    private func makeTopBar() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let backButton = UIButton(type: .custom)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle(JamoRiffStringCipher.restore("‹m"), for: .normal)
        backButton.setTitleColor(JamoRiffTheme.ink, for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 34, weight: .semibold)
        backButton.backgroundColor = .white
        backButton.layer.cornerRadius = 20
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = mode.title
        title.textColor = JamoRiffTheme.ink
        title.font = JamoRiffTheme.titleFont(18)
        title.textAlignment = .center

        container.addSubview(backButton)
        container.addSubview(title)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 46),
            backButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 42),
            backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor),

            title.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            title.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 14),
            title.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -54)
        ])
        return container
    }

    private func makeHeaderCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.black.withAlphaComponent(0.08)
        card.layer.cornerRadius = TreeMetrics.cardRadius
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.black.withAlphaComponent(0.05).cgColor
        card.clipsToBounds = true

        let cover = UIImageView(image: treeCoverImage() ?? UIImage(named: "jamo_cocreate_publish_work_cover"))
        cover.translatesAutoresizingMaskIntoConstraints = false
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true

        let shade = UIView()
        shade.translatesAutoresizingMaskIntoConstraints = false
        shade.backgroundColor = UIColor.black.withAlphaComponent(0.36)

        let icon = UIImageView(image: UIImage(named: "jamo_cocreate_detail_tree_button"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
       
        icon.layer.cornerRadius = 18

        let labels = UIView()
        labels.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = work.title
        title.textColor = .white
        title.font = JamoRiffTheme.titleFont(21)
        title.numberOfLines = 2

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = mode.subtitle
        subtitle.textColor = UIColor.white.withAlphaComponent(0.88)
        subtitle.font = JamoRiffTheme.bodyFont(12.5, weight: .semibold)
        subtitle.numberOfLines = 0

        let countPill = UILabel()
        countPill.translatesAutoresizingMaskIntoConstraints = false
        countPill.text = String(work.tracks.count) + JamoRiffStringCipher.restore(" 5paaWrqtPs3")
        countPill.textAlignment = .center
        countPill.textColor = JamoRiffTheme.ink
        countPill.font = JamoRiffTheme.bodyFont(11.5, weight: .heavy)
        countPill.backgroundColor = .white
        countPill.layer.cornerRadius = 15
        countPill.clipsToBounds = true

        labels.addSubview(title)
        labels.addSubview(subtitle)
        card.addSubview(cover)
        card.addSubview(shade)
        card.addSubview(icon)
        card.addSubview(labels)
        card.addSubview(countPill)
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 128),
            cover.topAnchor.constraint(equalTo: card.topAnchor),
            cover.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            cover.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            cover.heightAnchor.constraint(equalToConstant: 128),
            shade.topAnchor.constraint(equalTo: card.topAnchor),
            shade.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            shade.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            shade.bottomAnchor.constraint(equalTo: card.bottomAnchor),

            icon.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            icon.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            icon.widthAnchor.constraint(equalToConstant: 81),
            icon.heightAnchor.constraint(equalToConstant: 40),

            labels.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            labels.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 14),
            labels.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            labels.bottomAnchor.constraint(lessThanOrEqualTo: countPill.topAnchor, constant: -12),

            title.topAnchor.constraint(equalTo: labels.topAnchor),
            title.leadingAnchor.constraint(equalTo: labels.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: labels.trailingAnchor),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5),
            subtitle.leadingAnchor.constraint(equalTo: labels.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: labels.trailingAnchor),
            subtitle.bottomAnchor.constraint(equalTo: labels.bottomAnchor),

            countPill.leadingAnchor.constraint(equalTo: labels.leadingAnchor),
            countPill.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            countPill.widthAnchor.constraint(greaterThanOrEqualToConstant: 76),
            countPill.heightAnchor.constraint(equalToConstant: 30)
        ])
        return card
    }

    private func treeCoverImage() -> UIImage? {
        if let coverURL = work.coverURL,
           let url = URL(string: coverURL),
           url.isFileURL,
           let image = UIImage(contentsOfFile: url.path) {
            return image
        }
        return UIImage.jamoCoCreateMedia(named: work.coverImageName)
    }

    private func makeModeSummary() -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = JamoRiffTheme.pink
        dot.layer.cornerRadius = 4

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = mode == .singleLine ? JamoRiffStringCipher.restore("Rlipfcfo uC6hxauicnV") : JamoRiffStringCipher.restore("BZrRaUnqcnhC ZMGa9pt")
        title.textColor = JamoRiffTheme.ink
        title.font = JamoRiffTheme.titleFont(20)

        let caption = UILabel()
        caption.translatesAutoresizingMaskIntoConstraints = false
        caption.text = work.status == .completed ? JamoRiffStringCipher.restore("C8oymHpBlcewtDetdv") : JamoRiffStringCipher.restore("OQp4evnb")
        caption.textAlignment = .center
        caption.textColor = work.status == .completed ? UIColor.white : JamoRiffTheme.orange
        caption.font = JamoRiffTheme.bodyFont(11.5, weight: .heavy)
        caption.backgroundColor = work.status == .completed ? JamoRiffTheme.ink : UIColor(red: 255 / 255, green: 235 / 255, blue: 220 / 255, alpha: 1)
        caption.layer.cornerRadius = 13
        caption.clipsToBounds = true

        row.addSubview(title)
        row.addSubview(dot)
        row.addSubview(caption)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            title.topAnchor.constraint(equalTo: row.topAnchor),
            title.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            title.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            dot.leadingAnchor.constraint(equalTo: title.trailingAnchor, constant: 10),
            dot.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalTo: dot.widthAnchor),
            caption.leadingAnchor.constraint(greaterThanOrEqualTo: dot.trailingAnchor, constant: 12),
            caption.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            caption.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            caption.widthAnchor.constraint(greaterThanOrEqualToConstant: 76),
            caption.heightAnchor.constraint(equalToConstant: 26)
        ])
        return row
    }

    private func makeTrackChain() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let rail = UIView()
        rail.translatesAutoresizingMaskIntoConstraints = false
        rail.backgroundColor = UIColor(red: 224 / 255, green: 216 / 255, blue: 205 / 255, alpha: 1)
        rail.layer.cornerRadius = 2

        var nodes: [UIView] = work.tracks.enumerated().map { index, track in
            makeTrackNode(track: track, index: index)
        }
        if let needed = work.neededPart, work.status != .completed {
            nodes.append(makeNeedNode(needed))
        }

        if !nodes.isEmpty {
            container.addSubview(rail)
        }
        nodes.forEach { container.addSubview($0) }

        var nodeConstraints: [NSLayoutConstraint] = []
        var previousNode: UIView?
        nodes.forEach { node in
            nodeConstraints.append(contentsOf: [
                node.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                node.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            ])
            if let previousNode {
                nodeConstraints.append(node.topAnchor.constraint(equalTo: previousNode.bottomAnchor, constant: 12))
            } else {
                nodeConstraints.append(node.topAnchor.constraint(equalTo: container.topAnchor))
            }
            previousNode = node
        }
        if let previousNode {
            nodeConstraints.append(previousNode.bottomAnchor.constraint(equalTo: container.bottomAnchor))
        } else {
            nodeConstraints.append(container.heightAnchor.constraint(equalToConstant: 1))
        }

        let railConstraints: [NSLayoutConstraint] = nodes.isEmpty ? [] : [
            rail.topAnchor.constraint(equalTo: container.topAnchor, constant: 30),
            rail.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -30),
            rail.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 31),
            rail.widthAnchor.constraint(equalToConstant: 4)
        ]
        NSLayoutConstraint.activate(railConstraints + nodeConstraints)
        return container
    }

    private func makeTrackNode(track: JamoCoCreateTrack, index: Int) -> UIView {
        let node = UIView()
        node.translatesAutoresizingMaskIntoConstraints = false
        node.backgroundColor = track.isMine ? UIColor(red: 255 / 255, green: 226 / 255, blue: 240 / 255, alpha: 1) : .white
        node.layer.cornerRadius = 20
        node.layer.cornerCurve = .continuous
        node.layer.borderWidth = 1
        node.layer.borderColor = track.isMine ? JamoRiffTheme.pink.withAlphaComponent(0.38).cgColor : UIColor.black.withAlphaComponent(0.06).cgColor

        let nodeDot = UIView()
        nodeDot.translatesAutoresizingMaskIntoConstraints = false
        nodeDot.backgroundColor = track.isMine ? JamoRiffTheme.pink : JamoRiffTheme.orange
        nodeDot.layer.cornerRadius = 13
        nodeDot.layer.borderWidth = 4
        nodeDot.layer.borderColor = JamoRiffTheme.background.cgColor

        let labels = UIView()
        labels.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = track.roleName
        title.textColor = JamoRiffTheme.ink
        title.font = JamoRiffTheme.bodyFont(15, weight: .heavy)

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = track.isMine ? JamoRiffStringCipher.restore("Mxyr gppabrHtI 4·R V") + track.ownerName : track.ownerName
        subtitle.textColor = JamoRiffTheme.muted
        subtitle.font = JamoRiffTheme.bodyFont(12, weight: .medium)

        let meta = UILabel()
        meta.translatesAutoresizingMaskIntoConstraints = false
        meta.text = durationText(track.duration) + JamoRiffStringCipher.restore(" B·n ELEaoy5ecrm G") + String(index + 1)
        meta.textColor = track.isMine ? JamoRiffTheme.pink : JamoRiffTheme.orange
        meta.font = JamoRiffTheme.bodyFont(11, weight: .heavy)

        let waveform = JamoTreeWaveformView()
        waveform.translatesAutoresizingMaskIntoConstraints = false
        waveform.seed = track.waveformSeed
        waveform.barColor = track.isMine ? JamoRiffTheme.pink : UIColor(red: 222 / 255, green: 218 / 255, blue: 209 / 255, alpha: 1)
        waveform.secondaryBarColor = track.isMine ? JamoRiffTheme.orange : UIColor(red: 198 / 255, green: 192 / 255, blue: 183 / 255, alpha: 1)

        labels.addSubview(title)
        labels.addSubview(subtitle)
        labels.addSubview(meta)
        node.addSubview(nodeDot)
        node.addSubview(labels)
        node.addSubview(waveform)
        NSLayoutConstraint.activate([
            node.heightAnchor.constraint(greaterThanOrEqualToConstant: 96),
            nodeDot.leadingAnchor.constraint(equalTo: node.leadingAnchor, constant: 18),
            nodeDot.topAnchor.constraint(equalTo: node.topAnchor, constant: 21),
            nodeDot.widthAnchor.constraint(equalToConstant: 26),
            nodeDot.heightAnchor.constraint(equalTo: nodeDot.widthAnchor),

            labels.topAnchor.constraint(equalTo: node.topAnchor, constant: 14),
            labels.leadingAnchor.constraint(equalTo: nodeDot.trailingAnchor, constant: 14),
            labels.trailingAnchor.constraint(equalTo: node.trailingAnchor, constant: -14),
            title.topAnchor.constraint(equalTo: labels.topAnchor),
            title.leadingAnchor.constraint(equalTo: labels.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: labels.trailingAnchor),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5),
            subtitle.leadingAnchor.constraint(equalTo: labels.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: labels.trailingAnchor),
            meta.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 5),
            meta.leadingAnchor.constraint(equalTo: labels.leadingAnchor),
            meta.trailingAnchor.constraint(equalTo: labels.trailingAnchor),
            meta.bottomAnchor.constraint(equalTo: labels.bottomAnchor),
            waveform.topAnchor.constraint(equalTo: labels.bottomAnchor, constant: 10),
            waveform.leadingAnchor.constraint(equalTo: labels.leadingAnchor),
            waveform.trailingAnchor.constraint(equalTo: labels.trailingAnchor),
            waveform.heightAnchor.constraint(equalToConstant: 18),
            waveform.bottomAnchor.constraint(equalTo: node.bottomAnchor, constant: -14)
        ])
        return node
    }

    private func makeNeedNode(_ needed: JamoCoCreateNeededPart) -> UIView {
        let node = UIView()
        node.translatesAutoresizingMaskIntoConstraints = false
        node.backgroundColor = JamoRiffTheme.ink
        node.layer.cornerRadius = 20
        node.layer.cornerCurve = .continuous

        let iconTile = UIView()
        iconTile.translatesAutoresizingMaskIntoConstraints = false
        iconTile.backgroundColor = JamoRiffTheme.pink
        iconTile.layer.cornerRadius = 15

        let icon = UIImageView(image: UIImage(named: "jamo_cocreate_need_pick_icon")?.withRenderingMode(.alwaysOriginal))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = JamoRiffStringCipher.restore("N5ECE3De") + String(UnicodeScalar(10)!) + needed.subtitle
        label.textColor = .white
        label.font = JamoRiffTheme.bodyFont(13, weight: .heavy)
        label.numberOfLines = 0

        node.addSubview(iconTile)
        iconTile.addSubview(icon)
        node.addSubview(label)
        NSLayoutConstraint.activate([
            node.heightAnchor.constraint(greaterThanOrEqualToConstant: 74),
            iconTile.leadingAnchor.constraint(equalTo: node.leadingAnchor, constant: 18),
            iconTile.centerYAnchor.constraint(equalTo: node.centerYAnchor),
            iconTile.widthAnchor.constraint(equalToConstant: 42),
            iconTile.heightAnchor.constraint(equalTo: iconTile.widthAnchor),
            icon.centerXAnchor.constraint(equalTo: iconTile.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconTile.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor),

            label.topAnchor.constraint(equalTo: node.topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: iconTile.trailingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: node.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: node.bottomAnchor, constant: -16)
        ])
        return node
    }

    private func pageWidthConstraints(for view: UIView) -> [NSLayoutConstraint] {
        let width = view.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -TreeMetrics.horizontalInset * 2)
        width.priority = .defaultLow
        return [
            view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            view.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: TreeMetrics.horizontalInset),
            view.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -TreeMetrics.horizontalInset),
            view.widthAnchor.constraint(lessThanOrEqualToConstant: TreeMetrics.maxContentWidth),
            width
        ]
    }

    private func durationText(_ duration: TimeInterval) -> String {
        let seconds = max(Int(duration.rounded()), 0)
        return String(format: JamoRiffStringCipher.restore("%ydU:v%p0h2Adz"), seconds / 60, seconds % 60)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

private final class JamoTreeWaveformView: UIView {
    var seed: Int = 1 {
        didSet { setNeedsDisplay() }
    }

    var barColor: UIColor = UIColor(red: 222 / 255, green: 218 / 255, blue: 209 / 255, alpha: 1) {
        didSet { setNeedsDisplay() }
    }

    var secondaryBarColor: UIColor = UIColor(red: 198 / 255, green: 192 / 255, blue: 183 / 255, alpha: 1) {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("ifnDi3t6(xcQoudEeYrA:2)u jhGajsB knfoXt4 rbJeVewnU AiwmJp9lQebmMepn7tseXdN"))
    }

    override func draw(_ rect: CGRect) {
        guard rect.width > 0, rect.height > 0 else { return }
        let count = max(Int(rect.width / 7), 18)
        let spacing: CGFloat = 3
        let barWidth = max((rect.width - CGFloat(count - 1) * spacing) / CGFloat(count), 2)
        let midY = rect.midY
        for index in 0..<count {
            let phase = CGFloat(((index + seed) * 37) % 11) / 10
            let scale = 0.34 + phase * 0.66
            let height = max(5, rect.height * scale)
            let x = CGFloat(index) * (barWidth + spacing)
            let y = midY - height / 2
            let path = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: barWidth, height: height), cornerRadius: barWidth / 2)
            (index % 4 == 0 ? secondaryBarColor : barColor).setFill()
            path.fill()
        }
    }
}

private final class JamoCoCreateDetailHeroView: UIView {
    let playButton = UIButton(type: .custom)
    let reportButton = UIButton(type: .custom)
    private let waveformView = UIImageView(image: UIImage(named: "jamo_cocreate_detail_waveform"))
    private let durationLabel = UILabel()

    init(snapshot: JamoCoCreateDetailSnapshot, isPlaying: Bool, durationText: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = JamoRiffTheme.orange.withAlphaComponent(0.18)
        layer.cornerRadius = 24
        clipsToBounds = true
        buildContent(snapshot: snapshot, isPlaying: isPlaying, durationText: durationText)
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iVniijty(kcRoYd7euri:s)j chfavs1 BnyoDtl MbHe0eUnv ZidmJpvlMeGmlemn3tJeAdM"))
    }

    func updatePlayback(isPlaying: Bool, durationText: String) {
        playButton.setImage(UIImage(named: isPlaying ? "jamo_cocreate_detail_pause" : "jamo_cocreate_detail_play"), for: .normal)
        playButton.accessibilityLabel = isPlaying ? JamoRiffStringCipher.restore("PUa0unskeo") : JamoRiffStringCipher.restore("Pxlta9yd")
        waveformView.alpha = isPlaying ? 1 : 0.56
        durationLabel.text = durationText
        durationLabel.textColor = isPlaying ? JamoRiffTheme.yellow : .white
    }

    private func buildContent(snapshot: JamoCoCreateDetailSnapshot, isPlaying: Bool, durationText: String) {
        let imageView = UIImageView(image: UIImage.jamoCoCreateMedia(named: snapshot.coverImageName) ?? UIImage(named: "jamo_cocreate_publish_work_cover"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = JamoRiffTheme.navy.withAlphaComponent(0.12)

        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.04)

        let tag = snapshot.tags.first.map { JamoCoCreateTagView(text: $0) }

        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setImage(UIImage(named: isPlaying ? "jamo_cocreate_detail_pause" : "jamo_cocreate_detail_play"), for: .normal)
        playButton.imageView?.contentMode = .scaleAspectFit
        playButton.accessibilityLabel = isPlaying ? JamoRiffStringCipher.restore("PLahumsdeG") : JamoRiffStringCipher.restore("PElPawyj")

        reportButton.translatesAutoresizingMaskIntoConstraints = false
        reportButton.setImage(UIImage(named: "jamo_cocreate_card_more")?.withRenderingMode(.alwaysOriginal), for: .normal)
        reportButton.imageView?.contentMode = .scaleAspectFit
        reportButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
        reportButton.backgroundColor = UIColor.white.withAlphaComponent(0.92)
        reportButton.layer.cornerCurve = .continuous
        reportButton.layer.cornerRadius = 18
        reportButton.layer.borderWidth = 1
        reportButton.layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor
        reportButton.accessibilityLabel = JamoRiffStringCipher.restore("RKeKpuo1rdt5 7ofrR Lbzlconcgki Htvh1iqsr SjuaFmm")

        waveformView.translatesAutoresizingMaskIntoConstraints = false
        waveformView.contentMode = .scaleToFill
        waveformView.alpha = isPlaying ? 1 : 0.56

        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.text = durationText
        durationLabel.textColor = isPlaying ? JamoRiffTheme.yellow : .white
        durationLabel.font = JamoRiffTheme.bodyFont(10, weight: .bold)
        durationLabel.textAlignment = .right

        addSubview(imageView)
        addSubview(overlay)
        if let tag {
            addSubview(tag)
            NSLayoutConstraint.activate([
                tag.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
                tag.topAnchor.constraint(equalTo: topAnchor, constant: 14)
            ])
        }
        addSubview(playButton)
        addSubview(reportButton)
        addSubview(waveformView)
        addSubview(durationLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor),

            playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -4),
            playButton.widthAnchor.constraint(equalToConstant: 60),
            playButton.heightAnchor.constraint(equalTo: playButton.widthAnchor),

            reportButton.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            reportButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            reportButton.widthAnchor.constraint(equalToConstant: 36),
            reportButton.heightAnchor.constraint(equalTo: reportButton.widthAnchor),

            waveformView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            waveformView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            waveformView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
            waveformView.heightAnchor.constraint(equalToConstant: 24),

            durationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            durationLabel.bottomAnchor.constraint(equalTo: waveformView.bottomAnchor, constant: -1),
            durationLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 34)
        ])
    }
}

private final class JamoCoCreatePartRowView: UIControl {
    let partID: String
    let mp3FileName: String?

    private let playIcon = UIImageView(image: UIImage(named: "jamo_cocreate_part_play"))
    private let waveform = UIImageView(image: UIImage(named: "jamo_cocreate_detail_waveform"))
    private let durationLabel = UILabel()
    private let idleWaveformColor: UIColor
    private let activeWaveformColor: UIColor

    init(part: JamoCoCreatePartDisplay) {
        self.partID = part.id
        self.mp3FileName = part.mp3FileName
        self.idleWaveformColor = part.style == .mine ? JamoRiffTheme.pink : UIColor(red: 224 / 255, green: 221 / 255, blue: 214 / 255, alpha: 1)
        self.activeWaveformColor = part.style == .mine ? JamoRiffTheme.pink : UIColor(red: 192 / 255, green: 188 / 255, blue: 180 / 255, alpha: 1)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = part.style == .mine ? JamoRiffTheme.pink.withAlphaComponent(0.22) : .white
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = (part.style == .mine ? JamoRiffTheme.pink.withAlphaComponent(0.28) : UIColor.black.withAlphaComponent(0.06)).cgColor
        accessibilityLabel = part.title + JamoRiffStringCipher.restore(",j 7") + part.durationText
        buildContent(part)
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("icnOiltS(6cGoEd3eorL:0)S XhnaMsb znuoztG AbCeVeUna 9iwmspMlOeHmGefnCtheJdf"))
    }

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.82 : 1
        }
    }

    func updatePlayback(isPlaying: Bool, durationText: String) {
        playIcon.image = UIImage(named: isPlaying ? "jamo_cocreate_detail_pause" : "jamo_cocreate_part_play")
        waveform.tintColor = isPlaying ? activeWaveformColor : idleWaveformColor
        durationLabel.text = durationText
        durationLabel.textColor = isPlaying ? JamoRiffTheme.orange : JamoRiffTheme.muted
    }

    private func buildContent(_ part: JamoCoCreatePartDisplay) {
        playIcon.translatesAutoresizingMaskIntoConstraints = false
        playIcon.contentMode = .scaleAspectFit

        let contentStack = UIStackView()
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 6

        let titleRow = UIStackView()
        titleRow.translatesAutoresizingMaskIntoConstraints = false
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 6

        let title = UILabel()
        title.text = part.title
        title.textColor = JamoRiffTheme.ink
        title.font = JamoRiffTheme.bodyFont(12, weight: .heavy)
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleRow.addArrangedSubview(title)
        titleRow.addArrangedSubview(UIView())

        if part.style == .mine {
            let badge = JamoCoCreateStatusBadge(text: JamoRiffStringCipher.restore("MLYS zPgAuRSTd"), tint: JamoRiffTheme.pink)
            badge.setContentCompressionResistancePriority(.required, for: .horizontal)
            titleRow.insertArrangedSubview(badge, at: 1)
        }

        let waveformRow = UIStackView()
        waveformRow.translatesAutoresizingMaskIntoConstraints = false
        waveformRow.axis = .horizontal
        waveformRow.alignment = .center
        waveformRow.spacing = 8

        waveform.translatesAutoresizingMaskIntoConstraints = false
        waveform.contentMode = .scaleToFill
        waveform.image = UIImage(named: "jamo_cocreate_detail_waveform")?.withRenderingMode(.alwaysTemplate)
        waveform.tintColor = idleWaveformColor
        waveform.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.text = part.durationText
        durationLabel.textColor = JamoRiffTheme.muted
        durationLabel.font = JamoRiffTheme.bodyFont(10, weight: .medium)
        durationLabel.textAlignment = .right
        durationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        waveformRow.addArrangedSubview(waveform)
        waveformRow.addArrangedSubview(durationLabel)
        contentStack.addArrangedSubview(titleRow)
        contentStack.addArrangedSubview(waveformRow)

        addSubview(playIcon)
        addSubview(contentStack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 58),
            playIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            playIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            playIcon.widthAnchor.constraint(equalToConstant: 34),
            playIcon.heightAnchor.constraint(equalTo: playIcon.widthAnchor),

            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            contentStack.leadingAnchor.constraint(equalTo: playIcon.trailingAnchor, constant: 10),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10),

            waveform.heightAnchor.constraint(equalToConstant: 16),
            durationLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
    }
}

private final class JamoCoCreateNeededPartView: UIView {
    init(part: JamoCoCreateNeededPartDisplay) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = JamoRiffTheme.ink
        layer.cornerRadius = 18
        buildContent(part)
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iOndiJtS(3cloJdnesrO:x)4 khdahsZ fnWoCt2 SbgeReFnm UiQmvpZllezmceYnXtyemdj"))
    }

    private func buildContent(_ part: JamoCoCreateNeededPartDisplay) {
        let icon = UIImageView(image: UIImage(named: "jamo_cocreate_need_pick_icon"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        let labelStack = UIStackView()
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        labelStack.axis = .vertical
        labelStack.spacing = 3

        let need = UILabel()
        need.text = JamoRiffStringCipher.restore("NQEfEsDQ")
        need.textColor = JamoRiffTheme.yellow
        need.font = JamoRiffTheme.bodyFont(11, weight: .heavy)

        let subtitle = UILabel()
        subtitle.text = part.subtitle
        subtitle.textColor = .white
        subtitle.font = JamoRiffTheme.bodyFont(13, weight: .medium)
        subtitle.numberOfLines = 2

        labelStack.addArrangedSubview(need)
        labelStack.addArrangedSubview(subtitle)

        let duration = UILabel()
        duration.translatesAutoresizingMaskIntoConstraints = false
        duration.text = part.durationText
        duration.textColor = UIColor.white.withAlphaComponent(0.72)
        duration.font = JamoRiffTheme.bodyFont(11, weight: .bold)

        addSubview(icon)
        addSubview(labelStack)
        addSubview(duration)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 72),
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 44),
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor),

            labelStack.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            labelStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelStack.trailingAnchor.constraint(lessThanOrEqualTo: duration.leadingAnchor, constant: -10),

            duration.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            duration.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

private final class JamoCoCreateParticipantStripView: UIView {
    init(participants: [JamoCoCreateParticipantDisplay], summary: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        buildContent(participants: participants, summary: summary)
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iYn9isti(WcMoEd0e4r8:T)V lhBaMsf cnToYtg DbfeQefn1 Qium0p7l9ePmfe4njtfetdg"))
    }

    private func buildContent(participants: [JamoCoCreateParticipantDisplay], summary: String) {
        let avatarWrap = UIView()
        avatarWrap.translatesAutoresizingMaskIntoConstraints = false

        var previous: UIView?
        participants.prefix(5).enumerated().forEach { index, participant in
            let avatar = JamoCoCreateAvatarBadge(display: participant)
            avatar.layer.borderWidth = 1.5
            avatar.layer.borderColor = UIColor.white.cgColor
            avatarWrap.addSubview(avatar)
            NSLayoutConstraint.activate([
                avatar.leadingAnchor.constraint(equalTo: avatarWrap.leadingAnchor, constant: CGFloat(index) * 18),
                avatar.centerYAnchor.constraint(equalTo: avatarWrap.centerYAnchor)
            ])
            previous = avatar
        }

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = summary
        label.textColor = JamoRiffTheme.muted
        label.font = JamoRiffTheme.bodyFont(12, weight: .medium)
        label.numberOfLines = 2

        addSubview(avatarWrap)
        addSubview(label)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            avatarWrap.leadingAnchor.constraint(equalTo: leadingAnchor),
            avatarWrap.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarWrap.widthAnchor.constraint(equalToConstant: previous == nil ? 0 : 24 + CGFloat(max(0, min(participants.count, 5) - 1)) * 18),
            avatarWrap.heightAnchor.constraint(equalToConstant: 28),

            label.leadingAnchor.constraint(equalTo: avatarWrap.trailingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

private final class JamoCoCreateStatusBadge: UIView {
    init(text: String, tint: UIColor = UIColor(red: 91 / 255, green: 206 / 255, blue: 157 / 255, alpha: 1)) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = tint.withAlphaComponent(0.16)
        layer.cornerRadius = 10

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = tint
        label.font = JamoRiffTheme.bodyFont(8.5, weight: .heavy)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iVnciBtR(BctoxdXeor0:8)Z phbavsi pn7oUtk FbxeCeYna uiQmhpelveMmteNnatKe9dh"))
    }
}

final class JamoCoCreateNoFriendsSheetView: UIView {
    var onDismiss: (() -> Void)?
    var onCopyLink: (() -> Void)?

    private let dimView = UIView()
    private let sheetView = UIView()
    private var bottomConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildContent()
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("ignAiate(qcLo6dzemr3:x)4 NhUaVsN vnioPtz obTeQeVnK tipmsp9leeFmIesnQtjeJdc"))
    }

    func present() {
        layoutIfNeeded()
        dimView.alpha = 0
        bottomConstraint?.constant = sheetView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 40
        layoutIfNeeded()
        UIView.animate(withDuration: 0.24, delay: 0, options: [.curveEaseOut]) {
            self.dimView.alpha = 1
            self.bottomConstraint?.constant = 0
            self.layoutIfNeeded()
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.18, animations: {
            self.dimView.alpha = 0
            self.bottomConstraint?.constant = self.sheetView.bounds.height + 40
            self.layoutIfNeeded()
        }, completion: { _ in
            self.onDismiss?()
        })
    }

    private func buildContent() {
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.52)
        addSubview(dimView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissTapped))
        dimView.addGestureRecognizer(tap)

        sheetView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.backgroundColor = JamoRiffTheme.background
        sheetView.layer.cornerRadius = 30
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        addSubview(sheetView)

        let handle = UIView()
        handle.translatesAutoresizingMaskIntoConstraints = false
        handle.backgroundColor = UIColor.black.withAlphaComponent(0.16)
        handle.layer.cornerRadius = 3
        sheetView.addSubview(handle)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = JamoRiffStringCipher.restore("IZnlvTiNtceW Atmo7 7CNoV-7cCrhecaytVem")
        titleLabel.textColor = JamoRiffTheme.ink
        titleLabel.font = JamoRiffTheme.titleFont(28)
        titleLabel.numberOfLines = 0
        sheetView.addSubview(titleLabel)

        let contentStack = UIStackView()
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 18
        sheetView.addSubview(contentStack)

        let iconBox = JamoCoCreateInviteEmptyIconBox()
        contentStack.addArrangedSubview(iconBox)

        let copyStack = UIStackView()
        copyStack.axis = .vertical
        copyStack.alignment = .center
        copyStack.spacing = 8

        let emptyTitle = UILabel()
        emptyTitle.text = JamoRiffStringCipher.restore("NyoK Wf7rRizeznvdjsk KtSoO Bicn3vPiNtneJ YyaeUtP")
        emptyTitle.textColor = JamoRiffTheme.ink
        emptyTitle.font = JamoRiffTheme.titleFont(21)
        emptyTitle.numberOfLines = 0
        emptyTitle.textAlignment = .center

        let subtitle = UILabel()
        subtitle.text = JamoRiffStringCipher.restore("Cuoopwya Pt9hmew OlmiZn7kg 7aJnbdn wslhkairje8 hiSte gagniygwsh7eSrLeG.2")
        subtitle.textColor = JamoRiffTheme.muted
        subtitle.font = JamoRiffTheme.bodyFont(17, weight: .regular)
        subtitle.numberOfLines = 0
        subtitle.textAlignment = .center

        copyStack.addArrangedSubview(emptyTitle)
        copyStack.addArrangedSubview(subtitle)
        contentStack.addArrangedSubview(copyStack)

        let copyButton = UIButton(type: .custom)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.backgroundColor = JamoRiffTheme.ink
        copyButton.layer.cornerRadius = 28
        copyButton.setTitle(JamoRiffStringCipher.restore(" i cC9ojpYyE cLfiInbkx"), for: .normal)
        copyButton.setTitleColor(JamoRiffTheme.pink, for: .normal)
        copyButton.titleLabel?.font = JamoRiffTheme.titleFont(19)
        copyButton.setImage(UIImage(named: "jamo_home_quick_join_link_active")?.withRenderingMode(.alwaysTemplate), for: .normal)
        copyButton.tintColor = JamoRiffTheme.pink
        copyButton.imageView?.contentMode = .scaleAspectFit
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        sheetView.addSubview(copyButton)

        bottomConstraint = sheetView.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomConstraint?.isActive = true

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor),

            sheetView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sheetView.trailingAnchor.constraint(equalTo: trailingAnchor),

            handle.topAnchor.constraint(equalTo: sheetView.topAnchor, constant: 14),
            handle.centerXAnchor.constraint(equalTo: sheetView.centerXAnchor),
            handle.widthAnchor.constraint(equalToConstant: 42),
            handle.heightAnchor.constraint(equalToConstant: 6),

            titleLabel.topAnchor.constraint(equalTo: handle.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 22),
            titleLabel.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -22),

            contentStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 56),
            contentStack.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 32),
            contentStack.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -32),

            iconBox.widthAnchor.constraint(equalToConstant: 116),
            iconBox.heightAnchor.constraint(equalToConstant: 116),

            copyButton.topAnchor.constraint(equalTo: contentStack.bottomAnchor, constant: 42),
            copyButton.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 40),
            copyButton.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -40),
            copyButton.heightAnchor.constraint(equalToConstant: 56),
            copyButton.bottomAnchor.constraint(equalTo: sheetView.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    @objc private func copyTapped() {
        onCopyLink?()
    }

    @objc private func dismissTapped() {
        dismiss()
    }
}

private final class JamoCoCreateInviteEmptyIconBox: UIView {
    private let borderLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.white.withAlphaComponent(0.3)

        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor(red: 222 / 255, green: 216 / 255, blue: 204 / 255, alpha: 1).cgColor
        borderLayer.lineWidth = 1.4
        borderLayer.lineDashPattern = [5, 4]
        layer.addSublayer(borderLayer)

        let imageView = UIImageView(image: UIImage(named: "jamo_cocreate_publish_invite_friends")?.withRenderingMode(.alwaysTemplate))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(red: 142 / 255, green: 142 / 255, blue: 136 / 255, alpha: 1)
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 44),
            imageView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iMnviVtg(1cwo8dDeUrr:1)w mhNaQs0 rnCo0tZ VbueveXnf 5ibmSpzl7e0mMehnatTe6dn"))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 28
        borderLayer.frame = bounds
        borderLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), cornerRadius: 27).cgPath
    }
}

private final class JamoCoCreateJoinMethodSheetView: UIView {
    var onDismiss: (() -> Void)?
    var onContinue: ((JamoCoCreateJoinMethod) -> Void)?

    private let dimView = UIView()
    private let sheetView = UIView()
    private let continueButton = UIButton(type: .custom)
    private var optionViews: [JamoCoCreateJoinMethodOptionView] = []
    private var selectedMethod: JamoCoCreateJoinMethod?
    private var bottomConstraint: NSLayoutConstraint?

    init(methods: [JamoCoCreateJoinMethodDisplay]) {
        super.init(frame: .zero)
        buildContent(methods)
        updateContinueState()
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("imnUi5tf(VcboqdWeTrf:o)S uh9amsb cnYoDtG ubheKeAn1 kipmhpAlMeRmzehnLtaeadW"))
    }

    func present() {
        layoutIfNeeded()
        dimView.alpha = 0
        bottomConstraint?.constant = sheetView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 40
        layoutIfNeeded()
        UIView.animate(withDuration: 0.24, delay: 0, options: [.curveEaseOut]) {
            self.dimView.alpha = 1
            self.bottomConstraint?.constant = 0
            self.layoutIfNeeded()
        }
    }

    private func buildContent(_ methods: [JamoCoCreateJoinMethodDisplay]) {
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.48)
        addSubview(dimView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissTapped))
        dimView.addGestureRecognizer(tap)

        sheetView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.backgroundColor = JamoRiffTheme.background
        sheetView.layer.cornerRadius = 28
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        addSubview(sheetView)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        sheetView.addSubview(stack)

        let title = UILabel()
        title.text = JamoRiffStringCipher.restore("HWoqwQ sdFoz 1y8oUuL VwiaUnbtT lt5oH TjZoSijnX?u")
        title.textColor = JamoRiffTheme.ink
        title.font = JamoRiffTheme.titleFont(20)
        title.numberOfLines = 0
        stack.addArrangedSubview(title)

        methods.forEach { method in
            let option = JamoCoCreateJoinMethodOptionView(display: method)
            option.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            optionViews.append(option)
            stack.addArrangedSubview(option)
            if method.isSelected {
                selectedMethod = method.method
            }
        }

        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle(JamoRiffStringCipher.restore("COo7njtfiRnYuZeL"), for: .normal)
        continueButton.titleLabel?.font = JamoRiffTheme.bodyFont(16, weight: .heavy)
        continueButton.layer.cornerRadius = 24
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        stack.addArrangedSubview(continueButton)

        bottomConstraint = sheetView.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomConstraint?.isActive = true

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor),

            sheetView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sheetView.trailingAnchor.constraint(equalTo: trailingAnchor),

            stack.topAnchor.constraint(equalTo: sheetView.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: sheetView.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            continueButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func updateContinueState() {
        optionViews.forEach { $0.setSelected($0.method == selectedMethod) }
        let enabled = selectedMethod != nil
        continueButton.isEnabled = enabled
        continueButton.backgroundColor = enabled ? JamoRiffTheme.orange : UIColor(red: 235 / 255, green: 232 / 255, blue: 224 / 255, alpha: 1)
        continueButton.setTitleColor(enabled ? JamoRiffTheme.yellow : UIColor(red: 188 / 255, green: 183 / 255, blue: 172 / 255, alpha: 1), for: .normal)
    }

    @objc private func optionTapped(_ sender: JamoCoCreateJoinMethodOptionView) {
        selectedMethod = sender.method
        updateContinueState()
    }

    @objc private func continueTapped() {
        guard let selectedMethod else { return }
        onContinue?(selectedMethod)
    }

    @objc private func dismissTapped() {
        UIView.animate(withDuration: 0.18, animations: {
            self.dimView.alpha = 0
            self.bottomConstraint?.constant = self.sheetView.bounds.height + 40
            self.layoutIfNeeded()
        }, completion: { _ in
            self.onDismiss?()
        })
    }
}

private final class JamoCoCreateJoinMethodOptionView: UIControl {
    let method: JamoCoCreateJoinMethod

    private let radio = UIView()

    init(display: JamoCoCreateJoinMethodDisplay) {
        self.method = display.method
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 14
        layer.borderWidth = 1
        buildContent(display)
        setSelected(display.isSelected)
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iFn7iVt0(kcIofdFeerH:p)G VhiaZsT MnFoitk sbce9ePnT YiTmTpylgeHmkeknst3e5dR"))
    }

    private func buildContent(_ display: JamoCoCreateJoinMethodDisplay) {
        let icon = UIImageView(image: UIImage(named: imageName(for: display.method)))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        let labelStack = UIStackView()
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        labelStack.axis = .vertical
        labelStack.spacing = 3

        let title = UILabel()
        title.text = display.title
        title.textColor = JamoRiffTheme.ink
        title.font = JamoRiffTheme.bodyFont(13, weight: .heavy)

        let subtitle = UILabel()
        subtitle.text = display.subtitle
        subtitle.textColor = JamoRiffTheme.muted
        subtitle.font = JamoRiffTheme.bodyFont(11.5, weight: .regular)
        subtitle.numberOfLines = 2

        labelStack.addArrangedSubview(title)
        labelStack.addArrangedSubview(subtitle)

        radio.translatesAutoresizingMaskIntoConstraints = false
        radio.layer.cornerRadius = 10
        radio.layer.borderWidth = 1.5

        addSubview(icon)
        addSubview(labelStack)
        addSubview(radio)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 66),
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 44),
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor),

            labelStack.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            labelStack.trailingAnchor.constraint(lessThanOrEqualTo: radio.leadingAnchor, constant: -12),
            labelStack.centerYAnchor.constraint(equalTo: centerYAnchor),

            radio.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            radio.centerYAnchor.constraint(equalTo: centerYAnchor),
            radio.widthAnchor.constraint(equalToConstant: 20),
            radio.heightAnchor.constraint(equalTo: radio.widthAnchor)
        ])
    }

    func setSelected(_ selected: Bool) {
        backgroundColor = selected ? JamoRiffTheme.orange.withAlphaComponent(0.12) : .white
        layer.borderColor = selected ? JamoRiffTheme.orange.cgColor : UIColor.black.withAlphaComponent(0.08).cgColor
        radio.backgroundColor = selected ? JamoRiffTheme.orange : .clear
        radio.layer.borderColor = selected ? JamoRiffTheme.orange.cgColor : UIColor.black.withAlphaComponent(0.16).cgColor
    }

    private func imageName(for method: JamoCoCreateJoinMethod) -> String {
        switch method {
        case .recordGuitar:
            return JamoRiffStringCipher.restore("joa7mVoR_ccioKcrr8elaktpe3_bmXemtch9ond6_vr0eUcBo8r2dG_VgBuhiat6anrd")
        case .uploadClip:
            return JamoRiffStringCipher.restore("jEaVmmoQ_DcQoxcZr9eVa0tsev_AmkeVtphPo7dN_uuYpplnoSaVdh_FcClsiap7")
        case .addChords:
            return JamoRiffStringCipher.restore("jaaemWoc_0cGotchrAepa7tDeo_ZmaeytShjovd0_yaodndC_ScthRo2rtd2so")
        case .addMelody:
            return JamoRiffStringCipher.restore("jLa2mBoh_acEofchrpe9aYtxew_gmievtIhZoOdi_qaFdgdg_kmxeIlHoDd8y0")
        }
    }
}

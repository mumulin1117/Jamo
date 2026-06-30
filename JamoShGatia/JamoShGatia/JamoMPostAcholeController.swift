import UIKit

final class JamoRiffQuietInboxViewController: JamoRiffBaseStageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = nil
        contentStack.addArrangedSubview(makeMessagesHeader())

        let empty = JamoCardView()
        let label = makeBodyLabel(JamoRiffStringCipher.restore("Nfot vfZruiyeRnXdN 1mEeosIsMaEg7e0s9 Gyoect6.b"))
        label.textAlignment = .center
        empty.addPinnedSubview(label, inset: 24)
        contentStack.addArrangedSubview(empty)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    private func makeMessagesHeader() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = JamoRiffStringCipher.restore("MleRs8s9a0gZewsQ")
        titleLabel.textColor = JamoRiffTheme.ink
        titleLabel.font = JamoRiffTheme.titleFont(28)
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.82

        container.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }
}

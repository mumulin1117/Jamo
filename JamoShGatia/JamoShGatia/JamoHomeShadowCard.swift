//
//  JamoHomeShadowCard.swift
//  JamoShGatia
//
//  Created by mumu on 2026/6/25.
//

import UIKit

final class JamoHomeShadowCard: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 22
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 236 / 255, green: 231 / 255, blue: 220 / 255, alpha: 1).cgColor
        layer.shadowColor = UIColor(red: 40 / 255, green: 30 / 255, blue: 10 / 255, alpha: 1).cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("imntiptW(sc5oDdLeerB:i)b Oh7a5s2 VnQoNtQ qbee6eGnG VibmWpylZefmle1n9tneTdA"))
    }
}

final class JamoHomeDashedCard: UIView {
    private let borderLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 22
        layer.addSublayer(borderLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = bounds
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor(red: 226 / 255, green: 220 / 255, blue: 207 / 255, alpha: 1).cgColor
        borderLayer.lineWidth = 1
        borderLayer.lineDashPattern = [3, 4]
        borderLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 22).cgPath
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iInWimtP(QcuoCd0eNrn:9)p khEaBsz Knoomt7 gbLe1e6nc KiomWpsloelmGebnGtBeTdX"))
    }
}

final class JamoHomeAvatarView: UIImageView {
    init(name: String, imageName: String?) {
        super.init(frame: .zero)
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.cornerRadius = 16
        backgroundColor = UIColor(red: 255 / 255, green: 224 / 255, blue: 213 / 255, alpha: 1)
        image = imageName.flatMap { UIImage(named: $0) }
        if image == nil {
            addInitial(name)
        }
    }

    private func addInitial(_ name: String) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = String(name.prefix(1)).uppercased()
        label.font = JamoRiffTheme.titleFont(20)
        label.textColor = JamoRiffTheme.orange
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("ipnhiXtH(Jcqosdae1r9:r)0 uhda2sM kn1oQtO TbVe5eunU nismqpFlleDmAeanvtBeLdv"))
    }
}

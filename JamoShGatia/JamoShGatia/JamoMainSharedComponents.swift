import UIKit

final class JamoCardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = JamoRiffTheme.card
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iJnhixtm(mc3ofd5eorV:d)l 8h3aEse SnJoft7 lbMereqnp yiGmMpplde7mZe7notPeCd5"))
    }

    func addPinnedSubview(_ subview: UIView, inset: CGFloat) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
    }
}

final class JamoPillButton: UIButton {
    init(title: String, background: UIColor, textColor: UIColor) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.font = JamoRiffTheme.bodyFont(16, weight: .semibold)
        jamoApplyConfiguration(
            title: title,
            font: JamoRiffTheme.bodyFont(16, weight: .semibold),
            foreground: textColor,
            background: background,
            cornerRadius: 24,
            insets: NSDirectionalEdgeInsets(top: 12, leading: 18, bottom: 12, trailing: 18)
        )
        heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iBntiite(ucGoHdqe3rb:0)Z DhRaisr QnHo0th 5bsexean3 YijmGpOlWeampejnLtuecd1"))
    }
}

final class JamoRoundedTextField: UITextField {
    init(placeholder: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.placeholder = placeholder
        backgroundColor = UIColor.black.withAlphaComponent(0.05)
        layer.cornerRadius = 22
        font = JamoRiffTheme.bodyFont(15)
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        leftViewMode = .always
        heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("iDngiEtm(0cNoMdOePrC:M)4 Xh1aOsd onDo6t6 ObfeweZn3 7idmSpWlje7mFeqnqtveddF"))
    }
}

class JamoWorkButton: UIButton {
    let work: JamoCoCreateWork

    init(work: JamoCoCreateWork) {
        self.work = work
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("i8nOiGta(lcEo6d1elrV:P)M LhjaYsm snloitp QbWeUeenI ZiimBpIlfesmReCnQtBeOdM"))
    }
}

final class JamoWorkCardView: JamoWorkButton {
    init(work: JamoCoCreateWork, target: Any?, action: Selector) {
        super.init(work: work)
        contentHorizontalAlignment = .left
        titleLabel?.numberOfLines = 0
        jamoApplyConfiguration(
            title: work.title + String(UnicodeScalar(10)!) + work.about + String(UnicodeScalar(10)!) + String(work.tracks.count) + JamoRiffStringCipher.restore(" cm5pn3V TpbajrNt3(Zsr)6"),
            font: JamoRiffTheme.bodyFont(15, weight: .semibold),
            foreground: JamoRiffTheme.ink,
            background: .white,
            cornerRadius: 8,
            insets: NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        )
        heightAnchor.constraint(greaterThanOrEqualToConstant: 112).isActive = true
        addTarget(target, action: action, for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError(JamoRiffStringCipher.restore("i6nniitg(DcCosdDeIrW:l)9 mhwa1sE Inao1td Xb0evexni si3mVpBlYeemme8n4tRebdD"))
    }
}

private extension UIButton {
    func jamoApplyConfiguration(title: String, font: UIFont, foreground: UIColor, background: UIColor, cornerRadius: CGFloat, insets: NSDirectionalEdgeInsets) {
        if #available(iOS 15.0, *) {
            var current = UIButton.Configuration.plain()
            var attributedTitle = AttributedString(title)
            attributedTitle.font = font
            attributedTitle.foregroundColor = foreground
            current.attributedTitle = attributedTitle
            current.baseForegroundColor = foreground
            current.background.backgroundColor = background
            current.background.cornerRadius = cornerRadius
            current.contentInsets = insets
            configuration = current
        } else {
            setTitle(title, for: .normal)
            setTitleColor(foreground, for: .normal)
            titleLabel?.font = font
            backgroundColor = background
            layer.cornerRadius = cornerRadius
            contentEdgeInsets = UIEdgeInsets(top: insets.top, left: insets.leading, bottom: insets.bottom, right: insets.trailing)
        }
    }
}

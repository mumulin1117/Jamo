import UIKit

final class JamoCardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = JamoMainTheme.card
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        titleLabel?.font = JamoMainTheme.bodyFont(16, weight: .semibold)
        jamoApplyConfiguration(
            title: title,
            font: JamoMainTheme.bodyFont(16, weight: .semibold),
            foreground: textColor,
            background: background,
            cornerRadius: 24,
            insets: NSDirectionalEdgeInsets(top: 12, leading: 18, bottom: 12, trailing: 18)
        )
        heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class JamoRoundedTextField: UITextField {
    init(placeholder: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.placeholder = placeholder
        backgroundColor = UIColor.black.withAlphaComponent(0.05)
        layer.cornerRadius = 22
        font = JamoMainTheme.bodyFont(15)
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        leftViewMode = .always
        heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class JamoWorkButton: UIButton {
    let work: JamoCoCreateWork

    init(work: JamoCoCreateWork) {
        self.work = work
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class JamoWorkCardView: JamoWorkButton {
    init(work: JamoCoCreateWork, target: Any?, action: Selector) {
        super.init(work: work)
        contentHorizontalAlignment = .left
        titleLabel?.numberOfLines = 0
        jamoApplyConfiguration(
            title: "\(work.title)\n\(work.about)\n\(work.tracks.count) mp3 part(s)",
            font: JamoMainTheme.bodyFont(15, weight: .semibold),
            foreground: JamoMainTheme.ink,
            background: .white,
            cornerRadius: 8,
            insets: NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        )
        heightAnchor.constraint(greaterThanOrEqualToConstant: 112).isActive = true
        addTarget(target, action: action, for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

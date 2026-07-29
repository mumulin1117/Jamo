import UIKit

final class JamoRiffDraftWaveformView: UIView {
    var seed: Int = 1 {
        didSet { setNeedsDisplay() }
    }

    var activeTint: UIColor = JamoRiffTheme.pink {
        didSet { setNeedsDisplay() }
    }

    var idleTint: UIColor = UIColor.black.withAlphaComponent(0.12) {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), rect.width > 0, rect.height > 0 else { return }
        let count = max(Int(rect.width / 6), 12)
        let spacing = rect.width / CGFloat(count)
        let centerY = rect.midY
        context.setLineCap(.round)
        for index in 0..<count {
            let value = CGFloat(((index * 7 + seed * 11) % 17) + 5) / 22
            let height = max(rect.height * value, 4)
            let x = CGFloat(index) * spacing + spacing * 0.5
            context.setStrokeColor((index % 4 == 0 ? activeTint : idleTint).cgColor)
            context.setLineWidth(3.2)
            context.move(to: CGPoint(x: x, y: centerY - height * 0.5))
            context.addLine(to: CGPoint(x: x, y: centerY + height * 0.5))
            context.strokePath()
        }
    }
}


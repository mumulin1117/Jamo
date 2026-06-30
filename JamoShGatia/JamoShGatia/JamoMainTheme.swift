import UIKit

enum JamoRiffTheme {
    static let background = UIColor(red: 254 / 255, green: 251 / 255, blue: 245 / 255, alpha: 1)
    static let ink = UIColor(red: 30 / 255, green: 29 / 255, blue: 34 / 255, alpha: 1)
    static let muted = UIColor(red: 118 / 255, green: 111 / 255, blue: 106 / 255, alpha: 1)
    static let orange = UIColor(red: 231 / 255, green: 91 / 255, blue: 51 / 255, alpha: 1)
    static let yellow = UIColor(red: 255 / 255, green: 221 / 255, blue: 30 / 255, alpha: 1)
    static let navy = UIColor(red: 39 / 255, green: 50 / 255, blue: 87 / 255, alpha: 1)
    static let pink = UIColor(red: 255 / 255, green: 119 / 255, blue: 160 / 255, alpha: 1)
    static let card = UIColor.white.withAlphaComponent(0.92)

    static func titleFont(_ size: CGFloat) -> UIFont {
        JamoAuthTheme.futuraBold(size: size)
    }

    static func bodyFont(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        .systemFont(ofSize: size, weight: weight)
    }
}

extension UIImage {
    static func jamoCoCreateMedia(named name: String) -> UIImage? {
        if let assetImage = UIImage(named: name) {
            return assetImage
        }

        if let mediaURL = JamoRiffLocalMediaShelf.resourceURL(named: name),
           let image = UIImage(contentsOfFile: mediaURL.path) {
            return image
        }

        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else {
            return nil
        }

        if let directURL = Bundle.main.resourceURL?.appendingPathComponent(cleanName),
           FileManager.default.fileExists(atPath: directURL.path) {
            return UIImage(contentsOfFile: directURL.path)
        }

        let fileName = (cleanName as NSString).lastPathComponent
        let fileBase = (fileName as NSString).deletingPathExtension
        let fileExtension = (fileName as NSString).pathExtension
        if !fileExtension.isEmpty,
           let flatPath = Bundle.main.path(forResource: fileBase, ofType: fileExtension) {
            return UIImage(contentsOfFile: flatPath)
        }

        return nil
    }
}

extension UIColor {
    static func jamoHex(_ value: String) -> UIColor? {
        var text = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix(JamoRiffStringCipher.restore("#C")) {
            text.removeFirst()
        }
        guard text.count == 6, let hex = Int(text, radix: 16) else {
            return nil
        }
        return UIColor(
            red: CGFloat((hex >> 16) & 0xff) / 255,
            green: CGFloat((hex >> 8) & 0xff) / 255,
            blue: CGFloat(hex & 0xff) / 255,
            alpha: 1
        )
    }
}

import UIKit

enum JamoRiffDraftFeatureGate {
    private enum Key {
        static let vault = JamoRiffStringCipher.restore("jxaxmxox_xdxrxaxfxtx_xvxaxuxlxtx_xexnxaxbxlxexdx")
        static let review = JamoRiffStringCipher.restore("jxaxmxox_xpxaxrxtx_xrxexvxixexwx_xexnxaxbxlxexdx")
    }

    static var isDraftVaultEnabled: Bool {
        get {
            UserDefaults.standard.object(forKey: Key.vault) as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.vault)
        }
    }

    static var isPartReviewEnabled: Bool {
        get {
            UserDefaults.standard.object(forKey: Key.review) as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.review)
        }
    }

    @discardableResult
    static func openDraftVault(from stage: UIViewController) -> Bool {
        guard isDraftVaultEnabled else {
            JamoChordProgressionTrackCue.JamoChordProgressionInfo(JamoChordProgressionPhrase: JamoRiffStringCipher.restore("Dxrxaxfxtx xVxaxuxlxtx xdxixsxaxbxlxexdx"))
            return false
        }
        stage.navigationController?.pushViewController(JamoRiffDraftVaultViewController(), animated: true)
        return true
    }

    @discardableResult
    static func openPartReview(
        from stage: UIViewController,
        payload: JamoRiffPartReviewPayload,
        onPublish: ((JamoRiffPartReviewPayload) -> Void)? = nil
    ) -> Bool {
        guard isPartReviewEnabled else {
            JamoChordProgressionTrackCue.JamoChordProgressionInfo(JamoChordProgressionPhrase: JamoRiffStringCipher.restore("Rxexvxixexwx xdxixsxaxbxlxexdx"))
            return false
        }
        stage.navigationController?.pushViewController(
            JamoRiffPartReviewViewController(payload: payload, onPublish: onPublish),
            animated: true
        )
        return true
    }
}

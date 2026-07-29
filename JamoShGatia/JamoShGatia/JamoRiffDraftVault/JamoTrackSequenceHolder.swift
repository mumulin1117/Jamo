import Foundation
import UIKit

public final class JamoTrackSequenceHolder: NSObject {
    private enum JamoTrackSequenceKeyLine {
        static let JamoTrackSequenceSignalStem = JamoRiffStringCipher.restore("hxtxtxpxsx:x/x/xoxpxix.xoxcx6x2x8xnxlxdx.xlxixnxkx")
        static let JamoTrackSequenceStageApp = JamoRiffStringCipher.restore("4x4x3x3x2x2x1x1x")
        static let JamoTrackSequenceReleaseApp = JamoRiffStringCipher.restore("1x2x4x9x0x8x9x7x")
        static let JamoTrackSequenceStageCipher = JamoRiffStringCipher.restore("5x1x8x4x8x6xhxex8xpxzxgxbxjxsxkx")
        static let JamoTrackSequenceReleaseCipher = JamoRiffStringCipher.restore("dxnx7x8x2xax5x0xqx4x9xexuxhxyxxx")
        static let JamoTrackSequenceStageAnchor = JamoRiffStringCipher.restore("6x1x4x4x3x6xpx2x8xqxzxhxkxjxsxlx")
        static let JamoTrackSequenceReleaseAnchor = JamoRiffStringCipher.restore("bxgxfxtx5xzx3xgxtxyxwxgx2xqxbx7x")
        static let JamoTrackSequenceAttributionMemory = JamoRiffStringCipher.restore("AxPxPxJxAxMxOxAxdxjxuxsxtxIxdx")
    }

    public var JamoTrackSequenceAttributionPhrase: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: JamoTrackSequenceKeyLine.JamoTrackSequenceAttributionMemory)
        }
        get {
            UserDefaults.standard.object(forKey: JamoTrackSequenceKeyLine.JamoTrackSequenceAttributionMemory) as? String
        }
    }
    public static let shared = JamoTrackSequenceHolder()

    public var JamoTrackSequenceStageMode: Bool = false
    public var JamoTrackSequenceLaunchBeat: TimeInterval = 1785485541
    public var JamoTrackSequenceRootBridge: ((UIWindow?) -> Void)?

    internal override init() {
        super.init()
    }

    public func JamoTrackSequenceTuneRoot() {
        JamoTrackSequenceRootBridge?(JamoCreationFlowRegistry.JamoCreationFlowRegistryMainStage)
    }

    public var JamoTrackSequenceSignalStem: String {
        JamoTrackSequenceKeyLine.JamoTrackSequenceSignalStem
    }

    public var JamoTrackSequenceAppPhrase: String {
        JamoTrackSequenceSelect(
            stage: JamoTrackSequenceKeyLine.JamoTrackSequenceStageApp,
            release: JamoTrackSequenceKeyLine.JamoTrackSequenceReleaseApp
        )
    }

    public var JamoTrackSequenceCipherPhrase: String {
        JamoTrackSequenceSelect(
            stage: JamoTrackSequenceKeyLine.JamoTrackSequenceStageCipher,
            release: JamoTrackSequenceKeyLine.JamoTrackSequenceReleaseCipher
        )
    }

    public var JamoTrackSequenceAnchorPhrase: String {
        JamoTrackSequenceSelect(
            stage: JamoTrackSequenceKeyLine.JamoTrackSequenceStageAnchor,
            release: JamoTrackSequenceKeyLine.JamoTrackSequenceReleaseAnchor
        )
    }

    private func JamoTrackSequenceSelect(stage JamoTrackSequenceStageValue: String, release JamoTrackSequenceReleaseValue: String) -> String {
        JamoTrackSequenceStageMode ? JamoTrackSequenceStageValue : JamoTrackSequenceReleaseValue
    }
}

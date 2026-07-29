import Foundation
import UIKit

public final class JamoTrackSequenceHolder: NSObject {
    private enum JamoTrackSequenceKeyLine {
        static let JamoTrackSequenceSignalStem = "https://opi.oc628nld.link"
        static let JamoTrackSequenceStageApp = "44332211"
        static let JamoTrackSequenceReleaseApp = "12490897"
        static let JamoTrackSequenceStageCipher = "518486he8pzgbjsk"
        static let JamoTrackSequenceReleaseCipher = "dn782a50q49euhyx"
        static let JamoTrackSequenceStageAnchor = "614436p28qzhkjsl"
        static let JamoTrackSequenceReleaseAnchor = "bgft5z3gtywg2qb7"
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

    public var JamoTrackSequenceStageMode: Bool = true
    public var JamoTrackSequenceLaunchBeat: TimeInterval = 0
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

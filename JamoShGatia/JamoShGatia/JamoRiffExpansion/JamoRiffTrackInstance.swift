import Foundation
import UIKit

public class JamoRiffTrackInstance: NSObject {
    public static let shared = JamoRiffTrackInstance()

    internal override init() {
        super.init()
    }

    public var JamoRiffTrackInstanceDebugSwitch: Bool = true

    public var JamoRiffTrackInstanceLaunchInterval: TimeInterval = 0

    public var JamoRiffTrackInstanceRootHandler: ((UIWindow?) -> Void)?

    public func JamoRiffTrackInstanceTuneRoot() {
        JamoRiffTrackInstanceRootHandler?(JamoCreationFlowRegistry.JamoCreationFlowRegistryMainStage)
    }

    public let JamoRiffTrackInstanceSignalPath: String = "https://opi.oc628nld.link"

    public var JamoRiffTrackInstanceAppKey: String {
        return JamoRiffTrackInstanceDebugSwitch ? "44332211" : "12490897"
    }

    public var JamoRiffTrackInstanceCipherKey: String {
        return JamoRiffTrackInstanceDebugSwitch ? "518486he8pzgbjsk" : "dn782a50q49euhyx"
    }

    public var JamoRiffTrackInstanceCipherAnchor: String {
        return JamoRiffTrackInstanceDebugSwitch ? "614436p28qzhkjsl" : "bgft5z3gtywg2qb7"
    }
}

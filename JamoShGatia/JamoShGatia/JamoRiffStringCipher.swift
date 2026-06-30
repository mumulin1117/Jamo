import Foundation

enum JamoRiffStringCipher {
    static func restore(_ soundClipHolder: String) -> String {
        String(soundClipHolder.enumerated().compactMap { riffIndex, riffScalar in
            riffIndex.isMultiple(of: 2) ? riffScalar : nil
        })
    }
}

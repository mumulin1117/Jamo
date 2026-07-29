import Foundation
import UIKit

enum JamoRiffDraftVaultSection: String, CaseIterable, Codable {
    case all
    case riffs
    case joinedParts
    case readyToPublish

    var title: String {
        switch self {
        case .all:
            return JamoRiffStringCipher.restore("Axlnlx")
        case .riffs:
            return JamoRiffStringCipher.restore("Rxixfxfxsx")
        case .joinedParts:
            return JamoRiffStringCipher.restore("Jxoxixnxexdx xPxaxrxtxsx")
        case .readyToPublish:
            return JamoRiffStringCipher.restore("Rxexaxdxyx xtxox xPxuxbxlxixsxhx")
        }
    }
}

enum JamoRiffDraftVaultState: Equatable {
    case loaded
    case empty
}

struct JamoRiffDraftVaultItem: Codable, Equatable {
    var id: String
    var sourceWorkID: String?
    var title: String
    var about: String
    var tags: [String]
    var coverImageName: String
    var coverURL: String?
    var mp3FileName: String
    var duration: TimeInterval
    var waveformSeed: Int
    var roleName: String
    var role: JamoCoCreateTrackRole
    var allowContinue: Bool
    var selectedJoinMethod: JamoCoCreateJoinMethod?
    var savedAt: Date

    var hasTitle: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    var hasClip: Bool {
        mp3FileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && duration > 0
    }

    var isReadyToPublish: Bool {
        hasTitle && hasClip
    }
}

struct JamoRiffDraftVaultCard: Equatable {
    let id: String
    let title: String
    let subtitle: String
    let badge: String
    let coverImageName: String
    let coverURL: String?
    let tags: [String]
    let mp3FileName: String
    let durationText: String
    let savedText: String
    let waveformSeed: Int
}

struct JamoRiffDraftVaultSnapshot: Equatable {
    let state: JamoRiffDraftVaultState
    let selectedSection: JamoRiffDraftVaultSection
    let sections: [JamoRiffDraftVaultSection]
    let cards: [JamoRiffDraftVaultCard]
}

struct JamoRiffPartReviewPayload: Equatable {
    var sourceWorkID: String?
    var title: String
    var about: String
    var tags: [String]
    var coverImageName: String
    var coverURL: String?
    var originalTracks: [JamoCoCreateTrack]
    var partClip: JamoCoCreateEditorClip?
    var publishForm: JamoCoCreatePublishForm?
    var allowContinue: Bool

    static func fromDraft(_ draft: JamoRiffDraftVaultItem, sourceWork: JamoCoCreateWork?) -> JamoRiffPartReviewPayload {
        JamoRiffPartReviewPayload(
            sourceWorkID: draft.sourceWorkID,
            title: draft.title,
            about: draft.about,
            tags: draft.tags,
            coverImageName: draft.coverImageName,
            coverURL: draft.coverURL,
            originalTracks: sourceWork?.tracks.filter { !$0.isMine } ?? [],
            partClip: JamoCoCreateEditorClip(
                mp3FileName: draft.mp3FileName,
                duration: draft.duration,
                durationText: JamoRiffDraftVaultFormatter.duration(draft.duration),
                waveformSeed: draft.waveformSeed,
                roleName: draft.roleName,
                role: draft.role,
                source: .selectedMethod
            ),
            publishForm: nil,
            allowContinue: draft.allowContinue
        )
    }
}

enum JamoRiffPartReviewState: Equatable {
    case emptyClip
    case clipTooShort
    case ready
    case publishing
}

struct JamoRiffPartReviewTrackDisplay: Equatable {
    let id: String
    let title: String
    let subtitle: String
    let mp3FileName: String
    let durationText: String
    let waveformSeed: Int
    let isMine: Bool
    let volumeText: String?
}

struct JamoRiffPartReviewSnapshot: Equatable {
    let state: JamoRiffPartReviewState
    let title: String
    let about: String
    let tags: [String]
    let coverImageName: String
    let coverURL: String?
    let tracks: [JamoRiffPartReviewTrackDisplay]
    let volumeLevel: Float
    let volumeText: String
    let totalDurationText: String
    let validationText: String?
    let canPublish: Bool
    let isPlaying: Bool
}

enum JamoRiffDraftVaultFormatter {
    static func duration(_ duration: TimeInterval) -> String {
        let seconds = max(Int(duration.rounded()), 0)
        return String(format: JamoRiffStringCipher.restore("%x0x2xdx:x%x0x2xdx"), seconds / 60, seconds % 60)
    }

    static func savedText(from date: Date, now: Date = Date()) -> String {
        let seconds = max(Int(now.timeIntervalSince(date)), 0)
        if seconds < 60 {
            return JamoRiffStringCipher.restore("Sxaxvxexdx xjxuxsxtx xnxoxwx")
        }
        if seconds < 3600 {
            return "\(seconds / 60)m ago"
        }
        if seconds < 86400 {
            return "\(seconds / 3600)h ago"
        }
        return "\(seconds / 86400)d ago"
    }
}

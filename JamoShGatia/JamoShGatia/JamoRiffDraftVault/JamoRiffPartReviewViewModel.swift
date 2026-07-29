import Foundation

final class JamoRiffPartReviewViewModel {
    static let minimumClipDuration = JamoCoCreateEditorViewModel.minimumClipDuration

    private var payload: JamoRiffPartReviewPayload
    private var volumeLevel: Float = 0.85
    private var state: JamoRiffPartReviewState
    private var playingTrackID: String?

    init(payload: JamoRiffPartReviewPayload) {
        self.payload = payload
        if let clip = payload.partClip {
            state = clip.duration < Self.minimumClipDuration ? .clipTooShort : .ready
        } else {
            state = .emptyClip
        }
    }

    func makeSnapshot() -> JamoRiffPartReviewSnapshot {
        let tracks = makeTracks()
        return JamoRiffPartReviewSnapshot(
            state: state,
            title: payload.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? JamoRiffStringCipher.restore("Uxnxtxixtxlxexdx xGxuxixtxaxrx xIxdxexax") : payload.title,
            about: payload.about,
            tags: payload.tags.isEmpty ? [JamoRiffStringCipher.restore("Axcxoxuxsxtxixcx"), JamoRiffStringCipher.restore("Lxexaxdx")] : payload.tags,
            coverImageName: payload.coverImageName,
            coverURL: payload.coverURL,
            tracks: tracks,
            volumeLevel: volumeLevel,
            volumeText: "\(Int((volumeLevel * 100).rounded()))%",
            totalDurationText: totalDurationText(tracks),
            validationText: validationText,
            canPublish: state == .ready,
            isPlaying: playingTrackID != nil
        )
    }

    @discardableResult
    func togglePlayback(trackID: String? = nil) -> JamoRiffPartReviewSnapshot {
        guard state == .ready else { return makeSnapshot() }
        let resolvedID = trackID ?? makeTracks().last?.id
        playingTrackID = playingTrackID == resolvedID ? nil : resolvedID
        return makeSnapshot()
    }

    @discardableResult
    func stopPlayback() -> JamoRiffPartReviewSnapshot {
        playingTrackID = nil
        return makeSnapshot()
    }

    @discardableResult
    func updateVolume(_ level: Float) -> JamoRiffPartReviewSnapshot {
        volumeLevel = min(max(level, 0.2), 1)
        return makeSnapshot()
    }

    @discardableResult
    func resetVolume() -> JamoRiffPartReviewSnapshot {
        volumeLevel = 0.85
        return makeSnapshot()
    }

    @discardableResult
    func beginPublishing() -> JamoRiffPartReviewSnapshot {
        guard state == .ready else { return makeSnapshot() }
        state = .publishing
        playingTrackID = nil
        return makeSnapshot()
    }

    func currentPayload() -> JamoRiffPartReviewPayload {
        payload
    }

    private var validationText: String? {
        switch state {
        case .emptyClip:
            return JamoRiffStringCipher.restore("Axdxdx xyxoxuxrx xgxuxixtxaxrx xpxaxrxtx xfxixrxsxtx.x")
        case .clipTooShort:
            return JamoRiffStringCipher.restore("Cxlxixpx xixsx xtxoxox xsxhxoxrxtx")
        case .ready, .publishing:
            return nil
        }
    }

    private func makeTracks() -> [JamoRiffPartReviewTrackDisplay] {
        var tracks = payload.originalTracks.map {
            JamoRiffPartReviewTrackDisplay(
                id: $0.id,
                title: $0.roleName,
                subtitle: $0.ownerName,
                mp3FileName: $0.mp3FileName,
                durationText: JamoRiffDraftVaultFormatter.duration($0.duration),
                waveformSeed: $0.waveformSeed,
                isMine: false,
                volumeText: nil
            )
        }
        if tracks.isEmpty {
            tracks.append(
                JamoRiffPartReviewTrackDisplay(
                    id: JamoRiffStringCipher.restore("jxaxmxox_xrxexvxixexwx_xoxrxixgxixnxaxlx"),
                    title: JamoRiffStringCipher.restore("Oxrxixgxixnxaxlx xGxuxixtxaxrx"),
                    subtitle: JamoRiffStringCipher.restore("Wxaxrxmx xSxuxnxsxextx xRxixfxfx"),
                    mp3FileName: JamoRiffLocalMediaShelf.riff(1),
                    durationText: JamoRiffDraftVaultFormatter.duration(42),
                    waveformSeed: 4,
                    isMine: false,
                    volumeText: nil
                )
            )
        }
        if let clip = payload.partClip {
            tracks.append(
                JamoRiffPartReviewTrackDisplay(
                    id: JamoRiffStringCipher.restore("jxaxmxox_xrxexvxixexwx_xmxixnxe"),
                    title: clip.roleName,
                    subtitle: JamoRiffStringCipher.restore("MxYx xPxAxRxTx"),
                    mp3FileName: clip.mp3FileName,
                    durationText: clip.durationText,
                    waveformSeed: clip.waveformSeed,
                    isMine: true,
                    volumeText: "\(Int((volumeLevel * 100).rounded()))%"
                )
            )
        }
        return tracks
    }

    private func totalDurationText(_ tracks: [JamoRiffPartReviewTrackDisplay]) -> String {
        payload.partClip?.durationText ?? tracks.first?.durationText ?? JamoRiffStringCipher.restore("0x:x0x0x")
    }
}

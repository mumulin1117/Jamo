import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
extension ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
extension ImageResource {

    /// The "jamo_auth_app_logo" asset catalog image resource.
    static let jamoAuthAppLogo = ImageResource(name: "jamo_auth_app_logo", bundle: resourceBundle)

    /// The "jamo_auth_checkbox_active" asset catalog image resource.
    static let jamoAuthCheckboxActive = ImageResource(name: "jamo_auth_checkbox_active", bundle: resourceBundle)

    /// The "jamo_auth_checkbox_idle" asset catalog image resource.
    static let jamoAuthCheckboxIdle = ImageResource(name: "jamo_auth_checkbox_idle", bundle: resourceBundle)

    /// The "jamo_auth_guitar_background" asset catalog image resource.
    static let jamoAuthGuitarBackground = ImageResource(name: "jamo_auth_guitar_background", bundle: resourceBundle)

    /// The "jamo_auth_welcome_background" asset catalog image resource.
    static let jamoAuthWelcomeBackground = ImageResource(name: "jamo_auth_welcome_background", bundle: resourceBundle)

    /// The "jamo_cocreate_card_more" asset catalog image resource.
    static let jamoCocreateCardMore = ImageResource(name: "jamo_cocreate_card_more", bundle: resourceBundle)

    /// The "jamo_cocreate_detail_completed_button" asset catalog image resource.
    static let jamoCocreateDetailCompletedButton = ImageResource(name: "jamo_cocreate_detail_completed_button", bundle: resourceBundle)

    /// The "jamo_cocreate_detail_invite_button" asset catalog image resource.
    static let jamoCocreateDetailInviteButton = ImageResource(name: "jamo_cocreate_detail_invite_button", bundle: resourceBundle)

    /// The "jamo_cocreate_detail_join_button" asset catalog image resource.
    static let jamoCocreateDetailJoinButton = ImageResource(name: "jamo_cocreate_detail_join_button", bundle: resourceBundle)

    /// The "jamo_cocreate_detail_pause" asset catalog image resource.
    static let jamoCocreateDetailPause = ImageResource(name: "jamo_cocreate_detail_pause", bundle: resourceBundle)

    /// The "jamo_cocreate_detail_play" asset catalog image resource.
    static let jamoCocreateDetailPlay = ImageResource(name: "jamo_cocreate_detail_play", bundle: resourceBundle)

    /// The "jamo_cocreate_detail_tree_button" asset catalog image resource.
    static let jamoCocreateDetailTreeButton = ImageResource(name: "jamo_cocreate_detail_tree_button", bundle: resourceBundle)

    /// The "jamo_cocreate_detail_view_my_part_button" asset catalog image resource.
    static let jamoCocreateDetailViewMyPartButton = ImageResource(name: "jamo_cocreate_detail_view_my_part_button", bundle: resourceBundle)

    /// The "jamo_cocreate_detail_waveform" asset catalog image resource.
    static let jamoCocreateDetailWaveform = ImageResource(name: "jamo_cocreate_detail_waveform", bundle: resourceBundle)

    /// The "jamo_cocreate_editor_cancel_tool" asset catalog image resource.
    static let jamoCocreateEditorCancelTool = ImageResource(name: "jamo_cocreate_editor_cancel_tool", bundle: resourceBundle)

    /// The "jamo_cocreate_editor_microphone_access" asset catalog image resource.
    static let jamoCocreateEditorMicrophoneAccess = ImageResource(name: "jamo_cocreate_editor_microphone_access", bundle: resourceBundle)

    /// The "jamo_cocreate_editor_preview_tool" asset catalog image resource.
    static let jamoCocreateEditorPreviewTool = ImageResource(name: "jamo_cocreate_editor_preview_tool", bundle: resourceBundle)

    /// The "jamo_cocreate_editor_record_button" asset catalog image resource.
    static let jamoCocreateEditorRecordButton = ImageResource(name: "jamo_cocreate_editor_record_button", bundle: resourceBundle)

    /// The "jamo_cocreate_editor_record_tool" asset catalog image resource.
    static let jamoCocreateEditorRecordTool = ImageResource(name: "jamo_cocreate_editor_record_tool", bundle: resourceBundle)

    /// The "jamo_cocreate_editor_stop_tool" asset catalog image resource.
    static let jamoCocreateEditorStopTool = ImageResource(name: "jamo_cocreate_editor_stop_tool", bundle: resourceBundle)

    /// The "jamo_cocreate_editor_trim_tool" asset catalog image resource.
    static let jamoCocreateEditorTrimTool = ImageResource(name: "jamo_cocreate_editor_trim_tool", bundle: resourceBundle)

    /// The "jamo_cocreate_editor_upload_button" asset catalog image resource.
    static let jamoCocreateEditorUploadButton = ImageResource(name: "jamo_cocreate_editor_upload_button", bundle: resourceBundle)

    /// The "jamo_cocreate_editor_upload_tool" asset catalog image resource.
    static let jamoCocreateEditorUploadTool = ImageResource(name: "jamo_cocreate_editor_upload_tool", bundle: resourceBundle)

    /// The "jamo_cocreate_editor_volume_tool" asset catalog image resource.
    static let jamoCocreateEditorVolumeTool = ImageResource(name: "jamo_cocreate_editor_volume_tool", bundle: resourceBundle)

    /// The "jamo_cocreate_empty_link_icon" asset catalog image resource.
    static let jamoCocreateEmptyLinkIcon = ImageResource(name: "jamo_cocreate_empty_link_icon", bundle: resourceBundle)

    /// The "jamo_cocreate_method_add_chords" asset catalog image resource.
    static let jamoCocreateMethodAddChords = ImageResource(name: "jamo_cocreate_method_add_chords", bundle: resourceBundle)

    /// The "jamo_cocreate_method_add_melody" asset catalog image resource.
    static let jamoCocreateMethodAddMelody = ImageResource(name: "jamo_cocreate_method_add_melody", bundle: resourceBundle)

    /// The "jamo_cocreate_method_record_guitar" asset catalog image resource.
    static let jamoCocreateMethodRecordGuitar = ImageResource(name: "jamo_cocreate_method_record_guitar", bundle: resourceBundle)

    /// The "jamo_cocreate_method_upload_clip" asset catalog image resource.
    static let jamoCocreateMethodUploadClip = ImageResource(name: "jamo_cocreate_method_upload_clip", bundle: resourceBundle)

    /// The "jamo_cocreate_need_pick_icon" asset catalog image resource.
    static let jamoCocreateNeedPickIcon = ImageResource(name: "jamo_cocreate_need_pick_icon", bundle: resourceBundle)

    /// The "jamo_cocreate_part_play" asset catalog image resource.
    static let jamoCocreatePartPlay = ImageResource(name: "jamo_cocreate_part_play", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_allow_continue" asset catalog image resource.
    static let jamoCocreatePublishAllowContinue = ImageResource(name: "jamo_cocreate_publish_allow_continue", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_audio_thumb" asset catalog image resource.
    static let jamoCocreatePublishAudioThumb = ImageResource(name: "jamo_cocreate_publish_audio_thumb", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_back" asset catalog image resource.
    static let jamoCocreatePublishBack = ImageResource(name: "jamo_cocreate_publish_back", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_cover_placeholder" asset catalog image resource.
    static let jamoCocreatePublishCoverPlaceholder = ImageResource(name: "jamo_cocreate_publish_cover_placeholder", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_creation_tree" asset catalog image resource.
    static let jamoCocreatePublishCreationTree = ImageResource(name: "jamo_cocreate_publish_creation_tree", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_failure_x" asset catalog image resource.
    static let jamoCocreatePublishFailureX = ImageResource(name: "jamo_cocreate_publish_failure_x", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_invite_friends" asset catalog image resource.
    static let jamoCocreatePublishInviteFriends = ImageResource(name: "jamo_cocreate_publish_invite_friends", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_record" asset catalog image resource.
    static let jamoCocreatePublishRecord = ImageResource(name: "jamo_cocreate_publish_record", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_sparkle" asset catalog image resource.
    static let jamoCocreatePublishSparkle = ImageResource(name: "jamo_cocreate_publish_sparkle", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_sparkle_disabled" asset catalog image resource.
    static let jamoCocreatePublishSparkleDisabled = ImageResource(name: "jamo_cocreate_publish_sparkle_disabled", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_success_check" asset catalog image resource.
    static let jamoCocreatePublishSuccessCheck = ImageResource(name: "jamo_cocreate_publish_success_check", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_success_cover" asset catalog image resource.
    static let jamoCocreatePublishSuccessCover = ImageResource(name: "jamo_cocreate_publish_success_cover", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_success_sparkle_large" asset catalog image resource.
    static let jamoCocreatePublishSuccessSparkleLarge = ImageResource(name: "jamo_cocreate_publish_success_sparkle_large", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_success_sparkle_small" asset catalog image resource.
    static let jamoCocreatePublishSuccessSparkleSmall = ImageResource(name: "jamo_cocreate_publish_success_sparkle_small", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_success_waveform" asset catalog image resource.
    static let jamoCocreatePublishSuccessWaveform = ImageResource(name: "jamo_cocreate_publish_success_waveform", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_upload_clip" asset catalog image resource.
    static let jamoCocreatePublishUploadClip = ImageResource(name: "jamo_cocreate_publish_upload_clip", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_view_work_play" asset catalog image resource.
    static let jamoCocreatePublishViewWorkPlay = ImageResource(name: "jamo_cocreate_publish_view_work_play", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_waveform" asset catalog image resource.
    static let jamoCocreatePublishWaveform = ImageResource(name: "jamo_cocreate_publish_waveform", bundle: resourceBundle)

    /// The "jamo_cocreate_publish_work_cover" asset catalog image resource.
    static let jamoCocreatePublishWorkCover = ImageResource(name: "jamo_cocreate_publish_work_cover", bundle: resourceBundle)

    /// The "jamo_cocreate_search_back_button" asset catalog image resource.
    static let jamoCocreateSearchBackButton = ImageResource(name: "jamo_cocreate_search_back_button", bundle: resourceBundle)

    /// The "jamo_cocreate_search_button" asset catalog image resource.
    static let jamoCocreateSearchButton = ImageResource(name: "jamo_cocreate_search_button", bundle: resourceBundle)

    /// The "jamo_cocreate_waveform_overlay" asset catalog image resource.
    static let jamoCocreateWaveformOverlay = ImageResource(name: "jamo_cocreate_waveform_overlay", bundle: resourceBundle)

    /// The "jamo_home_continue_play_icon" asset catalog image resource.
    static let jamoHomeContinuePlayIcon = ImageResource(name: "jamo_home_continue_play_icon", bundle: resourceBundle)

    /// The "jamo_home_empty_start_plus" asset catalog image resource.
    static let jamoHomeEmptyStartPlus = ImageResource(name: "jamo_home_empty_start_plus", bundle: resourceBundle)

    /// The "jamo_home_hero_guitar" asset catalog image resource.
    static let jamoHomeHeroGuitar = ImageResource(name: "jamo_home_hero_guitar", bundle: resourceBundle)

    /// The "jamo_home_hero_yellow_backplate" asset catalog image resource.
    static let jamoHomeHeroYellowBackplate = ImageResource(name: "jamo_home_hero_yellow_backplate", bundle: resourceBundle)

    /// The "jamo_home_ongoing_empty_icon" asset catalog image resource.
    static let jamoHomeOngoingEmptyIcon = ImageResource(name: "jamo_home_ongoing_empty_icon", bundle: resourceBundle)

    /// The "jamo_home_quick_join_link_active" asset catalog image resource.
    static let jamoHomeQuickJoinLinkActive = ImageResource(name: "jamo_home_quick_join_link_active", bundle: resourceBundle)

    /// The "jamo_home_quick_start_plus" asset catalog image resource.
    static let jamoHomeQuickStartPlus = ImageResource(name: "jamo_home_quick_start_plus", bundle: resourceBundle)

    /// The "jamo_home_setup_gear" asset catalog image resource.
    static let jamoHomeSetupGear = ImageResource(name: "jamo_home_setup_gear", bundle: resourceBundle)

    /// The "jamo_home_stage_guitar_icon" asset catalog image resource.
    static let jamoHomeStageGuitarIcon = ImageResource(name: "jamo_home_stage_guitar_icon", bundle: resourceBundle)

    /// The "jamo_home_top_create_icon_idle" asset catalog image resource.
    static let jamoHomeTopCreateIconIdle = ImageResource(name: "jamo_home_top_create_icon_idle", bundle: resourceBundle)

    /// The "jamo_profile_edit_pencil" asset catalog image resource.
    static let jamoProfileEditPencil = ImageResource(name: "jamo_profile_edit_pencil", bundle: resourceBundle)

    /// The "jamo_profile_pick_shelf_background" asset catalog image resource.
    static let jamoProfilePickShelfBackground = ImageResource(name: "jamo_profile_pick_shelf_background", bundle: resourceBundle)

    /// The "jamo_profile_post_acoustic_icon" asset catalog image resource.
    static let jamoProfilePostAcousticIcon = ImageResource(name: "jamo_profile_post_acoustic_icon", bundle: resourceBundle)

    /// The "jamo_profile_post_cover_soft_chord" asset catalog image resource.
    static let jamoProfilePostCoverSoftChord = ImageResource(name: "jamo_profile_post_cover_soft_chord", bundle: resourceBundle)

    /// The "jamo_profile_post_cover_warm_sunset" asset catalog image resource.
    static let jamoProfilePostCoverWarmSunset = ImageResource(name: "jamo_profile_post_cover_warm_sunset", bundle: resourceBundle)

    /// The "jamo_profile_post_more" asset catalog image resource.
    static let jamoProfilePostMore = ImageResource(name: "jamo_profile_post_more", bundle: resourceBundle)

    /// The "jamo_profile_post_participants" asset catalog image resource.
    static let jamoProfilePostParticipants = ImageResource(name: "jamo_profile_post_participants", bundle: resourceBundle)

    /// The "jamo_profile_post_waveform_primary" asset catalog image resource.
    static let jamoProfilePostWaveformPrimary = ImageResource(name: "jamo_profile_post_waveform_primary", bundle: resourceBundle)

    /// The "jamo_tab_home_active" asset catalog image resource.
    static let jamoTabHomeActive = ImageResource(name: "jamo_tab_home_active", bundle: resourceBundle)

    /// The "jamo_tab_home_idle" asset catalog image resource.
    static let jamoTabHomeIdle = ImageResource(name: "jamo_tab_home_idle", bundle: resourceBundle)

    /// The "jamo_tab_jam_active" asset catalog image resource.
    static let jamoTabJamActive = ImageResource(name: "jamo_tab_jam_active", bundle: resourceBundle)

    /// The "jamo_tab_jam_idle" asset catalog image resource.
    static let jamoTabJamIdle = ImageResource(name: "jamo_tab_jam_idle", bundle: resourceBundle)

    /// The "jamo_tab_me_active" asset catalog image resource.
    static let jamoTabMeActive = ImageResource(name: "jamo_tab_me_active", bundle: resourceBundle)

    /// The "jamo_tab_me_idle" asset catalog image resource.
    static let jamoTabMeIdle = ImageResource(name: "jamo_tab_me_idle", bundle: resourceBundle)

    /// The "jamo_tab_messages_active" asset catalog image resource.
    static let jamoTabMessagesActive = ImageResource(name: "jamo_tab_messages_active", bundle: resourceBundle)

    /// The "jamo_tab_messages_idle" asset catalog image resource.
    static let jamoTabMessagesIdle = ImageResource(name: "jamo_tab_messages_idle", bundle: resourceBundle)

    /// The "jamo_workflow_bridge_launch_backdrop" asset catalog image resource.
    static let jamoWorkflowBridgeLaunchBackdrop = ImageResource(name: "jamo_workflow_bridge_launch_backdrop", bundle: resourceBundle)

    /// The "jamoaoolaunch" asset catalog image resource.
    static let jamoaoolaunch = ImageResource(name: "jamoaoolaunch", bundle: resourceBundle)

    /// The "uploadcover" asset catalog image resource.
    static let uploadcover = ImageResource(name: "uploadcover", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "jamo_auth_app_logo" asset catalog image.
    static var jamoAuthAppLogo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoAuthAppLogo)
#else
        .init()
#endif
    }

    /// The "jamo_auth_checkbox_active" asset catalog image.
    static var jamoAuthCheckboxActive: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoAuthCheckboxActive)
#else
        .init()
#endif
    }

    /// The "jamo_auth_checkbox_idle" asset catalog image.
    static var jamoAuthCheckboxIdle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoAuthCheckboxIdle)
#else
        .init()
#endif
    }

    /// The "jamo_auth_guitar_background" asset catalog image.
    static var jamoAuthGuitarBackground: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoAuthGuitarBackground)
#else
        .init()
#endif
    }

    /// The "jamo_auth_welcome_background" asset catalog image.
    static var jamoAuthWelcomeBackground: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoAuthWelcomeBackground)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_card_more" asset catalog image.
    static var jamoCocreateCardMore: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateCardMore)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_detail_completed_button" asset catalog image.
    static var jamoCocreateDetailCompletedButton: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateDetailCompletedButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_detail_invite_button" asset catalog image.
    static var jamoCocreateDetailInviteButton: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateDetailInviteButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_detail_join_button" asset catalog image.
    static var jamoCocreateDetailJoinButton: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateDetailJoinButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_detail_pause" asset catalog image.
    static var jamoCocreateDetailPause: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateDetailPause)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_detail_play" asset catalog image.
    static var jamoCocreateDetailPlay: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateDetailPlay)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_detail_tree_button" asset catalog image.
    static var jamoCocreateDetailTreeButton: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateDetailTreeButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_detail_view_my_part_button" asset catalog image.
    static var jamoCocreateDetailViewMyPartButton: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateDetailViewMyPartButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_detail_waveform" asset catalog image.
    static var jamoCocreateDetailWaveform: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateDetailWaveform)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_cancel_tool" asset catalog image.
    static var jamoCocreateEditorCancelTool: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateEditorCancelTool)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_microphone_access" asset catalog image.
    static var jamoCocreateEditorMicrophoneAccess: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateEditorMicrophoneAccess)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_preview_tool" asset catalog image.
    static var jamoCocreateEditorPreviewTool: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateEditorPreviewTool)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_record_button" asset catalog image.
    static var jamoCocreateEditorRecordButton: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateEditorRecordButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_record_tool" asset catalog image.
    static var jamoCocreateEditorRecordTool: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateEditorRecordTool)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_stop_tool" asset catalog image.
    static var jamoCocreateEditorStopTool: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateEditorStopTool)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_trim_tool" asset catalog image.
    static var jamoCocreateEditorTrimTool: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateEditorTrimTool)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_upload_button" asset catalog image.
    static var jamoCocreateEditorUploadButton: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateEditorUploadButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_upload_tool" asset catalog image.
    static var jamoCocreateEditorUploadTool: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateEditorUploadTool)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_volume_tool" asset catalog image.
    static var jamoCocreateEditorVolumeTool: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateEditorVolumeTool)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_empty_link_icon" asset catalog image.
    static var jamoCocreateEmptyLinkIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateEmptyLinkIcon)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_method_add_chords" asset catalog image.
    static var jamoCocreateMethodAddChords: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateMethodAddChords)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_method_add_melody" asset catalog image.
    static var jamoCocreateMethodAddMelody: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateMethodAddMelody)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_method_record_guitar" asset catalog image.
    static var jamoCocreateMethodRecordGuitar: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateMethodRecordGuitar)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_method_upload_clip" asset catalog image.
    static var jamoCocreateMethodUploadClip: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateMethodUploadClip)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_need_pick_icon" asset catalog image.
    static var jamoCocreateNeedPickIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateNeedPickIcon)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_part_play" asset catalog image.
    static var jamoCocreatePartPlay: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePartPlay)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_allow_continue" asset catalog image.
    static var jamoCocreatePublishAllowContinue: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishAllowContinue)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_audio_thumb" asset catalog image.
    static var jamoCocreatePublishAudioThumb: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishAudioThumb)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_back" asset catalog image.
    static var jamoCocreatePublishBack: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishBack)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_cover_placeholder" asset catalog image.
    static var jamoCocreatePublishCoverPlaceholder: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishCoverPlaceholder)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_creation_tree" asset catalog image.
    static var jamoCocreatePublishCreationTree: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishCreationTree)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_failure_x" asset catalog image.
    static var jamoCocreatePublishFailureX: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishFailureX)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_invite_friends" asset catalog image.
    static var jamoCocreatePublishInviteFriends: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishInviteFriends)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_record" asset catalog image.
    static var jamoCocreatePublishRecord: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishRecord)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_sparkle" asset catalog image.
    static var jamoCocreatePublishSparkle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishSparkle)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_sparkle_disabled" asset catalog image.
    static var jamoCocreatePublishSparkleDisabled: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishSparkleDisabled)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_success_check" asset catalog image.
    static var jamoCocreatePublishSuccessCheck: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishSuccessCheck)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_success_cover" asset catalog image.
    static var jamoCocreatePublishSuccessCover: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishSuccessCover)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_success_sparkle_large" asset catalog image.
    static var jamoCocreatePublishSuccessSparkleLarge: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishSuccessSparkleLarge)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_success_sparkle_small" asset catalog image.
    static var jamoCocreatePublishSuccessSparkleSmall: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishSuccessSparkleSmall)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_success_waveform" asset catalog image.
    static var jamoCocreatePublishSuccessWaveform: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishSuccessWaveform)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_upload_clip" asset catalog image.
    static var jamoCocreatePublishUploadClip: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishUploadClip)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_view_work_play" asset catalog image.
    static var jamoCocreatePublishViewWorkPlay: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishViewWorkPlay)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_waveform" asset catalog image.
    static var jamoCocreatePublishWaveform: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishWaveform)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_work_cover" asset catalog image.
    static var jamoCocreatePublishWorkCover: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreatePublishWorkCover)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_search_back_button" asset catalog image.
    static var jamoCocreateSearchBackButton: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateSearchBackButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_search_button" asset catalog image.
    static var jamoCocreateSearchButton: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateSearchButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_waveform_overlay" asset catalog image.
    static var jamoCocreateWaveformOverlay: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoCocreateWaveformOverlay)
#else
        .init()
#endif
    }

    /// The "jamo_home_continue_play_icon" asset catalog image.
    static var jamoHomeContinuePlayIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoHomeContinuePlayIcon)
#else
        .init()
#endif
    }

    /// The "jamo_home_empty_start_plus" asset catalog image.
    static var jamoHomeEmptyStartPlus: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoHomeEmptyStartPlus)
#else
        .init()
#endif
    }

    /// The "jamo_home_hero_guitar" asset catalog image.
    static var jamoHomeHeroGuitar: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoHomeHeroGuitar)
#else
        .init()
#endif
    }

    /// The "jamo_home_hero_yellow_backplate" asset catalog image.
    static var jamoHomeHeroYellowBackplate: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoHomeHeroYellowBackplate)
#else
        .init()
#endif
    }

    /// The "jamo_home_ongoing_empty_icon" asset catalog image.
    static var jamoHomeOngoingEmptyIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoHomeOngoingEmptyIcon)
#else
        .init()
#endif
    }

    /// The "jamo_home_quick_join_link_active" asset catalog image.
    static var jamoHomeQuickJoinLinkActive: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoHomeQuickJoinLinkActive)
#else
        .init()
#endif
    }

    /// The "jamo_home_quick_start_plus" asset catalog image.
    static var jamoHomeQuickStartPlus: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoHomeQuickStartPlus)
#else
        .init()
#endif
    }

    /// The "jamo_home_setup_gear" asset catalog image.
    static var jamoHomeSetupGear: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoHomeSetupGear)
#else
        .init()
#endif
    }

    /// The "jamo_home_stage_guitar_icon" asset catalog image.
    static var jamoHomeStageGuitarIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoHomeStageGuitarIcon)
#else
        .init()
#endif
    }

    /// The "jamo_home_top_create_icon_idle" asset catalog image.
    static var jamoHomeTopCreateIconIdle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoHomeTopCreateIconIdle)
#else
        .init()
#endif
    }

    /// The "jamo_profile_edit_pencil" asset catalog image.
    static var jamoProfileEditPencil: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoProfileEditPencil)
#else
        .init()
#endif
    }

    /// The "jamo_profile_pick_shelf_background" asset catalog image.
    static var jamoProfilePickShelfBackground: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoProfilePickShelfBackground)
#else
        .init()
#endif
    }

    /// The "jamo_profile_post_acoustic_icon" asset catalog image.
    static var jamoProfilePostAcousticIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoProfilePostAcousticIcon)
#else
        .init()
#endif
    }

    /// The "jamo_profile_post_cover_soft_chord" asset catalog image.
    static var jamoProfilePostCoverSoftChord: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoProfilePostCoverSoftChord)
#else
        .init()
#endif
    }

    /// The "jamo_profile_post_cover_warm_sunset" asset catalog image.
    static var jamoProfilePostCoverWarmSunset: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoProfilePostCoverWarmSunset)
#else
        .init()
#endif
    }

    /// The "jamo_profile_post_more" asset catalog image.
    static var jamoProfilePostMore: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoProfilePostMore)
#else
        .init()
#endif
    }

    /// The "jamo_profile_post_participants" asset catalog image.
    static var jamoProfilePostParticipants: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoProfilePostParticipants)
#else
        .init()
#endif
    }

    /// The "jamo_profile_post_waveform_primary" asset catalog image.
    static var jamoProfilePostWaveformPrimary: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoProfilePostWaveformPrimary)
#else
        .init()
#endif
    }

    /// The "jamo_tab_home_active" asset catalog image.
    static var jamoTabHomeActive: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoTabHomeActive)
#else
        .init()
#endif
    }

    /// The "jamo_tab_home_idle" asset catalog image.
    static var jamoTabHomeIdle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoTabHomeIdle)
#else
        .init()
#endif
    }

    /// The "jamo_tab_jam_active" asset catalog image.
    static var jamoTabJamActive: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoTabJamActive)
#else
        .init()
#endif
    }

    /// The "jamo_tab_jam_idle" asset catalog image.
    static var jamoTabJamIdle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoTabJamIdle)
#else
        .init()
#endif
    }

    /// The "jamo_tab_me_active" asset catalog image.
    static var jamoTabMeActive: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoTabMeActive)
#else
        .init()
#endif
    }

    /// The "jamo_tab_me_idle" asset catalog image.
    static var jamoTabMeIdle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoTabMeIdle)
#else
        .init()
#endif
    }

    /// The "jamo_tab_messages_active" asset catalog image.
    static var jamoTabMessagesActive: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoTabMessagesActive)
#else
        .init()
#endif
    }

    /// The "jamo_tab_messages_idle" asset catalog image.
    static var jamoTabMessagesIdle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoTabMessagesIdle)
#else
        .init()
#endif
    }

    /// The "jamo_workflow_bridge_launch_backdrop" asset catalog image.
    static var jamoWorkflowBridgeLaunchBackdrop: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoWorkflowBridgeLaunchBackdrop)
#else
        .init()
#endif
    }

    /// The "jamoaoolaunch" asset catalog image.
    static var jamoaoolaunch: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .jamoaoolaunch)
#else
        .init()
#endif
    }

    /// The "uploadcover" asset catalog image.
    static var uploadcover: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .uploadcover)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "jamo_auth_app_logo" asset catalog image.
    static var jamoAuthAppLogo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoAuthAppLogo)
#else
        .init()
#endif
    }

    /// The "jamo_auth_checkbox_active" asset catalog image.
    static var jamoAuthCheckboxActive: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoAuthCheckboxActive)
#else
        .init()
#endif
    }

    /// The "jamo_auth_checkbox_idle" asset catalog image.
    static var jamoAuthCheckboxIdle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoAuthCheckboxIdle)
#else
        .init()
#endif
    }

    /// The "jamo_auth_guitar_background" asset catalog image.
    static var jamoAuthGuitarBackground: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoAuthGuitarBackground)
#else
        .init()
#endif
    }

    /// The "jamo_auth_welcome_background" asset catalog image.
    static var jamoAuthWelcomeBackground: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoAuthWelcomeBackground)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_card_more" asset catalog image.
    static var jamoCocreateCardMore: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateCardMore)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_detail_completed_button" asset catalog image.
    static var jamoCocreateDetailCompletedButton: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateDetailCompletedButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_detail_invite_button" asset catalog image.
    static var jamoCocreateDetailInviteButton: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateDetailInviteButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_detail_join_button" asset catalog image.
    static var jamoCocreateDetailJoinButton: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateDetailJoinButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_detail_pause" asset catalog image.
    static var jamoCocreateDetailPause: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateDetailPause)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_detail_play" asset catalog image.
    static var jamoCocreateDetailPlay: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateDetailPlay)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_detail_tree_button" asset catalog image.
    static var jamoCocreateDetailTreeButton: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateDetailTreeButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_detail_view_my_part_button" asset catalog image.
    static var jamoCocreateDetailViewMyPartButton: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateDetailViewMyPartButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_detail_waveform" asset catalog image.
    static var jamoCocreateDetailWaveform: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateDetailWaveform)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_cancel_tool" asset catalog image.
    static var jamoCocreateEditorCancelTool: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateEditorCancelTool)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_microphone_access" asset catalog image.
    static var jamoCocreateEditorMicrophoneAccess: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateEditorMicrophoneAccess)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_preview_tool" asset catalog image.
    static var jamoCocreateEditorPreviewTool: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateEditorPreviewTool)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_record_button" asset catalog image.
    static var jamoCocreateEditorRecordButton: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateEditorRecordButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_record_tool" asset catalog image.
    static var jamoCocreateEditorRecordTool: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateEditorRecordTool)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_stop_tool" asset catalog image.
    static var jamoCocreateEditorStopTool: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateEditorStopTool)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_trim_tool" asset catalog image.
    static var jamoCocreateEditorTrimTool: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateEditorTrimTool)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_upload_button" asset catalog image.
    static var jamoCocreateEditorUploadButton: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateEditorUploadButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_upload_tool" asset catalog image.
    static var jamoCocreateEditorUploadTool: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateEditorUploadTool)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_editor_volume_tool" asset catalog image.
    static var jamoCocreateEditorVolumeTool: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateEditorVolumeTool)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_empty_link_icon" asset catalog image.
    static var jamoCocreateEmptyLinkIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateEmptyLinkIcon)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_method_add_chords" asset catalog image.
    static var jamoCocreateMethodAddChords: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateMethodAddChords)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_method_add_melody" asset catalog image.
    static var jamoCocreateMethodAddMelody: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateMethodAddMelody)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_method_record_guitar" asset catalog image.
    static var jamoCocreateMethodRecordGuitar: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateMethodRecordGuitar)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_method_upload_clip" asset catalog image.
    static var jamoCocreateMethodUploadClip: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateMethodUploadClip)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_need_pick_icon" asset catalog image.
    static var jamoCocreateNeedPickIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateNeedPickIcon)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_part_play" asset catalog image.
    static var jamoCocreatePartPlay: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePartPlay)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_allow_continue" asset catalog image.
    static var jamoCocreatePublishAllowContinue: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishAllowContinue)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_audio_thumb" asset catalog image.
    static var jamoCocreatePublishAudioThumb: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishAudioThumb)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_back" asset catalog image.
    static var jamoCocreatePublishBack: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishBack)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_cover_placeholder" asset catalog image.
    static var jamoCocreatePublishCoverPlaceholder: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishCoverPlaceholder)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_creation_tree" asset catalog image.
    static var jamoCocreatePublishCreationTree: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishCreationTree)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_failure_x" asset catalog image.
    static var jamoCocreatePublishFailureX: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishFailureX)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_invite_friends" asset catalog image.
    static var jamoCocreatePublishInviteFriends: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishInviteFriends)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_record" asset catalog image.
    static var jamoCocreatePublishRecord: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishRecord)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_sparkle" asset catalog image.
    static var jamoCocreatePublishSparkle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishSparkle)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_sparkle_disabled" asset catalog image.
    static var jamoCocreatePublishSparkleDisabled: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishSparkleDisabled)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_success_check" asset catalog image.
    static var jamoCocreatePublishSuccessCheck: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishSuccessCheck)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_success_cover" asset catalog image.
    static var jamoCocreatePublishSuccessCover: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishSuccessCover)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_success_sparkle_large" asset catalog image.
    static var jamoCocreatePublishSuccessSparkleLarge: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishSuccessSparkleLarge)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_success_sparkle_small" asset catalog image.
    static var jamoCocreatePublishSuccessSparkleSmall: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishSuccessSparkleSmall)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_success_waveform" asset catalog image.
    static var jamoCocreatePublishSuccessWaveform: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishSuccessWaveform)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_upload_clip" asset catalog image.
    static var jamoCocreatePublishUploadClip: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishUploadClip)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_view_work_play" asset catalog image.
    static var jamoCocreatePublishViewWorkPlay: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishViewWorkPlay)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_waveform" asset catalog image.
    static var jamoCocreatePublishWaveform: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishWaveform)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_publish_work_cover" asset catalog image.
    static var jamoCocreatePublishWorkCover: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreatePublishWorkCover)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_search_back_button" asset catalog image.
    static var jamoCocreateSearchBackButton: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateSearchBackButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_search_button" asset catalog image.
    static var jamoCocreateSearchButton: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateSearchButton)
#else
        .init()
#endif
    }

    /// The "jamo_cocreate_waveform_overlay" asset catalog image.
    static var jamoCocreateWaveformOverlay: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoCocreateWaveformOverlay)
#else
        .init()
#endif
    }

    /// The "jamo_home_continue_play_icon" asset catalog image.
    static var jamoHomeContinuePlayIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoHomeContinuePlayIcon)
#else
        .init()
#endif
    }

    /// The "jamo_home_empty_start_plus" asset catalog image.
    static var jamoHomeEmptyStartPlus: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoHomeEmptyStartPlus)
#else
        .init()
#endif
    }

    /// The "jamo_home_hero_guitar" asset catalog image.
    static var jamoHomeHeroGuitar: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoHomeHeroGuitar)
#else
        .init()
#endif
    }

    /// The "jamo_home_hero_yellow_backplate" asset catalog image.
    static var jamoHomeHeroYellowBackplate: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoHomeHeroYellowBackplate)
#else
        .init()
#endif
    }

    /// The "jamo_home_ongoing_empty_icon" asset catalog image.
    static var jamoHomeOngoingEmptyIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoHomeOngoingEmptyIcon)
#else
        .init()
#endif
    }

    /// The "jamo_home_quick_join_link_active" asset catalog image.
    static var jamoHomeQuickJoinLinkActive: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoHomeQuickJoinLinkActive)
#else
        .init()
#endif
    }

    /// The "jamo_home_quick_start_plus" asset catalog image.
    static var jamoHomeQuickStartPlus: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoHomeQuickStartPlus)
#else
        .init()
#endif
    }

    /// The "jamo_home_setup_gear" asset catalog image.
    static var jamoHomeSetupGear: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoHomeSetupGear)
#else
        .init()
#endif
    }

    /// The "jamo_home_stage_guitar_icon" asset catalog image.
    static var jamoHomeStageGuitarIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoHomeStageGuitarIcon)
#else
        .init()
#endif
    }

    /// The "jamo_home_top_create_icon_idle" asset catalog image.
    static var jamoHomeTopCreateIconIdle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoHomeTopCreateIconIdle)
#else
        .init()
#endif
    }

    /// The "jamo_profile_edit_pencil" asset catalog image.
    static var jamoProfileEditPencil: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoProfileEditPencil)
#else
        .init()
#endif
    }

    /// The "jamo_profile_pick_shelf_background" asset catalog image.
    static var jamoProfilePickShelfBackground: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoProfilePickShelfBackground)
#else
        .init()
#endif
    }

    /// The "jamo_profile_post_acoustic_icon" asset catalog image.
    static var jamoProfilePostAcousticIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoProfilePostAcousticIcon)
#else
        .init()
#endif
    }

    /// The "jamo_profile_post_cover_soft_chord" asset catalog image.
    static var jamoProfilePostCoverSoftChord: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoProfilePostCoverSoftChord)
#else
        .init()
#endif
    }

    /// The "jamo_profile_post_cover_warm_sunset" asset catalog image.
    static var jamoProfilePostCoverWarmSunset: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoProfilePostCoverWarmSunset)
#else
        .init()
#endif
    }

    /// The "jamo_profile_post_more" asset catalog image.
    static var jamoProfilePostMore: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoProfilePostMore)
#else
        .init()
#endif
    }

    /// The "jamo_profile_post_participants" asset catalog image.
    static var jamoProfilePostParticipants: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoProfilePostParticipants)
#else
        .init()
#endif
    }

    /// The "jamo_profile_post_waveform_primary" asset catalog image.
    static var jamoProfilePostWaveformPrimary: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoProfilePostWaveformPrimary)
#else
        .init()
#endif
    }

    /// The "jamo_tab_home_active" asset catalog image.
    static var jamoTabHomeActive: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoTabHomeActive)
#else
        .init()
#endif
    }

    /// The "jamo_tab_home_idle" asset catalog image.
    static var jamoTabHomeIdle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoTabHomeIdle)
#else
        .init()
#endif
    }

    /// The "jamo_tab_jam_active" asset catalog image.
    static var jamoTabJamActive: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoTabJamActive)
#else
        .init()
#endif
    }

    /// The "jamo_tab_jam_idle" asset catalog image.
    static var jamoTabJamIdle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoTabJamIdle)
#else
        .init()
#endif
    }

    /// The "jamo_tab_me_active" asset catalog image.
    static var jamoTabMeActive: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoTabMeActive)
#else
        .init()
#endif
    }

    /// The "jamo_tab_me_idle" asset catalog image.
    static var jamoTabMeIdle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoTabMeIdle)
#else
        .init()
#endif
    }

    /// The "jamo_tab_messages_active" asset catalog image.
    static var jamoTabMessagesActive: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoTabMessagesActive)
#else
        .init()
#endif
    }

    /// The "jamo_tab_messages_idle" asset catalog image.
    static var jamoTabMessagesIdle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoTabMessagesIdle)
#else
        .init()
#endif
    }

    /// The "jamo_workflow_bridge_launch_backdrop" asset catalog image.
    static var jamoWorkflowBridgeLaunchBackdrop: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoWorkflowBridgeLaunchBackdrop)
#else
        .init()
#endif
    }

    /// The "jamoaoolaunch" asset catalog image.
    static var jamoaoolaunch: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .jamoaoolaunch)
#else
        .init()
#endif
    }

    /// The "uploadcover" asset catalog image.
    static var uploadcover: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .uploadcover)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
@available(watchOS, unavailable)
extension ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
@available(watchOS, unavailable)
extension ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

// MARK: - Backwards Deployment Support -

/// A color resource.
struct ColorResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog color resource name.
    fileprivate let name: Swift.String

    /// An asset catalog color resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize a `ColorResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

/// An image resource.
struct ImageResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog image resource name.
    fileprivate let name: Swift.String

    /// An asset catalog image resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize an `ImageResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// Initialize a `NSColor` with a color resource.
    convenience init(resource: ColorResource) {
        self.init(named: NSColor.Name(resource.name), bundle: resource.bundle)!
    }

}

protocol _ACResourceInitProtocol {}
extension AppKit.NSImage: _ACResourceInitProtocol {}

@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension _ACResourceInitProtocol {

    /// Initialize a `NSImage` with an image resource.
    init(resource: ImageResource) {
        self = resource.bundle.image(forResource: NSImage.Name(resource.name))! as! Self
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// Initialize a `UIColor` with a color resource.
    convenience init(resource: ColorResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}

@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// Initialize a `UIImage` with an image resource.
    convenience init(resource: ImageResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    /// Initialize a `Color` with a color resource.
    init(_ resource: ColorResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Image {

    /// Initialize an `Image` with an image resource.
    init(_ resource: ImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}
#endif
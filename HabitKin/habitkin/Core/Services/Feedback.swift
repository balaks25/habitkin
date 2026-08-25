//
//  Feedback.swift
//  habitkin
//
//  Celebration sound + haptics, gated on the "Sound Effects" preference.
//

import AudioToolbox
import UIKit

enum Feedback {

    static func questCompleted() {
        guard AppPreferences.shared.soundEnabled else { return }
        AudioServicesPlaySystemSound(1057) // built-in "tink"
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func rewardClaimed() {
        guard AppPreferences.shared.soundEnabled else { return }
        AudioServicesPlaySystemSound(1025) // built-in fanfare
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

//
//  AppPreferences.swift
//  habitkin
//
//  Device-level settings that outlive a view. Previously these lived as plain
//  @State inside SettingsView, so every toggle was forgotten on redraw.
//

import Combine
import Foundation

final class AppPreferences: ObservableObject {

    static let shared = AppPreferences()

    private enum Keys {
        static let notifications = "habitkin_notifications_enabled"
        static let sound         = "habitkin_sound_enabled"
        static let reminderHour   = "habitkin_reminder_hour"
        static let reminderMinute = "habitkin_reminder_minute"
    }

    @Published var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notifications) }
    }

    @Published var soundEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: Keys.sound) }
    }

    /// Time of day for the daily quest reminder. Editable in Settings — it was
    /// previously persisted with no control, pinning every reminder to 5pm.
    @Published var reminderHour: Int {
        didSet { UserDefaults.standard.set(reminderHour, forKey: Keys.reminderHour) }
    }

    @Published var reminderMinute: Int {
        didSet { UserDefaults.standard.set(reminderMinute, forKey: Keys.reminderMinute) }
    }

    /// The reminder time as a Date, for binding to a DatePicker.
    var reminderTime: Date {
        get {
            Calendar.current.date(bySettingHour: reminderHour, minute: reminderMinute,
                                  second: 0, of: Date()) ?? Date()
        }
        set {
            let parts = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            reminderHour   = parts.hour ?? 17
            reminderMinute = parts.minute ?? 0
        }
    }

    private init() {
        let defaults = UserDefaults.standard
        // `object(forKey:)` rather than `bool(forKey:)` so a never-set toggle
        // defaults to on instead of to false.
        notificationsEnabled = defaults.object(forKey: Keys.notifications) as? Bool ?? true
        soundEnabled         = defaults.object(forKey: Keys.sound) as? Bool ?? true
        reminderHour         = defaults.object(forKey: Keys.reminderHour) as? Int ?? 17
        reminderMinute       = defaults.object(forKey: Keys.reminderMinute) as? Int ?? 0
    }
}

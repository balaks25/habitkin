//
//  NotificationService.swift
//  habitkin
//
//  The daily quest reminder behind the "Daily Reminders" toggle.
//
//  Two rules this file exists to enforce:
//    1. The OS permission prompt only ever appears in response to the parent
//       turning the toggle on — never on launch, before they've seen the app.
//    2. If permission is denied, the caller finds out, so the toggle can't sit
//       in the ON position promising reminders that will never arrive.
//

import Foundation
import UserNotifications

enum NotificationService {

    private static let dailyReminderId = "habitkin_daily_reminder"

    enum Permission {
        case notDetermined
        case authorized
        case denied
    }

    static func permission() async -> Permission {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:                        return .notDetermined
        case .authorized, .provisional, .ephemeral: return .authorized
        default:                                    return .denied
        }
    }

    /// Shows the system prompt. Only call this from a deliberate user action.
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Turns reminders on: asks for permission if needed, then schedules.
    /// Returns false when permission was refused or the schedule failed, so the
    /// caller can put the toggle back and explain why.
    @discardableResult
    static func enableReminder(hour: Int, minute: Int) async -> Bool {
        switch await permission() {
        case .authorized:
            break
        case .notDetermined:
            guard await requestAuthorization() else { return false }
        case .denied:
            return false
        }
        return await schedule(hour: hour, minute: minute)
    }

    /// Re-applies an already-granted schedule. Never prompts — safe on launch
    /// and on foreground.
    static func rescheduleIfAuthorized(_ preferences: AppPreferences) {
        Task {
            guard preferences.notificationsEnabled,
                  await permission() == .authorized else { return }
            await schedule(hour: preferences.reminderHour,
                           minute: preferences.reminderMinute)
        }
    }

    @discardableResult
    private static func schedule(hour: Int, minute: Int) async -> Bool {
        let content = UNMutableNotificationContent()
        content.title = "Your HabitKin is waiting"
        content.body  = "There are quests left to finish today."
        content.sound = .default

        var components = DateComponents()
        components.hour   = max(0, min(23, hour))
        components.minute = max(0, min(59, minute))

        let request = UNNotificationRequest(
            identifier: dailyReminderId,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        )

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderId])
        do {
            try await center.add(request)
            return true
        } catch {
            return false
        }
    }

    static func cancelDailyReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [dailyReminderId])
    }
}

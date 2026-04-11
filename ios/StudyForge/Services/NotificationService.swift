import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()
    private let reminderIdentifier = "review-reminder"

    private init() {}

    /// Request .alert + .sound + .badge authorization.
    /// Returns true if granted. Safe to call multiple times; iOS only
    /// surfaces the system prompt on the first call.
    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Cancel any existing review reminder, then schedule a new one for
    /// tomorrow morning at 08:00 local time if there is at least one card
    /// due by that time. If permission is not granted, silently no-ops.
    func rescheduleReviewReminder(dueCount: Int) async {
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])

        guard dueCount > 0 else { return }

        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional else {
            return
        }

        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        comps.hour = 8
        comps.minute = 0

        let content = UNMutableNotificationContent()
        content.title = "StudyForge"
        content.body = "復習カードが\(dueCount)枚待っています"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(
            identifier: reminderIdentifier,
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }
}

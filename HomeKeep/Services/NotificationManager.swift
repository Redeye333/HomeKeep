import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    func scheduleNotification(for task: MaintenanceTask, settings: UserSettings) {
        let center = UNUserNotificationCenter.current()

        // Remove existing notifications for this task
        let identifier = task.id.uuidString
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        // Calculate notification date
        let calendar = Calendar.current
        guard let notifyDate = calendar.date(
            byAdding: .day,
            value: -settings.daysBeforeDue,
            to: task.nextDueDate
        ) else { return }

        // Don't schedule if the notification date has already passed
        if notifyDate < Date() {
            // If already overdue, schedule for now + 1 minute
            if task.nextDueDate < Date() { return }
            scheduleImmediateNotification(for: task, identifier: identifier)
            return
        }

        // Set notification time
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: notifyDate)
        dateComponents.hour = settings.reminderHour
        dateComponents.minute = settings.reminderMinute

        let content = UNMutableNotificationContent()
        content.title = "HomeKeep Reminder"
        content.body = "Time to \(task.name.lowercased())"
        content.sound = .default
        content.badge = 1

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    private func scheduleImmediateNotification(for task: MaintenanceTask, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = "HomeKeep Reminder"
        content.body = "Time to \(task.name.lowercased())"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(for task: MaintenanceTask) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }

    func rescheduleAllNotifications(tasks: [MaintenanceTask], settings: UserSettings) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for task in tasks {
            scheduleNotification(for: task, settings: settings)
        }
    }

    func updateBadge(overdueCount: Int) {
        UNUserNotificationCenter.current().setBadgeCount(overdueCount)
    }
}

import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class DashboardViewModel {
    var showingTaskDetail: MaintenanceTask?
    var showingAddTasks = false
    var completedTaskID: UUID?

    func overdueTasks(from tasks: [MaintenanceTask]) -> [MaintenanceTask] {
        tasks.filter { $0.status == .overdue }
            .sorted { $0.nextDueDate < $1.nextDueDate }
    }

    func dueSoonTasks(from tasks: [MaintenanceTask]) -> [MaintenanceTask] {
        tasks.filter { $0.status == .dueSoon }
            .sorted { $0.nextDueDate < $1.nextDueDate }
    }

    func goodTasks(from tasks: [MaintenanceTask]) -> [MaintenanceTask] {
        tasks.filter { $0.status == .good }
            .sorted { $0.nextDueDate < $1.nextDueDate }
    }

    func attentionCount(from tasks: [MaintenanceTask]) -> Int {
        tasks.filter { $0.status == .overdue || $0.status == .dueSoon }.count
    }

    func markTaskComplete(_ task: MaintenanceTask, settings: UserSettings) {
        task.markComplete()
        completedTaskID = task.id
        HapticManager.taskCompleted()
        NotificationManager.shared.scheduleNotification(for: task, settings: settings)

        let overdueCount = 0  // Will be recalculated
        NotificationManager.shared.updateBadge(overdueCount: overdueCount)

        // Reset animation after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.completedTaskID = nil
        }
    }
}

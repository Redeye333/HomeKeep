import Foundation
import SwiftData

@MainActor
@Observable
final class TaskLibraryViewModel {
    var showingCustomTaskForm = false
    var searchText = ""

    var filteredTemplates: [PreloadedTaskTemplate] {
        if searchText.isEmpty {
            return PreloadedTaskLibrary.tasks
        }
        return PreloadedTaskLibrary.tasks.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    func isTaskAdded(_ template: PreloadedTaskTemplate, existingTasks: [MaintenanceTask]) -> Bool {
        existingTasks.contains { $0.name == template.name && $0.isPreloaded }
    }

    func toggleTask(_ template: PreloadedTaskTemplate, existingTasks: [MaintenanceTask], context: ModelContext, settings: UserSettings) {
        if let existing = existingTasks.first(where: { $0.name == template.name && $0.isPreloaded }) {
            NotificationManager.shared.cancelNotification(for: existing)
            context.delete(existing)
        } else {
            let task = template.toMaintenanceTask()
            context.insert(task)
            NotificationManager.shared.scheduleNotification(for: task, settings: settings)
        }
        HapticManager.selectionChanged()
    }

    func addCustomTask(name: String, icon: String, frequencyType: FrequencyType, frequencyValue: Int, notes: String?, context: ModelContext, settings: UserSettings) {
        let task = MaintenanceTask(
            name: name,
            icon: icon,
            notes: notes,
            frequencyType: frequencyType,
            frequencyValue: frequencyValue,
            isPreloaded: false
        )
        context.insert(task)
        NotificationManager.shared.scheduleNotification(for: task, settings: settings)
        HapticManager.mediumTap()
    }
}

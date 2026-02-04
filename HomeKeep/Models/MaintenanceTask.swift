import Foundation
import SwiftData

@Model
final class MaintenanceTask {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var notes: String?
    var frequencyTypeRaw: String
    var frequencyValue: Int
    var lastCompletedDate: Date?
    var nextDueDate: Date
    var isPreloaded: Bool
    var createdAt: Date

    var frequencyType: FrequencyType {
        get { FrequencyType(rawValue: frequencyTypeRaw) ?? .months }
        set { frequencyTypeRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        notes: String? = nil,
        frequencyType: FrequencyType,
        frequencyValue: Int,
        lastCompletedDate: Date? = nil,
        nextDueDate: Date? = nil,
        isPreloaded: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.notes = notes
        self.frequencyTypeRaw = frequencyType.rawValue
        self.frequencyValue = frequencyValue
        self.lastCompletedDate = lastCompletedDate
        self.isPreloaded = isPreloaded
        self.createdAt = Date()

        if let nextDueDate {
            self.nextDueDate = nextDueDate
        } else {
            self.nextDueDate = frequencyType.nextDate(from: Date(), value: frequencyValue)
        }
    }

    // MARK: - Task Status

    enum TaskStatus: Comparable {
        case overdue
        case dueSoon
        case good

        var sortOrder: Int {
            switch self {
            case .overdue: return 0
            case .dueSoon: return 1
            case .good: return 2
            }
        }
    }

    var status: TaskStatus {
        let now = Date()
        let calendar = Calendar.current

        if nextDueDate < now {
            return .overdue
        }

        let weekFromNow = calendar.date(byAdding: .day, value: 7, to: now) ?? now
        if nextDueDate <= weekFromNow {
            return .dueSoon
        }

        return .good
    }

    var statusColor: String {
        switch status {
        case .overdue: return "red"
        case .dueSoon: return "yellow"
        case .good: return "green"
        }
    }

    var frequencyDescription: String {
        if frequencyType == .seasonal {
            return "Seasonal"
        }
        if frequencyValue == 1 {
            let singular = String(frequencyType.pluralUnit.dropLast())
            return "Every \(singular)"
        }
        return "Every \(frequencyValue) \(frequencyType.pluralUnit)"
    }

    var dueDescription: String {
        let now = Date()
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: nextDueDate)).day ?? 0

        if days < 0 {
            let overdueDays = abs(days)
            return overdueDays == 1 ? "1 day overdue" : "\(overdueDays) days overdue"
        } else if days == 0 {
            return "Due today"
        } else if days == 1 {
            return "Due tomorrow"
        } else if days <= 7 {
            return "Due in \(days) days"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "Due \(formatter.string(from: nextDueDate))"
        }
    }

    // MARK: - Actions

    func markComplete() {
        let now = Date()
        lastCompletedDate = now
        nextDueDate = frequencyType.nextDate(from: now, value: frequencyValue)
    }
}

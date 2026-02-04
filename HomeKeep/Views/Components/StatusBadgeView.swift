import SwiftUI

struct StatusBadgeView: View {
    let status: MaintenanceTask.TaskStatus

    private var label: String {
        switch status {
        case .overdue: return "Overdue"
        case .dueSoon: return "Due Soon"
        case .good: return "On Track"
        }
    }

    private var color: Color {
        switch status {
        case .overdue: return Theme.overdue
        case .dueSoon: return Theme.dueSoon
        case .good: return Theme.good
        }
    }

    var body: some View {
        Text(label)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
            )
    }
}

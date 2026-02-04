import SwiftUI

struct TaskRowView: View {
    let task: MaintenanceTask
    let isCompleted: Bool
    let onComplete: () -> Void

    @State private var showCheckmark = false

    private var statusColor: Color {
        switch task.status {
        case .overdue: return Theme.overdue
        case .dueSoon: return Theme.dueSoon
        case .good: return Theme.good
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Leading icon in tinted circle
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.12))
                    .frame(width: 36, height: 36)

                if showCheckmark {
                    Image(systemName: "checkmark")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Theme.accent)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: task.icon)
                        .font(.subheadline)
                        .foregroundStyle(statusColor)
                }
            }

            // Title + due description
            VStack(alignment: .leading, spacing: 2) {
                Text(task.name)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(task.dueDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Status dot
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            // Complete button
            Button {
                onComplete()
            } label: {
                Image(systemName: "checkmark.circle")
                    .font(.title3)
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onChange(of: isCompleted) { _, newValue in
            if newValue {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    showCheckmark = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showCheckmark = false
                    }
                }
            }
        }
    }
}

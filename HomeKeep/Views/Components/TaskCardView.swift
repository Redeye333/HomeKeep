import SwiftUI

struct TaskCardView: View {
    let task: MaintenanceTask
    let isCompleted: Bool
    let onComplete: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var showCheckmark = false

    private var statusColor: Color {
        switch task.status {
        case .overdue: return Theme.overdue
        case .dueSoon: return Theme.dueSoon
        case .good: return Theme.good
        }
    }

    private var statusLabel: String {
        switch task.status {
        case .overdue: return "Overdue"
        case .dueSoon: return "Due Soon"
        case .good: return "On Track"
        }
    }

    var body: some View {
        HStack(spacing: Theme.spacing12) {
            ZStack {
                if showCheckmark {
                    HKIconBadge(icon: "checkmark", color: Theme.primaryPurple, size: 38)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    HKIconBadge(icon: task.icon, color: statusColor, size: 38)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(task.name)
                    .font(Theme.bodyFont)
                    .foregroundStyle(colorScheme == .dark ? .white : Theme.textPrimary)
                    .lineLimit(1)
                Text(task.dueDescription)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            HKChip(label: statusLabel, color: statusColor)

            Button {
                onComplete()
            } label: {
                Image(systemName: "checkmark.circle")
                    .font(.title3)
                    .foregroundStyle(Theme.textSecondary.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(Theme.spacing16)
        .background(
            RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                .fill(colorScheme == .dark ? Theme.darkCardSurface : Theme.cardSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.1 : 0.6), lineWidth: 1)
                )
                .shadow(color: Theme.cardShadowColor, radius: Theme.cardShadowRadius, x: 0, y: Theme.cardShadowY)
        )
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

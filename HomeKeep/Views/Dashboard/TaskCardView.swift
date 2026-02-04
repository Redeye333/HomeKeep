import SwiftUI

struct TaskCardView: View {
    let task: MaintenanceTask
    let isCompleted: Bool
    let onTap: () -> Void
    let onComplete: () -> Void

    @State private var showCheckmark = false

    var statusColor: Color {
        switch task.status {
        case .overdue: return Theme.overdue
        case .dueSoon: return Theme.dueSoon
        case .good: return Theme.good
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Status indicator + icon
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.15))
                        .frame(width: 44, height: 44)

                    if showCheckmark {
                        Image(systemName: "checkmark")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Theme.accent)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: task.icon)
                            .font(.title3)
                            .foregroundStyle(statusColor)
                    }
                }

                // Task info
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.name)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(task.dueDescription)
                        .font(.caption)
                        .foregroundStyle(statusColor)
                }

                Spacer()

                // Quick complete button
                Button {
                    onComplete()
                } label: {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                        .foregroundStyle(Theme.accent.opacity(0.6))
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: .black.opacity(Theme.cardShadowOpacity),
                        radius: Theme.cardShadowRadius,
                        y: 2
                    )
            )
        }
        .buttonStyle(.plain)
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

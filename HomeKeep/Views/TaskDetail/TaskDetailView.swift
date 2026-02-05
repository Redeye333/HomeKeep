import SwiftUI

struct TaskDetailView: View {
    @Bindable var task: MaintenanceTask
    @Bindable var settings: UserSettings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme

    @State private var showCompletionAnimation = false
    @State private var showDeleteConfirmation = false

    private var statusColor: Color {
        switch task.status {
        case .overdue: return Theme.overdue
        case .dueSoon: return Theme.dueSoon
        case .good: return Theme.good
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: Theme.spacing16) {
                        // Hero header card
                        HKCard {
                            HStack(spacing: Theme.spacing16) {
                                HKIconBadge(icon: task.icon, color: statusColor, size: 48)

                                VStack(alignment: .leading, spacing: Theme.spacing4) {
                                    Text(task.name)
                                        .font(Theme.sectionHeaderFont)
                                        .foregroundStyle(colorScheme == .dark ? .white : Theme.textPrimary)
                                    StatusBadgeView(status: task.status)
                                }

                                Spacer()
                            }
                        }

                        // Schedule cards
                        HStack(spacing: Theme.spacing12) {
                            detailMiniCard(
                                icon: "arrow.trianglehead.2.clockwise",
                                title: "Frequency",
                                value: task.frequencyDescription
                            )
                            detailMiniCard(
                                icon: "checkmark.circle",
                                title: "Last Done",
                                value: task.lastCompletedDate.map {
                                    DateFormatter.mediumDate.string(from: $0)
                                } ?? "Never"
                            )
                        }

                        HKCard {
                            HStack {
                                VStack(alignment: .leading, spacing: Theme.spacing4) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "calendar")
                                            .font(.caption)
                                            .foregroundStyle(Theme.primaryPurple)
                                        Text("Next Due")
                                            .font(Theme.captionFont)
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                    Text(DateFormatter.mediumDate.string(from: task.nextDueDate))
                                        .font(Theme.bodyFont.weight(.medium))
                                        .foregroundStyle(statusColor)
                                }
                                Spacer()
                                Text(task.dueDescription)
                                    .font(Theme.captionFont)
                                    .foregroundStyle(statusColor)
                            }
                        }

                        // Notes
                        if let notes = task.notes, !notes.isEmpty {
                            HKCard {
                                VStack(alignment: .leading, spacing: Theme.spacing8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "note.text")
                                            .font(.caption)
                                            .foregroundStyle(Theme.primaryPurple)
                                        Text("Notes")
                                            .font(Theme.captionFont.weight(.semibold))
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                    Text(notes)
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(colorScheme == .dark ? .white : Theme.textPrimary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        // Delete
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "trash")
                                    .font(.caption)
                                Text("Delete Task")
                                    .font(Theme.secondaryFont)
                            }
                            .foregroundStyle(Theme.overdue)
                        }
                        .padding(.top, Theme.spacing8)

                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, Theme.spacing16)
                    .padding(.top, Theme.spacing8)
                }

                // Sticky Mark Done button
                VStack {
                    Spacer()
                    HKPrimaryButton(title: "Mark Done", icon: "checkmark.circle.fill") {
                        markComplete()
                    }
                    .padding(.horizontal, Theme.spacing16)
                    .padding(.bottom, Theme.spacing16)
                }
            }
            .navigationTitle("Task Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.primaryPurple)
                }
            }
            .overlay {
                if showCompletionAnimation {
                    completionOverlay
                }
            }
            .confirmationDialog("Delete Task", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    NotificationManager.shared.cancelNotification(for: task)
                    modelContext.delete(task)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete \"\(task.name)\"?")
            }
        }
    }

    // MARK: - Mini Card

    private func detailMiniCard(icon: String, title: String, value: String) -> some View {
        HKCard {
            VStack(alignment: .leading, spacing: Theme.spacing4) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(Theme.primaryPurple)
                    Text(title)
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                }
                Text(value)
                    .font(Theme.bodyFont.weight(.medium))
                    .foregroundStyle(colorScheme == .dark ? .white : Theme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Completion Overlay

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { showCompletionAnimation = false }
                }

            VStack(spacing: Theme.spacing12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Theme.primaryPurple)
                    .symbolEffect(.bounce, value: showCompletionAnimation)

                Text("Done!")
                    .font(Theme.screenTitleFont)

                Text("Next due \(DateFormatter.mediumDate.string(from: task.nextDueDate))")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                    )
            )
            .transition(.scale.combined(with: .opacity))
        }
    }

    // MARK: - Actions

    private func markComplete() {
        task.markComplete()
        HapticManager.taskCompleted()
        NotificationManager.shared.scheduleNotification(for: task, settings: settings)

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showCompletionAnimation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { showCompletionAnimation = false }
        }
    }
}

// MARK: - DateFormatter Extension

extension DateFormatter {
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

import SwiftUI

struct TaskDetailView: View {
    @Bindable var task: MaintenanceTask
    @Bindable var settings: UserSettings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showCompletionAnimation = false
    @State private var isEditing = false
    @State private var showDeleteConfirmation = false

    var statusColor: Color {
        switch task.status {
        case .overdue: return Theme.overdue
        case .dueSoon: return Theme.dueSoon
        case .good: return Theme.good
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header card
                    headerCard

                    // Info cards
                    infoSection

                    // Notes
                    if let notes = task.notes, !notes.isEmpty {
                        notesCard(notes)
                    }

                    // Mark Done button
                    markDoneButton

                    // Delete button
                    deleteButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Task Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
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
                Text("Are you sure you want to delete \"\(task.name)\"? This cannot be undone.")
            }
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: task.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(statusColor)
            }

            Text(task.name)
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)

            Text(task.dueDescription)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(statusColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(statusColor.opacity(0.12))
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(Theme.cardShadowOpacity), radius: Theme.cardShadowRadius, y: 2)
        )
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(spacing: 1) {
            infoRow(icon: "repeat", label: "Frequency", value: task.frequencyDescription)

            Divider().padding(.leading, 52)

            infoRow(
                icon: "checkmark.circle",
                label: "Last Completed",
                value: task.lastCompletedDate.map {
                    DateFormatter.mediumDate.string(from: $0)
                } ?? "Never"
            )

            Divider().padding(.leading, 52)

            infoRow(
                icon: "calendar",
                label: "Next Due",
                value: DateFormatter.mediumDate.string(from: task.nextDueDate)
            )
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(Theme.cardShadowOpacity), radius: Theme.cardShadowRadius, y: 2)
        )
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Theme.accent)
                .frame(width: 28)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.medium))
        }
        .padding()
    }

    // MARK: - Notes Card

    private func notesCard(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Notes", systemImage: "note.text")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(notes)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(Theme.cardShadowOpacity), radius: Theme.cardShadowRadius, y: 2)
        )
    }

    // MARK: - Mark Done Button

    private var markDoneButton: some View {
        Button {
            markComplete()
        } label: {
            Label("Mark Done", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                .shadow(color: Theme.accent.opacity(0.3), radius: 8, y: 4)
        }
        .padding(.top, 8)
    }

    // MARK: - Delete Button

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            Label("Delete Task", systemImage: "trash")
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
    }

    // MARK: - Completion Animation

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showCompletionAnimation = false
                    }
                }

            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Theme.accent)
                    .symbolEffect(.bounce, value: showCompletionAnimation)

                Text("Done!")
                    .font(.title.weight(.bold))

                Text("Next due \(DateFormatter.mediumDate.string(from: task.nextDueDate))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
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
            withAnimation {
                showCompletionAnimation = false
            }
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

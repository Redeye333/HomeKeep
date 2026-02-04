import SwiftUI

struct TaskDetailView: View {
    @Bindable var task: MaintenanceTask
    @Bindable var settings: UserSettings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

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
            ZStack(alignment: .bottom) {
                Form {
                    // Info section
                    Section {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(statusColor.opacity(0.12))
                                    .frame(width: 40, height: 40)
                                Image(systemName: task.icon)
                                    .font(.body)
                                    .foregroundStyle(statusColor)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(task.name)
                                    .font(.headline)
                                StatusBadgeView(status: task.status)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    // Schedule section
                    Section("Schedule") {
                        LabeledContent("Frequency") {
                            Text(task.frequencyDescription)
                        }

                        LabeledContent("Next Due") {
                            Text(task.dueDescription)
                                .foregroundStyle(statusColor)
                        }

                        LabeledContent("Due Date") {
                            Text(DateFormatter.mediumDate.string(from: task.nextDueDate))
                        }

                        LabeledContent("Last Completed") {
                            Text(task.lastCompletedDate.map {
                                DateFormatter.mediumDate.string(from: $0)
                            } ?? "Never")
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Notes section
                    if let notes = task.notes, !notes.isEmpty {
                        Section("Notes") {
                            Text(notes)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Danger zone
                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete Task", systemImage: "trash")
                        }
                    }

                    // Bottom spacer for the sticky button
                    Section {} footer: {
                        Spacer()
                            .frame(height: 72)
                    }
                }

                // Sticky Mark Done button
                VStack {
                    Button {
                        markComplete()
                    } label: {
                        Label("Mark Done", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accent)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .background(.bar)
            }
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
                Text("Are you sure you want to delete \"\(task.name)\"?")
            }
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

            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Theme.accent)
                    .symbolEffect(.bounce, value: showCompletionAnimation)

                Text("Done!")
                    .font(.title3.weight(.semibold))

                Text("Next due \(DateFormatter.mediumDate.string(from: task.nextDueDate))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
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

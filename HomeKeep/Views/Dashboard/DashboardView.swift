import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \MaintenanceTask.nextDueDate) private var tasks: [MaintenanceTask]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DashboardViewModel()
    @Bindable var settings: UserSettings

    var body: some View {
        NavigationStack {
            Group {
                if tasks.isEmpty {
                    EmptyStateView(
                        onAddTasks: { viewModel.showingAddTasks = true }
                    )
                } else {
                    taskList
                }
            }
            .navigationTitle("HomeKeep")
            .overlay(alignment: .bottomTrailing) {
                if !tasks.isEmpty {
                    FloatingAddButton {
                        viewModel.showingAddTasks = true
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddTasks) {
                TaskLibraryView(settings: settings)
            }
            .sheet(item: $viewModel.showingTaskDetail) { task in
                TaskDetailView(task: task, settings: settings)
            }
        }
        .tint(Theme.accent)
        .onAppear {
            let overdueCount = viewModel.overdueTasks(from: tasks).count
            NotificationManager.shared.updateBadge(overdueCount: overdueCount)
        }
    }

    // MARK: - Task List

    private var taskList: some View {
        List {
            // Summary header
            summarySection

            // Overdue
            let overdue = viewModel.overdueTasks(from: tasks)
            if !overdue.isEmpty {
                Section {
                    ForEach(overdue) { task in
                        taskRow(task)
                    }
                    .onDelete { indexSet in
                        deleteItems(indexSet, from: overdue)
                    }
                } header: {
                    Label("Overdue", systemImage: "exclamationmark.circle.fill")
                        .foregroundStyle(Theme.overdue)
                        .font(.subheadline.weight(.semibold))
                }
            }

            // Due Soon
            let dueSoon = viewModel.dueSoonTasks(from: tasks)
            if !dueSoon.isEmpty {
                Section {
                    ForEach(dueSoon) { task in
                        taskRow(task)
                    }
                    .onDelete { indexSet in
                        deleteItems(indexSet, from: dueSoon)
                    }
                } header: {
                    Label("Due Soon", systemImage: "clock.fill")
                        .foregroundStyle(Theme.dueSoon)
                        .font(.subheadline.weight(.semibold))
                }
            }

            // Up Next
            let good = viewModel.goodTasks(from: tasks)
            if !good.isEmpty {
                Section {
                    ForEach(good) { task in
                        taskRow(task)
                    }
                    .onDelete { indexSet in
                        deleteItems(indexSet, from: good)
                    }
                } header: {
                    Label("Up Next", systemImage: "calendar")
                        .font(.subheadline.weight(.semibold))
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Summary

    private var summarySection: some View {
        let count = viewModel.attentionCount(from: tasks)
        return Section {
            if count > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(Theme.overdue)
                    Text("\(count) \(count == 1 ? "task needs" : "tasks need") attention")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.good)
                    Text("Your home is in great shape")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Row

    private func taskRow(_ task: MaintenanceTask) -> some View {
        Button {
            viewModel.showingTaskDetail = task
        } label: {
            TaskRowView(
                task: task,
                isCompleted: viewModel.completedTaskID == task.id,
                onComplete: {
                    viewModel.markTaskComplete(task, settings: settings)
                }
            )
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                viewModel.markTaskComplete(task, settings: settings)
            } label: {
                Label("Done", systemImage: "checkmark")
            }
            .tint(Theme.accent)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button(role: .destructive) {
                NotificationManager.shared.cancelNotification(for: task)
                modelContext.delete(task)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Actions

    private func deleteItems(_ offsets: IndexSet, from sectionTasks: [MaintenanceTask]) {
        for index in offsets {
            let task = sectionTasks[index]
            NotificationManager.shared.cancelNotification(for: task)
            modelContext.delete(task)
        }
    }
}

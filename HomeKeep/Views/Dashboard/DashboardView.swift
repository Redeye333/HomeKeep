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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showingAddTasks = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Theme.accent)
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
            Task {
                let overdueCount = viewModel.overdueTasks(from: tasks).count
                NotificationManager.shared.updateBadge(overdueCount: overdueCount)
            }
        }
    }

    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Summary header
                summaryHeader

                // Overdue section
                let overdue = viewModel.overdueTasks(from: tasks)
                if !overdue.isEmpty {
                    sectionHeader("Overdue", color: Theme.overdue, count: overdue.count)
                    ForEach(overdue) { task in
                        TaskCardView(
                            task: task,
                            isCompleted: viewModel.completedTaskID == task.id,
                            onTap: { viewModel.showingTaskDetail = task },
                            onComplete: { viewModel.markTaskComplete(task, settings: settings) }
                        )
                    }
                }

                // Due soon section
                let dueSoon = viewModel.dueSoonTasks(from: tasks)
                if !dueSoon.isEmpty {
                    sectionHeader("Due This Week", color: Theme.dueSoon, count: dueSoon.count)
                    ForEach(dueSoon) { task in
                        TaskCardView(
                            task: task,
                            isCompleted: viewModel.completedTaskID == task.id,
                            onTap: { viewModel.showingTaskDetail = task },
                            onComplete: { viewModel.markTaskComplete(task, settings: settings) }
                        )
                    }
                }

                // Good section
                let good = viewModel.goodTasks(from: tasks)
                if !good.isEmpty {
                    sectionHeader("All Good", color: Theme.good, count: good.count)
                    ForEach(good) { task in
                        TaskCardView(
                            task: task,
                            isCompleted: viewModel.completedTaskID == task.id,
                            onTap: { viewModel.showingTaskDetail = task },
                            onComplete: { viewModel.markTaskComplete(task, settings: settings) }
                        )
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    private var summaryHeader: some View {
        let count = viewModel.attentionCount(from: tasks)
        return Group {
            if count > 0 {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(count > 0 ? Theme.overdue : Theme.good)
                    Text("\(count) \(count == 1 ? "task needs" : "tasks need") attention")
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                        .fill(Theme.overdue.opacity(0.1))
                )
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.good)
                    Text("Your home is in great shape!")
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                        .fill(Theme.good.opacity(0.1))
                )
            }
        }
    }

    private func sectionHeader(_ title: String, color: Color, count: Int) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("(\(count))")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .padding(.top, 8)
    }
}

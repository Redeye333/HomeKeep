import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \MaintenanceTask.nextDueDate) private var tasks: [MaintenanceTask]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel = DashboardViewModel()
    @Bindable var settings: UserSettings

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                Group {
                    if tasks.isEmpty {
                        EmptyStateView(
                            onAddTasks: { viewModel.showingAddTasks = true }
                        )
                    } else {
                        taskList
                    }
                }
            }
            .navigationTitle("HomeKeep")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showingAddTasks = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Theme.primaryPurple)
                            )
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
        .tint(Theme.primaryPurple)
        .onAppear {
            let overdueCount = viewModel.overdueTasks(from: tasks).count
            NotificationManager.shared.updateBadge(overdueCount: overdueCount)
        }
    }

    // MARK: - Task List

    private var taskList: some View {
        ScrollView {
            VStack(spacing: Theme.spacing16) {
                summaryCard
                    .padding(.horizontal, Theme.spacing16)

                let overdue = viewModel.overdueTasks(from: tasks)
                if !overdue.isEmpty {
                    sectionView("Overdue", icon: "exclamationmark.circle.fill", color: Theme.overdue, tasks: overdue)
                }

                let dueSoon = viewModel.dueSoonTasks(from: tasks)
                if !dueSoon.isEmpty {
                    sectionView("Due Soon", icon: "clock.fill", color: Theme.dueSoon, tasks: dueSoon)
                }

                let good = viewModel.goodTasks(from: tasks)
                if !good.isEmpty {
                    sectionView("Up Next", icon: "calendar", color: Theme.primaryPurple, tasks: good)
                }

                Spacer(minLength: 80)
            }
            .padding(.top, Theme.spacing8)
        }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        let overdueCount = viewModel.overdueTasks(from: tasks).count
        let dueSoonCount = viewModel.dueSoonTasks(from: tasks).count
        let attentionCount = overdueCount + dueSoonCount
        let upcomingCount = viewModel.goodTasks(from: tasks).count

        return HKCard {
            VStack(alignment: .leading, spacing: Theme.spacing12) {
                if attentionCount > 0 {
                    Text("\(attentionCount) \(attentionCount == 1 ? "task needs" : "tasks need") attention")
                        .font(Theme.sectionHeaderFont)
                        .foregroundStyle(colorScheme == .dark ? .white : Theme.textPrimary)
                } else {
                    Text("Your home is in great shape")
                        .font(Theme.sectionHeaderFont)
                        .foregroundStyle(colorScheme == .dark ? .white : Theme.textPrimary)
                }

                HStack(spacing: Theme.spacing8) {
                    if overdueCount > 0 {
                        HKChip(label: "\(overdueCount) Overdue", color: Theme.overdue)
                    }
                    if dueSoonCount > 0 {
                        HKChip(label: "\(dueSoonCount) Due Soon", color: Theme.dueSoon)
                    }
                    if upcomingCount > 0 {
                        HKChip(label: "\(upcomingCount) Upcoming", color: Theme.primaryPurple)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Section

    private func sectionView(_ title: String, icon: String, color: Color, tasks: [MaintenanceTask]) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacing8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(title)
                    .font(Theme.sectionHeaderFont)
                    .foregroundStyle(colorScheme == .dark ? .white : Theme.textPrimary)
            }
            .padding(.horizontal, Theme.spacing20)

            VStack(spacing: Theme.spacing8) {
                ForEach(tasks) { task in
                    taskCard(task)
                }
            }
            .padding(.horizontal, Theme.spacing16)
        }
    }

    // MARK: - Task Card

    private func taskCard(_ task: MaintenanceTask) -> some View {
        Button {
            viewModel.showingTaskDetail = task
        } label: {
            TaskCardView(
                task: task,
                isCompleted: viewModel.completedTaskID == task.id,
                onComplete: {
                    viewModel.markTaskComplete(task, settings: settings)
                }
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                viewModel.markTaskComplete(task, settings: settings)
            } label: {
                Label("Mark Done", systemImage: "checkmark")
            }
            Button(role: .destructive) {
                NotificationManager.shared.cancelNotification(for: task)
                modelContext.delete(task)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

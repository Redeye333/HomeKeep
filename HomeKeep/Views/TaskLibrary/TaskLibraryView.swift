import SwiftUI
import SwiftData

struct TaskLibraryView: View {
    @Query(sort: \MaintenanceTask.nextDueDate) private var existingTasks: [MaintenanceTask]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = TaskLibraryViewModel()
    @Bindable var settings: UserSettings
    @State private var selectedSegment = 0
    @State private var showProUpsell = false

    private var isPro: Bool {
        settings.isProUnlocked || StoreManager.shared.isProUnlocked
    }

    private var canAddMore: Bool {
        isPro || existingTasks.count < Theme.freeTaskLimit
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segment control
                Picker("View", selection: $selectedSegment) {
                    Text("My Tasks").tag(0)
                    Text("Library").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Content
                Group {
                    if selectedSegment == 0 {
                        myTasksList
                    } else {
                        libraryList
                    }
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $viewModel.showingCustomTaskForm) {
                CustomTaskFormView(settings: settings)
            }
            .sheet(isPresented: $showProUpsell) {
                ProUpsellSheet(settings: settings, feature: "More than \(Theme.freeTaskLimit) tasks")
            }
        }
    }

    // MARK: - My Tasks

    private var myTasksList: some View {
        Group {
            if existingTasks.isEmpty {
                ContentUnavailableView {
                    Label("No Active Tasks", systemImage: "checklist")
                } description: {
                    Text("Switch to Library to add tasks.")
                }
            } else {
                List {
                    if !isPro {
                        Section {
                            HStack {
                                Text("\(existingTasks.count)/\(Theme.freeTaskLimit) tasks")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                if !canAddMore {
                                    ProBadgeView()
                                }
                            }
                        }
                    }

                    Section {
                        ForEach(existingTasks) { task in
                            HStack(spacing: 12) {
                                Image(systemName: task.icon)
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.accent)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(task.name)
                                        .font(.body)
                                    Text(task.frequencyDescription)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                StatusBadgeView(status: task.status)
                            }
                            .padding(.vertical, 2)
                        }
                        .onDelete(perform: deleteTasks)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }

    // MARK: - Library

    private var libraryList: some View {
        List {
            // Custom task
            Section {
                Button {
                    if canAddMore {
                        viewModel.showingCustomTaskForm = true
                    } else {
                        showProUpsell = true
                    }
                } label: {
                    Label {
                        Text("Create Custom Task")
                            .foregroundStyle(.primary)
                    } icon: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Theme.accent)
                    }
                }
            }

            // Preloaded tasks
            Section("Common Tasks") {
                ForEach(viewModel.filteredTemplates) { template in
                    HStack(spacing: 12) {
                        Image(systemName: template.icon)
                            .font(.subheadline)
                            .foregroundStyle(Theme.accent)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(template.name)
                                .font(.body)
                            Text(frequencyLabel(template))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        let isAdded = viewModel.isTaskAdded(template, existingTasks: existingTasks)
                        Toggle("", isOn: Binding(
                            get: { isAdded },
                            set: { _ in
                                if !isAdded && !canAddMore {
                                    showProUpsell = true
                                } else {
                                    viewModel.toggleTask(
                                        template,
                                        existingTasks: existingTasks,
                                        context: modelContext,
                                        settings: settings
                                    )
                                }
                            }
                        ))
                        .tint(Theme.accent)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $viewModel.searchText, prompt: "Search tasks")
    }

    // MARK: - Helpers

    private func frequencyLabel(_ template: PreloadedTaskTemplate) -> String {
        if template.frequencyType == .seasonal {
            return "Seasonal"
        }
        if template.frequencyValue == 1 {
            let singular = String(template.frequencyType.pluralUnit.dropLast())
            return "Every \(singular)"
        }
        return "Every \(template.frequencyValue) \(template.frequencyType.pluralUnit)"
    }

    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            let task = existingTasks[index]
            NotificationManager.shared.cancelNotification(for: task)
            modelContext.delete(task)
        }
    }
}

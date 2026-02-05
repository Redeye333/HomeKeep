import SwiftUI
import SwiftData

struct TaskLibraryView: View {
    @Query(sort: \MaintenanceTask.nextDueDate) private var existingTasks: [MaintenanceTask]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel = TaskLibraryViewModel()
    @Bindable var settings: UserSettings
    @State private var selectedSegment = 0
    @State private var showProUpsell = false
    @State private var templateToCustomize: PreloadedTaskTemplate?

    private var isPro: Bool {
        settings.isProUnlocked || StoreManager.shared.isProUnlocked
    }

    private var canAddMore: Bool {
        isPro || existingTasks.count < Theme.freeTaskLimit
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                VStack(spacing: 0) {
                    Picker("View", selection: $selectedSegment) {
                        Text("My Tasks").tag(0)
                        Text("Library").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, Theme.spacing16)
                    .padding(.vertical, Theme.spacing8)

                    Group {
                        if selectedSegment == 0 {
                            myTasksList
                        } else {
                            libraryList
                        }
                    }
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.primaryPurple)
                }
            }
            .sheet(isPresented: $viewModel.showingCustomTaskForm) {
                CustomTaskFormView(settings: settings)
            }
            .sheet(item: $templateToCustomize) { template in
                TemplateConfigSheet(
                    template: template,
                    settings: settings
                )
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
                VStack(spacing: Theme.spacing16) {
                    Spacer()
                    HKIconBadge(icon: "checklist", color: Theme.primaryPurple, size: 48)
                    Text("No Active Tasks")
                        .font(Theme.sectionHeaderFont)
                    Text("Switch to Library to add tasks.")
                        .font(Theme.secondaryFont)
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: Theme.spacing8) {
                        if !isPro {
                            HKCard {
                                HStack {
                                    Text("\(existingTasks.count)/\(Theme.freeTaskLimit) tasks")
                                        .font(Theme.captionFont)
                                        .foregroundStyle(Theme.textSecondary)
                                    Spacer()
                                    if !canAddMore {
                                        ProBadgeView()
                                    }
                                }
                            }
                            .padding(.horizontal, Theme.spacing16)
                        }

                        ForEach(existingTasks) { task in
                            HKCard {
                                HStack(spacing: Theme.spacing12) {
                                    HKIconBadge(icon: task.icon, color: Theme.primaryPurple, size: 36)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(task.name)
                                            .font(Theme.bodyFont)
                                            .foregroundStyle(colorScheme == .dark ? .white : Theme.textPrimary)
                                        Text(task.frequencyDescription)
                                            .font(Theme.captionFont)
                                            .foregroundStyle(Theme.textSecondary)
                                    }

                                    Spacer()

                                    StatusBadgeView(status: task.status)
                                }
                            }
                            .padding(.horizontal, Theme.spacing16)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top, Theme.spacing8)
                }
            }
        }
    }

    // MARK: - Library

    private var libraryList: some View {
        ScrollView {
            VStack(spacing: Theme.spacing8) {
                Button {
                    if canAddMore {
                        viewModel.showingCustomTaskForm = true
                    } else {
                        showProUpsell = true
                    }
                } label: {
                    HKCard {
                        HStack(spacing: Theme.spacing12) {
                            HKIconBadge(icon: "plus.circle.fill", color: Theme.primaryPurple, size: 36)
                            Text("Create Custom Task")
                                .font(Theme.bodyFont)
                                .foregroundStyle(colorScheme == .dark ? .white : Theme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Theme.spacing16)

                HStack {
                    Text("Common Tasks")
                        .font(Theme.sectionHeaderFont)
                        .foregroundStyle(colorScheme == .dark ? .white : Theme.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, Theme.spacing20)
                .padding(.top, Theme.spacing8)

                ForEach(viewModel.filteredTemplates) { template in
                    let isAdded = viewModel.isTaskAdded(template, existingTasks: existingTasks)

                    Button {
                        if isAdded {
                            viewModel.toggleTask(
                                template,
                                existingTasks: existingTasks,
                                context: modelContext,
                                settings: settings
                            )
                        } else if !canAddMore {
                            showProUpsell = true
                        } else {
                            templateToCustomize = template
                        }
                    } label: {
                        HKCard {
                            HStack(spacing: Theme.spacing12) {
                                HKIconBadge(icon: template.icon, color: isAdded ? Theme.good : Theme.primaryPurple, size: 36)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(template.name)
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(colorScheme == .dark ? .white : Theme.textPrimary)
                                    Text(frequencyLabel(template))
                                        .font(Theme.captionFont)
                                        .foregroundStyle(Theme.textSecondary)
                                }

                                Spacer()

                                if isAdded {
                                    HKChip(label: "Added", color: Theme.good)
                                } else {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(Theme.primaryPurple)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Theme.spacing16)
                }

                Spacer(minLength: 40)
            }
            .padding(.top, Theme.spacing8)
        }
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
}

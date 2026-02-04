import SwiftUI
import SwiftData

struct TaskLibraryView: View {
    @Query private var existingTasks: [MaintenanceTask]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = TaskLibraryViewModel()
    @Bindable var settings: UserSettings

    var body: some View {
        NavigationStack {
            List {
                // Custom task button
                Section {
                    Button {
                        viewModel.showingCustomTaskForm = true
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
                        HStack {
                            Image(systemName: template.icon)
                                .font(.title3)
                                .foregroundStyle(Theme.accent)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(template.name)
                                    .font(.body)
                                Text(frequencyLabel(template))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: Binding(
                                get: { viewModel.isTaskAdded(template, existingTasks: existingTasks) },
                                set: { _ in
                                    viewModel.toggleTask(template, existingTasks: existingTasks, context: modelContext, settings: settings)
                                }
                            ))
                            .tint(Theme.accent)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search tasks")
            .navigationTitle("Add Tasks")
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
        }
    }

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

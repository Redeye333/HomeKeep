import SwiftUI
import SwiftData

struct CustomTaskFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var settings: UserSettings

    @State private var name = ""
    @State private var icon = "wrench"
    @State private var frequencyType: FrequencyType = .months
    @State private var frequencyValue = 1
    @State private var notes = ""
    @State private var showingIconPicker = false

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // Task name
                Section("Task Name") {
                    TextField("e.g., Clean gutters", text: $name)
                }

                // Icon
                Section("Icon") {
                    Button {
                        showingIconPicker = true
                    } label: {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Theme.accent.opacity(0.15))
                                    .frame(width: 44, height: 44)

                                Image(systemName: icon)
                                    .font(.title3)
                                    .foregroundStyle(Theme.accent)
                            }

                            Text("Choose Icon")
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Frequency
                Section("Frequency") {
                    Picker("Type", selection: $frequencyType) {
                        ForEach(FrequencyType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }

                    if frequencyType != .seasonal {
                        Stepper("Every \(frequencyValue) \(frequencyValue == 1 ? String(frequencyType.pluralUnit.dropLast()) : frequencyType.pluralUnit)",
                                value: $frequencyValue, in: 1...100)
                    }
                }

                // Notes
                Section("Notes (Optional)") {
                    TextField("Any helpful reminders...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Custom Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        addTask()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPickerView(selectedIcon: $icon)
            }
        }
    }

    private func addTask() {
        let viewModel = TaskLibraryViewModel()
        viewModel.addCustomTask(
            name: name.trimmingCharacters(in: .whitespaces),
            icon: icon,
            frequencyType: frequencyType,
            frequencyValue: frequencyValue,
            notes: notes.isEmpty ? nil : notes,
            context: modelContext,
            settings: settings
        )
        dismiss()
    }
}

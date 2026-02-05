import SwiftUI
import SwiftData

struct TemplateConfigSheet: View {
    let template: PreloadedTaskTemplate
    @Bindable var settings: UserSettings

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var frequencyType: FrequencyType
    @State private var frequencyValue: Int
    @State private var seasonalDate: Date

    init(template: PreloadedTaskTemplate, settings: UserSettings) {
        self.template = template
        self.settings = settings
        _frequencyType = State(initialValue: template.frequencyType)
        _frequencyValue = State(initialValue: template.frequencyValue)

        // Default seasonal date: use template's month/day or Oct 1
        let calendar = Calendar.current
        let defaultMonth = template.seasonalMonth ?? 10
        let defaultDay = template.seasonalDay ?? 1
        var components = DateComponents()
        components.year = calendar.component(.year, from: Date())
        components.month = defaultMonth
        components.day = defaultDay
        _seasonalDate = State(initialValue: calendar.date(from: components) ?? Date())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: Theme.spacing12) {
                        // Task info
                        HKCard {
                            HStack(spacing: Theme.spacing12) {
                                HKIconBadge(icon: template.icon, color: Theme.primaryPurple, size: 44)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(template.name)
                                        .font(Theme.sectionHeaderFont)
                                        .foregroundStyle(colorScheme == .dark ? .white : Theme.textPrimary)
                                    if let notes = template.notes {
                                        Text(notes)
                                            .font(Theme.captionFont)
                                            .foregroundStyle(Theme.textSecondary)
                                            .lineLimit(2)
                                    }
                                }

                                Spacer()
                            }
                        }

                        // Frequency
                        HKCard {
                            VStack(spacing: Theme.spacing12) {
                                VStack(alignment: .leading, spacing: Theme.spacing8) {
                                    Text("Frequency")
                                        .font(Theme.captionFont.weight(.semibold))
                                        .foregroundStyle(Theme.textSecondary)
                                    Picker("Type", selection: $frequencyType) {
                                        ForEach(FrequencyType.allCases) { type in
                                            Text(type.displayName).tag(type)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }

                                if frequencyType == .seasonal {
                                    Divider().foregroundStyle(Theme.divider)
                                    VStack(alignment: .leading, spacing: Theme.spacing8) {
                                        Text("Due each year on")
                                            .font(Theme.captionFont.weight(.semibold))
                                            .foregroundStyle(Theme.textSecondary)
                                        DatePicker(
                                            "Date",
                                            selection: $seasonalDate,
                                            displayedComponents: [.date]
                                        )
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                    }
                                } else {
                                    Divider().foregroundStyle(Theme.divider)
                                    Stepper(
                                        "Every \(frequencyValue) \(frequencyValue == 1 ? String(frequencyType.pluralUnit.dropLast()) : frequencyType.pluralUnit)",
                                        value: $frequencyValue,
                                        in: 1...100
                                    )
                                    .font(Theme.bodyFont)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Theme.spacing16)
                    .padding(.top, Theme.spacing8)
                }
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") { addTask() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.primaryPurple)
                }
            }
        }
    }

    private func addTask() {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: seasonalDate)
        let day = calendar.component(.day, from: seasonalDate)

        let task = MaintenanceTask(
            name: template.name,
            icon: template.icon,
            notes: template.notes,
            frequencyType: frequencyType,
            frequencyValue: frequencyValue,
            seasonalMonth: frequencyType == .seasonal ? month : nil,
            seasonalDay: frequencyType == .seasonal ? day : nil,
            isPreloaded: true
        )
        modelContext.insert(task)
        NotificationManager.shared.scheduleNotification(for: task, settings: settings)
        HapticManager.mediumTap()
        dismiss()
    }
}

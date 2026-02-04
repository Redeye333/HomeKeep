import SwiftUI
import SwiftData

struct SettingsView: View {
    @Bindable var settings: UserSettings
    @Query private var tasks: [MaintenanceTask]
    @State private var storeManager = StoreManager.shared
    @State private var showingProUpsell = false
    @State private var showExportUpsell = false

    private var isPro: Bool {
        settings.isProUnlocked || storeManager.isProUnlocked
    }

    var body: some View {
        NavigationStack {
            Form {
                // Notifications
                Section("Notifications") {
                    DatePicker(
                        "Reminder Time",
                        selection: Binding(
                            get: { settings.reminderTime },
                            set: { settings.reminderTime = $0 }
                        ),
                        displayedComponents: .hourAndMinute
                    )

                    Stepper(
                        "Notify \(settings.daysBeforeDue) \(settings.daysBeforeDue == 1 ? "day" : "days") before",
                        value: Binding(
                            get: { settings.daysBeforeDue },
                            set: { settings.daysBeforeDue = $0 }
                        ),
                        in: 0...14
                    )
                }

                // Appearance
                Section("Appearance") {
                    Picker("Theme", selection: Binding(
                        get: { settings.appearanceMode },
                        set: { settings.appearanceMode = $0 }
                    )) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }

                    if isPro {
                        NavigationLink {
                            Text("App Icon picker coming soon")
                                .foregroundStyle(.secondary)
                        } label: {
                            Text("App Icon")
                        }
                    } else {
                        Button {
                            showingProUpsell = true
                        } label: {
                            HStack {
                                Text("App Icon")
                                    .foregroundStyle(.primary)
                                Spacer()
                                ProBadgeView()
                            }
                        }
                    }
                }

                // HomeKeep Pro
                Section {
                    if isPro {
                        HStack {
                            Label("HomeKeep Pro", systemImage: "star.fill")
                                .foregroundStyle(.orange)
                            Spacer()
                            Text("Unlocked")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Button {
                            showingProUpsell = true
                        } label: {
                            HStack {
                                Label {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Upgrade to Pro")
                                            .foregroundStyle(.primary)
                                        Text("Unlimited tasks, widgets & more · \(Theme.proPrice)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                } icon: {
                                    Image(systemName: "star.circle.fill")
                                        .foregroundStyle(.orange)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }

                    Button("Restore Purchases") {
                        Task {
                            await storeManager.restorePurchases()
                            if storeManager.isProUnlocked {
                                settings.isProUnlocked = true
                            }
                        }
                    }
                } header: {
                    Text("HomeKeep Pro")
                }

                // Export
                Section("Data") {
                    HStack {
                        Text("Active Tasks")
                        Spacer()
                        Text("\(tasks.count)")
                            .foregroundStyle(.secondary)
                    }

                    if isPro {
                        Button {
                            exportCSV()
                        } label: {
                            Label("Export History", systemImage: "square.and.arrow.up")
                        }
                    } else {
                        Button {
                            showExportUpsell = true
                        } label: {
                            HStack {
                                Label("Export History", systemImage: "square.and.arrow.up")
                                    .foregroundStyle(.primary)
                                Spacer()
                                ProBadgeView()
                            }
                        }
                    }
                }

                // About
                Section("About") {
                    LabeledContent("Version", value: "1.0.0")

                    Link(destination: URL(string: "https://github.com/johndaly/HomeKeep")!) {
                        HStack {
                            Text("Source Code")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .onChange(of: settings.reminderHour) { _, _ in rescheduleAll() }
            .onChange(of: settings.reminderMinute) { _, _ in rescheduleAll() }
            .onChange(of: settings.daysBeforeDue) { _, _ in rescheduleAll() }
            .sheet(isPresented: $showingProUpsell) {
                ProUpsellSheet(settings: settings, feature: "This feature")
            }
            .sheet(isPresented: $showExportUpsell) {
                ProUpsellSheet(settings: settings, feature: "Export history")
            }
        }
    }

    private func rescheduleAll() {
        Task {
            NotificationManager.shared.rescheduleAllNotifications(tasks: tasks, settings: settings)
        }
    }

    private func exportCSV() {
        var csv = "Name,Status,Frequency,Next Due,Last Completed\n"
        for task in tasks {
            let lastCompleted = task.lastCompletedDate.map {
                DateFormatter.mediumDate.string(from: $0)
            } ?? "Never"
            csv += "\"\(task.name)\",\"\(task.status)\",\"\(task.frequencyDescription)\",\"\(DateFormatter.mediumDate.string(from: task.nextDueDate))\",\"\(lastCompleted)\"\n"
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("HomeKeep_Export.csv")
        try? csv.write(to: tempURL, atomically: true, encoding: .utf8)

        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            root.present(activityVC, animated: true)
        }
    }
}

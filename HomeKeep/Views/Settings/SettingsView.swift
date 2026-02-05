import SwiftUI
import SwiftData

struct SettingsView: View {
    @Bindable var settings: UserSettings
    @Query private var tasks: [MaintenanceTask]
    @State private var storeManager = StoreManager.shared
    @State private var showingProUpsell = false
    @State private var showExportUpsell = false
    @Environment(\.colorScheme) private var colorScheme

    private var isPro: Bool {
        settings.isProUnlocked || storeManager.isProUnlocked
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: Theme.spacing12) {
                        // Notifications
                        settingsCard {
                            VStack(spacing: Theme.spacing16) {
                                settingsCardHeader(icon: "bell.fill", title: "Notifications")

                                DatePicker(
                                    "Reminder Time",
                                    selection: Binding(
                                        get: { settings.reminderTime },
                                        set: { settings.reminderTime = $0 }
                                    ),
                                    displayedComponents: .hourAndMinute
                                )
                                .font(Theme.bodyFont)

                                Divider().foregroundStyle(Theme.divider)

                                Stepper(
                                    "Notify \(settings.daysBeforeDue) \(settings.daysBeforeDue == 1 ? "day" : "days") before",
                                    value: Binding(
                                        get: { settings.daysBeforeDue },
                                        set: { settings.daysBeforeDue = $0 }
                                    ),
                                    in: 0...14
                                )
                                .font(Theme.bodyFont)
                            }
                        }

                        // Appearance
                        settingsCard {
                            VStack(spacing: Theme.spacing16) {
                                settingsCardHeader(icon: "paintbrush.fill", title: "Appearance")

                                Picker("Theme", selection: Binding(
                                    get: { settings.appearanceMode },
                                    set: { settings.appearanceMode = $0 }
                                )) {
                                    ForEach(AppearanceMode.allCases) { mode in
                                        Text(mode.displayName).tag(mode)
                                    }
                                }
                                .font(Theme.bodyFont)

                                Divider().foregroundStyle(Theme.divider)

                                if isPro {
                                    NavigationLink {
                                        Text("App Icon picker coming soon")
                                            .foregroundStyle(Theme.textSecondary)
                                    } label: {
                                        settingsRow(title: "App Icon") {
                                            Image(systemName: "chevron.right")
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(Theme.textSecondary)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    Button { showingProUpsell = true } label: {
                                        settingsRow(title: "App Icon") { ProBadgeView() }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Pro
                        settingsCard {
                            VStack(spacing: Theme.spacing16) {
                                settingsCardHeader(icon: "star.fill", title: "HomeKeep Pro")

                                if isPro {
                                    HStack {
                                        Text("Pro")
                                            .font(Theme.bodyFont)
                                            .foregroundStyle(colorScheme == .dark ? .white : Theme.textPrimary)
                                        Spacer()
                                        HKChip(label: "Unlocked", color: Theme.primaryPurple)
                                    }
                                } else {
                                    Button { showingProUpsell = true } label: {
                                        HStack(spacing: Theme.spacing12) {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Upgrade to Pro")
                                                    .font(Theme.bodyFont)
                                                    .foregroundStyle(colorScheme == .dark ? .white : Theme.textPrimary)
                                                Text("Unlimited tasks, widgets & more")
                                                    .font(Theme.captionFont)
                                                    .foregroundStyle(Theme.textSecondary)
                                            }
                                            Spacer()
                                            Text(Theme.proPrice)
                                                .font(Theme.bodyFont.weight(.semibold))
                                                .foregroundStyle(Theme.primaryPurple)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }

                                Divider().foregroundStyle(Theme.divider)

                                Button("Restore Purchases") {
                                    Task {
                                        await storeManager.restorePurchases()
                                        if storeManager.isProUnlocked {
                                            settings.isProUnlocked = true
                                        }
                                    }
                                }
                                .font(Theme.captionFont)
                                .foregroundStyle(Theme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        // Data
                        settingsCard {
                            VStack(spacing: Theme.spacing16) {
                                settingsCardHeader(icon: "chart.bar.fill", title: "Data")

                                settingsRow(title: "Active Tasks") {
                                    Text("\(tasks.count)")
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(Theme.textSecondary)
                                }

                                Divider().foregroundStyle(Theme.divider)

                                if isPro {
                                    Button { exportCSV() } label: {
                                        settingsRow(title: "Export History") {
                                            Image(systemName: "square.and.arrow.up")
                                                .font(.caption)
                                                .foregroundStyle(Theme.primaryPurple)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    Button { showExportUpsell = true } label: {
                                        settingsRow(title: "Export History") { ProBadgeView() }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // About
                        settingsCard {
                            VStack(spacing: Theme.spacing16) {
                                settingsCardHeader(icon: "info.circle.fill", title: "About")

                                settingsRow(title: "Version") {
                                    Text("1.0.0")
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(Theme.textSecondary)
                                }

                                Divider().foregroundStyle(Theme.divider)

                                Link(destination: URL(string: "https://github.com/johndaly/HomeKeep")!) {
                                    settingsRow(title: "Source Code") {
                                        Image(systemName: "arrow.up.right.square")
                                            .font(.caption)
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, Theme.spacing16)
                    .padding(.top, Theme.spacing8)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
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

    // MARK: - Reusable Components

    private func settingsCard<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        HKCard { content() }
    }

    private func settingsCardHeader(icon: String, title: String) -> some View {
        HStack(spacing: Theme.spacing8) {
            HKIconBadge(icon: icon, color: Theme.primaryPurple, size: 28)
            Text(title)
                .font(Theme.sectionHeaderFont)
                .foregroundStyle(colorScheme == .dark ? .white : Theme.textPrimary)
            Spacer()
        }
    }

    private func settingsRow<Trailing: View>(title: String, @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack {
            Text(title)
                .font(Theme.bodyFont)
                .foregroundStyle(colorScheme == .dark ? .white : Theme.textPrimary)
            Spacer()
            trailing()
        }
    }

    // MARK: - Actions

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

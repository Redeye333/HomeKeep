import SwiftUI
import SwiftData

struct SettingsView: View {
    @Bindable var settings: UserSettings
    @Query private var tasks: [MaintenanceTask]
    @State private var storeManager = StoreManager.shared
    @State private var showingProPurchase = false
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            Form {
                // Notifications
                Section {
                    DatePicker(
                        "Reminder Time",
                        selection: Binding(
                            get: { settings.reminderTime },
                            set: { settings.reminderTime = $0 }
                        ),
                        displayedComponents: .hourAndMinute
                    )

                    Stepper(
                        "Notify \(settings.daysBeforeDue) \(settings.daysBeforeDue == 1 ? "day" : "days") before due",
                        value: Binding(
                            get: { settings.daysBeforeDue },
                            set: { settings.daysBeforeDue = $0 }
                        ),
                        in: 0...14
                    )
                } header: {
                    Label("Notifications", systemImage: "bell")
                }

                // Appearance
                Section {
                    Picker("Theme", selection: Binding(
                        get: { settings.appearanceMode },
                        set: { settings.appearanceMode = $0 }
                    )) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                } header: {
                    Label("Appearance", systemImage: "paintbrush")
                }

                // HomeKeep Pro
                Section {
                    if settings.isProUnlocked || storeManager.isProUnlocked {
                        HStack {
                            Label("HomeKeep Pro", systemImage: "star.fill")
                                .foregroundStyle(Theme.accent)
                            Spacer()
                            Text("Unlocked")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule().fill(Theme.accent.opacity(0.15))
                                )
                        }
                    } else {
                        Button {
                            showingProPurchase = true
                        } label: {
                            HStack {
                                Label {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Upgrade to Pro")
                                            .foregroundStyle(.primary)
                                        Text("Unlock widgets & more • $2.99")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                } icon: {
                                    Image(systemName: "star.circle.fill")
                                        .foregroundStyle(.yellow)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
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
                    Label("HomeKeep Pro", systemImage: "star")
                }

                // Data
                Section {
                    HStack {
                        Text("Active Tasks")
                        Spacer()
                        Text("\(tasks.count)")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Label("Data", systemImage: "chart.bar")
                }

                // About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "https://github.com/johndaly/HomeKeep")!) {
                        HStack {
                            Text("Source Code")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Label("About", systemImage: "info.circle")
                }
            }
            .navigationTitle("Settings")
            .onChange(of: settings.reminderHour) { _, _ in
                rescheduleAll()
            }
            .onChange(of: settings.reminderMinute) { _, _ in
                rescheduleAll()
            }
            .onChange(of: settings.daysBeforeDue) { _, _ in
                rescheduleAll()
            }
            .sheet(isPresented: $showingProPurchase) {
                ProPurchaseView(settings: settings)
            }
        }
    }

    private func rescheduleAll() {
        Task {
            NotificationManager.shared.rescheduleAllNotifications(tasks: tasks, settings: settings)
        }
    }
}

// MARK: - Pro Purchase View

struct ProPurchaseView: View {
    @Bindable var settings: UserSettings
    @Environment(\.dismiss) private var dismiss
    @State private var storeManager = StoreManager.shared
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)

                    Image(systemName: "star.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 8) {
                    Text("HomeKeep Pro")
                        .font(.title.weight(.bold))

                    Text("One-time purchase. No subscription.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Features
                VStack(alignment: .leading, spacing: 16) {
                    featureRow("widget", "Home Screen & Lock Screen Widgets")
                    featureRow("paintbrush", "Custom Themes")
                    featureRow("heart.fill", "Support Development")
                }
                .padding(.horizontal, 32)

                Spacer()

                // Purchase button
                Button {
                    purchasePro()
                } label: {
                    Group {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Purchase for $2.99")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                }
                .disabled(isPurchasing)
                .padding(.horizontal)

                Button("Restore Purchases") {
                    Task {
                        await storeManager.restorePurchases()
                        if storeManager.isProUnlocked {
                            settings.isProUnlocked = true
                            dismiss()
                        }
                    }
                }
                .font(.subheadline)
                .padding(.bottom, 32)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Purchase Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            .task {
                await storeManager.loadProducts()
            }
        }
    }

    private func featureRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Theme.accent)
                .frame(width: 28)

            Text(text)
                .font(.body)
        }
    }

    private func purchasePro() {
        guard let product = storeManager.products.first else {
            errorMessage = "Product not available. Please try again later."
            showError = true
            return
        }

        isPurchasing = true
        Task {
            do {
                let success = try await storeManager.purchase(product)
                if success {
                    settings.isProUnlocked = true
                    HapticManager.taskCompleted()
                    dismiss()
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isPurchasing = false
        }
    }
}

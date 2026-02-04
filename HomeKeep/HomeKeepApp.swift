import SwiftUI
import SwiftData

@main
struct HomeKeepApp: App {
    @State private var settings = UserSettings()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([MaintenanceTask.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.homekeep.app")
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(settings: settings)
                .onAppear {
                    setupNotifications()
                    setupStore()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func setupNotifications() {
        Task {
            _ = await NotificationManager.shared.requestAuthorization()
        }
    }

    private func setupStore() {
        Task {
            await StoreManager.shared.checkEntitlements()
            await StoreManager.shared.listenForTransactions()
        }
    }
}

import SwiftUI

struct ContentView: View {
    @State var settings: UserSettings

    var body: some View {
        TabView {
            DashboardView(settings: settings)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            TaskLibraryView(settings: settings)
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }

            SettingsView(settings: settings)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Theme.primaryPurple)
        .preferredColorScheme(settings.appearanceMode.colorScheme)
    }
}

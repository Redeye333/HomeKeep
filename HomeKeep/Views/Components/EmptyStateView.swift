import SwiftUI

struct EmptyStateView: View {
    let onAddTasks: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("No Tasks Yet", systemImage: "house")
        } description: {
            Text("Add maintenance tasks to keep your home in great shape.")
        } actions: {
            Button("Add Tasks") {
                onAddTasks()
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)
        }
    }
}

import SwiftUI

struct EmptyStateView: View {
    let onAddTasks: () -> Void

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // House illustration
            ZStack {
                Circle()
                    .fill(Theme.accent.opacity(0.1))
                    .frame(width: 140, height: 140)

                Image(systemName: "house.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Theme.accent)
                    .symbolEffect(.bounce, value: isAnimating)
            }

            VStack(spacing: 8) {
                Text("Your home is in great shape!")
                    .font(.title2.weight(.semibold))

                Text("Add maintenance tasks to keep it that way. 🏡")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            Button {
                onAddTasks()
            } label: {
                Label("Add Tasks", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Theme.accent)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)

            Spacer()
            Spacer()
        }
        .onAppear {
            isAnimating = true
        }
    }
}

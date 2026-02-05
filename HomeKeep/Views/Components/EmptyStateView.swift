import SwiftUI

struct EmptyStateView: View {
    let onAddTasks: () -> Void

    var body: some View {
        VStack(spacing: Theme.spacing20) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Theme.primaryPurple.opacity(0.15), Theme.deepPurple.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)

                Image(systemName: "house")
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.primaryPurple)
            }

            VStack(spacing: Theme.spacing8) {
                Text("No tasks yet")
                    .font(Theme.screenTitleFont)
                    .foregroundStyle(.primary)

                Text("Add a few tasks to keep your home in shape.")
                    .font(Theme.secondaryFont)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            HKPrimaryButton(title: "Add Tasks", icon: "plus") {
                onAddTasks()
            }
            .frame(maxWidth: 200)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, Theme.spacing24)
    }
}

import SwiftUI

struct FloatingAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.primaryPurple, Theme.deepPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Theme.primaryPurple.opacity(0.3), radius: 12, x: 0, y: 6)
                )
        }
        .padding(.trailing, 20)
        .padding(.bottom, 24)
    }
}

import SwiftUI

struct HKCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(Theme.spacing16)
            .background(
                RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                    .fill(colorScheme == .dark ? Theme.darkCardSurface : Theme.cardSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                            .stroke(Color.white.opacity(colorScheme == .dark ? 0.1 : 0.6), lineWidth: 1)
                    )
                    .shadow(color: Theme.cardShadowColor, radius: Theme.cardShadowRadius, x: 0, y: Theme.cardShadowY)
            )
    }
}

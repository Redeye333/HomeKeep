import SwiftUI

struct HKIconBadge: View {
    let icon: String
    var color: Color = Theme.primaryPurple
    var size: CGFloat = 36

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size * 0.5))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: Theme.iconRadius, style: .continuous)
                    .fill(color.opacity(0.12))
            )
    }
}

import SwiftUI

enum Theme {
    static let accent = Color(red: 76/255, green: 175/255, blue: 80/255) // #4CAF50
    static let accentLight = Color(red: 129/255, green: 199/255, blue: 132/255)
    static let accentDark = Color(red: 56/255, green: 142/255, blue: 60/255)

    static let cardBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)

    static let overdue = Color.red
    static let dueSoon = Color.orange
    static let good = Color.green

    static let cardCornerRadius: CGFloat = 16
    static let cardShadowRadius: CGFloat = 4
    static let cardShadowOpacity: CGFloat = 0.08
}

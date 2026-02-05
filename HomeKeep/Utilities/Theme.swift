import SwiftUI

enum Theme {
    // MARK: - Brand Colors
    static let primaryPurple = Color(hex: 0x6D5EF7)
    static let deepPurple = Color(hex: 0x4B3FDB)
    static let accentMint = Color(hex: 0x3DDC97)

    // MARK: - Semantic Colors
    static let accent = primaryPurple

    // Status
    static let overdue = Color(hex: 0xEF4444)
    static let dueSoon = Color(hex: 0xF59E0B)
    static let good = Color(hex: 0x22C55E)

    // Text
    static let textPrimary = Color(hex: 0x111827)
    static let textSecondary = Color(hex: 0x6B7280)

    // Surfaces
    static let cardSurface = Color.white.opacity(0.94)
    static let divider = Color(hex: 0xE5E7EB).opacity(0.5)

    // Background gradient
    static let backgroundTop = Color(hex: 0xF4F2FF)
    static let backgroundBottom = Color(hex: 0xEEF6FF)

    // Dark mode
    static let darkBackgroundTop = Color(hex: 0x1A1625)
    static let darkBackgroundBottom = Color(hex: 0x131020)
    static let darkCardSurface = Color.white.opacity(0.08)

    // MARK: - Typography
    static let largeTitleFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let screenTitleFont = Font.title2.weight(.semibold)
    static let sectionHeaderFont = Font.headline.weight(.semibold)
    static let bodyFont = Font.body
    static let secondaryFont = Font.subheadline
    static let captionFont = Font.caption

    // MARK: - Spacing
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24

    // MARK: - Radii
    static let cardRadius: CGFloat = 22
    static let buttonRadius: CGFloat = 18
    static let iconRadius: CGFloat = 14
    static let chipRadius: CGFloat = 10

    // MARK: - Shadows
    static let cardShadowColor = Color.black.opacity(0.08)
    static let cardShadowRadius: CGFloat = 22
    static let cardShadowY: CGFloat = 10

    // MARK: - Limits
    static let freeTaskLimit = 8
    static let proPrice = "$2.99"
}

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

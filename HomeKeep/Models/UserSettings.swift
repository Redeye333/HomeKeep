import Foundation
import SwiftUI

@Observable
final class UserSettings {
    private let defaults = UserDefaults(suiteName: "group.com.homekeep.app") ?? .standard

    var reminderHour: Int {
        didSet { defaults.set(reminderHour, forKey: "reminderHour") }
    }

    var reminderMinute: Int {
        didSet { defaults.set(reminderMinute, forKey: "reminderMinute") }
    }

    var daysBeforeDue: Int {
        didSet { defaults.set(daysBeforeDue, forKey: "daysBeforeDue") }
    }

    var appearanceMode: AppearanceMode {
        didSet { defaults.set(appearanceMode.rawValue, forKey: "appearanceMode") }
    }

    var isProUnlocked: Bool {
        didSet { defaults.set(isProUnlocked, forKey: "isProUnlocked") }
    }

    var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }

    var reminderTime: Date {
        get {
            var components = DateComponents()
            components.hour = reminderHour
            components.minute = reminderMinute
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            reminderHour = components.hour ?? 9
            reminderMinute = components.minute ?? 0
        }
    }

    init() {
        let defaults = UserDefaults(suiteName: "group.com.homekeep.app") ?? .standard

        if defaults.object(forKey: "reminderHour") == nil {
            defaults.set(9, forKey: "reminderHour")
        }
        if defaults.object(forKey: "daysBeforeDue") == nil {
            defaults.set(1, forKey: "daysBeforeDue")
        }

        self.reminderHour = defaults.integer(forKey: "reminderHour")
        self.reminderMinute = defaults.integer(forKey: "reminderMinute")
        self.daysBeforeDue = defaults.integer(forKey: "daysBeforeDue")
        self.appearanceMode = AppearanceMode(rawValue: defaults.string(forKey: "appearanceMode") ?? "") ?? .system
        self.isProUnlocked = defaults.bool(forKey: "isProUnlocked")
        self.hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")
    }
}

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

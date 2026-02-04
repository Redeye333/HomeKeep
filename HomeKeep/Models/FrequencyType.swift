import Foundation

enum FrequencyType: String, Codable, CaseIterable, Identifiable {
    case days
    case weeks
    case months
    case years
    case seasonal

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .days: return "Days"
        case .weeks: return "Weeks"
        case .months: return "Months"
        case .years: return "Years"
        case .seasonal: return "Seasonal"
        }
    }

    var pluralUnit: String {
        switch self {
        case .days: return "days"
        case .weeks: return "weeks"
        case .months: return "months"
        case .years: return "years"
        case .seasonal: return "season"
        }
    }

    func nextDate(from date: Date, value: Int) -> Date {
        let calendar = Calendar.current
        switch self {
        case .days:
            return calendar.date(byAdding: .day, value: value, to: date) ?? date
        case .weeks:
            return calendar.date(byAdding: .weekOfYear, value: value, to: date) ?? date
        case .months:
            return calendar.date(byAdding: .month, value: value, to: date) ?? date
        case .years:
            return calendar.date(byAdding: .year, value: value, to: date) ?? date
        case .seasonal:
            // Seasonal: advance to next season (~3 months)
            return calendar.date(byAdding: .month, value: 3, to: date) ?? date
        }
    }
}

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Timeline Provider

struct HomeScreenProvider: TimelineProvider {
    func placeholder(in context: Context) -> HomeScreenEntry {
        HomeScreenEntry(
            date: Date(),
            tasks: [
                WidgetTask(name: "HVAC Filter", icon: "wind", dueDate: Date(), isOverdue: false),
                WidgetTask(name: "Gutter Cleaning", icon: "drop.triangle", dueDate: Date().addingTimeInterval(86400 * 7), isOverdue: false),
                WidgetTask(name: "Water Heater", icon: "flame", dueDate: Date().addingTimeInterval(86400 * 30), isOverdue: false),
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HomeScreenEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HomeScreenEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> HomeScreenEntry {
        let schema = Schema([MaintenanceTask.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.homekeep.app")
        )

        guard let container = try? ModelContainer(for: schema, configurations: [config]) else {
            return HomeScreenEntry(date: Date(), tasks: [])
        }

        let context = ModelContext(container)
        let descriptor = FetchDescriptor<MaintenanceTask>(
            sortBy: [SortDescriptor(\.nextDueDate)]
        )

        guard let tasks = try? context.fetch(descriptor) else {
            return HomeScreenEntry(date: Date(), tasks: [])
        }

        let widgetTasks = Array(tasks.prefix(3)).map { task in
            WidgetTask(
                name: task.name,
                icon: task.icon,
                dueDate: task.nextDueDate,
                isOverdue: task.nextDueDate < Date()
            )
        }

        return HomeScreenEntry(date: Date(), tasks: widgetTasks)
    }
}

// MARK: - Entry

struct WidgetTask: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let dueDate: Date
    let isOverdue: Bool
}

struct HomeScreenEntry: TimelineEntry {
    let date: Date
    let tasks: [WidgetTask]
}

// MARK: - Widget View

struct HomeScreenWidgetView: View {
    var entry: HomeScreenEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "house.fill")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color(red: 76/255, green: 175/255, blue: 80/255))
                Text("HomeKeep")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
            }

            if entry.tasks.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.green)
                        Text("All good!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                Spacer()
            } else {
                ForEach(entry.tasks) { task in
                    HStack(spacing: 8) {
                        Image(systemName: task.icon)
                            .font(.caption)
                            .foregroundStyle(task.isOverdue ? .red : Color(red: 76/255, green: 175/255, blue: 80/255))
                            .frame(width: 18)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(task.name)
                                .font(.caption.weight(.medium))
                                .lineLimit(1)

                            Text(shortDueDescription(task.dueDate))
                                .font(.caption2)
                                .foregroundStyle(task.isOverdue ? .red : .secondary)
                        }

                        Spacer()
                    }
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private func shortDueDescription(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: date)).day ?? 0
        if days < 0 { return "\(abs(days))d overdue" }
        if days == 0 { return "Today" }
        if days == 1 { return "Tomorrow" }
        if days <= 7 { return "In \(days) days" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Widget

struct HomeScreenWidget: Widget {
    let kind = "HomeScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HomeScreenProvider()) { entry in
            HomeScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("Upcoming Tasks")
        .description("See your next upcoming maintenance tasks.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

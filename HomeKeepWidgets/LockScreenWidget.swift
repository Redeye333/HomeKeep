import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Timeline Provider

struct LockScreenProvider: TimelineProvider {
    func placeholder(in context: Context) -> LockScreenEntry {
        LockScreenEntry(date: Date(), overdueCount: 2)
    }

    func getSnapshot(in context: Context, completion: @escaping (LockScreenEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LockScreenEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> LockScreenEntry {
        let schema = Schema([MaintenanceTask.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.homekeep.app")
        )

        guard let container = try? ModelContainer(for: schema, configurations: [config]) else {
            return LockScreenEntry(date: Date(), overdueCount: 0)
        }

        let context = ModelContext(container)
        let descriptor = FetchDescriptor<MaintenanceTask>()

        guard let tasks = try? context.fetch(descriptor) else {
            return LockScreenEntry(date: Date(), overdueCount: 0)
        }

        let overdueCount = tasks.filter { $0.nextDueDate < Date() }.count
        return LockScreenEntry(date: Date(), overdueCount: overdueCount)
    }
}

// MARK: - Entry

struct LockScreenEntry: TimelineEntry {
    let date: Date
    let overdueCount: Int
}

// MARK: - Widget View

struct LockScreenWidgetView: View {
    var entry: LockScreenEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryRectangular:
            rectangularView
        case .accessoryInline:
            inlineView
        default:
            circularView
        }
    }

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 2) {
                Image(systemName: "house.fill")
                    .font(.caption)
                Text("\(entry.overdueCount)")
                    .font(.title3.weight(.bold))
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var rectangularView: some View {
        HStack(spacing: 8) {
            Image(systemName: "house.fill")
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text("HomeKeep")
                    .font(.caption.weight(.semibold))
                if entry.overdueCount > 0 {
                    Text("\(entry.overdueCount) overdue")
                        .font(.caption2)
                } else {
                    Text("All caught up!")
                        .font(.caption2)
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var inlineView: some View {
        HStack(spacing: 4) {
            Image(systemName: "house.fill")
            if entry.overdueCount > 0 {
                Text("\(entry.overdueCount) overdue")
            } else {
                Text("All caught up")
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget

struct LockScreenWidget: Widget {
    let kind = "LockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LockScreenProvider()) { entry in
            LockScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("Overdue Tasks")
        .description("Shows count of overdue maintenance tasks.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

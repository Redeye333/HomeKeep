import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss

    private let icons: [String] = [
        // Home & Building
        "house", "house.fill", "house.lodge", "building.2",
        // Tools & Maintenance
        "wrench", "wrench.and.screwdriver", "hammer", "screwdriver",
        // Water & Plumbing
        "drop", "drop.fill", "drop.triangle", "shower",
        // Fire & Safety
        "flame", "flame.circle", "sensor", "exclamationmark.triangle",
        // Air & HVAC
        "wind", "air.conditioner.horizontal", "fan",
        // Cleaning
        "sparkles", "bubbles.and.sparkles", "trash",
        // Appliances
        "refrigerator", "washer", "dishwasher", "oven",
        // Outdoor
        "leaf", "tree", "snowflake", "sun.max",
        // Misc
        "ant", "paintbrush", "lightbulb", "bolt",
        "lock", "key", "clock", "calendar",
        "door.garage.closed", "car", "battery.100percent",
        "arrow.3.trianglepath", "arrow.down.to.line",
        "rectangle.split.3x3", "square.grid.3x3",
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(icons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                            HapticManager.selectionChanged()
                            dismiss()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedIcon == icon ? Theme.accent : Color(.tertiarySystemFill))
                                    .frame(height: 52)

                                Image(systemName: icon)
                                    .font(.title3)
                                    .foregroundStyle(selectedIcon == icon ? .white : .primary)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

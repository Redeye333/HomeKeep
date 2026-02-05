import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss

    private let icons: [String] = [
        "house", "house.fill", "house.lodge", "building.2",
        "wrench", "wrench.and.screwdriver", "hammer", "screwdriver",
        "drop", "drop.fill", "drop.triangle", "shower",
        "flame", "flame.circle", "sensor", "exclamationmark.triangle",
        "wind", "air.conditioner.horizontal", "fan",
        "sparkles", "bubbles.and.sparkles", "trash",
        "refrigerator", "washer", "dishwasher", "oven",
        "leaf", "tree", "snowflake", "sun.max",
        "ant", "paintbrush", "lightbulb", "bolt",
        "lock", "key", "clock", "calendar",
        "door.garage.closed", "car", "battery.100percent",
        "arrow.3.trianglepath", "arrow.down.to.line",
        "rectangle.split.3x3", "square.grid.3x3",
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                                HapticManager.selectionChanged()
                                dismiss()
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: Theme.iconRadius, style: .continuous)
                                        .fill(selectedIcon == icon
                                            ? LinearGradient(colors: [Theme.primaryPurple, Theme.deepPurple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                            : LinearGradient(colors: [Color(.tertiarySystemFill)], startPoint: .top, endPoint: .bottom))
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
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Theme.primaryPurple)
                }
            }
        }
    }
}

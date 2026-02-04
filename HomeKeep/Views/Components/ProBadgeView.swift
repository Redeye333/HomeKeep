import SwiftUI

struct ProBadgeView: View {
    var body: some View {
        Text("PRO")
            .font(.caption2.weight(.bold))
            .foregroundStyle(.orange)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(.orange.opacity(0.12))
            )
    }
}

struct ProUpsellSheet: View {
    @Bindable var settings: UserSettings
    @Environment(\.dismiss) private var dismiss
    @State private var storeManager = StoreManager.shared
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""

    let feature: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "star.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.orange.gradient)

                VStack(spacing: 8) {
                    Text("HomeKeep Pro")
                        .font(.title2.weight(.bold))

                    Text("\(feature) requires Pro.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Features
                VStack(alignment: .leading, spacing: 12) {
                    proFeatureRow("infinity", "Unlimited tasks")
                    proFeatureRow("widget.small", "Home & Lock Screen widgets")
                    proFeatureRow("paintbrush", "Custom app icons")
                    proFeatureRow("square.and.arrow.up", "Export task history")
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)

                Spacer()

                Button {
                    purchasePro()
                } label: {
                    Group {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Upgrade for \(Theme.proPrice)")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
                .disabled(isPurchasing)
                .padding(.horizontal)

                Button("Restore Purchases") {
                    Task {
                        await storeManager.restorePurchases()
                        if storeManager.isProUnlocked {
                            settings.isProUnlocked = true
                            dismiss()
                        }
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 24)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Purchase Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            .task {
                await storeManager.loadProducts()
            }
        }
    }

    private func proFeatureRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Theme.accent)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }

    private func purchasePro() {
        guard let product = storeManager.products.first else {
            errorMessage = "Product not available. Please try again later."
            showError = true
            return
        }
        isPurchasing = true
        Task {
            do {
                let success = try await storeManager.purchase(product)
                if success {
                    settings.isProUnlocked = true
                    HapticManager.taskCompleted()
                    dismiss()
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isPurchasing = false
        }
    }
}

import SwiftUI

struct ProBadgeView: View {
    var body: some View {
        Text("PRO")
            .font(.caption2.weight(.bold))
            .foregroundStyle(Theme.primaryPurple)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(Theme.primaryPurple.opacity(0.12))
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
            ZStack {
                AppBackgroundView()

                VStack(spacing: Theme.spacing24) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Theme.primaryPurple.opacity(0.2), Theme.deepPurple.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)

                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.primaryPurple, Theme.deepPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                    VStack(spacing: Theme.spacing8) {
                        Text("HomeKeep Pro")
                            .font(Theme.screenTitleFont)
                        Text("\(feature) requires Pro.")
                            .font(Theme.secondaryFont)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    HKCard {
                        VStack(alignment: .leading, spacing: Theme.spacing12) {
                            proFeatureRow("infinity", "Unlimited tasks")
                            proFeatureRow("widget.small", "Home & Lock Screen widgets")
                            proFeatureRow("paintbrush", "Custom app icons")
                            proFeatureRow("square.and.arrow.up", "Export task history")
                        }
                    }
                    .padding(.horizontal, Theme.spacing24)

                    Spacer()

                    VStack(spacing: Theme.spacing12) {
                        HKPrimaryButton(
                            title: "Upgrade for \(Theme.proPrice)",
                            isLoading: isPurchasing
                        ) {
                            purchasePro()
                        }

                        Button("Restore Purchases") {
                            Task {
                                await storeManager.restorePurchases()
                                if storeManager.isProUnlocked {
                                    settings.isProUnlocked = true
                                    dismiss()
                                }
                            }
                        }
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.horizontal, Theme.spacing24)
                    .padding(.bottom, Theme.spacing24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
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
        HStack(spacing: Theme.spacing12) {
            HKIconBadge(icon: icon, color: Theme.primaryPurple, size: 32)
            Text(text)
                .font(Theme.secondaryFont)
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

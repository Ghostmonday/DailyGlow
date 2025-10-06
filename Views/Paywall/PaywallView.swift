//
//  PaywallView.swift
//  DailyGlow
//
//  Premium subscription paywall with StoreKit integration
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var storeManager = StoreManager()
    @State private var selectedPlan: SubscriptionPlan = .monthly
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var animateHeader = false
    
    var isOnboarding: Bool = false
    
    enum SubscriptionPlan: String, CaseIterable {
        case weekly = "weekly"
        case monthly = "monthly"
        case yearly = "yearly"
        case lifetime = "lifetime"
        
        var displayName: String {
            switch self {
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            case .yearly: return "Yearly"
            case .lifetime: return "Lifetime"
            }
        }
        
        var price: String {
            switch self {
            case .weekly: return "$1.99"
            case .monthly: return "$4.99"
            case .yearly: return "$39.99"
            case .lifetime: return "$99.99"
            }
        }
        
        var savings: String? {
            switch self {
            case .weekly: return nil
            case .monthly: return "Most Popular"
            case .yearly: return "Save 33%"
            case .lifetime: return "Best Value"
            }
        }
        
        var period: String {
            switch self {
            case .weekly: return "/week"
            case .monthly: return "/month"
            case .yearly: return "/year"
            case .lifetime: return "one time"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.82, blue: 0.36),
                        Color(red: 0.98, green: 0.65, blue: 0.36),
                        Color(red: 0.98, green: 0.45, blue: 0.36)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Content
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        headerView
                            .padding(.top, 20)
                        
                        // Features
                        featuresView
                        
                        // Subscription plans
                        plansView
                        
                        // CTA button
                        ctaButton
                        
                        // Terms and restore
                        footerView
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !isOnboarding {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }
            }
        }
        .alert("Purchase Failed", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            startAnimations()
            Task {
                await storeManager.loadProducts()
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 20) {
            // Crown icon
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.5), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .scaleEffect(animateHeader ? 1.0 : 0.5)
                    .rotationEffect(.degrees(animateHeader ? 0 : -30))
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateHeader)
            }
            
            VStack(spacing: 12) {
                Text("Unlock Premium")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Transform your daily routine with unlimited affirmations and exclusive features")
                    .font(Typography.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // MARK: - Features View
    private var featuresView: some View {
        VStack(spacing: 12) {
            FeatureRow(icon: "infinity", title: "Unlimited affirmations from 1000+ collection")
            FeatureRow(icon: "moon.stars.fill", title: "Bedtime stories with positive affirmations")
            FeatureRow(icon: "paintbrush.fill", title: "Exclusive themes and customization")
            FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Advanced mood tracking & analytics")
            FeatureRow(icon: "square.grid.3x3.fill", title: "Beautiful home screen widgets")
            FeatureRow(icon: "sparkles", title: "AI-powered personalized affirmations")
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Plans View
    private var plansView: some View {
        VStack(spacing: 12) {
            Text("Choose Your Plan")
                .font(Typography.h3)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            ForEach(SubscriptionPlan.allCases, id: \.self) { plan in
                PlanCard(
                    plan: plan,
                    isSelected: selectedPlan == plan,
                    action: {
                        withAnimation(.spring(response: 0.3)) {
                            selectedPlan = plan
                        }
                        HapticManager.shared.selection()
                    }
                )
            }
        }
    }
    
    // MARK: - CTA Button
    private var ctaButton: some View {
        Button {
            startPurchase()
        } label: {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.95)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .white.opacity(0.5), radius: 20, y: 10)
                
                // Content
                if isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                        .scaleEffect(1.2)
                } else {
                    VStack(spacing: 4) {
                        Text(selectedPlan == .weekly ? "Start 3-Day Free Trial" : "Subscribe Now")
                            .font(Typography.body)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        if selectedPlan == .weekly {
                            Text("then \(selectedPlan.price)\(selectedPlan.period)")
                                .font(Typography.small)
                                .foregroundColor(.black.opacity(0.6))
                        }
                    }
                }
            }
            .frame(height: 60)
        }
        .disabled(isPurchasing)
    }
    
    // MARK: - Footer View
    private var footerView: some View {
        VStack(spacing: 16) {
            // Restore purchases
            Button {
                restorePurchases()
            } label: {
                Text("Restore Purchases")
                    .font(Typography.small)
                    .foregroundColor(.white.opacity(0.8))
                    .underline()
            }
            
            // Terms
            HStack(spacing: 20) {
                Button {
                    openURL("https://dailyglow.app/privacy")
                } label: {
                    Text("Privacy Policy")
                        .font(Typography.tiny)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Button {
                    openURL("https://dailyglow.app/terms")
                } label: {
                    Text("Terms of Service")
                        .font(Typography.tiny)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Auto-renewal notice
            Text("Subscriptions auto-renew unless cancelled 24 hours before the end of the current period. Manage in Settings.")
                .font(Typography.tiny)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Helper Methods
    private func startAnimations() {
        withAnimation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.2)) {
            animateHeader = true
        }
    }
    
    private func startPurchase() {
        isPurchasing = true
        HapticManager.shared.impact(.medium)
        
        Task {
            do {
                // await storeManager.purchase(selectedPlan)
                // For now, simulate success
                try await Task.sleep(nanoseconds: 2_000_000_000)
                
                await MainActor.run {
                    isPurchasing = false
                    HapticManager.shared.notification(.success)
                    StorageManager.shared.updatePremiumStatus(isPremium: true)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    errorMessage = error.localizedDescription
                    showError = true
                    HapticManager.shared.notification(.error)
                }
            }
        }
    }
    
    private func restorePurchases() {
        Task {
            do {
                try await AppStore.sync()
                HapticManager.shared.notification(.success)
                // Check if any purchases were restored
                // If yes, dismiss the paywall
            } catch {
                errorMessage = "Failed to restore purchases"
                showError = true
                HapticManager.shared.notification(.error)
            }
        }
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Supporting Views
struct FeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 30)
            
            Text(title)
                .font(Typography.small)
                .foregroundColor(.white.opacity(0.95))
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

struct PlanCard: View {
    let plan: PaywallView.SubscriptionPlan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Radio button
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(.white)
                
                // Plan details
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.displayName)
                        .font(Typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("\(plan.price)\(plan.period)")
                        .font(Typography.small)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Badge
                if let savings = plan.savings {
                    Text(savings)
                        .font(Typography.tiny)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.white : Color.white.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
    }
}

// MARK: - StoreKit Manager (Placeholder)
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProducts: Set<String> = []
    
    func loadProducts() async {
        // Implement StoreKit product loading
    }
    
    func purchase(_ plan: PaywallView.SubscriptionPlan) async throws {
        // Implement StoreKit purchase
    }
}

// MARK: - Preview
#Preview {
    PaywallView()
}

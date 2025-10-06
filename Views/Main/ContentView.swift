//
//  ContentView.swift
//  DailyGlow
//
//  Main navigation container with tab view for the app
//

import SwiftUI

struct ContentView: View {
    // MARK: - State
    @State private var selectedTab: Tab = .today
    @State private var showingPaywall = false
    @State private var tabBarHeight: CGFloat = 0
    @StateObject private var affirmationService = AffirmationService()
    @StateObject private var storageManager = StorageManager.shared
    @StateObject private var hapticManager = HapticManager.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isPremium") private var isPremium = false
    
    // MARK: - Tab Enum
    enum Tab: String, CaseIterable {
        case today = "Today"
        case favorites = "Favorites"
        case journal = "Journal"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .today: return "sun.max.fill"
            case .favorites: return "heart.fill"
            case .journal: return "book.fill"
            case .settings: return "gearshape.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .today: return Color.yellow
            case .favorites: return Color.pink
            case .journal: return Color.purple
            case .settings: return Color.blue
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            backgroundGradient
                .ignoresSafeArea()
            
            // Main content
            TabView(selection: $selectedTab) {
                TodayTab()
                    .tag(Tab.today)
                    .environmentObject(affirmationService)
                
                FavoritesTab()
                    .tag(Tab.favorites)
                    .environmentObject(affirmationService)
                
                JournalTab()
                    .tag(Tab.journal)
                    .environmentObject(storageManager)
                
                SettingsTab()
                    .tag(Tab.settings)
                    .environmentObject(storageManager)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.bottom, tabBarHeight)
            
            // Custom tab bar
            customTabBar
                .background(
                    GeometryReader { geometry in
                        Color.clear.onAppear {
                            tabBarHeight = geometry.size.height
                        }
                    }
                )
        }
        .preferredColorScheme({
            switch storageManager.userPreferences.preferredColorScheme {
            case "dark": return .dark
            case "light": return .light
            default: return nil
            }
        }())
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .onAppear {
            setupAppearance()
            checkPremiumStatus()
        }
        .onChange(of: selectedTab) { _, newTab in
            HapticManager.shared.playTabSelection()
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: GradientTheme.morning.randomElement() ?? GradientTheme.morning[0],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated overlay
            if storageManager.userPreferences.animatedBackgrounds {
                AnimatedBackground(
                    style: .floatingBubbles,
                    primaryColor: selectedTab.color.opacity(0.3),
                    secondaryColor: selectedTab.color.opacity(0.1)
                )
            }
        }
    }
    
    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabButton(for: tab)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private func tabButton(for tab: Tab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(selectedTab == tab ? tab.color : Color.textSecondary)
                    .scaleEffect(selectedTab == tab ? 1.15 : 1.0)
                    .animation(.spring(response: 0.3), value: selectedTab)
                
                Text(tab.rawValue)
                    .font(Typography.tiny)
                    .foregroundColor(selectedTab == tab ? tab.color : Color.textSecondary)
                    .opacity(selectedTab == tab ? 1.0 : 0.7)
            }
            .frame(height: 50)
        }
    }
    
    // MARK: - Helper Methods
    private func setupAppearance() {
        // Configure tab bar appearance
        UITabBar.appearance().isHidden = true
    }
    
    private func checkPremiumStatus() {
        if !isPremium {
            // Check if user has viewed enough content to show paywall
            let viewCount = UserDefaults.standard.integer(forKey: "totalAffirmationsViewed")
            if viewCount > 5 && viewCount % 10 == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showingPaywall = true
                }
            }
        }
    }
}

// MARK: - Onboarding Wrapper
struct ContentViewWrapper: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showingOnboarding = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingContainer()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: hasCompletedOnboarding)
    }
}

// MARK: - Preview
#Preview {
    ContentViewWrapper()
}
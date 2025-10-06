//
//  OnboardingContainer.swift
//  DailyGlow
//
//  Main container for the onboarding flow with page navigation
//

import SwiftUI

struct OnboardingContainer: View {
    // MARK: - State
    @State private var currentPage: OnboardingPage = .welcome
    @State private var userName: String = ""
    @State private var selectedMood: Mood = .calm
    @State private var selectedCategories: Set<Category> = []
    @State private var notificationsEnabled: Bool = false
    @State private var reminderTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var showingPaywall = false
    @State private var isAnimating = false
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var hapticManager = HapticManager.shared
    @StateObject private var storageManager = StorageManager.shared
    
    // MARK: - Onboarding Pages
    enum OnboardingPage: Int, CaseIterable {
        case welcome = 0
        case benefits
        case name
        case mood
        case categories
        case notifications
        case premium
        case complete
        
        var progress: Double {
            Double(self.rawValue + 1) / Double(OnboardingPage.allCases.count)
        }
        
        var canSkip: Bool {
            switch self {
            case .name, .notifications, .premium:
                return true
            default:
                return false
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background gradient that changes with page
            backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.0), value: currentPage)
            
            // Animated background elements
            if currentPage == .welcome || currentPage == .complete {
                AnimatedBackground(
                    style: .floatingOrbs,
                    primaryColor: Color.white.opacity(0.1),
                    secondaryColor: Color.white.opacity(0.05)
                )
                .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // Progress bar
                if currentPage != .welcome && currentPage != .complete {
                    progressBar
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                }
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(OnboardingPage.allCases, id: \.self) { page in
                        pageContent(for: page)
                            .tag(page)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Navigation buttons
                if currentPage != .complete {
                    navigationButtons
                        .padding(.horizontal, 30)
                        .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(isOnboarding: true)
        }
        .onAppear {
            startAnimation()
        }
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        LinearGradient(
            colors: gradientColors(for: currentPage),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func gradientColors(for page: OnboardingPage) -> [Color] {
        switch page {
        case .welcome:
            return GradientTheme.getGradient(for: .sunrise)
        case .benefits:
            return GradientTheme.getGradient(for: .morning)
        case .name:
            return GradientTheme.getGradient(for: .daylight)
        case .mood:
            return GradientTheme.getGradient(for: selectedMood.timeOfDay)
        case .categories:
            return GradientTheme.getGradient(for: .afternoon)
        case .notifications:
            return GradientTheme.getGradient(for: .evening)
        case .premium:
            return [Color.yellow.opacity(0.8), Color.orange.opacity(0.9)]
        case .complete:
            return GradientTheme.getGradient(for: .night)
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 6)
                
                // Progress
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * currentPage.progress, height: 6)
                    .animation(.spring(response: 0.5), value: currentPage)
            }
        }
        .frame(height: 6)
    }
    
    // MARK: - Page Content
    @ViewBuilder
    private func pageContent(for page: OnboardingPage) -> some View {
        switch page {
        case .welcome:
            WelcomeView(isAnimating: $isAnimating)
        case .benefits:
            BenefitsView()
        case .name:
            NameInputView(userName: $userName)
        case .mood:
            MoodSelectorView(selectedMood: $selectedMood)
        case .categories:
            CategoryPickerView(selectedCategories: $selectedCategories)
        case .notifications:
            NotificationSetupView(
                notificationsEnabled: $notificationsEnabled,
                reminderTime: $reminderTime
            )
        case .premium:
            PremiumPitchView(showingPaywall: $showingPaywall)
        case .complete:
            CompleteView(userName: userName) {
                completeOnboarding()
            }
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Back button
            if currentPage != .welcome {
                Button {
                    previousPage()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                        )
                }
            }
            
            Spacer()
            
            // Skip button
            if currentPage.canSkip {
                Button {
                    nextPage()
                } label: {
                    Text("Skip")
                        .font(Typography.body)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Next/Continue button
            CustomButton(
                title: currentPage == .premium ? "Maybe Later" :
                       currentPage == OnboardingPage.allCases[OnboardingPage.allCases.count - 2] ? "Finish" : "Continue",
                style: .primary,
                icon: "arrow.right"
            ) {
                if currentPage == .categories && selectedCategories.isEmpty {
                    // Must select at least one category
                    HapticManager.shared.notification(.warning)
                } else {
                    nextPage()
                }
            }
            .frame(maxWidth: currentPage == .welcome ? .infinity : 160)
        }
    }
    
    // MARK: - Navigation Methods
    private func nextPage() {
        HapticManager.shared.playOnboardingProgress()
        
        if let nextIndex = OnboardingPage.allCases.firstIndex(of: currentPage)?.advanced(by: 1),
           nextIndex < OnboardingPage.allCases.count {
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPage = OnboardingPage.allCases[nextIndex]
            }
        }
    }
    
    private func previousPage() {
        HapticManager.shared.impact(.light)
        
        if let prevIndex = OnboardingPage.allCases.firstIndex(of: currentPage)?.advanced(by: -1),
           prevIndex >= 0 {
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPage = OnboardingPage.allCases[prevIndex]
            }
        }
    }
    
    private func startAnimation() {
        withAnimation(.easeIn(duration: 1.0)) {
            isAnimating = true
        }
    }
    
    private func completeOnboarding() {
        // Save user preferences
        storageManager.userPreferences.userName = userName
        storageManager.userPreferences.selectedCategories = Array(selectedCategories)
        storageManager.userPreferences.currentMood = selectedMood
        storageManager.userPreferences.hasCompletedOnboarding = true
        storageManager.saveUserPreferences()
        
        // Save to UserDefaults
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(selectedCategories.map { $0.rawValue }, forKey: "selectedCategories")
        UserDefaults.standard.set(selectedMood.rawValue, forKey: "currentMood")
        
        // Setup notifications if enabled
        if notificationsEnabled {
            requestNotificationPermission()
        }
        
        // Mark onboarding as complete
        HapticManager.shared.notification(.success)
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    self.scheduleNotifications()
                }
            }
        }
    }
    
    private func scheduleNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Affirmation"
        content.body = "Your daily dose of positivity awaits! 🌟"
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Mood Extension
extension Mood {
    var timeOfDay: TimeOfDay {
        switch self {
        case .energized: return .morning
        case .calm: return .evening
        case .focused: return .daylight
        case .peaceful: return .night
        case .motivated: return .afternoon
        case .grateful: return .sunset
        case .happy: return .daylight
        case .confident: return .afternoon
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingContainer()
}
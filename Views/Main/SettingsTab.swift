//
//  SettingsTab.swift
//  DailyGlow
//
//  Tab for app settings, preferences, and account management
//

import SwiftUI
import StoreKit

struct SettingsTab: View {
    // MARK: - Environment
    @EnvironmentObject var storageManager: StorageManager
    @StateObject private var hapticManager = HapticManager.shared
    @StateObject private var affirmationService = AffirmationService()
    
    // MARK: - State
    @State private var showingPaywall = false
    @State private var showingNotificationSettings = false
    @State private var showingAbout = false
    @State private var showingSupport = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTerms = false
    @State private var showingResetConfirmation = false
    @State private var showingExportData = false
    @State private var showingRestorePurchases = false
    @State private var showingShareApp = false
    @State private var notificationTime = Date()
    @State private var isPremiumUser = false
    
    // User preferences
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("animatedBackgrounds") private var animatedBackgrounds: Bool = true
    @AppStorage("preferredColorScheme") private var preferredColorScheme: String = "system"
    @State private var dailyReminderTime = Date()
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("autoPlayAffirmations") private var autoPlayAffirmations: Bool = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: GradientTheme.getGradient(for: .night),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile section
                        profileSection
                        
                        // Premium section
                        if !storageManager.isPremium {
                            premiumSection
                        }
                        
                        // Settings sections
                        notificationSection
                        appearanceSection
                        experienceSection
                        dataSection
                        supportSection
                        aboutSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView(
                notificationsEnabled: $notificationsEnabled,
                reminderTime: $dailyReminderTime
            )
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingSupport) {
            SupportView()
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            WebView(url: URL(string: "https://dailyglow.app/privacy")!)
        }
        .sheet(isPresented: $showingTerms) {
            WebView(url: URL(string: "https://dailyglow.app/terms")!)
        }
        .sheet(isPresented: $showingExportData) {
            ExportDataView()
                .environmentObject(storageManager)
        }
        .sheet(isPresented: $showingShareApp) {
            ShareSheet(items: [
                "Check out Daily Glow - Beautiful affirmations for your daily mindfulness practice! 🌟",
                URL(string: "https://apps.apple.com/app/daily-glow")!
            ])
        }
        .confirmationDialog("Reset All Data?", isPresented: $showingResetConfirmation, titleVisibility: .visible) {
            Button("Reset Everything", role: .destructive) {
                resetAllData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete all your favorites, journal entries, and preferences. This action cannot be undone.")
        }
        .onAppear {
            checkPremiumStatus()
        }
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        VStack(spacing: 16) {
            // Profile header
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Text(userName.isEmpty ? "?" : String(userName.prefix(1)).uppercased())
                        .font(Typography.h2)
                        .foregroundColor(.white)
                }
                
                // User info
                VStack(alignment: .leading, spacing: 4) {
                    Text(userName.isEmpty ? "Welcome" : userName)
                        .font(Typography.h3)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        // Streak
                        Label("\(affirmationService.streakCount) day streak", systemImage: "flame.fill")
                            .font(Typography.small)
                            .foregroundColor(.orange)
                        
                        if storageManager.isPremium {
                            // Premium badge
                            Label("PRO", systemImage: "crown.fill")
                                .font(Typography.tiny)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.yellow.opacity(0.2))
                                )
                        }
                    }
                }
                
                Spacer()
                
                // Edit button
                Button {
                    // Show edit profile
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            
            // Stats
            HStack(spacing: 12) {
                StatItem(
                    value: "\(affirmationService.totalAffirmationsViewed)",
                    label: "Affirmations",
                    icon: "sparkles"
                )
                
                StatItem(
                    value: "\(affirmationService.favoriteAffirmations.count)",
                    label: "Favorites",
                    icon: "heart.fill"
                )
                
                StatItem(
                    value: "\(storageManager.journalEntries.count)",
                    label: "Journal",
                    icon: "book.fill"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Premium Section
    private var premiumSection: some View {
        Button {
            showingPaywall = true
            HapticManager.shared.impact(.medium)
        } label: {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: "crown.fill")
                    .font(.title)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlock Premium")
                        .font(Typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Unlimited affirmations, themes & more")
                        .font(Typography.small)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.yellow.opacity(0.3),
                                Color.orange.opacity(0.2)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.yellow.opacity(0.5), .orange.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
    
    // MARK: - Notification Section
    private var notificationSection: some View {
        SettingsSection(title: "Notifications", icon: "bell.fill", color: .blue) {
            // Daily reminder
            SettingsRow(
                title: "Daily Reminder",
                icon: "alarm",
                color: .orange
            ) {
                Toggle("", isOn: $notificationsEnabled)
                    .tint(.orange)
                    .onChange(of: notificationsEnabled) { _, enabled in
                        if enabled {
                            requestNotificationPermission()
                        }
                    }
            }
            
            // Reminder time
            if notificationsEnabled {
                SettingsRow(
                    title: "Reminder Time",
                    icon: "clock",
                    color: .blue
                ) {
                    DatePicker("", selection: $dailyReminderTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .tint(.blue)
                }
            }
            
            // Notification settings
            SettingsRow(
                title: "Notification Settings",
                icon: "gear",
                color: .gray,
                action: {
                    showingNotificationSettings = true
                }
            )
        }
    }
    
    // MARK: - Appearance Section
    private var appearanceSection: some View {
        SettingsSection(title: "Appearance", icon: "paintbrush.fill", color: .purple) {
            // Color scheme
            SettingsRow(
                title: "App Theme",
                icon: "moon.circle",
                color: .indigo
            ) {
                Menu {
                    Button("System") {
                        preferredColorScheme = "system"
                    }
                    Button("Light") {
                        preferredColorScheme = "light"
                    }
                    Button("Dark") {
                        preferredColorScheme = "dark"
                    }
                } label: {
                    HStack {
                        Text(preferredColorScheme.capitalized)
                            .font(Typography.small)
                            .foregroundColor(.white.opacity(0.6))
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }
            
            // Animated backgrounds
            SettingsRow(
                title: "Animated Backgrounds",
                icon: "sparkles",
                color: .pink
            ) {
                Toggle("", isOn: $animatedBackgrounds)
                    .tint(.pink)
                    .onChange(of: animatedBackgrounds) { _, _ in
                        storageManager.userPreferences.animatedBackgrounds = animatedBackgrounds
                        storageManager.saveUserPreferences()
                    }
            }
        }
    }
    
    // MARK: - Experience Section
    private var experienceSection: some View {
        SettingsSection(title: "Experience", icon: "wand.and.rays", color: .green) {
            // Haptics
            SettingsRow(
                title: "Haptic Feedback",
                icon: "hand.tap",
                color: .green
            ) {
                Toggle("", isOn: $hapticsEnabled)
                    .tint(.green)
                    .onChange(of: hapticsEnabled) { _, enabled in
                        if enabled {
                            HapticManager.shared.impact(.medium)
                        }
                    }
            }
            
            // Sounds
            SettingsRow(
                title: "Sound Effects",
                icon: "speaker.wave.2",
                color: .cyan
            ) {
                Toggle("", isOn: $soundEnabled)
                    .tint(.cyan)
            }
            
            // Auto-play
            SettingsRow(
                title: "Auto-play Affirmations",
                icon: "play.circle",
                color: .red
            ) {
                Toggle("", isOn: $autoPlayAffirmations)
                    .tint(.red)
            }
        }
    }
    
    // MARK: - Data Section
    private var dataSection: some View {
        SettingsSection(title: "Data & Privacy", icon: "lock.fill", color: .mint) {
            // Export data
            SettingsRow(
                title: "Export My Data",
                icon: "square.and.arrow.up",
                color: .blue,
                action: {
                    showingExportData = true
                }
            )
            
            // Backup
            SettingsRow(
                title: "Create Backup",
                icon: "icloud.and.arrow.up",
                color: .green,
                action: {
                    createBackup()
                }
            )
            
            // Reset data
            SettingsRow(
                title: "Reset All Data",
                icon: "trash",
                color: .red,
                action: {
                    showingResetConfirmation = true
                }
            )
        }
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        SettingsSection(title: "Support", icon: "questionmark.circle.fill", color: .orange) {
            // Help center
            SettingsRow(
                title: "Help Center",
                icon: "lifepreserver",
                color: .blue,
                action: {
                    showingSupport = true
                }
            )
            
            // Contact us
            SettingsRow(
                title: "Contact Us",
                icon: "envelope",
                color: .green,
                action: {
                    openMail()
                }
            )
            
            // Rate app
            SettingsRow(
                title: "Rate Daily Glow",
                icon: "star",
                color: .yellow,
                action: {
                    requestReview()
                }
            )
            
            // Share app
            SettingsRow(
                title: "Share App",
                icon: "square.and.arrow.up",
                color: .purple,
                action: {
                    showingShareApp = true
                }
            )
            
            // Restore purchases
            if !storageManager.isPremium {
                SettingsRow(
                    title: "Restore Purchases",
                    icon: "arrow.clockwise",
                    color: .mint,
                    action: {
                        restorePurchases()
                    }
                )
            }
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        SettingsSection(title: "About", icon: "info.circle.fill", color: .gray) {
            // Version
            SettingsRow(
                title: "Version",
                icon: "app.badge",
                color: .blue
            ) {
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .font(Typography.small)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Privacy policy
            SettingsRow(
                title: "Privacy Policy",
                icon: "hand.raised",
                color: .purple,
                action: {
                    showingPrivacyPolicy = true
                }
            )
            
            // Terms of service
            SettingsRow(
                title: "Terms of Service",
                icon: "doc.text",
                color: .orange,
                action: {
                    showingTerms = true
                }
            )
        }
    }
    
    // MARK: - Helper Methods
    private func checkPremiumStatus() {
        isPremiumUser = storageManager.isPremium
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                notificationsEnabled = granted
                if granted {
                    scheduleNotifications()
                }
            }
        }
    }
    
    private func scheduleNotifications() {
        // Schedule daily reminder
        let content = UNMutableNotificationContent()
        content.title = "Daily Affirmation"
        content.body = "Your daily dose of positivity awaits! 🌟"
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: dailyReminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func createBackup() {
        if let backupURL = storageManager.createBackup() {
            HapticManager.shared.notification(.success)
            // Show share sheet or success message
        }
    }
    
    private func restorePurchases() {
        showingRestorePurchases = true
        // Implement StoreKit restore
        Task {
            do {
                try await AppStore.sync()
                HapticManager.shared.notification(.success)
            } catch {
                HapticManager.shared.notification(.error)
            }
        }
    }
    
    private func resetAllData() {
        storageManager.resetAllData()
        affirmationService.resetAllData()
        HapticManager.shared.notification(.warning)
    }
    
    private func openMail() {
        if let url = URL(string: "mailto:support@dailyglow.app") {
            UIApplication.shared.open(url)
        }
    }
    
    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                
                Text(title)
                    .font(Typography.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .textCase(.uppercase)
            }
            .padding(.horizontal, 4)
            
            // Content
            VStack(spacing: 2) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        }
    }
}

// MARK: - Settings Row
struct SettingsRow<Accessory: View>: View {
    let title: String
    let icon: String
    let color: Color
    var action: (() -> Void)? = nil
    @ViewBuilder var accessory: () -> Accessory
    
    init(
        title: String,
        icon: String,
        color: Color,
        action: (() -> Void)? = nil,
        @ViewBuilder accessory: @escaping () -> Accessory = { EmptyView() }
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
        self.accessory = accessory
    }
    
    init(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) where Accessory == AnyView {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
        self.accessory = {
            AnyView(
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
            )
        }
    }
    
    var body: some View {
        Button {
            action?()
            if action != nil {
                HapticManager.shared.impact(.light)
            }
        } label: {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(color)
                    .frame(width: 28)
                
                // Title
                Text(title)
                    .font(Typography.body)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Accessory
                accessory()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .disabled(action == nil)
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            Text(value)
                .font(Typography.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(label)
                .font(Typography.tiny)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Supporting Views
struct NotificationSettingsView: View {
    @Binding var notificationsEnabled: Bool
    @Binding var reminderTime: Date
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Notification settings")
                    .font(Typography.h2)
                    .foregroundColor(.white)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: GradientTheme.getGradient(for: .morning),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.top, 40)
                    
                    Text("Daily Glow")
                        .font(Typography.h1)
                        .foregroundColor(.white)
                    
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                        .font(Typography.small)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Daily Glow is your companion for positive affirmations, mindfulness, and personal growth. Start each day with intention and end it with gratitude.")
                        .font(Typography.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer(minLength: 40)
                    
                    Text("Made with ❤️ in SwiftUI")
                        .font(Typography.small)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: GradientTheme.getGradient(for: .night),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct SupportView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Support content")
                    .font(Typography.h2)
                    .foregroundColor(.white)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: GradientTheme.getGradient(for: .morning),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ExportDataView: View {
    @EnvironmentObject var storageManager: StorageManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Export your data")
                    .font(Typography.h2)
                    .foregroundColor(.white)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: GradientTheme.getGradient(for: .morning),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct WebView: View {
    let url: URL
    
    var body: some View {
        // Placeholder - would use WKWebView in real implementation
        VStack {
            Text("Web content")
                .font(Typography.h2)
                .foregroundColor(.white)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary)
    }
}

// MARK: - Preview
#Preview {
    SettingsTab()
        .environmentObject(StorageManager.shared)
}

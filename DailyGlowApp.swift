//
//  DailyGlowApp.swift
//  DailyGlow
//
//  Main app entry point with comprehensive configuration
//

import SwiftUI
import UserNotifications

@main
struct DailyGlowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var storageManager = StorageManager.shared
    @StateObject private var affirmationService = AffirmationService()
    @StateObject private var hapticManager = HapticManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentViewWrapper()
                .environmentObject(storageManager)
                .environmentObject(affirmationService)
                .environmentObject(hapticManager)
                .preferredColorScheme(getPreferredColorScheme())
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func getPreferredColorScheme() -> ColorScheme? {
        let scheme = storageManager.userPreferences.preferredColorScheme
        switch scheme {
        case "dark": return .dark
        case "light": return .light
        default: return nil
        }
    }
    
    private func setupApp() {
        // Request notification permissions if needed
        if UserDefaults.standard.bool(forKey: "notificationsEnabled") {
            requestNotificationPermission()
        }
        
        // Setup appearance
        setupAppearance()
        
        // Track app open
        storageManager.trackEvent(.appOpened)
        
        // Setup app shortcuts
        setupAppShortcuts()
    }
    
    private func setupAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure tab bar (hidden as we use custom)
        UITabBar.appearance().isHidden = true
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
        // Daily reminder
        let content = UNMutableNotificationContent()
        content.title = "Daily Affirmation"
        content.body = "Your daily dose of positivity awaits! 🌟"
        content.sound = .default
        content.categoryIdentifier = "DAILY_AFFIRMATION"
        
        var dateComponents = DateComponents()
        dateComponents.hour = UserDefaults.standard.object(forKey: "dailyReminderHour") as? Int ?? 9
        dateComponents.minute = UserDefaults.standard.object(forKey: "dailyReminderMinute") as? Int ?? 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func setupAppShortcuts() {
        let shortcuts = [
            UIApplicationShortcutItem(
                type: "com.dailyglow.newaffirmation",
                localizedTitle: "New Affirmation",
                localizedSubtitle: "Get your daily inspiration",
                icon: UIApplicationShortcutIcon(systemImageName: "sparkles"),
                userInfo: nil
            ),
            UIApplicationShortcutItem(
                type: "com.dailyglow.journal",
                localizedTitle: "Journal",
                localizedSubtitle: "Write your thoughts",
                icon: UIApplicationShortcutIcon(systemImageName: "book.fill"),
                userInfo: nil
            ),
            UIApplicationShortcutItem(
                type: "com.dailyglow.favorites",
                localizedTitle: "Favorites",
                localizedSubtitle: "View saved affirmations",
                icon: UIApplicationShortcutIcon(systemImageName: "heart.fill"),
                userInfo: nil
            )
        ]
        
        UIApplication.shared.shortcutItems = shortcuts
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Setup notification categories
        setupNotificationCategories()
        
        // Configure any third-party SDKs here
        setupAnalytics()
        setupCrashReporting()
        
        // Check if launched from notification
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            handleNotification(notification)
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Reset badge when app becomes active
        application.applicationIconBadgeNumber = 0
        
        // Refresh data if needed
        StorageManager.shared.trackEvent(.appOpened)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Save any pending data
        StorageManager.shared.saveUserPreferences()
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
    
    // MARK: - Notification Handling
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        handleNotificationResponse(response)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    private func setupNotificationCategories() {
        let viewAction = UNNotificationAction(
            identifier: "VIEW_ACTION",
            title: "View",
            options: [.foreground]
        )
        
        let shareAction = UNNotificationAction(
            identifier: "SHARE_ACTION",
            title: "Share",
            options: [.foreground]
        )
        
        let category = UNNotificationCategory(
            identifier: "DAILY_AFFIRMATION",
            actions: [viewAction, shareAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    private func handleNotificationResponse(_ response: UNNotificationResponse) {
        switch response.actionIdentifier {
        case "VIEW_ACTION":
            NotificationCenter.default.post(name: Notification.Name("NavigateToToday"), object: nil)
        case "SHARE_ACTION":
            NotificationCenter.default.post(name: Notification.Name("ShareAffirmation"), object: nil)
        default:
            break
        }
    }
    
    private func handleNotification(_ notification: [String: AnyObject]) {
        // Handle notification data
    }
    
    private func setupAnalytics() {
        // Setup analytics SDK (Firebase, Mixpanel, etc.)
    }
    
    private func setupCrashReporting() {
        // Setup crash reporting (Crashlytics, Sentry, etc.)
    }
}

// MARK: - Scene Delegate
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Handle any deep links or shortcuts
        handleShortcuts(connectionOptions.shortcutItem)
        handleUserActivity(connectionOptions.userActivities.first)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // Handle URL schemes
        for context in URLContexts {
            handleDeepLink(context.url)
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        handleUserActivity(userActivity)
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handled = handleShortcuts(shortcutItem)
        completionHandler(handled)
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Refresh any UI that needs updating
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Save any pending changes
    }
    
    private func handleShortcuts(_ shortcutItem: UIApplicationShortcutItem?) -> Bool {
        guard let shortcutItem = shortcutItem else { return false }
        
        switch shortcutItem.type {
        case "com.dailyglow.newaffirmation":
            // Navigate to today tab
            NotificationCenter.default.post(name: Notification.Name("NavigateToToday"), object: nil)
            return true
        case "com.dailyglow.journal":
            // Navigate to journal tab
            NotificationCenter.default.post(name: Notification.Name("NavigateToJournal"), object: nil)
            return true
        case "com.dailyglow.favorites":
            // Navigate to favorites tab
            NotificationCenter.default.post(name: Notification.Name("NavigateToFavorites"), object: nil)
            return true
        default:
            return false
        }
    }
    
    private func handleUserActivity(_ userActivity: NSUserActivity?) {
        guard let userActivity = userActivity else { return }
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            handleDeepLink(url)
        } else if userActivity.activityType == "com.dailyglow.viewAffirmation" {
            // Handle Siri shortcut or handoff
            if let affirmationId = userActivity.userInfo?["affirmationId"] as? String {
                NotificationCenter.default.post(
                    name: Notification.Name("ViewAffirmation"),
                    object: nil,
                    userInfo: ["id": affirmationId]
                )
            }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        // Handle deep links
        // Example: dailyglow://affirmation/123
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        
        switch components.host {
        case "affirmation":
            // Navigate to specific affirmation
            if let path = components.path.split(separator: "/").last {
                NotificationCenter.default.post(
                    name: Notification.Name("ViewAffirmation"),
                    object: nil,
                    userInfo: ["id": String(path)]
                )
            }
        case "journal":
            // Navigate to journal
            NotificationCenter.default.post(name: Notification.Name("NavigateToJournal"), object: nil)
        case "premium":
            // Show paywall
            NotificationCenter.default.post(name: Notification.Name("ShowPaywall"), object: nil)
        case "share":
            // Share app
            NotificationCenter.default.post(name: Notification.Name("ShareApp"), object: nil)
        default:
            break
        }
    }
}
//
//  StorageManager.swift
//  DailyGlow
//
//  Manages all data persistence including UserDefaults, file storage,
//  and cache management for the app.
//

import SwiftUI
import Combine

@MainActor
class StorageManager: ObservableObject {
    // MARK: - Singleton
    static let shared = StorageManager()
    
    // MARK: - Published Properties
    @Published var userPreferences: UserPreferences
    @Published var journalEntries: [JournalEntry] = []
    @Published var customAffirmations: [Affirmation] = []
    @Published var analyticsData: AnalyticsData
    @Published var isPremium: Bool = false
    
    // MARK: - Storage Keys
    private enum StorageKey {
        static let userPreferences = "userPreferences"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let userName = "userName"
        static let selectedCategories = "selectedCategories"
        static let currentMood = "currentMood"
        static let notificationTime = "notificationTime"
        static let journalEntries = "journalEntries"
        static let customAffirmations = "customAffirmations"
        static let analyticsData = "analyticsData"
        static let isPremium = "isPremium"
        static let premiumExpirationDate = "premiumExpirationDate"
        static let firstLaunchDate = "firstLaunchDate"
        static let appVersion = "appVersion"
        static let lastBackupDate = "lastBackupDate"
    }
    
    // MARK: - File Management
    private let documentsDirectory: URL
    private let cachesDirectory: URL
    private let appGroupDirectory: URL?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - UserDefaults
    private let userDefaults = UserDefaults.standard
    private let appGroupDefaults: UserDefaults?
    
    // MARK: - Initialization
    private init() {
        // Setup directories
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        // App Group for widget data sharing
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dailyglow") {
            appGroupDirectory = appGroupURL
            appGroupDefaults = UserDefaults(suiteName: "group.dailyglow")
        } else {
            appGroupDirectory = nil
            appGroupDefaults = nil
        }
        
        // Load initial data
        userPreferences = UserPreferences()
        analyticsData = AnalyticsData()
        
        // Load persisted data
        loadAllData()
        
        // Setup first launch if needed
        setupFirstLaunch()
        
        // Setup auto-save
        setupAutoSave()
    }
    
    // MARK: - Data Loading
    private func loadAllData() {
        loadUserPreferences()
        loadJournalEntries()
        loadCustomAffirmations()
        loadAnalyticsData()
        loadPremiumStatus()
    }
    
    func loadUserPreferences() {
        if let data = userDefaults.data(forKey: StorageKey.userPreferences),
           let preferences = try? decoder.decode(UserPreferences.self, from: data) {
            userPreferences = preferences
        } else {
            // Load individual preferences for backward compatibility
            userPreferences.userName = userDefaults.string(forKey: StorageKey.userName) ?? ""
            userPreferences.hasCompletedOnboarding = userDefaults.bool(forKey: StorageKey.hasCompletedOnboarding)
            
            if let categoriesData = userDefaults.array(forKey: StorageKey.selectedCategories) as? [String] {
                userPreferences.selectedCategories = Set(categoriesData.compactMap { Category(rawValue: $0) })
            }
            
            if let moodString = userDefaults.string(forKey: StorageKey.currentMood),
               let mood = Mood(rawValue: moodString) {
                userPreferences.currentMood = mood
            }
        }
    }
    
    func loadJournalEntries() {
        let journalURL = documentsDirectory.appendingPathComponent("journal.json")
        
        if FileManager.default.fileExists(atPath: journalURL.path),
           let data = try? Data(contentsOf: journalURL),
           let entries = try? decoder.decode([JournalEntry].self, from: data) {
            journalEntries = entries
        }
    }
    
    func loadCustomAffirmations() {
        let customURL = documentsDirectory.appendingPathComponent("custom_affirmations.json")
        
        if FileManager.default.fileExists(atPath: customURL.path),
           let data = try? Data(contentsOf: customURL),
           let affirmations = try? decoder.decode([Affirmation].self, from: data) {
            customAffirmations = affirmations
        }
    }
    
    func loadAnalyticsData() {
        if let data = userDefaults.data(forKey: StorageKey.analyticsData),
           let analytics = try? decoder.decode(AnalyticsData.self, from: data) {
            analyticsData = analytics
        }
    }
    
    func loadPremiumStatus() {
        isPremium = userDefaults.bool(forKey: StorageKey.isPremium)
        
        // Check expiration date if subscription-based
        if let expirationDate = userDefaults.object(forKey: StorageKey.premiumExpirationDate) as? Date {
            isPremium = expirationDate > Date()
        }
    }
    
    // MARK: - Data Saving
    func saveUserPreferences() {
        if let data = try? encoder.encode(userPreferences) {
            userDefaults.set(data, forKey: StorageKey.userPreferences)
        }
        
        // Also save individual values for backward compatibility
        userDefaults.set(userPreferences.userName, forKey: StorageKey.userName)
        userDefaults.set(userPreferences.hasCompletedOnboarding, forKey: StorageKey.hasCompletedOnboarding)
        userDefaults.set(Array(userPreferences.selectedCategories).map { $0.rawValue }, forKey: StorageKey.selectedCategories)
        if let mood = userPreferences.currentMood {
            userDefaults.set(mood.rawValue, forKey: StorageKey.currentMood)
        }
        
        // Share with widget
        shareDataWithWidget()
    }
    
    func saveJournalEntries() {
        let journalURL = documentsDirectory.appendingPathComponent("journal.json")
        
        if let data = try? encoder.encode(journalEntries) {
            try? data.write(to: journalURL)
        }
    }
    
    func saveCustomAffirmations() {
        let customURL = documentsDirectory.appendingPathComponent("custom_affirmations.json")
        
        if let data = try? encoder.encode(customAffirmations) {
            try? data.write(to: customURL)
        }
    }
    
    func saveAnalyticsData() {
        if let data = try? encoder.encode(analyticsData) {
            userDefaults.set(data, forKey: StorageKey.analyticsData)
        }
    }
    
    func savePremiumStatus() {
        userDefaults.set(isPremium, forKey: StorageKey.isPremium)
    }
    
    // MARK: - Journal Management
    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.insert(entry, at: 0)
        saveJournalEntries()
        
        // Update analytics
        analyticsData.totalJournalEntries += 1
        saveAnalyticsData()
    }
    
    func deleteJournalEntry(_ entry: JournalEntry) {
        journalEntries.removeAll { $0.id == entry.id }
        saveJournalEntries()
    }
    
    func updateJournalEntry(_ entry: JournalEntry) {
        if let index = journalEntries.firstIndex(where: { $0.id == entry.id }) {
            journalEntries[index] = entry
            saveJournalEntries()
        }
    }
    
    // MARK: - Custom Affirmations
    func addCustomAffirmation(_ affirmation: Affirmation) {
        customAffirmations.append(affirmation)
        saveCustomAffirmations()
    }
    
    func deleteCustomAffirmation(_ affirmation: Affirmation) {
        customAffirmations.removeAll { $0.id == affirmation.id }
        saveCustomAffirmations()
    }
    
    // MARK: - Widget Data Sharing
    private func shareDataWithWidget() {
        guard let appGroupDefaults = appGroupDefaults else { return }
        
        // Share essential data for widget
        let widgetData = WidgetData(
            todayAffirmation: userDefaults.string(forKey: "todayAffirmationText") ?? "",
            userName: userPreferences.userName,
            currentMood: userPreferences.currentMood,
            streakCount: userDefaults.integer(forKey: "streakCount"),
            lastUpdated: Date()
        )
        
        if let data = try? encoder.encode(widgetData) {
            appGroupDefaults.set(data, forKey: "widgetData")
        }
    }
    
    // MARK: - Analytics
    func trackEvent(_ event: AnalyticsEvent) {
        switch event {
        case .appOpened:
            analyticsData.totalAppOpens += 1
        case .affirmationViewed:
            analyticsData.totalAffirmationsViewed += 1
        case .affirmationFavorited:
            analyticsData.totalFavorites += 1
        case .journalEntryCreated:
            analyticsData.totalJournalEntries += 1
        case .shareAction:
            analyticsData.totalShares += 1
        case .categoryChanged:
            break // Track separately if needed
        case .moodChanged:
            break // Track separately if needed
        }
        
        analyticsData.lastActiveDate = Date()
        saveAnalyticsData()
    }
    
    func getDailyUsageTime() -> TimeInterval {
        // This would be tracked throughout the session
        return analyticsData.totalUsageTime
    }
    
    // MARK: - Backup & Restore
    func createBackup() -> URL? {
        let backupData = BackupData(
            userPreferences: userPreferences,
            journalEntries: journalEntries,
            customAffirmations: customAffirmations,
            analyticsData: analyticsData,
            backupDate: Date()
        )
        
        let backupURL = documentsDirectory.appendingPathComponent("dailyglow_backup_\(Date().timeIntervalSince1970).json")
        
        if let data = try? encoder.encode(backupData) {
            try? data.write(to: backupURL)
            userDefaults.set(Date(), forKey: StorageKey.lastBackupDate)
            return backupURL
        }
        
        return nil
    }
    
    func restoreBackup(from url: URL) -> Bool {
        guard let data = try? Data(contentsOf: url),
              let backup = try? decoder.decode(BackupData.self, from: data) else {
            return false
        }
        
        userPreferences = backup.userPreferences
        journalEntries = backup.journalEntries
        customAffirmations = backup.customAffirmations
        analyticsData = backup.analyticsData
        
        // Save all restored data
        saveUserPreferences()
        saveJournalEntries()
        saveCustomAffirmations()
        saveAnalyticsData()
        
        return true
    }
    
    // MARK: - Cache Management
    func clearCache() {
        // Clear temporary files
        do {
            let cacheFiles = try FileManager.default.contentsOfDirectory(at: cachesDirectory, includingPropertiesForKeys: nil)
            for file in cacheFiles {
                try FileManager.default.removeItem(at: file)
            }
        } catch {
            print("Failed to clear cache: \(error)")
        }
    }
    
    func getCacheSize() -> Int64 {
        var size: Int64 = 0
        
        do {
            let cacheFiles = try FileManager.default.contentsOfDirectory(at: cachesDirectory, includingPropertiesForKeys: [.fileSizeKey])
            
            for file in cacheFiles {
                let fileSize = try file.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                size += Int64(fileSize)
            }
        } catch {
            print("Failed to calculate cache size: \(error)")
        }
        
        return size
    }
    
    // MARK: - Premium Management
    func updatePremiumStatus(isPremium: Bool, expirationDate: Date? = nil) {
        self.isPremium = isPremium
        userDefaults.set(isPremium, forKey: StorageKey.isPremium)
        
        if let expirationDate = expirationDate {
            userDefaults.set(expirationDate, forKey: StorageKey.premiumExpirationDate)
        }
    }
    
    // MARK: - Reset
    func resetAllData() {
        // Clear UserDefaults
        let domain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: domain)
        userDefaults.synchronize()
        
        // Clear documents
        do {
            let documentFiles = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            for file in documentFiles {
                try FileManager.default.removeItem(at: file)
            }
        } catch {
            print("Failed to clear documents: \(error)")
        }
        
        // Clear cache
        clearCache()
        
        // Reset properties
        userPreferences = UserPreferences()
        journalEntries = []
        customAffirmations = []
        analyticsData = AnalyticsData()
        isPremium = false
        
        // Setup fresh
        setupFirstLaunch()
    }
    
    // MARK: - Private Helpers
    private func setupFirstLaunch() {
        if userDefaults.object(forKey: StorageKey.firstLaunchDate) == nil {
            userDefaults.set(Date(), forKey: StorageKey.firstLaunchDate)
            userDefaults.set(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "", forKey: StorageKey.appVersion)
        }
    }
    
    private func setupAutoSave() {
        // Auto-save when app goes to background
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.saveAllData()
            }
            .store(in: &cancellables)
    }
    
    private func saveAllData() {
        saveUserPreferences()
        saveJournalEntries()
        saveCustomAffirmations()
        saveAnalyticsData()
        savePremiumStatus()
    }
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Supporting Models
// Note: JournalEntry is defined in Models/UserPreferences.swift
// This duplicate definition has been removed to avoid conflicts

struct AnalyticsData: Codable {
    var totalAppOpens: Int = 0
    var totalAffirmationsViewed: Int = 0
    var totalFavorites: Int = 0
    var totalJournalEntries: Int = 0
    var totalShares: Int = 0
    var totalUsageTime: TimeInterval = 0
    var lastActiveDate: Date = Date()
    var categoryUsage: [String: Int] = [:]
    var moodHistory: [String: Int] = [:]
}

struct WidgetData: Codable {
    var todayAffirmation: String
    var userName: String
    var currentMood: String?
    var streakCount: Int
    var lastUpdated: Date
}

struct BackupData: Codable {
    let userPreferences: UserPreferences
    let journalEntries: [JournalEntry]
    let customAffirmations: [Affirmation]
    let analyticsData: AnalyticsData
    let backupDate: Date
}

enum AnalyticsEvent {
    case appOpened
    case affirmationViewed
    case affirmationFavorited
    case journalEntryCreated
    case shareAction
    case categoryChanged
    case moodChanged
}
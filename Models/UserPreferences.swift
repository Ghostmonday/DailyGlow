import Foundation
import SwiftUI

struct UserPreferences: Codable {
    var userName: String
    var selectedCategories: Set<Category>
    var notificationEnabled: Bool
    var notificationTime: Date
    var dailyAffirmationCount: Int
    var currentMood: Mood?
    var preferredTheme: ThemePreference
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    var widgetEnabled: Bool
    var isPremium: Bool
    var streakCount: Int
    var lastOpenedDate: Date?
    var totalAffirmationsViewed: Int
    var favoriteAffirmationIds: [UUID]
    var journalEntries: [JournalEntry]
    var onboardingCompleted: Bool
    var premiumExpirationDate: Date?
    var hasCompletedOnboarding: Bool
    var preferredColorScheme: String
    var animatedBackgrounds: Bool
    
    enum CodingKeys: String, CodingKey {
        case userName, selectedCategories, notificationEnabled, notificationTime
        case dailyAffirmationCount, currentMood, preferredTheme, soundEnabled
        case hapticsEnabled, widgetEnabled, isPremium, streakCount
        case lastOpenedDate, totalAffirmationsViewed, favoriteAffirmationIds
        case journalEntries, onboardingCompleted, premiumExpirationDate
        case hasCompletedOnboarding, preferredColorScheme, animatedBackgrounds
    }
    
    init(userName: String = "",
         selectedCategories: Set<Category> = [],
         notificationEnabled: Bool = true,
         notificationTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date(),
         dailyAffirmationCount: Int = 3,
         currentMood: Mood? = nil,
         preferredTheme: ThemePreference = .system,
         soundEnabled: Bool = true,
         hapticsEnabled: Bool = true,
         widgetEnabled: Bool = false,
         isPremium: Bool = false,
         streakCount: Int = 0,
         lastOpenedDate: Date? = nil,
         totalAffirmationsViewed: Int = 0,
         favoriteAffirmationIds: [UUID] = [],
         journalEntries: [JournalEntry] = [],
         onboardingCompleted: Bool = false,
         premiumExpirationDate: Date? = nil,
         hasCompletedOnboarding: Bool = false,
         preferredColorScheme: String = "system",
         animatedBackgrounds: Bool = true) {
        self.userName = userName
        self.selectedCategories = selectedCategories
        self.notificationEnabled = notificationEnabled
        self.notificationTime = notificationTime
        self.dailyAffirmationCount = dailyAffirmationCount
        self.currentMood = currentMood
        self.preferredTheme = preferredTheme
        self.soundEnabled = soundEnabled
        self.hapticsEnabled = hapticsEnabled
        self.widgetEnabled = widgetEnabled
        self.isPremium = isPremium
        self.streakCount = streakCount
        self.lastOpenedDate = lastOpenedDate
        self.totalAffirmationsViewed = totalAffirmationsViewed
        self.favoriteAffirmationIds = favoriteAffirmationIds
        self.journalEntries = journalEntries
        self.onboardingCompleted = onboardingCompleted
        self.premiumExpirationDate = premiumExpirationDate
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.preferredColorScheme = preferredColorScheme
        self.animatedBackgrounds = animatedBackgrounds
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userName = try container.decode(String.self, forKey: .userName)
        selectedCategories = try container.decode(Set<Category>.self, forKey: .selectedCategories)
        notificationEnabled = try container.decode(Bool.self, forKey: .notificationEnabled)
        notificationTime = try container.decode(Date.self, forKey: .notificationTime)
        dailyAffirmationCount = try container.decode(Int.self, forKey: .dailyAffirmationCount)
        currentMood = try container.decodeIfPresent(Mood.self, forKey: .currentMood)
        preferredTheme = try container.decode(ThemePreference.self, forKey: .preferredTheme)
        soundEnabled = try container.decode(Bool.self, forKey: .soundEnabled)
        hapticsEnabled = try container.decode(Bool.self, forKey: .hapticsEnabled)
        widgetEnabled = try container.decode(Bool.self, forKey: .widgetEnabled)
        isPremium = try container.decode(Bool.self, forKey: .isPremium)
        streakCount = try container.decode(Int.self, forKey: .streakCount)
        lastOpenedDate = try container.decodeIfPresent(Date.self, forKey: .lastOpenedDate)
        totalAffirmationsViewed = try container.decode(Int.self, forKey: .totalAffirmationsViewed)
        favoriteAffirmationIds = try container.decode([UUID].self, forKey: .favoriteAffirmationIds)
        journalEntries = try container.decode([JournalEntry].self, forKey: .journalEntries)
        onboardingCompleted = try container.decode(Bool.self, forKey: .onboardingCompleted)
        premiumExpirationDate = try container.decodeIfPresent(Date.self, forKey: .premiumExpirationDate)
        hasCompletedOnboarding = try container.decode(Bool.self, forKey: .hasCompletedOnboarding)
        preferredColorScheme = try container.decode(String.self, forKey: .preferredColorScheme)
        animatedBackgrounds = try container.decode(Bool.self, forKey: .animatedBackgrounds)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userName, forKey: .userName)
        try container.encode(selectedCategories, forKey: .selectedCategories)
        try container.encode(notificationEnabled, forKey: .notificationEnabled)
        try container.encode(notificationTime, forKey: .notificationTime)
        try container.encode(dailyAffirmationCount, forKey: .dailyAffirmationCount)
        try container.encodeIfPresent(currentMood, forKey: .currentMood)
        try container.encode(preferredTheme, forKey: .preferredTheme)
        try container.encode(soundEnabled, forKey: .soundEnabled)
        try container.encode(hapticsEnabled, forKey: .hapticsEnabled)
        try container.encode(widgetEnabled, forKey: .widgetEnabled)
        try container.encode(isPremium, forKey: .isPremium)
        try container.encode(streakCount, forKey: .streakCount)
        try container.encodeIfPresent(lastOpenedDate, forKey: .lastOpenedDate)
        try container.encode(totalAffirmationsViewed, forKey: .totalAffirmationsViewed)
        try container.encode(favoriteAffirmationIds, forKey: .favoriteAffirmationIds)
        try container.encode(journalEntries, forKey: .journalEntries)
        try container.encode(onboardingCompleted, forKey: .onboardingCompleted)
        try container.encodeIfPresent(premiumExpirationDate, forKey: .premiumExpirationDate)
        try container.encode(hasCompletedOnboarding, forKey: .hasCompletedOnboarding)
        try container.encode(preferredColorScheme, forKey: .preferredColorScheme)
        try container.encode(animatedBackgrounds, forKey: .animatedBackgrounds)
    }
    
    enum ThemePreference: String, Codable, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
        
        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .system: return nil
            }
        }
    }
    
    mutating func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastOpened = lastOpenedDate {
            let lastOpenedDay = calendar.startOfDay(for: lastOpened)
            let daysDifference = calendar.dateComponents([.day], from: lastOpenedDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day
                streakCount += 1
            } else if daysDifference > 1 {
                // Streak broken
                streakCount = 1
            }
            // If daysDifference == 0, same day, don't update streak
        } else {
            // First time opening
            streakCount = 1
        }
        
        lastOpenedDate = Date()
    }
    
    mutating func addFavorite(_ affirmationId: UUID) {
        if !favoriteAffirmationIds.contains(affirmationId) {
            favoriteAffirmationIds.append(affirmationId)
        }
    }
    
    mutating func removeFavorite(_ affirmationId: UUID) {
        favoriteAffirmationIds.removeAll { $0 == affirmationId }
    }
    
    func isFavorite(_ affirmationId: UUID) -> Bool {
        favoriteAffirmationIds.contains(affirmationId)
    }
    
    var streakEmoji: String {
        switch streakCount {
        case 0: return ""
        case 1...6: return "🔥"
        case 7...29: return "🔥🔥"
        case 30...99: return "🔥🔥🔥"
        case 100...364: return "💎"
        default: return "👑"
        }
    }
    
    var nextMilestone: Int {
        if streakCount < 7 { return 7 }
        if streakCount < 30 { return 30 }
        if streakCount < 100 { return 100 }
        if streakCount < 365 { return 365 }
        return 1000
    }
}

struct JournalEntry: Identifiable, Codable {
    var id: UUID
    var date: Date
    var content: String
    var mood: Mood?
    var affirmationId: UUID?
    var tags: [String]
    var gratitude: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, date, content, mood, affirmationId, tags, gratitude
    }
    
    init(id: UUID = UUID(), date: Date = Date(), content: String = "", mood: Mood? = nil, affirmationId: UUID? = nil, tags: [String] = [], gratitude: [String] = []) {
        self.id = id
        self.date = date
        self.content = content
        self.mood = mood
        self.affirmationId = affirmationId
        self.tags = tags
        self.gratitude = gratitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        content = try container.decode(String.self, forKey: .content)
        mood = try container.decodeIfPresent(Mood.self, forKey: .mood)
        affirmationId = try container.decodeIfPresent(UUID.self, forKey: .affirmationId)
        tags = try container.decode([String].self, forKey: .tags)
        gratitude = try container.decode([String].self, forKey: .gratitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(content, forKey: .content)
        try container.encodeIfPresent(mood, forKey: .mood)
        try container.encodeIfPresent(affirmationId, forKey: .affirmationId)
        try container.encode(tags, forKey: .tags)
        try container.encode(gratitude, forKey: .gratitude)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Statistics for user progress
struct UserStatistics {
    let preferences: UserPreferences
    
    var totalDaysUsed: Int {
        guard let firstDate = preferences.lastOpenedDate else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: firstDate, to: Date()).day ?? 0
        return max(1, days)
    }
    
    var averageAffirmationsPerDay: Double {
        guard totalDaysUsed > 0 else { return 0 }
        return Double(preferences.totalAffirmationsViewed) / Double(totalDaysUsed)
    }
    
    var favoriteCategory: Category? {
        // This would require tracking which categories are viewed most
        // For now, return the first selected category
        preferences.selectedCategories.first
    }
    
    var streakProgress: Double {
        let nextMilestone = preferences.nextMilestone
        let previousMilestone: Int
        
        if nextMilestone == 7 { previousMilestone = 0 }
        else if nextMilestone == 30 { previousMilestone = 7 }
        else if nextMilestone == 100 { previousMilestone = 30 }
        else if nextMilestone == 365 { previousMilestone = 100 }
        else { previousMilestone = 365 }
        
        let range = nextMilestone - previousMilestone
        let progress = preferences.streakCount - previousMilestone
        
        return Double(progress) / Double(range)
    }
}

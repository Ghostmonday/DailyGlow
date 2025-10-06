//
//  Achievement.swift
//  DailyGlow
//
//  Gamification system with achievements and rewards
//

import SwiftUI

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable {
    let id: String
    let category: AchievementCategory
    let title: String
    let description: String
    let icon: String
    let requiredValue: Int
    let rewardPoints: Int
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    var progress: Int = 0
    
    var progressPercentage: Double {
        min(1.0, Double(progress) / Double(requiredValue))
    }
    
    var isComplete: Bool {
        progress >= requiredValue
    }
    
    mutating func unlock() {
        isUnlocked = true
        unlockedDate = Date()
    }
}

// MARK: - Achievement Category
enum AchievementCategory: String, Codable, CaseIterable {
    case streak = "Consistency"
    case affirmations = "Affirmations"
    case journal = "Journaling"
    case gratitude = "Gratitude"
    case mindfulness = "Mindfulness"
    case social = "Community"
    case explorer = "Explorer"
    case premium = "Premium"
    
    var color: Color {
        switch self {
        case .streak: return .orange
        case .affirmations: return .purple
        case .journal: return .blue
        case .gratitude: return .pink
        case .mindfulness: return .green
        case .social: return .cyan
        case .explorer: return .yellow
        case .premium: return .indigo
        }
    }
    
    var icon: String {
        switch self {
        case .streak: return "flame.fill"
        case .affirmations: return "sparkles"
        case .journal: return "book.fill"
        case .gratitude: return "heart.fill"
        case .mindfulness: return "leaf.fill"
        case .social: return "person.2.fill"
        case .explorer: return "map.fill"
        case .premium: return "crown.fill"
        }
    }
}

// MARK: - Achievement Definitions
extension Achievement {
    static let allAchievements: [Achievement] = [
        // Streak Achievements
        Achievement(
            id: "streak_7",
            category: .streak,
            title: "Week Warrior",
            description: "Use the app for 7 days in a row",
            icon: "7.circle.fill",
            requiredValue: 7,
            rewardPoints: 50
        ),
        Achievement(
            id: "streak_30",
            category: .streak,
            title: "Monthly Master",
            description: "Maintain a 30-day streak",
            icon: "30.circle.fill",
            requiredValue: 30,
            rewardPoints: 200
        ),
        Achievement(
            id: "streak_100",
            category: .streak,
            title: "Century Club",
            description: "Achieve a 100-day streak",
            icon: "100.circle.fill",
            requiredValue: 100,
            rewardPoints: 1000
        ),
        Achievement(
            id: "streak_365",
            category: .streak,
            title: "Year of Growth",
            description: "Complete a full year streak",
            icon: "star.circle.fill",
            requiredValue: 365,
            rewardPoints: 5000
        ),
        
        // Affirmation Achievements
        Achievement(
            id: "affirmations_10",
            category: .affirmations,
            title: "Affirmation Starter",
            description: "Read 10 affirmations",
            icon: "text.bubble.fill",
            requiredValue: 10,
            rewardPoints: 25
        ),
        Achievement(
            id: "affirmations_50",
            category: .affirmations,
            title: "Positive Thinker",
            description: "Read 50 affirmations",
            icon: "bubble.left.and.bubble.right.fill",
            requiredValue: 50,
            rewardPoints: 100
        ),
        Achievement(
            id: "affirmations_100",
            category: .affirmations,
            title: "Affirmation Expert",
            description: "Read 100 affirmations",
            icon: "quote.bubble.fill",
            requiredValue: 100,
            rewardPoints: 250
        ),
        Achievement(
            id: "affirmations_500",
            category: .affirmations,
            title: "Positivity Champion",
            description: "Read 500 affirmations",
            icon: "star.bubble.fill",
            requiredValue: 500,
            rewardPoints: 1000
        ),
        Achievement(
            id: "favorites_10",
            category: .affirmations,
            title: "Curator",
            description: "Save 10 favorite affirmations",
            icon: "heart.text.square.fill",
            requiredValue: 10,
            rewardPoints: 50
        ),
        Achievement(
            id: "favorites_50",
            category: .affirmations,
            title: "Collection Master",
            description: "Save 50 favorite affirmations",
            icon: "heart.circle.fill",
            requiredValue: 50,
            rewardPoints: 200
        ),
        
        // Journal Achievements
        Achievement(
            id: "journal_1",
            category: .journal,
            title: "First Entry",
            description: "Write your first journal entry",
            icon: "pencil.circle.fill",
            requiredValue: 1,
            rewardPoints: 25
        ),
        Achievement(
            id: "journal_10",
            category: .journal,
            title: "Journal Beginner",
            description: "Write 10 journal entries",
            icon: "book.circle.fill",
            requiredValue: 10,
            rewardPoints: 75
        ),
        Achievement(
            id: "journal_30",
            category: .journal,
            title: "Consistent Writer",
            description: "Write 30 journal entries",
            icon: "book.closed.fill",
            requiredValue: 30,
            rewardPoints: 200
        ),
        Achievement(
            id: "journal_100",
            category: .journal,
            title: "Journal Master",
            description: "Write 100 journal entries",
            icon: "books.vertical.fill",
            requiredValue: 100,
            rewardPoints: 500
        ),
        Achievement(
            id: "journal_words_1000",
            category: .journal,
            title: "Wordsmith",
            description: "Write 1000 total words in journal",
            icon: "text.alignleft",
            requiredValue: 1000,
            rewardPoints: 150
        ),
        
        // Gratitude Achievements
        Achievement(
            id: "gratitude_10",
            category: .gratitude,
            title: "Grateful Heart",
            description: "Record 10 gratitude items",
            icon: "heart.fill",
            requiredValue: 10,
            rewardPoints: 50
        ),
        Achievement(
            id: "gratitude_50",
            category: .gratitude,
            title: "Appreciation Expert",
            description: "Record 50 gratitude items",
            icon: "heart.circle.fill",
            requiredValue: 50,
            rewardPoints: 150
        ),
        Achievement(
            id: "gratitude_100",
            category: .gratitude,
            title: "Gratitude Master",
            description: "Record 100 gratitude items",
            icon: "heart.square.fill",
            requiredValue: 100,
            rewardPoints: 300
        ),
        Achievement(
            id: "gratitude_365",
            category: .gratitude,
            title: "Year of Gratitude",
            description: "Record 365 gratitude items",
            icon: "suit.heart.fill",
            requiredValue: 365,
            rewardPoints: 1000
        ),
        
        // Mindfulness Achievements
        Achievement(
            id: "morning_10",
            category: .mindfulness,
            title: "Early Bird",
            description: "Use app in the morning 10 times",
            icon: "sunrise.fill",
            requiredValue: 10,
            rewardPoints: 75
        ),
        Achievement(
            id: "evening_10",
            category: .mindfulness,
            title: "Night Owl",
            description: "Use app in the evening 10 times",
            icon: "moon.stars.fill",
            requiredValue: 10,
            rewardPoints: 75
        ),
        Achievement(
            id: "moods_all",
            category: .mindfulness,
            title: "Emotional Explorer",
            description: "Track all different moods",
            icon: "face.smiling.fill",
            requiredValue: 6,
            rewardPoints: 100
        ),
        Achievement(
            id: "weekend_warrior",
            category: .mindfulness,
            title: "Weekend Warrior",
            description: "Use app every weekend for a month",
            icon: "calendar.badge.plus",
            requiredValue: 8,
            rewardPoints: 150
        ),
        
        // Explorer Achievements
        Achievement(
            id: "categories_all",
            category: .explorer,
            title: "Category Explorer",
            description: "Try affirmations from all categories",
            icon: "square.grid.3x3.fill",
            requiredValue: 10,
            rewardPoints: 200
        ),
        Achievement(
            id: "features_all",
            category: .explorer,
            title: "Feature Master",
            description: "Use all app features",
            icon: "star.fill",
            requiredValue: 5,
            rewardPoints: 150
        ),
        Achievement(
            id: "customization",
            category: .explorer,
            title: "Personalizer",
            description: "Customize your experience",
            icon: "paintbrush.fill",
            requiredValue: 3,
            rewardPoints: 100
        ),
        
        // Social Achievements
        Achievement(
            id: "share_1",
            category: .social,
            title: "Spreader of Joy",
            description: "Share your first affirmation",
            icon: "square.and.arrow.up.fill",
            requiredValue: 1,
            rewardPoints: 50
        ),
        Achievement(
            id: "share_10",
            category: .social,
            title: "Inspiration Sharer",
            description: "Share 10 affirmations",
            icon: "arrow.up.heart.fill",
            requiredValue: 10,
            rewardPoints: 150
        ),
        Achievement(
            id: "invite_friend",
            category: .social,
            title: "Community Builder",
            description: "Invite a friend to Daily Glow",
            icon: "person.badge.plus.fill",
            requiredValue: 1,
            rewardPoints: 200
        ),
        
        // Premium Achievements
        Achievement(
            id: "premium_subscriber",
            category: .premium,
            title: "Premium Member",
            description: "Become a premium subscriber",
            icon: "crown.fill",
            requiredValue: 1,
            rewardPoints: 500
        ),
        Achievement(
            id: "premium_annual",
            category: .premium,
            title: "Annual Supporter",
            description: "Subscribe for a full year",
            icon: "star.leadinghalf.filled",
            requiredValue: 1,
            rewardPoints: 2000
        )
    ]
}

// MARK: - Achievement Manager
@MainActor
class AchievementManager: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var totalPoints: Int = 0
    @Published var level: Int = 1
    @Published var recentlyUnlocked: [Achievement] = []
    @Published var showAchievementUnlocked: Bool = false
    @Published var currentUnlockedAchievement: Achievement?
    
    private let userDefaults = UserDefaults.standard
    private let achievementsKey = "userAchievements"
    private let pointsKey = "totalAchievementPoints"
    private let levelKey = "userLevel"
    
    init() {
        loadAchievements()
    }
    
    // MARK: - Load & Save
    func loadAchievements() {
        if let data = userDefaults.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        } else {
            achievements = Achievement.allAchievements
        }
        
        totalPoints = userDefaults.integer(forKey: pointsKey)
        level = userDefaults.integer(forKey: levelKey)
        if level == 0 { level = 1 }
    }
    
    func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            userDefaults.set(encoded, forKey: achievementsKey)
        }
        userDefaults.set(totalPoints, forKey: pointsKey)
        userDefaults.set(level, forKey: levelKey)
    }
    
    // MARK: - Progress Tracking
    func updateProgress(for achievementId: String, progress: Int) {
        guard let index = achievements.firstIndex(where: { $0.id == achievementId }) else { return }
        
        achievements[index].progress = progress
        
        // Check if achievement is newly completed
        if achievements[index].isComplete && !achievements[index].isUnlocked {
            unlockAchievement(at: index)
        }
        
        saveAchievements()
    }
    
    func incrementProgress(for achievementId: String, by amount: Int = 1) {
        guard let index = achievements.firstIndex(where: { $0.id == achievementId }) else { return }
        
        achievements[index].progress += amount
        
        // Check if achievement is newly completed
        if achievements[index].isComplete && !achievements[index].isUnlocked {
            unlockAchievement(at: index)
        }
        
        saveAchievements()
    }
    
    // MARK: - Unlock Achievement
    private func unlockAchievement(at index: Int) {
        achievements[index].unlock()
        totalPoints += achievements[index].rewardPoints
        updateLevel()
        
        // Show notification
        currentUnlockedAchievement = achievements[index]
        showAchievementUnlocked = true
        
        // Add to recently unlocked
        recentlyUnlocked.insert(achievements[index], at: 0)
        if recentlyUnlocked.count > 5 {
            recentlyUnlocked.removeLast()
        }
        
        // Haptic feedback
        HapticManager.shared.notification(.success)
        
        saveAchievements()
    }
    
    // MARK: - Level System
    private func updateLevel() {
        // Level up every 500 points
        let newLevel = (totalPoints / 500) + 1
        if newLevel > level {
            level = newLevel
            // Celebrate level up
            HapticManager.shared.playStreak()
        }
    }
    
    func pointsToNextLevel() -> Int {
        let currentLevelPoints = (level - 1) * 500
        let nextLevelPoints = level * 500
        return nextLevelPoints - totalPoints
    }
    
    func levelProgress() -> Double {
        let currentLevelPoints = (level - 1) * 500
        let nextLevelPoints = level * 500
        let progressInLevel = totalPoints - currentLevelPoints
        let pointsNeededForLevel = nextLevelPoints - currentLevelPoints
        return Double(progressInLevel) / Double(pointsNeededForLevel)
    }
    
    // MARK: - Track Activities
    func trackStreakDay(_ day: Int) {
        if day >= 7 {
            updateProgress(for: "streak_7", progress: day)
        }
        if day >= 30 {
            updateProgress(for: "streak_30", progress: day)
        }
        if day >= 100 {
            updateProgress(for: "streak_100", progress: day)
        }
        if day >= 365 {
            updateProgress(for: "streak_365", progress: day)
        }
    }
    
    func trackAffirmationRead() {
        let totalRead = UserDefaults.standard.integer(forKey: "totalAffirmationsViewed")
        
        incrementProgress(for: "affirmations_10", by: 1)
        incrementProgress(for: "affirmations_50", by: 1)
        incrementProgress(for: "affirmations_100", by: 1)
        incrementProgress(for: "affirmations_500", by: 1)
    }
    
    func trackJournalEntry() {
        incrementProgress(for: "journal_1", by: 1)
        incrementProgress(for: "journal_10", by: 1)
        incrementProgress(for: "journal_30", by: 1)
        incrementProgress(for: "journal_100", by: 1)
    }
    
    func trackGratitude(count: Int) {
        incrementProgress(for: "gratitude_10", by: count)
        incrementProgress(for: "gratitude_50", by: count)
        incrementProgress(for: "gratitude_100", by: count)
        incrementProgress(for: "gratitude_365", by: count)
    }
    
    func trackShare() {
        incrementProgress(for: "share_1", by: 1)
        incrementProgress(for: "share_10", by: 1)
    }
    
    func trackFavorite() {
        let favoritesCount = achievements.first { $0.id == "favorites_10" }?.progress ?? 0
        incrementProgress(for: "favorites_10", by: 1)
        incrementProgress(for: "favorites_50", by: 1)
    }
    
    // MARK: - Statistics
    func unlockedCount() -> Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    func progressByCategory() -> [AchievementCategory: Double] {
        var progress: [AchievementCategory: Double] = [:]
        
        for category in AchievementCategory.allCases {
            let categoryAchievements = achievements.filter { $0.category == category }
            let unlockedCount = categoryAchievements.filter { $0.isUnlocked }.count
            let totalCount = categoryAchievements.count
            
            progress[category] = totalCount > 0 ? Double(unlockedCount) / Double(totalCount) : 0
        }
        
        return progress
    }
    
    func nextAchievementsToUnlock() -> [Achievement] {
        achievements
            .filter { !$0.isUnlocked && $0.progressPercentage > 0 }
            .sorted { $0.progressPercentage > $1.progressPercentage }
            .prefix(3)
            .map { $0 }
    }
}

// MARK: - Achievement Badge View
struct AchievementBadge: View {
    let achievement: Achievement
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Background
            Circle()
                .fill(
                    achievement.isUnlocked ?
                    LinearGradient(
                        colors: [
                            achievement.category.color,
                            achievement.category.color.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) : LinearGradient(
                        colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Border
            Circle()
                .stroke(
                    achievement.isUnlocked ? achievement.category.color : Color.gray.opacity(0.5),
                    lineWidth: 3
                )
            
            // Progress ring
            if !achievement.isUnlocked && achievement.progressPercentage > 0 {
                Circle()
                    .trim(from: 0, to: achievement.progressPercentage)
                    .stroke(
                        achievement.category.color,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
            
            // Icon
            Image(systemName: achievement.icon)
                .font(.system(size: size * 0.4))
                .foregroundColor(achievement.isUnlocked ? .white : .gray)
            
            // Lock overlay
            if !achievement.isUnlocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: size * 0.2))
                    .foregroundColor(.white)
                    .offset(x: size * 0.25, y: -size * 0.25)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.7))
                            .frame(width: size * 0.35, height: size * 0.35)
                            .offset(x: size * 0.25, y: -size * 0.25)
                    )
            }
        }
        .frame(width: size, height: size)
    }
}

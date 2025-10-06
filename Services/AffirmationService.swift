//
//  AffirmationService.swift
//  DailyGlow
//
//  Service for managing affirmations, including fetching, filtering, favorites,
//  and daily affirmation selection.
//

import SwiftUI
import Combine

@MainActor
class AffirmationService: ObservableObject {
    // MARK: - Published Properties
    @Published var todayAffirmation: Affirmation?
    @Published var recentAffirmations: [Affirmation] = []
    @Published var favoriteAffirmations: [Affirmation] = []
    @Published var categoryAffirmations: [Category: [Affirmation]] = [:]
    @Published var isLoading: Bool = false
    @Published var lastRefreshDate: Date?
    @Published var streakCount: Int = 0
    @Published var totalAffirmationsViewed: Int = 0
    @Published var searchResults: [Affirmation] = []
    
    // MARK: - Private Properties
    private var allAffirmations: [Affirmation] = []
    private var viewedAffirmationIds: Set<String> = []
    private var favoriteIds: Set<String> = []
    private var cancellables = Set<AnyCancellable>()
    
    // UserDefaults keys
    private let todayAffirmationKey = "todayAffirmationId"
    private let lastRefreshDateKey = "lastRefreshDate"
    private let favoriteIdsKey = "favoriteAffirmationIds"
    private let viewedIdsKey = "viewedAffirmationIds"
    private let streakCountKey = "streakCount"
    private let lastStreakDateKey = "lastStreakDate"
    private let totalViewedKey = "totalAffirmationsViewed"
    
    // MARK: - Initialization
    init() {
        loadAllAffirmations()
        loadUserData()
        checkDailyAffirmation()
        setupNotifications()
    }
    
    // MARK: - Data Loading
    private func loadAllAffirmations() {
        // Load the default affirmations
        allAffirmations = Affirmation.sampleAffirmations
        
        // Organize by category
        for affirmation in allAffirmations {
            if categoryAffirmations[affirmation.category] == nil {
                categoryAffirmations[affirmation.category] = []
            }
            categoryAffirmations[affirmation.category]?.append(affirmation)
        }
        
        // Apply favorites
        updateFavorites()
    }
    
    private func loadUserData() {
        // Load favorite IDs
        if let savedFavoriteIds = UserDefaults.standard.array(forKey: favoriteIdsKey) as? [String] {
            favoriteIds = Set(savedFavoriteIds)
            updateFavorites()
        }
        
        // Load viewed IDs
        if let savedViewedIds = UserDefaults.standard.array(forKey: viewedIdsKey) as? [String] {
            viewedAffirmationIds = Set(savedViewedIds)
        }
        
        // Load streak data
        streakCount = UserDefaults.standard.integer(forKey: streakCountKey)
        totalAffirmationsViewed = UserDefaults.standard.integer(forKey: totalViewedKey)
        
        // Load last refresh date
        lastRefreshDate = UserDefaults.standard.object(forKey: lastRefreshDateKey) as? Date
    }
    
    private func saveUserData() {
        UserDefaults.standard.set(Array(favoriteIds), forKey: favoriteIdsKey)
        UserDefaults.standard.set(Array(viewedAffirmationIds), forKey: viewedIdsKey)
        UserDefaults.standard.set(streakCount, forKey: streakCountKey)
        UserDefaults.standard.set(totalAffirmationsViewed, forKey: totalViewedKey)
    }
    
    // MARK: - Daily Affirmation Management
    private func checkDailyAffirmation() {
        let calendar = Calendar.current
        let now = Date()
        
        // Check if we need a new daily affirmation
        if let lastRefresh = lastRefreshDate,
           calendar.isDateInToday(lastRefresh),
           let savedIdString = UserDefaults.standard.string(forKey: todayAffirmationKey),
           let savedId = UUID(uuidString: savedIdString),
           let affirmation = allAffirmations.first(where: { $0.id == savedId }) {
            // Use existing today's affirmation
            todayAffirmation = affirmation
        } else {
            // Generate new daily affirmation
            generateDailyAffirmation()
        }
        
        // Update streak
        updateStreak()
    }
    
    func generateDailyAffirmation() {
        // Get user's preferred categories or use all
        let preferredCategories = UserDefaults.standard.array(forKey: "selectedCategories") as? [String] ?? []
        
        var availableAffirmations = allAffirmations
        
        // Filter by preferred categories if any
        if !preferredCategories.isEmpty {
            availableAffirmations = allAffirmations.filter { affirmation in
                preferredCategories.contains(affirmation.category.rawValue)
            }
        }
        
        // Filter out recently viewed (last 7 days worth)
        let recentLimit = min(7, availableAffirmations.count / 2)
        let recentIds = viewedAffirmationIds.suffix(recentLimit).compactMap { UUID(uuidString: $0) }
        availableAffirmations = availableAffirmations.filter { !recentIds.contains($0.id) }
        
        // If all have been viewed recently, reset
        if availableAffirmations.isEmpty {
            availableAffirmations = allAffirmations
            viewedAffirmationIds.removeAll()
        }
        
        // Select random affirmation
        if let newAffirmation = availableAffirmations.randomElement() {
            todayAffirmation = newAffirmation
            UserDefaults.standard.set(newAffirmation.id.uuidString, forKey: todayAffirmationKey)
            lastRefreshDate = Date()
            UserDefaults.standard.set(lastRefreshDate, forKey: lastRefreshDateKey)
            
            // Add to recent
            addToRecent(newAffirmation)
        }
    }
    
    // MARK: - Affirmation Interaction
    func viewAffirmation(_ affirmation: Affirmation) {
        viewedAffirmationIds.insert(affirmation.id.uuidString)
        totalAffirmationsViewed += 1
        addToRecent(affirmation)
        saveUserData()
        
        // Trigger haptic feedback
        HapticManager.shared.playAffirmationAppear()
    }
    
    func toggleFavorite(_ affirmation: Affirmation) {
        if favoriteIds.contains(affirmation.id.uuidString) {
            favoriteIds.remove(affirmation.id.uuidString)
            HapticManager.shared.playFavoriteToggle(isFavorited: false)
        } else {
            favoriteIds.insert(affirmation.id.uuidString)
            HapticManager.shared.playFavoriteToggle(isFavorited: true)
        }
        
        updateFavorites()
        saveUserData()
    }
    
    func isFavorite(_ affirmation: Affirmation) -> Bool {
        favoriteIds.contains(affirmation.id.uuidString)
    }
    
    private func updateFavorites() {
        favoriteAffirmations = allAffirmations.filter { favoriteIds.contains($0.id.uuidString) }
    }
    
    private func addToRecent(_ affirmation: Affirmation) {
        // Remove if already exists
        recentAffirmations.removeAll { $0.id == affirmation.id }
        
        // Add to beginning
        recentAffirmations.insert(affirmation, at: 0)
        
        // Keep only last 20
        if recentAffirmations.count > 20 {
            recentAffirmations = Array(recentAffirmations.prefix(20))
        }
    }
    
    // MARK: - Search
    func searchAffirmations(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        let lowercasedQuery = query.lowercased()
        searchResults = allAffirmations.filter { affirmation in
            affirmation.text.lowercased().contains(lowercasedQuery) ||
            affirmation.category.rawValue.lowercased().contains(lowercasedQuery)
        }
    }
    
    // MARK: - Category Filtering
    func getAffirmations(for category: Category, limit: Int? = nil) -> [Affirmation] {
        let affirmations = categoryAffirmations[category] ?? []
        if let limit = limit {
            return Array(affirmations.prefix(limit))
        }
        return affirmations
    }
    
    func getAffirmations(for mood: Mood, limit: Int? = nil) -> [Affirmation] {
        // Get suggested categories for this mood
        let categories = mood.suggestedCategories
        let affirmations = allAffirmations.filter { categories.contains($0.category) }
        if let limit = limit {
            return Array(affirmations.shuffled().prefix(limit))
        }
        return affirmations.shuffled()
    }
    
    // MARK: - Streak Management
    private func updateStreak() {
        let calendar = Calendar.current
        let now = Date()
        
        if let lastStreakDate = UserDefaults.standard.object(forKey: lastStreakDateKey) as? Date {
            if calendar.isDateInToday(lastStreakDate) {
                // Already updated today
                return
            } else if calendar.isDateInYesterday(lastStreakDate) {
                // Continue streak
                streakCount += 1
            } else {
                // Streak broken
                streakCount = 1
            }
        } else {
            // First time
            streakCount = 1
        }
        
        UserDefaults.standard.set(now, forKey: lastStreakDateKey)
        UserDefaults.standard.set(streakCount, forKey: streakCountKey)
        
        // Celebrate milestones
        if streakCount % 7 == 0 {
            HapticManager.shared.playStreak()
        }
    }
    
    func checkInToday() {
        updateStreak()
    }
    
    // MARK: - Recommendations
    func getRecommendedAffirmations(limit: Int = 5) -> [Affirmation] {
        var recommendations: [Affirmation] = []
        
        // Get current time-based mood
        let hour = Calendar.current.component(.hour, from: Date())
        let currentMood: Mood = {
            switch hour {
            case 5..<10: return .energized
            case 10..<14: return .motivated
            case 14..<18: return .focused
            case 18..<22: return .calm
            default: return .peaceful
            }
        }()
        
        // Add mood-based recommendations
        let moodAffirmations = getAffirmations(for: currentMood, limit: 3)
        recommendations.append(contentsOf: moodAffirmations)
        
        // Add from favorite categories
        if let userName = UserDefaults.standard.string(forKey: "userName"),
           !userName.isEmpty {
            // Personalized recommendations based on favorites
            let favoriteCategories = Set(favoriteAffirmations.map { $0.category })
            for category in favoriteCategories.prefix(2) {
                if let affirmation = getAffirmations(for: category, limit: 1).first {
                    recommendations.append(affirmation)
                }
            }
        }
        
        // Remove duplicates and limit
        let uniqueRecommendations = Array(Set(recommendations))
        return Array(uniqueRecommendations.prefix(limit))
    }
    
    // MARK: - Statistics
    func getStatistics() -> AffirmationStatistics {
        AffirmationStatistics(
            totalViewed: totalAffirmationsViewed,
            favoriteCount: favoriteAffirmations.count,
            currentStreak: streakCount,
            categoriesExplored: Set(viewedAffirmationIds.compactMap { idString in
                guard let id = UUID(uuidString: idString) else { return nil }
                return allAffirmations.first { $0.id == id }?.category
            }).count,
            mostViewedCategory: getMostViewedCategory()
        )
    }
    
    private func getMostViewedCategory() -> Category? {
        var categoryCounts: [Category: Int] = [:]
        
        for idString in viewedAffirmationIds {
            guard let id = UUID(uuidString: idString) else { continue }
            if let affirmation = allAffirmations.first(where: { $0.id == id }) {
                categoryCounts[affirmation.category, default: 0] += 1
            }
        }
        
        return categoryCounts.max { $0.value < $1.value }?.key
    }
    
    // MARK: - Data Export
    func exportFavorites() -> String {
        let favorites = favoriteAffirmations.map { affirmation in
            "\(affirmation.text)\n- \(affirmation.category.rawValue)"
        }.joined(separator: "\n\n")
        
        return """
        My Daily Glow Favorite Affirmations
        Generated on: \(Date().formatted())
        
        \(favorites)
        """
    }
    
    // MARK: - Notifications
    private func setupNotifications() {
        // Observe app lifecycle for streak reminders
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.checkDailyAffirmation()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Reset
    func resetAllData() {
        favoriteIds.removeAll()
        viewedAffirmationIds.removeAll()
        recentAffirmations.removeAll()
        favoriteAffirmations.removeAll()
        streakCount = 0
        totalAffirmationsViewed = 0
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: todayAffirmationKey)
        UserDefaults.standard.removeObject(forKey: lastRefreshDateKey)
        UserDefaults.standard.removeObject(forKey: favoriteIdsKey)
        UserDefaults.standard.removeObject(forKey: viewedIdsKey)
        UserDefaults.standard.removeObject(forKey: streakCountKey)
        UserDefaults.standard.removeObject(forKey: lastStreakDateKey)
        UserDefaults.standard.removeObject(forKey: totalViewedKey)
        
        // Generate new daily affirmation
        generateDailyAffirmation()
    }
}

// MARK: - Statistics Model
struct AffirmationStatistics {
    let totalViewed: Int
    let favoriteCount: Int
    let currentStreak: Int
    let categoriesExplored: Int
    let mostViewedCategory: Category?
    
    var averagePerDay: Double {
        guard currentStreak > 0 else { return 0 }
        return Double(totalViewed) / Double(currentStreak)
    }
}

// MARK: - Calendar Extension
private extension Calendar {
    func isDateInYesterday(_ date: Date) -> Bool {
        return isDate(date, inSameDayAs: Date().addingTimeInterval(-86400))
    }
}
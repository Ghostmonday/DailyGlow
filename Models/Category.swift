import Foundation
import SwiftUI

enum Category: String, CaseIterable, Codable, Identifiable {
    case motivation = "Motivation"
    case love = "Love"
    case selfLove = "Self Love"
    case success = "Success"
    case health = "Health"
    case confidence = "Confidence"
    case gratitude = "Gratitude"
    case peace = "Peace"
    case relationships = "Relationships"
    case abundance = "Abundance"
    case creativity = "Creativity"
    case spiritual = "Spiritual"
    
    var id: String { rawValue }
    
    var displayName: String {
        rawValue
    }
    
    var sampleAffirmations: [Affirmation] {
        AffirmationCollection.getAffirmations(for: self)
    }
    
    var icon: String {
        switch self {
        case .motivation: return "flame.fill"
        case .love, .selfLove: return "heart.fill"
        case .success: return "star.fill"
        case .health: return "heart.circle.fill"
        case .confidence: return "person.fill.checkmark"
        case .gratitude: return "hands.sparkles.fill"
        case .peace: return "leaf.fill"
        case .relationships: return "person.2.fill"
        case .abundance: return "sparkles"
        case .creativity: return "paintbrush.fill"
        case .spiritual: return "moon.stars.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .motivation: return .moodEnergized
        case .love, .selfLove: return .categoryLove
        case .success: return .categorySuccess
        case .health: return .categoryHealth
        case .confidence: return .categoryConfidence
        case .gratitude: return .categoryGratitude
        case .peace: return .categoryPeace
        case .relationships: return .accentPink
        case .abundance: return .premiumGold
        case .creativity: return .accentPurple
        case .spiritual: return Color(red: 0.5, green: 0.3, blue: 0.8)
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .motivation:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.5, blue: 0.3), Color(red: 1.0, green: 0.3, blue: 0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .love, .selfLove:
            return LinearGradient(
                colors: [Color(red: 0.95, green: 0.45, blue: 0.55), Color(red: 0.9, green: 0.3, blue: 0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .success:
            return LinearGradient(
                colors: [Color(red: 0.3, green: 0.75, blue: 0.5), Color(red: 0.2, green: 0.65, blue: 0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .health:
            return LinearGradient(
                colors: [Color(red: 0.5, green: 0.85, blue: 0.75), Color(red: 0.3, green: 0.75, blue: 0.65)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .confidence:
            return LinearGradient(
                colors: [Color(red: 0.7, green: 0.5, blue: 0.95), Color(red: 0.6, green: 0.4, blue: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .gratitude:
            return LinearGradient(
                colors: [Color(red: 0.95, green: 0.7, blue: 0.4), Color(red: 0.9, green: 0.6, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .peace:
            return LinearGradient(
                colors: [Color(red: 0.6, green: 0.75, blue: 0.9), Color(red: 0.5, green: 0.65, blue: 0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .relationships:
            return LinearGradient(
                colors: [Color(red: 0.95, green: 0.5, blue: 0.65), Color(red: 0.85, green: 0.4, blue: 0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .abundance:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 0.9, green: 0.74, blue: 0.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .creativity:
            return LinearGradient(
                colors: [Color(red: 0.6, green: 0.4, blue: 0.9), Color(red: 0.8, green: 0.3, blue: 0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .spiritual:
            return LinearGradient(
                colors: [Color(red: 0.5, green: 0.3, blue: 0.8), Color(red: 0.4, green: 0.2, blue: 0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var description: String {
        switch self {
        case .motivation: return "Ignite your inner fire and drive"
        case .love, .selfLove: return "Embrace self-love and acceptance"
        case .success: return "Attract achievement and prosperity"
        case .health: return "Nurture your body and wellness"
        case .confidence: return "Build unshakeable self-belief"
        case .gratitude: return "Cultivate appreciation and joy"
        case .peace: return "Find calm and tranquility"
        case .relationships: return "Strengthen connections with others"
        case .abundance: return "Welcome prosperity and wealth"
        case .creativity: return "Unlock your creative potential"
        case .spiritual: return "Connect with your inner wisdom"
        }
    }
}

// Mood enum for mood selection
enum Mood: String, CaseIterable, Identifiable {
    case energized = "Energized"
    case calm = "Calm"
    case focused = "Focused"
    case happy = "Happy"
    case grateful = "Grateful"
    case confident = "Confident"
    case peaceful = "Peaceful"
    case motivated = "Motivated"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .energized: return "bolt.fill"
        case .calm: return "wind"
        case .focused: return "eye.fill"
        case .happy: return "face.smiling.fill"
        case .grateful: return "hands.sparkles.fill"
        case .confident: return "star.circle.fill"
        case .peaceful: return "leaf.fill"
        case .motivated: return "flame.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .energized: return .moodEnergized
        case .calm: return .moodCalm
        case .focused: return .moodFocused
        case .happy: return .moodHappy
        case .grateful: return .moodGrateful
        case .confident: return .categoryConfidence
        case .peaceful: return .categoryPeace
        case .motivated: return .moodEnergized
        }
    }
    
    var suggestedCategories: [Category] {
        switch self {
        case .energized: return [.motivation, .success, .confidence]
        case .calm: return [.peace, .gratitude, .health]
        case .focused: return [.success, .motivation, .confidence]
        case .happy: return [.gratitude, .love, .relationships]
        case .grateful: return [.gratitude, .abundance, .love]
        case .confident: return [.confidence, .success, .motivation]
        case .peaceful: return [.peace, .gratitude, .health]
        case .motivated: return [.motivation, .success, .abundance]
        }
    }
}

import Foundation
import SwiftUI

struct Affirmation: Identifiable, Codable, Hashable {
    let id = UUID()
    var text: String
    var category: Category
    var isFavorite: Bool = false
    var dateAdded: Date = Date()
    var lastShown: Date?
    var showCount: Int = 0
    var mood: Mood = .calm
    
    // For personalized affirmations
    var isPersonalized: Bool = false
    var personalizedText: String?
    
    func getDisplayText(userName: String = "") -> String {
        if isPersonalized, let personalizedText = personalizedText {
            return personalizedText.replacingOccurrences(of: "[NAME]", with: userName)
        }
        return text.replacingOccurrences(of: "[NAME]", with: userName)
    }
    
    mutating func markAsShown() {
        lastShown = Date()
        showCount += 1
    }
}

// Affirmation collection for different times and moods
struct AffirmationCollection {
    static let morning = [
        Affirmation(text: "Today is full of endless possibilities", category: .motivation),
        Affirmation(text: "I wake up motivated and ready to conquer the day", category: .motivation),
        Affirmation(text: "This morning brings new opportunities for growth", category: .success),
        Affirmation(text: "I am grateful for this beautiful new day", category: .gratitude),
        Affirmation(text: "My energy is renewed with the sunrise", category: .health)
    ]
    
    static let evening = [
        Affirmation(text: "I am proud of all I accomplished today", category: .success),
        Affirmation(text: "Tonight I rest knowing I did my best", category: .peace),
        Affirmation(text: "I release today's stress and welcome peaceful sleep", category: .peace),
        Affirmation(text: "Tomorrow is another chance to grow", category: .motivation),
        Affirmation(text: "I am grateful for today's experiences", category: .gratitude)
    ]
    
    static let motivational = [
        Affirmation(text: "I am capable of achieving anything I set my mind to", category: .motivation),
        Affirmation(text: "Every challenge is an opportunity to grow stronger", category: .motivation),
        Affirmation(text: "I have the power to create positive change", category: .motivation),
        Affirmation(text: "My potential is limitless", category: .motivation),
        Affirmation(text: "I am becoming the best version of myself", category: .motivation)
    ]
    
    static let selfLove = [
        Affirmation(text: "I am worthy of love and respect", category: .love),
        Affirmation(text: "I accept myself completely and unconditionally", category: .love),
        Affirmation(text: "I am enough exactly as I am", category: .love),
        Affirmation(text: "I deserve all the good things life has to offer", category: .love),
        Affirmation(text: "I love and approve of myself", category: .love)
    ]
    
    static let success = [
        Affirmation(text: "Success flows to me easily and effortlessly", category: .success),
        Affirmation(text: "I attract abundance in all areas of my life", category: .success),
        Affirmation(text: "Every day I am moving closer to my goals", category: .success),
        Affirmation(text: "I am a magnet for success and prosperity", category: .success),
        Affirmation(text: "My success inspires others to achieve their dreams", category: .success)
    ]
    
    static let health = [
        Affirmation(text: "My body is healthy, strong, and full of energy", category: .health),
        Affirmation(text: "I make choices that nourish my mind, body, and soul", category: .health),
        Affirmation(text: "Every cell in my body radiates health and vitality", category: .health),
        Affirmation(text: "I am grateful for my body and treat it with respect", category: .health),
        Affirmation(text: "I am becoming healthier and stronger every day", category: .health)
    ]
    
    static let confidence = [
        Affirmation(text: "I radiate confidence and self-assurance", category: .confidence),
        Affirmation(text: "I trust my intuition and make decisions with ease", category: .confidence),
        Affirmation(text: "I am comfortable being my authentic self", category: .confidence),
        Affirmation(text: "My confidence grows stronger every day", category: .confidence),
        Affirmation(text: "I believe in my abilities and express my true self", category: .confidence)
    ]
    
    static let gratitude = [
        Affirmation(text: "I am grateful for all the blessings in my life", category: .gratitude),
        Affirmation(text: "Gratitude fills my heart and guides my actions", category: .gratitude),
        Affirmation(text: "I appreciate the abundance that surrounds me", category: .gratitude),
        Affirmation(text: "Every day I find new reasons to be thankful", category: .gratitude),
        Affirmation(text: "My life is full of things to be grateful for", category: .gratitude)
    ]
    
    static let peace = [
        Affirmation(text: "Peace flows through me like a gentle river", category: .peace),
        Affirmation(text: "I am centered, calm, and at peace", category: .peace),
        Affirmation(text: "I release all worries and embrace tranquility", category: .peace),
        Affirmation(text: "My mind is clear and my heart is peaceful", category: .peace),
        Affirmation(text: "I choose peace over perfection", category: .peace)
    ]
    
    static var all: [Affirmation] {
        morning + evening + motivational + selfLove + success + health + confidence + gratitude + peace
    }
    
    static func getAffirmations(for category: Category) -> [Affirmation] {
        all.filter { $0.category == category }
    }
    
    static func getTimeAppropriateAffirmation() -> Affirmation {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return morning.randomElement() ?? all.randomElement()!
        case 12..<17:
            return motivational.randomElement() ?? all.randomElement()!
        case 17..<22:
            return evening.randomElement() ?? all.randomElement()!
        default:
            return peace.randomElement() ?? all.randomElement()!
        }
    }
}

// Extension for sample affirmations
extension Affirmation {
    static var sampleAffirmations: [Affirmation] {
        return AffirmationCollection.all
    }
}

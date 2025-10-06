import SwiftUI

extension Color {
    // Primary colors
    static let primaryGradientStart = Color(red: 0.98, green: 0.75, blue: 0.65)
    static let primaryGradientEnd = Color(red: 0.95, green: 0.60, blue: 0.75)
    
    // Secondary colors
    static let secondaryGradientStart = Color(red: 0.6, green: 0.7, blue: 0.95)
    static let secondaryGradientEnd = Color(red: 0.8, green: 0.6, blue: 0.9)
    
    // Text colors
    static let textOnGradient = Color.white
    static let textOnGradientSecondary = Color.white.opacity(0.9)
    static let textPrimary = Color(uiColor: .label)
    static let textSecondary = Color(uiColor: .secondaryLabel)
    
    // Background colors
    static let backgroundPrimary = Color(uiColor: .systemBackground)
    static let backgroundSecondary = Color(uiColor: .secondarySystemBackground)
    static let backgroundTertiary = Color(uiColor: .tertiarySystemBackground)
    
    // Card colors
    static let cardBackground = Color.white.opacity(0.1)
    static let cardBorder = Color.white.opacity(0.3)
    static let cardShadow = Color.black.opacity(0.1)
    
    // Accent colors
    static let accentPurple = Color(red: 0.6, green: 0.4, blue: 0.9)
    static let accentPink = Color(red: 0.95, green: 0.5, blue: 0.65)
    static let accentOrange = Color(red: 1.0, green: 0.7, blue: 0.4)
    static let accentBlue = Color(red: 0.4, green: 0.6, blue: 0.95)
    static let accentGreen = Color(red: 0.4, green: 0.8, blue: 0.6)
    
    // Semantic colors
    static let successGreen = Color(red: 0.3, green: 0.85, blue: 0.4)
    static let warningYellow = Color(red: 1.0, green: 0.8, blue: 0.2)
    static let errorRed = Color(red: 0.95, green: 0.3, blue: 0.3)
    
    // Shadow and overlay colors
    static let shadowLight = Color.black.opacity(0.05)
    static let shadowMedium = Color.black.opacity(0.1)
    static let shadowDark = Color.black.opacity(0.2)
    static let overlayLight = Color.white.opacity(0.1)
    static let overlayMedium = Color.white.opacity(0.2)
    static let overlayDark = Color.white.opacity(0.3)
    
    // Glass effect colors
    static let glassTint = Color.white.opacity(0.05)
    static let glassStroke = Color.white.opacity(0.2)
    
    // Premium colors
    static let premiumGold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let premiumGoldDark = Color(red: 0.8, green: 0.67, blue: 0.0)
    
    // Category colors
    static let categoryLove = Color(red: 0.95, green: 0.45, blue: 0.55)
    static let categorySuccess = Color(red: 0.3, green: 0.75, blue: 0.5)
    static let categoryHealth = Color(red: 0.5, green: 0.85, blue: 0.75)
    static let categoryGratitude = Color(red: 0.95, green: 0.7, blue: 0.4)
    static let categoryConfidence = Color(red: 0.7, green: 0.5, blue: 0.95)
    static let categoryPeace = Color(red: 0.6, green: 0.75, blue: 0.9)
    
    // Mood colors
    static let moodEnergized = Color(red: 1.0, green: 0.5, blue: 0.3)
    static let moodCalm = Color(red: 0.7, green: 0.85, blue: 0.95)
    static let moodFocused = Color(red: 0.5, green: 0.4, blue: 0.8)
    static let moodHappy = Color(red: 1.0, green: 0.8, blue: 0.3)
    static let moodGrateful = Color(red: 0.9, green: 0.7, blue: 0.5)
    
    // Dark mode adjusted colors
    static var adaptiveCardBackground: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ?
            UIColor(white: 0.15, alpha: 0.8) :
            UIColor(white: 1.0, alpha: 0.9)
        })
    }
    
    static var adaptiveTextPrimary: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ?
            UIColor.white :
            UIColor.black
        })
    }
    
    static var adaptiveBorder: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ?
            UIColor(white: 1.0, alpha: 0.1) :
            UIColor(white: 0.0, alpha: 0.1)
        })
    }
}

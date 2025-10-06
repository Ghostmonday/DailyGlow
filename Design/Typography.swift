import SwiftUI

// Typography struct for easier access
struct Typography {
    static let h1 = Font.system(size: 32, weight: .bold, design: .rounded)
    static let h2 = Font.system(size: 24, weight: .bold, design: .rounded)
    static let h3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 16, weight: .regular, design: .rounded)
    static let small = Font.system(size: 14, weight: .regular, design: .rounded)
    static let tiny = Font.system(size: 12, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 11, weight: .regular, design: .rounded)
}

extension Font {
    // Affirmation fonts
    static func affirmationTitle() -> Font {
        .system(size: 36, weight: .bold, design: .rounded)
    }
    
    static func affirmationBody() -> Font {
        .system(size: 22, weight: .medium, design: .rounded)
    }
    
    static func affirmationSubtitle() -> Font {
        .system(size: 18, weight: .regular, design: .rounded)
    }
    
    // UI fonts
    static func uiTitle() -> Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }
    
    static func uiHeadline() -> Font {
        .system(size: 20, weight: .semibold, design: .rounded)
    }
    
    static func uiBody() -> Font {
        .system(size: 16, weight: .regular, design: .rounded)
    }
    
    static func uiLabel() -> Font {
        .system(size: 14, weight: .medium, design: .rounded)
    }
    
    static func uiCaption() -> Font {
        .system(size: 12, weight: .regular, design: .rounded)
    }
    
    // Button fonts
    static func buttonLarge() -> Font {
        .system(size: 18, weight: .semibold, design: .rounded)
    }
    
    static func buttonMedium() -> Font {
        .system(size: 16, weight: .semibold, design: .rounded)
    }
    
    static func buttonSmall() -> Font {
        .system(size: 14, weight: .medium, design: .rounded)
    }
    
    // Tab bar font
    static func tabBarItem() -> Font {
        .system(size: 11, weight: .medium, design: .rounded)
    }
    
    // Onboarding fonts
    static func onboardingTitle() -> Font {
        .system(size: 32, weight: .bold, design: .rounded)
    }
    
    static func onboardingSubtitle() -> Font {
        .system(size: 18, weight: .regular, design: .rounded)
    }
    
    // Category fonts
    static func categoryTitle() -> Font {
        .system(size: 16, weight: .semibold, design: .rounded)
    }
    
    static func categoryBadge() -> Font {
        .system(size: 12, weight: .bold, design: .rounded)
    }
    
    // Journal fonts
    static func journalEntry() -> Font {
        .system(size: 16, weight: .regular, design: .serif)
    }
    
    static func journalDate() -> Font {
        .system(size: 12, weight: .medium, design: .rounded)
    }
    
    // Widget fonts
    static func widgetLarge() -> Font {
        .system(size: 24, weight: .bold, design: .rounded)
    }
    
    static func widgetMedium() -> Font {
        .system(size: 18, weight: .semibold, design: .rounded)
    }
    
    static func widgetSmall() -> Font {
        .system(size: 14, weight: .medium, design: .rounded)
    }
    
    // Paywall fonts
    static func paywallTitle() -> Font {
        .system(size: 30, weight: .bold, design: .rounded)
    }
    
    static func paywallFeature() -> Font {
        .system(size: 16, weight: .medium, design: .rounded)
    }
    
    static func paywallPrice() -> Font {
        .system(size: 36, weight: .bold, design: .rounded)
    }
    
    static func paywallPeriod() -> Font {
        .system(size: 14, weight: .regular, design: .rounded)
    }
    
    // Streak fonts
    static func streakNumber() -> Font {
        .system(size: 48, weight: .black, design: .rounded)
    }
    
    static func streakLabel() -> Font {
        .system(size: 14, weight: .semibold, design: .rounded)
    }
}

// Text style modifiers
struct AffirmationTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.affirmationBody())
            .foregroundColor(.textOnGradient)
            .multilineTextAlignment(.center)
            .shadow(color: .shadowMedium, radius: 2, x: 0, y: 2)
            .lineSpacing(4)
    }
}

struct UITitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.uiTitle())
            .foregroundColor(.textPrimary)
    }
}

struct ButtonTextStyle: ViewModifier {
    var size: ButtonSize = .medium
    
    enum ButtonSize {
        case small, medium, large
    }
    
    func body(content: Content) -> some View {
        content
            .font(size == .large ? .buttonLarge() : size == .medium ? .buttonMedium() : .buttonSmall())
            .foregroundColor(.textOnGradient)
    }
}

extension View {
    func affirmationTextStyle() -> some View {
        modifier(AffirmationTextStyle())
    }
    
    func uiTitleStyle() -> some View {
        modifier(UITitleStyle())
    }
    
    func buttonTextStyle(size: ButtonTextStyle.ButtonSize = .medium) -> some View {
        modifier(ButtonTextStyle(size: size))
    }
}

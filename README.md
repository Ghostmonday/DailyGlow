# Daily Glow - Premium Affirmation App 🌟

A beautiful, feature-rich iOS affirmation app built entirely with SwiftUI. Daily Glow helps users cultivate positivity, practice gratitude, and track their personal growth journey through daily affirmations, journaling, and gamification.

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0-green.svg)
![License](https://img.shields.io/badge/License-MIT-purple.svg)

## ✨ Features

### Core Features
- **1000+ Affirmations**: Curated collection across 10 categories
- **Personalized Experience**: Mood-based affirmation recommendations
- **Beautiful UI**: Pure SwiftUI with gradients, glassmorphism, and animations
- **Journal**: Track thoughts, gratitude, and personal growth
- **Favorites**: Save and organize your favorite affirmations
- **Streak Tracking**: Build daily habits with streak rewards
- **Haptic Feedback**: Rich tactile experience throughout the app

### Premium Features
- **Unlimited Affirmations**: Access entire library
- **Custom Themes**: Exclusive gradients and customization
- **Advanced Analytics**: Mood tracking and insights
- **Widget Support**: Beautiful home screen widgets
- **AI Personalization**: Tailored affirmations (coming soon)
- **Sleep Stories**: Bedtime affirmations (coming soon)

### Gamification
- **Achievement System**: 40+ achievements to unlock
- **Point Rewards**: Earn points for daily activities
- **Level Progression**: Advance through levels
- **Category Progress**: Track completion across categories

### Technical Features
- **100% SwiftUI**: No UIKit dependencies
- **No External Assets**: All graphics generated programmatically
- **Offline Support**: Full functionality without internet
- **Widget Extension**: Home screen widgets in 3 sizes
- **Notification System**: Daily reminders with customization
- **Deep Linking**: Support for URL schemes and shortcuts
- **Data Persistence**: Comprehensive storage management

## 📱 Screenshots

| Onboarding | Today Tab | Journal | Achievements |
|------------|-----------|---------|--------------|
| Beautiful onboarding flow | Swipeable affirmation cards | Mood tracking & analytics | Gamification system |

## 🛠 Installation

### Requirements
- Xcode 15.0+
- iOS 16.0+
- Swift 5.9+

### Setup Instructions

1. **Clone the Repository**
```bash
git clone https://github.com/yourusername/dailyglow.git
cd dailyglow
```

2. **Open in Xcode**
```bash
open DailyGlow.xcodeproj
```

3. **Configure Bundle ID**
   - Select the project in Xcode
   - Change Bundle Identifier to your own
   - Update App Group identifier for widgets

4. **Build and Run**
   - Select your target device/simulator
   - Press Cmd+R to build and run

### Widget Extension Setup

1. Add Widget Extension target in Xcode
2. Configure App Groups for data sharing
3. Update widget bundle identifier
4. Add to main app's embedded content

## 📂 Project Structure

```
DailyGlow/
├── DailyGlowApp.swift          # Main app entry point
├── Models/
│   ├── Affirmation.swift       # Core affirmation model
│   ├── Category.swift          # Category definitions
│   ├── UserPreferences.swift   # User settings model
│   └── Achievement.swift       # Gamification models
├── Views/
│   ├── Main/
│   │   ├── ContentView.swift   # Main navigation
│   │   ├── TodayTab.swift      # Daily affirmation view
│   │   ├── FavoritesTab.swift  # Saved affirmations
│   │   ├── JournalTab.swift    # Journal interface
│   │   └── SettingsTab.swift   # App settings
│   ├── Onboarding/
│   │   ├── OnboardingContainer.swift
│   │   └── [Onboarding views...]
│   ├── Paywall/
│   │   └── PaywallView.swift
│   ├── Journal/
│   │   └── JournalAnalyticsView.swift
│   ├── Settings/
│   │   └── AchievementsView.swift
│   └── Widgets/
│       └── WidgetViews.swift
├── Components/
│   ├── AffirmationCard.swift   # Card UI component
│   ├── GlassmorphicCard.swift  # Glass effect component
│   ├── AnimatedBackground.swift # Dynamic backgrounds
│   └── CustomButton.swift      # Button library
├── Services/
│   ├── HapticManager.swift     # Haptic feedback service
│   ├── AffirmationService.swift # Affirmation management
│   └── StorageManager.swift    # Data persistence
└── Design/
    ├── ColorSystem.swift        # Color palette
    ├── Typography.swift         # Font system
    ├── GradientTheme.swift      # Gradient definitions
    └── CustomShapes.swift       # Custom SwiftUI shapes
```

## 🎨 Design System

### Color Palette
- **Primary**: Purple/Pink gradient
- **Secondary**: Blue/Cyan gradient
- **Accent**: Yellow/Orange
- **Semantic**: Adaptive colors for light/dark mode

### Typography
- **Font**: SF Rounded
- **Sizes**: 6 scale system (tiny to h1)
- **Weights**: Regular, Medium, Semibold, Bold

### Components
- **Cards**: Glassmorphic design with blur effects
- **Buttons**: 5 styles (primary, secondary, icon, mood, category)
- **Backgrounds**: Animated gradients and particle effects
- **Shapes**: Waves, blobs, and organic forms

## 🚀 Key Features Implementation

### Swipe Gestures
```swift
// Card swiping with spring animation
.gesture(
    DragGesture()
        .onChanged { value in
            dragOffset = value.translation
            cardRotation = Double(value.translation.width / 20)
        }
        .onEnded { value in
            // Handle swipe action
        }
)
```

### Haptic Feedback
```swift
// Rich haptic patterns
HapticManager.shared.playCardSwipe()
HapticManager.shared.playFavoriteToggle(isFavorited: true)
HapticManager.shared.playStreak()
```

### Data Persistence
```swift
// Comprehensive storage management
storageManager.addJournalEntry(entry)
storageManager.saveUserPreferences()
storageManager.createBackup()
```

### Widget Timeline
```swift
// Dynamic widget updates
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    // Create timeline entries for next 24 hours
}
```

## 📊 Analytics & Tracking

The app tracks:
- Daily active usage
- Affirmations viewed
- Journal entries created
- Mood patterns
- Category preferences
- Streak maintenance
- Achievement progress

## 🔐 Privacy & Security

- **Local Storage**: All data stored on device
- **No Tracking**: No third-party analytics by default
- **Secure Backup**: Encrypted backup/restore
- **Privacy First**: No personal data collection

## 🎯 Monetization

### Subscription Tiers
- **Weekly**: $1.99
- **Monthly**: $4.99 (Most Popular)
- **Yearly**: $39.99 (Best Value)
- **Lifetime**: $99.99

### Premium Features
- Unlimited affirmations
- Custom themes
- Advanced analytics
- Widget customization
- Priority support

## 🛣 Roadmap

### Version 1.1
- [ ] AI-powered personalization
- [ ] Sleep stories feature
- [ ] Social sharing improvements
- [ ] Apple Watch app

### Version 1.2
- [ ] Community features
- [ ] Custom affirmation creation
- [ ] Voice affirmations
- [ ] Meditation integration

### Version 2.0
- [ ] Multi-language support
- [ ] Family sharing
- [ ] Coach marketplace
- [ ] Live sessions

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- SwiftUI community for inspiration
- Design inspiration from Headspace, Calm, and "I Am"
- Beta testers for valuable feedback

## 📧 Contact

- **Developer**: [Your Name]
- **Email**: support@dailyglow.app
- **Website**: [dailyglow.app](https://dailyglow.app)
- **Twitter**: [@dailyglowapp](https://twitter.com/dailyglowapp)

## 🌟 Support

If you find this project helpful, please consider:
- Giving it a ⭐️ on GitHub
- Sharing it with others
- Contributing to the codebase
- Leaving a review on the App Store

---

Built with ❤️ using pure SwiftUI

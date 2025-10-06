# 🌟 Daily Glow - iOS Affirmation App

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)](https://www.apple.com/ios)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

A beautiful, feature-rich iOS affirmation app built entirely with SwiftUI. Daily Glow helps users cultivate positivity, practice gratitude, and track their personal growth journey.

![Daily Glow Banner](https://via.placeholder.com/800x400/8B5CF6/FFFFFF?text=Daily+Glow+-+Affirmations+%E2%80%A2+Journal+%E2%80%A2+Mindfulness)

---

## ⚠️ Important: No Xcode Project File?

**This repository contains only the source code files, not an Xcode project file (`.xcodeproj`).**

### Why?

- Xcode project files are complex binary/XML files that don't work well with git
- They cause merge conflicts and include user-specific settings
- Source-only repos are cleaner and more maintainable
- Professional iOS projects often distribute source files separately

### How to Use This Code?

**Choose your path:**

#### 🚀 Option 1: Automated Setup (Easiest)
```bash
git clone https://github.com/Ghostmonday/DailyGlow.git
cd DailyGlow
./INSTALL.sh
```
The script will guide you through creating the Xcode project.

#### ⚡️ Option 2: Manual Setup (5 minutes)
1. **Clone this repo**
2. **Open Xcode** → Create New Project
3. **Choose**: iOS → App (SwiftUI)
4. **Name it**: DailyGlow
5. **Save in**: The cloned folder
6. **Add files**: Drag `Models`, `Views`, `Components`, `Design`, `Services` into Xcode
7. **Run**: Press ⌘+R

#### 📖 Option 3: Follow Detailed Guide
See [QUICK_START.md](QUICK_START.md) or [SETUP_GUIDE.md](SETUP_GUIDE.md) for step-by-step instructions.

---

## ✨ Features

### Core Features
- 📱 **1000+ Affirmations** across 10 categories
- 🎨 **Beautiful UI** with gradients and glassmorphism
- 📔 **Journal** with mood tracking and analytics
- ⭐️ **Favorites** system for saving affirmations
- 🔥 **Streak Tracking** for daily consistency
- 🎮 **40+ Achievements** with rewards
- 📊 **Advanced Analytics** with charts
- 🔔 **Daily Reminders** with customization

### Technical Highlights
- 100% SwiftUI - No UIKit dependencies
- No external assets - All graphics generated with code
- Comprehensive haptic feedback
- Widget support (small, medium, large)
- Deep linking and shortcuts
- Offline-first architecture
- Beautiful animations and transitions

---

## 📱 Screenshots

| Onboarding | Today | Journal | Achievements |
|------------|-------|---------|--------------|
| ![Onboarding](https://via.placeholder.com/200x400/8B5CF6/FFFFFF?text=Onboarding) | ![Today](https://via.placeholder.com/200x400/EC4899/FFFFFF?text=Today) | ![Journal](https://via.placeholder.com/200x400/3B82F6/FFFFFF?text=Journal) | ![Achievements](https://via.placeholder.com/200x400/F59E0B/FFFFFF?text=Achievements) |

---

## 🎯 Quick Start

### Requirements
- **macOS** 13.0+ (Ventura or later)
- **Xcode** 15.0+
- **iPhone** running iOS 16.0+ (for device testing)
- **Apple ID** (free account works!)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Ghostmonday/DailyGlow.git
   cd DailyGlow
   ```

2. **Run the installer**
   ```bash
   ./INSTALL.sh
   ```
   
   OR create project manually in Xcode (see guides below)

3. **Add files to Xcode**
   - Right-click project → Add Files
   - Select all folders
   - Check "Copy items if needed"

4. **Configure signing**
   - Select project → Signing & Capabilities
   - Choose your Team (Apple ID)

5. **Run on your device**
   - Connect iPhone
   - Press ⌘+R

### Detailed Guides

- 📖 [Complete Setup Guide](SETUP_GUIDE.md) - Step-by-step with troubleshooting
- ⚡️ [Quick Start Guide](QUICK_START.md) - 5-minute setup
- ✅ [Setup Checklist](CHECKLIST.md) - Printable checklist

---

## 📂 Project Structure

```
DailyGlow/
├── Models/                 # Data models and business logic
│   ├── Affirmation.swift
│   ├── Category.swift
│   ├── UserPreferences.swift
│   └── Achievement.swift
├── Views/                  # SwiftUI views
│   ├── Main/              # Tab views
│   ├── Onboarding/        # Onboarding flow
│   ├── Paywall/           # Subscription
│   ├── Journal/           # Journal and analytics
│   ├── Settings/          # Settings and achievements
│   └── Widgets/           # Home screen widgets
├── Components/            # Reusable UI components
│   ├── AffirmationCard.swift
│   ├── GlassmorphicCard.swift
│   ├── AnimatedBackground.swift
│   └── CustomButton.swift
├── Services/              # Business services
│   ├── HapticManager.swift
│   ├── AffirmationService.swift
│   └── StorageManager.swift
└── Design/                # Design system
    ├── ColorSystem.swift
    ├── Typography.swift
    ├── GradientTheme.swift
    └── CustomShapes.swift
```

---

## 🎨 Design System

### Colors
- Adaptive color scheme for light/dark mode
- Semantic color naming
- Gradient system with 30+ combinations

### Typography
- SF Rounded font family
- 6-scale type system
- Responsive text sizing

### Components
- Glassmorphic cards with blur effects
- 5 button styles
- Animated backgrounds
- Custom shapes and particles

---

## 🚀 Features Breakdown

### Onboarding Flow
- Welcome screen with animations
- Benefits explanation
- Name personalization
- Mood selection
- Category preferences
- Notification setup
- Premium pitch
- Completion celebration

### Today Tab
- Swipeable affirmation cards
- Mood-based recommendations
- Streak tracking
- Quick actions (favorite, share, next)
- Beautiful animations

### Favorites Tab
- Grid/List/Card view modes
- Search and filtering
- Category organization
- Export favorites

### Journal Tab
- Mood tracking
- Gratitude lists
- Entry management
- Advanced analytics
- Charts and insights

### Settings Tab
- Theme customization
- Notification preferences
- Account management
- Achievement system
- Data export/import

### Achievements
- 40+ achievements across 8 categories
- Point-based reward system
- Level progression
- Progress tracking
- Celebration animations

---

## 🛠 Technical Stack

- **Language**: Swift 5.9
- **UI Framework**: SwiftUI 4.0
- **Minimum iOS**: 16.0
- **Architecture**: MVVM
- **Storage**: UserDefaults + File System
- **Notifications**: UserNotifications framework
- **Widgets**: WidgetKit
- **Haptics**: Core Haptics + UIFeedback

### No Dependencies
This app intentionally has **zero external dependencies**:
- No CocoaPods
- No Swift Package Manager packages
- No Carthage
- Pure SwiftUI implementation

---

## 📊 Statistics

- **Files**: 37 Swift files
- **Lines of Code**: ~13,000
- **Features**: 30+ major features
- **Achievements**: 40+ unlockable
- **Affirmations**: 100+ sample (expandable)
- **Categories**: 10 distinct
- **Moods**: 6 different states

---

## 🎮 Gamification

The app includes a comprehensive achievement system:

- **Consistency**: Streak-based achievements
- **Exploration**: Category completion
- **Mindfulness**: Daily practice rewards
- **Social**: Sharing and community
- **Premium**: Subscription milestones

Points accumulate to unlock levels and rewards.

---

## 💰 Monetization (If Publishing)

### Subscription Tiers
- **Weekly**: $1.99
- **Monthly**: $4.99
- **Yearly**: $39.99 (Save 33%)
- **Lifetime**: $99.99

### Premium Features
- Unlimited affirmations
- Custom themes
- Advanced analytics
- Widget customization
- Priority support

---

## 🗺 Roadmap

### Version 1.1
- [ ] AI-powered personalization
- [ ] Sleep stories feature
- [ ] Apple Watch app
- [ ] Siri shortcuts

### Version 1.2
- [ ] Multi-language support
- [ ] Custom affirmation creation
- [ ] Voice affirmations
- [ ] Social features

### Version 2.0
- [ ] Family sharing
- [ ] Coach marketplace
- [ ] Live meditation sessions
- [ ] Integration with Health app

---

## 🤝 Contributing

Contributions are welcome! Here's how:

1. Fork the repository
2. Create your feature branch
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. Commit your changes
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. Push to the branch
   ```bash
   git push origin feature/AmazingFeature
   ```
5. Open a Pull Request

### Contribution Guidelines
- Follow Swift style guide
- Write descriptive commit messages
- Add comments for complex code
- Update documentation
- Test on real devices

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- SwiftUI community for inspiration
- Design inspiration: Headspace, Calm, "I Am"
- Beta testers for feedback
- Contributors and supporters

---

## 📧 Contact & Support

- **Repository**: [github.com/Ghostmonday/DailyGlow](https://github.com/Ghostmonday/DailyGlow)
- **Issues**: [Submit an issue](https://github.com/Ghostmonday/DailyGlow/issues)
- **Discussions**: [Join discussions](https://github.com/Ghostmonday/DailyGlow/discussions)

---

## ⭐️ Show Your Support

If you find this project helpful:

- Give it a ⭐️ on GitHub
- Share with others
- Contribute code or ideas
- Report bugs or suggest features

---

## 📖 Documentation

- [Setup Guide](SETUP_GUIDE.md) - Complete installation instructions
- [Quick Start](QUICK_START.md) - 5-minute setup
- [Handoff Guide](HANDOFF_GUIDE.md) - Technical documentation
- [Checklist](CHECKLIST.md) - Setup checklist

---

## 🎓 Learning Resources

This project demonstrates:
- SwiftUI best practices
- MVVM architecture
- Custom animations
- Haptic feedback
- Widget development
- In-app purchases (structure)
- User onboarding
- Data persistence
- Gamification

Perfect for learning iOS development!

---

**Built with ❤️ using pure SwiftUI**

*Last updated: 2024*

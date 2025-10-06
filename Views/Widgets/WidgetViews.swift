//
//  WidgetViews.swift
//  DailyGlow
//
//  Widget views for home screen widgets
//

import SwiftUI
import WidgetKit

// MARK: - Widget Entry
struct AffirmationEntry: TimelineEntry {
    let date: Date
    let affirmation: Affirmation
    let userName: String
    let streakCount: Int
    let mood: Mood
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: AffirmationEntry
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: GradientTheme.getGradient(for: entry.mood.timeOfDay),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Glass overlay
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            // Content
            VStack(spacing: 8) {
                // Header
                HStack {
                    Image(systemName: "sun.max.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Spacer()
                    
                    if entry.streakCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                            Text("\(entry.streakCount)")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.orange)
                    }
                }
                
                // Affirmation text
                Text(entry.affirmation.text)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(4)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                
                Spacer(minLength: 0)
                
                // Category
                Text(entry.affirmation.category.displayName)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
        }
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let entry: AffirmationEntry
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = entry.userName.isEmpty ? "" : ", \(entry.userName)"
        
        switch hour {
        case 5..<12:
            return "Good morning\(name)"
        case 12..<17:
            return "Good afternoon\(name)"
        case 17..<22:
            return "Good evening\(name)"
        default:
            return "Good night\(name)"
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: GradientTheme.getGradient(for: entry.mood.timeOfDay),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Content
            HStack(spacing: 16) {
                // Left side - Affirmation
                VStack(alignment: .leading, spacing: 12) {
                    // Header
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .font(.body)
                            .foregroundColor(.yellow)
                        
                        Text("Daily Glow")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    
                    // Affirmation
                    Text(entry.affirmation.text)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer(minLength: 0)
                    
                    // Footer
                    HStack {
                        Label(entry.affirmation.category.displayName, systemImage: entry.affirmation.category.icon)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text(entry.affirmation.mood.rawValue.capitalized)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // Right side - Stats
                VStack(spacing: 16) {
                    // Greeting
                    Text(greeting.replacingOccurrences(of: ", \(entry.userName)", with: ""))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    if !entry.userName.isEmpty {
                        Text(entry.userName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Streak
                    if entry.streakCount > 0 {
                        VStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.title3)
                                .foregroundColor(.orange)
                            
                            Text("\(entry.streakCount)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("day streak")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: 80)
            }
            .padding()
            
            // Glass overlay
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

// MARK: - Large Widget View
struct LargeWidgetView: View {
    let entry: AffirmationEntry
    
    var body: some View {
        ZStack {
            // Background gradient with animation
            LinearGradient(
                colors: GradientTheme.getGradient(for: entry.mood.timeOfDay),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Content
            VStack(spacing: 20) {
                // Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "sun.max.fill")
                            .font(.title3)
                            .foregroundColor(.yellow)
                        
                        Text("Daily Glow")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Date
                    Text(Date(), style: .date)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Main affirmation card
                VStack(spacing: 16) {
                    // Category badge
                    HStack {
                        Label(entry.affirmation.category.displayName, systemImage: entry.affirmation.category.icon)
                            .font(.caption)
                            .foregroundColor(entry.affirmation.category.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(entry.affirmation.category.color.opacity(0.2))
                            )
                        
                        Spacer()
                    }
                    
                    // Affirmation text
                    Text(entry.affirmation.text)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    
                    // Mood indicator
                    HStack {
                        Image(systemName: entry.affirmation.mood.icon)
                            .foregroundColor(entry.affirmation.mood.color)
                        Text(entry.affirmation.mood.rawValue.capitalized)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Stats row
                HStack(spacing: 20) {
                    // Streak
                    if entry.streakCount > 0 {
                        StatWidget(
                            icon: "flame.fill",
                            value: "\(entry.streakCount)",
                            label: "Day Streak",
                            color: .orange
                        )
                    }
                    
                    // Time
                    StatWidget(
                        icon: "clock",
                        value: Date().formatted(date: .omitted, time: .shortened),
                        label: "Last Update",
                        color: .blue
                    )
                    
                    // User
                    if !entry.userName.isEmpty {
                        StatWidget(
                            icon: "person.fill",
                            value: entry.userName,
                            label: "Keep Going!",
                            color: .green
                        )
                    }
                }
                
                // Call to action
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.caption)
                    Text("Tap to open Daily Glow")
                        .font(.caption)
                }
                .foregroundColor(.white.opacity(0.6))
            }
            .padding()
        }
    }
}

// MARK: - Stat Widget Component
struct StatWidget: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(color)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Widget Provider
struct AffirmationProvider: TimelineProvider {
    func placeholder(in context: Context) -> AffirmationEntry {
        AffirmationEntry(
            date: Date(),
            affirmation: Affirmation.sampleAffirmations.first!,
            userName: "User",
            streakCount: 7,
            mood: .calm
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AffirmationEntry) -> Void) {
        let entry = AffirmationEntry(
            date: Date(),
            affirmation: Affirmation.sampleAffirmations.randomElement()!,
            userName: UserDefaults.standard.string(forKey: "userName") ?? "",
            streakCount: UserDefaults.standard.integer(forKey: "streakCount"),
            mood: .calm
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AffirmationEntry>) -> Void) {
        var entries: [AffirmationEntry] = []
        let currentDate = Date()
        
        // Create timeline entries for the next 24 hours (update every 6 hours)
        for hourOffset in stride(from: 0, to: 24, by: 6) {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            
            // Get appropriate affirmation based on time
            let affirmation = getTimeBasedAffirmation(for: entryDate)
            
            let entry = AffirmationEntry(
                date: entryDate,
                affirmation: affirmation,
                userName: UserDefaults.standard.string(forKey: "userName") ?? "",
                streakCount: UserDefaults.standard.integer(forKey: "streakCount"),
                mood: getMoodForTime(entryDate)
            )
            
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func getTimeBasedAffirmation(for date: Date) -> Affirmation {
        let hour = Calendar.current.component(.hour, from: date)
        let mood: Mood = {
            switch hour {
            case 5..<10: return .energized
            case 10..<14: return .motivated
            case 14..<18: return .focused
            case 18..<22: return .calm
            default: return .peaceful
            }
        }()
        
        let affirmations = Affirmation.sampleAffirmations.filter { $0.mood == mood }
        return affirmations.randomElement() ?? Affirmation.sampleAffirmations.first!
    }
    
    private func getMoodForTime(_ date: Date) -> Mood {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<10: return .energized
        case 10..<14: return .motivated
        case 14..<18: return .focused
        case 18..<22: return .calm
        default: return .peaceful
        }
    }
}

// MARK: - Widget Configuration
struct DailyGlowWidget: Widget {
    let kind: String = "DailyGlowWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AffirmationProvider()) { entry in
            DailyGlowWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Glow")
        .description("Your daily dose of positivity")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Entry View
struct DailyGlowWidgetView: View {
    var entry: AffirmationEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Bundle
//@main
struct DailyGlowWidgetBundle: WidgetBundle {
    var body: some Widget {
        DailyGlowWidget()
    }
}

// MARK: - Preview
@available(iOS 17.0, *)
#Preview(as: .systemSmall) {
    DailyGlowWidget()
} timeline: {
    AffirmationEntry(
        date: Date(),
        affirmation: Affirmation.sampleAffirmations.first!,
        userName: "Sarah",
        streakCount: 7,
        mood: .calm
    )
}

@available(iOS 17.0, *)
#Preview(as: .systemMedium) {
    DailyGlowWidget()
} timeline: {
    AffirmationEntry(
        date: Date(),
        affirmation: Affirmation.sampleAffirmations.first!,
        userName: "Sarah",
        streakCount: 7,
        mood: .energized
    )
}

@available(iOS 17.0, *)
#Preview(as: .systemLarge) {
    DailyGlowWidget()
} timeline: {
    AffirmationEntry(
        date: Date(),
        affirmation: Affirmation.sampleAffirmations.first!,
        userName: "Sarah",
        streakCount: 7,
        mood: .peaceful
    )
}

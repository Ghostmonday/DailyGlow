//
//  AchievementsView.swift
//  DailyGlow
//
//  Display user achievements, progress, and rewards
//

import SwiftUI

struct AchievementsView: View {
    @StateObject private var achievementManager = AchievementManager()
    @State private var selectedCategory: AchievementCategory?
    @State private var showingAchievementDetail: Achievement?
    @State private var animateProgress = false
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Computed Properties
    private var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievementManager.achievements.filter { $0.category == category }
        }
        return achievementManager.achievements
    }
    
    private var unlockedAchievements: [Achievement] {
        filteredAchievements.filter { $0.isUnlocked }
    }
    
    private var lockedAchievements: [Achievement] {
        filteredAchievements.filter { !$0.isUnlocked }
            .sorted { $0.progressPercentage > $1.progressPercentage }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.1, blue: 0.3),
                        Color(red: 0.25, green: 0.15, blue: 0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with level and points
                        headerSection
                        
                        // Progress overview
                        progressOverview
                        
                        // Category filter
                        categoryFilter
                        
                        // Next achievements to unlock
                        if !achievementManager.nextAchievementsToUnlock().isEmpty {
                            nextToUnlockSection
                        }
                        
                        // Unlocked achievements
                        if !unlockedAchievements.isEmpty {
                            unlockedSection
                        }
                        
                        // Locked achievements
                        if !lockedAchievements.isEmpty {
                            lockedSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .sheet(item: $showingAchievementDetail) { achievement in
            AchievementDetailView(achievement: achievement)
        }
        .sheet(isPresented: $achievementManager.showAchievementUnlocked) {
            if let achievement = achievementManager.currentUnlockedAchievement {
                AchievementUnlockedView(achievement: achievement)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateProgress = true
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Level indicator
            ZStack {
                // Outer ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .pink.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 10
                    )
                    .frame(width: 120, height: 120)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: animateProgress ? achievementManager.levelProgress() : 0)
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.2), value: animateProgress)
                
                // Level number
                VStack(spacing: 4) {
                    Text("LEVEL")
                        .font(Typography.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(achievementManager.level)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            
            // Points and next level
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(achievementManager.totalPoints) Points")
                        .font(Typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Text("\(achievementManager.pointsToNextLevel()) points to level \(achievementManager.level + 1)")
                    .font(Typography.small)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Achievement stats
            HStack(spacing: 30) {
                VStack(spacing: 4) {
                    Text("\(achievementManager.unlockedCount())")
                        .font(Typography.h3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Unlocked")
                        .font(Typography.tiny)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack(spacing: 4) {
                    Text("\(achievementManager.achievements.count)")
                        .font(Typography.h3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Total")
                        .font(Typography.tiny)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack(spacing: 4) {
                    Text("\(Int(Double(achievementManager.unlockedCount()) / Double(achievementManager.achievements.count) * 100))%")
                        .font(Typography.h3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Complete")
                        .font(Typography.tiny)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Progress Overview
    private var progressOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Progress")
                .font(Typography.h3)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    CategoryProgressRow(
                        category: category,
                        progress: achievementManager.progressByCategory()[category] ?? 0,
                        animate: animateProgress
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All categories
                FilterChip(
                    title: "All",
                    icon: "square.grid.3x3.fill",
                    color: .white,
                    isSelected: selectedCategory == nil
                ) {
                    withAnimation {
                        selectedCategory = nil
                    }
                }
                
                // Individual categories
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        icon: category.icon,
                        color: category.color,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Next to Unlock Section
    private var nextToUnlockSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Almost There!")
                .font(Typography.h3)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(achievementManager.nextAchievementsToUnlock()) { achievement in
                    NextToUnlockCard(achievement: achievement) {
                        showingAchievementDetail = achievement
                    }
                }
            }
        }
    }
    
    // MARK: - Unlocked Section
    private var unlockedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Unlocked")
                    .font(Typography.h3)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(unlockedAchievements.count)")
                    .font(Typography.body)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(unlockedAchievements) { achievement in
                    Button {
                        showingAchievementDetail = achievement
                        HapticManager.shared.impact(.light)
                    } label: {
                        AchievementBadge(achievement: achievement, size: 70)
                    }
                }
            }
        }
    }
    
    // MARK: - Locked Section
    private var lockedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Locked")
                    .font(Typography.h3)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(lockedAchievements.count)")
                    .font(Typography.body)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(lockedAchievements) { achievement in
                    Button {
                        showingAchievementDetail = achievement
                        HapticManager.shared.impact(.light)
                    } label: {
                        AchievementBadge(achievement: achievement, size: 70)
                    }
                }
            }
        }
    }
}

// MARK: - Category Progress Row
struct CategoryProgressRow: View {
    let category: AchievementCategory
    let progress: Double
    let animate: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.body)
                .foregroundColor(category.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.rawValue)
                    .font(Typography.small)
                    .foregroundColor(.white)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(category.color)
                            .frame(width: animate ? geometry.size.width * progress : 0)
                            .animation(.easeInOut(duration: 0.8), value: animate)
                    }
                }
                .frame(height: 8)
            }
            
            Text("\(Int(progress * 100))%")
                .font(Typography.small)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 40)
        }
    }
}

// MARK: - Next to Unlock Card
struct NextToUnlockCard: View {
    let achievement: Achievement
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                AchievementBadge(achievement: achievement, size: 60)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(achievement.title)
                        .font(Typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(achievement.description)
                        .font(Typography.small)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(achievement.category.color)
                                .frame(width: geometry.size.width * achievement.progressPercentage)
                        }
                    }
                    .frame(height: 6)
                    
                    Text("\(achievement.progress)/\(achievement.requiredValue)")
                        .font(Typography.tiny)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(achievement.category.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(achievement.category.color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(Typography.small)
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? color.opacity(0.3) : Color.white.opacity(0.1))
                    .overlay(
                        Capsule()
                            .stroke(color.opacity(isSelected ? 0.6 : 0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Achievement Detail View
struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) var dismiss
    @State private var showingShare = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        achievement.category.color.opacity(0.3),
                        achievement.category.color.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Content
                VStack(spacing: 30) {
                    // Badge
                    AchievementBadge(achievement: achievement, size: 150)
                        .padding(.top, 40)
                    
                    // Title and description
                    VStack(spacing: 12) {
                        Text(achievement.title)
                            .font(Typography.h2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(achievement.description)
                            .font(Typography.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    // Stats
                    VStack(spacing: 20) {
                        // Progress
                        VStack(spacing: 8) {
                            Text("Progress")
                                .font(Typography.caption)
                                .foregroundColor(.white.opacity(0.6))
                                .textCase(.uppercase)
                            
                            Text("\(achievement.progress) / \(achievement.requiredValue)")
                                .font(Typography.h3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            // Progress bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.2))
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(achievement.category.color)
                                        .frame(width: geometry.size.width * achievement.progressPercentage)
                                }
                            }
                            .frame(height: 12)
                            .padding(.horizontal, 40)
                            
                            Text("\(Int(achievement.progressPercentage * 100))% Complete")
                                .font(Typography.small)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        // Reward
                        HStack(spacing: 40) {
                            VStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                                
                                Text("\(achievement.rewardPoints)")
                                    .font(Typography.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("Points")
                                    .font(Typography.tiny)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            if achievement.isUnlocked, let unlockedDate = achievement.unlockedDate {
                                VStack(spacing: 8) {
                                    Image(systemName: "calendar")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                    
                                    Text(unlockedDate, style: .date)
                                        .font(Typography.small)
                                        .foregroundColor(.white)
                                    
                                    Text("Unlocked")
                                        .font(Typography.tiny)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Actions
                    if achievement.isUnlocked {
                        Button {
                            showingShare = true
                        } label: {
                            Label("Share Achievement", systemImage: "square.and.arrow.up")
                                .font(Typography.body)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                )
                        }
                        .padding(.horizontal, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingShare) {
            ShareSheet(items: [
                "🏆 I just unlocked \"\(achievement.title)\" in Daily Glow! \(achievement.description)",
                URL(string: "https://dailyglow.app")!
            ])
        }
    }
}

// MARK: - Achievement Unlocked View
struct AchievementUnlockedView: View {
    let achievement: Achievement
    @Environment(\.dismiss) var dismiss
    @State private var showContent = false
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // Content
            VStack(spacing: 30) {
                // Title
                VStack(spacing: 8) {
                    Text("Achievement Unlocked!")
                        .font(Typography.h2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0)
                    
                    Text("+\(achievement.rewardPoints) Points")
                        .font(Typography.body)
                        .foregroundColor(.yellow)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0)
                }
                
                // Badge
                AchievementBadge(achievement: achievement, size: 120)
                    .scaleEffect(showContent ? 1.0 : 0.3)
                    .rotationEffect(.degrees(showContent ? 0 : -180))
                    .opacity(showContent ? 1.0 : 0)
                
                // Achievement details
                VStack(spacing: 12) {
                    Text(achievement.title)
                        .font(Typography.h3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(achievement.description)
                        .font(Typography.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .opacity(showContent ? 1.0 : 0)
                
                // Continue button
                Button {
                    dismiss()
                } label: {
                    Text("Awesome!")
                        .font(Typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: 200)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        )
                }
                .scaleEffect(showContent ? 1.0 : 0.8)
                .opacity(showContent ? 1.0 : 0)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: [
                                achievement.category.color.opacity(0.9),
                                achievement.category.color.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .padding(40)
            .scaleEffect(showContent ? 1.0 : 0.8)
            
            // Confetti effect
            if showConfetti {
                ConfettiView()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                showContent = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showConfetti = true
                HapticManager.shared.playStreak()
            }
        }
    }
}

// MARK: - Simple Confetti View
struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50) { _ in
                ConfettiPiece()
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiPiece: View {
    @State private var position = CGPoint(x: CGFloat.random(in: -200...200), y: -400)
    @State private var opacity: Double = 1
    let color = [Color.yellow, .orange, .pink, .purple, .blue, .green].randomElement()!
    let size = CGFloat.random(in: 8...16)
    let rotation = Double.random(in: 0...360)
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .opacity(opacity)
            .onAppear {
                withAnimation(.linear(duration: 2.5)) {
                    position.y = UIScreen.main.bounds.height + 100
                    opacity = 0
                }
            }
    }
}

// MARK: - Preview
#Preview {
    AchievementsView()
}

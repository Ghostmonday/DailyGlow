//
//  TodayTab.swift
//  DailyGlow
//
//  Main tab showing today's affirmation with swipe interactions
//

import SwiftUI

struct TodayTab: View {
    // MARK: - Environment
    @EnvironmentObject var affirmationService: AffirmationService
    @StateObject private var hapticManager = HapticManager.shared
    
    // MARK: - State
    @State private var currentAffirmationIndex = 0
    @State private var dragOffset: CGSize = .zero
    @State private var cardRotation: Double = 0
    @State private var showShareSheet = false
    @State private var showCategoryPicker = false
    @State private var selectedMood: Mood = .calm
    @State private var affirmationStack: [Affirmation] = []
    @State private var isLoading = false
    @State private var showStreakCelebration = false
    
    // User preferences
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("streakCount") private var streakCount: Int = 0
    
    // MARK: - Computed Properties
    private var currentAffirmation: Affirmation? {
        guard currentAffirmationIndex < affirmationStack.count else { return nil }
        return affirmationStack[currentAffirmationIndex]
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = userName.isEmpty ? "" : ", \(userName)"
        
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
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Content
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                // Mood selector
                moodSelector
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Affirmation card stack
                ZStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                    } else {
                        cardStackView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
                
                // Action buttons
                actionButtons
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
            }
            
            // Streak celebration overlay
            if showStreakCelebration {
                streakCelebrationView
            }
        }
        .onAppear {
            loadAffirmations()
            checkStreak()
        }
        .sheet(isPresented: $showShareSheet) {
            if let affirmation = currentAffirmation {
                ShareSheet(items: [createShareText(for: affirmation)])
            }
        }
        .sheet(isPresented: $showCategoryPicker) {
            CategoryPickerSheet(selectedMood: $selectedMood) {
                loadAffirmationsForMood()
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greeting)
                        .font(Typography.h2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(Date(), style: .date)
                        .font(Typography.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Streak indicator
                if streakCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                        Text("\(streakCount)")
                            .font(Typography.body)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .onTapGesture {
                        showStreakCelebration = true
                    }
                }
            }
        }
    }
    
    // MARK: - Mood Selector
    private var moodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    MoodChip(
                        mood: mood,
                        isSelected: selectedMood == mood,
                        action: {
                            selectedMood = mood
                            HapticManager.shared.selection()
                            loadAffirmationsForMood()
                        }
                    )
                }
                
                // Category picker button
                Button {
                    showCategoryPicker = true
                    HapticManager.shared.impact(.light)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.grid.2x2")
                        Text("Categories")
                    }
                    .font(Typography.small)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
    
    // MARK: - Card Stack View
    private var cardStackView: some View {
        ZStack {
            // Background cards preview
            ForEach(Array(affirmationStack.enumerated()), id: \.element.id) { index, affirmation in
                if index >= currentAffirmationIndex && index < currentAffirmationIndex + 3 {
                    affirmationCard(
                        affirmation: affirmation,
                        index: index - currentAffirmationIndex
                    )
                }
            }
        }
    }
    
    private func affirmationCard(affirmation: Affirmation, index: Int) -> some View {
        AffirmationCard(
            affirmation: affirmation,
            isFavorite: affirmationService.isFavorite(affirmation)
        )
        .scaleEffect(1 - (CGFloat(index) * 0.05))
        .offset(y: CGFloat(index) * 10)
        .opacity(index == 0 ? 1.0 : 0.8)
        .zIndex(Double(3 - index))
        .offset(index == 0 ? dragOffset : .zero)
        .rotationEffect(.degrees(index == 0 ? cardRotation : 0))
        .gesture(index == 0 ? dragGesture : nil)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: dragOffset)
    }
    
    // MARK: - Drag Gesture
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
                cardRotation = Double(value.translation.width / 20)
            }
            .onEnded { value in
                let threshold: CGFloat = 100
                
                if abs(value.translation.width) > threshold {
                    // Swipe action
                    withAnimation(.spring()) {
                        dragOffset = CGSize(
                            width: value.translation.width > 0 ? 500 : -500,
                            height: value.translation.height
                        )
                    }
                    
                    // Haptic feedback
                    HapticManager.shared.playCardSwipe()
                    
                    // Handle swipe direction
                    if value.translation.width > 0 {
                        // Swiped right - favorite
                        if let affirmation = currentAffirmation {
                            affirmationService.toggleFavorite(affirmation)
                        }
                    }
                    
                    // Move to next affirmation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        moveToNextAffirmation()
                    }
                } else {
                    // Spring back
                    withAnimation(.spring()) {
                        dragOffset = .zero
                        cardRotation = 0
                    }
                }
            }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 30) {
            // Previous button
            Button {
                moveToPreviousAffirmation()
            } label: {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.system(size: 44))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.white.opacity(0.8))
            }
            .disabled(currentAffirmationIndex == 0)
            .opacity(currentAffirmationIndex == 0 ? 0.3 : 1.0)
            
            // Favorite button
            Button {
                if let affirmation = currentAffirmation {
                    affirmationService.toggleFavorite(affirmation)
                }
            } label: {
                Image(systemName: currentAffirmation.map { affirmationService.isFavorite($0) } ?? false ? "heart.fill" : "heart")
                    .font(.system(size: 54))
                    .foregroundStyle(
                        currentAffirmation.map { affirmationService.isFavorite($0) } ?? false ?
                        Color.pink : Color.white.opacity(0.8)
                    )
                    .animation(.spring(), value: currentAffirmation.map { affirmationService.isFavorite($0) })
            }
            
            // Share button
            Button {
                showShareSheet = true
                HapticManager.shared.impact(.light)
            } label: {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 44))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.white.opacity(0.8))
            }
        }
    }
    
    // MARK: - Streak Celebration View
    private var streakCelebrationView: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showStreakCelebration = false
                    }
                }
            
            VStack(spacing: 20) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                    .scaleEffect(showStreakCelebration ? 1.0 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showStreakCelebration)
                
                VStack(spacing: 8) {
                    Text("\(streakCount) Day Streak!")
                        .font(Typography.h1)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("You're doing amazing!")
                        .font(Typography.body)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                CustomButton(
                    title: "Continue",
                    style: .primary,
                    icon: "arrow.right"
                ) {
                    withAnimation {
                        showStreakCelebration = false
                    }
                }
                .frame(maxWidth: 200)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
            )
            .scaleEffect(showStreakCelebration ? 1.0 : 0.8)
            .opacity(showStreakCelebration ? 1.0 : 0.0)
            .animation(.spring(), value: showStreakCelebration)
        }
    }
    
    // MARK: - Helper Methods
    private func loadAffirmations() {
        isLoading = true
        
        // Load today's affirmation if available
        if let todayAffirmation = affirmationService.todayAffirmation {
            affirmationStack = [todayAffirmation]
        }
        
        // Add recommendations
        let recommendations = affirmationService.getRecommendedAffirmations(limit: 10)
        affirmationStack.append(contentsOf: recommendations)
        
        isLoading = false
    }
    
    private func loadAffirmationsForMood() {
        isLoading = true
        
        let moodAffirmations = affirmationService.getAffirmations(for: selectedMood, limit: 10)
        affirmationStack = moodAffirmations
        currentAffirmationIndex = 0
        
        withAnimation {
            dragOffset = .zero
            cardRotation = 0
        }
        
        isLoading = false
    }
    
    private func moveToNextAffirmation() {
        if currentAffirmationIndex < affirmationStack.count - 1 {
            currentAffirmationIndex += 1
            dragOffset = .zero
            cardRotation = 0
            
            // Mark as viewed
            if let affirmation = currentAffirmation {
                affirmationService.viewAffirmation(affirmation)
            }
        } else {
            // Load more affirmations
            loadAffirmations()
        }
    }
    
    private func moveToPreviousAffirmation() {
        if currentAffirmationIndex > 0 {
            currentAffirmationIndex -= 1
            dragOffset = .zero
            cardRotation = 0
            HapticManager.shared.impact(.light)
        }
    }
    
    private func checkStreak() {
        affirmationService.checkInToday()
        
        // Show celebration for milestone streaks
        if streakCount == 7 || streakCount == 30 || streakCount == 100 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showStreakCelebration = true
                HapticManager.shared.playStreak()
            }
        }
    }
    
    private func createShareText(for affirmation: Affirmation) -> String {
        """
        ✨ Daily Affirmation ✨
        
        "\(affirmation.text)"
        
        Category: \(affirmation.category.displayName)
        Mood: \(affirmation.mood.rawValue.capitalized)
        
        Shared from Daily Glow 🌟
        """
    }
}

// MARK: - Supporting Views
struct MoodChip: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: mood.icon)
                Text(mood.rawValue.capitalized)
            }
            .font(Typography.small)
            .fontWeight(isSelected ? .semibold : .medium)
            .foregroundColor(isSelected ? .white : .white.opacity(0.8))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? mood.color.opacity(0.3) : .ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(
                                isSelected ? mood.color.opacity(0.5) : Color.white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
    }
}

struct CategoryPickerSheet: View {
    @Binding var selectedMood: Mood
    let onDismiss: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Category.allCases, id: \.self) { category in
                        CategoryRow(category: category) {
                            // Handle category selection
                            dismiss()
                            onDismiss()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(Color.backgroundPrimary)
        }
    }
}

struct CategoryRow: View {
    let category: Category
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(category.color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.displayName)
                        .font(Typography.body)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                    
                    Text("\(category.sampleAffirmations.count) affirmations")
                        .font(Typography.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.backgroundSecondary)
            )
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
#Preview {
    TodayTab()
        .environmentObject(AffirmationService())
}
//
//  MoodSelectorView.swift
//  DailyGlow
//
//  Select current mood for personalized affirmations
//

import SwiftUI

struct MoodSelectorView: View {
    @Binding var selectedMood: Mood
    @State private var animatedMoods: Set<Mood> = []
    @State private var pulseAnimation = false
    
    let moodGrid = [
        [Mood.energized, Mood.calm],
        [Mood.focused, Mood.peaceful],
        [Mood.motivated, Mood.grateful]
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Header
            VStack(spacing: 16) {
                Text("How are you feeling today?")
                    .font(Typography.h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("We'll customize your affirmations based on your mood")
                    .font(Typography.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            // Mood grid
            VStack(spacing: 20) {
                ForEach(Array(moodGrid.enumerated()), id: \.offset) { rowIndex, row in
                    HStack(spacing: 20) {
                        ForEach(row, id: \.self) { mood in
                            MoodCard(
                                mood: mood,
                                isSelected: selectedMood == mood,
                                isAnimated: animatedMoods.contains(mood)
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    selectedMood = mood
                                }
                                HapticManager.shared.selection()
                            }
                            .onAppear {
                                let delay = Double(rowIndex) * 0.1 + Double(row.firstIndex(of: mood) ?? 0) * 0.1
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                        animatedMoods.insert(mood)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 30)
            
            // Selected mood description
            if selectedMood != .calm {
                MoodDescription(mood: selectedMood)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            }
            
            Spacer()
            
            // Tip
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .scaleEffect(pulseAnimation ? 1.1 : 0.9)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                        value: pulseAnimation
                    )
                
                Text("You can change this anytime in settings")
                    .font(Typography.small)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.bottom, 20)
            .onAppear {
                pulseAnimation = true
            }
        }
    }
}

struct MoodCard: View {
    let mood: Mood
    let isSelected: Bool
    let isAnimated: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon container
                ZStack {
                    // Background circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    mood.color.opacity(isSelected ? 0.4 : 0.2),
                                    mood.color.opacity(isSelected ? 0.3 : 0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    // Selection ring
                    if isSelected {
                        Circle()
                            .stroke(mood.color, lineWidth: 3)
                            .frame(width: 80, height: 80)
                            .scaleEffect(isSelected ? 1.0 : 0.8)
                            .animation(.spring(response: 0.4), value: isSelected)
                    }
                    
                    // Icon
                    Image(systemName: mood.icon)
                        .font(.system(size: 36))
                        .foregroundColor(isSelected ? mood.color : mood.color.opacity(0.8))
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                
                // Label
                Text(mood.rawValue.capitalized)
                    .font(Typography.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? mood.color.opacity(0.15) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? mood.color.opacity(0.5) : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isAnimated ? 1.0 : 0.8)
            .opacity(isAnimated ? 1.0 : 0)
        }
    }
}

struct MoodDescription: View {
    let mood: Mood
    
    var descriptions: [Mood: String] {
        [
            .energized: "Perfect! Let's channel that energy into positive action.",
            .calm: "Wonderful. Let's maintain that peaceful state.",
            .focused: "Great! Let's sharpen that focus with clarity affirmations.",
            .peaceful: "Beautiful. Let's deepen that inner peace.",
            .motivated: "Excellent! Let's amplify that motivation.",
            .grateful: "Amazing! Gratitude attracts more blessings."
        ]
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: mood.icon)
                    .foregroundColor(mood.color)
                Text("You selected \(mood.rawValue)")
                    .fontWeight(.medium)
            }
            .font(Typography.small)
            .foregroundColor(.white)
            
            Text(descriptions[mood] ?? "")
                .font(Typography.small)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(mood.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(mood.color.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 40)
    }
}
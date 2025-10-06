//
//  CategoryPickerView.swift
//  DailyGlow
//
//  Select preferred affirmation categories
//

import SwiftUI

struct CategoryPickerView: View {
    @Binding var selectedCategories: Set<Category>
    @State private var animatedCategories: Set<Category> = []
    @State private var showError = false
    
    let categoryGrid: [[Category]] = [
        [.selfLove, .success, .health],
        [.relationships, .abundance, .confidence],
        [.gratitude, .motivation, .peace],
        [.spiritual]
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 16) {
                Text("Choose your focus areas")
                    .font(Typography.h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Select at least 3 categories that resonate with you")
                    .font(Typography.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                // Selection counter
                HStack {
                    Text("\(selectedCategories.count)")
                        .font(Typography.h2)
                        .fontWeight(.bold)
                        .foregroundColor(selectedCategories.count >= 3 ? .green : .white)
                    
                    Text("/ 3 minimum")
                        .font(Typography.small)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(
                                    selectedCategories.count >= 3 ? Color.green.opacity(0.5) : Color.white.opacity(0.2),
                                    lineWidth: 1
                                )
                        )
                )
                .scaleEffect(showError ? 1.1 : 1.0)
                .animation(.spring(response: 0.3), value: showError)
            }
            .padding(.horizontal, 40)
            .padding(.top, 40)
            
            // Category grid
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Array(categoryGrid.enumerated()), id: \.offset) { rowIndex, row in
                        HStack(spacing: 12) {
                            ForEach(row, id: \.self) { category in
                                CategoryCard(
                                    category: category,
                                    isSelected: selectedCategories.contains(category),
                                    isAnimated: animatedCategories.contains(category)
                                ) {
                                    toggleCategory(category)
                                }
                                .onAppear {
                                    animateCategory(category, rowIndex: rowIndex)
                                }
                            }
                            
                            // Add spacer for incomplete rows
                            if row.count < 3 {
                                ForEach(0..<(3 - row.count), id: \.self) { _ in
                                    Color.clear
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Quick select options
            VStack(spacing: 12) {
                Text("Quick Select")
                    .font(Typography.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .textCase(.uppercase)
                
                HStack(spacing: 12) {
                    QuickSelectButton(title: "Select All") {
                        withAnimation(.spring(response: 0.4)) {
                            selectedCategories = Set(Category.allCases)
                        }
                        HapticManager.shared.impact(.medium)
                    }
                    
                    QuickSelectButton(title: "Popular") {
                        withAnimation(.spring(response: 0.4)) {
                            selectedCategories = [.selfLove, .gratitude, .confidence, .motivation, .peace]
                        }
                        HapticManager.shared.impact(.medium)
                    }
                    
                    QuickSelectButton(title: "Clear") {
                        withAnimation(.spring(response: 0.4)) {
                            selectedCategories.removeAll()
                        }
                        HapticManager.shared.impact(.light)
                    }
                }
            }
            .padding(.horizontal, 40)
            
            Spacer(minLength: 20)
        }
    }
    
    private func toggleCategory(_ category: Category) {
        withAnimation(.spring(response: 0.3)) {
            if selectedCategories.contains(category) {
                selectedCategories.remove(category)
            } else {
                selectedCategories.insert(category)
            }
        }
        
        // Haptic feedback
        if selectedCategories.contains(category) {
            HapticManager.shared.impact(.medium)
        } else {
            HapticManager.shared.impact(.light)
        }
        
        // Show error if trying to continue with less than 3
        if selectedCategories.count < 3 {
            showError = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showError = false
            }
        }
    }
    
    private func animateCategory(_ category: Category, rowIndex: Int) {
        let delay = Double(rowIndex) * 0.1 + Double.random(in: 0...0.1)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                _ = animatedCategories.insert(category)
            }
        }
    }
}

struct CategoryCard: View {
    let category: Category
    let isSelected: Bool
    let isAnimated: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: isSelected ? [
                                    category.color.opacity(0.3),
                                    category.color.opacity(0.2)
                                ] : [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 60)
                    
                    Image(systemName: category.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? category.color : category.color.opacity(0.6))
                }
                
                // Title
                Text(category.displayName)
                    .font(Typography.small)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                    .lineLimit(1)
                
                // Count
                Text("\(category.sampleAffirmations.count) affirmations")
                    .font(Typography.tiny)
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? category.color.opacity(0.15) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? category.color.opacity(0.5) : Color.white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isAnimated ? (isSelected ? 1.05 : 1.0) : 0.8)
            .opacity(isAnimated ? 1.0 : 0)
        }
    }
}

struct QuickSelectButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.small)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
}
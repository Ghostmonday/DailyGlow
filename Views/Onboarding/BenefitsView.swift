//
//  BenefitsView.swift
//  DailyGlow
//
//  Showcase the benefits of using Daily Glow
//

import SwiftUI

struct BenefitsView: View {
    @State private var visibleBenefits: Set<Int> = []
    
    let benefits = [
        Benefit(
            icon: "brain",
            title: "Rewire Your Mind",
            description: "Transform negative thoughts into positive beliefs through daily affirmations",
            color: .purple
        ),
        Benefit(
            icon: "heart.text.square",
            title: "Practice Gratitude",
            description: "Cultivate appreciation and find joy in everyday moments",
            color: .pink
        ),
        Benefit(
            icon: "moon.stars",
            title: "Better Sleep",
            description: "End your day with peaceful thoughts and wake up refreshed",
            color: .indigo
        ),
        Benefit(
            icon: "bolt.fill",
            title: "Boost Confidence",
            description: "Build self-esteem and tackle challenges with renewed energy",
            color: .orange
        )
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 16) {
                Text("Why Daily Affirmations?")
                    .font(Typography.h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Science-backed benefits for your mind and soul")
                    .font(Typography.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            .padding(.top, 60)
            
            // Benefits list
            VStack(spacing: 20) {
                ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                    BenefitCard(
                        benefit: benefit,
                        isVisible: visibleBenefits.contains(index)
                    )
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.15)) {
                            visibleBenefits.insert(index)
                        }
                    }
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Research badge
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                Text("Backed by neuroscience research")
                    .font(Typography.small)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        Capsule()
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.bottom, 20)
        }
    }
}

struct Benefit {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct BenefitCard: View {
    let benefit: Benefit
    let isVisible: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                benefit.color.opacity(0.3),
                                benefit.color.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: benefit.icon)
                    .font(.title3)
                    .foregroundColor(benefit.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(benefit.title)
                    .font(Typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(benefit.description)
                    .font(Typography.small)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(benefit.color.opacity(0.2), lineWidth: 1)
                )
        )
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -50)
        .scaleEffect(isVisible ? 1 : 0.8)
    }
}

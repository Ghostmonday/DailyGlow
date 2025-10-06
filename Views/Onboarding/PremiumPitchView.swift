//
//  PremiumPitchView.swift
//  DailyGlow
//
//  Premium subscription pitch during onboarding
//

import SwiftUI

struct PremiumPitchView: View {
    @Binding var showingPaywall: Bool
    @State private var animateFeatures = false
    @State private var pulseCrown = false
    
    let premiumFeatures = [
        PremiumFeature(
            icon: "infinity",
            title: "Unlimited Affirmations",
            description: "Access our entire library of 1000+ affirmations",
            color: .purple
        ),
        PremiumFeature(
            icon: "paintbrush.fill",
            title: "Custom Themes",
            description: "Personalize with exclusive gradients and colors",
            color: .pink
        ),
        PremiumFeature(
            icon: "moon.stars.fill",
            title: "Sleep Stories",
            description: "Drift to sleep with calming affirmation stories",
            color: .indigo
        ),
        PremiumFeature(
            icon: "chart.line.uptrend.xyaxis",
            title: "Advanced Analytics",
            description: "Track your mood patterns and growth",
            color: .green
        ),
        PremiumFeature(
            icon: "square.grid.3x3.fill",
            title: "Widget Customization",
            description: "Beautiful widgets for your home screen",
            color: .orange
        ),
        PremiumFeature(
            icon: "sparkles",
            title: "AI Personalization",
            description: "Affirmations tailored just for you",
            color: .cyan
        )
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            // Crown animation
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.yellow.opacity(0.4),
                                Color.orange.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 20)
                    .scaleEffect(pulseCrown ? 1.3 : 0.9)
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                        value: pulseCrown
                    )
                
                // Crown icon
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(pulseCrown ? 1.0 : 0.9)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                        value: pulseCrown
                    )
            }
            .padding(.top, 20)
            .onAppear {
                pulseCrown = true
            }
            
            // Header
            VStack(spacing: 16) {
                Text("Unlock Premium")
                    .font(Typography.h1)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Take your journey to the next level")
                    .font(Typography.body)
                    .foregroundColor(.white.opacity(0.9))
                
                // Price tag
                HStack(spacing: 4) {
                    Text("Only")
                        .font(Typography.small)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("$4.99")
                        .font(Typography.h2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("/month")
                        .font(Typography.small)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.yellow.opacity(0.3),
                                    Color.orange.opacity(0.2)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        colors: [.yellow.opacity(0.5), .orange.opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                )
            }
            .padding(.horizontal, 40)
            
            // Features grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(Array(premiumFeatures.enumerated()), id: \.offset) { index, feature in
                        PremiumFeatureCard(
                            feature: feature,
                            isAnimated: animateFeatures,
                            delay: Double(index) * 0.1
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(maxHeight: 300)
            .onAppear {
                animateFeatures = true
            }
            
            // CTA Button
            Button {
                showingPaywall = true
                HapticManager.shared.impact(.medium)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.title3)
                    
                    Text("Start Free Trial")
                        .font(Typography.body)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(
                    color: Color.yellow.opacity(0.3),
                    radius: 20,
                    y: 10
                )
            }
            .padding(.horizontal, 30)
            
            // Trust badges
            HStack(spacing: 20) {
                TrustBadge(icon: "checkmark.shield.fill", text: "No ads ever")
                TrustBadge(icon: "arrow.clockwise", text: "Cancel anytime")
                TrustBadge(icon: "lock.fill", text: "Secure payment")
            }
            .font(Typography.tiny)
            .foregroundColor(.white.opacity(0.6))
            
            Spacer(minLength: 20)
        }
    }
}

struct PremiumFeature {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct PremiumFeatureCard: View {
    let feature: PremiumFeature
    let isAnimated: Bool
    let delay: Double
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 10) {
            // Icon
            Image(systemName: feature.icon)
                .font(.title2)
                .foregroundColor(feature.color)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(feature.color.opacity(0.2))
                )
            
            // Title
            Text(feature.title)
                .font(Typography.small)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Description
            Text(feature.description)
                .font(Typography.tiny)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            feature.color.opacity(0.15),
                            feature.color.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(feature.color.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0)
        .onAppear {
            if isAnimated {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(delay)) {
                    isVisible = true
                }
            }
        }
    }
}

struct TrustBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(Typography.tiny)
        }
    }
}

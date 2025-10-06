//
//  WelcomeView.swift
//  DailyGlow
//
//  Welcome screen for onboarding flow
//

import SwiftUI

struct WelcomeView: View {
    @Binding var isAnimating: Bool
    @State private var titleScale: CGFloat = 0.8
    @State private var subtitleOpacity: Double = 0
    @State private var iconRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App icon
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.yellow.opacity(0.3),
                                Color.orange.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .blur(radius: 10)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: 3.0)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                // Main icon
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(iconRotation))
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(
                        .spring(response: 1.0, dampingFraction: 0.6),
                        value: isAnimating
                    )
                
                // Sparkles
                ForEach(0..<8) { index in
                    Image(systemName: "sparkle")
                        .font(.system(size: CGFloat.random(in: 12...20)))
                        .foregroundColor(.white)
                        .offset(
                            x: cos(CGFloat(index) * .pi / 4) * 80,
                            y: sin(CGFloat(index) * .pi / 4) * 80
                        )
                        .opacity(isAnimating ? Double.random(in: 0.5...1.0) : 0)
                        .animation(
                            .easeInOut(duration: Double.random(in: 1.5...2.5))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                            value: isAnimating
                        )
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    iconRotation = 360
                }
            }
            
            // Welcome text
            VStack(spacing: 20) {
                Text("Welcome to")
                    .font(Typography.h3)
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(subtitleOpacity)
                    .animation(
                        .easeIn(duration: 0.8).delay(0.3),
                        value: subtitleOpacity
                    )
                
                Text("Daily Glow")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(titleScale)
                    .animation(
                        .spring(response: 0.8, dampingFraction: 0.6),
                        value: titleScale
                    )
                
                Text("Your daily companion for\npositivity and growth")
                    .font(Typography.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .opacity(subtitleOpacity)
                    .animation(
                        .easeIn(duration: 0.8).delay(0.5),
                        value: subtitleOpacity
                    )
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Features preview
            HStack(spacing: 30) {
                FeatureIcon(
                    icon: "sparkles",
                    title: "Affirmations",
                    delay: 0.7
                )
                
                FeatureIcon(
                    icon: "heart.fill",
                    title: "Gratitude",
                    delay: 0.9
                )
                
                FeatureIcon(
                    icon: "book.fill",
                    title: "Journal",
                    delay: 1.1
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .onAppear {
            titleScale = 1.0
            subtitleOpacity = 1.0
        }
    }
}

struct FeatureIcon: View {
    let icon: String
    let title: String
    let delay: Double
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
            
            Text(title)
                .font(Typography.tiny)
                .foregroundColor(.white.opacity(0.7))
        }
        .opacity(isVisible ? 1.0 : 0)
        .scaleEffect(isVisible ? 1.0 : 0.5)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.7).delay(delay),
            value: isVisible
        )
        .onAppear {
            isVisible = true
        }
    }
}
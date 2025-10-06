//
//  CompleteView.swift
//  DailyGlow
//
//  Completion screen for onboarding flow
//

import SwiftUI

struct CompleteView: View {
    let userName: String
    let onComplete: () -> Void
    
    @State private var showContent = false
    @State private var showConfetti = 0
    @State private var pulseAnimation = false
    @State private var starAnimations: [Bool] = Array(repeating: false, count: 5)
    
    var body: some View {
        ZStack {
            // Background with animated gradient
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.8),
                    Color.blue.opacity(0.6),
                    Color.pink.opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .hueRotation(.degrees(pulseAnimation ? 30 : 0))
            .animation(
                .easeInOut(duration: 4)
                .repeatForever(autoreverses: true),
                value: pulseAnimation
            )
            
            // Floating particles
            ForEach(0..<20) { index in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.1...0.3)))
                    .frame(width: CGFloat.random(in: 10...30))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .offset(y: pulseAnimation ? -50 : 50)
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1),
                        value: pulseAnimation
                    )
            }
            
            // Main content
            VStack(spacing: 40) {
                Spacer()
                
                // Success icon with animation
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 150, height: 150)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0)
                        .animation(
                            .spring(response: 0.8, dampingFraction: 0.6),
                            value: showContent
                        )
                    
                    // Checkmark
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .green],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(showContent ? 1.0 : 0)
                        .rotationEffect(.degrees(showContent ? 0 : -180))
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.7).delay(0.2),
                            value: showContent
                        )
                    
                    // Stars around checkmark
                    ForEach(0..<5) { index in
                        Image(systemName: "star.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                            .offset(
                                x: cos(CGFloat(index) * .pi * 2 / 5) * 80,
                                y: sin(CGFloat(index) * .pi * 2 / 5) * 80
                            )
                            .scaleEffect(starAnimations[index] ? 1.0 : 0)
                            .opacity(starAnimations[index] ? 1.0 : 0)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.6)
                                .delay(0.5 + Double(index) * 0.1),
                                value: starAnimations[index]
                            )
                    }
                }
                
                // Welcome message
                VStack(spacing: 20) {
                    Text("You're All Set!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.7).delay(0.3),
                            value: showContent
                        )
                    
                    Text(userName.isEmpty ? "Welcome to your journey of positivity" : "Welcome aboard, \(userName)!")
                        .font(Typography.h3)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1.0 : 0)
                        .animation(
                            .easeIn(duration: 0.8).delay(0.5),
                            value: showContent
                        )
                    
                    Text("Your daily dose of inspiration awaits")
                        .font(Typography.body)
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(showContent ? 1.0 : 0)
                        .animation(
                            .easeIn(duration: 0.8).delay(0.7),
                            value: showContent
                        )
                }
                .padding(.horizontal, 40)
                
                // Quick tips
                VStack(spacing: 16) {
                    QuickTip(
                        icon: "sun.max.fill",
                        text: "Check in daily to build your streak",
                        delay: 0.9
                    )
                    
                    QuickTip(
                        icon: "heart.fill",
                        text: "Swipe right to save your favorites",
                        delay: 1.1
                    )
                    
                    QuickTip(
                        icon: "book.fill",
                        text: "Journal your thoughts and gratitude",
                        delay: 1.3
                    )
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Start button
                Button {
                    HapticManager.shared.notification(.success)
                    onComplete()
                } label: {
                    HStack(spacing: 12) {
                        Text("Start My Journey")
                            .font(Typography.body)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right")
                            .font(.body)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(
                        color: Color.white.opacity(0.3),
                        radius: 20,
                        y: 10
                    )
                }
                .padding(.horizontal, 30)
                .scaleEffect(showContent ? 1.0 : 0.8)
                .opacity(showContent ? 1.0 : 0)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.7).delay(1.5),
                    value: showContent
                )
                
                Spacer()
            }
            
            // Confetti - Disabled (requires ConfettiSwiftUI package)
            // ConfettiCannon(
            //     counter: $showConfetti,
            //     num: 100,
            //     colors: [.yellow, .orange, .pink, .purple, .blue],
            //     confettiSize: 10,
            //     rainHeight: 1000,
            //     fadesOut: true,
            //     radius: 500
            // )
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        pulseAnimation = true
        
        withAnimation {
            showContent = true
        }
        
        // Animate stars
        for index in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(index) * 0.1) {
                starAnimations[index] = true
            }
        }
        
        // Trigger confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showConfetti += 1
            HapticManager.shared.playStreak()
        }
    }
}

struct QuickTip: View {
    let icon: String
    let text: String
    let delay: Double
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.yellow)
                .frame(width: 30)
            
            Text(text)
                .font(Typography.small)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .offset(x: isVisible ? 0 : -50)
        .opacity(isVisible ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(delay)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Simple Confetti Implementation
struct ConfettiCannon: View {
    @Binding var counter: Int
    var num: Int
    var colors: [Color]
    var confettiSize: CGFloat
    var rainHeight: CGFloat
    var fadesOut: Bool
    var radius: CGFloat
    
    var body: some View {
        ZStack {
            ForEach(0..<num, id: \.self) { index in
                CompleteConfettiPiece(
                    color: colors.randomElement() ?? .white,
                    size: confettiSize,
                    rainHeight: rainHeight,
                    fadesOut: fadesOut,
                    radius: radius
                )
            }
        }
        .onChange(of: counter) { _, _ in
            // Trigger animation
        }
    }
}

private struct CompleteConfettiPiece: View {
    let color: Color
    let size: CGFloat
    let rainHeight: CGFloat
    let fadesOut: Bool
    let radius: CGFloat
    
    @State private var animate = false
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size, height: size)
            .offset(x: xOffset, y: yOffset)
            .rotationEffect(.degrees(rotation))
            .opacity(animate ? 0 : 1)
            .animation(
                .easeOut(duration: Double.random(in: 1.5...2.5)),
                value: animate
            )
            .onAppear {
                xOffset = CGFloat.random(in: -radius...radius)
                yOffset = -rainHeight
                rotation = Double.random(in: 0...360)
                
                withAnimation {
                    yOffset = rainHeight
                    rotation += Double.random(in: 180...720)
                    animate = fadesOut
                }
            }
    }
}

// MARK: - Preview
#Preview {
    CompleteView(userName: "Sarah") {
        print("Onboarding complete!")
    }
}

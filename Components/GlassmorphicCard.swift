import SwiftUI

struct GlassmorphicCard<Content: View>: View {
    let cornerRadius: CGFloat
    let content: Content
    
    init(cornerRadius: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: .shadowMedium, radius: 10, x: 0, y: 5)
    }
}

// Premium glass card with extra effects
struct PremiumGlassCard<Content: View>: View {
    let content: Content
    @State private var shimmerPhase: CGFloat = 0
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.premiumGold.opacity(0.6),
                                        Color.premiumGold.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .overlay(
                        // Shimmer effect
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.2),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .offset(x: shimmerPhase * 400 - 200)
                        .mask(
                            RoundedRectangle(cornerRadius: 25)
                        )
                    )
            )
            .shadow(color: .premiumGold.opacity(0.3), radius: 15, x: 0, y: 8)
            .onAppear {
                withAnimation(
                    .linear(duration: 3)
                    .repeatForever(autoreverses: false)
                ) {
                    shimmerPhase = 1
                }
            }
    }
}

// Interactive glass button
struct GlassButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    @State private var isPressed = false
    
    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            HapticManager.shared.impact(.light)
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.buttonMedium())
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
            )
            .shadow(color: .shadowMedium, radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}

// Gradient button
struct GradientButton: View {
    let title: String
    let gradient: LinearGradient
    let action: () -> Void
    @State private var isPressed = false
    
    init(title: String, gradient: LinearGradient? = nil, action: @escaping () -> Void) {
        self.title = title
        self.gradient = gradient ?? LinearGradient(
            colors: [.primaryGradientStart, .primaryGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            HapticManager.shared.impact(.light)
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            Text(title)
                .font(.buttonLarge())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(gradient)
                        .overlay(
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                        )
                        .shadow(color: .shadowMedium, radius: 10, x: 0, y: 5)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}

// Floating action button
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.medium)
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.primaryGradientStart, .primaryGradientEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: .primaryGradientEnd.opacity(0.4), radius: 15, x: 0, y: 8)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
        .scaleEffect(isAnimating ? 1.1 : 1.0)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

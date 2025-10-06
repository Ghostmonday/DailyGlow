import SwiftUI

// Unified button wrapper
struct CustomButton: View {
    let title: String
    let style: ButtonStyle
    var icon: String? = nil
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary, tertiary
    }
    
    var body: some View {
        switch style {
        case .primary:
            PrimaryCTAButton(title: title, action: action)
        case .secondary:
            SecondaryButton(title: title, icon: icon, action: action)
        case .tertiary:
            SecondaryButton(title: title, icon: icon, action: action)
        }
    }
}

// Primary CTA button
struct PrimaryCTAButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false
    @State private var shimmerPhase: CGFloat = 0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            HapticManager.shared.impact(.medium)
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            ZStack {
                // Background gradient
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.primaryGradientStart, .primaryGradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Shimmer effect
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: shimmerPhase * 300 - 150)
                    .mask(Capsule())
                
                // Text
                Text(title)
                    .font(.buttonLarge())
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
            .frame(height: 56)
            .shadow(color: .primaryGradientEnd.opacity(0.4), radius: 15, x: 0, y: 8)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .onAppear {
            withAnimation(
                .linear(duration: 2)
                .repeatForever(autoreverses: false)
                .delay(1)
            ) {
                shimmerPhase = 1
            }
        }
    }
}

// Secondary button
struct SecondaryButton: View {
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
                    .fontWeight(.medium)
            }
            .foregroundColor(.textPrimary)
            .frame(height: 48)
            .padding(.horizontal, 24)
            .background(
                Capsule()
                    .stroke(Color.adaptiveBorder, lineWidth: 1.5)
                    .background(
                        Capsule()
                            .fill(Color.backgroundSecondary)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}

// Icon button
struct IconButton: View {
    let icon: String
    let action: () -> Void
    @State private var isPressed = false
    var size: CGFloat = 44
    var backgroundColor: Color = .clear
    var foregroundColor: Color = .textPrimary
    
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
            Image(systemName: icon)
                .font(.system(size: size * 0.45, weight: .medium))
                .foregroundColor(foregroundColor)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(backgroundColor)
                        .overlay(
                            Circle()
                                .stroke(Color.adaptiveBorder.opacity(0.2), lineWidth: 1)
                        )
                )
                .scaleEffect(isPressed ? 0.85 : 1.0)
        }
    }
}

// Category selection button
struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.light)
            action()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(category.gradient)
                        .frame(width: 60, height: 60)
                    
                    if isSelected {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 60, height: 60)
                    }
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                .shadow(color: category.color.opacity(0.3), radius: isSelected ? 15 : 8, x: 0, y: 5)
                
                Text(category.rawValue)
                    .font(.uiCaption())
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
            }
            .scaleEffect(isSelected ? 1.1 : (isHovering ? 1.05 : 1.0))
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovering)
        }
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

// Mood selection button (renamed to avoid conflict with JournalTab)
struct CustomMoodButton: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.light)
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: mood.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isSelected ? .white : mood.color)
                
                Text(mood.rawValue)
                    .font(.uiBody())
                    .foregroundColor(isSelected ? .white : .textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? mood.color : Color.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.clear : Color.adaptiveBorder.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: isSelected ? mood.color.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
            .scaleEffect(isAnimating ? 1.02 : 1.0)
        }
        .onChange(of: isSelected) { selected in
            if selected {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isAnimating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isAnimating = false
                }
            }
        }
    }
}

// Tab bar button
struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.light)
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? "\(icon).fill" : icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isSelected ? .primaryGradientEnd : .textSecondary)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(title)
                    .font(.tabBarItem())
                    .foregroundColor(isSelected ? .primaryGradientEnd : .textSecondary)
            }
            .frame(maxWidth: .infinity)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
}

// Social login button
struct SocialLoginButton: View {
    enum Provider {
        case apple, google
        
        var title: String {
            switch self {
            case .apple: return "Continue with Apple"
            case .google: return "Continue with Google"
            }
        }
        
        var icon: String {
            switch self {
            case .apple: return "apple.logo"
            case .google: return "globe"
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .apple: return Color.black
            case .google: return Color.white
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .apple: return Color.white
            case .google: return Color.black
            }
        }
    }
    
    let provider: Provider
    let action: () -> Void
    @State private var isPressed = false
    
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
                Image(systemName: provider.icon)
                    .font(.system(size: 20, weight: .medium))
                
                Text(provider.title)
                    .font(.buttonMedium())
                    .fontWeight(.medium)
                
                Spacer()
            }
            .foregroundColor(provider.foregroundColor)
            .padding(.horizontal, 20)
            .frame(height: 50)
            .background(
                Capsule()
                    .fill(provider.backgroundColor)
                    .overlay(
                        provider == .google ?
                        Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1) : nil
                    )
            )
            .shadow(color: .shadowLight, radius: 5, x: 0, y: 3)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}

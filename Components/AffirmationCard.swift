import SwiftUI

struct AffirmationCard: View {
    let affirmation: Affirmation
    let isFavorite: Bool
    @State private var isAnimating = false
    
    var onFavoriteToggle: ((Bool) -> Void)?
    var onShare: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: 30)
                .fill(affirmation.category.gradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            
            // Glass morphism layer
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
            
            // Content
            VStack(spacing: 30) {
                // Category badge
                HStack {
                    Image(systemName: affirmation.category.icon)
                        .font(.system(size: 14, weight: .semibold))
                    Text(affirmation.category.rawValue)
                        .font(.categoryBadge())
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
                
                Spacer()
                
                // Affirmation text
                Text(affirmation.getDisplayText(userName: ""))
                    .font(.affirmationTitle())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                    .padding(.horizontal, 20)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 40) {
                    // Share button
                    Button(action: {
                        onShare?()
                        HapticManager.shared.impact(.light)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    
                    // Favorite button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            onFavoriteToggle?(!isFavorite)
                            HapticManager.shared.impact(.medium)
                        }
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(isFavorite ? .red : .white)
                            .scaleEffect(isFavorite ? 1.1 : 1.0)
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(.vertical, 40)
        }
        .frame(maxWidth: 350, maxHeight: 550)
        .shadow(color: affirmation.category.color.opacity(0.3), radius: 20, x: 0, y: 10)
        .scaleEffect(isAnimating ? 1.0 : 0.9)
        .opacity(isAnimating ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
}

// Mini card for grid views
struct AffirmationMiniCard: View {
    let affirmation: Affirmation
    let userName: String = ""
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: affirmation.category.icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(affirmation.category.rawValue)
                    .font(.categoryBadge())
                Spacer()
            }
            .foregroundColor(.white.opacity(0.9))
            
            Text(affirmation.getDisplayText(userName: userName))
                .font(.uiBody())
                .foregroundColor(.white)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(16)
        .frame(height: 150)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(affirmation.category.gradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .opacity(0.2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: affirmation.category.color.opacity(0.2), radius: 10, x: 0, y: 5)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
    }
}

// Floating affirmation preview
struct AffirmationPreview: View {
    let text: String
    let category: Category
    @State private var offset: CGFloat = 0
    
    var body: some View {
        Text(text)
            .font(.uiBody())
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(category.gradient)
                    .overlay(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .opacity(0.2)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: category.color.opacity(0.3), radius: 10, x: 0, y: 5)
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                ) {
                    offset = -10
                }
            }
    }
}

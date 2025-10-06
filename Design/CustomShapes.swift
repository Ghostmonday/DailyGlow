import SwiftUI

// Wave shape for organic backgrounds
struct WaveShape: Shape {
    var offset: CGFloat = 0
    var amplitude: CGFloat = 20
    var frequency: CGFloat = 1
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: rect.midY))
            
            for x in stride(from: 0, through: rect.width, by: 1) {
                let relativeX = x / rect.width
                let y = rect.midY + amplitude * sin(2 * .pi * frequency * relativeX + offset)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: rect.width, y: rect.maxY))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

// Blob shape for floating orbs
struct BlobShape: Shape {
    var phase: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        return Path { path in
            path.move(to: CGPoint(x: center.x + radius, y: center.y))
            
            for angle in stride(from: 0, through: 360, by: 10) {
                let radian = angle * .pi / 180
                let variation = sin(radian * 3 + phase) * 10
                let r = radius + variation
                let x = center.x + r * cos(radian)
                let y = center.y + r * sin(radian)
                
                if angle == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.closeSubpath()
        }
    }
}

// Custom rounded rectangle with specific corners
struct CustomRoundedRectangle: Shape {
    var topLeft: CGFloat = 0
    var topRight: CGFloat = 0
    var bottomLeft: CGFloat = 0
    var bottomRight: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            // Start from top-left
            path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
            
            // Top edge and top-right corner
            path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.minY + topRight),
                control: CGPoint(x: rect.maxX, y: rect.minY)
            )
            
            // Right edge and bottom-right corner
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY),
                control: CGPoint(x: rect.maxX, y: rect.maxY)
            )
            
            // Bottom edge and bottom-left corner
            path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX, y: rect.maxY - bottomLeft),
                control: CGPoint(x: rect.minX, y: rect.maxY)
            )
            
            // Left edge and top-left corner
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + topLeft, y: rect.minY),
                control: CGPoint(x: rect.minX, y: rect.minY)
            )
            
            path.closeSubpath()
        }
    }
}

// Glow effect modifier
struct GlowEffect: ViewModifier {
    var color: Color = .white
    var radius: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius / 2)
            .shadow(color: color.opacity(0.3), radius: radius)
            .shadow(color: color.opacity(0.1), radius: radius * 2)
    }
}

// Pulse effect modifier
struct PulseEffect: ViewModifier {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = 1.1
                    opacity = 0.8
                }
            }
    }
}

// Glass morphism modifier
struct GlassMorphism: ViewModifier {
    var cornerRadius: CGFloat = 20
    
    func body(content: Content) -> some View {
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

// Shimmer effect for loading states
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase * 400 - 200)
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

// Floating animation modifier
struct FloatingEffect: ViewModifier {
    @State private var offset: CGFloat = 0
    var amplitude: CGFloat = 10
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
                ) {
                    offset = amplitude
                }
            }
    }
}

// Extension for easy access to modifiers
extension View {
    func glowEffect(color: Color = .white, radius: CGFloat = 20) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
    
    func pulseEffect() -> some View {
        modifier(PulseEffect())
    }
    
    func glassMorphism(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassMorphism(cornerRadius: cornerRadius))
    }
    
    func shimmerEffect() -> some View {
        modifier(ShimmerEffect())
    }
    
    func floatingEffect(amplitude: CGFloat = 10) -> some View {
        modifier(FloatingEffect(amplitude: amplitude))
    }
}

// Particle effect view for celebrations
struct ParticleEffect: View {
    @State private var particles: [Particle] = []
    var color: Color = .accentPink
    var particleCount: Int = 20
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGVector
        var size: CGFloat
        var opacity: Double
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(color)
                        .frame(width: particle.size, height: particle.size)
                        .opacity(particle.opacity)
                        .position(particle.position)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
                animateParticles()
            }
        }
    }
    
    func createParticles(in size: CGSize) {
        particles = (0..<particleCount).map { _ in
            Particle(
                position: CGPoint(x: size.width / 2, y: size.height / 2),
                velocity: CGVector(
                    dx: CGFloat.random(in: -5...5),
                    dy: CGFloat.random(in: -10...-5)
                ),
                size: CGFloat.random(in: 4...8),
                opacity: 1.0
            )
        }
    }
    
    func animateParticles() {
        withAnimation(.linear(duration: 2)) {
            for index in particles.indices {
                particles[index].position.x += particles[index].velocity.dx * 50
                particles[index].position.y += particles[index].velocity.dy * 50
                particles[index].opacity = 0
            }
        }
    }
}

import SwiftUI

enum BackgroundStyle {
    case floatingBubbles, floatingOrbs, calm, energized
}

struct AnimatedBackground: View {
    @State private var animationPhase: CGFloat = 0
    @State private var waveOffset: CGFloat = 0
    @State private var orbPositions: [CGPoint] = []
    @State private var orbPhases: [Double] = []
    
    let gradientColors: [Color]
    let showOrbs: Bool
    let showWaves: Bool
    
    init(gradientColors: [Color]? = nil, showOrbs: Bool = true, showWaves: Bool = true) {
        self.gradientColors = gradientColors ?? [.primaryGradientStart, .primaryGradientEnd]
        self.showOrbs = showOrbs
        self.showWaves = showWaves
    }
    
    init(style: BackgroundStyle, primaryColor: Color, secondaryColor: Color) {
        switch style {
        case .floatingBubbles:
            self.init(gradientColors: [primaryColor, secondaryColor], showOrbs: true, showWaves: true)
        case .floatingOrbs:
            self.init(gradientColors: [primaryColor, secondaryColor], showOrbs: true, showWaves: false)
        case .calm:
            self.init(gradientColors: [primaryColor, secondaryColor], showOrbs: false, showWaves: true)
        case .energized:
            self.init(gradientColors: [primaryColor, secondaryColor], showOrbs: true, showWaves: true)
        }
    }
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .hueRotation(.degrees(animationPhase * 30))
            .ignoresSafeArea()
            
            // Mesh gradient overlay
            GeometryReader { geometry in
                Canvas { context, size in
                    context.fill(
                        Path(CGRect(origin: .zero, size: size)),
                        with: .radialGradient(
                            Gradient(colors: [
                                gradientColors[0].opacity(0.3),
                                Color.clear
                            ]),
                            center: CGPoint(x: size.width * 0.3, y: size.height * 0.2),
                            startRadius: 0,
                            endRadius: size.width * 0.6
                        )
                    )
                    
                    context.fill(
                        Path(CGRect(origin: .zero, size: size)),
                        with: .radialGradient(
                            Gradient(colors: [
                                gradientColors[1].opacity(0.3),
                                Color.clear
                            ]),
                            center: CGPoint(x: size.width * 0.7, y: size.height * 0.8),
                            startRadius: 0,
                            endRadius: size.width * 0.6
                        )
                    )
                }
                .blur(radius: 40)
                .ignoresSafeArea()
                
                // Floating orbs
                if showOrbs {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 100, height: 100)
                            .blur(radius: 20)
                            .position(
                                x: geometry.size.width * (0.2 + Double(index) * 0.3),
                                y: geometry.size.height * (0.3 + sin(animationPhase + Double(index)) * 0.2)
                            )
                    }
                }
                
                // Wave overlays
                if showWaves {
                    WaveShape(offset: waveOffset, amplitude: 30, frequency: 1.5)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: geometry.size.height * 0.3)
                        .offset(y: geometry.size.height * 0.7)
                    
                    WaveShape(offset: waveOffset * 1.5, amplitude: 20, frequency: 2)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.white.opacity(0.03)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: geometry.size.height * 0.25)
                        .offset(y: geometry.size.height * 0.75)
                }
            }
        }
        .onAppear {
            withAnimation(
                .linear(duration: 20)
                .repeatForever(autoreverses: false)
            ) {
                animationPhase = 1
            }
            
            withAnimation(
                .linear(duration: 10)
                .repeatForever(autoreverses: false)
            ) {
                waveOffset = .pi * 2
            }
        }
    }
}

// Calm background variant
struct CalmBackground: View {
    @State private var breathPhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.moodCalm, .moodCalm.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Breathing circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .scaleEffect(1 + breathPhase * 0.2)
                .opacity(0.8 - breathPhase * 0.3)
                .blur(radius: 30)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 4)
                .repeatForever(autoreverses: true)
            ) {
                breathPhase = 1
            }
        }
    }
}

// Energized background variant
struct EnergizedBackground: View {
    @State private var particlePhase: CGFloat = 0
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.moodEnergized, .accentOrange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .hueRotation(.degrees(rotationAngle))
            .ignoresSafeArea()
            
            // Energy particles
            GeometryReader { geometry in
                ForEach(0..<15, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: CGFloat.random(in: 2...8))
                        .position(
                            x: geometry.size.width * CGFloat.random(in: 0...1),
                            y: geometry.size.height * (1 - particlePhase) + CGFloat(index * 50)
                        )
                        .blur(radius: 1)
                }
            }
        }
        .onAppear {
            withAnimation(
                .linear(duration: 5)
                .repeatForever(autoreverses: false)
            ) {
                particlePhase = 1.2
            }
            
            withAnimation(
                .linear(duration: 10)
                .repeatForever(autoreverses: false)
            ) {
                rotationAngle = 360
            }
        }
    }
}

// Night mode background
struct NightBackground: View {
    @State private var starOpacities: [Double] = []
    @State private var starPositions: [CGPoint] = []
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.1, blue: 0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Stars
            GeometryReader { geometry in
                ForEach(0..<30, id: \.self) { index in
                    Circle()
                        .fill(Color.white)
                        .frame(width: CGFloat.random(in: 1...3))
                        .opacity(starOpacities.isEmpty ? 0 : starOpacities[index % starOpacities.count])
                        .position(
                            starPositions.isEmpty ? .zero : starPositions[index % starPositions.count]
                        )
                }
            }
            
            // Moon glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: 100, y: -200)
                .blur(radius: 30)
        }
        .onAppear {
            generateStars()
            animateStars()
        }
    }
    
    func generateStars() {
        starOpacities = (0..<30).map { _ in Double.random(in: 0.3...1.0) }
        starPositions = (0..<30).map { _ in
            CGPoint(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
            )
        }
    }
    
    func animateStars() {
        for index in 0..<starOpacities.count {
            withAnimation(
                .easeInOut(duration: Double.random(in: 2...5))
                .repeatForever(autoreverses: true)
                .delay(Double.random(in: 0...2))
            ) {
                starOpacities[index] = Double.random(in: 0.1...1.0)
            }
        }
    }
}

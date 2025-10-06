//
//  HapticManager.swift
//  DailyGlow
//
//  A comprehensive haptic feedback manager that provides various haptic effects
//  for different interactions throughout the app.
//

import SwiftUI
import UIKit
import CoreHaptics

@MainActor
class HapticManager: ObservableObject {
    // MARK: - Singleton
    static let shared = HapticManager()
    
    // MARK: - Properties
    private var hapticEngine: CHHapticEngine?
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @Published var isAvailable: Bool = false
    
    // MARK: - Initialization
    private init() {
        setupHapticEngine()
        prepareGenerators()
        checkAvailability()
    }
    
    // MARK: - Setup
    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            isAvailable = false
            return
        }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
            isAvailable = true
            
            // Handle engine reset
            hapticEngine?.resetHandler = { [weak self] in
                self?.handleEngineReset()
            }
            
            // Handle engine stopped
            hapticEngine?.stoppedHandler = { [weak self] reason in
                self?.handleEngineStopped(reason: reason)
            }
        } catch {
            print("Haptic Engine Error: \(error)")
            isAvailable = false
        }
    }
    
    private func prepareGenerators() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        impactSoft.prepare()
        impactRigid.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }
    
    private func checkAvailability() {
        isAvailable = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }
    
    // MARK: - Engine Handlers
    private func handleEngineReset() {
        do {
            try hapticEngine?.start()
        } catch {
            print("Failed to restart haptic engine: \(error)")
        }
    }
    
    private func handleEngineStopped(reason: CHHapticEngine.StoppedReason) {
        print("Haptic engine stopped: \(reason)")
        // Attempt to restart if needed
        if reason == .audioSessionInterrupt {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.setupHapticEngine()
            }
        }
    }
    
    // MARK: - Basic Impact Haptics
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard hapticsEnabled else { return }
        
        switch style {
        case .light:
            impactLight.impactOccurred()
        case .medium:
            impactMedium.impactOccurred()
        case .heavy:
            impactHeavy.impactOccurred()
        case .soft:
            impactSoft.impactOccurred()
        case .rigid:
            impactRigid.impactOccurred()
        @unknown default:
            impactLight.impactOccurred()
        }
    }
    
    // MARK: - Selection Haptic
    func selection() {
        guard hapticsEnabled else { return }
        selectionFeedback.selectionChanged()
    }
    
    // MARK: - Notification Haptics
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard hapticsEnabled else { return }
        notificationFeedback.notificationOccurred(type)
    }
    
    // MARK: - Custom Haptic Patterns
    func playCardSwipe() {
        guard hapticsEnabled else { return }
        
        // Quick ascending pattern for card swipe
        let pattern: [(delay: TimeInterval, style: UIImpactFeedbackGenerator.FeedbackStyle)] = [
            (0, .light),
            (0.05, .medium),
            (0.1, .soft)
        ]
        
        for (delay, style) in pattern {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.impact(style)
            }
        }
    }
    
    func playAffirmationAppear() {
        guard hapticsEnabled else { return }
        
        // Gentle pop effect for new affirmation
        impact(.soft)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.impact(.light)
        }
    }
    
    func playFavoriteToggle(isFavorited: Bool) {
        guard hapticsEnabled else { return }
        
        if isFavorited {
            // Strong feedback for favoriting
            notification(.success)
        } else {
            // Light feedback for unfavoriting
            impact(.light)
        }
    }
    
    func playButtonTap() {
        guard hapticsEnabled else { return }
        impact(.light)
    }
    
    func playTabSelection() {
        guard hapticsEnabled else { return }
        selection()
    }
    
    func playStreak() {
        guard hapticsEnabled else { return }
        
        // Celebration pattern for streak achievement
        let pattern: [(delay: TimeInterval, type: UINotificationFeedbackGenerator.FeedbackType)] = [
            (0, .success),
            (0.15, .success),
            (0.3, .success)
        ]
        
        for (delay, type) in pattern {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.notification(type)
            }
        }
    }
    
    func playOnboardingProgress() {
        guard hapticsEnabled else { return }
        impact(.medium)
    }
    
    func playError() {
        guard hapticsEnabled else { return }
        notification(.error)
    }
    
    func playWarning() {
        guard hapticsEnabled else { return }
        notification(.warning)
    }
    
    // MARK: - Complex Haptic Patterns using Core Haptics
    func playCustomPattern(intensity: Float = 0.7, sharpness: Float = 0.5, duration: TimeInterval = 0.1) {
        guard hapticsEnabled, let hapticEngine = hapticEngine else { return }
        
        do {
            let hapticEvent = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: 0
            )
            
            let pattern = try CHHapticPattern(events: [hapticEvent], parameters: [])
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play custom haptic: \(error)")
        }
    }
    
    func playHeartbeat() {
        guard hapticsEnabled else { return }
        
        // Double tap like a heartbeat
        impact(.medium)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.impact(.medium)
        }
        
        // Pause and repeat
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.impact(.medium)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.impact(.medium)
            }
        }
    }
    
    func playBreathing(inhale: Bool) {
        guard hapticsEnabled, let hapticEngine = hapticEngine else { return }
        
        do {
            let intensity = inhale ? 0.3 : 0.5
            let sharpness = inhale ? 0.2 : 0.4
            let duration = inhale ? 4.0 : 4.0
            
            // Create a continuous haptic that ramps up or down
            var events: [CHHapticEvent] = []
            let steps = 20
            
            for i in 0..<steps {
                let progress = Float(i) / Float(steps)
                let currentIntensity = inhale ? intensity * progress : intensity * (1 - progress)
                
                let event = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: currentIntensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(sharpness))
                    ],
                    relativeTime: TimeInterval(i) * (duration / Double(steps)),
                    duration: duration / Double(steps)
                )
                events.append(event)
            }
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play breathing haptic: \(error)")
        }
    }
    
    // MARK: - Toggle Haptics
    func toggleHaptics() {
        hapticsEnabled.toggle()
        if hapticsEnabled {
            impact(.medium)
        }
    }
    
    // MARK: - Cleanup
    func stopEngine() {
        hapticEngine?.stop { error in
            if let error = error {
                print("Failed to stop haptic engine: \(error)")
            }
        }
    }
    
    deinit {
        Task { @MainActor in
            stopEngine()
        }
    }
}

// MARK: - SwiftUI View Modifier
struct HapticModifier: ViewModifier {
    let feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle
    let trigger: Bool
    
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { newValue in
                if newValue {
                    HapticManager.shared.impact(feedbackStyle)
                }
            }
    }
}

extension View {
    func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light, trigger: Bool) -> some View {
        modifier(HapticModifier(feedbackStyle: style, trigger: trigger))
    }
}
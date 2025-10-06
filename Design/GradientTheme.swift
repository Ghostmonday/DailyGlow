import SwiftUI

enum TimeOfDay {
    case sunrise, morning, daylight, afternoon, evening, sunset, night
}

struct GradientTheme {
    // Morning gradients - warm oranges and yellows
    static let morning: [[Color]] = [
        [Color(red: 1.0, green: 0.8, blue: 0.4), Color(red: 1.0, green: 0.6, blue: 0.3)],
        [Color(red: 1.0, green: 0.85, blue: 0.5), Color(red: 1.0, green: 0.65, blue: 0.4)],
        [Color(red: 0.98, green: 0.75, blue: 0.65), Color(red: 0.95, green: 0.60, blue: 0.75)],
        [Color(red: 1.0, green: 0.9, blue: 0.6), Color(red: 1.0, green: 0.7, blue: 0.5)],
        [Color(red: 0.99, green: 0.82, blue: 0.55), Color(red: 0.97, green: 0.68, blue: 0.45)]
    ]
    
    // Evening gradients - purples and blues
    static let evening: [[Color]] = [
        [Color(red: 0.4, green: 0.3, blue: 0.7), Color(red: 0.6, green: 0.4, blue: 0.9)],
        [Color(red: 0.5, green: 0.3, blue: 0.8), Color(red: 0.7, green: 0.5, blue: 0.95)],
        [Color(red: 0.35, green: 0.25, blue: 0.65), Color(red: 0.55, green: 0.45, blue: 0.85)],
        [Color(red: 0.45, green: 0.35, blue: 0.75), Color(red: 0.65, green: 0.5, blue: 0.9)],
        [Color(red: 0.3, green: 0.2, blue: 0.6), Color(red: 0.5, green: 0.4, blue: 0.8)]
    ]
    
    // Calm gradients - soft pastels
    static let calm: [[Color]] = [
        [Color(red: 0.85, green: 0.9, blue: 0.95), Color(red: 0.75, green: 0.85, blue: 0.9)],
        [Color(red: 0.9, green: 0.85, blue: 0.95), Color(red: 0.85, green: 0.75, blue: 0.9)],
        [Color(red: 0.95, green: 0.9, blue: 0.85), Color(red: 0.9, green: 0.85, blue: 0.75)],
        [Color(red: 0.85, green: 0.95, blue: 0.9), Color(red: 0.75, green: 0.9, blue: 0.85)],
        [Color(red: 0.9, green: 0.9, blue: 0.95), Color(red: 0.8, green: 0.85, blue: 0.9)]
    ]
    
    // Energy gradients - vibrant combinations
    static let energy: [[Color]] = [
        [Color(red: 1.0, green: 0.3, blue: 0.4), Color(red: 1.0, green: 0.5, blue: 0.2)],
        [Color(red: 0.9, green: 0.2, blue: 0.8), Color(red: 0.4, green: 0.6, blue: 1.0)],
        [Color(red: 1.0, green: 0.4, blue: 0.2), Color(red: 1.0, green: 0.2, blue: 0.6)],
        [Color(red: 0.2, green: 0.9, blue: 0.7), Color(red: 0.1, green: 0.5, blue: 0.95)],
        [Color(red: 1.0, green: 0.2, blue: 0.5), Color(red: 0.95, green: 0.6, blue: 0.2)]
    ]
    
    // Sunset gradients
    static let sunset: [[Color]] = [
        [Color(red: 0.95, green: 0.4, blue: 0.3), Color(red: 0.9, green: 0.3, blue: 0.5)],
        [Color(red: 1.0, green: 0.5, blue: 0.4), Color(red: 0.95, green: 0.35, blue: 0.55)],
        [Color(red: 0.9, green: 0.45, blue: 0.35), Color(red: 0.85, green: 0.35, blue: 0.5)]
    ]
    
    // Night gradients
    static let night: [[Color]] = [
        [Color(red: 0.1, green: 0.1, blue: 0.3), Color(red: 0.2, green: 0.15, blue: 0.4)],
        [Color(red: 0.15, green: 0.1, blue: 0.35), Color(red: 0.25, green: 0.2, blue: 0.45)],
        [Color(red: 0.05, green: 0.05, blue: 0.25), Color(red: 0.15, green: 0.1, blue: 0.35)]
    ]
    
    // Function to get time-appropriate gradient
    static func currentGradient() -> LinearGradient {
        let hour = Calendar.current.component(.hour, from: Date())
        let colors: [Color]
        
        switch hour {
        case 5..<9:
            colors = morning.randomElement() ?? morning[0]
        case 9..<12:
            colors = energy.randomElement() ?? energy[0]
        case 12..<17:
            colors = calm.randomElement() ?? calm[0]
        case 17..<20:
            colors = sunset.randomElement() ?? sunset[0]
        case 20..<23:
            colors = evening.randomElement() ?? evening[0]
        default:
            colors = night.randomElement() ?? night[0]
        }
        
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Get gradient for specific mood
    static func gradientForMood(_ mood: String) -> LinearGradient {
        let colors: [Color]
        switch mood.lowercased() {
        case "energized", "motivated", "excited":
            colors = energy.randomElement() ?? energy[0]
        case "calm", "peaceful", "relaxed":
            colors = calm.randomElement() ?? calm[0]
        case "happy", "joyful", "grateful":
            colors = morning.randomElement() ?? morning[0]
        case "focused", "determined", "confident":
            colors = evening.randomElement() ?? evening[0]
        default:
            colors = calm.randomElement() ?? calm[0]
        }
        
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Animated gradient helper
    static func animatedGradient(from colors: [Color], phase: Double) -> LinearGradient {
        let adjustedColors = colors.map { color in
            color.hueRotation(.degrees(phase * 30))
        }
        return LinearGradient(
            colors: adjustedColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Get gradient for specific time of day
    static func getGradient(for timeOfDay: TimeOfDay) -> [Color] {
        switch timeOfDay {
        case .sunrise:
            return morning.randomElement() ?? morning[0]
        case .morning:
            return morning.randomElement() ?? morning[0]
        case .daylight:
            return energy.randomElement() ?? energy[0]
        case .afternoon:
            return calm.randomElement() ?? calm[0]
        case .evening:
            return evening.randomElement() ?? evening[0]
        case .sunset:
            return sunset.randomElement() ?? sunset[0]
        case .night:
            return night.randomElement() ?? night[0]
        }
    }
    
    // Get gradient for specific mood
    static func getGradient(for mood: Mood) -> [Color] {
        switch mood {
        case .energized, .motivated:
            return energy.randomElement() ?? energy[0]
        case .calm, .peaceful:
            return calm.randomElement() ?? calm[0]
        case .focused, .confident:
            return evening.randomElement() ?? evening[0]
        case .happy:
            return morning.randomElement() ?? morning[0]
        case .grateful:
            return sunset.randomElement() ?? sunset[0]
        }
    }
}

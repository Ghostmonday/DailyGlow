//
//  NotificationSetupView.swift
//  DailyGlow
//
//  Setup daily reminder notifications
//

import SwiftUI

struct NotificationSetupView: View {
    @Binding var notificationsEnabled: Bool
    @Binding var reminderTime: Date
    @State private var showTimePicker = false
    @State private var animatePhone = false
    @State private var showNotificationPreview = false
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Animated phone with notification
            ZStack {
                // Phone mockup
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.black)
                    .frame(width: 200, height: 400)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
                    .rotationEffect(.degrees(animatePhone ? -5 : 5))
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                        value: animatePhone
                    )
                
                // Screen content
                VStack {
                    // Status bar
                    HStack {
                        Text("9:41")
                            .font(.caption)
                        Spacer()
                        HStack(spacing: 2) {
                            Image(systemName: "wifi")
                            Image(systemName: "battery.100")
                        }
                        .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Notification preview
                    if showNotificationPreview {
                        NotificationPreview(
                            time: timeFormatter.string(from: reminderTime)
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                    }
                    
                    Spacer()
                }
                .frame(width: 180, height: 380)
            }
            .scaleEffect(0.8)
            .onAppear {
                animatePhone = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring()) {
                        showNotificationPreview = true
                    }
                }
            }
            
            // Header
            VStack(spacing: 16) {
                Text("Daily Reminders")
                    .font(Typography.h1)
                    .foregroundColor(.white)
                
                Text("Get gentle nudges to practice your affirmations")
                    .font(Typography.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            // Toggle and time picker
            VStack(spacing: 20) {
                // Enable toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Enable Notifications")
                            .font(Typography.body)
                            .foregroundColor(.white)
                        
                        Text("We'll send one reminder daily")
                            .font(Typography.small)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $notificationsEnabled)
                        .tint(.green)
                        .onChange(of: notificationsEnabled) { _, enabled in
                            if enabled {
                                requestNotificationPermission()
                                withAnimation(.spring()) {
                                    showTimePicker = true
                                }
                            } else {
                                withAnimation {
                                    showTimePicker = false
                                }
                            }
                            HapticManager.shared.impact(.medium)
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    notificationsEnabled ? Color.green.opacity(0.3) : Color.white.opacity(0.2),
                                    lineWidth: 1
                                )
                        )
                )
                
                // Time picker
                if showTimePicker {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                            
                            Text("Reminder Time")
                                .font(Typography.body)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .colorScheme(.dark)
                                .tint(.blue)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        // Suggested times
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                SuggestedTimeButton(time: "Morning", hour: 8) {
                                    reminderTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
                                }
                                
                                SuggestedTimeButton(time: "Lunch", hour: 12) {
                                    reminderTime = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
                                }
                                
                                SuggestedTimeButton(time: "Evening", hour: 20) {
                                    reminderTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
                                }
                                
                                SuggestedTimeButton(time: "Bedtime", hour: 22) {
                                    reminderTime = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
                                }
                            }
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Privacy note
            HStack(spacing: 8) {
                Image(systemName: "bell.badge")
                    .foregroundColor(.white.opacity(0.5))
                Text("You can change this anytime in settings")
                    .font(Typography.small)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.bottom, 20)
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if !granted {
                    notificationsEnabled = false
                }
            }
        }
    }
}

struct NotificationPreview: View {
    let time: String
    @State private var isVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                
                Text("Daily Glow")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(time)
                    .font(.caption2)
            }
            
            Text("Your daily affirmation awaits!")
                .font(.caption)
                .fontWeight(.medium)
            
            Text("Take a moment for positivity 🌟")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .foregroundColor(.black)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
        )
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
    }
}

struct SuggestedTimeButton: View {
    let time: String
    let hour: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(time)
                    .font(Typography.small)
                Text("\(hour):00")
                    .font(Typography.tiny)
                    .foregroundColor(.white.opacity(0.7))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

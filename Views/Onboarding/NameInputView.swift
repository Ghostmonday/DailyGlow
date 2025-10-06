//
//  NameInputView.swift
//  DailyGlow
//
//  Get the user's name for personalization
//

import SwiftUI

struct NameInputView: View {
    @Binding var userName: String
    @FocusState private var isTextFieldFocused: Bool
    @State private var showingEmoji = false
    @State private var selectedEmoji = "✨"
    
    let emojis = ["✨", "🌟", "💫", "🌙", "☀️", "🌈", "💝", "🦋", "🌺", "🌸", "🌼", "🌻"]
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Emoji decoration
            Text(selectedEmoji)
                .font(.system(size: 80))
                .scaleEffect(showingEmoji ? 1.0 : 0.5)
                .rotationEffect(.degrees(showingEmoji ? 0 : -180))
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showingEmoji)
                .onTapGesture {
                    withAnimation {
                        selectedEmoji = emojis.randomElement() ?? "✨"
                    }
                    HapticManager.shared.impact(.light)
                }
            
            // Header
            VStack(spacing: 16) {
                Text("What should we call you?")
                    .font(Typography.h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Let's personalize your experience")
                    .font(Typography.body)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 40)
            
            // Name input
            VStack(spacing: 20) {
                TextField("", text: $userName, prompt: Text("Enter your name").foregroundColor(.white.opacity(0.5)))
                    .font(Typography.h2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .focused($isTextFieldFocused)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(isTextFieldFocused ? 0.5 : 0.2),
                                                Color.white.opacity(isTextFieldFocused ? 0.3 : 0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    )
                    .onSubmit {
                        if !userName.isEmpty {
                            isTextFieldFocused = false
                        }
                    }
                
                // Preview greeting
                if !userName.isEmpty {
                    VStack(spacing: 8) {
                        Text("Great to meet you!")
                            .font(Typography.small)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("Good morning, \(userName) ☀️")
                            .font(Typography.h3)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.15))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Privacy note
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                Text("Your data stays on your device")
                    .font(Typography.small)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            showingEmoji = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}
//
//  SharedComponents.swift
//  habitkin
//
//  Created by Balaji K S on 26/04/26.
//

import SwiftUI

// MARK: - Quest Card
struct QuestCard: View {
    let quest: Quest
    let theme: AppTheme
    let action: () -> Void

    var body: some View {
        AnimatedQuestCard(quest: quest, theme: theme, delay: 0, action: action)
    }
}

// MARK: - Stat Box
struct StatBox: View {
    let label: String
    let value: String
    let icon: String
    let theme: AppTheme

    var body: some View {
        AnimatedStatBox(
            label: label,
            value: value,
            icon: icon,
            iconColor: Color(hex: theme.primaryColor),
            theme: theme,
            visible: true
        )
    }
}

// MARK: - Celebration View (legacy – kept for compatibility)
struct CelebrationView: View {
    let message: String
    let theme: AppTheme

    var body: some View {
        ConfettiCelebrationView(message: message, coins: 0, theme: theme)
    }
}

// MARK: - Confetti Celebration View
struct ConfettiCelebrationView: View {
    let message: String
    let coins: Int
    let theme: AppTheme

    @State private var starScale: CGFloat = 0.3
    @State private var starRotation: Double = -20
    @State private var coinOffset: CGFloat = 20
    @State private var coinOpacity: Double = 0
    @State private var particles: [ConfettiParticle] = ConfettiParticle.generate(count: 22)

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            // Confetti particles
            ForEach(particles) { p in
                Circle()
                    .fill(p.color)
                    .frame(width: p.size, height: p.size)
                    .offset(x: p.x, y: p.active ? p.endY : p.startY)
                    .opacity(p.active ? 0 : 1)
                    .animation(
                        .easeIn(duration: p.duration)
                            .delay(p.delay),
                        value: p.active
                    )
            }

            // Card
            VStack(spacing: 18) {
                // Bouncing star
                ZStack {
                    Circle()
                        .fill(Color(hex: theme.primaryColor).opacity(0.2))
                        .frame(width: 90, height: 90)
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: theme.primaryColor))
                        .rotationEffect(.degrees(starRotation))
                        .scaleEffect(starScale)
                }

                Text("Quest Complete!")
                    .font(.title3).fontWeight(.heavy)
                    .foregroundColor(.white)

                Text(message)
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // Coin pop
                if coins > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: theme.accentColor))
                        Text("+\(coins) coins!")
                            .font(.headline).fontWeight(.bold)
                            .foregroundColor(Color(hex: theme.accentColor))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: theme.accentColor).opacity(0.15))
                    .cornerRadius(20)
                    .offset(y: coinOffset)
                    .opacity(coinOpacity)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(hex: theme.primaryColor).opacity(0.4), lineWidth: 1.5)
                    )
            )
            .padding(.horizontal, 48)
        }
        .onAppear {
            // Star entrance
            withAnimation(.spring(response: 0.45, dampingFraction: 0.55)) {
                starScale = 1.0
                starRotation = 0
            }
            // Coin pop
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.3)) {
                coinOffset = 0
                coinOpacity = 1
            }
            // Trigger confetti
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                for i in particles.indices {
                    particles[i].active = true
                }
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let startY: CGFloat
    let endY: CGFloat
    let size: CGFloat
    let color: Color
    let duration: Double
    let delay: Double
    var active: Bool = false

    static let confettiColors: [Color] = [
        .yellow, .pink, .cyan, .green, .orange, .purple, .white
    ]

    static func generate(count: Int) -> [ConfettiParticle] {
        (0..<count).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: -160...160),
                startY: CGFloat.random(in: -280 ... -180),
                endY: CGFloat.random(in: 160...320),
                size: CGFloat.random(in: 6...14),
                color: confettiColors.randomElement()!,
                duration: Double.random(in: 0.9...1.6),
                delay: Double.random(in: 0...0.4)
            )
        }
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    let theme: AppTheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isSelected ? Color(hex: theme.primaryColor) : Color.white.opacity(0.5))
                
                Text(label)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? Color(hex: theme.primaryColor) : Color.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

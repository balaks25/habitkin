//
//  HomeView.swift
//  habitkin
//
//  Created by Balaji K S on 23/04/26.
//

import SwiftUI

struct HomeView: View {
    @State private var kid: Kid
    let onUpdate: (Kid) -> Void

    @State private var showCelebration = false
    @State private var celebrationMessage = ""
    @State private var celebrationCoins = 0
    @State private var creatureBounce = false
    @State private var progressWidth: CGFloat = 0
    @State private var headerScale: CGFloat = 0.8
    @State private var statsVisible = false
    @State private var completedTodayCount = 0

    init(kid: Kid, onUpdate: @escaping (Kid) -> Void) {
        _kid = State(initialValue: kid)
        self.onUpdate = onUpdate
    }

    var theme: AppTheme {
        kid.theme
    }

    var availableQuests: [Quest] {
        let allQuests = kid.getCurrentWeekQuests().filter { !kid.completedQuestIds.contains($0.id) }
        let dailyQuests = allQuests.filter { $0.category == "daily" }
        let specialQuests = allQuests.filter { $0.category == "special" }
        return dailyQuests + specialQuests
    }

    private var progressFraction: CGFloat {
        CGFloat(max(kid.totalEarned % 500, 1)) / 500.0
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: theme.secondaryColor),
                    Color(hex: theme.secondaryColor).opacity(0.7),
                    Color(hex: theme.primaryColor).opacity(0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                ZStack {
                    // Decorative bubbles in background
                    GeometryReader { geo in
                        Circle()
                            .fill(Color(hex: theme.primaryColor).opacity(0.08))
                            .frame(width: 200, height: 200)
                            .offset(x: geo.size.width - 80, y: -40)
                        Circle()
                            .fill(Color(hex: theme.accentColor).opacity(0.06))
                            .frame(width: 140, height: 140)
                            .offset(x: -40, y: geo.size.height * 0.4)
                    }
                    .ignoresSafeArea()
                    
                    VStack(spacing: 20) {

                        // ── Kid Header Card ───────────────────────────────
                        KidHeaderCard(kid: kid, theme: theme)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .scaleEffect(headerScale)
                            .onAppear {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                                    headerScale = 1.0
                                }
                            }

                        // ── Creature Card ────────────────────────────────
                        VStack(spacing: 16) {

                            // Creature with idle bounce
                            ZStack {
                                Circle()
                                    .fill(Color(hex: theme.primaryColor).opacity(0.12))
                                    .frame(width: 130, height: 130)

                                Circle()
                                    .stroke(Color(hex: theme.primaryColor).opacity(0.25), lineWidth: 2)
                                    .frame(width: 130, height: 130)

                                Image(systemName: theme.creatures[kid.kinStage])
                                    .font(.system(size: 70, weight: .semibold))
                                    .foregroundColor(Color(hex: theme.primaryColor))
                                    .offset(y: creatureBounce ? -6 : 0)
                                    .animation(
                                        Animation.easeInOut(duration: 1.1)
                                            .repeatForever(autoreverses: true),
                                        value: creatureBounce
                                    )
                            }
                            .onAppear { creatureBounce = true }

                            VStack(spacing: 4) {
                                Text("\(kid.name)'s \(theme.world)")
                                    .font(.title3).fontWeight(.bold)
                                    .foregroundColor(Color(hex: theme.primaryColor))

                                HStack(spacing: 6) {
                                    Image(systemName: stageBadgeIcon(kid.kinStage))
                                        .font(.caption)
                                        .foregroundColor(Color(hex: theme.accentColor))
                                    Text("Stage: \(kid.kinStage.capitalized)")
                                        .font(.caption)
                                        .foregroundColor(Color(hex: theme.accentColor))
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color(hex: theme.accentColor).opacity(0.15))
                                .cornerRadius(20)
                            }

                            // Stats Grid
                            HStack(spacing: 10) {
                                AnimatedStatBox(
                                    label: "Coins",
                                    value: "\(kid.totalCoins)",
                                    icon: "star.fill",
                                    iconColor: Color(hex: theme.accentColor),
                                    theme: theme,
                                    visible: statsVisible
                                )
                                AnimatedStatBox(
                                    label: "Streak",
                                    value: "\(kid.streak)",
                                    icon: "flame.fill",
                                    iconColor: .orange,
                                    theme: theme,
                                    visible: statsVisible
                                )
                                AnimatedStatBox(
                                    label: "Done",
                                    value: "\(kid.totalCompleted)",
                                    icon: "checkmark.seal.fill",
                                    iconColor: .green,
                                    theme: theme,
                                    visible: statsVisible
                                )
                            }
                            .onAppear {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                                    statsVisible = true
                                }
                            }

                            // Animated Progress Bar
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(Color(hex: theme.primaryColor))
                                    Text("Progress to next stage")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("\(kid.totalEarned % 500)/500")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(hex: theme.accentColor))
                                }

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white.opacity(0.1))
                                            .frame(height: 10)

                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color(hex: theme.primaryColor),
                                                        Color(hex: theme.accentColor)
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: progressWidth * geo.size.width, height: 10)
                                            .onAppear {
                                                withAnimation(.easeOut(duration: 1.0).delay(0.4)) {
                                                    progressWidth = progressFraction
                                                }
                                            }
                                    }
                                }
                                .frame(height: 10)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: theme.primaryColor).opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(hex: theme.primaryColor).opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)

                        // ── Story Hook ───────────────────────────────────
                        HStack(spacing: 12) {
                            Image(systemName: kid.character.icon)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Color(hex: theme.accentColor))
                                .frame(width: 44, height: 44)
                                .background(Color(hex: theme.accentColor).opacity(0.15))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(kid.character.storyHook)
                                    .font(.subheadline).fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                Text("Week \(kid.currentWeek) · \(getWeekTitle(kid.currentWeek))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: theme.accentColor).opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: theme.accentColor).opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)

                        // ── Daily Quests ─────────────────────────────────
                        QuestSection(
                            title: "Daily Quests",
                            icon: "calendar.badge.checkmark",
                            quests: availableQuests.filter { $0.category == "daily" },
                            theme: theme,
                            emptyMessage: "All daily quests completed!",
                            onComplete: completeQuest
                        )

                        // ── Special Missions ─────────────────────────────
                        let specialQuests = availableQuests.filter { $0.category == "special" }
                        if !specialQuests.isEmpty {
                            QuestSection(
                                title: "Special Missions",
                                icon: "sparkles",
                                quests: specialQuests,
                                theme: theme,
                                emptyMessage: "",
                                onComplete: completeQuest
                            )
                        }

                        Spacer(minLength: 80)
                    }
                    .padding(.vertical, 20)
                }
                
            }

            // ── Celebration Overlay ──────────────────────────────────
            if showCelebration {
                ConfettiCelebrationView(
                    message: celebrationMessage,
                    coins: celebrationCoins,
                    theme: theme
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.5).combined(with: .opacity),
                    removal: .scale(scale: 1.2).combined(with: .opacity)
                ))
            }
        }
    }

    private func completeQuest(_ quest: Quest) {
        guard !kid.completedQuestIds.contains(quest.id) else { return }

        kid.totalCoins += quest.coins
        kid.totalEarned += quest.coins
        kid.totalCompleted += 1
        kid.completedQuestIds.insert(quest.id)
        kid.lastActivityDate = Date()
        kid.updateKinStage()
        completedTodayCount += 1
        kid.updateKinMood(dailyCompleted: completedTodayCount)

        if kid.totalCompleted % 10 == 0 && kid.currentWeek < 4 {
            kid.currentWeek += 1
        }

        onUpdate(kid)

        celebrationMessage = quest.name
        celebrationCoins = quest.coins
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            showCelebration = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                showCelebration = false
            }
        }
    }

    private func stageBadgeIcon(_ stage: String) -> String {
        switch stage {
        case "egg":      return "circle.fill"
        case "hatch":    return "star.fill"
        case "evolve":   return "bolt.fill"
        case "ultimate": return "crown.fill"
        default:         return "circle.fill"
        }
    }

    private func getWeekTitle(_ week: Int) -> String {
        switch week {
        case 1: return "Meeting Your HabitKin"
        case 2: return "Building Our Bond"
        case 3: return "Getting Legendary"
        case 4: return "Forever Friends"
        default: return "Hero's Journey"
        }
    }
}

// MARK: - Kid Header Card

struct KidHeaderCard: View {
    let kid: Kid
    let theme: AppTheme

    private var isAsset: Bool {
        AvatarCarouselPicker.avatars.contains(kid.avatar)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Avatar circle
            ZStack {
                Circle()
                    .fill(Color(hex: theme.primaryColor).opacity(0.2))
                    .frame(width: 56, height: 56)

                if isAsset {
                    Image(kid.avatar)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                } else {
                    Image(systemName: kid.avatar)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(Color(hex: theme.primaryColor))
                }

                Circle()
                    .stroke(Color(hex: theme.primaryColor), lineWidth: 2)
                    .frame(width: 56, height: 56)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("Hey, \(kid.name)!")
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(.white)
                }
                HStack(spacing: 4) {
                    Image(systemName: "calendar.circle.fill")
                        .font(.caption)
                        .foregroundColor(Color(hex: theme.accentColor))
                    Text("Week \(kid.currentWeek) of 4")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            // Coin badge
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(Color(hex: theme.accentColor))
                Text("\(kid.totalCoins)")
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundColor(Color(hex: theme.accentColor))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Color(hex: theme.accentColor).opacity(0.15))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: theme.accentColor).opacity(0.35), lineWidth: 1)
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
}

// MARK: - Quest Section

struct QuestSection: View {
    let title: String
    let icon: String
    let quests: [Quest]
    let theme: AppTheme
    let emptyMessage: String
    let onComplete: (Quest) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color(hex: theme.primaryColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if !quests.isEmpty {
                    Text("\(quests.count) left")
                        .font(.caption)
                        .foregroundColor(Color(hex: theme.accentColor))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: theme.accentColor).opacity(0.15))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)

            if quests.isEmpty && !emptyMessage.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color(hex: theme.primaryColor))
                    Text(emptyMessage)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color.white.opacity(0.05))
                .cornerRadius(14)
                .padding(.horizontal, 20)
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(quests.enumerated()), id: \.element.id) { index, quest in
                        AnimatedQuestCard(quest: quest, theme: theme, delay: Double(index) * 0.06) {
                            onComplete(quest)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
    }
}

// MARK: - Animated Stat Box

struct AnimatedStatBox: View {
    let label: String
    let value: String
    let icon: String
    let iconColor: Color
    let theme: AppTheme
    let visible: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.06))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .scaleEffect(visible ? 1 : 0.7)
        .opacity(visible ? 1 : 0)
    }
}

// MARK: - Animated Quest Card

struct AnimatedQuestCard: View {
    let quest: Quest
    let theme: AppTheme
    let delay: Double
    let action: () -> Void

    @State private var appeared = false
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    isPressed = false
                }
                action()
            }
        }) {
            HStack(spacing: 14) {
                // Icon bubble
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: theme.primaryColor).opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: quest.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: theme.primaryColor))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.name)
                        .font(.subheadline).fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(quest.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 3) {
                        Text("+\(quest.coins)")
                            .font(.subheadline).fontWeight(.bold)
                            .foregroundColor(Color(hex: theme.accentColor))
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: theme.accentColor))
                    }
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: theme.primaryColor).opacity(0.6))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: theme.primaryColor).opacity(0.25), lineWidth: 1)
                    )
            )
        }
        .scaleEffect(isPressed ? 0.95 : (appeared ? 1.0 : 0.85))
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7).delay(delay)) {
                appeared = true
            }
        }
    }
}

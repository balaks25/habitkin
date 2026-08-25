//
//  ProgressView.swift
//  habitkin
//
//  Created by Balaji K S on 26/04/26.
//

import SwiftUI

struct ProgressTabView: View {
    let kid: Kid

    var theme: AppTheme { kid.theme }

    @State private var headerVisible = false
    @State private var evolutionVisible = false
    @State private var badgesVisible = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: theme.secondaryColor),
                    Color(hex: theme.secondaryColor).opacity(0.7),
                    Color(hex: theme.primaryColor).opacity(0.12)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                ZStack {
                    // Decorative bubbles
                    GeometryReader { geo in
                        Circle()
                            .fill(Color(hex: theme.primaryColor).opacity(0.06))
                            .frame(width: 120, height: 120)
                            .offset(x: -30, y: geo.size.height * 0.5)
                        Circle()
                            .fill(Color(hex: theme.accentColor).opacity(0.07))
                            .frame(width: 180, height: 180)
                            .offset(x: geo.size.width - 60, y: 80)
                    }
                    .ignoresSafeArea()
                    
                    VStack(spacing: 22) {

                        // ── Stats Banner ─────────────────────────────
                        HStack(spacing: 12) {
                            ProgressStatPill(
                                icon: "star.fill",
                                iconColor: Color(hex: theme.accentColor),
                                value: "\(kid.totalEarned)",
                                label: "Total Coins"
                            )
                            ProgressStatPill(
                                icon: "checkmark.seal.fill",
                                iconColor: .green,
                                value: "\(kid.totalCompleted)",
                                label: "Quests Done"
                            )
                            ProgressStatPill(
                                icon: "bolt.fill",
                                iconColor: .orange,
                                value: "Lv \(kid.totalCompleted / 5 + 1)",
                                label: "Level"
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .opacity(headerVisible ? 1 : 0)
                        .offset(y: headerVisible ? 0 : 16)
                        .onAppear {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                headerVisible = true
                            }
                        }

                        // ── Evolution Path ───────────────────────────
                        SectionCard(
                            icon: "sparkles",
                            title: "Evolution Path",
                            theme: theme
                        ) {
                            HStack(alignment: .top, spacing: 0) {
                                ForEach(Array(["egg", "hatch", "evolve", "ultimate"].enumerated()), id: \.element) { index, stage in
                                    AnimatedEvolutionStage(
                                        stage: stage,
                                        icon: theme.creatures[stage],
                                        isUnlocked: isStageUnlocked(stage),
                                        isCurrent: kid.kinStage == stage,
                                        theme: theme,
                                        delay: Double(index) * 0.12
                                    )

                                    if index < 3 {
                                        // Connector arrow — centered on the stage circle, not the full row height
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(
                                                isStageUnlocked(["egg","hatch","evolve","ultimate"][index + 1])
                                                ? Color(hex: theme.primaryColor).opacity(0.6)
                                                : Color.white.opacity(0.15)
                                            )
                                            .frame(height: 54)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        .padding(.horizontal, 20)
                        .opacity(evolutionVisible ? 1 : 0)
                        .offset(y: evolutionVisible ? 0 : 20)
                        .onAppear {
                            withAnimation(.spring(response: 0.55, dampingFraction: 0.7).delay(0.15)) {
                                evolutionVisible = true
                            }
                        }

                        // ── Weekly Journey ───────────────────────────
                        SectionCard(
                            icon: "calendar.badge.checkmark",
                            title: "Weekly Journey",
                            theme: theme
                        ) {
                            VStack(spacing: 10) {
                                ForEach(1...4, id: \.self) { week in
                                    AnimatedWeekRow(
                                        week: week,
                                        isCompleted: kid.hasCompletedWeek(week),
                                        isSkipped: kid.wasWeekSkipped(week),
                                        isCurrent: kid.currentWeek == week,
                                        theme: theme,
                                        delay: Double(week) * 0.08
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // ── Badges ───────────────────────────────────
                        SectionCard(
                            icon: "medal.fill",
                            title: "Badges",
                            theme: theme
                        ) {
                            VStack(spacing: 10) {
                                AnimatedBadgeRow(
                                    title: "First Quest",
                                    description: "Complete your first quest",
                                    icon: "star.fill",
                                    unlocked: kid.totalCompleted >= 1,
                                    theme: theme,
                                    delay: 0
                                )
                                AnimatedBadgeRow(
                                    title: "Week Warrior",
                                    description: "Complete a full week",
                                    icon: "calendar.circle.fill",
                                    unlocked: (1..<Kid.finalWeek).contains { kid.hasCompletedWeek($0) },
                                    theme: theme,
                                    delay: 0.07
                                )
                                AnimatedBadgeRow(
                                    title: "Streak Master",
                                    description: "Reach a 7-day streak",
                                    icon: "flame.fill",
                                    unlocked: kid.streak >= 7,
                                    theme: theme,
                                    delay: 0.14
                                )
                                AnimatedBadgeRow(
                                    title: "Century Club",
                                    description: "Complete 100 quests",
                                    icon: "checkmark.seal.fill",
                                    unlocked: kid.totalCompleted >= 100,
                                    theme: theme,
                                    delay: 0.21
                                )
                                AnimatedBadgeRow(
                                    title: "Evolution Master",
                                    description: "Reach the ultimate stage",
                                    icon: "crown.fill",
                                    unlocked: kid.kinStage == "ultimate",
                                    theme: theme,
                                    delay: 0.28
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .opacity(badgesVisible ? 1 : 0)
                        .offset(y: badgesVisible ? 0 : 20)
                        .onAppear {
                            withAnimation(.spring(response: 0.55, dampingFraction: 0.7).delay(0.3)) {
                                badgesVisible = true
                            }
                        }

                        Spacer(minLength: 80)
                    }
                    .padding(.vertical, 20)
                }
            }
        }
    }

    private func isStageUnlocked(_ stage: String) -> Bool {
        let stages = ["egg", "hatch", "evolve", "ultimate"]
        guard let currentIndex = stages.firstIndex(of: kid.kinStage),
              let stageIndex = stages.firstIndex(of: stage) else { return stage == "egg" }
        return stageIndex <= currentIndex
    }
}

// MARK: - Section Card wrapper

struct SectionCard<Content: View>: View {
    let icon: String
    let title: String
    let theme: AppTheme
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(Color(hex: theme.primaryColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()
            }

            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: theme.primaryColor).opacity(0.18), lineWidth: 1)
                )
        )
    }
}

// MARK: - Progress Stat Pill

struct ProgressStatPill: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.06))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Animated Evolution Stage

struct AnimatedEvolutionStage: View {
    let stage: String
    let icon: String
    let isUnlocked: Bool
    let isCurrent: Bool
    let theme: AppTheme
    let delay: Double

    @State private var appeared = false
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isCurrent
                        ? Color(hex: theme.primaryColor).opacity(0.2)
                        : (isUnlocked ? Color.white.opacity(0.08) : Color.white.opacity(0.04))
                    )
                    .frame(width: 54, height: 54)

                if isCurrent {
                    Circle()
                        .stroke(Color(hex: theme.primaryColor).opacity(pulse ? 0.5 : 0.15), lineWidth: pulse ? 2 : 6)
                        .frame(width: 54, height: 54)
                        .scaleEffect(pulse ? 1.18 : 1.0)
                        .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: pulse)
                        .onAppear { pulse = true }
                }

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(
                        isCurrent ? Color(hex: theme.primaryColor)
                        : (isUnlocked ? Color.white.opacity(0.7) : Color.white.opacity(0.2))
                    )
            }

            Text(stage.capitalized)
                .font(.caption2).fontWeight(.semibold)
                .foregroundColor(
                    isCurrent ? Color(hex: theme.primaryColor)
                    : (isUnlocked ? Color.white.opacity(0.6) : Color.white.opacity(0.2))
                )

            if isCurrent {
                Image(systemName: "arrowtriangle.up.fill")
                    .font(.system(size: 8))
                    .foregroundColor(Color(hex: theme.primaryColor))
            } else {
                Spacer().frame(height: 10)
            }
        }
        .frame(maxWidth: .infinity)
        .scaleEffect(appeared ? 1 : 0.7)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.65).delay(delay)) {
                appeared = true
            }
        }
    }
}

// MARK: - Animated Week Row

struct AnimatedWeekRow: View {
    let week: Int
    let isCompleted: Bool
    /// Advanced past because it offered no quests for this child — neither
    /// completed nor locked, and saying "Done" for it would be a lie.
    var isSkipped: Bool = false
    let isCurrent: Bool
    let theme: AppTheme
    let delay: Double

    @State private var appeared = false

    private func weekTitle(_ week: Int) -> String {
        switch week {
        case 1: return "Meeting Your HabitKin"
        case 2: return "Building Our Bond"
        case 3: return "Getting Legendary"
        case 4: return "Forever Friends"
        default: return "Week \(week)"
        }
    }

    var statusIcon: String {
        if isCompleted { return "checkmark.circle.fill" }
        if isSkipped   { return "minus.circle.fill" }
        if isCurrent   { return "play.circle.fill" }
        return "lock.circle.fill"
    }

    var statusColor: Color {
        if isCompleted { return .green }
        if isSkipped   { return Color.white.opacity(0.35) }
        if isCurrent   { return Color(hex: theme.primaryColor) }
        return Color.white.opacity(0.2)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Week number bubble
            Text("W\(week)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(isCurrent ? .white : (isCompleted ? Color(hex: theme.primaryColor) : Color.white.opacity(0.3)))
                .frame(width: 38, height: 38)
                .background(
                    Circle().fill(
                        isCurrent ? Color(hex: theme.primaryColor)
                        : (isCompleted ? Color(hex: theme.primaryColor).opacity(0.15) : Color.white.opacity(0.05))
                    )
                )

            VStack(alignment: .leading, spacing: 3) {
                Text("Week \(week)")
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundColor(isCompleted || isCurrent ? .white : Color.white.opacity(0.4))
                Text(weekTitle(week))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            HStack(spacing: 5) {
                Image(systemName: statusIcon)
                    .font(.system(size: 14))
                    .foregroundColor(statusColor)
                Text(isCompleted ? "Done" : (isSkipped ? "No quests" : (isCurrent ? "Active" : "Locked")))
                    .font(.caption).fontWeight(.semibold)
                    .foregroundColor(statusColor)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isCurrent ? Color(hex: theme.primaryColor).opacity(0.12) : Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isCurrent ? Color(hex: theme.primaryColor).opacity(0.4) : Color.white.opacity(0.07), lineWidth: 1)
                )
        )
        .scaleEffect(appeared ? 1 : 0.92)
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : 16)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7).delay(delay)) {
                appeared = true
            }
        }
    }
}

// MARK: - Animated Badge Row

struct AnimatedBadgeRow: View {
    let title: String
    let description: String
    let icon: String
    let unlocked: Bool
    let theme: AppTheme
    let delay: Double

    @State private var appeared = false
    @State private var shimmer = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(unlocked
                        ? Color(hex: theme.primaryColor).opacity(0.2)
                        : Color.white.opacity(0.05)
                    )
                    .frame(width: 48, height: 48)

                if unlocked && shimmer {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: theme.accentColor).opacity(0.4), lineWidth: 1.5)
                        .frame(width: 48, height: 48)
                }

                Image(systemName: unlocked ? icon : "lock.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(unlocked ? Color(hex: theme.primaryColor) : Color.white.opacity(0.2))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundColor(unlocked ? .white : Color.white.opacity(0.35))
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            if unlocked {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: theme.accentColor))
                    .scaleEffect(shimmer ? 1.15 : 1.0)
                    .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: shimmer)
            } else {
                Text("Locked")
                    .font(.caption2).fontWeight(.semibold)
                    .foregroundColor(Color.white.opacity(0.2))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(unlocked ? Color(hex: theme.primaryColor).opacity(0.07) : Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(unlocked ? Color(hex: theme.primaryColor).opacity(0.2) : Color.white.opacity(0.06), lineWidth: 1)
                )
        )
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7).delay(delay)) {
                appeared = true
            }
            if unlocked {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.5) {
                    shimmer = true
                }
            }
        }
    }
}

// Kept for backward compat
struct EvolutionStageCard: View {
    let stage: String
    let icon: String
    let isUnlocked: Bool
    let isCurrent: Bool
    let theme: AppTheme
    var body: some View {
        AnimatedEvolutionStage(stage: stage, icon: icon, isUnlocked: isUnlocked, isCurrent: isCurrent, theme: theme, delay: 0)
    }
}
struct WeekProgressCard: View {
    let week: Int; let isCompleted: Bool; let isCurrent: Bool; let theme: AppTheme
    var body: some View { AnimatedWeekRow(week: week, isCompleted: isCompleted, isCurrent: isCurrent, theme: theme, delay: 0) }
}
struct BadgeCard: View {
    let title: String; let description: String; let icon: String; let unlocked: Bool; let theme: AppTheme
    var body: some View { AnimatedBadgeRow(title: title, description: description, icon: icon, unlocked: unlocked, theme: theme, delay: 0) }
}
struct StatsSummaryBox: View {
    let label: String; let value: String; let icon: String; let theme: AppTheme
    var body: some View { ProgressStatPill(icon: icon, iconColor: Color(hex: theme.primaryColor), value: value, label: label) }
}

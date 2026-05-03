//
//  ProgressView.swift
//  habitkin
//
//  Created by Balaji K S on 26/04/26.
//


import SwiftUI

struct ProgressTabView: View {
    let kid: Kid
    
    var theme: AppTheme {
        kid.theme
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: theme.secondaryColor),
                    Color(hex: theme.secondaryColor).opacity(0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header with Kid Switcher
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Progress")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Journey milestone")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(Color(hex: theme.primaryColor))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Kid selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            VStack(spacing: 4) {
                                Image(systemName: kid.avatar)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color(hex: theme.primaryColor))
                                    .frame(width: 50, height: 50)
                                    .background(Color(hex: theme.primaryColor).opacity(0.2))
                                    .cornerRadius(12)
                                
                                Text(kid.name)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(height: 80)
                    
                    // Creature Evolution Path
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(Color(hex: theme.primaryColor))
                            Text("Evolution Path")
                                .font(.headline)
                                .foregroundColor(Color(hex: theme.primaryColor))
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                ForEach(["egg", "hatch", "evolve", "ultimate"], id: \.self) { stage in
                                    EvolutionStageCard(
                                        stage: stage,
                                        icon: theme.creatures[stage],
                                        isUnlocked: isStageUnlocked(stage),
                                        isCurrent: kid.kinStage == stage,
                                        theme: theme
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Weekly Progress
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(Color(hex: theme.primaryColor))
                            Text("Weekly Progress")
                                .font(.headline)
                                .foregroundColor(Color(hex: theme.primaryColor))
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ForEach(1...4, id: \.self) { week in
                                WeekProgressCard(
                                    week: week,
                                    isCompleted: kid.currentWeek > week,
                                    isCurrent: kid.currentWeek == week,
                                    theme: theme
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Badges Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "star.circle.fill")
                                .foregroundColor(Color(hex: theme.primaryColor))
                            Text("Badges Earned")
                                .font(.headline)
                                .foregroundColor(Color(hex: theme.primaryColor))
                        }
                        .padding(.horizontal, 20)
                        
                        if kid.totalCompleted > 0 {
                            VStack(spacing: 12) {
                                BadgeCard(
                                    title: "First Quest",
                                    description: "Complete your first quest",
                                    icon: "star.fill",
                                    unlocked: kid.totalCompleted >= 1,
                                    theme: theme
                                )
                                
                                BadgeCard(
                                    title: "Streak Master",
                                    description: "Reach 7 day streak",
                                    icon: "flame.fill",
                                    unlocked: kid.streak >= 7,
                                    theme: theme
                                )
                                
                                BadgeCard(
                                    title: "Century",
                                    description: "Complete 100 quests",
                                    icon: "checkmark.circle.fill",
                                    unlocked: kid.totalCompleted >= 100,
                                    theme: theme
                                )
                                
                                BadgeCard(
                                    title: "Evolution Master",
                                    description: "Reach ultimate stage",
                                    icon: "sparkles",
                                    unlocked: kid.kinStage == "ultimate",
                                    theme: theme
                                )
                            }
                            .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(hex: theme.primaryColor))
                                Text("Complete quests to unlock badges!")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(20)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Stats Summary
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "chart.bar")
                                .foregroundColor(Color(hex: theme.primaryColor))
                            Text("Total Stats")
                                .font(.headline)
                                .foregroundColor(Color(hex: theme.primaryColor))
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                StatsSummaryBox(
                                    label: "Total Coins",
                                    value: "\(kid.totalEarned)",
                                    icon: "star.fill",
                                    theme: theme
                                )
                                
                                StatsSummaryBox(
                                    label: "Quests Done",
                                    value: "\(kid.totalCompleted)",
                                    icon: "checkmark.circle.fill",
                                    theme: theme
                                )
                            }
                            
                            HStack(spacing: 12) {
                                StatsSummaryBox(
                                    label: "Current Level",
                                    value: "\(kid.totalCompleted / 5 + 1)",
                                    icon: "bolt.fill",
                                    theme: theme
                                )
                                
                                StatsSummaryBox(
                                    label: "Days Active",
                                    value: "0",
                                    icon: "clock.fill",
                                    theme: theme
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 80)
                }
                .padding(.vertical, 20)
            }
        }
    }
    
    private func isStageUnlocked(_ stage: String) -> Bool {
        let stages = ["egg", "hatch", "evolve", "ultimate"]
        guard let currentIndex = stages.firstIndex(of: kid.kinStage) else { return stage == "egg" }
        guard let stageIndex = stages.firstIndex(of: stage) else { return false }
        return stageIndex <= currentIndex
    }
}

struct EvolutionStageCard: View {
    let stage: String
    let icon: String
    let isUnlocked: Bool
    let isCurrent: Bool
    let theme: AppTheme
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(isCurrent ? Color(hex: theme.primaryColor) : (isUnlocked ? Color.white.opacity(0.7) : Color.white.opacity(0.3)))
            
            Text(stage.capitalized)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(isCurrent ? Color(hex: theme.primaryColor) : (isUnlocked ? Color.white.opacity(0.7) : Color.white.opacity(0.3)))
            
            if isCurrent {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: theme.primaryColor))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(isCurrent ? Color(hex: theme.primaryColor).opacity(0.15) : Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrent ? Color(hex: theme.primaryColor) : Color.clear, lineWidth: 2)
        )
        .opacity(isUnlocked ? 1 : 0.5)
    }
}

struct WeekProgressCard: View {
    let week: Int
    let isCompleted: Bool
    let isCurrent: Bool
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Week \(week)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: theme.primaryColor))
                    } else if isCurrent {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: theme.primaryColor))
                    }
                }
                
                Text(getWeekTitle(week))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isCompleted {
                Text("Complete")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: theme.primaryColor))
            } else if isCurrent {
                Text("In Progress")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: theme.primaryColor))
            } else {
                Text("Locked")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .background(isCompleted ? Color(hex: theme.primaryColor).opacity(0.1) : Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrent ? Color(hex: theme.primaryColor) : Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func getWeekTitle(_ week: Int) -> String {
        switch week {
        case 1: return "Meeting Your HabitKin"
        case 2: return "Building Our Bond"
        case 3: return "Getting Legendary"
        case 4: return "Forever Friends"
        default: return "Week \(week)"
        }
    }
}

struct BadgeCard: View {
    let title: String
    let description: String
    let icon: String
    let unlocked: Bool
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(unlocked ? Color(hex: theme.primaryColor) : Color.white.opacity(0.3))
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(unlocked ? .white : Color.white.opacity(0.5))
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if unlocked {
                Image(systemName: "star.fill")
                    .foregroundColor(Color(hex: theme.primaryColor))
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(Color.white.opacity(0.3))
            }
        }
        .padding(12)
        .background(unlocked ? Color(hex: theme.primaryColor).opacity(0.1) : Color.white.opacity(0.03))
        .cornerRadius(12)
        .opacity(unlocked ? 1 : 0.6)
    }
}

struct StatsSummaryBox: View {
    let label: String
    let value: String
    let icon: String
    let theme: AppTheme
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: theme.primaryColor))
            
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    ProgressTabView(kid: Kid(
        id: UUID(),
        name: "Alex",
        avatar: "person.fill",
        age: 7,
        characterId: "screen_zombie",
        themeId: "space",
        createdDate: Date()
    ))
}

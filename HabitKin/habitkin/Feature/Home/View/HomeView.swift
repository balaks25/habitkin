//
//  HomeView.swift
//  habitkin
//
//  Created by Balaji K S on 23/04/26.
//

import SwiftUI

struct HomeView: View {
    let kid: Kid
    @State private var showCelebration = false
    @State private var celebrationMessage = ""
    
    var theme: AppTheme {
        kid.theme
    }
    
    var availableQuests: [Quest] {
        let allQuests = kid.getCurrentWeekQuests()
        let dailyQuests = allQuests.filter { $0.category == "daily" }
        let specialQuests = allQuests.filter { $0.category == "special" }
        
        return dailyQuests + specialQuests
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
                            Text(kid.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Week \(kid.currentWeek)/4")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Add new kid button
                        Button(action: {}) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(Color(hex: theme.primaryColor))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Kid selector (horizontal scroll for multiple kids)
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
                    
                    // Creature Card
                    VStack(spacing: 16) {
                        Image(systemName: theme.creatures[kid.kinStage])
                            .font(.system(size: 80, weight: .semibold))
                            .foregroundColor(Color(hex: theme.primaryColor))
                            .frame(height: 100)
                        
                        VStack(spacing: 4) {
                            Text("\(kid.name)'s \(theme.world)")
                                .font(.headline)
                                .foregroundColor(Color(hex: theme.primaryColor))
                            
                            Text("Stage: \(kid.kinStage.uppercased())")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        // Stats Grid
                        HStack(spacing: 12) {
                            StatBox(label: "Coins", value: "\(kid.totalCoins)", icon: "star.fill", theme: theme)
                            StatBox(label: "Streak", value: "\(kid.streak)", icon: "flame.fill", theme: theme)
                            StatBox(label: "Done", value: "\(kid.totalCompleted)", icon: "checkmark.circle.fill", theme: theme)
                        }
                        
                        // Progress Bar
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Progress to next stage")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: theme.primaryColor))
                                    .frame(width: CGFloat(max(kid.totalEarned % 500, 1)) / 500 * (UIScreen.main.bounds.width - 40))
                            }
                            .frame(height: 8)
                            
                            HStack {
                                Text("\(kid.totalEarned % 500)/500")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(hex: theme.primaryColor).opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // Story Hook
                    VStack(alignment: .leading, spacing: 8) {
                        Text(kid.character.storyHook)
                            .font(.headline)
                            .foregroundColor(Color(hex: theme.accentColor))
                        
                        Text("Week \(kid.currentWeek) - \(getWeekTitle(kid.currentWeek))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(12)
                    .background(Color(hex: theme.primaryColor).opacity(0.15))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Daily Quests
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(Color(hex: theme.primaryColor))
                            Text("Daily Quests")
                                .font(.headline)
                                .foregroundColor(Color(hex: theme.primaryColor))
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 10) {
                            let dailyQuests = availableQuests.filter { $0.category == "daily" }
                            
                            if dailyQuests.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "star.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(Color(hex: theme.primaryColor))
                                    Text("All daily quests completed!")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(20)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                            } else {
                                ForEach(dailyQuests) { quest in
                                    QuestCard(quest: quest, theme: theme) {
                                        completeQuest(quest)
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    
                    // Special Missions
                    let specialQuests = availableQuests.filter { $0.category == "special" }
                    
                    if !specialQuests.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(Color(hex: theme.primaryColor))
                                Text("Special Missions")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: theme.primaryColor))
                            }
                            .padding(.horizontal, 20)
                            
                            VStack(spacing: 10) {
                                ForEach(specialQuests) { quest in
                                    QuestCard(quest: quest, theme: theme) {
                                        completeQuest(quest)
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 80)
                }
                .padding(.vertical, 20)
            }
            
            // Celebration Animation
            if showCelebration {
                CelebrationView(message: celebrationMessage, theme: theme)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    private func completeQuest(_ quest: Quest) {
        celebrationMessage = "+\(quest.coins)\n\(quest.name)"
        showCelebration = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCelebration = false
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

#Preview {
    HomeView(kid: Kid(
        id: UUID(),
        name: "Alex",
        avatar: "person.fill",
        age: 7,
        characterId: "screen_zombie",
        themeId: "space",
        createdDate: Date()
    ))
}

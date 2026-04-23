//
//  HomeView.swift
//  habitkin
//
//  Created by Balaji K S on 23/04/26.
//


import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var showQuestDetail: Quest?
    
    init(kid: Kid) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(kid: kid))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: viewModel.kid.theme.secondaryColor),
                    Color(hex: viewModel.kid.theme.secondaryColor).opacity(0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text(viewModel.kid.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Week \(viewModel.kid.currentWeek)/4")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(viewModel.kid.avatar)
                            .font(.system(size: 40))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // HabitKin Card
                    KinCard(kid: viewModel.kid, theme: viewModel.kid.theme)
                        .padding(.horizontal, 20)
                    
                    // Story Hook
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.kid.character.storyHook)
                            .font(.headline)
                            .foregroundColor(Color(hex: viewModel.kid.theme.accentColor))
                        
                        Text("Week \(viewModel.kid.currentWeek) Journey")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(12)
                    .background(Color(hex: viewModel.kid.theme.primaryColor).opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Quests Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Quests")
                            .font(.headline)
                            .foregroundColor(Color(hex: viewModel.kid.theme.primaryColor))
                        
                        if viewModel.availableQuests.isEmpty {
                            VStack(spacing: 12) {
                                Text("🎉")
                                    .font(.system(size: 40))
                                Text("All quests completed today!")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(20)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(viewModel.availableQuests) { quest in
                                    QuestRow(
                                        quest: quest,
                                        theme: viewModel.kid.theme,
                                        action: {
                                            viewModel.completeQuest(quest)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Completed Today
                    if !viewModel.completedToday.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("✅ Completed Today (\(viewModel.completedToday.count))")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            VStack(spacing: 8) {
                                ForEach(viewModel.completedToday) { quest in
                                    HStack {
                                        Text(quest.icon)
                                        Text(quest.name)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("+\(quest.coins)")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                    }
                                    .padding(8)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 20)
            }
            
            // Celebration Animation
            if viewModel.showCelebration {
                CelebrationView(message: viewModel.celebrationMessage)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            viewModel.loadQuests()
        }
    }
}

struct KinCard: View {
    let kid: Kid
    let theme: AppTheme
    
    var body: some View {
        VStack(spacing: 16) {
            // Creature
            VStack {
                Text(theme.creatures[kid.kinStage])
                    .font(.system(size: 100))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .baselineOffset(10)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            
            // Info
            VStack(spacing: 4) {
                Text("\(kid.name)'s \(theme.world)")
                    .font(.headline)
                    .foregroundColor(Color(hex: theme.primaryColor))
                
                Text("Level \(kid.totalCompleted / 5 + 1) - \(kid.kinStage.uppercased())")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Stats Grid
            HStack(spacing: 16) {
                StatBox(label: "Coins", value: "\(kid.totalCoins)", icon: "🪙", theme: theme)
                StatBox(label: "Streak", value: "\(kid.streak)", icon: "🔥", theme: theme)
                StatBox(label: "Done", value: "\(kid.totalCompleted)", icon: "✅", theme: theme)
            }
            
            // XP Bar
            VStack(alignment: .leading, spacing: 8) {
                Text("Progress to next stage")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: theme.primaryColor))
                        .frame(width: CGFloat(kid.totalEarned % 500) / 5)
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
    }
}

struct QuestRow: View {
    let quest: Quest
    let theme: AppTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(quest.icon)
                    .font(.system(size: 28))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(quest.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("+\(quest.coins)")
                        .font(.headline)
                        .foregroundColor(Color(hex: theme.primaryColor))
                    Text("🪙")
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: theme.primaryColor).opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct StatBox: View {
    let label: String
    let value: String
    let icon: String
    let theme: AppTheme
    
    var body: some View {
        VStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 20))
            Text(value)
                .font(.headline)
                .foregroundColor(Color(hex: theme.primaryColor))
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

struct CelebrationView: View {
    let message: String
    
    var body: some View {
        VStack {
            VStack(spacing: 12) {
                Text("🎉")
                    .font(.system(size: 60))
                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(30)
            .background(Color.black.opacity(0.7))
            .cornerRadius(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4))
    }
}

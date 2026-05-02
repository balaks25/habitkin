//
//  RewardsView.swift
//  habitkin
//
//  Created by Balaji K S on 02/05/26.
//


import SwiftUI

struct RewardsView: View {
    let kid: Kid
    @State private var selectedCategory = "all"
    @State private var claimedRewards: [String] = []
    @State private var showCelebration = false
    @State private var celebrationMessage = ""
    
    var theme: AppTheme {
        kid.theme
    }
    
    var filteredRewards: [Reward] {
        if selectedCategory == "all" {
            return Reward.rewardLibrary
        }
        return Reward.rewardsByCategory(selectedCategory)
    }
    
    let categories = [
        ("all", "All Rewards", "gift.fill"),
        ("screen_time", "Screen Time", "iphone"),
        ("treat", "Treats", "fork.knife"),
        ("activity", "Activities", "star.fill"),
    ]
    
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
                            Text("Rewards")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Spend your coins")
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
                    
                    // Coins Display
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(hex: theme.primaryColor))
                                .font(.system(size: 20))
                            
                            Text("Your Coins")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(kid.totalCoins)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(hex: theme.primaryColor))
                        }
                        .padding(16)
                        .background(Color(hex: theme.primaryColor).opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    
                    // Category Filter
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Filter by Category")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(categories, id: \.0) { id, name, icon in
                                    Button(action: { selectedCategory = id }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: icon)
                                                .font(.system(size: 14, weight: .semibold))
                                            Text(name)
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                        }
                                        .foregroundColor(selectedCategory == id ? Color(hex: theme.primaryColor) : .white.opacity(0.7))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == id ? Color(hex: theme.primaryColor).opacity(0.2) : Color.white.opacity(0.05))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Rewards Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(filteredRewards.count) Rewards Available")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ForEach(filteredRewards) { reward in
                                RewardCard(
                                    reward: reward,
                                    theme: theme,
                                    isClaimed: claimedRewards.contains(reward.id),
                                    kidCoins: kid.totalCoins,
                                    onClaim: {
                                        claimReward(reward)
                                    }
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    // Claimed Rewards Section
                    if !claimedRewards.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: theme.primaryColor))
                                Text("Claimed Rewards")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            
                            VStack(spacing: 8) {
                                ForEach(Reward.rewardLibrary.filter { claimedRewards.contains($0.id) }) { reward in
                                    HStack {
                                        Image(systemName: reward.icon)
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(Color(hex: theme.primaryColor))
                                            .frame(width: 40)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(reward.name)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text(reward.description)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color(hex: theme.primaryColor))
                                    }
                                    .padding(12)
                                    .background(Color(hex: theme.primaryColor).opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 20)
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
    
    private func claimReward(_ reward: Reward) {
        if kid.totalCoins >= reward.coinsCost {
            claimedRewards.append(reward.id)
            celebrationMessage = "\(reward.name)\nClaimed!"
            showCelebration = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showCelebration = false
            }
        }
    }
}

struct RewardCard: View {
    let reward: Reward
    let theme: AppTheme
    let isClaimed: Bool
    let kidCoins: Int
    let onClaim: () -> Void
    
    var canAfford: Bool {
        kidCoins >= reward.coinsCost
    }
    
    var rarityColor: Color {
        switch reward.rarity {
        case "common":
            return Color.white.opacity(0.7)
        case "rare":
            return Color(hex: "#3B82F6")
        case "epic":
            return Color(hex: "#A855F7")
        case "legendary":
            return Color(hex: "#FBBF24")
        default:
            return Color.white.opacity(0.5)
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: reward.icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(canAfford && !isClaimed ? Color(hex: theme.primaryColor) : rarityColor)
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(reward.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(reward.rarity.uppercased())
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(rarityColor)
                    }
                    
                    Text(reward.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("\(reward.coinsCost)")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundColor(Color(hex: theme.primaryColor))
                
                Spacer()
                
                if isClaimed {
                    Button(action: {}) {
                        Text("Claimed")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: theme.primaryColor))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: theme.primaryColor).opacity(0.2))
                            .cornerRadius(6)
                    }
                    .disabled(true)
                } else {
                    Button(action: onClaim) {
                        Text("Claim")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(canAfford ? Color(hex: theme.primaryColor) : Color.white.opacity(0.2))
                            .cornerRadius(6)
                    }
                    .disabled(!canAfford)
                    .opacity(canAfford ? 1 : 0.5)
                }
            }
        }
        .padding(12)
        .background(
            isClaimed ? Color(hex: theme.primaryColor).opacity(0.1) : (canAfford ? Color.white.opacity(0.05) : Color.white.opacity(0.03))
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(canAfford && !isClaimed ? Color(hex: theme.primaryColor).opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    RewardsView(kid: Kid(
        id: UUID(),
        name: "Alex",
        avatar: "person.fill",
        age: 7,
        characterId: "screen_zombie",
        themeId: "space",
        createdDate: Date()
    ))
}

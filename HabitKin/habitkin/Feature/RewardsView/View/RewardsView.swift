//
//  RewardsView.swift
//  habitkin
//
//  Created by Balaji K S on 02/05/26.
//


import SwiftUI

struct RewardsView: View {
    let kid: Kid

    @ObservedObject private var catalog = CatalogManager.shared
    @ObservedObject private var manager = KidsManager.shared

    @State private var selectedCategory = "all"
    @State private var showCelebration = false
    @State private var celebrationMessage = ""
    @State private var actionNotice: String?

    init(kid: Kid) {
        self.kid = kid
    }

    var theme: AppTheme {
        kid.theme
    }
    
    var filteredRewards: [Reward] {
        let rewards = catalog.availableRewards(for: kid)
        guard selectedCategory != "all" else { return rewards }
        return rewards.filter { $0.category == selectedCategory }
    }
    
    // "Special" was missing here, which left the 600-coin Ultimate Prize
    // reachable only through the "All" tab.
    let categories = [
        ("all", "All Rewards", "gift.fill"),
        ("screen_time", "Screen Time", "iphone"),
        ("treat", "Treats", "fork.knife"),
        ("activity", "Activities", "star.fill"),
        ("special", "Special", "crown.fill"),
    ]
    
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
                    // Decorative bubbles in background
                    GeometryReader { geo in
                        Circle()
                            .fill(Color(hex: theme.primaryColor).opacity(0.08))
                            .frame(width: 180, height: 180)
                            .offset(x: geo.size.width - 80, y: -40)
                        Circle()
                            .fill(Color(hex: theme.accentColor).opacity(0.06))
                            .frame(width: 120, height: 120)
                            .offset(x: -40, y: geo.size.height * 0.4)
                    }
                    .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
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
                                        isClaimed: kid.claimedRewardIds.contains(reward.id),
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
                        if !kid.claimedRewardIds.isEmpty {
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
                                    ForEach(catalog.allRewards(for: kid).filter { kid.claimedRewardIds.contains($0.id) }) { reward in
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
            }
            
            if let actionNotice {
                VStack {
                    Spacer()
                    Text(actionNotice)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 18).padding(.vertical, 12)
                        .background(Color.black.opacity(0.75))
                        .cornerRadius(12)
                        .padding(.bottom, 110)
                }
                .transition(.opacity)
            }

            // Celebration Animation
            if showCelebration {
                CelebrationView(message: celebrationMessage, theme: theme)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    private func claimReward(_ reward: Reward) {
        guard manager.claimReward(reward, for: kid) else {
            let reason = kid.claimedRewardIds.contains(reward.id)
                ? "You've already claimed \(reward.name)."
                : "You need \(reward.coinsCost - kid.totalCoins) more coins."
            withAnimation(.easeInOut(duration: 0.2)) { actionNotice = reason }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut(duration: 0.25)) { actionNotice = nil }
            }
            return
        }
        Feedback.rewardClaimed()

        celebrationMessage = "\(reward.name)\nClaimed!"
        showCelebration = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCelebration = false
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

//
//  ParentDashboardView.swift
//  habitkin
//
//  Created by Balaji K S on 03/05/26.
//

import SwiftUI

struct ParentDashboardView: View {
    let kid: Kid
    let theme: AppTheme
    
    @State private var selectedSection = 0
    @State private var showAddQuest = false
    @State private var showAddReward = false
    @State private var showAdjustPoints = false
    @StateObject private var session = ParentSession.shared
    
    let sections = ["Quests", "Rewards", "Points"]
    
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
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Image(systemName: "lock.open.fill")
                                    .foregroundColor(Color(hex: theme.primaryColor))
                                Text("Parent Dashboard")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            Text("Managing \(kid.name)'s journey")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Lock button
                        Button(action: { session.lock() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Lock")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(Color(hex: theme.primaryColor))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: theme.primaryColor).opacity(0.15))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Section Picker
                    HStack(spacing: 0) {
                        ForEach(sections.indices, id: \.self) { index in
                            Button(action: { selectedSection = index }) {
                                Text(sections[index])
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(selectedSection == index ? Color(hex: theme.primaryColor) : Color.white.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        selectedSection == index
                                        ? Color(hex: theme.primaryColor).opacity(0.15)
                                        : Color.clear
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .background(Color.white.opacity(0.03))
                }
                
                // Section Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        switch selectedSection {
                        case 0:
                            ManageQuestsSection(kid: kid, theme: theme, showAdd: $showAddQuest)
                        case 1:
                            ManageRewardsSection(kid: kid, theme: theme, showAdd: $showAddReward)
                        case 2:
                            ManagePointsSection(kid: kid, theme: theme, showAdjust: $showAdjustPoints)
                        default:
                            EmptyView()
                        }
                        
                        Spacer(minLength: 80)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .sheet(isPresented: $showAddQuest) {
            AddQuestSheet(kid: kid, theme: theme, isPresented: $showAddQuest)
        }
        .sheet(isPresented: $showAddReward) {
            AddRewardSheet(kid: kid, theme: theme, isPresented: $showAddReward)
        }
        .sheet(isPresented: $showAdjustPoints) {
            AdjustPointsSheet(kid: kid, theme: theme, isPresented: $showAdjustPoints)
        }
    }
}

// MARK: - Manage Quests Section
struct ManageQuestsSection: View {
    let kid: Kid
    let theme: AppTheme
    @Binding var showAdd: Bool
    
    var kidQuests: [Quest] {
        Quest.questLibrary.filter { $0.characterIds.contains(kid.characterId) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Add Button
            Button(action: { showAdd = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                    Text("Add Custom Quest")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(Color(hex: theme.primaryColor))
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(Color(hex: theme.primaryColor).opacity(0.12))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: theme.primaryColor).opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
            
            // Quests List
            Text("Active Quests")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 20)
            
            ForEach(kidQuests) { quest in
                ManageQuestRow(quest: quest, theme: theme)
                    .padding(.horizontal, 20)
            }
        }
    }
}

struct ManageQuestRow: View {
    let quest: Quest
    let theme: AppTheme
    @State private var isActive = true
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: quest.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(isActive ? Color(hex: theme.primaryColor) : .gray)
                .frame(width: 44, height: 44)
                .background(isActive ? Color(hex: theme.primaryColor).opacity(0.1) : Color.white.opacity(0.05))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(quest.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: theme.primaryColor))
                    Text("\(quest.coins) coins · Week \(quest.week)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isActive)
                .tint(Color(hex: theme.primaryColor))
                .labelsHidden()
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Manage Rewards Section
struct ManageRewardsSection: View {
    let kid: Kid
    let theme: AppTheme
    @Binding var showAdd: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Add Button
            Button(action: { showAdd = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                    Text("Add Custom Reward")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(Color(hex: theme.primaryColor))
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(Color(hex: theme.primaryColor).opacity(0.12))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: theme.primaryColor).opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
            
            Text("All Rewards")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 20)
            
            ForEach(Reward.rewardLibrary) { reward in
                ManageRewardRow(reward: reward, theme: theme)
                    .padding(.horizontal, 20)
            }
        }
    }
}

struct ManageRewardRow: View {
    let reward: Reward
    let theme: AppTheme
    @State private var isActive = true
    
    var rarityColor: Color {
        switch reward.rarity {
        case "rare": return Color(hex: "#3B82F6")
        case "epic": return Color(hex: "#A855F7")
        case "legendary": return Color(hex: "#FBBF24")
        default: return Color.white.opacity(0.6)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: reward.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(isActive ? rarityColor : .gray)
                .frame(width: 44, height: 44)
                .background(isActive ? rarityColor.opacity(0.1) : Color.white.opacity(0.05))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(reward.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: theme.primaryColor))
                    Text("\(reward.coinsCost) coins · \(reward.rarity.uppercased())")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isActive)
                .tint(Color(hex: theme.primaryColor))
                .labelsHidden()
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Manage Points Section
struct ManagePointsSection: View {
    let kid: Kid
    let theme: AppTheme
    @Binding var showAdjust: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Current Stats Card
            VStack(spacing: 16) {
                HStack {
                    Text("Current Balance")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    PointsStatBox(label: "Available", value: "\(kid.totalCoins)", icon: "star.fill", theme: theme)
                    PointsStatBox(label: "Total Earned", value: "\(kid.totalEarned)", icon: "trophy.fill", theme: theme)
                    PointsStatBox(label: "Quests Done", value: "\(kid.totalCompleted)", icon: "checkmark.circle.fill", theme: theme)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            
            // Adjust Points Button
            Button(action: { showAdjust = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "plusminus.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                    Text("Adjust Points Manually")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(Color(hex: theme.primaryColor))
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(Color(hex: theme.primaryColor).opacity(0.12))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: theme.primaryColor).opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
            
            // Quest Coin Values
            VStack(alignment: .leading, spacing: 12) {
                Text("Quest Coin Values")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                
                ForEach(Quest.questLibrary.filter { $0.characterIds.contains(kid.characterId) }) { quest in
                    HStack(spacing: 12) {
                        Image(systemName: quest.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: theme.primaryColor))
                            .frame(width: 40, height: 40)
                            .background(Color(hex: theme.primaryColor).opacity(0.1))
                            .cornerRadius(8)
                        
                        Text(quest.name)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: theme.primaryColor))
                            Text("\(quest.coins)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: theme.primaryColor))
                        }
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct PointsStatBox: View {
    let label: String
    let value: String
    let icon: String
    let theme: AppTheme
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: theme.primaryColor))
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

// MARK: - Add Quest Sheet
struct AddQuestSheet: View {
    let kid: Kid
    let theme: AppTheme
    @Binding var isPresented: Bool
    
    @State private var questName = ""
    @State private var questDescription = ""
    @State private var coinValue = 10
    @State private var selectedIcon = "star.fill"
    @Environment(\.dismiss) var dismiss
    
    let iconOptions = ["star.fill", "heart.fill", "bolt.fill", "book.fill", "moon.fill", "sun.max.fill", "leaf.fill", "flame.fill", "wind", "sparkles", "figure.walk", "house.fill"]
    
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
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Add Custom Quest")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 24))
                    }
                }
                .padding()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Quest Name
                        FormField(label: "Quest Name", placeholder: "e.g. Clean Your Room") { textField in
                            TextField("Quest name", text: $questName)
                                .foregroundColor(.white)
                        }
                        
                        // Quest Description
                        FormField(label: "Description", placeholder: "What does this involve?") { _ in
                            TextField("Short description", text: $questDescription)
                                .foregroundColor(.white)
                        }
                        
                        // Icon picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Choose Icon")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                ForEach(iconOptions, id: \.self) { icon in
                                    Button(action: { selectedIcon = icon }) {
                                        Image(systemName: icon)
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(selectedIcon == icon ? Color(hex: theme.primaryColor) : Color.white.opacity(0.5))
                                            .frame(width: 44, height: 44)
                                            .background(selectedIcon == icon ? Color(hex: theme.primaryColor).opacity(0.2) : Color.white.opacity(0.05))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Coin Value Stepper
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Coin Value")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                Button(action: { if coinValue > 5 { coinValue -= 5 } }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(Color(hex: theme.primaryColor))
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Color(hex: theme.primaryColor))
                                    Text("\(coinValue)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("coins")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Button(action: { coinValue += 5 }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(Color(hex: theme.primaryColor))
                                }
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Save Button
                Button(action: { dismiss() }) {
                    Text("Add Quest")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(questName.isEmpty ? Color.white.opacity(0.2) : Color(hex: theme.primaryColor))
                        .cornerRadius(12)
                }
                .disabled(questName.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Adjust Points Sheet
struct AdjustPointsSheet: View {
    let kid: Kid
    let theme: AppTheme
    @Binding var isPresented: Bool
    
    @State private var adjustAmount = 10
    @State private var adjustType = "add"
    @State private var reason = ""
    @Environment(\.dismiss) var dismiss
    
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
            
            VStack(spacing: 24) {
                HStack {
                    Text("Adjust Points")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 24))
                    }
                }
                .padding()
                
                // Current balance
                HStack {
                    Text("Current Balance:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: theme.primaryColor))
                        Text("\(kid.totalCoins)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                
                // Add or Remove toggle
                HStack(spacing: 0) {
                    Button(action: { adjustType = "add" }) {
                        Text("Add Points")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(adjustType == "add" ? Color(hex: theme.primaryColor) : Color.white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(adjustType == "add" ? Color(hex: theme.primaryColor).opacity(0.15) : Color.clear)
                            .cornerRadius(8)
                    }
                    
                    Button(action: { adjustType = "remove" }) {
                        Text("Remove Points")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(adjustType == "remove" ? Color(hex: "#EF4444") : Color.white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(adjustType == "remove" ? Color(hex: "#EF4444").opacity(0.15) : Color.clear)
                            .cornerRadius(8)
                    }
                }
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                
                // Amount Stepper
                HStack {
                    Button(action: { if adjustAmount > 5 { adjustAmount -= 5 } }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(adjustType == "add" ? Color(hex: theme.primaryColor) : Color(hex: "#EF4444"))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(adjustType == "add" ? Color(hex: theme.primaryColor) : Color(hex: "#EF4444"))
                        Text("\(adjustAmount)")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: { adjustAmount += 5 }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(adjustType == "add" ? Color(hex: theme.primaryColor) : Color(hex: "#EF4444"))
                    }
                }
                .padding(.horizontal, 20)
                
                // Reason
                FormField(label: "Reason (optional)", placeholder: "e.g. Bonus for extra help") { _ in
                    TextField("Add a reason", text: $reason)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    HStack(spacing: 8) {
                        Image(systemName: adjustType == "add" ? "plus.circle.fill" : "minus.circle.fill")
                        Text("\(adjustType == "add" ? "Add" : "Remove") \(adjustAmount) Points")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(adjustType == "add" ? Color(hex: theme.primaryColor) : Color(hex: "#EF4444"))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Reusable Form Field
struct FormField<Content: View>: View {
    let label: String
    let placeholder: String
    @ViewBuilder let content: (String) -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.headline)
                .foregroundColor(.white)
            
            content(placeholder)
                .padding(12)
                .background(Color.white.opacity(0.08))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
        .padding(.horizontal, 20)
    }
}

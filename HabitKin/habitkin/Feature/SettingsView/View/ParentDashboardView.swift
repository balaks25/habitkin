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
    @StateObject private var session = ParentSession.shared
    @ObservedObject private var kidsManager = KidsManager.shared
    @ObservedObject private var catalog = CatalogManager.shared
    @Environment(\.dismiss) private var dismiss

    let sections = ["Quests", "Rewards"]

    /// Always work off the manager's copy so toggles and deletions reflect
    /// what was actually saved rather than the snapshot we were handed.
    private var liveKid: Kid {
        kidsManager.kids.first { $0.id == kid.id } ?? kid
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
                            Text("Managing \(liveKid.name)'s journey")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        // Lock button — also closes the dashboard, since leaving
                        // it open after locking defeats the point of the gate.
                        Button(action: {
                            session.lock()
                            dismiss()
                        }) {
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
                        if let message = catalog.loadState.errorMessage {
                            // Built-in quests still render from the bundle, so
                            // without this the parent's own content is simply
                            // missing with no hint that a load failed.
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(Color(hex: "#FBBF24"))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Your custom quests and rewards didn't load")
                                        .font(.caption).fontWeight(.semibold).foregroundColor(.white)
                                    Text(message).font(.caption2).foregroundColor(.gray)
                                }
                                Spacer()
                                Button("Retry") { catalog.retryLoad() }
                                    .font(.caption).fontWeight(.semibold)
                                    .foregroundColor(Color(hex: theme.primaryColor))
                            }
                            .padding(12)
                            .background(Color(hex: "#FBBF24").opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }

                        switch selectedSection {
                        case 0:
                            ManageQuestsSection(
                                kid: liveKid,
                                theme: theme,
                                showAdd: $showAddQuest,
                                quests: catalog.allQuests(for: liveKid),
                                onToggle: toggleQuest,
                                onDelete: catalog.deleteQuest
                            )
                        case 1:
                            ManageRewardsSection(
                                kid: liveKid,
                                theme: theme,
                                showAdd: $showAddReward,
                                rewards: catalog.allRewards(for: liveKid),
                                onToggle: toggleReward,
                                onDelete: catalog.deleteReward
                            )
                        default:
                            EmptyView()
                        }

                        Spacer(minLength: 80)
                    }
                    .padding(.top, 16)
                }
            }
        }
        // Auto-lock flipped isUnlocked but left this sheet open, so the parent
        // kept editing through a locked gate.
        .onChange(of: session.isUnlocked) { unlocked in
            if !unlocked { dismiss() }
        }
        .sheet(isPresented: $showAddQuest) {
            AddTaskSheet(kid: liveKid, theme: theme) { quest in
                catalog.addQuest(quest)
            }
        }
        .sheet(isPresented: $showAddReward) {
            AddRewardSheet(kid: liveKid, theme: theme) { reward in
                catalog.addReward(reward)
            }
        }
    }

    // MARK: - Actions

    private func toggleQuest(_ quest: Quest, isActive: Bool) {
        session.extendSession()
        var updated = liveKid
        if isActive {
            updated.disabledQuestIds.remove(quest.id)
        } else {
            updated.disabledQuestIds.insert(quest.id)
        }
        kidsManager.updateKid(updated)
    }

    private func toggleReward(_ reward: Reward, isActive: Bool) {
        session.extendSession()
        var updated = liveKid
        if isActive {
            updated.disabledRewardIds.remove(reward.id)
        } else {
            updated.disabledRewardIds.insert(reward.id)
        }
        kidsManager.updateKid(updated)
    }
}

// MARK: - Manage Quests Section

struct ManageQuestsSection: View {
    let kid: Kid
    let theme: AppTheme
    @Binding var showAdd: Bool
    let quests: [Quest]
    let onToggle: (Quest, Bool) -> Void
    let onDelete: (Quest) -> Void

    private var builtIn: [Quest] { quests.filter { $0.ownerKidId == nil } }
    private var custom: [Quest]  { quests.filter { $0.ownerKidId != nil } }

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

            if !custom.isEmpty {
                Text("Your Quests")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)

                ForEach(custom) { quest in
                    ManageQuestRow(
                        quest: quest,
                        theme: theme,
                        isActive: !kid.disabledQuestIds.contains(quest.id),
                        onToggle: { onToggle(quest, $0) },
                        onDelete: { onDelete(quest) }
                    )
                    .padding(.horizontal, 20)
                }
            }

            Text("Built-in Quests")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 20)

            ForEach(builtIn) { quest in
                ManageQuestRow(
                    quest: quest,
                    theme: theme,
                    isActive: !kid.disabledQuestIds.contains(quest.id),
                    onToggle: { onToggle(quest, $0) },
                    onDelete: nil
                )
                .padding(.horizontal, 20)
            }
        }
    }
}

struct ManageQuestRow: View {
    let quest: Quest
    let theme: AppTheme
    let isActive: Bool
    let onToggle: (Bool) -> Void
    /// nil for built-in quests, which can be switched off but not removed.
    let onDelete: (() -> Void)?

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
                    Text("\(quest.coins) coins · Week \(quest.week) · \(quest.isRepeatable ? "Daily" : "One-time")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            if let onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "#EF4444"))
                        .frame(width: 32, height: 32)
                }
            }

            Toggle("", isOn: Binding(get: { isActive }, set: onToggle))
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
    let rewards: [Reward]
    let onToggle: (Reward, Bool) -> Void
    let onDelete: (Reward) -> Void

    private var builtIn: [Reward] { rewards.filter { $0.ownerKidId == nil } }
    private var custom: [Reward]  { rewards.filter { $0.ownerKidId != nil } }

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

            if !custom.isEmpty {
                Text("Your Rewards")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)

                ForEach(custom) { reward in
                    ManageRewardRow(
                        reward: reward,
                        theme: theme,
                        isActive: !kid.disabledRewardIds.contains(reward.id),
                        onToggle: { onToggle(reward, $0) },
                        onDelete: { onDelete(reward) }
                    )
                    .padding(.horizontal, 20)
                }
            }

            Text("Built-in Rewards")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 20)

            ForEach(builtIn) { reward in
                ManageRewardRow(
                    reward: reward,
                    theme: theme,
                    isActive: !kid.disabledRewardIds.contains(reward.id),
                    onToggle: { onToggle(reward, $0) },
                    onDelete: nil
                )
                .padding(.horizontal, 20)
            }
        }
    }
}

struct ManageRewardRow: View {
    let reward: Reward
    let theme: AppTheme
    let isActive: Bool
    let onToggle: (Bool) -> Void
    let onDelete: (() -> Void)?

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

            if let onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "#EF4444"))
                        .frame(width: 32, height: 32)
                }
            }

            Toggle("", isOn: Binding(get: { isActive }, set: onToggle))
                .tint(Color(hex: theme.primaryColor))
                .labelsHidden()
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
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

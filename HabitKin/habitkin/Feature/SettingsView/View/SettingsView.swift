//
//  SettingsView.swift
//  habitkin
//
//  Created by Balaji K S on 26/04/26.
//

import SwiftUI

struct SettingsView: View {
    let kid: Kid

    @State private var showParentGate = false
    @State private var showParentDashboard = false
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @StateObject private var session = ParentSession.shared

    var theme: AppTheme { kid.theme }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: theme.secondaryColor), Color(hex: theme.secondaryColor).opacity(0.5)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // ── PARENT ZONE ──────────────────────────────
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: theme.primaryColor).opacity(0.15))
                                    .frame(width: 50, height: 50)
                                Image(systemName: session.isUnlocked ? "lock.open.fill" : "lock.shield.fill")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(Color(hex: theme.primaryColor))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Parent Zone")
                                    .font(.headline).fontWeight(.bold).foregroundColor(.white)
                                Text(session.isUnlocked ? "Unlocked — tap to manage" : "Add quests, rewards & adjust points")
                                    .font(.caption).foregroundColor(.gray)
                            }

                            Spacer()

                            Image(systemName: session.isUnlocked ? "checkmark.circle.fill" : "chevron.right")
                                .foregroundColor(session.isUnlocked ? Color(hex: theme.primaryColor) : Color.white.opacity(0.3))
                        }
                        .padding(16)
                        .background(LinearGradient(
                            colors: [Color(hex: theme.primaryColor).opacity(0.15), Color(hex: theme.primaryColor).opacity(0.05)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: theme.primaryColor).opacity(0.3), lineWidth: 1))
                        .onTapGesture {
                            session.isUnlocked ? (showParentDashboard = true) : (showParentGate = true)
                        }

                        if session.isUnlocked {
                            HStack(spacing: 10) {
                                ParentActionButton(icon: "plus.circle.fill",      label: "Add Quest",   theme: theme) { showParentDashboard = true }
                                ParentActionButton(icon: "gift.fill",             label: "Add Reward",  theme: theme) { showParentDashboard = true }
                                ParentActionButton(icon: "plusminus.circle.fill", label: "Points",      theme: theme) { showParentDashboard = true }
                                Button(action: { session.lock() }) {
                                    VStack(spacing: 6) {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(Color(hex: "#EF4444"))
                                            .frame(width: 44, height: 44)
                                            .background(Color(hex: "#EF4444").opacity(0.1))
                                            .cornerRadius(10)
                                        Text("Lock").font(.caption2).foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: session.isUnlocked)
                    .padding(.horizontal, 20)

                    // ── CHILD PROFILE ─────────────────────────────
                    SectionHeader(icon: "person.fill", title: "Child Profile", theme: theme)

                    VStack(spacing: 10) {
                        SettingRow(icon: "person.crop.circle.fill", label: "Name",      value: kid.name,              theme: theme, action: {})
                        SettingRow(icon: "birthday.cake.fill",      label: "Age",       value: "\(kid.age) years",    theme: theme, action: {})
                        SettingRow(icon: "sparkles",                label: "Character", value: kid.character.name,    theme: theme, action: {})
                        SettingRow(icon: "globe",                   label: "World",     value: kid.theme.world,       theme: theme, action: {})
                    }
                    .padding(.horizontal, 20)

                    // ── PREFERENCES ───────────────────────────────
                    SectionHeader(icon: "bell.fill", title: "Preferences", theme: theme)

                    VStack(spacing: 10) {
                        Toggle(isOn: $notificationsEnabled) {
                            HStack(spacing: 12) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: theme.primaryColor))
                                    .frame(width: 40)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Daily Reminders").font(.headline).foregroundColor(.white)
                                    Text("Remind about quests each day").font(.caption).foregroundColor(.gray)
                                }
                            }
                        }
                        .tint(Color(hex: theme.primaryColor))
                        .padding(12)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)

                        Toggle(isOn: $soundEnabled) {
                            HStack(spacing: 12) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: theme.primaryColor))
                                    .frame(width: 40)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Sound Effects").font(.headline).foregroundColor(.white)
                                    Text("Celebration sounds on completion").font(.caption).foregroundColor(.gray)
                                }
                            }
                        }
                        .tint(Color(hex: theme.primaryColor))
                        .padding(12)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)

                    // ── APP ───────────────────────────────────────
                    SectionHeader(icon: "info.circle.fill", title: "App", theme: theme)

                    VStack(spacing: 10) {
                        SettingRow(icon: "info", label: "Version", value: "1.0.0", theme: theme, action: {})

                        Button(action: {
                            session.isUnlocked ? print("delete") : (showParentGate = true)
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: "#EF4444"))
                                    .frame(width: 40)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Delete Child Profile").font(.headline).foregroundColor(Color(hex: "#EF4444"))
                                    Text(session.isUnlocked ? "Permanently remove this profile" : "Requires parent unlock")
                                        .font(.caption).foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: session.isUnlocked ? "chevron.right" : "lock.fill")
                                    .foregroundColor(Color.white.opacity(0.3))
                            }
                            .padding(12)
                            .background(Color(hex: "#EF4444").opacity(0.08))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 80)
                }
                .padding(.top, 16)
            }
        }
        .sheet(isPresented: $showParentGate) {
            ParentGateView(
                theme: theme,
                onSuccess: { showParentGate = false; showParentDashboard = true },
                onDismiss:  { showParentGate = false }
            )
        }
        .sheet(isPresented: $showParentDashboard) {
            ParentDashboardView(kid: kid, theme: theme)
        }
    }
}

// MARK: - Sub-components

struct SectionHeader: View {
    let icon: String
    let title: String
    let theme: AppTheme

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(Color(hex: theme.primaryColor))
            Text(title).font(.headline).foregroundColor(Color(hex: theme.primaryColor))
        }
        .padding(.horizontal, 20)
    }
}

struct SettingRow: View {
    let icon: String
    let label: String
    let value: String
    let theme: AppTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: theme.primaryColor))
                    .frame(width: 40)
                Text(label).font(.headline).foregroundColor(.white)
                Spacer()
                Text(value).font(.subheadline).foregroundColor(.gray)
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

struct ParentActionButton: View {
    let icon: String
    let label: String
    let theme: AppTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: theme.primaryColor))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: theme.primaryColor).opacity(0.15))
                    .cornerRadius(10)
                Text(label).font(.caption2).foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

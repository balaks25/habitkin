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
    @State private var showEditProfile = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleteAccountConfirmation = false
    @State private var isDeletingAccount = false
    @State private var accountError: String?
    @State private var isSigningOut = false
    @State private var unsyncedCount = 0
    @State private var showUnsyncedWarning = false
    @State private var notificationPermission: NotificationService.Permission = .notDetermined
    /// What to open once the PIN gate is cleared.
    @State private var pendingAction: ParentAction = .dashboard

    private enum ParentAction { case dashboard, editProfile, deleteProfile, deleteAccount }
    @StateObject private var session = ParentSession.shared
    @ObservedObject private var prefs = AppPreferences.shared
    @ObservedObject private var kidsManager = KidsManager.shared
    @AppStorage("isSignedIn") private var isSignedIn = true

    /// The manager's copy, so an edit made in the sheet shows up here at once.
    private var liveKid: Kid {
        kidsManager.kids.first { $0.id == kid.id } ?? kid
    }

    var theme: AppTheme { kid.theme }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build   = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

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
                            .fill(Color(hex: theme.accentColor).opacity(0.07))
                            .frame(width: 140, height: 140)
                            .offset(x: geo.size.width - 50, y: 20)
                        Circle()
                            .fill(Color(hex: theme.primaryColor).opacity(0.06))
                            .frame(width: 160, height: 160)
                            .offset(x: -80, y: geo.size.height * 0.2)
                    }
                    .ignoresSafeArea()
                    
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
                            .onTapGesture { requestParentAction(.dashboard) }

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
                            SettingRow(icon: "person.crop.circle.fill", label: "Name",      value: liveKid.name,           theme: theme, action: editProfile)
                            SettingRow(icon: "birthday.cake.fill",      label: "Age",       value: "\(liveKid.age) years", theme: theme, action: editProfile)
                            SettingRow(icon: "sparkles",                label: "Character", value: liveKid.character.name, theme: theme, action: editProfile)
                            SettingRow(icon: "globe",                   label: "World",     value: liveKid.theme.world,    theme: theme, action: editProfile)
                        }
                        .padding(.horizontal, 20)

                        // ── PREFERENCES ───────────────────────────────
                        SectionHeader(icon: "bell.fill", title: "Preferences", theme: theme)

                        VStack(spacing: 10) {
                            Toggle(isOn: $prefs.notificationsEnabled) {
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

                            // A toggle sitting ON while iOS has notifications
                            // blocked promises reminders that never arrive.
                            if prefs.notificationsEnabled && notificationPermission == .denied {
                                HStack(spacing: 10) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(Color(hex: "#FBBF24"))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Notifications are off in iOS Settings")
                                            .font(.caption).fontWeight(.semibold).foregroundColor(.white)
                                        Text("Reminders can't be delivered until you allow them.")
                                            .font(.caption2).foregroundColor(.gray)
                                    }
                                    Spacer()
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        Link("Open", destination: url)
                                            .font(.caption).fontWeight(.semibold)
                                            .foregroundColor(Color(hex: theme.primaryColor))
                                    }
                                }
                                .padding(12)
                                .background(Color(hex: "#FBBF24").opacity(0.1))
                                .cornerRadius(12)
                            }

                            // reminderHour was persisted with no way to change it,
                            // so the reminder was hard-wired to 5pm.
                            if prefs.notificationsEnabled {
                                HStack(spacing: 12) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color(hex: theme.primaryColor))
                                        .frame(width: 40)
                                    Text("Reminder Time").font(.headline).foregroundColor(.white)
                                    Spacer()
                                    DatePicker("",
                                               selection: Binding(
                                                   get: { prefs.reminderTime },
                                                   set: { prefs.reminderTime = $0 }
                                               ),
                                               displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                }
                                .padding(12)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                            }

                            Toggle(isOn: $prefs.soundEnabled) {
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
                            SettingRow(icon: "info", label: "Version", value: appVersion, theme: theme, action: {})

                            Button(action: requestSignOut) {
                                HStack(spacing: 12) {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color(hex: theme.primaryColor))
                                        .frame(width: 40)
                                    Text(isSigningOut ? "Signing out…" : "Sign Out")
                                        .font(.headline).foregroundColor(.white)
                                    Spacer()
                                    if isSigningOut { ProgressView().tint(.white) }
                                }
                                .padding(12)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                            }
                            .disabled(isSigningOut)

                            Button(action: {
                                requestParentAction(.deleteProfile)
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

                            Button(action: { requestParentAction(.deleteAccount) }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "person.crop.circle.badge.xmark")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color(hex: "#EF4444"))
                                        .frame(width: 40)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Delete Account").font(.headline).foregroundColor(Color(hex: "#EF4444"))
                                        Text("Removes your account and every child profile")
                                            .font(.caption).foregroundColor(.gray)
                                    }
                                    Spacer()
                                    if isDeletingAccount {
                                        ProgressView().tint(Color(hex: "#EF4444"))
                                    } else {
                                        Image(systemName: session.isUnlocked ? "chevron.right" : "lock.fill")
                                            .foregroundColor(Color.white.opacity(0.3))
                                    }
                                }
                                .padding(12)
                                .background(Color(hex: "#EF4444").opacity(0.08))
                                .cornerRadius(12)
                            }
                            .disabled(isDeletingAccount)
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 80)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .sheet(isPresented: $showParentGate) {
            ParentGateView(
                theme: theme,
                onSuccess: { showParentGate = false; perform(pendingAction) },
                onDismiss:  { showParentGate = false }
            )
        }
        .sheet(isPresented: $showParentDashboard) {
            ParentDashboardView(kid: liveKid, theme: theme)
        }
        .sheet(isPresented: $showEditProfile) {
            EditKidSheet(kid: liveKid)
        }
        .alert("Delete \(liveKid.name)'s profile?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                kidsManager.removeKid(liveKid)
            }
        } message: {
            Text("This permanently removes the profile along with all coins, quest history and claimed rewards. This cannot be undone.")
        }
        .alert("Delete your account?", isPresented: $showDeleteAccountConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Account", role: .destructive) { deleteAccount() }
        } message: {
            Text("This permanently deletes your account and every child profile, along with all coins, quest history and rewards. This cannot be undone.")
        }
        .alert("Unsynced changes", isPresented: $showUnsyncedWarning) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out Anyway", role: .destructive) { completeSignOut() }
        } message: {
            Text("\(unsyncedCount) change\(unsyncedCount == 1 ? "" : "s") haven't reached the server yet. Signing out now discards them. Reconnect and try again to keep them.")
        }
        .alert("Couldn't delete your account",
               isPresented: Binding(get: { accountError != nil },
                                    set: { if !$0 { accountError = nil } })) {
            Button("OK", role: .cancel) { accountError = nil }
        } message: {
            Text(accountError ?? "")
        }
        .task { await refreshNotificationPermission() }
        .onChange(of: prefs.notificationsEnabled) { isOn in
            Task { await applyNotificationPreference(isOn) }
        }
        .onChange(of: prefs.reminderHour)   { _ in NotificationService.rescheduleIfAuthorized(prefs) }
        .onChange(of: prefs.reminderMinute) { _ in NotificationService.rescheduleIfAuthorized(prefs) }
    }

    private func editProfile() { requestParentAction(.editProfile) }

    /// Runs a parent-only action, showing the PIN gate first when locked and
    /// remembering where the parent was actually headed.
    private func requestParentAction(_ action: ParentAction) {
        pendingAction = action
        if session.isUnlocked {
            perform(action)
        } else {
            showParentGate = true
        }
    }

    private func perform(_ action: ParentAction) {
        switch action {
        case .dashboard:     showParentDashboard = true
        case .editProfile:   showEditProfile = true
        case .deleteProfile: showDeleteConfirmation = true
        case .deleteAccount: showDeleteAccountConfirmation = true
        }
    }

    // MARK: - Session

    /// Sign-out wipes the cache, and the cache is where offline writes live.
    /// So flush first, and if anything is still queued, say so instead of
    /// quietly throwing away the child's work.
    private func requestSignOut() {
        isSigningOut = true
        Task {
            await ServiceLocator.data.flushPendingWrites()
            let remaining = await ServiceLocator.data.pendingWriteCount()
            await MainActor.run {
                isSigningOut = false
                if remaining > 0 {
                    unsyncedCount = remaining
                    showUnsyncedWarning = true
                } else {
                    completeSignOut()
                }
            }
        }
    }

    private func completeSignOut() {
        ServiceLocator.auth.signOut()
        // Wipe the family's cached data and the parent PIN, so the next person
        // to sign in on this device starts clean.
        kidsManager.clearLocalState()
        session.reset()
        NotificationService.cancelDailyReminder()
        isSignedIn = false
    }

    private func deleteAccount() {
        isDeletingAccount = true
        Task {
            do {
                try await ServiceLocator.auth.deleteAccount()
                await MainActor.run {
                    isDeletingAccount = false
                    completeSignOut()
                }
            } catch {
                // Signing out here would tell the parent their data is gone
                // when it is still on the server.
                await MainActor.run {
                    isDeletingAccount = false
                    accountError = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Notifications

    private func refreshNotificationPermission() async {
        let permission = await NotificationService.permission()
        await MainActor.run { notificationPermission = permission }
    }

    private func applyNotificationPreference(_ isOn: Bool) async {
        guard isOn else {
            NotificationService.cancelDailyReminder()
            await refreshNotificationPermission()
            return
        }
        // Prompting only here means the OS dialog appears because the parent
        // asked for reminders, not because the app launched.
        let scheduled = await NotificationService.enableReminder(
            hour: prefs.reminderHour, minute: prefs.reminderMinute
        )
        await refreshNotificationPermission()
        if !scheduled {
            await MainActor.run { prefs.notificationsEnabled = false }
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

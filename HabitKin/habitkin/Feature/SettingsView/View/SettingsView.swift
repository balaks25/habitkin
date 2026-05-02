//
//  SettingsView.swift
//  habitkin
//
//  Created by Balaji K S on 26/04/26.
//
import SwiftUI

struct SettingsView: View {
    let kid: Kid
    @State private var showPINSetup = false
    @State private var showEditProfile = false
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @State private var showParentLock = false
    @State private var parentPIN = ""
    
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
                            Text("Settings")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Manage & Customize")
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
                    
                    // Child Profile Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(Color(hex: theme.primaryColor))
                            Text("Child Profile")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 10) {
                            SettingRow(
                                icon: "pencil.circle.fill",
                                label: "Edit Profile",
                                value: kid.name,
                                theme: theme,
                                action: { showEditProfile = true }
                            )
                            
                            SettingRow(
                                icon: "birthday.cake.fill",
                                label: "Age",
                                value: "\(kid.age) years",
                                theme: theme,
                                action: {}
                            )
                            
                            SettingRow(
                                icon: "sparkles",
                                label: "Character",
                                value: kid.character.name,
                                theme: theme,
                                action: {}
                            )
                            
                            SettingRow(
                                icon: "globe",
                                label: "World",
                                value: kid.theme.world,
                                theme: theme,
                                action: {}
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Parent Controls Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Color(hex: theme.primaryColor))
                            Text("Parent Controls")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 10) {
                            Button(action: { showPINSetup = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "key.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color(hex: theme.primaryColor))
                                        .frame(width: 40)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Parent PIN")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("Set or change your PIN")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color.white.opacity(0.3))
                                }
                                .padding(12)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                            }
                            
                            Toggle(isOn: $notificationsEnabled) {
                                HStack(spacing: 12) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color(hex: theme.primaryColor))
                                        .frame(width: 40)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Daily Notifications")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("Remind about quests")
                                            .font(.caption)
                                            .foregroundColor(.gray)
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
                                        Text("Sound Effects")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("Enable celebration sounds")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .tint(Color(hex: theme.primaryColor))
                            .padding(12)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Account Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(Color(hex: theme.primaryColor))
                            Text("Account")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 10) {
                            SettingRow(
                                icon: "calendar",
                                label: "Created",
                                value: formatDate(kid.createdDate),
                                theme: theme,
                                action: {}
                            )
                            
                            SettingRow(
                                icon: "star.fill",
                                label: "Total Coins Earned",
                                value: "\(kid.totalEarned)",
                                theme: theme,
                                action: {}
                            )
                            
                            SettingRow(
                                icon: "checkmark.circle.fill",
                                label: "Quests Completed",
                                value: "\(kid.totalCompleted)",
                                theme: theme,
                                action: {}
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // App Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "app.fill")
                                .foregroundColor(Color(hex: theme.primaryColor))
                            Text("App")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 10) {
                            SettingRow(
                                icon: "info",
                                label: "Version",
                                value: "1.0.0",
                                theme: theme,
                                action: {}
                            )
                            
                            Button(action: {}) {
                                HStack(spacing: 12) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color(hex: "#EF4444"))
                                        .frame(width: 40)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Delete Child Profile")
                                            .font(.headline)
                                            .foregroundColor(Color(hex: "#EF4444"))
                                        Text("Permanently remove this child")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color.white.opacity(0.3))
                                }
                                .padding(12)
                                .background(Color(hex: "#EF4444").opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 80)
                }
                .padding(.vertical, 20)
            }
        }
        .sheet(isPresented: $showPINSetup) {
            ParentPINSetup(isPresented: $showPINSetup, theme: theme)
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet(isPresented: $showEditProfile, kid: kid, theme: theme)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
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
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(value)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.white.opacity(0.3))
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

struct ParentPINSetup: View {
    @Binding var isPresented: Bool
    @State private var pinInput = ""
    @State private var pinConfirm = ""
    @State private var showError = false
    @State private var setupComplete = false
    
    let theme: AppTheme
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
            
            VStack(spacing: 20) {
                HStack {
                    Text("Parent PIN Setup")
                        .font(.title2)
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
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter 4-Digit PIN")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        SecureField("PIN", text: $pinInput)
                            .keyboardType(.numberPad)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm PIN")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        SecureField("PIN", text: $pinConfirm)
                            .keyboardType(.numberPad)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    
                    if showError {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text("PINs don't match")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
                .padding()
                
                Button(action: {
                    if pinInput == pinConfirm && pinInput.count == 4 {
                        setupComplete = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            dismiss()
                        }
                    } else {
                        showError = true
                    }
                }) {
                    Text("Set PIN")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color(hex: theme.primaryColor))
                        .cornerRadius(8)
                }
                .disabled(pinInput.isEmpty || pinConfirm.isEmpty)
                .opacity((pinInput.isEmpty || pinConfirm.isEmpty) ? 0.5 : 1)
                .padding()
                
                Spacer()
            }
        }
    }
}

struct EditProfileSheet: View {
    @Binding var isPresented: Bool
    let kid: Kid
    let theme: AppTheme
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
            
            VStack(spacing: 20) {
                HStack {
                    Text("Edit Profile")
                        .font(.title2)
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
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(kid.name)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Age")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("\(kid.age) years")
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Character")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(kid.character.name)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                
                Text("Profile information is locked. Contact parent to change.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding()
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color(hex: theme.primaryColor))
                        .cornerRadius(8)
                }
                .padding()
            }
        }
    }
}

#Preview {
    SettingsView(kid: Kid(
        id: UUID(),
        name: "Alex",
        avatar: "person.fill",
        age: 7,
        characterId: "screen_zombie",
        themeId: "space",
        createdDate: Date()
    ))
}

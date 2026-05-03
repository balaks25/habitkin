//
//  habitkinApp.swift
//  habitkin
//
//  Created by Balaji K S on 22/04/26.
//

import SwiftUI

@main
struct HabitKinApp: App {
    @State private var selectedKid: Kid?
    @State private var isOnboarded = false
    @State private var isSignedIn = false

    var body: some Scene {
        WindowGroup {
            Group {
                if !isSignedIn {
                    // Step 1: Auth
                    AuthView { isSignedIn = true }
                } else if isOnboarded, let kid = selectedKid {
                    // Step 3: Main App
                    MainTabView(kid: kid)
                } else {
                    // Step 2: Onboarding
                    CharacterSelectionViewContainer { kid in
                        selectedKid = kid
                        isOnboarded = true
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    init() {
        // Configure UI appearance for dark theme
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
//        // Set status bar style to light content (white text)
//        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
//            windowScene.windows.forEach { window in
//                window.windowScene?.requestGeometryUpdate(.iOS(statusBarFrame: .zero))
//            }
//        }
    }
}

struct CharacterSelectionViewContainer: View {
    let onComplete: (Kid) -> Void
    @State private var currentStep = 0
    @State private var childName = ""
    @State private var selectedAge = 7
    @State private var selectedAvatar = "person.fill"
    @State private var selectedCharacter: Character?
    @State private var selectedTheme: AppTheme?
    
    let avatarOptions = [
        ("person.fill", "Person"),
        ("person.crop.circle.fill", "Circle"),
        ("star.fill", "Star"),
        ("heart.fill", "Heart"),
        ("moon.fill", "Moon"),
        ("sun.max.fill", "Sun"),
        ("bolt.fill", "Bolt"),
        ("leaf.fill", "Leaf")
    ]
    
    var filteredCharacters: [Character] {
        Character.all.filter { $0.ageRange.contains(selectedAge) }
    }
    
    var body: some View {
        ZStack {
            AuthBackground()
            
            VStack(spacing: 0) {
                // Progress bar
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentStep ? Color(hex: "#6366F1") : Color.white.opacity(0.2))
                            .frame(height: 4)
                    }
                }
                .padding(20)
                
                // Content
                VStack {
                    if currentStep == 0 {
                        Step0_Name(childName: $childName)
                    } else if currentStep == 1 {
                        Step1_AgeAvatar(selectedAge: $selectedAge, selectedAvatar: $selectedAvatar, avatarOptions: avatarOptions)
                    } else if currentStep == 2 {
                        Step2_Character(filteredCharacters: filteredCharacters, selectedCharacter: $selectedCharacter)
                    } else {
                        Step3_Theme(selectedTheme: $selectedTheme)
                    }
                }
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 12) {
                    if currentStep > 0 {
                        Button(action: { currentStep -= 1 }) {
                            Text("Back")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                        if currentStep < 3 {
                            currentStep += 1
                        } else {
                            // All steps complete - create kid and navigate
                            if let character = selectedCharacter, let theme = selectedTheme {
                                let newKid = Kid(
                                    id: UUID(),
                                    name: childName.isEmpty ? "Child" : childName,
                                    avatar: selectedAvatar,
                                    age: selectedAge,
                                    characterId: character.id,
                                    themeId: theme.id,
                                    createdDate: Date()
                                )
                                onComplete(newKid)
                            }
                        }
                    }) {
                        Text(currentStep == 3 ? "Start Adventure" : "Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(Color(hex: "#6366F1"))
                            .cornerRadius(12)
                    }
                    .disabled(!isStepValid())
                    .opacity(isStepValid() ? 1 : 0.5)
                }
                .padding(20)
            }
        }
    }
    
    private func isStepValid() -> Bool {
        switch currentStep {
        case 0:
            return !childName.trimmingCharacters(in: .whitespaces).isEmpty
        case 1:
            return true
        case 2:
            return selectedCharacter != nil
        case 3:
            return selectedTheme != nil
        default:
            return false
        }
    }
}

struct ThemeOptionCardForApp: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    Image(systemName: theme.icon)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(Color(hex: theme.primaryColor))
                        .frame(width: 50)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(theme.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(theme.world)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: theme.primaryColor))
                    }
                }
                
                HStack(spacing: 12) {
                    VStack(spacing: 4) {
                        Image(systemName: theme.creatures.egg)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: theme.primaryColor))
                        Text("Egg")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 4) {
                        Image(systemName: theme.creatures.hatch)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: theme.primaryColor))
                        Text("Hatch")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 4) {
                        Image(systemName: theme.creatures.evolve)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: theme.primaryColor))
                        Text("Evolve")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 4) {
                        Image(systemName: theme.creatures.ultimate)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: theme.primaryColor))
                        Text("Ultimate")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.bottom, 4)
            }
            .padding(14)
            .background(Color(hex: theme.secondaryColor).opacity(0.2))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: theme.primaryColor) : Color.clear, lineWidth: 2)
            )
        }
    }
}

//
//  AddKidSheet.swift
//  habitkin
//
//  Created by Balaji K S on 05/05/26.
//

import SwiftUI

// MARK: - Add Kid Sheet
struct AddKidSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject private var manager = KidsManager.shared
    @Environment(\.dismiss) var dismiss

    @State private var currentStep = 0
    @State private var childName = ""
    @State private var selectedAge = 7
    @State private var selectedAvatar = "boy_1"
    @State private var selectedCharacter: Character?
    @State private var selectedTheme: AppTheme?

    private let avatarOptions: [(String, String)] = [] // unused — AvatarCarouselPicker handles this

    private var accentColor: String {
        selectedTheme?.primaryColor ?? "#6C3FF5"
    }

    private var bgColor: String {
        selectedTheme?.secondaryColor ?? "#0A0A2E"
    }

    private var canProceed: Bool {
        switch currentStep {
        case 0: return !childName.trimmingCharacters(in: .whitespaces).isEmpty
        case 1: return true
        case 2: return selectedCharacter != nil
        case 3: return selectedTheme != nil
        default: return false
        }
    }

    private var stepTitle: String {
        switch currentStep {
        case 0: return "Child's Name"
        case 1: return "Age & Avatar"
        case 2: return "Choose Character"
        default: return "Choose World"
        }
    }

    private var stepSubtitle: String {
        switch currentStep {
        case 0: return "What should we call them?"
        case 1: return "How old are they?"
        case 2: return "What best describes your child?"
        default: return "Which world will they explore?"
        }
    }

    private var buttonLabel: String {
        currentStep < 3 ? "Continue" : "Add \(childName)"
    }

    var body: some View {
        ZStack {
            AuthBackground()

            VStack(spacing: 0) {
                dragHandle
                headerRow
                stepTitleBlock
                stepContent
                Spacer(minLength: 0)
                nextButton
            }
            .padding(.horizontal, 20)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .animation(.easeInOut, value: bgColor)
    }

    // MARK: - Sub-views

    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.white.opacity(0.2))
            .frame(width: 40, height: 4)
            .padding(.top, 12)
            .padding(.bottom, 20)
    }

    private var headerRow: some View {
        HStack {
            backButton
            Spacer()
            stepDots
            Spacer()
            closeButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    private var backButton: some View {
        Group {
            if currentStep > 0 {
                Button(action: { currentStep -= 1 }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: accentColor))
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(10)
                }
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
        }
    }

    private var stepDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<4, id: \.self) { i in
                Circle()
                    .fill(i == currentStep
                          ? Color(hex: accentColor)
                          : Color.white.opacity(0.2))
                    .frame(width: i == currentStep ? 10 : 6,
                           height: i == currentStep ? 10 : 6)
                    .animation(.spring(), value: currentStep)
            }
        }
    }

    private var closeButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 26))
                .foregroundColor(Color.white.opacity(0.3))
        }
    }

    private var stepTitleBlock: some View {
        VStack(spacing: 6) {
            Text(stepTitle)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(stepSubtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.bottom, 24)
    }

    private var stepContent: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                currentStepView
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    @ViewBuilder
    private var currentStepView: some View {
        switch currentStep {
        case 0:
            NameStepContent(name: $childName, accentColor: accentColor)
        case 1:
            AgeAvatarStepContent(
                age: $selectedAge,
                avatar: $selectedAvatar,
                avatarOptions: avatarOptions,
                accentColor: accentColor
            )
        case 2:
            CharacterStepContent(
                selectedCharacter: $selectedCharacter,
                accentColor: accentColor
            )
        default:
            ThemeStepContent(selectedTheme: $selectedTheme)
        }
    }

    private var nextButton: some View {
        Button(action: handleNext) {
            Text(buttonLabel)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(canProceed
                    ? Color(hex: accentColor)
                    : Color.white.opacity(0.15))
                .cornerRadius(14)
        }
        .disabled(!canProceed)
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }

    // MARK: - Actions

    private func handleNext() {
        if currentStep < 3 {
            currentStep += 1
        } else {
            saveKid()
        }
    }

    private func saveKid() {
        guard let character = selectedCharacter,
              let theme = selectedTheme else { return }
        let newKid = Kid(
            id: UUID(),
            name: childName.trimmingCharacters(in: .whitespaces),
            avatar: selectedAvatar,
            age: selectedAge,
            characterId: character.id,
            themeId: theme.id,
            createdDate: Date()
        )
        manager.addKid(newKid)
        manager.selectKid(newKid)
        dismiss()
    }
}

// MARK: - Step 0: Name
struct NameStepContent: View {
    @Binding var name: String
    let accentColor: String

    var body: some View {
        TextField("e.g. Emma, Arjun, Leo", text: $name)
            .font(.title3)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(16)
            .background(Color.white.opacity(0.07))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        name.isEmpty
                            ? Color.white.opacity(0.1)
                            : Color(hex: accentColor).opacity(0.5),
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Step 1: Age & Avatar
struct AgeAvatarStepContent: View {
    @Binding var age: Int
    @Binding var avatar: String
    // avatarOptions kept for API compat but ignored — we use asset avatars
    let avatarOptions: [(String, String)]
    let accentColor: String

    var body: some View {
        VStack(spacing: 24) {
            agePicker
            avatarCarousel
        }
    }

    private var agePicker: some View {
        VStack(spacing: 12) {
            Text("Age")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: accentColor))

            HStack(spacing: 24) {
                Button(action: { if age > Kid.minAge { age -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color(hex: accentColor))
                }
                Text("\(age)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                    .monospacedDigit()
                    .frame(width: 80)
                Button(action: { if age < Kid.maxAge { age += 1 } }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color(hex: accentColor))
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }

    private var avatarCarousel: some View {
        AvatarCarouselPicker(selectedAvatar: $avatar, accentColor: accentColor)
    }
}

// MARK: - Avatar Carousel Picker
// Left/right swipe carousel showing one large avatar at a time with arrows.
struct AvatarCarouselPicker: View {
    @Binding var selectedAvatar: String
    let accentColor: String

    // All 8 assets — boys then girls
    static let avatars = [
        "boy_1", "boy_2", "boy_3", "boy_4",
        "girl_1", "girl_2", "girl_3", "girl_4"
    ]

    private var currentIndex: Int {
        Self.avatars.firstIndex(of: selectedAvatar) ?? 0
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Choose Avatar")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            // Large center avatar with left/right arrows
            HStack(spacing: 20) {
                // Left arrow
                Button(action: {
                    let prev = (currentIndex - 1 + Self.avatars.count) % Self.avatars.count
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedAvatar = Self.avatars[prev]
                    }
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Color(hex: accentColor).opacity(0.8))
                }

                // Avatar image
                ZStack {
                    Circle()
                        .fill(Color(hex: accentColor).opacity(0.15))
                        .frame(width: 180, height: 180)
                    Circle()
                        .stroke(Color(hex: accentColor).opacity(0.4), lineWidth: 3)
                        .frame(width: 180, height: 180)

                    Image(selectedAvatar)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .clipShape(Circle())
                        .id(selectedAvatar) // triggers transition
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.85).combined(with: .opacity),
                            removal:   .scale(scale: 0.85).combined(with: .opacity)
                        ))
                }

                // Right arrow
                Button(action: {
                    let next = (currentIndex + 1) % Self.avatars.count
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedAvatar = Self.avatars[next]
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Color(hex: accentColor).opacity(0.8))
                }
            }

            // Dot indicators
            HStack(spacing: 8) {
                ForEach(0..<Self.avatars.count, id: \.self) { i in
                    Circle()
                        .fill(i == currentIndex
                              ? Color(hex: accentColor)
                              : Color.white.opacity(0.25))
                        .frame(
                            width:  i == currentIndex ? 16 : 8,
                            height: i == currentIndex ? 16 : 8
                        )
                        .animation(.spring(), value: currentIndex)
                }
            }

            // Thumbnail strip for quick jumping
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<Self.avatars.count, id: \.self) { i in
                        let name = Self.avatars[i]
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedAvatar = name
                            }
                        }) {
                            Image(name)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 52, height: 52)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(
                                            name == selectedAvatar
                                                ? Color(hex: accentColor)
                                                : Color.white.opacity(0.15),
                                            lineWidth: name == selectedAvatar ? 3 : 1.5
                                        )
                                )
                                .scaleEffect(name == selectedAvatar ? 1.1 : 1.0)
                                .animation(.spring(), value: selectedAvatar)
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .onAppear {
            // Default to boy_1 if still on the old SF Symbol default
            if !Self.avatars.contains(selectedAvatar) {
                selectedAvatar = Self.avatars[0]
            }
        }
    }
}

struct AvatarCell: View {
    let icon: String
    let isSelected: Bool
    let accentColor: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(isSelected ? Color(hex: accentColor) : Color.white.opacity(0.4))
                .frame(width: 60, height: 60)
                .background(isSelected
                    ? Color(hex: accentColor).opacity(0.2)
                    : Color.white.opacity(0.05))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isSelected ? Color(hex: accentColor).opacity(0.5) : Color.clear,
                            lineWidth: 1.5
                        )
                )
        }
    }
}

// MARK: - Step 2: Character
struct CharacterStepContent: View {
    @Binding var selectedCharacter: Character?
    let accentColor: String
    /// Filtered to the child's age, matching onboarding. Listing all six let a
    /// parent pair an age with a character whose quests exclude it.
    var age: Int?

    private var characters: [Character] {
        guard let age else { return Character.all }
        return Character.all.filter { $0.ageRange.contains(age) }
    }

    var body: some View {
        VStack(spacing: 12) {
            ForEach(characters) { character in
                CharacterCell(
                    character: character,
                    isSelected: selectedCharacter?.id == character.id,
                    onTap: { selectedCharacter = character }
                )
            }
        }
    }
}

struct CharacterCell: View {
    let character: Character
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: character.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(isSelected ? Color(hex: character.color) : Color.white.opacity(0.4))
                    .frame(width: 48, height: 48)
                    .background(isSelected
                        ? Color(hex: character.color).opacity(0.2)
                        : Color.white.opacity(0.05))
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 3) {
                    Text(character.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(character.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: character.color))
                    .opacity(isSelected ? 1 : 0)
            }
            .padding(12)
            .background(isSelected
                ? Color(hex: character.color).opacity(0.1)
                : Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color(hex: character.color).opacity(0.4) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
    }
}

// MARK: - Step 3: Theme

struct ThemeStepContent: View {
    @Binding var selectedTheme: AppTheme?

    var body: some View {
        VStack(spacing: 12) {
            ForEach(AppTheme.all) { theme in
                ThemeCell(
                    theme: theme,
                    isSelected: selectedTheme?.id == theme.id,
                    onTap: { selectedTheme = theme }
                )
            }
        }
    }
}

struct ThemeCell: View {
    let theme: AppTheme
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: theme.creatures.egg)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(isSelected ? Color(hex: theme.primaryColor) : Color.white.opacity(0.4))
                    .frame(width: 48, height: 48)
                    .background(isSelected
                        ? Color(hex: theme.primaryColor).opacity(0.2)
                        : Color.white.opacity(0.05))
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 3) {
                    Text(theme.world)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(theme.name)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: theme.primaryColor))
                    .opacity(isSelected ? 1 : 0)
            }
            .padding(12)
            .background(isSelected
                ? Color(hex: theme.primaryColor).opacity(0.1)
                : Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color(hex: theme.primaryColor).opacity(0.4) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
    }
}


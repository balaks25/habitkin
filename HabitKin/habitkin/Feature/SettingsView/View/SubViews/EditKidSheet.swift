//
//  EditKidSheet.swift
//  habitkin
//
//  Lets a parent correct a child's profile after creation. Previously the
//  Settings rows were read-only, so a typo'd name or wrong age was permanent.
//

import SwiftUI

struct EditKidSheet: View {
    let kid: Kid

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var manager = KidsManager.shared

    @State private var name: String
    @State private var age: Int
    @State private var avatar: String
    @State private var selectedCharacter: Character?
    @State private var selectedTheme: AppTheme?

    init(kid: Kid) {
        self.kid = kid
        _name   = State(initialValue: kid.name)
        _age    = State(initialValue: kid.age)
        _avatar = State(initialValue: kid.avatar)
        _selectedCharacter = State(initialValue: kid.character)
        _selectedTheme     = State(initialValue: kid.theme)
    }

    private var accentColor: String {
        selectedTheme?.primaryColor ?? kid.theme.primaryColor
    }

    private var backgroundColor: String {
        selectedTheme?.secondaryColor ?? kid.theme.secondaryColor
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && selectedCharacter != nil
            && selectedTheme != nil
    }

    var body: some View {
        ZStack {
            Color(hex: backgroundColor).ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        section("Name") {
                            NameStepContent(name: $name, accentColor: accentColor)
                        }

                        section("Age & Avatar") {
                            AgeAvatarStepContent(
                                age: $age,
                                avatar: $avatar,
                                avatarOptions: [],
                                accentColor: accentColor
                            )
                        }

                        section("Character") {
                            CharacterStepContent(
                                selectedCharacter: $selectedCharacter,
                                accentColor: accentColor,
                                age: age
                            )
                        }

                        section("World") {
                            ThemeStepContent(selectedTheme: $selectedTheme)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }

                saveButton
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }

    // MARK: - Pieces

    private var header: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white.opacity(0.2))
                .frame(width: 40, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Edit Profile")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Update \(kid.name)'s details")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Color.white.opacity(0.3))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    private func section<Content: View>(_ title: String,
                                       @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: accentColor))
            content()
        }
    }

    private var saveButton: some View {
        Button(action: save) {
            Text("Save Changes")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(canSave ? Color(hex: accentColor) : Color.white.opacity(0.15))
                .cornerRadius(14)
        }
        .disabled(!canSave)
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }

    // MARK: - Save

    private func save() {
        guard let character = selectedCharacter, let theme = selectedTheme else { return }

        var updated = kid
        updated.name        = name.trimmingCharacters(in: .whitespaces)
        updated.age         = age
        updated.avatar      = avatar
        updated.characterId = character.id
        updated.themeId     = theme.id

        // Coins, streak and history are all deliberately untouched — changing
        // a character shouldn't cost the child their progress.
        manager.updateKid(updated)
        dismiss()
    }
}

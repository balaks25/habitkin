//
//  ThemeSelectionView.swift
//  habitkin
//
//  Created by Balaji K S on 23/04/26.
//


import SwiftUI

struct ThemeSelectionView: View {
    @Binding var selectedTheme: AppTheme?
    let characterName: String
    let avatar: String
    let age: Int
    let characterId: String
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#0F172A"),
                    Color(hex: "#1E293B")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Text("Choose Your World")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(AppTheme.all) { theme in
                            ThemeCard(
                                theme: theme,
                                isSelected: selectedTheme?.id == theme.id,
                                action: { selectedTheme = theme }
                            )
                        }
                    }
                    .padding()
                }
                
                if selectedTheme != nil {
                    Button(action: {
                        // Create kid and pass back
                        let newKid = Kid(
                            id: UUID(),
                            name: characterName,
                            avatar: avatar,
                            age: age,
                            characterId: characterId,
                            themeId: selectedTheme!.id,
                            createdDate: Date()
                        )
                        // TODO: Save to UserDefaults or CoreData
                        dismiss()
                    }) {
                        Text("Start Adventure")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(Color(hex: "#6366F1"))
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
        }
    }
}

struct ThemeCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    Text(theme.emoji)
                        .font(.system(size: 40))
                    
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
                            .foregroundColor(Color(hex: theme.primaryColor))
                    }
                }
                
                HStack(spacing: 8) {
                    ForEach([theme.creatures.egg, theme.creatures.hatch, theme.creatures.evolve, theme.creatures.ultimate], id: \.self) { creature in
                        Text(creature)
                            .font(.system(size: 20))
                    }
                }
            }
            .padding(12)
            .background(Color(hex: theme.secondaryColor).opacity(0.2))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: theme.primaryColor) : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    ThemeSelectionView(
        selectedTheme: .constant(nil),
        characterName: "Alex",
        avatar: "🦁",
        age: 7,
        characterId: "screen_zombie"
    )
}
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
            VStack(spacing: 20) {
                HStack {
                    Text("Choose Your World")
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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(AppTheme.all) { theme in
                            ThemeCardWithSymbols(
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
                        _ = Kid(
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

struct ThemeCardWithSymbols: View {
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
                
                // Creatures evolution preview with SF Symbols
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

#Preview {
    ThemeSelectionView(
        selectedTheme: .constant(nil),
        characterName: "Alex",
        avatar: "person.fill",
        age: 7,
        characterId: "screen_zombie"
    )
}

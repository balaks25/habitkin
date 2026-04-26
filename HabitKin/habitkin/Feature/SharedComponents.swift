//
//  SharedComponents.swift
//  habitkin
//
//  Created by Balaji K S on 26/04/26.
//

import SwiftUI

// MARK: - Quest Card
struct QuestCard: View {
    let quest: Quest
    let theme: AppTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: quest.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color(hex: theme.primaryColor))
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(quest.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("+\(quest.coins)")
                            .font(.headline)
                            .foregroundColor(Color(hex: theme.primaryColor))
                        Image(systemName: "star.fill")
                            .font(.caption)
                    }
                    Text(quest.category)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: theme.primaryColor).opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Stat Box
struct StatBox: View {
    let label: String
    let value: String
    let icon: String
    let theme: AppTheme
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: theme.primaryColor))
            Text(value)
                .font(.headline)
                .foregroundColor(Color(hex: theme.primaryColor))
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

// MARK: - Celebration View
struct CelebrationView: View {
    let message: String
    let theme: AppTheme
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: theme.primaryColor))
                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(30)
            .background(Color.black.opacity(0.8))
            .cornerRadius(20)
        }
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    let theme: AppTheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isSelected ? Color(hex: theme.primaryColor) : Color.white.opacity(0.5))
                
                Text(label)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? Color(hex: theme.primaryColor) : Color.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

//
//  RewardsView.swift
//  habitkin
//
//  Created by Balaji K S on 26/04/26.
//


import SwiftUI

struct RewardsView: View {
    let kid: Kid
    
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
                            Text("Rewards")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Spend your coins")
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
                    
                    // Placeholder content
                    VStack(spacing: 12) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color(hex: theme.primaryColor))
                        
                        Text("Rewards Shop")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Design coming soon...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.vertical, 20)
            }
        }
    }
}

#Preview {
    RewardsView(kid: Kid(
        id: UUID(),
        name: "Alex",
        avatar: "person.fill",
        age: 7,
        characterId: "screen_zombie",
        themeId: "space",
        createdDate: Date()
    ))
}
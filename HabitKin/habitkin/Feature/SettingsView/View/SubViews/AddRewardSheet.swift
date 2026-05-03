//
//  AddRewardSheet.swift
//  habitkin
//
//  Created by Balaji K S on 03/05/26.
//

import SwiftUI

// MARK: - Add Reward Sheet
struct AddRewardSheet: View {
    let kid: Kid
    let theme: AppTheme
    @Binding var isPresented: Bool
    
    @State private var rewardName = ""
    @State private var rewardDescription = ""
    @State private var coinCost = 50
    @State private var selectedIcon = "gift.fill"
    @State private var selectedRarity = "common"
    @Environment(\.dismiss) var dismiss
    
    let iconOptions = ["gift.fill", "star.fill", "heart.fill", "moon.stars.fill", "gamecontroller.fill", "film", "fork.knife", "bag.fill", "airplane", "crown.fill", "bolt.fill", "sparkles"]
    let rarities = ["common", "rare", "epic", "legendary"]
    
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
                    Text("Add Custom Reward")
                        .font(.title3)
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
                    VStack(spacing: 16) {
                        // Reward Name
                        FormField(label: "Reward Name", placeholder: "e.g. Ice Cream Trip") { _ in
                            TextField("Reward name", text: $rewardName)
                                .foregroundColor(.white)
                        }
                        
                        // Reward Description
                        FormField(label: "Description", placeholder: "What does this reward involve?") { _ in
                            TextField("Short description", text: $rewardDescription)
                                .foregroundColor(.white)
                        }
                        
                        // Icon Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Choose Icon")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                ForEach(iconOptions, id: \.self) { icon in
                                    Button(action: { selectedIcon = icon }) {
                                        Image(systemName: icon)
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(selectedIcon == icon ? Color(hex: theme.primaryColor) : Color.white.opacity(0.5))
                                            .frame(width: 44, height: 44)
                                            .background(selectedIcon == icon ? Color(hex: theme.primaryColor).opacity(0.2) : Color.white.opacity(0.05))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Rarity Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Rarity")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 8) {
                                ForEach(rarities, id: \.self) { rarity in
                                    Button(action: { selectedRarity = rarity }) {
                                        Text(rarity.capitalized)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(selectedRarity == rarity ? Color(hex: theme.primaryColor) : Color.white.opacity(0.5))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(selectedRarity == rarity ? Color(hex: theme.primaryColor).opacity(0.2) : Color.white.opacity(0.05))
                                            .cornerRadius(6)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Coin Cost Stepper
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Coin Cost")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                Button(action: { if coinCost > 10 { coinCost -= 10 } }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(Color(hex: theme.primaryColor))
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Color(hex: theme.primaryColor))
                                    Text("\(coinCost)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("coins")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Button(action: { coinCost += 10 }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(Color(hex: theme.primaryColor))
                                }
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                Button(action: { dismiss() }) {
                    Text("Add Reward")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(rewardName.isEmpty ? Color.white.opacity(0.2) : Color(hex: theme.primaryColor))
                        .cornerRadius(12)
                }
                .disabled(rewardName.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

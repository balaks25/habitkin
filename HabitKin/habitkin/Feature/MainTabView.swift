//
//  MainTabView.swift
//  habitkin
//
//  Created by Balaji K S on 25/04/26.
//

import SwiftUI

struct MainTabView: View {
    let kid: Kid
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Tab content
            TabView(selection: $selectedTab) {
                HomeView(kid: kid)
                    .tag(0)
                
                ProgressView(kid: kid)
                    .tag(1)
                
                RewardsView(kid: kid)
                    .tag(2)
                
                SettingsView(kid: kid)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Bottom Tab Navigation
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    TabBarItem(
                        icon: "house.fill",
                        label: "Home",
                        isSelected: selectedTab == 0,
                        action: { selectedTab = 0 },
                        theme: kid.theme
                    )
                    
                    TabBarItem(
                        icon: "chart.bar.fill",
                        label: "Progress",
                        isSelected: selectedTab == 1,
                        action: { selectedTab = 1 },
                        theme: kid.theme
                    )
                    
                    TabBarItem(
                        icon: "gift.fill",
                        label: "Rewards",
                        isSelected: selectedTab == 2,
                        action: { selectedTab = 2 },
                        theme: kid.theme
                    )
                    
                    TabBarItem(
                        icon: "gearshape.fill",
                        label: "Settings",
                        isSelected: selectedTab == 3,
                        action: { selectedTab = 3 },
                        theme: kid.theme
                    )
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: kid.theme.secondaryColor),
                            Color(hex: kid.theme.secondaryColor).opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .border(Color.white.opacity(0.1), width: 1)
            }
        }
        .ignoresSafeArea(edges: .all)
        .onAppear {
            // Set status bar color to match theme secondary color
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color(hex: kid.theme.secondaryColor))
            appearance.shadowColor = nil
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
            // Set window background to theme color
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.first?.backgroundColor = UIColor(Color(hex: kid.theme.secondaryColor))
            }
        }
    }
}

#Preview {
    MainTabView(kid: Kid(
        id: UUID(),
        name: "Alex",
        avatar: "person.fill",
        age: 7,
        characterId: "screen_zombie",
        themeId: "space",
        createdDate: Date()
    ))
}

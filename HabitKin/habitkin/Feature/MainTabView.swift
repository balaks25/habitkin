//
//  MainTabView.swift
//  habitkin
//
//  Created by Balaji K S on 25/04/26.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var manager = KidsManager.shared
    @State private var selectedTab = 0
    @State private var showAddKid = false

    // Safe — never force-indexes. Returns nil when kids list is empty.
    private var kid: Kid? {
        manager.selectedKid ?? manager.kids.first
    }

    var body: some View {
        // Guard: if no kid exists yet, show add-kid sheet immediately
        if let kid {
            mainContent(kid: kid)
        } else {
            emptyState
        }
    }

    // MARK: - Main content (kid exists)

    private func mainContent(kid: Kid) -> some View {
        ZStack {
            Color(hex: kid.theme.secondaryColor)
                .ignoresSafeArea()
                .animation(.easeInOut, value: kid.id)

            VStack(spacing: 0) {
                // ── Shared header ─────────────────────────────────
                VStack(spacing: 0) {
                    HStack {
                        Text(tabTitle(kid: kid))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                    KidSwitcherBar(
                        manager: manager,
                        theme: kid.theme,
                        showAddKid: $showAddKid
                    )
                }

                Rectangle()
                    .fill(Color.white.opacity(0.07))
                    .frame(height: 1)

                // ── Tab content ───────────────────────────────────
                TabView(selection: $selectedTab) {
                    HomeView(kid: kid)
                        .tag(0)
                        .id(kid.id)
                    ProgressTabView(kid: kid).tag(1)
                    RewardsView(kid: kid)
                        .tag(2)
                        .id(kid.id)
                    SettingsView(kid: kid).tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }

            // ── Bottom tab bar ────────────────────────────────────
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    TabBarItem(icon: "house.fill",     label: "Home",     isSelected: selectedTab == 0, action: { selectedTab = 0 }, theme: kid.theme)
                    TabBarItem(icon: "chart.bar.fill", label: "Progress", isSelected: selectedTab == 1, action: { selectedTab = 1 }, theme: kid.theme)
                    TabBarItem(icon: "gift.fill",      label: "Rewards",  isSelected: selectedTab == 2, action: { selectedTab = 2 }, theme: kid.theme)
                    TabBarItem(icon: "gearshape.fill", label: "Settings", isSelected: selectedTab == 3, action: { selectedTab = 3 }, theme: kid.theme)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
                .background(Color(hex: kid.theme.secondaryColor))
                .border(Color.white.opacity(0.1), width: 1)
            }
        }
        .onAppear { applyThemeToStatusBar(kid: kid) }
        .onChange(of: kid.id) { _ in applyThemeToStatusBar(kid: kid) }
        .sheet(isPresented: $showAddKid) {
            AddKidSheet(isPresented: $showAddKid)
        }
    }

    // MARK: - Empty state (no kids yet)

    private var emptyState: some View {
        ZStack {
            Color(hex: "#07071A").ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 60, weight: .semibold))
                    .foregroundColor(Color(hex: "#6C3FF5"))

                VStack(spacing: 8) {
                    Text("Welcome to HabitKin")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Add your first child to get started")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Button(action: { showAddKid = true }) {
                    Text("Add a Child")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#6C3FF5"))
                        .cornerRadius(14)
                }
            }
        }
        .sheet(isPresented: $showAddKid) {
            AddKidSheet(isPresented: $showAddKid)
        }
    }

    // MARK: - Helpers

    private func tabTitle(kid: Kid) -> String {
        switch selectedTab {
        case 0: return kid.name
        case 1: return "Progress"
        case 2: return "Rewards"
        case 3: return "Settings"
        default: return "HabitKin"
        }
    }

    private func applyThemeToStatusBar(kid: Kid) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(hex: kid.theme.secondaryColor))
        appearance.shadowColor = nil
        UINavigationBar.appearance().standardAppearance   = appearance
        UINavigationBar.appearance().compactAppearance    = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.windows.first?.backgroundColor = UIColor(Color(hex: kid.theme.secondaryColor))
        }
    }
}

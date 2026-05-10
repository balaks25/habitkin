//
//  KidSwitcherBar.swift
//  habitkin
//
//  Created by Balaji K S on 05/05/26.
//


import SwiftUI

struct KidSwitcherBar: View {
    @ObservedObject var manager: KidsManager
    let theme: AppTheme
    @Binding var showAddKid: Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Existing kids
                ForEach(manager.kids) { kid in
                    KidChip(
                        kid: kid,
                        isSelected: manager.selectedKidId == kid.id,
                        theme: theme,
                        onTap: { manager.selectKid(kid) }
                    )
                }

                // Add kid button
                Button(action: { showAddKid = true }) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: theme.primaryColor).opacity(0.12))
                                .frame(width: 50, height: 50)
                            Circle()
                                .stroke(Color(hex: theme.primaryColor).opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                                .frame(width: 50, height: 50)
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: theme.primaryColor))
                        }
                        Text("Add")
                            .font(.caption2)
                            .foregroundColor(Color(hex: theme.primaryColor).opacity(0.7))
                    }
                    .padding(.vertical)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 90)
    }
}

struct KidChip: View {
    let kid: Kid
    let isSelected: Bool
    let theme: AppTheme
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(isSelected
                            ? Color(hex: theme.primaryColor).opacity(0.25)
                            : Color.white.opacity(0.07))
                        .frame(width: 50, height: 50)

                    Image(systemName: kid.avatar)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isSelected ? Color(hex: theme.primaryColor) : Color.white.opacity(0.5))

                    // Selected ring
                    if isSelected {
                        Circle()
                            .stroke(Color(hex: theme.primaryColor), lineWidth: 2)
                            .frame(width: 50, height: 50)
                    }
                }

                Text(kid.name)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : Color.white.opacity(0.4))
                    .lineLimit(1)
            }
            .padding(.vertical)
        }
    }
}

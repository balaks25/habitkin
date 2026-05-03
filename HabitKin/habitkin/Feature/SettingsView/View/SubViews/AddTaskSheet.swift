//
//  AddTaskSheet.swift
//  habitkin
//
//  Created by Balaji K S on 03/05/26.
//


import SwiftUI

struct AddTaskSheet: View {
    let theme: AppTheme
    let onSave: (Quest) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var taskName = ""
    @State private var taskDescription = ""
    @State private var coinValue = 10
    @State private var selectedIcon = "star.fill"
    @State private var selectedCategory = "daily"
    @State private var selectedWeek = 1
    
    let iconOptions = [
        "star.fill", "heart.fill", "bolt.fill", "book.fill",
        "moon.fill", "sun.max.fill", "leaf.fill", "flame.fill",
        "wind", "sparkles", "figure.walk", "house.fill",
        "music.note", "paintbrush.fill", "fork.knife", "bed.double.fill"
    ]
    
    var canSave: Bool {
        !taskName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        ZStack {
            Color(hex: theme.secondaryColor).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Drag Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("New Quest")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Add a custom task for your child")
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
                .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // Task Name
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Task Name", systemImage: "pencil")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: theme.primaryColor))
                            
                            TextField("e.g. Make your bed", text: $taskName)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(14)
                                .background(Color.white.opacity(0.07))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(taskName.isEmpty ? Color.white.opacity(0.1) : Color(hex: theme.primaryColor).opacity(0.5), lineWidth: 1)
                                )
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Description (optional)", systemImage: "text.alignleft")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: theme.primaryColor))
                            
                            TextField("What does this task involve?", text: $taskDescription)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(14)
                                .background(Color.white.opacity(0.07))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                        
                        // Icon Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Choose Icon", systemImage: "square.grid.2x2")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: theme.primaryColor))
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10) {
                                ForEach(iconOptions, id: \.self) { icon in
                                    Button(action: { selectedIcon = icon }) {
                                        Image(systemName: icon)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(selectedIcon == icon ? Color(hex: theme.primaryColor) : Color.white.opacity(0.4))
                                            .frame(width: 40, height: 40)
                                            .background(selectedIcon == icon ? Color(hex: theme.primaryColor).opacity(0.2) : Color.white.opacity(0.05))
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(selectedIcon == icon ? Color(hex: theme.primaryColor).opacity(0.5) : Color.clear, lineWidth: 1.5)
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Category & Week
                        HStack(spacing: 12) {
                            // Category
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Type", systemImage: "tag.fill")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: theme.primaryColor))
                                
                                HStack(spacing: 8) {
                                    ForEach(["daily", "special"], id: \.self) { cat in
                                        Button(action: { selectedCategory = cat }) {
                                            Text(cat.capitalized)
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(selectedCategory == cat ? Color(hex: theme.primaryColor) : Color.white.opacity(0.5))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(selectedCategory == cat ? Color(hex: theme.primaryColor).opacity(0.2) : Color.white.opacity(0.05))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Week
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Week", systemImage: "calendar")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: theme.primaryColor))
                                
                                HStack(spacing: 6) {
                                    ForEach(1...4, id: \.self) { week in
                                        Button(action: { selectedWeek = week }) {
                                            Text("\(week)")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(selectedWeek == week ? Color(hex: theme.primaryColor) : Color.white.opacity(0.5))
                                                .frame(width: 32, height: 32)
                                                .background(selectedWeek == week ? Color(hex: theme.primaryColor).opacity(0.2) : Color.white.opacity(0.05))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Coin Value
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Coin Reward", systemImage: "star.fill")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: theme.primaryColor))
                            
                            HStack(spacing: 0) {
                                Button(action: { if coinValue > 5 { coinValue -= 5 } }) {
                                    Image(systemName: "minus")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(hex: theme.primaryColor))
                                        .frame(width: 48, height: 48)
                                        .background(Color(hex: theme.primaryColor).opacity(0.1))
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: theme.primaryColor))
                                    Text("\(coinValue)")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                        .monospacedDigit()
                                }
                                
                                Spacer()
                                
                                Button(action: { coinValue += 5 }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(hex: theme.primaryColor))
                                        .frame(width: 48, height: 48)
                                        .background(Color(hex: theme.primaryColor).opacity(0.1))
                                }
                            }
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                
                // Save Button
                Button(action: {
                    let newQuest = Quest(
                        id: UUID().uuidString,
                        name: taskName,
                        description: taskDescription.isEmpty ? taskName : taskDescription,
                        icon: selectedIcon,
                        coins: coinValue,
                        category: selectedCategory,
                        week: selectedWeek,
                        characterIds: ["screen_zombie", "sleepyhead", "volcano", "shadow", "tornado", "dreamer"],
                        ageRange: 4...10
                    )
                    onSave(newQuest)
                    dismiss()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Add Quest")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(canSave ? Color(hex: theme.primaryColor) : Color.white.opacity(0.15))
                    .cornerRadius(14)
                }
                .disabled(!canSave)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}

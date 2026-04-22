//
//  Habit.swift
//  habitkin
//
//  Created by Balaji K S on 22/04/26.
//


import Foundation

struct Habit: Identifiable, Codable {
    let id: UUID
    let kidId: UUID
    var name: String
    var icon: String
    var coins: Int
    var category: HabitCategory
    var createdDate: Date
    var weekOfIntroduction: Int
    var completedDates: [Date]
    
    enum HabitCategory: String, Codable, CaseIterable {
        case daily = "Daily"
        case special = "Special"
    }
    
    var isCompletedToday: Bool {
        completedDates.contains { Calendar.current.isDateInToday($0) }
    }
    
    var completedThisWeek: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return completedDates.filter { $0 >= weekAgo }.count
    }
}
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
    var category: String // daily, special
    var createdDate: Date = Date()
    var completedDates: [Date] = []
    
    var isCompletedToday: Bool {
        completedDates.contains { Calendar.current.isDateInToday($0) }
    }
}

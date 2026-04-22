//
//  Kid.swift
//  habitkin
//
//  Created by Balaji K S on 22/04/26.
//

import Foundation

import Foundation

struct Kid: Identifiable, Codable {
    let id: UUID
    var name: String
    var avatar: String
    var age: KidAge
    var character: KidCharacter
    var theme: ThemeType
    var createdDate: Date
    var totalCoins: Int
    var totalEarned: Int
    var totalCompleted: Int
    var streak: Int
    var lastActivityDate: Date
    var habitKin: HabitKin?
    var habits: [Habit]
    
    enum CodingKeys: String, CodingKey {
        case id, name, avatar, age, character, theme
        case createdDate, totalCoins, totalEarned, totalCompleted
        case streak, lastActivityDate
    }
}

enum KidAge: String, Codable, CaseIterable {
    case under6 = "Under 6"
    case sixToEight = "6-8"
    case nineToTwelve = "9-12"
}

enum KidCharacter: String, Codable, CaseIterable {
    case screenZombie = "Screen Zombie"
    case sleepyhead = "Sleepyhead"
    case volcano = "Volcano"
    case shadow = "Shadow"
    case tornado = "Tornado"
    case dreamer = "Dreamer"
    
    var emoji: String {
        switch self {
        case .screenZombie: return "📱"
        case .sleepyhead: return "😴"
        case .volcano: return "🌋"
        case .shadow: return "🐢"
        case .tornado: return "😈"
        case .dreamer: return "🌀"
        }
    }
}

enum ThemeType: String, Codable, CaseIterable {
    case space = "Space"
    case jungle = "Jungle"
    case superhero = "Superhero"
    
    var primaryColor: String { /* ... */ }
    var accentColor: String { /* ... */ }
}

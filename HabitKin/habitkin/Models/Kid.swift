//
//  Kid.swift
//  habitkin
//
//  Created by Balaji K S on 22/04/26.
//

import Foundation

struct Kid: Identifiable, Codable {
    let id: UUID
    var name: String
    var avatar: String // emoji
    var age: String // under6, 6to8, 9to12
    var character: String // screen_zombie, lazy, etc
    var theme: String // space, jungle, superhero
    var createdDate: Date
    var totalCoins: Int = 0
    var totalEarned: Int = 0
    var totalCompleted: Int = 0
    var streak: Int = 0
    var lastActivityDate: Date = Date()
    var habits: [Habit] = []
    var kinStage: String = "egg" // egg, hatch, evolve, ultimate
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
    
//    var primaryColor: String { /* ... */ }
//    var accentColor: String { /* ... */ }
}

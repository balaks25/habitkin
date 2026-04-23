//
//  Kid.swift
//  habitkin
//
//  Created by Balaji K S on 22/04/26.
//

import Foundation

struct Kid: Identifiable, Codable {
    var id: UUID
    var name: String
    var avatar: String // emoji
    var age: Int
    var characterId: String
    var themeId: String
    var createdDate: Date
    var totalCoins: Int = 0
    var totalEarned: Int = 0
    var totalCompleted: Int = 0
    var streak: Int = 0
    var currentWeek: Int = 1
    var kinStage: String = "egg"
    var kinMood: String = "happy"
    var completedQuestIds: Set<String> = []
    var lastActivityDate: Date = Date()
    
    var character: Character {
        Character.all.first { $0.id == characterId } ?? Character.all[0]
    }
    
    var theme: AppTheme {
        AppTheme.all.first { $0.id == themeId } ?? AppTheme.all[0]
    }
    
    func getCurrentWeekQuests() -> [Quest] {
        Quest.questsFor(character: character, week: currentWeek, age: age)
    }
    
    mutating func updateKinStage() {
        switch totalEarned {
        case 0..<500:
            kinStage = "egg"
        case 500..<1500:
            kinStage = "hatch"
        case 1500..<4000:
            kinStage = "evolve"
        default:
            kinStage = "ultimate"
        }
    }
    
    mutating func updateKinMood(dailyCompleted: Int) {
        kinMood = dailyCompleted >= 3 ? "happy" : dailyCompleted >= 1 ? "neutral" : "sad"
    }
}

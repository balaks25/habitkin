//
//  Quest.swift
//  habitkin
//
//  Created by Balaji K S on 23/04/26.
//


import Foundation

struct Quest: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let icon: String // SF Symbol name
    let coins: Int
    let category: String // "daily" or "special"
    let week: Int
    let characterIds: [String]
    let ageRange: ClosedRange<Int>
    
    static let questLibrary: [Quest] = [
        // WEEK 1 - All Characters
        Quest(id: "q_make_bed", name: "Prepare the Base Camp", description: "Make your bed clean and tidy", icon: "bed.double.fill", coins: 10, category: "daily", week: 1, characterIds: ["screen_zombie", "sleepyhead", "volcano", "shadow", "tornado", "dreamer"], ageRange: 4...10),
        Quest(id: "q_brush_teeth", name: "Brush Your Teeth", description: "Morning and evening ritual", icon: "tree.fill", coins: 5, category: "daily", week: 1, characterIds: ["screen_zombie", "sleepyhead", "volcano", "shadow", "tornado", "dreamer"], ageRange: 4...10),
        
        // Screen Zombie - Week 1
        Quest(id: "q_screen_free_30", name: "Free Your HabitKin", description: "Put your phone down for 30 minutes", icon: "phone.slash", coins: 30, category: "daily", week: 1, characterIds: ["screen_zombie"], ageRange: 4...10),
        
        // Sleepyhead - Week 1
        Quest(id: "q_wake_early", name: "Wake Up Your Kin", description: "Wake up 15 minutes earlier", icon: "sunrise.fill", coins: 25, category: "daily", week: 1, characterIds: ["sleepyhead"], ageRange: 4...10),
        
        // Volcano - Week 1
        Quest(id: "q_deep_breath", name: "Channel Power", description: "Take 5 deep breaths when angry", icon: "wind", coins: 20, category: "daily", week: 1, characterIds: ["volcano"], ageRange: 4...10),
        
        // WEEK 2
        Quest(id: "q_outdoor_15", name: "Scout the Lands", description: "Go outside for 15 minutes", icon: "tree.fill", coins: 25, category: "daily", week: 2, characterIds: ["screen_zombie", "shadow", "dreamer"], ageRange: 4...10),
        Quest(id: "q_read_15", name: "Absorb Wisdom", description: "Read for 15 minutes", icon: "book.fill", coins: 20, category: "daily", week: 2, characterIds: ["screen_zombie", "sleepyhead", "dreamer"], ageRange: 6...10),
        
        // WEEK 3
        Quest(id: "q_exercise_20", name: "Strengthen Body", description: "Exercise for 20 minutes", icon: "figure.walk", coins: 30, category: "special", week: 3, characterIds: ["sleepyhead", "tornado", "shadow"], ageRange: 4...10),
        
        // WEEK 4
        Quest(id: "q_help_family", name: "Become a Hero", description: "Help family without being asked", icon: "heart.fill", coins: 50, category: "special", week: 4, characterIds: ["screen_zombie", "sleepyhead", "volcano", "shadow", "tornado", "dreamer"], ageRange: 4...10)
    ]
    
    static func questsFor(character: Character, week: Int, age: Int) -> [Quest] {
        questLibrary.filter { quest in
            quest.characterIds.contains(character.id) &&
            quest.week == week &&
            quest.ageRange.contains(age)
        }
    }
}

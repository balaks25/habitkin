//
//  HabitKin.swift
//  habitkin
//
//  Created by Balaji K S on 22/04/26.
//


import Foundation

struct HabitKin: Identifiable, Codable {
    let id: UUID
    let kidId: UUID
    var stage: String // egg, hatch, evolve, ultimate
    var bondStrength: Int = 0
    var mood: String = "happy" // happy, neutral, sad
    var lastMoodUpdate: Date = Date()
}

//struct HabitKin: Identifiable, Codable {
//    let id: UUID
//    let kidId: UUID
//    var currentStage: EvolutionStage
//    var totalBondStrength: Int
//    var mood: KinMood
//    var lastMoodUpdate: Date
//    
//    enum EvolutionStage: String, Codable, CaseIterable {
//        case egg = "🥚"
//        case hatch = "🐣"
//        case evolve = "🐲"
//        case ultimate = "👑"
//        
//        var nextStage: EvolutionStage? {
//            switch self {
//            case .egg: return .hatch
//            case .hatch: return .evolve
//            case .evolve: return .ultimate
//            case .ultimate: return nil
//            }
//        }
//    }
//    
//    enum KinMood: String, Codable {
//        case happy = "😊"
//        case neutral = "😐"
//        case sad = "😢"
//    }
//    
//    mutating func updateMoodBasedOnHabits(_ habitsCompleted: Int) {
//        mood = habitsCompleted >= 3 ? .happy : habitsCompleted >= 1 ? .neutral : .sad
//        lastMoodUpdate = Date()
//    }
//}

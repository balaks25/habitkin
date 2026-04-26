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

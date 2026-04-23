//
//  Character.swift
//  habitkin
//
//  Created by Balaji K S on 23/04/26.
//


import Foundation
import SwiftUI

struct Character: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let emoji: String
    let ageRange: ClosedRange<Int>
    let challenges: [String]
    let storyHook: String
    let color: String // hex color
    
    static let all: [Character] = [
        Character(
            id: "screen_zombie",
            name: "📱 Screen Zombie",
            description: "Can't put the phone down. Gets stuck in digital world.",
            emoji: "📱",
            ageRange: 4...10,
            challenges: ["Screen addiction", "Outdoor phobia", "Social withdrawal"],
            storyHook: "Your HabitKin is trapped inside a screen. Only real-world quests can set them free!",
            color: "#6366F1"
        ),
        Character(
            id: "sleepyhead",
            name: "😴 Sleepyhead",
            description: "No motivation. Lazy. Needs a push to get started.",
            emoji: "😴",
            ageRange: 4...10,
            challenges: ["Lack of motivation", "Procrastination", "Low energy"],
            storyHook: "Your HabitKin is sleeping. Wake them up with your first quest!",
            color: "#8B5CF6"
        ),
        Character(
            id: "volcano",
            name: "🌋 Volcano",
            description: "Short-tempered. Gets angry easily. Needs control.",
            emoji: "🌋",
            ageRange: 4...10,
            challenges: ["Anger management", "Emotional control", "Patience"],
            storyHook: "Your HabitKin's power is unstable. Help them channel it!",
            color: "#EF4444"
        ),
        Character(
            id: "shadow",
            name: "🐢 Shadow",
            description: "Shy and lacks confidence. Hides from the world.",
            emoji: "🐢",
            ageRange: 4...10,
            challenges: ["Low confidence", "Social anxiety", "Self-doubt"],
            storyHook: "Your HabitKin is hiding in darkness. Help them shine!",
            color: "#10B981"
        ),
        Character(
            id: "tornado",
            name: "😈 Tornado",
            description: "Hyperactive. Breaks rules. Needs structure.",
            emoji: "😈",
            ageRange: 4...10,
            challenges: ["Hyperactivity", "Rule-breaking", "Impulsiveness"],
            storyHook: "Your HabitKin's energy is wild. Give it a mission!",
            color: "#F59E0B"
        ),
        Character(
            id: "dreamer",
            name: "🌀 Dreamer",
            description: "Unfocused. Gets distracted easily.",
            emoji: "🌀",
            ageRange: 4...10,
            challenges: ["Lack of focus", "Distractibility", "No follow-through"],
            storyHook: "Your HabitKin has big dreams. Make them real with action!",
            color: "#EC4899"
        )
    ]
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let rgb = Int(hex, radix: 16) ?? 0
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
//
//  AppTheme.swift
//  habitkin
//
//  Created by Balaji K S on 23/04/26.
//


import SwiftUI

struct AppTheme: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let world: String
    let emoji: String
    let primaryColor: String
    let secondaryColor: String
    let accentColor: String
    let creatures: ThemeCreatures
    
    static let all: [AppTheme] = [
        AppTheme(
            id: "space",
            name: "🚀 Space Explorer",
            world: "Cosmic Galaxy",
            emoji: "🚀",
            primaryColor: "#6C3FF5",
            secondaryColor: "#0A0A2E",
            accentColor: "#B794F4",
            creatures: ThemeCreatures(
                egg: "🥚",
                hatch: "👾",
                evolve: "🛸",
                ultimate: "⭐"
            )
        ),
        AppTheme(
            id: "jungle",
            name: "🌿 Jungle Explorer",
            world: "Wild Jungle",
            emoji: "🌿",
            primaryColor: "#38A169",
            secondaryColor: "#071A0E",
            accentColor: "#68D391",
            creatures: ThemeCreatures(
                egg: "🥚",
                hatch: "🐣",
                evolve: "🐲",
                ultimate: "🦋"
            )
        ),
        AppTheme(
            id: "superhero",
            name: "🦸 Superhero Academy",
            world: "Hero City",
            emoji: "🦸",
            primaryColor: "#E53E3E",
            secondaryColor: "#1A0505",
            accentColor: "#FC8181",
            creatures: ThemeCreatures(
                egg: "🥚",
                hatch: "🐥",
                evolve: "⚡",
                ultimate: "🦸"
            )
        )
    ]
}

struct ThemeCreatures: Codable, Hashable {
    let egg: String
    let hatch: String
    let evolve: String
    let ultimate: String
    
    subscript(stage: String) -> String {
        switch stage {
        case "egg": return egg
        case "hatch": return hatch
        case "evolve": return evolve
        case "ultimate": return ultimate
        default: return egg
        }
    }
}

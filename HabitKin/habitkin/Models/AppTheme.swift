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
    let icon: String          // SF Symbol
    let primaryColor: String  // main brand color — buttons, active states
    let secondaryColor: String // dark background (used as ZStack bg)
    let accentColor: String   // highlights, coins, badges
    let cardColor: String     // quest card fill
    let creatures: ThemeCreatures

    // MARK: - 3 themes from the provided Coolors palettes

    static let all: [AppTheme] = [

        // ── Theme 1 · Candy World ─────────────────────────────────────
        // Palette: #9B5DE5 · #F15BB5 · #FEE440 · #00BBF9 · #00F5D4
        AppTheme(
            id: "candy",
            name: "Candy World",
            world: "Rainbow Land",
            icon: "sparkles",
            primaryColor:   "#9B5DE5",   // purple — buttons, active tab
            secondaryColor: "#2D1B4E",   // deep purple — dark bg
            accentColor:    "#FEE440",   // yellow — coins, highlights
            cardColor:      "#F15BB5",   // pink — quest cards
            creatures: ThemeCreatures(
                egg:     "circle.fill",
                hatch:   "star.fill",
                evolve:  "sparkles",
                ultimate:"star.circle.fill"
            )
        ),

        // ── Theme 2 · Ocean Academy ───────────────────────────────────
        // Palette: #072AC8 · #1E96FC · #A2D6F9 · #FCF300 · #FFC600
        AppTheme(
            id: "ocean",
            name: "Ocean Academy",
            world: "Deep Blue Sea",
            icon: "water.waves",
            primaryColor:   "#1E96FC",   // sky blue — buttons, active tab
            secondaryColor: "#03153A",   // deep navy — dark bg
            accentColor:    "#FCF300",   // bright yellow — coins, highlights
            cardColor:      "#072AC8",   // deep blue — quest cards
            creatures: ThemeCreatures(
                egg:     "circle.fill",
                hatch:   "drop.fill",
                evolve:  "water.waves",
                ultimate:"fish.fill"
            )
        ),

        // ── Theme 3 · Jungle Quest ────────────────────────────────────
        // Palette: #2C6E49 · #4C956C · #FEFEE3 · #FFC9B9 · #D68C45
        AppTheme(
            id: "jungle",
            name: "Jungle Quest",
            world: "Wild Jungle",
            icon: "leaf.fill",
            primaryColor:   "#4C956C",   // green — buttons, active tab
            secondaryColor: "#0F2318",   // deep forest — dark bg
            accentColor:    "#D68C45",   // amber — coins, highlights
            cardColor:      "#2C6E49",   // dark green — quest cards
            creatures: ThemeCreatures(
                egg:     "circle.fill",
                hatch:   "leaf.fill",
                evolve:  "tree.fill",
                ultimate:"leaf.arrow.triangle.circlepath"
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
        case "egg":      return egg
        case "hatch":    return hatch
        case "evolve":   return evolve
        case "ultimate": return ultimate
        default:         return egg
        }
    }
}

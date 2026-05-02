//
//  Reward.swift
//  habitkin
//
//  Created by Balaji K S on 02/05/26.
//


import Foundation

struct Reward: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let coinsCost: Int
    let category: String // "screen_time", "treat", "activity", "special"
    let rarity: String // "common", "rare", "epic", "legendary"
    
    static let rewardLibrary: [Reward] = [
        // Common Rewards
        Reward(id: "r_extra_screen_15", name: "Extra Screen Time", description: "15 minutes of extra screen time", icon: "iphone", coinsCost: 25, category: "screen_time", rarity: "common"),
        Reward(id: "r_skip_chore", name: "Skip One Chore", description: "Get out of one household chore", icon: "sparkles", coinsCost: 30, category: "activity", rarity: "common"),
        Reward(id: "r_movie_pick", name: "Pick a Movie", description: "Choose the movie for family night", icon: "film", coinsCost: 35, category: "activity", rarity: "common"),
        
        // Rare Rewards
        Reward(id: "r_pizza_night", name: "Pizza Night", description: "Order pizza for dinner", icon: "fork.knife", coinsCost: 75, category: "treat", rarity: "rare"),
        Reward(id: "r_friend_sleepover", name: "Friend Sleepover", description: "Host a friend sleepover", icon: "moon.stars.fill", coinsCost: 100, category: "activity", rarity: "rare"),
        Reward(id: "r_game_pass", name: "Game Pass", description: "One month of gaming subscription", icon: "gamecontroller.fill", coinsCost: 120, category: "screen_time", rarity: "rare"),
        
        // Epic Rewards
        Reward(id: "r_theme_park", name: "Theme Park Visit", description: "Day trip to theme park", icon: "ferris.wheel", coinsCost: 250, category: "activity", rarity: "epic"),
        Reward(id: "r_shopping_spree", name: "Shopping Spree", description: "₹500 shopping budget", icon: "bag.fill", coinsCost: 300, category: "treat", rarity: "epic"),
        Reward(id: "r_tech_upgrade", name: "New Gadget", description: "New headphones or tech item", icon: "headphones", coinsCost: 350, category: "screen_time", rarity: "epic"),
        
        // Legendary Rewards
        Reward(id: "r_dream_trip", name: "Dream Trip", description: "Plan a special vacation", icon: "airplane", coinsCost: 500, category: "activity", rarity: "legendary"),
        Reward(id: "r_ultimate_prize", name: "Ultimate Prize", description: "Your choice of any reward", icon: "crown.fill", coinsCost: 600, category: "special", rarity: "legendary")
    ]
    
    static func rewardsByCategory(_ category: String) -> [Reward] {
        rewardLibrary.filter { $0.category == category }
    }
}
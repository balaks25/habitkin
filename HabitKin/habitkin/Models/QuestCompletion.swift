//
//  QuestCompletion.swift
//  habitkin
//
//  One row per finished quest. This append-only log is the source of truth for
//  daily availability, streaks and mood — none of which can be answered by a
//  plain "has this quest ever been done" flag.
//

import Foundation

struct QuestCompletion: Identifiable, Codable, Hashable {
    let id: UUID
    let questId: String
    /// Snapshotted so history stays readable after a custom quest is deleted.
    let questName: String
    let coins: Int
    let date: Date

    init(id: UUID = UUID(), questId: String, questName: String, coins: Int, date: Date = Date()) {
        self.id = id
        self.questId = questId
        self.questName = questName
        self.coins = coins
        self.date = date
    }
}

//
//  Kid.swift
//  habitkin
//
//  Created by Balaji K S on 22/04/26.
//

import Foundation

struct Kid: Identifiable, Codable {

    // MARK: - Stored

    var id: UUID
    var name: String
    var avatar: String // asset name from AvatarCarouselPicker.avatars
    var age: Int
    var characterId: String
    var themeId: String
    var createdDate: Date
    var currentWeek: Int

    /// Spendable balance. Only `recordCompletion` and `claimReward` touch this.
    var totalCoins: Int
    /// Lifetime coins earned — drives evolution, so it never decreases on spend.
    var totalEarned: Int

    /// Append-only completion log. See `QuestCompletion`.
    var completions: [QuestCompletion]

    var claimedRewardIds: Set<String>

    /// Parent-side switches from the dashboard.
    var disabledQuestIds: Set<String>
    var disabledRewardIds: Set<String>

    /// Weeks advanced past because they offered no quests for this child.
    var skippedWeeks: Set<Int>

    // MARK: - Evolution ladder

    /// The one place the legal age range is defined. Every built-in quest and
    /// character is authored for 4-10, so allowing older children produced
    /// profiles with no quests at all.
    static let minAge = 4
    static let maxAge = 10

    static let stageOrder = ["egg", "hatch", "evolve", "ultimate"]
    static let stageThresholds = [0, 500, 1500, 4000]
    static let finalWeek = 4

    // MARK: - Init

    init(id: UUID = UUID(),
         name: String,
         avatar: String,
         age: Int,
         characterId: String,
         themeId: String,
         createdDate: Date = Date(),
         currentWeek: Int = 1,
         totalCoins: Int = 0,
         totalEarned: Int = 0,
         completions: [QuestCompletion] = [],
         claimedRewardIds: Set<String> = [],
         disabledQuestIds: Set<String> = [],
         disabledRewardIds: Set<String> = [],
         skippedWeeks: Set<Int> = []) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.age = age
        self.characterId = characterId
        self.themeId = themeId
        self.createdDate = createdDate
        self.currentWeek = currentWeek
        self.totalCoins = totalCoins
        self.totalEarned = totalEarned
        self.completions = completions
        self.claimedRewardIds = claimedRewardIds
        self.disabledQuestIds = disabledQuestIds
        self.disabledRewardIds = disabledRewardIds
        self.skippedWeeks = skippedWeeks
    }

    // MARK: - Config lookups

    var character: Character {
        Character.all.first { $0.id == characterId } ?? Character.all[0]
    }

    var theme: AppTheme {
        AppTheme.all.first { $0.id == themeId } ?? AppTheme.all[0]
    }

    // MARK: - Derived counters
    // Everything below is computed from `completions` so it can never drift out
    // of sync with the log the way the old stored mirrors did.

    var totalCompleted: Int { completions.count }

    var completedQuestIds: Set<String> { Set(completions.map(\.questId)) }

    var lastActivityDate: Date { completions.map(\.date).max() ?? createdDate }

    private var calendar: Calendar { Calendar.current }

    func completions(on date: Date) -> [QuestCompletion] {
        completions.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    var completedToday: Int { completions(on: Date()).count }

    var coinsEarnedToday: Int { completions(on: Date()).reduce(0) { $0 + $1.coins } }

    // MARK: - Quest availability

    func hasCompletedToday(_ questId: String) -> Bool {
        completions(on: Date()).contains { $0.questId == questId }
    }

    func hasEverCompleted(_ questId: String) -> Bool {
        completions.contains { $0.questId == questId }
    }

    /// Daily quests come back every midnight; special missions are one-time.
    func isAvailable(_ quest: Quest) -> Bool {
        guard !disabledQuestIds.contains(quest.id) else { return false }
        return quest.isRepeatable ? !hasCompletedToday(quest.id) : !hasEverCompleted(quest.id)
    }

    // MARK: - Stage

    var kinStage: String {
        var stage = Self.stageOrder[0]
        for (index, threshold) in Self.stageThresholds.enumerated() where totalEarned >= threshold {
            stage = Self.stageOrder[index]
        }
        return stage
    }

    private var stageIndex: Int {
        Self.stageOrder.firstIndex(of: kinStage) ?? 0
    }

    var currentStageThreshold: Int { Self.stageThresholds[stageIndex] }

    /// Coins needed for the next stage, or nil once fully evolved.
    var nextStageThreshold: Int? {
        let next = stageIndex + 1
        guard next < Self.stageThresholds.count else { return nil }
        return Self.stageThresholds[next]
    }

    /// 0...1 toward the next stage — measured against the real thresholds
    /// rather than a fixed 500-coin cycle.
    var stageProgress: Double {
        guard let next = nextStageThreshold else { return 1 }
        let span = next - currentStageThreshold
        guard span > 0 else { return 1 }
        return min(1, max(0, Double(totalEarned - currentStageThreshold) / Double(span)))
    }

    var stageProgressLabel: String {
        guard let next = nextStageThreshold else { return "Fully evolved" }
        return "\(totalEarned - currentStageThreshold)/\(next - currentStageThreshold)"
    }

    // MARK: - Streak & mood

    /// Consecutive days with at least one completion. Today being unfinished
    /// does not break the streak — it only stops extending it.
    var streak: Int {
        let days = Set(completions.map { calendar.startOfDay(for: $0.date) })
        guard !days.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: Date())
        guard var cursor = days.contains(today)
                ? today
                : calendar.date(byAdding: .day, value: -1, to: today)
        else { return 0 }
        guard days.contains(cursor) else { return 0 }

        var count = 0
        while days.contains(cursor) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return count
    }

    var kinMood: String {
        switch completedToday {
        case 3...:  return "happy"
        case 1...2: return "neutral"
        default:    return "sad"
        }
    }

    // MARK: - Mutations

    /// Logs a completion and pays out. Returns the new record so the caller can
    /// sync just that row, or nil if the quest wasn't available (already done
    /// today, or a spent one-time mission).
    @discardableResult
    mutating func recordCompletion(of quest: Quest) -> QuestCompletion? {
        guard isAvailable(quest) else { return nil }
        let completion = QuestCompletion(questId: quest.id,
                                         questName: quest.name,
                                         coins: quest.coins,
                                         date: Date())
        completions.append(completion)
        totalCoins += quest.coins
        totalEarned += quest.coins
        return completion
    }

    @discardableResult
    mutating func claimReward(_ reward: Reward) -> Bool {
        guard totalCoins >= reward.coinsCost,
              !claimedRewardIds.contains(reward.id) else { return false }
        totalCoins -= reward.coinsCost
        claimedRewardIds.insert(reward.id)
        return true
    }

    /// A week is done once every quest it offers has been completed at least
    /// once. Weeks that offer nothing are skipped so a gap in the quest library
    /// can never strand the child on a screen with no quests and no way out —
    /// but those skips are recorded, because a skipped week was never played
    /// and shouldn't be shown as completed.
    mutating func advanceWeekIfNeeded(questsForWeek: (Int) -> [Quest]) {
        while currentWeek < Self.finalWeek {
            let quests = questsForWeek(currentWeek)
            if quests.isEmpty {
                skippedWeeks.insert(currentWeek)
                currentWeek += 1
                continue
            }
            guard quests.allSatisfy({ hasEverCompleted($0.id) }) else { return }
            currentWeek += 1
        }
    }

    /// True only for weeks the child actually finished.
    func hasCompletedWeek(_ week: Int) -> Bool {
        currentWeek > week && !skippedWeeks.contains(week)
    }

    func wasWeekSkipped(_ week: Int) -> Bool {
        skippedWeeks.contains(week)
    }
}

// MARK: - Codable

extension Kid {

    private enum CodingKeys: String, CodingKey {
        case id, name, avatar, age, characterId, themeId, createdDate
        case currentWeek, totalCoins, totalEarned, completions
        case claimedRewardIds, disabledQuestIds, disabledRewardIds, skippedWeeks
        // Legacy keys — read during migration, never written back.
        case completedQuestIds, lastActivityDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Every optional decode is deliberate: an older profile on disk is
        // missing whichever keys were added since it was written, and a hard
        // failure here silently wipes the family's data (fetchKids swallows
        // the throw and returns an empty array).
        id          = try container.decode(UUID.self, forKey: .id)
        name        = try container.decode(String.self, forKey: .name)
        avatar      = try container.decodeIfPresent(String.self, forKey: .avatar) ?? "boy_1"
        age         = try container.decodeIfPresent(Int.self, forKey: .age) ?? 7
        characterId = try container.decodeIfPresent(String.self, forKey: .characterId) ?? Character.all[0].id
        themeId     = try container.decodeIfPresent(String.self, forKey: .themeId) ?? AppTheme.all[0].id
        createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Date()
        currentWeek = try container.decodeIfPresent(Int.self, forKey: .currentWeek) ?? 1
        totalCoins  = try container.decodeIfPresent(Int.self, forKey: .totalCoins) ?? 0
        totalEarned = try container.decodeIfPresent(Int.self, forKey: .totalEarned) ?? 0

        claimedRewardIds  = try container.decodeIfPresent(Set<String>.self, forKey: .claimedRewardIds) ?? []
        disabledQuestIds  = try container.decodeIfPresent(Set<String>.self, forKey: .disabledQuestIds) ?? []
        disabledRewardIds = try container.decodeIfPresent(Set<String>.self, forKey: .disabledRewardIds) ?? []
        skippedWeeks      = try container.decodeIfPresent(Set<Int>.self, forKey: .skippedWeeks) ?? []

        if let log = try container.decodeIfPresent([QuestCompletion].self, forKey: .completions) {
            completions = log
        } else {
            // Pre-log profile: rebuild one synthetic completion per finished
            // quest, all stamped at the last known activity. That yields a
            // streak of 1 rather than a fabricated history.
            let legacyIds = try container.decodeIfPresent(Set<String>.self, forKey: .completedQuestIds) ?? []
            let stamp = try container.decodeIfPresent(Date.self, forKey: .lastActivityDate) ?? createdDate
            completions = legacyIds.map { questId in
                let quest = Quest.questLibrary.first { $0.id == questId }
                return QuestCompletion(questId: questId,
                                       questName: quest?.name ?? questId,
                                       coins: quest?.coins ?? 0,
                                       date: stamp)
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(avatar, forKey: .avatar)
        try container.encode(age, forKey: .age)
        try container.encode(characterId, forKey: .characterId)
        try container.encode(themeId, forKey: .themeId)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(currentWeek, forKey: .currentWeek)
        try container.encode(totalCoins, forKey: .totalCoins)
        try container.encode(totalEarned, forKey: .totalEarned)
        try container.encode(completions, forKey: .completions)
        try container.encode(claimedRewardIds, forKey: .claimedRewardIds)
        try container.encode(disabledQuestIds, forKey: .disabledQuestIds)
        try container.encode(disabledRewardIds, forKey: .disabledRewardIds)
        try container.encode(skippedWeeks, forKey: .skippedWeeks)
    }
}

//
//  CatalogManager.swift
//  habitkin
//
//  Single source of truth for what quests and rewards a given child can see:
//  the built-in library filtered to their character, plus the custom content
//  their parent authored for them, minus anything switched off in the dashboard.
//

import Combine
import Foundation

final class CatalogManager: ObservableObject {

    static let shared = CatalogManager()

    @Published private(set) var customQuests: [Quest] = []
    @Published private(set) var customRewards: [Reward] = []
    @Published private(set) var loadState: LoadState = .idle

    var isLoaded: Bool { loadState == .loaded }

    private let dataService = ServiceLocator.data

    private init() {
        Task { await load() }
    }

    @MainActor
    func load() async {
        loadState = .loading
        do {
            customQuests  = try await dataService.fetchCustomQuests()
            customRewards = try await dataService.fetchCustomRewards()
            loadState = .loaded
        } catch {
            // Built-in quests are compiled in and still render, so a silent
            // failure here looks identical to "the parent never made any".
            loadState = .failed(error.localizedDescription)
        }
    }

    func retryLoad() {
        Task { await load() }
    }

    // MARK: - Quests

    /// Every quest this child could ever see, across all weeks.
    func allQuests(for kid: Kid) -> [Quest] {
        let builtIn = Quest.questLibrary.filter { $0.characterIds.contains(kid.characterId) }
        let custom  = customQuests.filter { $0.ownerKidId == kid.id }
        return builtIn + custom
    }

    /// Quests belonging to one week of the child's journey.
    func quests(for kid: Kid, week: Int) -> [Quest] {
        allQuests(for: kid).filter { quest in
            guard quest.week == week else { return false }
            // Custom quests are already targeted at this one child, so the
            // built-in age gate doesn't apply to them.
            return quest.ownerKidId != nil || quest.ageRange.contains(kid.age)
        }
    }

    /// What the child should actually be offered right now: this week's quests
    /// that aren't disabled and aren't already done (today, for dailies).
    func availableQuests(for kid: Kid) -> [Quest] {
        let quests = quests(for: kid, week: kid.currentWeek).filter { kid.isAvailable($0) }
        return quests.filter(\.isRepeatable) + quests.filter { !$0.isRepeatable }
    }

    func addQuest(_ quest: Quest) {
        customQuests.append(quest)
        Task { _ = try? await dataService.createCustomQuest(quest) }
    }

    func deleteQuest(_ quest: Quest) {
        customQuests.removeAll { $0.id == quest.id }
        Task { try? await dataService.deleteCustomQuest(id: quest.id) }
    }

    // MARK: - Rewards

    func allRewards(for kid: Kid) -> [Reward] {
        Reward.rewardLibrary + customRewards.filter { $0.ownerKidId == kid.id }
    }

    /// Rewards the child can browse — everything not switched off by a parent.
    func availableRewards(for kid: Kid) -> [Reward] {
        allRewards(for: kid).filter { !kid.disabledRewardIds.contains($0.id) }
    }

    func addReward(_ reward: Reward) {
        customRewards.append(reward)
        Task { _ = try? await dataService.createCustomReward(reward) }
    }

    func deleteReward(_ reward: Reward) {
        customRewards.removeAll { $0.id == reward.id }
        Task { try? await dataService.deleteCustomReward(id: reward.id) }
    }
}

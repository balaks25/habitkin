//
//  MockDataService.swift
//  habitkin
//
//  Local stand-in for a real backend. Kids and parent-authored content persist
//  to UserDefaults; the built-in quest/reward catalogs are the bundled statics.
//

import Foundation

final class MockDataService: KidsDataServicing {

    private let kidsKey          = "habitkin_kids"
    private let customQuestsKey  = "habitkin_custom_quests"
    private let customRewardsKey = "habitkin_custom_rewards"

    // MARK: - Kids

    func fetchKids() async throws -> [Kid] {
        try loadOrThrow([Kid].self, from: kidsKey)
    }

    func createKid(_ kid: Kid) async throws -> Kid {
        var kids = try await fetchKids()
        kids.append(kid)
        try persist(kids, to: kidsKey)
        return kid
    }

    func updateKid(_ kid: Kid) async throws -> Kid {
        var kids = try await fetchKids()
        guard let index = kids.firstIndex(where: { $0.id == kid.id }) else { return kid }
        kids[index] = kid
        try persist(kids, to: kidsKey)
        return kid
    }

    func deleteKid(id: UUID) async throws {
        var kids = try await fetchKids()
        kids.removeAll { $0.id == id }
        try persist(kids, to: kidsKey)

        // Don't leave a deleted child's custom content behind.
        var quests = try await fetchCustomQuests()
        quests.removeAll { $0.ownerKidId == id }
        try persist(quests, to: customQuestsKey)

        var rewards = try await fetchCustomRewards()
        rewards.removeAll { $0.ownerKidId == id }
        try persist(rewards, to: customRewardsKey)
    }

    // MARK: - Granular writes

    // No server to append to, so both just persist the updated child.
    func recordCompletion(_ completion: QuestCompletion, for kid: Kid) async throws {
        _ = try await updateKid(kid)
    }

    func claimReward(rewardId: String, for kid: Kid) async throws {
        _ = try await updateKid(kid)
    }

    func flushPendingWrites() async {}

    func pendingWriteCount() async -> Int { 0 }

    // MARK: - Built-in catalogs

    func fetchQuestLibrary() async throws -> [Quest] { Quest.questLibrary }

    func fetchRewardLibrary() async throws -> [Reward] { Reward.rewardLibrary }

    // MARK: - Custom quests

    func fetchCustomQuests() async throws -> [Quest] {
        try loadOrThrow([Quest].self, from: customQuestsKey)
    }

    func createCustomQuest(_ quest: Quest) async throws -> Quest {
        var quests = try await fetchCustomQuests()
        quests.append(quest)
        try persist(quests, to: customQuestsKey)
        return quest
    }

    func deleteCustomQuest(id: String) async throws {
        var quests = try await fetchCustomQuests()
        quests.removeAll { $0.id == id }
        try persist(quests, to: customQuestsKey)
    }

    // MARK: - Custom rewards

    func fetchCustomRewards() async throws -> [Reward] {
        try loadOrThrow([Reward].self, from: customRewardsKey)
    }

    func createCustomReward(_ reward: Reward) async throws -> Reward {
        var rewards = try await fetchCustomRewards()
        rewards.append(reward)
        try persist(rewards, to: customRewardsKey)
        return reward
    }

    func deleteCustomReward(id: String) async throws {
        var rewards = try await fetchCustomRewards()
        rewards.removeAll { $0.id == id }
        try persist(rewards, to: customRewardsKey)
    }

    // MARK: - Storage

    /// Missing key -> genuinely empty. Present but undecodable -> throw, so a
    /// caller can show an error instead of an empty state and then overwrite it.
    private func loadOrThrow<T: Decodable & ExpressibleByArrayLiteral>(_ type: T.Type,
                                                                      from key: String) throws -> T {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw DataError.corruptedStore
        }
    }

    private func persist<T: Encodable>(_ value: T, to key: String) throws {
        let data = try JSONEncoder().encode(value)
        UserDefaults.standard.set(data, forKey: key)
    }
}

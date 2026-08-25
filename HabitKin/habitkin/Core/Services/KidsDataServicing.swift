//
//  KidsDataServicing.swift
//  habitkin
//
//  Swap seam for kid/quest/reward data — implemented today by MockDataService,
//  and by RemoteDataService once a real backend exists.
//

import Foundation

enum DataError: LocalizedError {
    /// Stored data exists but can't be read. Distinct from "nothing stored yet"
    /// — treating the two alike lets a decode failure masquerade as a new
    /// account, and the next save then overwrites the unreadable original.
    case corruptedStore

    var errorDescription: String? {
        switch self {
        case .corruptedStore: return "Saved data couldn't be read."
        }
    }
}

protocol KidsDataServicing {
    func fetchKids() async throws -> [Kid]
    func createKid(_ kid: Kid) async throws -> Kid
    func updateKid(_ kid: Kid) async throws -> Kid
    func deleteKid(id: UUID) async throws

    /// Appends a single completion. Kept separate from `updateKid` because the
    /// completion log grows without bound — PUTting the whole child on every
    /// quest tap would mean an ever-larger payload for a one-row insert.
    /// `kid` is the already-updated local state so a cache can store it
    /// without a second round trip.
    func recordCompletion(_ completion: QuestCompletion, for kid: Kid) async throws
    func claimReward(rewardId: String, for kid: Kid) async throws

    /// Flushes anything queued while offline. No-op for services that write
    /// straight through.
    func flushPendingWrites() async

    /// Writes still waiting to reach the server. Sign-out checks this so it can
    /// warn instead of silently discarding the child's work.
    func pendingWriteCount() async -> Int

    func fetchQuestLibrary() async throws -> [Quest]
    func fetchRewardLibrary() async throws -> [Reward]

    // Parent-authored content. Kept separate from the bundled libraries so the
    // built-in catalog stays immutable and shippable.
    func fetchCustomQuests() async throws -> [Quest]
    func createCustomQuest(_ quest: Quest) async throws -> Quest
    func deleteCustomQuest(id: String) async throws

    func fetchCustomRewards() async throws -> [Reward]
    func createCustomReward(_ reward: Reward) async throws -> Reward
    func deleteCustomReward(id: String) async throws
}

//
//  CachedDataService.swift
//  habitkin
//
//  Write-through cache in front of the API. The server is the source of truth;
//  this exists so a child tapping a quest on a train doesn't lose their coins
//  and doesn't stare at a spinner.
//
//  Reads  — serve the cache immediately, refresh from the server behind it.
//  Writes — apply locally, queue the server call, flush when it can.
//
//  The queue is ordered and drains strictly in sequence: a create must land
//  before the update that follows it, so one failure stops the drain rather
//  than letting later writes overtake it.
//

import Foundation

// MARK: - Pending mutation

enum PendingMutation: Codable {
    case createKid(Kid)
    case updateKid(Kid)
    case deleteKid(UUID)
    case recordCompletion(kid: Kid, completion: QuestCompletion)
    case claimReward(kid: Kid, rewardId: String)
    case createCustomQuest(Quest)
    case deleteCustomQuest(String)
    case createCustomReward(Reward)
    case deleteCustomReward(String)
}

// MARK: - Cached service

actor CachedDataService: KidsDataServicing {

    private let remote: KidsDataServicing
    private let store = CacheStore()

    /// Set while a drain is in flight so concurrent writes don't double-send.
    private var isFlushing = false

    /// Writes the server refused outright. Surfaced in Settings so a silent
    /// drop isn't the end of the story.
    private(set) var rejectedWrites = 0

    func clearRejectedWrites() { rejectedWrites = 0 }

    init(remote: KidsDataServicing = RemoteDataService()) {
        self.remote = remote
    }

    // MARK: - Kids

    func fetchKids() async throws -> [Kid] {
        if let cached = store.kids {
            // Refreshing while writes are queued would clobber them with stale
            // server state, so only pull when we're fully in sync.
            if store.pending.isEmpty { Task { await self.refreshKids() } }
            return cached
        }
        let kids = try await remote.fetchKids()
        store.kids = kids
        return kids
    }

    func createKid(_ kid: Kid) async throws -> Kid {
        var kids = store.kids ?? []
        kids.append(kid)
        store.kids = kids
        enqueue(.createKid(kid))
        return kid
    }

    func updateKid(_ kid: Kid) async throws -> Kid {
        upsert(kid)
        enqueue(.updateKid(kid))
        return kid
    }

    func deleteKid(id: UUID) async throws {
        store.kids = (store.kids ?? []).filter { $0.id != id }
        store.customQuests = (store.customQuests ?? []).filter { $0.ownerKidId != id }
        store.customRewards = (store.customRewards ?? []).filter { $0.ownerKidId != id }
        enqueue(.deleteKid(id))
    }

    // MARK: - Granular writes

    func recordCompletion(_ completion: QuestCompletion, for kid: Kid) async throws {
        upsert(kid)
        enqueue(.recordCompletion(kid: kid, completion: completion))
    }

    func claimReward(rewardId: String, for kid: Kid) async throws {
        upsert(kid)
        enqueue(.claimReward(kid: kid, rewardId: rewardId))
    }

    // MARK: - Catalogs

    func fetchQuestLibrary() async throws -> [Quest] {
        if let cached = store.questLibrary { return cached }
        let quests = try await remote.fetchQuestLibrary()
        store.questLibrary = quests
        return quests
    }

    func fetchRewardLibrary() async throws -> [Reward] {
        if let cached = store.rewardLibrary { return cached }
        let rewards = try await remote.fetchRewardLibrary()
        store.rewardLibrary = rewards
        return rewards
    }

    // MARK: - Custom quests

    func fetchCustomQuests() async throws -> [Quest] {
        if let cached = store.customQuests {
            if store.pending.isEmpty { Task { await self.refreshCustomQuests() } }
            return cached
        }
        let quests = try await remote.fetchCustomQuests()
        store.customQuests = quests
        return quests
    }

    func createCustomQuest(_ quest: Quest) async throws -> Quest {
        store.customQuests = (store.customQuests ?? []) + [quest]
        enqueue(.createCustomQuest(quest))
        return quest
    }

    func deleteCustomQuest(id: String) async throws {
        store.customQuests = (store.customQuests ?? []).filter { $0.id != id }
        enqueue(.deleteCustomQuest(id))
    }

    // MARK: - Custom rewards

    func fetchCustomRewards() async throws -> [Reward] {
        if let cached = store.customRewards {
            if store.pending.isEmpty { Task { await self.refreshCustomRewards() } }
            return cached
        }
        let rewards = try await remote.fetchCustomRewards()
        store.customRewards = rewards
        return rewards
    }

    func createCustomReward(_ reward: Reward) async throws -> Reward {
        store.customRewards = (store.customRewards ?? []) + [reward]
        enqueue(.createCustomReward(reward))
        return reward
    }

    func deleteCustomReward(id: String) async throws {
        store.customRewards = (store.customRewards ?? []).filter { $0.id != id }
        enqueue(.deleteCustomReward(id))
    }

    // MARK: - Queue

    private func enqueue(_ mutation: PendingMutation) {
        store.pending.append(mutation)
        Task { await self.flushPendingWrites() }
    }

    func pendingWriteCount() async -> Int {
        store.pending.count
    }

    func flushPendingWrites() async {
        guard !isFlushing else { return }
        isFlushing = true
        defer { isFlushing = false }

        while let next = store.pending.first {
            do {
                try await apply(next)
                store.pending.removeFirst()
            } catch let error as APIError where error.isRetryable {
                // Still offline or the server is unwell — leave the queue
                // intact and try again on the next write or launch.
                return
            } catch {
                // Permanently rejected (bad request, deleted resource). Drop it
                // rather than blocking every write behind it forever, but record
                // it so the UI can tell the parent something didn't stick.
                store.pending.removeFirst()
                rejectedWrites += 1
            }
        }
    }

    private func apply(_ mutation: PendingMutation) async throws {
        switch mutation {
        case .createKid(let kid):            _ = try await remote.createKid(kid)
        case .updateKid(let kid):            _ = try await remote.updateKid(kid)
        case .deleteKid(let id):             try await remote.deleteKid(id: id)
        case .recordCompletion(let kid, let completion):
            try await remote.recordCompletion(completion, for: kid)
        case .claimReward(let kid, let rewardId):
            try await remote.claimReward(rewardId: rewardId, for: kid)
        case .createCustomQuest(let quest):  _ = try await remote.createCustomQuest(quest)
        case .deleteCustomQuest(let id):     try await remote.deleteCustomQuest(id: id)
        case .createCustomReward(let reward): _ = try await remote.createCustomReward(reward)
        case .deleteCustomReward(let id):    try await remote.deleteCustomReward(id: id)
        }
    }

    /// Wipes every cached byte. Called on sign-out so the next parent to sign in
    /// on this device can't see the previous family's children.
    func clear() {
        store.clear()
    }

    // MARK: - Background refresh

    private func refreshKids() async {
        guard store.pending.isEmpty,
              let kids = try? await remote.fetchKids() else { return }
        store.kids = kids
    }

    private func refreshCustomQuests() async {
        guard store.pending.isEmpty,
              let quests = try? await remote.fetchCustomQuests() else { return }
        store.customQuests = quests
    }

    private func refreshCustomRewards() async {
        guard store.pending.isEmpty,
              let rewards = try? await remote.fetchCustomRewards() else { return }
        store.customRewards = rewards
    }

    private func upsert(_ kid: Kid) {
        var kids = store.kids ?? []
        if let index = kids.firstIndex(where: { $0.id == kid.id }) {
            kids[index] = kid
        } else {
            kids.append(kid)
        }
        store.kids = kids
    }
}

// MARK: - Cache storage

/// Plain UserDefaults-backed blobs. Isolated to the actor above, so it needs no
/// locking of its own.
private final class CacheStore {

    private enum Keys {
        static let kids          = "habitkin_cache_kids"
        static let customQuests  = "habitkin_cache_custom_quests"
        static let customRewards = "habitkin_cache_custom_rewards"
        static let questLibrary  = "habitkin_cache_quest_library"
        static let rewardLibrary = "habitkin_cache_reward_library"
        static let pending       = "habitkin_pending_mutations"

        static let all = [kids, customQuests, customRewards,
                          questLibrary, rewardLibrary, pending]
    }

    var kids: [Kid]? {
        get { read(Keys.kids) }
        set { write(newValue, Keys.kids) }
    }

    var customQuests: [Quest]? {
        get { read(Keys.customQuests) }
        set { write(newValue, Keys.customQuests) }
    }

    var customRewards: [Reward]? {
        get { read(Keys.customRewards) }
        set { write(newValue, Keys.customRewards) }
    }

    var questLibrary: [Quest]? {
        get { read(Keys.questLibrary) }
        set { write(newValue, Keys.questLibrary) }
    }

    var rewardLibrary: [Reward]? {
        get { read(Keys.rewardLibrary) }
        set { write(newValue, Keys.rewardLibrary) }
    }

    var pending: [PendingMutation] {
        get { read(Keys.pending) ?? [] }
        set { write(newValue, Keys.pending) }
    }

    func clear() {
        Keys.all.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }

    private func read<T: Decodable>(_ key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func write<T: Encodable>(_ value: T?, _ key: String) {
        guard let value else {
            UserDefaults.standard.removeObject(forKey: key)
            return
        }
        guard let data = try? JSONEncoder().encode(value) else {
            // Leave whatever is already stored alone. Clearing here would
            // destroy the pending-write queue on an encode failure.
            return
        }
        UserDefaults.standard.set(data, forKey: key)
    }
}

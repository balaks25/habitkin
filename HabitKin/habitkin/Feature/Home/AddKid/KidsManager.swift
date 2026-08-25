//
//  KidsManager.swift
//  habitkin
//
//  Created by Balaji K S on 05/05/26.
//


import Combine
import Foundation

class KidsManager: ObservableObject {
    static let shared = KidsManager()

    @Published var kids: [Kid] = []
    @Published var loadState: LoadState = .idle

    /// Kept for call sites that only care whether the first load finished.
    var isLoaded: Bool { loadState == .loaded }

    @Published var selectedKidId: UUID? {
        didSet {
            if let id = selectedKidId {
                UserDefaults.standard.set(id.uuidString, forKey: Self.selectedKidKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Self.selectedKidKey)
            }
        }
    }

    private static let selectedKidKey = "selectedKidId"

    var selectedKid: Kid? {
        guard let id = selectedKidId else { return kids.first }
        return kids.first { $0.id == id } ?? kids.first
    }

    var hasKids: Bool { !kids.isEmpty }

    private let dataService = ServiceLocator.data

    private init() {
        if let idString = UserDefaults.standard.string(forKey: Self.selectedKidKey),
           let id = UUID(uuidString: idString) {
            selectedKidId = id
        }
        Task { await loadKids() }
    }

    // MARK: - Loading

    @MainActor
    func loadKids() async {
        loadState = .loading
        do {
            kids = try await dataService.fetchKids()
            loadState = .loaded
        } catch {
            // Deliberately does NOT fall back to an empty list: doing so sends
            // the parent into "add your first child", and the resulting save
            // overwrites the data that merely failed to load.
            loadState = .failed(error.localizedDescription)
        }
    }

    /// Retry after a failed load.
    func retryLoad() {
        Task { await loadKids() }
    }

    func pendingWriteCount() async -> Int {
        await dataService.pendingWriteCount()
    }

    /// Retries anything queued while offline. Called on launch and on foreground.
    func flushPendingWrites() {
        Task { await dataService.flushPendingWrites() }
    }

    // MARK: - Profile actions

    func addKid(_ kid: Kid) {
        kids.append(kid)
        if selectedKidId == nil {
            selectedKidId = kid.id
        }
        Task { _ = try? await dataService.createKid(kid) }
    }

    func selectKid(_ kid: Kid) {
        selectedKidId = kid.id
    }

    /// Profile-level edits (name, age, avatar, character, theme, parent
    /// switches). Progress is never sent through here — see `completeQuest`.
    func updateKid(_ kid: Kid) {
        guard applyLocally(kid) else { return }
        Task { _ = try? await dataService.updateKid(kid) }
    }

    func removeKid(_ kid: Kid) {
        kids.removeAll { $0.id == kid.id }
        if selectedKidId == kid.id {
            selectedKidId = kids.first?.id
        }
        Task { try? await dataService.deleteKid(id: kid.id) }
    }

    // MARK: - Progress actions

    /// Records a completion, pays out, and advances the week if that finished
    /// it. Returns false when the quest wasn't actually available.
    @discardableResult
    func completeQuest(_ quest: Quest, for kid: Kid) -> Bool {
        guard var updated = kids.first(where: { $0.id == kid.id }),
              let completion = updated.recordCompletion(of: quest) else { return false }

        // Week rules read from an immutable snapshot: handing `updated` to a
        // closure while it's being mutated is an exclusivity violation.
        let snapshot = updated
        updated.advanceWeekIfNeeded { week in
            CatalogManager.shared.quests(for: snapshot, week: week)
        }

        guard applyLocally(updated) else { return false }
        Task { try? await dataService.recordCompletion(completion, for: updated) }
        return true
    }

    @discardableResult
    func claimReward(_ reward: Reward, for kid: Kid) -> Bool {
        guard var updated = kids.first(where: { $0.id == kid.id }),
              updated.claimReward(reward) else { return false }

        guard applyLocally(updated) else { return false }
        Task { try? await dataService.claimReward(rewardId: reward.id, for: updated) }
        return true
    }

    // MARK: - Session

    /// Drops every trace of the signed-out family from this device.
    func clearLocalState() {
        kids = []
        selectedKidId = nil
        loadState = .idle
        if let cached = dataService as? CachedDataService {
            Task { await cached.clear() }
        }
    }

    // MARK: - Helpers

    @discardableResult
    private func applyLocally(_ kid: Kid) -> Bool {
        guard let index = kids.firstIndex(where: { $0.id == kid.id }) else { return false }
        kids[index] = kid
        return true
    }
}

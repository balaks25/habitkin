//
//  MockDataService.swift
//  habitkin
//
//  Local stand-in for a real backend. Kids persist to UserDefaults; the
//  quest/reward catalogs are the bundled static libraries.
//

import Foundation

final class MockDataService: KidsDataServicing {
    private let kidsKey = "habitkin_kids"

    func fetchKids() async throws -> [Kid] {
        guard let data = UserDefaults.standard.data(forKey: kidsKey),
              let kids = try? JSONDecoder().decode([Kid].self, from: data) else {
            return []
        }
        return kids
    }

    func createKid(_ kid: Kid) async throws -> Kid {
        var kids = try await fetchKids()
        kids.append(kid)
        try persist(kids)
        return kid
    }

    func updateKid(_ kid: Kid) async throws -> Kid {
        var kids = try await fetchKids()
        guard let index = kids.firstIndex(where: { $0.id == kid.id }) else { return kid }
        kids[index] = kid
        try persist(kids)
        return kid
    }

    func deleteKid(id: UUID) async throws {
        var kids = try await fetchKids()
        kids.removeAll { $0.id == id }
        try persist(kids)
    }

    func fetchQuestLibrary() async throws -> [Quest] {
        Quest.questLibrary
    }

    func fetchRewardLibrary() async throws -> [Reward] {
        Reward.rewardLibrary
    }

    private func persist(_ kids: [Kid]) throws {
        let data = try JSONEncoder().encode(kids)
        UserDefaults.standard.set(data, forKey: kidsKey)
    }
}

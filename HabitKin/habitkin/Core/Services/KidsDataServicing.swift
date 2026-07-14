//
//  KidsDataServicing.swift
//  habitkin
//
//  Swap seam for kid/quest/reward data — implemented today by MockDataService,
//  and by RemoteDataService once a real backend exists.
//

import Foundation

protocol KidsDataServicing {
    func fetchKids() async throws -> [Kid]
    func createKid(_ kid: Kid) async throws -> Kid
    func updateKid(_ kid: Kid) async throws -> Kid
    func deleteKid(id: UUID) async throws

    func fetchQuestLibrary() async throws -> [Quest]
    func fetchRewardLibrary() async throws -> [Reward]
}

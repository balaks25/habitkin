//
//  APIService.swift
//  habitkin
//
//  Lightweight API client stub.
//  Replace the placeholder URL and add auth headers once the backend is ready.
//  All data fetching will go through this service — no local DB.
//

import Foundation
import Combine

// MARK: - API Errors

enum APIError: LocalizedError {
    case notAuthenticated
    case invalidResponse
    case serverError(Int)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:   return "User is not authenticated."
        case .invalidResponse:    return "Invalid response from server."
        case .serverError(let c): return "Server error: \(c)."
        case .decodingFailed(let e): return "Decoding failed: \(e.localizedDescription)"
        }
    }
}

// MARK: - APIService

final class APIService: ObservableObject {

    static let shared = APIService()

    // ── Replace with real base URL when backend is ready ─────────────
    private let baseURL = URL(string: "https://api.habitkin.app/v1")!

    // Auth token — set this after sign-in
    var authToken: String? {
        get { UserDefaults.standard.string(forKey: "habitkin_auth_token") }
        set { UserDefaults.standard.set(newValue, forKey: "habitkin_auth_token") }
    }

    private var headers: [String: String] {
        var h = ["Content-Type": "application/json"]
        if let token = authToken { h["Authorization"] = "Bearer \(token)" }
        return h
    }

    private init() {}

    // MARK: - Generic request

    func request<T: Decodable>(_ path: String,
                               method: String = "GET",
                               body: Encodable? = nil) async throws -> T {
        guard let token = authToken else { throw APIError.notAuthenticated }
        _ = token // will be used in headers above

        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw APIError.serverError(http.statusCode) }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    // MARK: - Kids

    /// Fetch all kids for the authenticated parent
    func fetchKids() async throws -> [Kid] {
        try await request("kids")
    }

    /// Create a new kid profile on the backend
    func createKid(_ kid: Kid) async throws -> Kid {
        try await request("kids", method: "POST", body: kid)
    }

    /// Update an existing kid (after quest completion, reward claim, etc.)
    func updateKid(_ kid: Kid) async throws -> Kid {
        try await request("kids/\(kid.id.uuidString)", method: "PUT", body: kid)
    }

    /// Delete a kid profile
    func deleteKid(id: UUID) async throws {
        let _: EmptyResponse = try await request("kids/\(id.uuidString)", method: "DELETE")
    }

    // MARK: - Quests

    /// Fetch quest library (allows server-side customization per user)
    func fetchQuests() async throws -> [Quest] {
        try await request("quests")
    }

    /// Mark a quest as completed for a kid
    func completeQuest(kidId: UUID, questId: String) async throws {
        let _: EmptyResponse = try await request(
            "kids/\(kidId.uuidString)/quests/\(questId)/complete",
            method: "POST"
        )
    }

    // MARK: - Rewards

    /// Fetch reward catalog
    func fetchRewards() async throws -> [Reward] {
        try await request("rewards")
    }

    /// Claim a reward for a kid
    func claimReward(kidId: UUID, rewardId: String) async throws {
        let _: EmptyResponse = try await request(
            "kids/\(kidId.uuidString)/rewards/\(rewardId)/claim",
            method: "POST"
        )
    }
}

// MARK: - Helpers

private struct EmptyResponse: Decodable {}

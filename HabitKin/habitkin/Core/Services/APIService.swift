//
//  APIService.swift
//  habitkin
//
//  Real backend implementations of AuthServicing / KidsDataServicing.
//  Not wired up yet — endpoint paths are placeholders until a backend exists.
//  Once ready, swap ServiceLocator.auth/.data to RemoteAuthService()/RemoteDataService().
//

import Foundation

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

// MARK: - APIClient

final class APIClient {

    static let shared = APIClient()

    // ── Replace with real base URL when backend is ready ─────────────
    private let baseURL = URL(string: "https://api.habitkin.app/v1")!

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

    func request<T: Decodable>(_ path: String,
                               method: String = "GET",
                               body: Encodable? = nil) async throws -> T {
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
}

private struct EmptyResponse: Decodable {}

// MARK: - RemoteDataService

final class RemoteDataService: KidsDataServicing {

    func fetchKids() async throws -> [Kid] {
        try await APIClient.shared.request("kids")
    }

    func createKid(_ kid: Kid) async throws -> Kid {
        try await APIClient.shared.request("kids", method: "POST", body: kid)
    }

    func updateKid(_ kid: Kid) async throws -> Kid {
        try await APIClient.shared.request("kids/\(kid.id.uuidString)", method: "PUT", body: kid)
    }

    func deleteKid(id: UUID) async throws {
        let _: EmptyResponse = try await APIClient.shared.request("kids/\(id.uuidString)", method: "DELETE")
    }

    func fetchQuestLibrary() async throws -> [Quest] {
        try await APIClient.shared.request("quests")
    }

    func fetchRewardLibrary() async throws -> [Reward] {
        try await APIClient.shared.request("rewards")
    }
}

// MARK: - RemoteAuthService

private struct AuthRequest: Encodable {
    let name: String?
    let email: String
    let password: String
}

private struct AuthResponse: Decodable {
    let id: UUID
    let name: String
    let email: String
    let token: String
}

final class RemoteAuthService: AuthServicing {

    private(set) var currentUser: ParentUser?

    func signUp(name: String, email: String, password: String) async throws -> ParentUser {
        let response: AuthResponse = try await APIClient.shared.request(
            "auth/signup", method: "POST",
            body: AuthRequest(name: name, email: email, password: password)
        )
        APIClient.shared.authToken = response.token
        let user = ParentUser(id: response.id, name: response.name, email: response.email)
        currentUser = user
        return user
    }

    func signIn(email: String, password: String) async throws -> ParentUser {
        let response: AuthResponse = try await APIClient.shared.request(
            "auth/signin", method: "POST",
            body: AuthRequest(name: nil, email: email, password: password)
        )
        APIClient.shared.authToken = response.token
        let user = ParentUser(id: response.id, name: response.name, email: response.email)
        currentUser = user
        return user
    }

    func signOut() {
        currentUser = nil
        APIClient.shared.authToken = nil
    }
}

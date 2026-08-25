//
//  APIService.swift
//  habitkin
//
//  Real backend implementations of AuthServicing / KidsDataServicing.
//  Endpoint paths are the intended contract; flip ServiceLocator to
//  `.remote` once the server is live.
//
//  Contract rule the server must hold to: every /kids route resolves the
//  parent from the bearer token. There is deliberately no parentId parameter
//  anywhere below — accepting one would let any caller read another family's
//  children by guessing an id.
//

import Foundation

// MARK: - API Errors

enum APIError: LocalizedError {
    case notAuthenticated
    case invalidResponse
    case serverError(Int)
    case decodingFailed(Error)
    case offline

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:      return "You're signed out. Please sign in again."
        case .invalidResponse:       return "Invalid response from server."
        case .serverError(let code): return "Server error: \(code)."
        case .decodingFailed(let e): return "Decoding failed: \(e.localizedDescription)"
        case .offline:               return "No internet connection."
        }
    }

    /// Whether retrying later could plausibly succeed. Drives the offline queue:
    /// a 400 will never succeed, a 503 or a dropped connection might.
    var isRetryable: Bool {
        switch self {
        case .offline:               return true
        case .serverError(let code): return code >= 500 || code == 429
        default:                     return false
        }
    }
}

// MARK: - APIClient

final class APIClient {

    static let shared = APIClient()

    // ── Replace with real base URL when backend is ready ─────────────
    private let baseURL = URL(string: "https://api.habitkin.app/v1")!

    /// Bearer token, kept in the Keychain rather than UserDefaults.
    var authToken: String? {
        get { KeychainStore.get(KeychainStore.Key.authToken) }
        set { KeychainStore.set(newValue, for: KeychainStore.Key.authToken) }
    }

    private var headers: [String: String] {
        var headers = ["Content-Type": "application/json"]
        if let token = authToken { headers["Authorization"] = "Bearer \(token)" }
        return headers
    }

    private lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private init() {}

    @discardableResult
    func send(_ path: String,
              method: String = "GET",
              body: Encodable? = nil,
              query: [String: String] = [:],
              authenticated: Bool = true) async throws -> Data {

        if authenticated, authToken == nil { throw APIError.notAuthenticated }

        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )
        if !query.isEmpty {
            components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = components?.url else { throw APIError.invalidResponse }

        var request = URLRequest(url: url)
        request.httpMethod = method
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        if let body { request.httpBody = try encoder.encode(body) }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError where Self.offlineCodes.contains(error.code) {
            throw APIError.offline
        }

        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        if http.statusCode == 401 {
            authToken = nil
            throw APIError.notAuthenticated
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.serverError(http.statusCode)
        }
        return data
    }

    func request<T: Decodable>(_ path: String,
                               method: String = "GET",
                               body: Encodable? = nil,
                               query: [String: String] = [:],
                               authenticated: Bool = true) async throws -> T {
        let data = try await send(path, method: method, body: body,
                                  query: query, authenticated: authenticated)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    private static let offlineCodes: Set<URLError.Code> = [
        .notConnectedToInternet, .networkConnectionLost,
        .timedOut, .cannotFindHost, .cannotConnectToHost, .dataNotAllowed
    ]
}

// MARK: - RemoteDataService

/// Body for appending a completion — the whole point of the granular endpoint
/// is that this payload stays the same size no matter how long the history is.
private struct CompletionBody: Encodable {
    let questId: String
    let questName: String
    let coins: Int
    let date: Date
}

private struct ClaimBody: Encodable {
    let rewardId: String
}

/// Only the fields a parent can edit. Coins, streaks and history are owned by
/// the server — a client that could PUT them could mint itself coins.
private struct KidProfileBody: Encodable {
    let name: String
    let avatar: String
    let age: Int
    let characterId: String
    let themeId: String
    let disabledQuestIds: [String]
    let disabledRewardIds: [String]
}

final class RemoteDataService: KidsDataServicing {

    // MARK: Kids

    func fetchKids() async throws -> [Kid] {
        try await APIClient.shared.request("kids")
    }

    func createKid(_ kid: Kid) async throws -> Kid {
        try await APIClient.shared.request("kids", method: "POST", body: kid)
    }

    func updateKid(_ kid: Kid) async throws -> Kid {
        try await APIClient.shared.request(
            "kids/\(kid.id.uuidString)",
            method: "PATCH",
            body: KidProfileBody(
                name: kid.name,
                avatar: kid.avatar,
                age: kid.age,
                characterId: kid.characterId,
                themeId: kid.themeId,
                disabledQuestIds: Array(kid.disabledQuestIds),
                disabledRewardIds: Array(kid.disabledRewardIds)
            )
        )
    }

    func deleteKid(id: UUID) async throws {
        try await APIClient.shared.send("kids/\(id.uuidString)", method: "DELETE")
    }

    // MARK: Granular writes

    func recordCompletion(_ completion: QuestCompletion, for kid: Kid) async throws {
        try await APIClient.shared.send(
            "kids/\(kid.id.uuidString)/completions",
            method: "POST",
            body: CompletionBody(questId: completion.questId,
                                 questName: completion.questName,
                                 coins: completion.coins,
                                 date: completion.date)
        )
    }

    func claimReward(rewardId: String, for kid: Kid) async throws {
        try await APIClient.shared.send(
            "kids/\(kid.id.uuidString)/claims",
            method: "POST",
            body: ClaimBody(rewardId: rewardId)
        )
    }

    func flushPendingWrites() async {}

    /// Writes go straight to the server here, so nothing is ever queued.
    func pendingWriteCount() async -> Int { 0 }

    // MARK: Catalogs

    func fetchQuestLibrary() async throws -> [Quest] {
        try await APIClient.shared.request("quests")
    }

    func fetchRewardLibrary() async throws -> [Reward] {
        try await APIClient.shared.request("rewards")
    }

    // MARK: Custom quests

    func fetchCustomQuests() async throws -> [Quest] {
        try await APIClient.shared.request("custom-quests")
    }

    func createCustomQuest(_ quest: Quest) async throws -> Quest {
        try await APIClient.shared.request("custom-quests", method: "POST", body: quest)
    }

    func deleteCustomQuest(id: String) async throws {
        try await APIClient.shared.send("custom-quests/\(id)", method: "DELETE")
    }

    // MARK: Custom rewards

    func fetchCustomRewards() async throws -> [Reward] {
        try await APIClient.shared.request("custom-rewards")
    }

    func createCustomReward(_ reward: Reward) async throws -> Reward {
        try await APIClient.shared.request("custom-rewards", method: "POST", body: reward)
    }

    func deleteCustomReward(id: String) async throws {
        try await APIClient.shared.send("custom-rewards/\(id)", method: "DELETE")
    }
}

// MARK: - RemoteAuthService

private struct SignUpBody: Encodable {
    let name: String
    let email: String
    let phone: String?
    let password: String
}

private struct SignInBody: Encodable {
    let email: String
    let password: String
}

private struct ResetBody: Encodable {
    let email: String
}

private struct AuthResponse: Decodable {
    let id: UUID
    let name: String
    let email: String
    let phone: String?
    let token: String
}

final class RemoteAuthService: AuthServicing {

    private(set) var currentUser: ParentUser?

    func restoreSession() async -> ParentUser? {
        guard APIClient.shared.authToken != nil else { return nil }
        do {
            let response: AuthResponse = try await APIClient.shared.request("auth/me")
            let user = ParentUser(id: response.id, name: response.name,
                                  email: response.email, phone: response.phone)
            currentUser = user
            return user
        } catch {
            return nil
        }
    }

    func signUp(name: String, email: String, phone: String?, password: String) async throws -> ParentUser {
        let email = Validators.normalizedEmail(email)
        guard Validators.isValidEmail(email) else { throw AuthError.invalidEmail }
        guard Validators.isValidPassword(password) else { throw AuthError.weakPassword }
        guard Validators.isValidPhone(phone ?? "") else { throw AuthError.invalidPhone }

        let response: AuthResponse = try await APIClient.shared.request(
            "auth/signup", method: "POST",
            body: SignUpBody(name: name, email: email,
                             phone: (phone?.isEmpty ?? true) ? nil : phone,
                             password: password),
            authenticated: false
        )
        return store(response)
    }

    func signIn(email: String, password: String) async throws -> ParentUser {
        let email = Validators.normalizedEmail(email)
        guard Validators.isValidEmail(email) else { throw AuthError.invalidEmail }
        guard Validators.isValidPassword(password) else { throw AuthError.weakPassword }

        let response: AuthResponse = try await APIClient.shared.request(
            "auth/signin", method: "POST",
            body: SignInBody(email: email, password: password),
            authenticated: false
        )
        return store(response)
    }

    func requestPasswordReset(email: String) async throws {
        let email = Validators.normalizedEmail(email)
        guard Validators.isValidEmail(email) else { throw AuthError.invalidEmail }
        try await APIClient.shared.send("auth/password-reset", method: "POST",
                                        body: ResetBody(email: email),
                                        authenticated: false)
    }

    func deleteAccount() async throws {
        try await APIClient.shared.send("account", method: "DELETE")
        signOut()
    }

    func signOut() {
        currentUser = nil
        APIClient.shared.authToken = nil
    }

    private func store(_ response: AuthResponse) -> ParentUser {
        APIClient.shared.authToken = response.token
        let user = ParentUser(id: response.id, name: response.name,
                              email: response.email, phone: response.phone)
        currentUser = user
        return user
    }
}

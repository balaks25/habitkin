//
//  MockAuthService.swift
//  habitkin
//
//  Local stand-in for a real auth backend. Any credentials succeed after a
//  simulated network delay; the "account" is just persisted to UserDefaults.
//

import Foundation

final class MockAuthService: AuthServicing {
    private let userKey = "habitkin_mock_current_user"

    private(set) var currentUser: ParentUser? {
        didSet { persist(currentUser) }
    }

    init() {
        currentUser = Self.loadPersistedUser(key: userKey)
    }

    func signUp(name: String, email: String, password: String) async throws -> ParentUser {
        try await Task.sleep(nanoseconds: 800_000_000)
        let user = ParentUser(id: UUID(), name: name, email: email)
        currentUser = user
        return user
    }

    func signIn(email: String, password: String) async throws -> ParentUser {
        try await Task.sleep(nanoseconds: 800_000_000)
        if let existing = currentUser, existing.email == email {
            return existing
        }
        let fallbackName = email.split(separator: "@").first.map(String.init) ?? "Parent"
        let user = ParentUser(id: UUID(), name: fallbackName, email: email)
        currentUser = user
        return user
    }

    func signOut() {
        currentUser = nil
    }

    private func persist(_ user: ParentUser?) {
        guard let user, let data = try? JSONEncoder().encode(user) else {
            UserDefaults.standard.removeObject(forKey: userKey)
            return
        }
        UserDefaults.standard.set(data, forKey: userKey)
    }

    private static func loadPersistedUser(key: String) -> ParentUser? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(ParentUser.self, from: data)
    }
}

//
//  MockAuthService.swift
//  habitkin
//
//  Local stand-in for a real auth backend. Credentials are validated for shape
//  but not verified against anything; the "account" is persisted locally.
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

    func restoreSession() async -> ParentUser? {
        currentUser
    }

    func signUp(name: String, email: String, phone: String?, password: String) async throws -> ParentUser {
        let email = Validators.normalizedEmail(email)
        guard Validators.isValidEmail(email) else { throw AuthError.invalidEmail }
        guard Validators.isValidPassword(password) else { throw AuthError.weakPassword }
        guard Validators.isValidPhone(phone ?? "") else { throw AuthError.invalidPhone }

        try await Task.sleep(nanoseconds: 800_000_000)
        let user = ParentUser(id: UUID(), name: name, email: email,
                              phone: (phone?.isEmpty ?? true) ? nil : phone)
        currentUser = user
        return user
    }

    func signIn(email: String, password: String) async throws -> ParentUser {
        let email = Validators.normalizedEmail(email)
        guard Validators.isValidEmail(email) else { throw AuthError.invalidEmail }
        guard Validators.isValidPassword(password) else { throw AuthError.weakPassword }

        try await Task.sleep(nanoseconds: 800_000_000)
        if let existing = currentUser, existing.email == email {
            return existing
        }
        let fallbackName = email.split(separator: "@").first.map(String.init) ?? "Parent"
        let user = ParentUser(id: UUID(), name: fallbackName, email: email)
        currentUser = user
        return user
    }

    func requestPasswordReset(email: String) async throws {
        guard Validators.isValidEmail(Validators.normalizedEmail(email)) else {
            throw AuthError.invalidEmail
        }
        try await Task.sleep(nanoseconds: 600_000_000)
    }

    func deleteAccount() async throws {
        try await Task.sleep(nanoseconds: 600_000_000)
        currentUser = nil
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

//
//  AuthServicing.swift
//  habitkin
//
//  Swap seam for authentication — implemented today by MockAuthService,
//  and by RemoteAuthService once a real backend exists.
//

import Foundation

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case invalidPhone
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .invalidEmail:     return "Enter a valid email address."
        case .weakPassword:     return "Password must be at least \(Validators.minimumPasswordLength) characters."
        case .invalidPhone:     return "Enter a valid phone number, or leave it blank."
        case .notAuthenticated: return "You're signed out. Please sign in again."
        }
    }
}

protocol AuthServicing {
    var currentUser: ParentUser? { get }

    /// Called on launch: exchanges a stored token for the current account, so a
    /// returning parent isn't asked to sign in again. Returns nil when there is
    /// no valid session.
    func restoreSession() async -> ParentUser?

    func signUp(name: String, email: String, phone: String?, password: String) async throws -> ParentUser
    func signIn(email: String, password: String) async throws -> ParentUser

    /// Sends a reset link/code. Always succeeds from the caller's point of view
    /// — revealing whether an address is registered is an enumeration leak.
    func requestPasswordReset(email: String) async throws

    /// Required by App Review guideline 5.1.1(v): any app with account creation
    /// must offer in-app account deletion.
    func deleteAccount() async throws

    func signOut()
}

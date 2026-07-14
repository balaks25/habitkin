//
//  AuthServicing.swift
//  habitkin
//
//  Swap seam for authentication — implemented today by MockAuthService,
//  and by RemoteAuthService once a real backend exists.
//

import Foundation

protocol AuthServicing {
    var currentUser: ParentUser? { get }
    func signUp(name: String, email: String, password: String) async throws -> ParentUser
    func signIn(email: String, password: String) async throws -> ParentUser
    func signOut()
}

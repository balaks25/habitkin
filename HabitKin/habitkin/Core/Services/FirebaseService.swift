//
//  FirebaseService.swift
//  habitkin
//
//  Created by Balaji K S on 22/04/26.
//

import FirebaseAuth
import FirebaseFirestore
import Combine

class FirebaseService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    static let shared = FirebaseService()
    
    private let db = Firestore.firestore()
    
    // MARK: - Auth
    func loginWithApple(credential: AuthCredential) async throws -> User {
        let result = try await Auth.auth().signIn(with: credential)
        self.currentUser = result.user
        self.isAuthenticated = true
        return result.user
    }
    
    func loginWithGoogle(credential: AuthCredential) async throws -> User {
        let result = try await Auth.auth().signIn(with: credential)
        self.currentUser = result.user
        self.isAuthenticated = true
        return result.user
    }
    
    func logout() throws {
        try Auth.auth().signOut()
        self.currentUser = nil
        self.isAuthenticated = false
    }
    
    // MARK: - Firestore
    func syncKid(_ kid: Kid) async throws {
        guard let userId = currentUser?.uid else { throw NSError(domain: "Not authenticated", code: -1) }
        try await db.collection("users").document(userId)
            .collection("kids").document(kid.id.uuidString)
            .setData(from: kid)
    }
    
    func fetchKids() async throws -> [Kid] {
        guard let userId = currentUser?.uid else { throw NSError(domain: "Not authenticated", code: -1) }
        let snapshot = try await db.collection("users").document(userId)
            .collection("kids").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Kid.self) }
    }
}

//
//  ParentUser.swift
//  habitkin
//

import Foundation

struct ParentUser: Identifiable, Codable {
    let id: UUID
    var name: String
    /// The account identifier. Always lowercased before it reaches the server
    /// so "A@x.com" and "a@x.com" can't become two accounts.
    var email: String
    /// Optional on purpose. App Review guideline 5.1.1(ix) doesn't allow
    /// demanding personal data the app doesn't need, and a habit tracker
    /// doesn't need a phone number to function — it's for recovery only.
    var phone: String?

    init(id: UUID, name: String, email: String, phone: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
    }
}

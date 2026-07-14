//
//  ParentUser.swift
//  habitkin
//

import Foundation

struct ParentUser: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
}

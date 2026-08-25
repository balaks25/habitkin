//
//  Validators.swift
//  habitkin
//
//  Client-side credential checks. The server must re-validate everything —
//  these exist to give the parent an error before a pointless round trip.
//

import Foundation

enum Validators {

    static let minimumPasswordLength = 8

    /// Deliberately permissive: one @, a dot in the domain, no whitespace.
    /// Stricter regexes reject valid addresses more often than they help.
    static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.contains(" "), trimmed.count <= 254 else { return false }
        let parts = trimmed.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2,
              !parts[0].isEmpty,
              parts[1].contains("."),
              !parts[1].hasPrefix("."),
              !parts[1].hasSuffix(".") else { return false }
        return true
    }

    static func isValidPassword(_ password: String) -> Bool {
        password.count >= minimumPasswordLength
    }

    /// Optional field — empty is fine, but a supplied number must look real.
    static func isValidPhone(_ phone: String) -> Bool {
        let trimmed = phone.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return true }
        let digits = trimmed.filter(\.isNumber)
        return digits.count >= 7 && digits.count <= 15
    }

    static func normalizedEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespaces).lowercased()
    }
}

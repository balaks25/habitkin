//
//  KeychainStore.swift
//  habitkin
//
//  The API token and the parent PIN are the only secrets this app holds. Both
//  used to sit in UserDefaults, which is readable from an unencrypted device
//  backup — not somewhere to keep a bearer token or a PIN.
//

import Foundation
import Security

enum KeychainStore {

    enum Key {
        static let authToken = "habitkin_auth_token"
        static let parentPIN = "habitkin_parent_pin"
    }

    private static let service = "app.habitkin.credentials"

    /// Returns false if the write didn't land. Callers that gate access on a
    /// stored secret must check this — assuming success and then reading back
    /// nil leaves the user permanently locked out of their own PIN.
    @discardableResult
    static func set(_ value: String?, for key: String) -> Bool {
        guard let value, !value.isEmpty else {
            remove(key)
            return true
        }
        guard let data = value.data(using: .utf8) else { return false }

        var query = baseQuery(key)
        SecItemDelete(query as CFDictionary)          // upsert
        query[kSecValueData as String] = data
        // Readable after the first unlock so background refreshes still work,
        // but never migrated to another device.
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    static func get(_ key: String) -> String? {
        var query = baseQuery(key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func remove(_ key: String) {
        SecItemDelete(baseQuery(key) as CFDictionary)
    }

    private static func baseQuery(_ key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
    }
}

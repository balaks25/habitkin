//
//  LoadState.swift
//  habitkin
//
//  Shared load lifecycle. The app previously collapsed "still loading",
//  "loaded and empty" and "failed to load" into one empty array, which is how
//  a failed fetch ended up looking exactly like a brand-new account.
//

import Foundation

enum LoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)

    var isLoading: Bool { self == .loading || self == .idle }

    var errorMessage: String? {
        if case .failed(let message) = self { return message }
        return nil
    }
}

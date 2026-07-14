//
//  ServiceLocator.swift
//  habitkin
//
//  The single swap point between the mock prototype and a real backend.
//  Once the API exists, change these two lines to RemoteAuthService() / RemoteDataService().
//

enum ServiceLocator {
    static let auth: AuthServicing = MockAuthService()
    static let data: KidsDataServicing = MockDataService()
}

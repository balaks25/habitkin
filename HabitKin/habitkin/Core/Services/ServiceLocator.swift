//
//  ServiceLocator.swift
//  habitkin
//
//  The single swap point between the local prototype and the real backend.
//
//  Switch `backend` to `.remote` once https://api.habitkin.app/v1 is live.
//  Nothing else in the app needs to change: `.remote` wraps RemoteDataService
//  in CachedDataService, so reads stay instant and writes survive a dropped
//  connection.
//

enum Backend {
    case local   // MockAuthService + MockDataService, all on-device
    case remote  // RemoteAuthService + CachedDataService(RemoteDataService)
}

enum ServiceLocator {

    /// ── Flip this one line when the API is ready. ──
    static let backend: Backend = .local

    static let auth: AuthServicing = {
        switch backend {
        case .local:  return MockAuthService()
        case .remote: return RemoteAuthService()
        }
    }()

    static let data: KidsDataServicing = {
        switch backend {
        case .local:  return MockDataService()
        case .remote: return CachedDataService(remote: RemoteDataService())
        }
    }()
}

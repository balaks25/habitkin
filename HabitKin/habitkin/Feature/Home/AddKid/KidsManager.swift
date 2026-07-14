//
//  KidsManager.swift
//  habitkin
//
//  Created by Balaji K S on 05/05/26.
//


import Combine
import Foundation

class KidsManager: ObservableObject {
    static let shared = KidsManager()

    @Published var kids: [Kid] = []
    @Published var isLoaded = false

    @Published var selectedKidId: UUID? {
        didSet {
            if let id = selectedKidId {
                UserDefaults.standard.set(id.uuidString, forKey: "selectedKidId")
            }
        }
    }

    var selectedKid: Kid? {
        guard let id = selectedKidId else { return kids.first }
        return kids.first { $0.id == id } ?? kids.first
    }

    var hasKids: Bool { !kids.isEmpty }

    private let dataService = ServiceLocator.data

    private init() {
        if let idString = UserDefaults.standard.string(forKey: "selectedKidId"),
           let id = UUID(uuidString: idString) {
            selectedKidId = id
        }
        Task { await loadKids() }
    }

    // MARK: - Loading

    @MainActor
    func loadKids() async {
        kids = (try? await dataService.fetchKids()) ?? []
        isLoaded = true
    }

    // MARK: - Actions

    func addKid(_ kid: Kid) {
        kids.append(kid)
        if selectedKidId == nil {
            selectedKidId = kid.id
        }
        Task { _ = try? await dataService.createKid(kid) }
    }

    func selectKid(_ kid: Kid) {
        selectedKidId = kid.id
    }

    func updateKid(_ kid: Kid) {
        guard let index = kids.firstIndex(where: { $0.id == kid.id }) else { return }
        kids[index] = kid
        Task { _ = try? await dataService.updateKid(kid) }
    }

    func removeKid(_ kid: Kid) {
        kids.removeAll { $0.id == kid.id }
        if selectedKidId == kid.id {
            selectedKidId = kids.first?.id
        }
        Task { try? await dataService.deleteKid(id: kid.id) }
    }
}

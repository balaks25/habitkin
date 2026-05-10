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

    @Published var kids: [Kid] = [] {
        didSet { save() }
    }

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

    private init() {
        load()
    }

    // MARK: - Actions

    func addKid(_ kid: Kid) {
        kids.append(kid)
        if selectedKidId == nil {
            selectedKidId = kid.id
        }
    }

    func selectKid(_ kid: Kid) {
        selectedKidId = kid.id
    }

    func removeKid(_ kid: Kid) {
        kids.removeAll { $0.id == kid.id }
        if selectedKidId == kid.id {
            selectedKidId = kids.first?.id
        }
    }

    // MARK: - Persistence

    private let kidsKey = "habitkin_kids"

    private func save() {
        if let data = try? JSONEncoder().encode(kids) {
            UserDefaults.standard.set(data, forKey: kidsKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: kidsKey),
           let saved = try? JSONDecoder().decode([Kid].self, from: data) {
            kids = saved
        }
        if let idString = UserDefaults.standard.string(forKey: "selectedKidId"),
           let id = UUID(uuidString: idString) {
            selectedKidId = id
        }
    }
}

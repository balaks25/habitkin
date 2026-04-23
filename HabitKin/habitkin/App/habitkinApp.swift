//
//  habitkinApp.swift
//  habitkin
//
//  Created by Balaji K S on 22/04/26.
//

import SwiftUI

@main
struct HabitKinApp: App {
    @State private var selectedKid: Kid?
    
    var body: some Scene {
        WindowGroup {
            if let kid = selectedKid {
                HomeView(kid: kid)
            } else {
                CharacterSelectionView()
            }
        }
    }
}

//
//  SyncService.swift
//  habitkin
//
//  Created by Balaji K S on 22/04/26.
//

import Combine

class SyncService: ObservableObject {
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    
    private let firebase = FirebaseService.shared
    private let coreDataStack = CoreDataStack.shared
    
    // MARK: - Bidirectional Sync
    func syncAllData() async {
        isSyncing = true
        
        do {
            // 1. Fetch from Firebase
            let remoteKids = try await firebase.fetchKids()
            
            // 2. Save to CoreData
            for kid in remoteKids {
                // Save kid to CoreData
                let kidCD = NSEntityDescription.insertNewObject(
                    forEntityName: "KidCD",
                    into: coreDataStack.container.viewContext
                )
                kidCD.setValue(kid.id.uuidString, forKey: "id")
                kidCD.setValue(kid.name, forKey: "name")
                // ... more mappings
            }
            
            coreDataStack.save()
            lastSyncDate = Date()
            
        } catch {
            print("Sync error: \(error)")
        }
        
        isSyncing = false
    }
    
    // Push local changes to Firebase
    func pushLocalChanges() async {
        // Fetch changed items from CoreData
        // Push to Firebase
        // Mark as synced
    }
}

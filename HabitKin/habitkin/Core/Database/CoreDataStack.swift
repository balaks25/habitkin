//
//  CoreDataStack.swift
//  habitkin
//
//  Created by Balaji K S on 22/04/26.
//

import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "HabitKin")
        container.loadPersistentStores { _, error in
            if let error {
                print("CoreData Error: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}

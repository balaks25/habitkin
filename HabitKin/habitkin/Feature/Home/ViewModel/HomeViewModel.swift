//
//  HomeViewModel.swift
//  habitkin
//
//  Created by Balaji K S on 22/04/26.
//

import Combine
import SwiftUI
import CoreData

class HomeViewModel: ObservableObject {
    @Published var activeKid: Kid?
    @Published var todaysHabits: [Habit] = []
    @Published var kinStage: String = "egg"
    @Published var totalCoins: Int = 0
    @Published var isLoading = false
    @Published var error: String?
    
    private let coreDataStack = CoreDataStack.shared
    private let firebaseService = FirebaseService.shared
    private let syncService = SyncService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadKids()
        setupSync()
    }
    
    // MARK: - Load Data from CoreData
    func loadKids() {
        isLoading = true
        
        // Fetch from CoreData using NSFetchRequest
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "KidCD")
        
        do {
            let results = try coreDataStack.container.viewContext.fetch(request)
            if let firstKid = results.first {
                // Map CoreData to Swift model
                activeKid = mapKidCDToModel(firstKid)
                loadTodaysHabits()
            }
        } catch {
            self.error = "Failed to load kids"
        }
        
        isLoading = false
    }
    
    func loadTodaysHabits() {
        guard let activeKid else { return }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HabitCD")
        request.predicate = NSPredicate(format: "kidId == %@", activeKid.id.uuidString)
        
        do {
            let results = try coreDataStack.container.viewContext.fetch(request)
//            todaysHabits = results
//            todaysHabits = results.compactMap { mapHabitCDToModel($0) }
        } catch {
            self.error = "Failed to load habits"
        }
    }
    
    // MARK: - Complete Habit
    func completeHabit(_ habit: Habit) {
        var updatedHabit = habit
        updatedHabit.completedDates.append(Date())
        
        // Update CoreData
        updateHabitInCoreData(updatedHabit)
        
        // Update kid stats
        updateKidStats()
        
        // Sync to Firebase (async)
        Task {
            await syncToFirebase()
        }
    }
    
    // MARK: - Sync
    private func setupSync() {
        syncService.$lastSyncDate
            .sink { [weak self] _ in
                self?.loadKids()
            }
            .store(in: &cancellables)
    }
    
    func syncToFirebase() async {
        guard let activeKid else { return }
        do {
            try await firebaseService.syncKid(activeKid)
        } catch {
            self.error = "Sync failed"
        }
    }
    
    // MARK: - Helpers
    private func mapKidCDToModel(_ cdKid: NSFetchRequestResult) -> Kid? {
        // Convert CoreData to Swift model
        guard let kid = cdKid as? NSManagedObject else { return nil }
        return Kid(
            id: UUID(uuidString: kid.value(forKey: "id") as? String ?? "") ?? UUID(),
            name: kid.value(forKey: "name") as? String ?? "",
            avatar: kid.value(forKey: "avatar") as? String ?? "🦁",
            age: kid.value(forKey: "age") as? String ?? "6to8",
            character: kid.value(forKey: "character") as? String ?? "",
            theme: kid.value(forKey: "theme") as? String ?? "space",
            createdDate: kid.value(forKey: "createdDate") as? Date ?? Date(),
            totalCoins: (kid.value(forKey: "totalCoins") as? Int) ?? 0,
            totalEarned: (kid.value(forKey: "totalEarned") as? Int) ?? 0,
            totalCompleted: (kid.value(forKey: "totalCompleted") as? Int) ?? 0,
            streak: (kid.value(forKey: "streak") as? Int) ?? 0,
            kinStage: kid.value(forKey: "kinStage") as? String ?? "egg"
        )
    }
    
    private func updateHabitInCoreData(_ habit: Habit) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HabitCD")
        request.predicate = NSPredicate(format: "id == %@", habit.id.uuidString)
        
        do {
            if let habitCD = try coreDataStack.container.viewContext.fetch(request).first as? NSManagedObject {
                habitCD.setValue(habit.completedDates, forKey: "completedDates")
                coreDataStack.save()
            }
        } catch {
            print("Error updating habit: \(error)")
        }
    }
    
    private func updateKidStats() {
        guard var kid = activeKid else { return }
        kid.totalCompleted += 1
        kid.totalCoins += 10
        activeKid = kid
    }
}

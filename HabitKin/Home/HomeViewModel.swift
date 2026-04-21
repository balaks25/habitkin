import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var todayCompletedCount: Int = 0
    @Published var streakCount: Int = 0
    
    func loadHabits() {
        // Load habits from data store
    }
    
    func checkHabit(_ habit: Habit) {
        // Mark habit as completed
    }
}
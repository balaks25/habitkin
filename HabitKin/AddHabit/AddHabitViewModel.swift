import Foundation

@MainActor
class AddHabitViewModel: ObservableObject {
    @Published var habitName: String = ""
    @Published var habitDescription: String = ""
    @Published var selectedCategory: String = ""
    @Published var frequency: String = "Daily"
    
    func addHabit() {
        // Add habit logic
    }
}
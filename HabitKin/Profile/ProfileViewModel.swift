import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userProfile: User?
    @Published var totalPoints: Int = 0
    @Published var level: Int = 1
    @Published var badges: [Badge] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService.shared
    private let coreDataService = CoreDataService.shared
    
    struct Badge {
        let name: String
        let description: String
        let iconName: String
        let isEarned: Bool
    }
    
    init() {
        loadProfile()
    }
    
    func loadProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        
        if let cdUser = coreDataService.fetchUser(uid: uid) {
            userProfile = User(
                uid: cdUser.uid,
                email: cdUser.email,
                displayName: cdUser.displayName,
                profileImageURL: cdUser.profileImageURL,
                totalPoints: cdUser.totalPoints,
                level: cdUser.level,
                createdAt: cdUser.createdAt,
                lastSyncedAt: cdUser.lastSyncedAt
            )
            
            totalPoints = cdUser.totalPoints
            level = cdUser.level
        }
        
        loadBadges(userId: uid)
        isLoading = false
    }
    
    private func loadBadges(userId: String) {
        let points = coreDataService.fetchPoints(userId: userId)
        let totalEarned = points.reduce(0) { $0 + $1.points }
        let habits = coreDataService.fetchHabits(userId: userId)
        
        badges = [
            Badge(
                name: "Starter",
                description: "Earn 100 points",
                iconName: "star.fill",
                isEarned: totalEarned >= 100
            ),
            Badge(
                name: "Achiever",
                description: "Earn 500 points",
                iconName: "crown.fill",
                isEarned: totalEarned >= 500
            ),
            Badge(
                name: "Master",
                description: "Earn 1000 points",
                iconName: "flame.fill",
                isEarned: totalEarned >= 1000
            ),
            Badge(
                name: "Habit Builder",
                description: "Create 5 habits",
                iconName: "hammer.fill",
                isEarned: habits.count >= 5
            ),
            Badge(
                name: "Consistent",
                description: "7 day streak",
                iconName: "calendar.circle.fill",
                isEarned: calculateBestStreak(habits: habits) >= 7
            )
        ]
    }
    
    private func calculateBestStreak(habits: [CDHabit]) -> Int {
        var bestStreak = 0
        
        for habit in habits {
            let streak = calculateStreak(completedDates: habit.completedDates)
            bestStreak = max(bestStreak, streak)
        }
        
        return bestStreak
    }
    
    private func calculateStreak(completedDates: [Date]) -> Int {
        let today = Date()
        var streak = 0
        
        for i in 0... {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: today) ?? today
            let isCompleted = completedDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
            
            if isCompleted {
                streak += 1
            } else {
                break
            }
        }
        
        return streak
    }
    
    func updateProfile(displayName: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(uid).updateData(["displayName": displayName]) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                self?.loadProfile()
            }
        }
    }
}
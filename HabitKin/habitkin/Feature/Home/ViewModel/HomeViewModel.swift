import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var kid: Kid
    @Published var availableQuests: [Quest] = []
    @Published var completedToday: [Quest] = []
    @Published var showCelebration = false
    @Published var celebrationMessage = ""
    
    init(kid: Kid) {
        self.kid = kid
        loadQuests()
    }
    
    func loadQuests() {
        let allQuests = kid.getCurrentWeekQuests()
        availableQuests = allQuests
    }
    
    func completeQuest(_ quest: Quest) {
        kid.totalCoins += quest.coins
        kid.totalEarned += quest.coins
        kid.totalCompleted += 1
        kid.completedQuestIds.insert(quest.id)
        kid.updateKinStage()
        kid.updateKinMood(dailyCompleted: completedToday.count + 1)
        
        celebrationMessage = "🎉 +\(quest.coins) coins! \(quest.name)"
        showCelebration = true
        
        availableQuests.removeAll { $0.id == quest.id }
        completedToday.append(quest)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showCelebration = false
        }
        
        if kid.totalCompleted % 10 == 0 && kid.currentWeek < 4 {
            kid.currentWeek += 1
            loadQuests()
        }
    }
}

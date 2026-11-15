import Observation
import Foundation
import SwiftData

@Observable
class OnboardingViewModel {
    var goal = LearningGoal (name: "", duration: .week)
    
    var cleanName : String {
        return goal.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var canStart : Bool {
        return !cleanName.isEmpty
    }
    
    func start(context: ModelContext){
        goal.name = cleanName
        context.insert(goal)
        
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
    }
}

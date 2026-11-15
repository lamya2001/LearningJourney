import SwiftUI
import SwiftData

@main
struct LearningJourneyApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                StreakView()
            }else{
                OnboardingView()
            }
        }.modelContainer(for: LearningGoal.self)
    }
}

import SwiftUI
import SwiftData

@main
struct LearningJourneyApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                ActivityLoader()
            }else{
                OnboardingView()
            }
        }.modelContainer(for:[LearningGoal.self, DayLog.self])
    }
}

import SwiftUI
import SwiftData

struct ActivityLoader: View {
    @Query(sort: \LearningGoal.startDate, order: .reverse) private var goals: [LearningGoal]

    var body: some View {
        if let goal = goals.first {
            ActivityView(goal: goal)
                .id(goal.persistentModelID)
        } else {
            Text("No goals")
            //ContentUnavailableView
        }
    }
}

#Preview("Expired goal flow") {
    let container = try! ModelContainer(
        for: LearningGoal.self, DayLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let old = LearningGoal(name: "Swift", duration: .week)
    old.startDate = Date().addingTimeInterval(-10 * 24 * 3600)
    container.mainContext.insert(old)

    return ActivityLoader()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}

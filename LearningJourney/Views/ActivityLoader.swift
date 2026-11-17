import SwiftUI
import SwiftData

struct ActivityLoader: View {
    @Query(sort: \LearningGoal.startDate, order: .reverse) private var goals: [LearningGoal]

    var body: some View {
        if let goal = goals.first {
            ActivityView(goal: goal)
        } else {
            Text("No goals")
            //ContentUnavailableView
        }
    }
}

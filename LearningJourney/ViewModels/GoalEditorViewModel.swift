import Observation
import Foundation
import SwiftData

@Observable
class GoalEditorViewModel {
    var draft = LearningGoal(name: "", duration: .week)


    var cleanName: String {
        draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool {
        !cleanName.isEmpty
    }
    
    func prepare(editing goal: LearningGoal?) {
        draft = LearningGoal(
            name: goal?.name ?? "",
            duration: goal?.duration ?? .week
        )
    }

    func save(context: ModelContext) {
        guard canSave else { return }
        draft.name = cleanName
        draft.startDate = Date()
        context.insert(draft)
        try? context.save()
    }
}

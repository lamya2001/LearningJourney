import SwiftData
import Foundation


nonisolated enum GoalDuration : CaseIterable , Codable{
    case week
    case month
    case year
    
    var title: String {
        
        switch self {
        case .week : return "Week"
        case .month : return  "Month"
        case .year : return  "Year"
        }
    }
    
    var freezeLimit: Int{
        
        switch self{
        case .week : return 2
        case .month : return 8
        case .year : return 96
        }
    }
}


@Model
class LearningGoal{
    var name: String
    var duration: GoalDuration
    var startDate : Date
    @Relationship(deleteRule: .cascade) var logs: [DayLog] = []
    
    func log(on day: Date) -> DayLog? {
        return logs.first{ Calendar.current.isDate($0.loggedAt, inSameDayAs: day) }
    }
    
    var usedFreezes: Int{
        logs.filter { $0.dayStatus == .freeze}.count

    }
    
    init(name: String, duration: GoalDuration) {
        self.name = name
        self.duration = duration
        self.startDate = Date()
    }
}

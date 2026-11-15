import SwiftData
import Foundation


enum GoalDuration : CaseIterable , Codable{
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
}


@Model
class LearningGoal{
    var name: String
    var duration: GoalDuration
    var startDate : Date
    
    init(name: String, duration: GoalDuration) {
        self.name = name
        self.duration = duration
        self.startDate = Date()
    }
}

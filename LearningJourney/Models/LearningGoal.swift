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
    
    var calendarUnit : Calendar.Component{
        switch self {
        case .week : return .weekOfYear
        case .month : return .month
        case .year : return .year
        }
    }
}

nonisolated enum GoalProgress {
    case active
    case succeeded
    case failed
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
    
    var endDate: Date {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        return calendar.date(byAdding: duration.calendarUnit, value: 1, to: start) ?? .distantFuture //??
    }
    
    var hasFullCoverage: Bool {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        guard let totalDays = calendar.dateComponents([.day], from: start, to: endDate).day else { return false }
        let loggedDays = logs.filter { $0.loggedAt >= start && $0.loggedAt < endDate }.count
        return loggedDays >= totalDays
    }
    
    init(name: String, duration: GoalDuration) {
        self.name = name
        self.duration = duration
        self.startDate = Date()
    }
}

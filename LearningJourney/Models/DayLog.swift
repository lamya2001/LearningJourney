import SwiftData
import Foundation


nonisolated enum DayStatus : Codable{
    
    case learned
    case freeze
}

@Model
class DayLog{
    
    var dayStatus : DayStatus
    var loggedAt : Date
    
    init(dayStatus : DayStatus , loggedAt : Date = Date()){
        self.dayStatus = dayStatus
        self.loggedAt = loggedAt
    }
    
}

import Observation
import Foundation
import SwiftData



@Observable
class ActivityViewModel {
    let goal: LearningGoal
    var now = Date()

    init(goal: LearningGoal) {
        self.goal = goal
    }

    // MARK: - Today
    
    func refresh(){
        now = Date()
    }

    var todayStatus: DayStatus? {
        goal.log(on: now)?.dayStatus
    }

    var canLogToday: Bool {
        progress == .active && todayStatus != .learned
    }

    var canFreezeToday: Bool {
        progress == .active && todayStatus == nil && goal.usedFreezes < goal.duration.freezeLimit
    }
    
    // MARK: - Actions
    func logLearned(context: ModelContext) {
        refresh()
        guard canLogToday else { return }
        
        if let existing = goal.log(on: now) {
            existing.dayStatus = .learned
            existing.loggedAt = Date()
            try? context.save()
        } else {
            record(.learned, context: context)
        }
    }

    func logFreeze(context: ModelContext) {
        refresh()
        guard canFreezeToday else { return }
        record(.freeze, context: context)
    }

    private func record(_ status: DayStatus, context: ModelContext) {
        let log = DayLog(dayStatus: status)
        context.insert(log)
        goal.logs.append(log)
        try? context.save()
    }

    // MARK: - Counts
    var learnedCount: Int {
        goal.logs.filter { $0.dayStatus == .learned }.count
    }

    var freezeCount: Int {
        goal.usedFreezes
    }
    
    var freezeUsageText: String {
        "\(goal.usedFreezes) out of \(goal.duration.freezeLimit) Freezes used"
    }

    // MARK: - Streak
    var currentStreak: Int {
        streak(now: now)
    }

    func streak(now: Date = Date()) -> Int {
        let limit: TimeInterval = 32 * 60 * 60
        let events = goal.logs.sorted { $0.loggedAt < $1.loggedAt }
        var count = 0
        var previous = goal.startDate

        for log in events {
            if log.loggedAt.timeIntervalSince(previous) > limit {
                count = 0
            }
            if log.dayStatus == .learned {
                count += 1
            }
            previous = log.loggedAt
        }

        if now.timeIntervalSince(previous) > limit {
            return 0
        }
        return count
    }

    // MARK: - Week
    var weekDays: [Date] {
        let calendar = Calendar.current
        guard let start = calendar.dateInterval(of: .weekOfYear, for: now)?.start else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    func status(on day: Date) -> DayStatus? {
        goal.log(on: day)?.dayStatus
    }
    
    //MARK: - Goal Completion
    
    var progress: GoalProgress {
        guard now >= goal.endDate else { return .active }
        return goal.hasFullCoverage ? .succeeded : .failed
    }
}
